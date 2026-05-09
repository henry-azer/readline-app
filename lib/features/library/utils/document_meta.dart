import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';
import 'package:readline_app/core/utils/date_formatter.dart';
import 'package:readline_app/data/models/document_model.dart';

/// Formatting helpers shared by the library grid card and list tile so the
/// two views agree on how word count and estimated reading time are
/// presented.
abstract final class DocumentMeta {
  /// Returns the total word count formatted with comma thousands separators.
  ///
  /// Examples: `0 → "0"`, `1234 → "1,234"`, `1234567 → "1,234,567"`.
  static String wordCount(int totalWords) {
    final s = totalWords.toString();
    if (s.length <= 3) return s;
    final buf = StringBuffer();
    final firstGroup = s.length % 3;
    if (firstGroup > 0) {
      buf.write(s.substring(0, firstGroup));
      if (s.length > firstGroup) buf.write(',');
    }
    for (var i = firstGroup; i < s.length; i += 3) {
      buf.write(s.substring(i, i + 3));
      if (i + 3 < s.length) buf.write(',');
    }
    return buf.toString();
  }

  /// Returns the human-readable reading time for [doc].
  ///
  /// - **Completed** documents prefer the actual time the user spent reading
  ///   (sum of session durations) when [actualMinutes] is provided and > 0,
  ///   formatted via [DateFormatter.duration] (e.g. "23 min", "1h 12m"),
  ///   so the label reflects what the user *did*, not a projection.
  /// - **In-progress** documents fall through to "~N min left" using
  ///   remaining words at [wpm].
  /// - **Unread** (and completed without recorded sessions) fall through to
  ///   "~N min total" using the full word count at [wpm].
  ///
  /// Returns `null` when nothing reasonable can be displayed.
  static String? estimatedTime(
    DocumentModel doc,
    int wpm, {
    double? actualMinutes,
  }) {
    if (doc.isCompleted &&
        actualMinutes != null &&
        actualMinutes > 0) {
      return DateFormatter.duration(actualMinutes);
    }
    if (wpm <= 0 || doc.totalWords <= 0) return null;
    if (doc.isInProgress) {
      final wordsLeft = doc.totalWords - doc.wordsRead;
      if (wordsLeft <= 0) return null;
      final mins = (wordsLeft / wpm).ceil();
      if (mins <= 0) return null;
      return AppStrings.homeEstimatedLeft.trParams({'n': '$mins'});
    }
    final mins = (doc.totalWords / wpm).ceil();
    if (mins <= 0) return null;
    return AppStrings.homeEstimatedTotal.trParams({'n': '$mins'});
  }
}
