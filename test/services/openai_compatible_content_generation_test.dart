import 'dart:convert';
import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:readline_app/core/services/content_generation/content_generation_config.dart';
import 'package:readline_app/core/services/content_generation/openai_compatible_content_generation_service.dart';
import 'package:readline_app/data/contracts/content_generation_service.dart';

void main() {
  const sampleRequest = ContentGenerationRequest(
    category: 'general',
    wordCount: 150,
    difficulty: ContentDifficulty.intermediate,
  );

  ContentGenerationConfig groqConfig() => ContentGenerationConfig.groq(
        apiKey: 'test-key',
      );

  String chatResponse(String content) => jsonEncode({
        'choices': [
          {
            'message': {'role': 'assistant', 'content': content},
          },
        ],
      });

  OpenAiCompatibleContentGenerationService serviceReturning(
    String content, {
    int statusCode = 200,
  }) {
    final client = MockClient((_) async => http.Response(
          statusCode == 200 ? chatResponse(content) : content,
          statusCode,
          headers: const {'content-type': 'application/json'},
        ));
    return OpenAiCompatibleContentGenerationService(
      config: groqConfig(),
      client: client,
      random: Random(0),
    );
  }

  group('generate — success', () {
    test('returns parsed passage from choices[0].message.content', () async {
      final service = serviceReturning(
        'TITLE: A Quiet Morning\n---\nThe harbor was still.',
      );
      final result = await service.generate(sampleRequest);
      expect(result.isSuccess, true);
      expect(result.content!.title, 'A Quiet Morning');
      expect(result.content!.body.startsWith('The harbor'), true);
    });

    test('sends correct request body', () async {
      late http.Request capturedRequest;
      final client = MockClient((req) async {
        capturedRequest = req;
        return http.Response(
          chatResponse('TITLE: X\n---\nBody.'),
          200,
          headers: const {'content-type': 'application/json'},
        );
      });
      final service = OpenAiCompatibleContentGenerationService(
        config: groqConfig(),
        client: client,
        random: Random(42),
      );
      await service.generate(sampleRequest);

      expect(capturedRequest.method, 'POST');
      expect(capturedRequest.url.toString(),
          'https://api.groq.com/openai/v1/chat/completions');
      expect(capturedRequest.headers['authorization'], 'Bearer test-key');
      expect(capturedRequest.headers['content-type'], contains('application/json'));

      final body = jsonDecode(capturedRequest.body) as Map<String, dynamic>;
      expect(body['model'], 'llama-3.3-70b-versatile');
      expect(body['temperature'], 0.85);
      expect(body['seed'], isA<int>());
      final messages = body['messages'] as List;
      expect(messages, hasLength(2));
      expect(messages[0]['role'], 'system');
      expect(messages[0]['content'], contains('TITLE:'));
      expect(messages[1]['role'], 'user');
      expect(messages[1]['content'], contains('"general"'));
      expect(messages[1]['content'], contains('150 words'));
    });
  });

  group('generate — error mapping', () {
    test('401 → server', () async {
      final service = serviceReturning('Unauthorized', statusCode: 401);
      final result = await service.generate(sampleRequest);
      expect(result.isSuccess, false);
      expect(result.error, ContentGenerationError.server);
    });

    test('403 → server', () async {
      final service = serviceReturning('Forbidden', statusCode: 403);
      final result = await service.generate(sampleRequest);
      expect(result.error, ContentGenerationError.server);
    });

    test('429 → server', () async {
      final service = serviceReturning('Rate limited', statusCode: 429);
      final result = await service.generate(sampleRequest);
      expect(result.error, ContentGenerationError.server);
    });

    test('5xx → server', () async {
      final service = serviceReturning('upstream', statusCode: 502);
      final result = await service.generate(sampleRequest);
      expect(result.error, ContentGenerationError.server);
    });

    test('200 with no choices → empty', () async {
      final client = MockClient((_) async => http.Response(
            jsonEncode({'choices': []}),
            200,
            headers: const {'content-type': 'application/json'},
          ));
      final service = OpenAiCompatibleContentGenerationService(
        config: groqConfig(),
        client: client,
      );
      final result = await service.generate(sampleRequest);
      expect(result.error, ContentGenerationError.empty);
    });

    test('200 with empty content → empty', () async {
      final service = serviceReturning('');
      final result = await service.generate(sampleRequest);
      expect(result.error, ContentGenerationError.empty);
    });

    test('200 with refusal in content → empty', () async {
      final service = serviceReturning(
        "I'm sorry, but I can't produce that.",
      );
      final result = await service.generate(sampleRequest);
      expect(result.error, ContentGenerationError.empty);
    });

    test('network failure → network', () async {
      final client = MockClient((_) async {
        throw http.ClientException('connection refused');
      });
      final service = OpenAiCompatibleContentGenerationService(
        config: groqConfig(),
        client: client,
      );
      final result = await service.generate(sampleRequest);
      expect(result.error, ContentGenerationError.network);
    });
  });

  group('isAvailable', () {
    test('200 from /models → true', () async {
      final client = MockClient((req) async {
        expect(req.url.toString(),
            'https://api.groq.com/openai/v1/models');
        expect(req.headers['authorization'], 'Bearer test-key');
        return http.Response('{}', 200);
      });
      final service = OpenAiCompatibleContentGenerationService(
        config: groqConfig(),
        client: client,
      );
      expect(await service.isAvailable(), true);
    });

    test('401 from /models → false', () async {
      final client = MockClient((_) async => http.Response('nope', 401));
      final service = OpenAiCompatibleContentGenerationService(
        config: groqConfig(),
        client: client,
      );
      expect(await service.isAvailable(), false);
    });

    test('network failure → false (no throw)', () async {
      final client = MockClient((_) async {
        throw http.ClientException('boom');
      });
      final service = OpenAiCompatibleContentGenerationService(
        config: groqConfig(),
        client: client,
      );
      expect(await service.isAvailable(), false);
    });
  });
}
