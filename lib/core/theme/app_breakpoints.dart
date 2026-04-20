abstract final class AppBreakpoints {
  static const double compact = 360;
  static const double expanded = 414;
  static const double maxContentWidth = 480;
  static const double tablet = 600;

  static double maxContentWidthFor(double screenWidth) {
    return screenWidth >= tablet ? double.infinity : maxContentWidth;
  }
}
