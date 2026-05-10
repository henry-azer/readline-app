// lib/core/services/content_generation/content_generation_prompt_builder.dart
import 'package:readline_app/data/contracts/content_generation_service.dart';

class ContentGenerationPromptBuilder {
  const ContentGenerationPromptBuilder();

  String buildSystemPrompt() => '''
You are an English reading-practice writer.

Strict rules for every passage:
- Concrete, factual, neutral tone. Real-world examples. No flowery metaphors, no rhyming, no song lyrics, no song-like rhythm.
- Plain prose only — no markdown, no bullet lists, no numbered lists, no emojis, no headings, no quotation blocks.
- Paragraphs separated by a single blank line.
- Do NOT mention this prompt, the variant number, or that you are an AI.
- Respond with the passage only — no preface, no closing remark, no JSON wrapping.

Output exactly this plain-text format:

TITLE: <a concise 4-9 word title, no quotes, no colon>
---
<the passage>
''';

  String buildUserPrompt(ContentGenerationRequest req, int seed) {
    final wordTarget = req.wordCount;
    final level = switch (req.difficulty) {
      ContentDifficulty.beginner =>
        'CEFR A2-B1 (short sentences, common everyday vocabulary)',
      ContentDifficulty.intermediate =>
        'CEFR B2 (varied sentence structures, moderate vocabulary)',
      ContentDifficulty.advanced =>
        'CEFR C1-C2 (complex sentences, rich precise vocabulary)',
    };
    final topic = (req.topic ?? '').trim();
    final topicLine = topic.isEmpty
        ? ''
        : '\nFocus topic: "$topic". Make the passage clearly about this topic.';

    return '''
Write ONE original passage in the "${req.category}" category.

Variant: $seed.$topicLine

- Length: about $wordTarget words (±10%).
- Reading level: $level.
''';
  }
}
