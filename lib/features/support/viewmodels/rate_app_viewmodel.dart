import 'package:rxdart/rxdart.dart';
import 'package:readline_app/core/constants/personal_links.dart';
import 'package:readline_app/core/services/form_submission_service.dart';

/// Result of a rating submission attempt — typed so the screen doesn't have to
/// reach into stream values to decide which message to show.
enum RateSubmitOutcome {
  success,
  missingRating,
  alreadySubmitting,
  networkError,
}

class RateAppViewModel {
  final FormSubmissionService _formService;

  final BehaviorSubject<int> rating$ = BehaviorSubject.seeded(0);
  final BehaviorSubject<bool> isSubmitting$ = BehaviorSubject.seeded(false);

  RateAppViewModel({FormSubmissionService? formService})
    : _formService = formService ?? FormSubmissionService();

  void setRating(int rating) {
    rating$.add(rating);
  }

  Future<RateSubmitOutcome> submit({
    required String name,
    required String description,
  }) async {
    if (isSubmitting$.value) return RateSubmitOutcome.alreadySubmitting;
    if (rating$.value == 0) return RateSubmitOutcome.missingRating;

    isSubmitting$.add(true);
    try {
      final result = await _formService.submit(
        url: PersonalLinks.getByName('rating-url')!,
        body: {
          PersonalLinks.getByName('rating-app-name-entry')!: 'readline',
          PersonalLinks.getByName('rating-name-entry')!: name,
          PersonalLinks.getByName('rating-rate-entry')!: '${rating$.value}',
          PersonalLinks.getByName('rating-description-entry')!: description,
        },
      );
      return result.success
          ? RateSubmitOutcome.success
          : RateSubmitOutcome.networkError;
    } finally {
      if (!isSubmitting$.isClosed) isSubmitting$.add(false);
    }
  }

  void dispose() {
    rating$.close();
    isSubmitting$.close();
  }
}
