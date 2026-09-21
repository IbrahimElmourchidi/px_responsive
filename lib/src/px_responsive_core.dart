import 'package:flutter/widgets.dart';
import 'px_responsive_config.dart';
import 'px_responsive_data.dart';

/// The singleton facade over the current [PxResponsiveData] snapshot.
///
/// [PxResponsiveWrapper] builds a [PxResponsiveData] snapshot on every
/// layout pass and publishes it two ways at once: it calls [attach] on this
/// singleton (the static read path — `PxResponsive()`, `200.w`, ...) and
/// wraps its child in a `PxResponsiveScope` carrying the *same* instance
/// (the context-aware read path — `context.responsive`, the package's own
/// widgets). Both paths always agree, because there is exactly one snapshot
/// per layout pass.
///
/// Only the root-most `PxResponsiveWrapper` (one with no `PxResponsiveScope`
/// above it) writes to this singleton — a nested wrapper still initializes
/// correctly and is reachable through its `PxResponsiveScope`, but it does
/// not overwrite the app-wide static reader.
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
/// ## Reading before initialization
///
/// Reading a *derived* getter (a scale factor, [deviceType], [effectiveWidth],
/// [w], [h], [sp], [r], [value]) before any wrapper has built asserts in
/// debug mode. Set [debugAllowUninitializedReads] to `true` in tests that
/// exercise the API directly via [init] without a wrapper (the *state*
/// getters — [screenWidth], [screenHeight], safe area, [config],
/// [activeBaseSize], [orientation], [isInitialized] — never assert, and
/// read [PxResponsiveData.fallback] instead).
class PxResponsive {
  // ============== Singleton Pattern ==============

  static final PxResponsive _instance = PxResponsive._internal();

  /// Returns the singleton instance of [PxResponsive].
  factory PxResponsive() => _instance;

  PxResponsive._internal();

  // ============== State ==============

  PxResponsiveData? _snapshot;

  /// Suppresses the debug-mode assert on reading a derived getter before
  /// initialization. Intended for unit tests that call [init] directly
  /// without mounting a `PxResponsiveWrapper`, or that intentionally probe
  /// pre-initialization behaviour.
  static bool debugAllowUninitializedReads = false;

  /// The current [PxResponsiveData] snapshot, or [PxResponsiveData.fallback]
  /// if nothing has initialized this singleton yet.
  PxResponsiveData get data => _snapshot ?? PxResponsiveData.fallback;

  /// Publishes a new snapshot. Called by `PxResponsiveWrapper` /
  /// `PxResponsiveMediaQueryWrapper`; not intended for direct use.
  void attach(PxResponsiveData data) => _snapshot = data;

  PxResponsiveData get _guarded {
    assert(
      _snapshot != null || debugAllowUninitializedReads,
      'PxResponsive was read before any PxResponsiveWrapper (or '
      'PxResponsiveMediaQueryWrapper) built.\n'
      '• App:  wrap your root widget in PxResponsiveWrapper.\n'
      '• Test: call PxResponsive().init(constraints: ..., config: ...) '
      'first, or set PxResponsive.debugAllowUninitializedReads = true.',
    );
    return data;
  }

  // ============== Configuration Getters ==============

  /// The current configuration.
  PxResponsiveConfig get config => data.config;

  /// Returns `true` if the singleton has been properly initialized.
  bool get isInitialized => _snapshot != null;

  // ============== Screen Dimension Getters ==============

  /// Returns the current screen width in logical pixels.
  ///
  /// This is the actual screen width regardless of [PxResponsiveConfig.maxWidth].
  /// For the width used in scaling calculations, see [effectiveWidth].
  double get screenWidth => data.screenWidth;

  /// Returns the effective width used for scaling calculations.
  ///
  /// When [PxResponsiveConfig.maxWidth] is set:
  /// - Returns min(actualScreenWidth, maxWidth)
  ///
  /// When [PxResponsiveConfig.maxWidth] is null:
  /// - Returns actualScreenWidth
  double get effectiveWidth => _guarded.effectiveWidth;

  /// Returns the current screen height in logical pixels.
  double get screenHeight => data.screenHeight;

  /// Returns the device pixel ratio of the current screen.
  double get devicePixelRatio => data.devicePixelRatio;

  /// The active base design size based on current screen width, orientation
  /// and [PxResponsiveConfig.transitionBand] position.
  Size get activeBaseSize => data.activeBaseSize;

