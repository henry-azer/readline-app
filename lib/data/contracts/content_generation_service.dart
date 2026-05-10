enum ContentGenerationError { network, timeout, empty, server }

class GeneratedContent {
  final String title;
  final String body;

  const GeneratedContent({required this.title, required this.body});
}

class ContentGenerationResult {
  final GeneratedContent? content;
  final ContentGenerationError? error;

  const ContentGenerationResult({this.content, this.error});

  bool get isSuccess => content != null;
}

enum ContentDifficulty { beginner, intermediate, advanced }

class ContentGenerationRequest {
  final String category;
  final int wordCount;
  final ContentDifficulty difficulty;
  final String? topic;

  const ContentGenerationRequest({
    required this.category,
    required this.wordCount,
    required this.difficulty,
    this.topic,
  });
}

abstract class ContentGenerationService {
  Future<bool> isAvailable();

  Future<ContentGenerationResult> generate(ContentGenerationRequest request);
}
