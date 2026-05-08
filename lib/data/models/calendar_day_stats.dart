/// Per-day stats for the streak calendar heat map.
class CalendarDayStats {
  final double minutesRead;
  final int sessionsCount;
  final bool targetMet;

  const CalendarDayStats({
    this.minutesRead = 0,
    this.sessionsCount = 0,
    this.targetMet = false,
  });
}
