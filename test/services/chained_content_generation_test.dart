import 'package:flutter_test/flutter_test.dart';
import 'package:readline_app/core/services/content_generation/chained_content_generation_service.dart';
import 'package:readline_app/data/contracts/content_generation_service.dart';

class _FakeService implements ContentGenerationService {
  _FakeService({this.available = true, required this.result});

  final bool available;
  final ContentGenerationResult result;
  int generateCalls = 0;

  @override
  Future<bool> isAvailable() async => available;

  @override
  Future<ContentGenerationResult> generate(
      ContentGenerationRequest request) async {
    generateCalls++;
    return result;
  }
}

void main() {
  const request = ContentGenerationRequest(
    category: 'general',
    wordCount: 150,
    difficulty: ContentDifficulty.intermediate,
  );

  test('throws when constructed with empty list', () {
    expect(() => ChainedContentGenerationService(const []),
        throwsA(isA<AssertionError>()));
  });

  group('generate', () {
    test('single-provider chain delegates verbatim', () async {
      final inner = _FakeService(
        result: const ContentGenerationResult(
          content: GeneratedContent(title: 't', body: 'b'),
        ),
      );
      final chain = ChainedContentGenerationService([inner]);
      final result = await chain.generate(request);
      expect(result.isSuccess, true);
      expect(inner.generateCalls, 1);
    });

    test('returns first success without calling later providers', () async {
      final first = _FakeService(
        result: const ContentGenerationResult(
          content: GeneratedContent(title: 't', body: 'b'),
        ),
      );
      final second = _FakeService(
        result: const ContentGenerationResult(
          error: ContentGenerationError.network,
        ),
      );
      final chain = ChainedContentGenerationService([first, second]);
      await chain.generate(request);
      expect(first.generateCalls, 1);
      expect(second.generateCalls, 0);
    });

    test('falls through on network → eventually returns success from later provider', () async {
      final first = _FakeService(
        result: const ContentGenerationResult(
          error: ContentGenerationError.network,
        ),
      );
      final second = _FakeService(
        result: const ContentGenerationResult(
          content: GeneratedContent(title: 't', body: 'b'),
        ),
      );
      final chain = ChainedContentGenerationService([first, second]);
      final result = await chain.generate(request);
      expect(result.isSuccess, true);
      expect(first.generateCalls, 1);
      expect(second.generateCalls, 1);
    });

    test('falls through on server', () async {
      final first = _FakeService(
        result: const ContentGenerationResult(
          error: ContentGenerationError.server,
        ),
      );
      final second = _FakeService(
        result: const ContentGenerationResult(
          content: GeneratedContent(title: 't', body: 'b'),
        ),
      );
      final chain = ChainedContentGenerationService([first, second]);
      final result = await chain.generate(request);
      expect(result.isSuccess, true);
      expect(second.generateCalls, 1);
    });

    test('falls through on timeout', () async {
      final first = _FakeService(
        result: const ContentGenerationResult(
          error: ContentGenerationError.timeout,
        ),
      );
      final second = _FakeService(
        result: const ContentGenerationResult(
          content: GeneratedContent(title: 't', body: 'b'),
        ),
      );
      final chain = ChainedContentGenerationService([first, second]);
      final result = await chain.generate(request);
      expect(result.isSuccess, true);
    });

    test('does NOT fall through on empty (real refusal)', () async {
      final first = _FakeService(
        result: const ContentGenerationResult(
          error: ContentGenerationError.empty,
        ),
      );
      final second = _FakeService(
        result: const ContentGenerationResult(
          content: GeneratedContent(title: 't', body: 'b'),
        ),
      );
      final chain = ChainedContentGenerationService([first, second]);
      final result = await chain.generate(request);
      expect(result.isSuccess, false);
      expect(result.error, ContentGenerationError.empty);
      expect(second.generateCalls, 0);
    });

    test('all providers fail with transport errors → returns last error', () async {
      final first = _FakeService(
        result: const ContentGenerationResult(
          error: ContentGenerationError.network,
        ),
      );
      final second = _FakeService(
        result: const ContentGenerationResult(
          error: ContentGenerationError.server,
        ),
      );
      final chain = ChainedContentGenerationService([first, second]);
      final result = await chain.generate(request);
      expect(result.isSuccess, false);
      expect(result.error, ContentGenerationError.server);
    });
  });

  group('isAvailable', () {
    test('returns true if any provider is available', () async {
      final first = _FakeService(
        available: false,
        result: const ContentGenerationResult(),
      );
      final second = _FakeService(
        available: true,
        result: const ContentGenerationResult(),
      );
      final chain = ChainedContentGenerationService([first, second]);
      expect(await chain.isAvailable(), true);
    });

    test('returns false if no provider is available', () async {
      final first = _FakeService(
        available: false,
        result: const ContentGenerationResult(),
      );
      final chain = ChainedContentGenerationService([first]);
      expect(await chain.isAvailable(), false);
    });
  });
}
