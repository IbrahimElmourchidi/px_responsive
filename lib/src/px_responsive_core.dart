import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'px_responsive_config.dart';

/// The singleton core that calculates and provides scaling factors.
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
class PxResponsive {
  // ============== Singleton Pattern ==============

  static final PxResponsive _instance = PxResponsive._internal();

  /// Returns the singleton instance of [PxResponsive].
  factory PxResponsive() => _instance;

  PxResponsive._internal();

  // ============== Private Fields ==============

  /// The configuration provided by the user via [PxResponsiveWrapper].
  PxResponsiveConfig _config = const PxResponsiveConfig();

  /// Current screen width in logical pixels.
  double _screenWidth = 0;

  /// Current screen height in logical pixels.
  double _screenHeight = 0;

  /// The device pixel ratio (dpr) of the current screen.
  double _devicePixelRatio = 1.0;

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

  double get screenWidth => _screenWidth;
  double get screenHeight => _screenHeight;
  double get devicePixelRatio => _devicePixelRatio;

  /// The active base design size based on current screen width.
  Size get activeBaseSize => _activeBaseSize;

  // ============== Device Type Getters ==============

  /// The current device type as [PxDeviceType] enum.
  PxDeviceType get deviceType {
    if (isMobile) return PxDeviceType.mobile;
    if (isTablet) return PxDeviceType.tablet;
    return PxDeviceType.desktop;
  }

  /// Returns `true` if the current screen width is in the mobile range.
  bool get isMobile => _screenWidth < _config.mobileBreakpoint;

  /// Returns `true` if the current screen width is in the tablet range.
  bool get isTablet =>
      _screenWidth >= _config.mobileBreakpoint &&
      _screenWidth < _config.tabletBreakpoint;

  /// Returns `true` if the current screen width is in the desktop range.
  bool get isDesktop => _screenWidth >= _config.tabletBreakpoint;

  // ============== Scale Factor Getters ==============

  /// Raw (unclamped) scale factor for width.
  double get rawScaleW {
    final baseWidth = _activeBaseSize.width;
    return baseWidth > 0 ? _screenWidth / baseWidth : 1.0;
  }

  /// Raw (unclamped) scale factor for height.
  double get rawScaleH {
    final baseHeight = _activeBaseSize.height;
    return baseHeight > 0 ? _screenHeight / baseHeight : 1.0;
  }

  /// Clamped scale factor for width.
  double get scaleW => _clampScale(rawScaleW);

  /// Clamped scale factor for height.
  double get scaleH => _clampScale(rawScaleH);

  /// Clamped scale factor for fonts (scalable pixels).
  double get scaleSp => _clampTextScale(rawScaleW);

  /// Clamped scale factor for radius/diagonal elements.
  double get scaleR => _clampScale(math.min(rawScaleW, rawScaleH));

  // ============== Private Utility Methods ==============

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

  double w(num value) => value * scaleW;
  double h(num value) => value * scaleH;
  double sp(num value) => value * scaleSp;
  double r(num value) => value * scaleR;

  /// Returns the appropriate value based on the current device type.
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
  void init({
    required BoxConstraints constraints,
    required PxResponsiveConfig config,
    double devicePixelRatio = 1.0,
  }) {
    _config = config;
    _screenWidth = constraints.maxWidth;
    _screenHeight = constraints.maxHeight;
    _devicePixelRatio = devicePixelRatio;
    _isInitialized = true;

    // Determine active base size based on current width
    if (isMobile) {
      _activeBaseSize = _config.mobile;
    } else if (isTablet) {
      _activeBaseSize = _config.tablet;
    } else {
      _activeBaseSize = _config.desktop;
    }
  }

  /// Resets the singleton to its initial state.
  void reset() {
    _config = const PxResponsiveConfig();
    _screenWidth = 0;
    _screenHeight = 0;
    _devicePixelRatio = 1.0;
    _activeBaseSize = const Size(375, 812);
    _isInitialized = false;
  }

  @override
  String toString() {
    return 'PxResponsive('
        'isInitialized: $_isInitialized, '
        'screenWidth: ${_screenWidth.toStringAsFixed(1)}, '
        'screenHeight: ${_screenHeight.toStringAsFixed(1)}, '
        'deviceType: $deviceType, '
        'activeBaseSize: $_activeBaseSize, '
        'scaleW: ${scaleW.toStringAsFixed(3)}, '
        'scaleH: ${scaleH.toStringAsFixed(3)}, '
        'scaleSp: ${scaleSp.toStringAsFixed(3)}, '
        'scaleR: ${scaleR.toStringAsFixed(3)})';
  }
}
