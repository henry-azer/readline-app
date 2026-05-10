// lib/core/services/content_generation/openai_compatible_content_generation_service.dart
import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:http/http.dart' as http;
import 'package:readline_app/core/services/content_generation/content_generation_config.dart';
import 'package:readline_app/core/services/content_generation/content_generation_prompt_builder.dart';
import 'package:readline_app/core/services/content_generation/content_generation_response_parser.dart';
import 'package:readline_app/data/contracts/content_generation_service.dart';

class OpenAiCompatibleContentGenerationService
    implements ContentGenerationService {
  final ContentGenerationConfig _config;
  final ContentGenerationPromptBuilder _promptBuilder;
  final ContentGenerationResponseParser _parser;
  final http.Client _client;
  final Random _random;

  OpenAiCompatibleContentGenerationService({
    required ContentGenerationConfig config,
    ContentGenerationPromptBuilder? promptBuilder,
    ContentGenerationResponseParser? parser,
    http.Client? client,
    Random? random,
  })  : _config = config,
        _promptBuilder = promptBuilder ?? const ContentGenerationPromptBuilder(),
        _parser = parser ?? const ContentGenerationResponseParser(),
        _client = client ?? http.Client(),
        _random = random ?? Random();

  @override
  Future<bool> isAvailable() async {
    try {
      final response = await _client
          .get(
            Uri.parse('${_config.baseUrl}/models'),
            headers: {'Authorization': 'Bearer ${_config.apiKey}'},
          )
          .timeout(_config.availabilityTimeout);
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }

  @override
  Future<ContentGenerationResult> generate(
    ContentGenerationRequest request,
  ) async {
    final seed = _random.nextInt(1 << 31);
    final body = jsonEncode({
      'model': _config.modelId,
      'temperature': _config.temperature,
      'seed': seed,
      'messages': [
        {'role': 'system', 'content': _promptBuilder.buildSystemPrompt()},
        {
          'role': 'user',
          'content': _promptBuilder.buildUserPrompt(request, seed),
        },
      ],
    });

    try {
      final response = await _client
          .post(
            Uri.parse('${_config.baseUrl}/chat/completions'),
            headers: {
              'Authorization': 'Bearer ${_config.apiKey}',
              'Content-Type': 'application/json',
            },
            body: body,
          )
          .timeout(_config.generateTimeout);

      if (response.statusCode < 200 || response.statusCode >= 300) {
        return const ContentGenerationResult(
          error: ContentGenerationError.server,
        );
      }

      final content = _extractContent(response.body);
      if (content == null || content.trim().isEmpty) {
        return const ContentGenerationResult(
          error: ContentGenerationError.empty,
        );
      }

      final parsed = _parser.parse(content);
      if (parsed == null) {
        return const ContentGenerationResult(
          error: ContentGenerationError.empty,
        );
      }
      return ContentGenerationResult(content: parsed);
    } on TimeoutException {
      return const ContentGenerationResult(
        error: ContentGenerationError.timeout,
      );
    } on http.ClientException {
      return const ContentGenerationResult(
        error: ContentGenerationError.network,
      );
    } catch (_) {
      return const ContentGenerationResult(
        error: ContentGenerationError.network,
      );
    }
  }

  String? _extractContent(String responseBody) {
    try {
      final decoded = jsonDecode(responseBody);
      if (decoded is! Map<String, dynamic>) return null;
      final choices = decoded['choices'];
      if (choices is! List || choices.isEmpty) return null;
      final first = choices.first;
      if (first is! Map<String, dynamic>) return null;
      final message = first['message'];
      if (message is Map<String, dynamic>) {
        final content = message['content'];
        if (content is String) return content;
      }
      final text = first['text'];
      if (text is String) return text;
      return null;
    } catch (_) {
      return null;
    }
  }

  void dispose() {
    _client.close();
  }
}
