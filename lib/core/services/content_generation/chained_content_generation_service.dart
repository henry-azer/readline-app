import 'package:readline_app/data/contracts/content_generation_service.dart';

class ChainedContentGenerationService implements ContentGenerationService {
  final List<ContentGenerationService> _providers;

  ChainedContentGenerationService(this._providers)
      : assert(_providers.isNotEmpty,
            'ChainedContentGenerationService requires at least one provider');

  @override
  Future<bool> isAvailable() async {
    for (final provider in _providers) {
      if (await provider.isAvailable()) return true;
    }
    return false;
  }

  @override
  Future<ContentGenerationResult> generate(
    ContentGenerationRequest request,
  ) async {
    ContentGenerationResult? lastResult;
    for (final provider in _providers) {
      final result = await provider.generate(request);
      if (result.isSuccess) return result;

      // Fall through on transport-class errors only.
      if (result.error == ContentGenerationError.network ||
          result.error == ContentGenerationError.server ||
          result.error == ContentGenerationError.timeout) {
        lastResult = result;
        continue;
      }

      // empty (real refusal) — do not retry, surface immediately.
      return result;
    }
    return lastResult ??
        const ContentGenerationResult(error: ContentGenerationError.server);
  }
}
