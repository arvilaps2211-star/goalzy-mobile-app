import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

enum ScreenType { phone, tablet, desktop }

class ResponsiveUtils {
  const ResponsiveUtils(this.width);

  final double width;

  ScreenType get screenType {
    if (width >= AppConstants.desktopBreakpoint) return ScreenType.desktop;
    if (width >= AppConstants.tabletBreakpoint) return ScreenType.tablet;
    return ScreenType.phone;
  }

  bool get isPhone => screenType == ScreenType.phone;
  bool get isTablet => screenType == ScreenType.tablet;
  bool get isDesktop => screenType == ScreenType.desktop;

  int get gridColumns {
    return switch (screenType) {
      ScreenType.phone => 1,
      ScreenType.tablet => 2,
      ScreenType.desktop => 3,
    };
  }

  double get contentMaxWidth {
    return switch (screenType) {
      ScreenType.phone => double.infinity,
      ScreenType.tablet => 900,
      ScreenType.desktop => 1200,
    };
  }

  EdgeInsets get pagePadding {
    return switch (screenType) {
      ScreenType.phone => const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ScreenType.tablet => const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ScreenType.desktop => const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
    };
  }
}

extension ResponsiveContext on BuildContext {
  ResponsiveUtils get responsive {
    return ResponsiveUtils(MediaQuery.sizeOf(this).width);
  }
}
