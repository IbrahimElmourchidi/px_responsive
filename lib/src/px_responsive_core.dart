import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'px_responsive_config.dart';

/// The singleton core that calculates and provides scaling factors.
///
/// This class automatically switches between mobile, tablet, and desktop
/// base sizes based on the current screen width and breakpoints defined
/// in [PxResponsiveConfig].
///
/// ## Usage
///
/// ```dart
/// // Simple way (recommended)
/// if (isMobile) { ... }
/// width: 200.w
///
/// // Direct singleton access (when needed)
/// final responsive = PxResponsive();
/// double scaledWidth = 200 * responsive.scaleW;
/// ```
///
/// ## How maxWidth Works
///
/// When [PxResponsiveConfig.maxWidth] is set:
/// - If actual screen width <= maxWidth: scales normally based on actual width
/// - If actual screen width > maxWidth: scales based on maxWidth, not actual width
///
/// Example with maxWidth: 1920:
/// ```dart
/// // On 1600px screen: scales to 1600px (normal)
/// // On 2560px screen: scales to 1920px (capped)
/// // Content appears centered with margins on ultra-wide screens
/// ```
class PxResponsive {
  // ============== Singleton Pattern ==============

  static final PxResponsive _instance = PxResponsive._internal();

  /// Returns the singleton instance of [PxResponsive].
  factory PxResponsive() => _instance;

  PxResponsive._internal();

  // ============== Private Fields ==============

  /// The configuration provided by the user via [PxResponsiveWrapper].
  PxResponsiveConfig _config = const PxResponsiveConfig();

  /// Current screen width in logical pixels (actual screen width).
  double _actualScreenWidth = 0;

  /// Current screen height in logical pixels.
  double _screenHeight = 0;

  /// The device pixel ratio (dpr) of the current screen.
  double _devicePixelRatio = 1.0;

  /// The effective width used for scaling calculations.
  /// This equals min(actualScreenWidth, maxWidth) when maxWidth is set.
  double _effectiveWidth = 0;

  /// The active base size (Mobile, Tablet, or Desktop) chosen based on current width.
  Size _activeBaseSize = const Size(375, 812);

  /// Whether the singleton has been properly initialized.
  bool _isInitialized = false;

  // ============== Configuration Getters ==============

  /// The current configuration.
  PxResponsiveConfig get config => _config;

  /// Returns `true` if the singleton has been properly initialized.
  bool get isInitialized => _isInitialized;

  // ============== Screen Dimension Getters ==============

  /// Returns the current screen width in logical pixels.
  ///
  /// This is the actual screen width regardless of [maxWidth] setting.
  /// For the width used in scaling calculations, see [effectiveWidth].
  double get screenWidth => _actualScreenWidth;

  /// Returns the effective width used for scaling calculations.
  ///
  /// When [PxResponsiveConfig.maxWidth] is set:
  /// - Returns min(actualScreenWidth, maxWidth)
  ///
  /// When [PxResponsiveConfig.maxWidth] is null:
  /// - Returns actualScreenWidth
  ///
  /// Example:
  /// ```dart
  /// // With maxWidth: 1920
  /// // On 2560px screen: effectiveWidth = 1920
  /// // On 1600px screen: effectiveWidth = 1600
  /// ```
  double get effectiveWidth => _effectiveWidth;

  /// Returns the current screen height in logical pixels.
  double get screenHeight => _screenHeight;

  /// Returns the device pixel ratio of the current screen.
  ///
  /// This represents the number of physical pixels per logical pixel.
  /// Common values: 1.0, 2.0, 3.0
  double get devicePixelRatio => _devicePixelRatio;

  /// The active base design size based on current screen width.
  ///
  /// This is automatically chosen from [PxResponsiveConfig.mobile],
  /// [PxResponsiveConfig.tablet], or [PxResponsiveConfig.desktop]
  /// based on the breakpoints.
  Size get activeBaseSize => _activeBaseSize;

  // ============== Device Type Getters ==============

