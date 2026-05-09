import 'package:readline_app/core/localization/app_localization.dart';
import 'package:readline_app/core/localization/app_strings.dart';

abstract final class DateFormatter {
  /// Formats a DateTime as 'YYYY-MM-DD' for Hive storage keys.
  static String toKey(DateTime date) =>
      '${date.year}-${_pad(date.month)}-${_pad(date.day)}';

  /// "Today", "Yesterday", "3 days ago", "Apr 20"
  static String relative(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final target = DateTime(date.year, date.month, date.day);
    final diff = today.difference(target).inDays;

    if (diff == 0) return AppStrings.today.tr;
    if (diff == 1) return AppStrings.yesterday.tr;
    if (diff < 7) return AppStrings.daysAgo.trParams({'n': '$diff'});
    return compact(date);
  }

  /// Uppercase relative date: "TODAY", "1 DAY AGO", "5 DAYS AGO",
  /// "1 MONTH AGO", "3 MOS AGO", "LONG AGO" — used by vocabulary metadata
  /// and other dense card meta lines.
  static String relativeUpper(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays == 0) return AppStrings.todayUpper.tr;
    if (diff.inDays == 1) return AppStrings.oneDayAgo.tr;
    if (diff.inDays < 30) {
      return AppStrings.daysAgoUpper.trParams({'n': '${diff.inDays}'});
    }
    if (diff.inDays < 365) {
      final months = (diff.inDays / 30).round();
      return months > 1
          ? AppStrings.monthsAgoUpper.trParams({'n': '$months'})
          : AppStrings.monthAgo.trParams({'n': '$months'});
    }
    return AppStrings.longAgo.tr;
  }

  /// "5 min", "1h 23m"
  static String duration(double minutes) {
    if (minutes < 1) return AppStrings.generalLessThanMinute.tr;
    if (minutes < 60) {
      return AppStrings.generalMinutes.trParams({'n': '${minutes.round()}'});
    }
    final h = minutes ~/ 60;
    final m = (minutes % 60).round();
    return m == 0
        ? AppStrings.generalHoursOnly.trParams({'h': '$h'})
        : AppStrings.generalHoursMinutes.trParams({'h': '$h', 'm': '$m'});
  }

  static const _monthKeys = [
    AppStrings.monthJan,
    AppStrings.monthFeb,
    AppStrings.monthMar,
    AppStrings.monthApr,
    AppStrings.monthMay,
    AppStrings.monthJun,
    AppStrings.monthJul,
    AppStrings.monthAug,
    AppStrings.monthSep,
    AppStrings.monthOct,
    AppStrings.monthNov,
    AppStrings.monthDec,
  ];

  /// "Apr 20"
  static String compact(DateTime date) {
    return '${_monthKeys[date.month - 1].tr} ${date.day}';
  }

  static String _pad(int n) => n.toString().padLeft(2, '0');
}
