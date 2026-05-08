import 'package:rxdart/rxdart.dart';
import 'package:readline_app/core/constants/personal_links.dart';
import 'package:readline_app/core/services/form_submission_service.dart';

class SupportViewModel {
  final FormSubmissionService _formService;
  final String _formUrl;
  final Map<String, String> _entryKeys;

  final BehaviorSubject<bool> isSubmitting$ = BehaviorSubject.seeded(false);

  SupportViewModel._({
    required FormSubmissionService formService,
    required String formUrl,
    required Map<String, String> entryKeys,
  })  : _formService = formService,
        _formUrl = formUrl,
        _entryKeys = entryKeys;

  factory SupportViewModel.bugReport({FormSubmissionService? formService}) {
    return SupportViewModel._(
      formService: formService ?? FormSubmissionService(),
      formUrl: PersonalLinks.getByName('bug-reporting-url')!,
      entryKeys: {
        'appName': PersonalLinks.getByName('bug-reporting-app-name-entry')!,
        'name': PersonalLinks.getByName('bug-reporting-name-entry')!,
        'subject': PersonalLinks.getByName('bug-reporting-subject-entry')!,
        'description':
            PersonalLinks.getByName('bug-reporting-description-entry')!,
      },
    );
  }

  factory SupportViewModel.helpSupport({FormSubmissionService? formService}) {
    return SupportViewModel._(
      formService: formService ?? FormSubmissionService(),
      formUrl: PersonalLinks.getByName('support-url')!,
      entryKeys: {
        'appName': PersonalLinks.getByName('support-app-name-entry')!,
        'name': PersonalLinks.getByName('support-name-entry')!,
        'subject': PersonalLinks.getByName('support-subject-entry')!,
        'description': PersonalLinks.getByName('support-description-entry')!,
      },
    );
  }

  Future<FormSubmissionResult> submit({
    required String name,
    required String subject,
    required String description,
  }) async {
    if (isSubmitting$.value) {
      return const FormSubmissionResult(
        success: false,
        error: 'Already submitting',
      );
    }
    isSubmitting$.add(true);
    try {
      return await _formService.submit(
        url: _formUrl,
        body: {
          _entryKeys['appName']!: 'readline',
          _entryKeys['name']!: name,
          _entryKeys['subject']!: subject,
          _entryKeys['description']!: description,
        },
      );
    } finally {
      if (!isSubmitting$.isClosed) isSubmitting$.add(false);
    }
  }

  void dispose() {
    isSubmitting$.close();
  }
}