  /// The current device type as [PxDeviceType] enum.
  ///
  /// Example:
  /// ```dart
  /// switch (PxResponsive().deviceType) {
  ///   case PxDeviceType.mobile:
  ///     // Mobile-specific code
  ///   case PxDeviceType.tablet:
  ///     // Tablet-specific code
  ///   case PxDeviceType.desktop:
  ///     // Desktop-specific code
  /// }
  /// ```
  PxDeviceType get deviceType {
    if (isMobile) return PxDeviceType.mobile;
    if (isTablet) return PxDeviceType.tablet;
    return PxDeviceType.desktop;
  }

  /// Returns `true` if the current screen width is in the mobile range.
  ///
  /// Mobile: width < [PxResponsiveConfig.mobileBreakpoint]
  bool get isMobile => _actualScreenWidth < _config.mobileBreakpoint;

  /// Returns `true` if the current screen width is in the tablet range.
  ///
  /// Tablet: [PxResponsiveConfig.mobileBreakpoint] <= width < [PxResponsiveConfig.tabletBreakpoint]
  bool get isTablet =>
      _actualScreenWidth >= _config.mobileBreakpoint &&
      _actualScreenWidth < _config.tabletBreakpoint;

  /// Returns `true` if the current screen width is in the desktop range.
  ///
  /// Desktop: width >= [PxResponsiveConfig.tabletBreakpoint]
  bool get isDesktop => _actualScreenWidth >= _config.tabletBreakpoint;

  // ============== Scale Factor Getters ==============

  /// Raw (unclamped) scale factor for width.
  ///
  /// Calculated as: effectiveWidth / activeBaseSize.width
  ///
  /// Note: This uses [effectiveWidth], which respects [maxWidth] if set.
  double get rawScaleW {
    final baseWidth = _activeBaseSize.width;
    return baseWidth > 0 ? _effectiveWidth / baseWidth : 1.0;
  }

  /// Raw (unclamped) scale factor for height.
  ///
  /// Calculated as: screenHeight / activeBaseSize.height
  double get rawScaleH {
    final baseHeight = _activeBaseSize.height;
    return baseHeight > 0 ? _screenHeight / baseHeight : 1.0;
  }

  /// Clamped scale factor for width.
  ///
  /// Used by the [.w] extension for width scaling.
  /// Respects [PxResponsiveConfig.minScaleFactor] and [PxResponsiveConfig.maxScaleFactor].
  double get scaleW => _clampScale(rawScaleW);

  /// Clamped scale factor for height.
  ///
  /// Used by the [.h] extension for height scaling.
  /// Respects [PxResponsiveConfig.minScaleFactor] and [PxResponsiveConfig.maxScaleFactor].
  double get scaleH => _clampScale(rawScaleH);

  /// Clamped scale factor for fonts (scalable pixels).
  ///
  /// Used by the [.sp] extension for text sizing.
  /// Respects [PxResponsiveConfig.maxTextScaleFactor] which is typically more restrictive
  /// than [maxScaleFactor] to prevent text from becoming too large.
  double get scaleSp => _clampTextScale(rawScaleW);

  /// Clamped scale factor for radius/diagonal elements.
  ///
  /// Used by the [.r] extension for border radii and circular elements.
  /// Uses the minimum of width and height scales to maintain aspect ratio.
  double get scaleR => _clampScale(math.min(rawScaleW, rawScaleH));

  // ============== Private Utility Methods ==============

  /// Clamps the scale factor based on [minScaleFactor] and [maxScaleFactor].
  double _clampScale(double scale) {
    double result = scale;
    if (_config.minScaleFactor != null) {
      result = math.max(result, _config.minScaleFactor!);
    }
    if (_config.maxScaleFactor != null) {
      result = math.min(result, _config.maxScaleFactor!);
    }
    return result;
  }

  /// Clamps the text scale factor based on [minScaleFactor] and [maxTextScaleFactor].
  ///
  /// Text scaling uses a tighter maximum to prevent oversized text on large screens.
  double _clampTextScale(double scale) {
    double result = scale;
    if (_config.minScaleFactor != null) {
      result = math.max(result, _config.minScaleFactor!);
    }
    final double maxText =
        _config.maxTextScaleFactor ?? _config.maxScaleFactor ?? double.infinity;
    result = math.min(result, maxText);
    return result;
  }

