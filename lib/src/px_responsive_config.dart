import 'package:flutter/widgets.dart';

/// Configuration class that holds the design baselines for all three device types.
///
/// ## Basic Example
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
///
/// ## With maxWidth Example
///
/// ```dart
/// const config = PxResponsiveConfig(
///   desktop: Size(1920, 1080),
///   tablet: Size(834, 1194),
///   mobile: Size(375, 812),
///   maxWidth: 1920, // Prevent scaling beyond 1920px width
/// );
/// ```
///
/// ## Why use maxWidth?
///
/// On ultra-wide screens (e.g., 3840px or 5120px), scaling UI elements
/// proportionally can make them excessively wide while the height remains normal.
/// Setting [maxWidth] ensures that once the screen width exceeds this value,
/// the package will scale based on [maxWidth] instead of the actual screen width.
/// This creates a centered content area with empty space on the sides,
/// which is a common design pattern for very wide displays.
class PxResponsiveConfig {
  /// Base design size for Desktop layouts.
  ///
  /// This should match your design tool's desktop artboard size.
  /// Common values: Size(1920, 1080), Size(1440, 900), Size(1366, 768)
  final Size desktop;

  /// Base design size for Tablet layouts.
  ///
  /// This should match your design tool's tablet artboard size.
  /// Common values: Size(834, 1194), Size(768, 1024), Size(1024, 768)
  final Size tablet;

  /// Base design size for Mobile layouts.
  ///
  /// This should match your design tool's mobile artboard size.
  /// Common values: Size(375, 812), Size(360, 640), Size(414, 896)
  final Size mobile;

  /// The width threshold below which the layout is considered Mobile.
  ///
  /// Default: 600 logical pixels
  /// When screen width < [mobileBreakpoint], mobile base size is used.
  final double mobileBreakpoint;

  /// The width threshold at or above which the layout is considered Desktop.
  ///
  /// Default: 1200 logical pixels
  /// When screen width >= [tabletBreakpoint], desktop base size is used.
  /// Between [mobileBreakpoint] and [tabletBreakpoint], tablet base size is used.
  final double tabletBreakpoint;

  /// Maximum width for scaling calculations.
  ///
  /// When the actual screen width exceeds this value, the package will use
  /// [maxWidth] for scaling calculations instead of the actual width.
  /// This prevents UI elements from becoming excessively wide on ultra-wide screens.
  ///
  /// Example:
  /// ```dart
  /// PxResponsiveConfig(
  ///   desktop: Size(1920, 1080),
  ///   maxWidth: 1920, // Cap scaling at 1920px
  /// )
  /// ```
  ///
  /// On a 3840px wide screen:
  /// - Without maxWidth: Elements scale to 200% of design size
  /// - With maxWidth: 1920: Elements maintain 100% of design size, centered
  ///
  /// Set to null (default) to disable width capping.
  final double? maxWidth;

  /// Minimum scale factor to prevent elements from becoming too small.
  ///
  /// Default: 0.5 (elements won't shrink below 50% of design size)
  /// Set to null to disable minimum scaling constraint.
  final double? minScaleFactor;

  /// Maximum scale factor to prevent elements from becoming too large.
  ///
  /// Default: 2.0 (elements won't grow beyond 200% of design size)
  /// Set to null to disable maximum scaling constraint.
  ///
  /// Note: This is overridden by [maxWidth] for width calculations when [maxWidth] is set.
  final double? maxScaleFactor;

  /// Maximum scale factor specifically for text ([sp] extension).
  ///
  /// Default: 1.5 (text won't grow beyond 150% of design size)
  /// This tighter constraint prevents text from becoming too large on big screens.
  /// Set to null to use [maxScaleFactor] instead.
  final double? maxTextScaleFactor;

  /// Creates a responsive design configuration.
  ///
  /// All size parameters should use logical pixels.
  const PxResponsiveConfig({
    this.desktop = const Size(1920, 1080),
    this.tablet = const Size(834, 1194),
    this.mobile = const Size(375, 812),
    this.mobileBreakpoint = 600,
    this.tabletBreakpoint = 1200,
    this.maxWidth,
    this.minScaleFactor = 0.5,
    this.maxScaleFactor = 2.0,
    this.maxTextScaleFactor = 1.5,
  })  : assert(mobileBreakpoint > 0, 'mobileBreakpoint must be positive'),
        assert(
          tabletBreakpoint > mobileBreakpoint,
          'tabletBreakpoint must be greater than mobileBreakpoint',
        ),
        assert(
          maxWidth == null || maxWidth > 0,
          'maxWidth must be positive if provided',
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
  ///
  /// Example:
  /// ```dart
  /// final newConfig = config.copyWith(
  ///   maxWidth: 2560,
  ///   maxTextScaleFactor: 1.3,
  /// );
  /// ```
  PxResponsiveConfig copyWith({
    Size? desktop,
    Size? tablet,
    Size? mobile,
    double? mobileBreakpoint,
    double? tabletBreakpoint,
    double? maxWidth,
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
      maxWidth: maxWidth ?? this.maxWidth,
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
        other.maxWidth == maxWidth &&
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
      maxWidth,
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
        'maxWidth: $maxWidth, '
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
