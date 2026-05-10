import 'package:readline_app/core/services/content_generation/content_generation_config.dart';
import 'package:readline_app/core/services/content_generation/magic_content_settings_service.dart';
import 'package:readline_app/core/services/content_generation/openai_compatible_content_generation_service.dart';
import 'package:readline_app/data/contracts/content_generation_service.dart';

/// Function type used to build the inner Groq service. Tests inject a
/// stubbed builder; production uses the default which constructs a real
/// `OpenAiCompatibleContentGenerationService`.
typedef ContentGenerationServiceBuilder = ContentGenerationService Function(
  String apiKey,
);

/// Wraps a real provider service behind the user's settings. Reports
/// unavailable when the feature is disabled or no API key is saved; rebuilds
/// the inner service when the saved key changes.
class SettingsAwareContentGenerationService implements ContentGenerationService {
  final MagicContentSettingsService _settings;
  final ContentGenerationServiceBuilder _builder;

  ContentGenerationService? _cachedInner;
  String? _cachedKey;

  SettingsAwareContentGenerationService(
    this._settings, {
    ContentGenerationServiceBuilder? builder,
  }) : _builder = builder ?? _defaultBuilder;

  static ContentGenerationService _defaultBuilder(String apiKey) =>
      OpenAiCompatibleContentGenerationService(
        config: ContentGenerationConfig.groq(apiKey: apiKey),
      );

  @override
  Future<bool> isAvailable() async {
    final inner = await _resolve();
    if (inner == null) return false;
    return inner.isAvailable();
  }

  @override
  Future<ContentGenerationResult> generate(
    ContentGenerationRequest request,
  ) async {
    final inner = await _resolve();
    if (inner == null) {
      return const ContentGenerationResult(
        error: ContentGenerationError.server,
      );
    }
    return inner.generate(request);
  }

  Future<ContentGenerationService?> _resolve() async {
    if (!await _settings.isEnabled()) {
      _cachedInner = null;
      _cachedKey = null;
      return null;
    }
    final key = await _settings.getKey();
    if (key == null || key.isEmpty) {
      _cachedInner = null;
      _cachedKey = null;
      return null;
    }
    if (_cachedKey != key) {
      _cachedInner = _builder(key);
      _cachedKey = key;
    }
    return _cachedInner;
  }
}