  // ============== Public Scaling Methods ==============

  /// Scales the given value by width factor.
  ///
  /// Equivalent to: `value * scaleW`
  ///
  /// Example:
  /// ```dart
  /// double width = PxResponsive().w(200); // 200 scaled by width factor
  /// ```
  double w(num value) => value * scaleW;

  /// Scales the given value by height factor.
  ///
  /// Equivalent to: `value * scaleH`
  ///
  /// Example:
  /// ```dart
  /// double height = PxResponsive().h(100); // 100 scaled by height factor
  /// ```
  double h(num value) => value * scaleH;

  /// Scales the given value by font/text factor.
  ///
  /// Equivalent to: `value * scaleSp`
  ///
  /// Example:
  /// ```dart
  /// double fontSize = PxResponsive().sp(16); // 16 scaled for text
  /// ```
  double sp(num value) => value * scaleSp;

  /// Scales the given value by radius factor.
  ///
  /// Equivalent to: `value * scaleR`
  ///
  /// Example:
  /// ```dart
  /// double radius = PxResponsive().r(12); // 12 scaled for border radius
  /// ```
  double r(num value) => value * scaleR;

  /// Returns the appropriate value based on the current device type.
  ///
  /// The [mobile] value is required. If [tablet] is null, [mobile] is used.
  /// If [desktop] is null, [tablet] or [mobile] is used.
  ///
  /// Example:
  /// ```dart
  /// int columns = PxResponsive().value(
  ///   mobile: 1,
  ///   tablet: 2,
  ///   desktop: 4,
  /// );
  /// ```
  T value<T>({
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }

  // ============== Internal Methods ==============

  /// Internal initialization method called by [PxResponsiveWrapper].
  ///
  /// This method calculates the effective width based on [maxWidth] setting
  /// and determines the active base size.
  ///
  /// Should not be called directly by users.
  void init({
    required BoxConstraints constraints,
    required PxResponsiveConfig config,
    double devicePixelRatio = 1.0,
  }) {
    _config = config;
    _actualScreenWidth = constraints.maxWidth;
    _screenHeight = constraints.maxHeight;
    _devicePixelRatio = devicePixelRatio;
    _isInitialized = true;

    // Calculate effective width: cap at maxWidth if specified
    if (_config.maxWidth != null) {
      _effectiveWidth = math.min(_actualScreenWidth, _config.maxWidth!);
    } else {
      _effectiveWidth = _actualScreenWidth;
    }

    // Determine active base size based on current width
    // Note: We use actualScreenWidth for breakpoint comparison,
    // not effectiveWidth. This ensures consistent layout switching.
    if (isMobile) {
      _activeBaseSize = _config.mobile;
    } else if (isTablet) {
      _activeBaseSize = _config.tablet;
    } else {
      _activeBaseSize = _config.desktop;
    }
  }

  /// Resets the singleton to its initial state.
  ///
  /// Mainly used for testing purposes.
  void reset() {
    _config = const PxResponsiveConfig();
    _actualScreenWidth = 0;
    _screenHeight = 0;
    _devicePixelRatio = 1.0;
    _effectiveWidth = 0;
    _activeBaseSize = const Size(375, 812);
    _isInitialized = false;
  }

  @override
  String toString() {
    return 'PxResponsive('
        'isInitialized: $_isInitialized, '
        'actualWidth: ${_actualScreenWidth.toStringAsFixed(1)}, '
        'effectiveWidth: ${_effectiveWidth.toStringAsFixed(1)}, '
        'screenHeight: ${_screenHeight.toStringAsFixed(1)}, '
        'deviceType: $deviceType, '
        'activeBaseSize: $_activeBaseSize, '
        'scaleW: ${scaleW.toStringAsFixed(3)}, '
        'scaleH: ${scaleH.toStringAsFixed(3)}, '
        'scaleSp: ${scaleSp.toStringAsFixed(3)}, '
        'scaleR: ${scaleR.toStringAsFixed(3)})';
  }
}
