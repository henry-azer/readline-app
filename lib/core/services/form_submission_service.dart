import 'package:http/http.dart' as http;

class FormSubmissionResult {
  final bool success;
  final String? error;

  const FormSubmissionResult({required this.success, this.error});
}

class FormSubmissionService {
  Future<FormSubmissionResult> submit({
    required String url,
    required Map<String, String> body,
  }) async {
    try {
      await http.post(Uri.parse(url), body: body);
      return const FormSubmissionResult(success: true);
    } catch (e) {
      return FormSubmissionResult(success: false, error: e.toString());
    }
  }
}
