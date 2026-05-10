import 'dart:async';
import 'package:http/http.dart' as http;

enum GroqCredentialResult { valid, unauthorized, network, server }

/// Probes Groq's `/models` endpoint with a candidate API key and reports
/// whether the key is usable. Lives outside `OpenAiCompatibleContent
/// GenerationService` because the Settings UI tests credentials before any
/// service is registered, and because the result signals (valid /
/// unauthorized / network / server) are different from the generation-time
/// `ContentGenerationError` set.
class GroqCredentialValidator {
  static const _modelsUrl = 'https://api.groq.com/openai/v1/models';
  static const _timeout = Duration(seconds: 8);

  final http.Client _client;

  GroqCredentialValidator({http.Client? client})
      : _client = client ?? http.Client();

  Future<GroqCredentialResult> validate(String apiKey) async {
    if (apiKey.trim().isEmpty) return GroqCredentialResult.unauthorized;
    try {
      final response = await _client
          .get(
            Uri.parse(_modelsUrl),
            headers: {'Authorization': 'Bearer ${apiKey.trim()}'},
          )
          .timeout(_timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return GroqCredentialResult.valid;
      }
      if (response.statusCode == 401 || response.statusCode == 403) {
        return GroqCredentialResult.unauthorized;
      }
      return GroqCredentialResult.server;
    } on TimeoutException {
      return GroqCredentialResult.network;
    } on http.ClientException {
      return GroqCredentialResult.network;
    } catch (_) {
      return GroqCredentialResult.network;
    }
  }
}
