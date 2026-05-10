// lib/core/services/content_generation/content_generation_config.dart

enum ContentGenerationProvider { groq, openRouter, cerebras }

class ContentGenerationConfig {
  final ContentGenerationProvider provider;
  final String baseUrl;
  final String apiKey;
  final String modelId;
  final double temperature;
  final Duration availabilityTimeout;
  final Duration generateTimeout;

  const ContentGenerationConfig({
    required this.provider,
    required this.baseUrl,
    required this.apiKey,
    required this.modelId,
    this.temperature = 0.85,
    this.availabilityTimeout = const Duration(seconds: 4),
    this.generateTimeout = const Duration(seconds: 90),
  });

  factory ContentGenerationConfig.groq({
    required String apiKey,
    String modelId = 'llama-3.3-70b-versatile',
  }) => ContentGenerationConfig(
        provider: ContentGenerationProvider.groq,
        baseUrl: 'https://api.groq.com/openai/v1',
        apiKey: apiKey,
        modelId: modelId,
      );

  factory ContentGenerationConfig.openRouter({
    required String apiKey,
    required String modelId,
  }) => ContentGenerationConfig(
        provider: ContentGenerationProvider.openRouter,
        baseUrl: 'https://openrouter.ai/api/v1',
        apiKey: apiKey,
        modelId: modelId,
      );

  factory ContentGenerationConfig.cerebras({
    required String apiKey,
    String modelId = 'gpt-oss-120b',
  }) => ContentGenerationConfig(
        provider: ContentGenerationProvider.cerebras,
        baseUrl: 'https://api.cerebras.ai/v1',
        apiKey: apiKey,
        modelId: modelId,
      );
}
