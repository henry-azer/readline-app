import 'package:rxdart/rxdart.dart';
import 'package:readline_app/core/di/injection.dart';
import 'package:readline_app/data/contracts/content_generation_service.dart';

class MagicContentCategory {
  final String id;
  final String labelKey;

  const MagicContentCategory({required this.id, required this.labelKey});
}

/// Length presets surfaced in the UI. Mapped to concrete word counts at
/// generation time so the service contract stays preset-agnostic.
enum MagicContentLength { short, medium, long }

class MagicContentViewModel {
  /// Word-count targets per preset. `long` matches Groq's safe per-request
  /// output budget for Llama 3.3 70B; `medium` is half of that; `short` sits
  /// at a quick reading session length.
  static const int shortWordCount = 750;
  static const int mediumWordCount = 2500;
  static const int longWordCount = 5000;

  final ContentGenerationService _service;

  MagicContentViewModel({ContentGenerationService? service})
    : _service = service ?? getIt<ContentGenerationService>();

  static const categories = <MagicContentCategory>[
    MagicContentCategory(id: 'general', labelKey: 'magic.categoryGeneral'),
    MagicContentCategory(id: 'science', labelKey: 'magic.categoryScience'),
    MagicContentCategory(id: 'history', labelKey: 'magic.categoryHistory'),
    MagicContentCategory(
      id: 'technology',
      labelKey: 'magic.categoryTechnology',
    ),
    MagicContentCategory(id: 'nature', labelKey: 'magic.categoryNature'),
    MagicContentCategory(id: 'business', labelKey: 'magic.categoryBusiness'),
    MagicContentCategory(
      id: 'philosophy',
      labelKey: 'magic.categoryPhilosophy',
    ),
    MagicContentCategory(id: 'travel', labelKey: 'magic.categoryTravel'),
    MagicContentCategory(id: 'culture', labelKey: 'magic.categoryCulture'),
    MagicContentCategory(id: 'health', labelKey: 'magic.categoryHealth'),
  ];

  final BehaviorSubject<String> selectedCategory$ = BehaviorSubject.seeded(
    'general',
  );
  final BehaviorSubject<MagicContentLength> selectedLength$ =
      BehaviorSubject.seeded(MagicContentLength.medium);
  final BehaviorSubject<ContentDifficulty> selectedDifficulty$ =
      BehaviorSubject.seeded(ContentDifficulty.intermediate);
  final BehaviorSubject<String> topic$ = BehaviorSubject.seeded('');
  final BehaviorSubject<bool> isGenerating$ = BehaviorSubject.seeded(false);
  final BehaviorSubject<ContentGenerationError?> error$ =
      BehaviorSubject.seeded(null);

  void setCategory(String id) => selectedCategory$.add(id);

  void setLength(MagicContentLength length) => selectedLength$.add(length);

  void setDifficulty(ContentDifficulty difficulty) =>
      selectedDifficulty$.add(difficulty);

  void setTopic(String value) => topic$.add(value);

  Future<GeneratedContent?> generate() async {
    if (isGenerating$.value) return null;
    isGenerating$.add(true);
    error$.add(null);

    final categoryId = selectedCategory$.value;
    final categoryLabel = categories
        .firstWhere(
          (c) => c.id == categoryId,
          orElse: () => categories.first,
        )
        .id;

    final result = await _service.generate(
      ContentGenerationRequest(
        category: categoryLabel,
        wordCount: _wordCountFor(selectedLength$.value),
        difficulty: selectedDifficulty$.value,
        topic: topic$.value.trim().isEmpty ? null : topic$.value.trim(),
      ),
    );

    isGenerating$.add(false);
    if (result.isSuccess) return result.content;
    error$.add(result.error);
    return null;
  }

  int _wordCountFor(MagicContentLength length) => switch (length) {
    MagicContentLength.short => shortWordCount,
    MagicContentLength.medium => mediumWordCount,
    MagicContentLength.long => longWordCount,
  };

  void dispose() {
    selectedCategory$.close();
    selectedLength$.close();
    selectedDifficulty$.close();
    topic$.close();
    isGenerating$.close();
    error$.close();
  }
}
