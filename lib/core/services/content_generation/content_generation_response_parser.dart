import 'dart:convert';

import 'package:readline_app/data/contracts/content_generation_service.dart';

class ContentGenerationResponseParser {
  const ContentGenerationResponseParser();

  GeneratedContent? parse(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) return null;

    // The GET endpoint occasionally returns the raw OpenAI assistant
    // message JSON (e.g. {"role":"assistant","reasoning":"...","content":...}).
    // Without this step, the regex below would happily find a `TITLE:`
    // string inside the *reasoning* trace and produce a corrupt title and
    // a body that's actually still JSON. Unwrap envelopes first.
    final unwrapped = _unwrapEnvelope(trimmed);
    if (unwrapped != null) {
      if (unwrapped.trim().isEmpty) return null;
      // Recurse with the extracted text (now plain prose).
      return parse(unwrapped);
    }

    // Detect refusal responses ("I'm sorry, but I can't…") so we don't
    // persist them as if they were the requested passage.
    if (_looksLikeRefusal(trimmed)) return null;

    // Strategy:
    //   1. Prefer the explicit `TITLE: ... --- body` format we asked for.
    //      Sanitize: if title or body is JSON-shaped, unwrap it.
    //   2. Otherwise try parsing the whole response as JSON.
    //   3. Otherwise treat the first line as the title.
    final fromExplicit = _parseExplicitFormat(trimmed);
    if (fromExplicit != null) return fromExplicit;

    final fromJson = _tryParseJson(trimmed);
    if (fromJson != null) return fromJson;

