import 'package:flutter/widgets.dart';

class ResponsiveHelper {
  const ResponsiveHelper._();

  static bool isSmallPhone(BuildContext context) => _width(context) < 360;

  static bool isMediumPhone(BuildContext context) {
    final width = _width(context);
    return width >= 360 && width <= 430;
  }

  static bool isLargePhone(BuildContext context) {
    final width = _width(context);
    return width >= 431 && width <= 600;
  }

  static bool isFoldable(BuildContext context) {
    final width = _width(context);
    return width > 600 && width < 840;
  }

  static bool isTablet(BuildContext context) => _width(context) >= 840;

  static double _width(BuildContext context) {
    return MediaQuery.sizeOf(context).width;
  }
}