  // ============== Orientation Getters ==============

  /// Returns `true` if the screen is in landscape orientation (width > height).
  bool get isLandscape => data.isLandscape;

  /// Returns `true` if the screen is in portrait orientation (height >= width).
  bool get isPortrait => data.isPortrait;

  /// Returns the current screen orientation as a [PxOrientation] enum.
  PxOrientation get orientation => data.orientation;

  /// Returns the appropriate value based on the current orientation.
  T orientationValue<T>({required T portrait, required T landscape}) =>
      _guarded.orientationValue(portrait: portrait, landscape: landscape);

  // ============== Safe Area Getters ==============

  /// Returns the top safe area inset (status bar, notch).
  double get safeAreaTop => data.safeAreaTop;

  /// Returns the bottom safe area inset (home indicator).
  double get safeAreaBottom => data.safeAreaBottom;

  /// Returns the left safe area inset.
  double get safeAreaLeft => data.safeAreaLeft;

  /// Returns the right safe area inset.
  double get safeAreaRight => data.safeAreaRight;

  /// Returns the screen height minus top and bottom safe area insets.
  double get safeScreenHeight => data.safeScreenHeight;

  // ============== Device Type Getters ==============

  /// The current device type as [PxDeviceType] enum.
  PxDeviceType get deviceType => _guarded.deviceType;

  /// Returns `true` if the current screen width is in the mobile range.
  bool get isMobile => _guarded.isMobile;

  /// Returns `true` if the current screen width is in the tablet range.
  bool get isTablet => _guarded.isTablet;

  /// Returns `true` if the current screen width is in the desktop range.
  bool get isDesktop => _guarded.isDesktop;

  /// How far [activeBaseSize] is currently blended between two tiers due to
  /// [PxResponsiveConfig.transitionBand]. See [PxResponsiveData.tierBlend].
  double get tierBlend => data.tierBlend;

  /// See [PxResponsiveData.isInTransition].
  bool get isInTransition => data.isInTransition;

  // ============== Scale Factor Getters ==============

  /// Raw (unclamped) scale factor for width. Exposed for diagnostics.
  double get rawScaleW => data.rawScaleW;

  /// Raw (unclamped) scale factor for height. Exposed for diagnostics.
  double get rawScaleH => data.rawScaleH;

  /// Clamped scale factor for width. Used by the [.w] extension.
  double get scaleW => _guarded.scaleW;

  /// Clamped scale factor for height. Used by the [.h] extension.
  double get scaleH => _guarded.scaleH;

  /// Clamped scale factor for fonts. Used by the [.sp] extension.
  double get scaleSp => _guarded.scaleSp;

  /// Clamped scale factor for radius/diagonal elements. Used by [.r].
  double get scaleR => _guarded.scaleR;

  // ============== Public Scaling Methods ==============

  /// Scales the given value by width factor.
  double w(num value) => value * scaleW;

  /// Scales the given value by height factor.
  double h(num value) => value * scaleH;

  /// Scales the given value by font/text factor.
  double sp(num value) => value * scaleSp;

  /// Scales the given value by radius factor.
  double r(num value) => value * scaleR;

  /// Returns the appropriate value based on the current device type.
  T value<T>({required T mobile, T? tablet, T? desktop}) => _guarded.value(
        mobile: mobile,
        tablet: tablet,
        desktop: desktop,
      );

  // ============== Internal Methods ==============

  /// Initializes the responsive singleton with current screen constraints.
  ///
  /// Called automatically by [PxResponsiveWrapper]. Should not be called
  /// directly by users (tests may call it to exercise the API without a
  /// wrapper).
  void init({
    required BoxConstraints constraints,
    required PxResponsiveConfig config,
    double devicePixelRatio = 1.0,
    EdgeInsets safeAreaPadding = EdgeInsets.zero,
  }) {
    attach(PxResponsiveData.fromSize(
      size: Size(constraints.maxWidth, constraints.maxHeight),
      config: config,
      devicePixelRatio: devicePixelRatio,
      safeAreaPadding: safeAreaPadding,
    ));
  }

  /// Resets the singleton to its initial (uninitialized) state.
  ///
  /// Mainly used for testing purposes.
  void reset() => _snapshot = null;

  @override
  String toString() =>
      _snapshot == null ? 'PxResponsive(uninitialized)' : data.toString();
}