    final lines = trimmed.split('\n');
    final firstNonEmpty = lines.firstWhere(
      (l) => l.trim().isNotEmpty,
      orElse: () => '',
    );
    if (firstNonEmpty.isEmpty) return null;
    final fallbackTitle = _sanitizeTitle(
      firstNonEmpty
          .replaceFirst(RegExp(r'^TITLE\s*:\s*', caseSensitive: false), '')
          .trim(),
    );
    final restIndex = trimmed.indexOf(firstNonEmpty) + firstNonEmpty.length;
    final fallbackBody = _sanitizeBody(trimmed.substring(restIndex));
    if (fallbackBody.isEmpty) {
      final body = _sanitizeBody(trimmed);
      return GeneratedContent(
        title: fallbackTitle.isEmpty ? _titleFromBody(body) : fallbackTitle,
        body: body,
      );
    }
    return GeneratedContent(
      title: fallbackTitle.isEmpty ? _titleFromBody(fallbackBody) : fallbackTitle,
      body: fallbackBody,
    );
  }

  GeneratedContent? _parseExplicitFormat(String input) {
    final titleMatch = RegExp(
      r'^\s*TITLE\s*:\s*(.+?)\s*$',
      multiLine: true,
    ).firstMatch(input);
    final separatorIndex = input.indexOf('---');
    if (titleMatch == null || separatorIndex == -1) return null;

    final rawTitle = titleMatch.group(1)!.trim();
    final rawBody = input.substring(separatorIndex + 3);

    final body = _sanitizeBody(rawBody);
    if (body.isEmpty) return null;

    final sanitized = _sanitizeTitle(rawTitle);
    final title = sanitized.isEmpty ? _titleFromBody(body) : sanitized;

    return GeneratedContent(title: title, body: body);
  }

  // If [body] starts with a JSON object that has a body-ish field, use that
  // value as the body. Otherwise return the body cleaned of trailing
  // separators. This protects users from raw JSON ending up in the reading
  // content field when the model wraps the passage in a JSON envelope.
  String _sanitizeBody(String input) {
    var body = _cleanBody(input);
    if (body.isEmpty) return body;

    // Strip leading markdown fences like ```json ... ```
    body = body
        .replaceFirst(RegExp(r'^```(?:json|JSON)?\s*\n'), '')
        .replaceFirst(RegExp(r'\n```\s*$'), '')
        .trim();

    if (!body.startsWith('{')) return body;

    final jsonString = _extractJsonObject(body);
    if (jsonString == null) return body;

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) return body;
      final unwrapped = _unwrapNested(decoded) ?? decoded;
      final extracted = _firstString(unwrapped, const [
        'body',
        'passage',
        'content',
        'text',
        'article',
        'story',
      ]);
      if (extracted == null || extracted.trim().isEmpty) return body;
      return _cleanBody(extracted);
    } catch (_) {
      return body;
    }
  }

  // Drops surrounding quotes/braces, then rejects the title outright if it
  // still looks like JSON or contains JSON-like punctuation noise — the
  // caller will fall back to a body-derived title in that case.
  String _sanitizeTitle(String input) {
    var title = input.trim();

    // Strip "Variant 12345:" prefix — the model frequently echoes the
    // cache-buster seed straight into the title field.
    title = title
        .replaceFirst(
          RegExp(r'^Variant\s+\d+\s*[:\-—]\s*', caseSensitive: false),
          '',
        )
        .trim();

    // Strip surrounding quote characters (straight + smart).
    title = title.replaceAll(RegExp(r'^["“”«]+|["“”»]+$'), '').trim();

    // Strip surrounding markdown emphasis / heading punctuation on BOTH
    // ends (was previously leading-only, leaving e.g. "Title*" intact).
    title = title.replaceAll(RegExp(r'^[*_~#>\-]+|[*_~#>\-]+$'), '').trim();

    // Trim trailing terminal punctuation that doesn't belong in titles.
    title = title.replaceAll(RegExp(r'[.,;:]+$'), '').trim();

    if (title.isEmpty) return '';
    // Looks like JSON or contains structural punctuation we don't want in
    // a human-readable title.
    if (title.startsWith('{') ||
        title.startsWith('[') ||
        RegExp(r'"\s*:\s*"').hasMatch(title) ||
        title.contains('": "')) {
      return '';
    }
    return title;
  }

  /// Pulls the assistant's actual prose out of a raw OpenAI-style chat
  /// message envelope. Returns:
  /// - the extracted content string when the input is an envelope and
  ///   contains a non-empty `content` (or `choices[0].message.content`);
  /// - an empty string when the input is recognisably an envelope but has
  ///   no usable content (so the caller treats it as an empty result, not
  ///   as text to parse);
  /// - null when the input isn't a chat envelope at all.
  String? _unwrapEnvelope(String input) {
    final leading = input.trimLeft();
    if (!leading.startsWith('{') && !leading.startsWith('[')) return null;

    final jsonString = _extractJsonObject(leading);
    if (jsonString == null) return null;

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) return null;

      // Heuristic: this looks like an OpenAI / Pollinations chat envelope
      // if it carries any of these top-level keys.
      final isEnvelope = decoded.containsKey('role') ||
          decoded.containsKey('reasoning') ||
          decoded.containsKey('reasoning_content') ||
          decoded.containsKey('tool_calls') ||
          decoded.containsKey('choices') ||
          decoded.containsKey('message') ||
          decoded.containsKey('object');
      if (!isEnvelope) return null;

      // Direct content on the envelope itself.
      final direct = decoded['content'];
      if (direct is String && direct.trim().isNotEmpty) return direct;

      // {"message": {"content": "..."}}
      final message = decoded['message'];
      if (message is Map<String, dynamic>) {
        final mc = message['content'];
        if (mc is String && mc.trim().isNotEmpty) return mc;
      }

      // {"choices": [{"message": {"content": "..."}}]}
      final choices = decoded['choices'];
      if (choices is List && choices.isNotEmpty) {
        final first = choices.first;
        if (first is Map<String, dynamic>) {
          final msg = first['message'];
          if (msg is Map<String, dynamic>) {
            final c = msg['content'];
            if (c is String && c.trim().isNotEmpty) return c;
          }
          final t = first['text'];
          if (t is String && t.trim().isNotEmpty) return t;
        }
      }

      // Envelope detected but no usable content (model spent all tokens on
      // reasoning, refusal, etc.) — return empty string so the caller treats
      // the result as empty rather than parsing the JSON as plain text.
      return '';
    } catch (_) {
      return null;
    }
  }

  bool _looksLikeRefusal(String input) {
    final head = input.trim().toLowerCase();
    if (head.length > 200) return false; // refusals are short
    final refusalPatterns = [
      RegExp(r"^i['’]?m sorry"),
      RegExp(r"^sorry,?\s+(?:but\s+)?i\s+can'?t"),
      RegExp(r"^i can'?t (?:produce|generate|create|write)"),
      RegExp(r"^i cannot (?:produce|generate|create|write)"),
      RegExp(r"^i am (?:not )?(?:able|unable) to"),
      RegExp(r"^i won'?t be able to"),
      RegExp(r"^i['’]?m not able"),
    ];
    return refusalPatterns.any((re) => re.hasMatch(head));
  }

  GeneratedContent? _tryParseJson(String input) {
    final jsonString = _extractJsonObject(input);
    if (jsonString == null) return null;

    try {
      final decoded = jsonDecode(jsonString);
      if (decoded is! Map<String, dynamic>) return null;

      // Unwrap one level of nesting for shapes like {"data": {...}} or
      // {"choices": [{"message": {"content": "..."}}]}.
      final unwrapped = _unwrapNested(decoded);
      final source = unwrapped ?? decoded;

      final title = _firstString(source, const [
        'title',
        'heading',
        'name',
        'subject',
      ]);
      final body = _firstString(source, const [
        'body',
        'passage',
        'content',
        'text',
        'article',
        'story',
      ]);

      if (body == null || body.trim().isEmpty) return null;
      final cleanBody = _cleanBody(body);
      if (cleanBody.isEmpty) return null;
      final resolvedTitle = (title ?? '').trim();
      return GeneratedContent(
        title: resolvedTitle.isEmpty ? _titleFromBody(cleanBody) : resolvedTitle,
        body: cleanBody,
      );
    } catch (_) {
      return null;
    }
  }

  // Locates the first balanced top-level JSON object in [input], even when
  // the model wraps it in commentary or fences (```json ... ```).
  String? _extractJsonObject(String input) {
    final start = input.indexOf('{');
    if (start == -1) return null;

    var depth = 0;
    var inString = false;
    var escape = false;
    for (var i = start; i < input.length; i++) {
      final ch = input[i];
      if (inString) {
        if (escape) {
          escape = false;
        } else if (ch == r'\') {
          escape = true;
        } else if (ch == '"') {
          inString = false;
        }
        continue;
      }
      if (ch == '"') {
        inString = true;
      } else if (ch == '{') {
        depth++;
      } else if (ch == '}') {
        depth--;
        if (depth == 0) return input.substring(start, i + 1);
      }
    }
    return null;
  }

  Map<String, dynamic>? _unwrapNested(Map<String, dynamic> map) {
    for (final key in const ['data', 'result', 'response', 'output']) {
      final v = map[key];
      if (v is Map<String, dynamic>) return v;
    }
    final choices = map['choices'];
    if (choices is List && choices.isNotEmpty) {
      final first = choices.first;
      if (first is Map<String, dynamic>) {
        final message = first['message'];
        if (message is Map<String, dynamic>) {
          final content = message['content'];
          if (content is String) return {'body': content};
        }
        final text = first['text'];
        if (text is String) return {'body': text};
      }
    }
    return null;
  }

  String? _firstString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final v = map[key];
      if (v is String && v.trim().isNotEmpty) return v;
    }
    return null;
  }

  // Strips leading + trailing `---` separator lines and any surrounding
  // whitespace. The model occasionally echoes the TITLE/--- delimiter a
  // second time on its own line before the body, which would otherwise
  // leak "---" as a prefix on the rendered passage.
  String _cleanBody(String input) {
    var body = input.trim();
    while (true) {
      final stripped = body
          .replaceFirst(RegExp(r'^-{3,}[ \t]*(?:\n|$)'), '')
          .trim();
      if (stripped == body) break;
      body = stripped;
    }
    body = body.replaceAll(RegExp(r'\n?\s*-{3,}\s*$'), '').trim();
    return body;
  }

  // Builds a short, readable title from the opening of a passage when the
  // model didn't supply one (e.g. JSON without `title`, or unparseable
  // free-form output). Takes the first 4-7 content words from the leading
  // sentence and title-cases them.
  // Returns an empty string when no title can be derived, so the consumer
  // (import sheet) can render its localized hint placeholder rather than a
  // hard-coded English fallback.
  String _titleFromBody(String body) {
    final cleaned = body
        .replaceAll(RegExp(r'^\s*(TITLE|---)\s*:?\s*', caseSensitive: false), '')
        .trim();
    if (cleaned.isEmpty) return '';

    final firstSentence = cleaned.split(RegExp(r'(?<=[.!?])\s+')).first;
    final words = firstSentence
        .replaceAll(RegExp(r'[^\w\s\-’]'), '')
        .split(RegExp(r'\s+'))
        .where((w) => w.trim().isNotEmpty)
        .toList();
    if (words.isEmpty) return '';

    final picked = words.take(words.length < 5 ? words.length : 6).join(' ');
    return _titleCase(picked);
  }

  String _titleCase(String input) {
    const lowercase = {
      'a',
      'an',
      'and',
      'as',
      'at',
      'but',
      'by',
      'for',
      'in',
      'of',
      'on',
      'or',
      'the',
      'to',
      'with',
    };
    final words = input.split(' ');
    return words
        .asMap()
        .entries
        .map((e) {
          final w = e.value;
          if (w.isEmpty) return w;
          if (e.key != 0 && lowercase.contains(w.toLowerCase())) {
            return w.toLowerCase();
          }
          return w[0].toUpperCase() + w.substring(1).toLowerCase();
        })
        .join(' ');
  }
}
