class MinuteCalculator {
  /// Computes duration in minutes between clock-in and clock-out
  static int computeMinutes(DateTime clockIn, DateTime clockOut) {
    final diff = clockOut.difference(clockIn);
    return diff.inMinutes > 0 ? diff.inMinutes : 0;
  }

  /// Calculates exact wage down to the minute: minutes * (hourlyRate / 60)
  static double computeWage(int minutes, double hourlyRateUsd) {
    return (minutes / 60.0) * hourlyRateUsd;
  }

  /// Formats minutes into human-readable e.g. "2h 45m (165 mins)"
  static String formatDuration(int totalMinutes) {
    final hours = totalMinutes ~/ 60;
    final mins = totalMinutes % 60;
    if (hours == 0) return '${mins}m';
    if (mins == 0) return '${hours}h';
    return '${hours}h ${mins}m';
  }
}

