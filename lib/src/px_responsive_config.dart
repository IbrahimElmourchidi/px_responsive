import 'package:flutter/widgets.dart';

/// Configuration class that holds the design baselines for all three device types.
///
/// ## Example
///
/// ```dart
/// const config = PxResponsiveConfig(
///   desktop: Size(1920, 1080),  // Your desktop design size
///   tablet: Size(834, 1194),    // Your tablet design size
///   mobile: Size(375, 812),     // Your mobile design size
///   mobileBreakpoint: 600,      // Below this = mobile
///   tabletBreakpoint: 1200,     // Above this = desktop
/// );
/// ```
class PxResponsiveConfig {
  /// Base design size for Desktop layouts.
  final Size desktop;

  /// Base design size for Tablet layouts.
  final Size tablet;

  /// Base design size for Mobile layouts.
  final Size mobile;

  /// The width threshold below which the layout is considered Mobile.
  final double mobileBreakpoint;

  /// The width threshold at or above which the layout is considered Desktop.
  final double tabletBreakpoint;

  /// Minimum scale factor to prevent elements from becoming too small.
  final double? minScaleFactor;

  /// Maximum scale factor to prevent elements from becoming too large.
  final double? maxScaleFactor;

  /// Maximum scale factor specifically for text ([sp] extension).
  final double? maxTextScaleFactor;

  /// Creates a responsive design configuration.
  const PxResponsiveConfig({
    this.desktop = const Size(1920, 1080),
    this.tablet = const Size(834, 1194),
    this.mobile = const Size(375, 812),
    this.mobileBreakpoint = 600,
    this.tabletBreakpoint = 1200,
    this.minScaleFactor = 0.5,
    this.maxScaleFactor = 2.0,
    this.maxTextScaleFactor = 1.5,
  })  : assert(mobileBreakpoint > 0, 'mobileBreakpoint must be positive'),
        assert(
          tabletBreakpoint > mobileBreakpoint,
          'tabletBreakpoint must be greater than mobileBreakpoint',
        ),
        assert(
          minScaleFactor == null || minScaleFactor > 0,
          'minScaleFactor must be positive if provided',
        ),
        assert(
          maxScaleFactor == null || maxScaleFactor > 0,
          'maxScaleFactor must be positive if provided',
        ),
        assert(
          minScaleFactor == null ||
              maxScaleFactor == null ||
              minScaleFactor <= maxScaleFactor,
          'minScaleFactor must be less than or equal to maxScaleFactor',
        );

  /// Creates a copy of this config with the given fields replaced.
  PxResponsiveConfig copyWith({
    Size? desktop,
    Size? tablet,
    Size? mobile,
    double? mobileBreakpoint,
    double? tabletBreakpoint,
    double? minScaleFactor,
    double? maxScaleFactor,
    double? maxTextScaleFactor,
  }) {
    return PxResponsiveConfig(
      desktop: desktop ?? this.desktop,
      tablet: tablet ?? this.tablet,
      mobile: mobile ?? this.mobile,
      mobileBreakpoint: mobileBreakpoint ?? this.mobileBreakpoint,
      tabletBreakpoint: tabletBreakpoint ?? this.tabletBreakpoint,
      minScaleFactor: minScaleFactor ?? this.minScaleFactor,
      maxScaleFactor: maxScaleFactor ?? this.maxScaleFactor,
      maxTextScaleFactor: maxTextScaleFactor ?? this.maxTextScaleFactor,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PxResponsiveConfig &&
        other.desktop == desktop &&
        other.tablet == tablet &&
        other.mobile == mobile &&
        other.mobileBreakpoint == mobileBreakpoint &&
        other.tabletBreakpoint == tabletBreakpoint &&
        other.minScaleFactor == minScaleFactor &&
        other.maxScaleFactor == maxScaleFactor &&
        other.maxTextScaleFactor == maxTextScaleFactor;
  }

  @override
  int get hashCode {
    return Object.hash(
      desktop,
      tablet,
      mobile,
      mobileBreakpoint,
      tabletBreakpoint,
      minScaleFactor,
      maxScaleFactor,
      maxTextScaleFactor,
    );
  }

  @override
  String toString() {
    return 'PxResponsiveConfig('
        'desktop: $desktop, '
        'tablet: $tablet, '
        'mobile: $mobile, '
        'mobileBreakpoint: $mobileBreakpoint, '
        'tabletBreakpoint: $tabletBreakpoint, '
        'minScaleFactor: $minScaleFactor, '
        'maxScaleFactor: $maxScaleFactor, '
        'maxTextScaleFactor: $maxTextScaleFactor)';
  }
}

/// Enum representing the current device type based on screen width.
///
/// Use with [deviceType] global getter or [PxResponsive.deviceType]:
///
/// ```dart
/// switch (deviceType) {
///   case PxDeviceType.mobile:
///     return MobileLayout();
///   case PxDeviceType.tablet:
///     return TabletLayout();
///   case PxDeviceType.desktop:
///     return DesktopLayout();
/// }
/// ```
enum PxDeviceType {
  /// Mobile device (screen width < mobileBreakpoint).
  mobile,

  /// Tablet device (mobileBreakpoint <= screen width < tabletBreakpoint).
  tablet,

  /// Desktop device (screen width >= tabletBreakpoint).
  desktop,
}
