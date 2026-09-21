import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'px_responsive_config.dart';

// ============================================================================
// PxResponsiveData - Immutable snapshot of the responsive scaling state
// ============================================================================

/// An immutable snapshot of every value the responsive system derives from
/// a screen size and a [PxResponsiveConfig].
///
/// This is the single source of truth for a given frame. [PxResponsive]
/// (the static singleton) and [PxResponsiveScope] (the [InheritedWidget])
/// both read from — and are built from — the same [PxResponsiveData]
/// instance, so the two access paths can never drift apart.
///
/// You normally don't construct this directly; [PxResponsiveWrapper] and
/// [PxResponsiveMediaQueryWrapper] build it for you via [PxResponsiveData.fromSize].
@immutable
class PxResponsiveData {
  /// The actual screen size in logical pixels, regardless of [PxResponsiveConfig.maxWidth].
  final Size screenSize;

  /// The width used for scaling and breakpoint calculations.
  ///
  /// Equals `min(screenSize.width, config.maxWidth)` when [PxResponsiveConfig.maxWidth]
  /// is set, otherwise equals `screenSize.width`.
  final double effectiveWidth;

  /// The base design size chosen for the current tier, orientation and
  /// [PxResponsiveConfig.transitionBand] position.
  final Size activeBaseSize;

  /// The configuration this snapshot was derived from.
  final PxResponsiveConfig config;

  /// Safe area padding (notch, status bar, etc.) from `MediaQuery.padding`.
  final EdgeInsets safeAreaPadding;

  /// The device pixel ratio of the current screen.
  final double devicePixelRatio;

  /// The device type for this snapshot. This is always a discrete value —
  /// even while [tierBlend] indicates the scale factors are mid-transition,
  /// `deviceType` reflects a single, definite tier so that
  /// [PxResponsiveBuilder]-style "pick one tree" widgets have a clear answer.
  final PxDeviceType deviceType;

  /// How far between two tiers this snapshot's [activeBaseSize] was blended,
  /// as a result of [PxResponsiveConfig.transitionBand].
  ///
  /// `0.0` means the base size is exactly the active tier's base (the
  /// default, when `transitionBand` is `0`, or when outside any band).
  /// A value strictly between `0.0` and `1.0` means [activeBaseSize] was
  /// linearly interpolated between the lower and upper tier's base size;
  /// see [isInTransition].
  final double tierBlend;

  /// Scale factor for width. See [PxResponsive.scaleW].
  final double scaleW;

  /// Scale factor for height. See [PxResponsive.scaleH].
  final double scaleH;

  /// Scale factor for text. See [PxResponsive.scaleSp].
  final double scaleSp;

  /// Scale factor for radius/diagonal elements. See [PxResponsive.scaleR].
  final double scaleR;

  const PxResponsiveData._({
    required this.screenSize,
    required this.effectiveWidth,
    required this.activeBaseSize,
    required this.config,
    required this.safeAreaPadding,
    required this.devicePixelRatio,
    required this.deviceType,
    required this.tierBlend,
    required this.scaleW,
    required this.scaleH,
    required this.scaleSp,
    required this.scaleR,
  });

  /// The snapshot used before any [PxResponsiveWrapper] has built:
  /// all scale factors are `1.0` (values render at design size, unscaled)
  /// and the device type defaults to [PxDeviceType.mobile].
  ///
  /// This is deliberately *not* the old behaviour of clamping to
  /// [PxResponsiveConfig.minScaleFactor] — a value read too early now
  /// renders at an obviously-unscaled size instead of a silently-wrong one.
  static const PxResponsiveData fallback = PxResponsiveData._(
    screenSize: Size.zero,
    effectiveWidth: 0,
    activeBaseSize: Size(375, 812),
    config: PxResponsiveConfig(),
    safeAreaPadding: EdgeInsets.zero,
    devicePixelRatio: 1.0,
    deviceType: PxDeviceType.mobile,
    tierBlend: 0.0,
    scaleW: 1.0,
    scaleH: 1.0,
    scaleSp: 1.0,
    scaleR: 1.0,
  );

  /// Builds a [PxResponsiveData] snapshot from a raw screen [size] and
  /// [config]. This is the single place the whole derivation pipeline runs:
  /// tier detection, orientation/auto-flip resolution, [PxResponsiveConfig.transitionBand]
  /// blending, raw scale calculation, then clamping.
  factory PxResponsiveData.fromSize({
    required Size size,
    required PxResponsiveConfig config,
    double devicePixelRatio = 1.0,
    EdgeInsets safeAreaPadding = EdgeInsets.zero,
  }) {
    assert(
      size.width.isFinite && size.height.isFinite,
      'PxResponsiveData.fromSize() was given a non-finite size ($size). '
      'This usually means PxResponsiveWrapper is inside an unbounded '
      'ancestor (e.g. a SingleChildScrollView\'s scroll axis). Wrap it in a '
      'SizedBox, or provide bounded constraints.',
    );

    final screenSize = Size(
      size.width.isFinite ? size.width : 0,
      size.height.isFinite ? size.height : 0,
    );
    final effectiveWidth = config.maxWidth != null
        ? math.min(screenSize.width, config.maxWidth!)
        : screenSize.width;
    final isLandscape = screenSize.width > screenSize.height;

    final deviceType = _detectDeviceType(
      effectiveWidth: effectiveWidth,
      screenHeight: screenSize.height,
      config: config,
    );

    final (base: activeBaseSize, tierBlend: tierBlend) = _resolveBaseAndBlend(
      effectiveWidth: effectiveWidth,
      deviceType: deviceType,
      isLandscape: isLandscape,
      config: config,
    );

    final rawScaleW =
        activeBaseSize.width > 0 ? effectiveWidth / activeBaseSize.width : 1.0;
    final rawScaleH = activeBaseSize.height > 0
        ? screenSize.height / activeBaseSize.height
        : 1.0;

    final scaleW = _finite(_clampScale(rawScaleW, config), fallback: 1.0);
    final scaleH = _finite(_clampScale(rawScaleH, config), fallback: 1.0);
    final scaleSp = _finite(_clampTextScale(rawScaleW, config), fallback: 1.0);
    final scaleR = _finite(
      _clampScale(math.min(rawScaleW, rawScaleH), config),
      fallback: 1.0,
    );

    return PxResponsiveData._(
      screenSize: screenSize,
      effectiveWidth: effectiveWidth,
      activeBaseSize: activeBaseSize,
      config: config,
      safeAreaPadding: safeAreaPadding,
      devicePixelRatio: devicePixelRatio,
      deviceType: deviceType,
      tierBlend: tierBlend,
      scaleW: scaleW,
      scaleH: scaleH,
      scaleSp: scaleSp,
      scaleR: scaleR,
    );
  }

  static double _finite(double value, {required double fallback}) =>
      value.isFinite ? value : fallback;

  static double _clampScale(double scale, PxResponsiveConfig config) {
    double result = scale;
    if (config.minScaleFactor != null) {
      result = math.max(result, config.minScaleFactor!);
    }
    if (config.maxScaleFactor != null) {
      result = math.min(result, config.maxScaleFactor!);
    }
    return result;
  }

  static double _clampTextScale(double scale, PxResponsiveConfig config) {
    double result = scale;
    if (config.minScaleFactor != null) {
      result = math.max(result, config.minScaleFactor!);
    }
    final maxText =
        config.maxTextScaleFactor ?? config.maxScaleFactor ?? double.infinity;
    result = math.min(result, maxText);
    return result;
  }

  /// Detects the discrete device tier.
  ///
  /// The two boundaries ask different questions, so — for
  /// [PxBreakpointAxis.hybrid] (the default) — they use different axes:
  /// [PxResponsiveConfig.mobileBreakpoint] asks "is this a phone?"
  /// (`min(effectiveWidth, screenHeight)`), while
  /// [PxResponsiveConfig.tabletBreakpoint] asks "is this a desktop-class
  /// wide window?" (`effectiveWidth`). A pure width check misclassifies a
  /// landscape phone as a tablet; a pure shortest-side check misclassifies
  /// every desktop monitor (whose height is rarely above 1200) as a tablet.
  static PxDeviceType _detectDeviceType({
    required double effectiveWidth,
    required double screenHeight,
    required PxResponsiveConfig config,
  }) {
    final double mobileCheckWidth;
    final double desktopCheckWidth;
    switch (config.breakpointAxis) {
      case PxBreakpointAxis.width:
        mobileCheckWidth = effectiveWidth;
        desktopCheckWidth = effectiveWidth;
      case PxBreakpointAxis.shortestSide:
        final shortestSide = math.min(effectiveWidth, screenHeight);
        mobileCheckWidth = shortestSide;
        desktopCheckWidth = shortestSide;
      case PxBreakpointAxis.hybrid:
        mobileCheckWidth = math.min(effectiveWidth, screenHeight);
        desktopCheckWidth = effectiveWidth;
    }
    if (mobileCheckWidth < config.mobileBreakpoint) return PxDeviceType.mobile;
    if (desktopCheckWidth < config.tabletBreakpoint) return PxDeviceType.tablet;
    return PxDeviceType.desktop;
  }

  /// Resolves the base design [Size] for a single tier, applying the
  /// explicit landscape override or [PxResponsiveConfig.autoFlipLandscapeBase]
  /// when in landscape.
  static Size _resolvedBaseForTier({
    required PxDeviceType tier,
    required bool isLandscape,
    required PxResponsiveConfig config,
  }) {
    final Size portraitBase;
    final Size? explicitLandscape;
    switch (tier) {
      case PxDeviceType.mobile:
        portraitBase = config.mobile;
        explicitLandscape = config.mobileLandscape;
      case PxDeviceType.tablet:
        portraitBase = config.tablet;
        explicitLandscape = config.tabletLandscape;
      case PxDeviceType.desktop:
        portraitBase = config.desktop;
        explicitLandscape = config.desktopLandscape;
    }
    if (!isLandscape) return portraitBase;
    if (explicitLandscape != null) return explicitLandscape;
    if (config.autoFlipLandscapeBase && portraitBase.height > portraitBase.width) {
      return Size(portraitBase.height, portraitBase.width);
    }
    return portraitBase;
  }

  /// Resolves the final [activeBaseSize] and [tierBlend], applying
  /// [PxResponsiveConfig.transitionBand] if the effective width falls
  /// within a band around either breakpoint.
  ///
  /// The band always compares against [effectiveWidth], regardless of
  /// [PxResponsiveConfig.breakpointAxis] — the axis only changes which
  /// dimension decides the *discrete* [deviceType].
  ///
  /// [deviceType] itself is never blended: there is no meaningful "60%
  /// tablet" for widgets like [PxResponsiveBuilder] that must return a
  /// single tree. Only the base size — and therefore the scale factors —
  /// are made continuous across the crossing.
  static ({Size base, double tierBlend}) _resolveBaseAndBlend({
    required double effectiveWidth,
    required PxDeviceType deviceType,
    required bool isLandscape,
    required PxResponsiveConfig config,
  }) {
    final band = config.transitionBand;
    if (band > 0) {
      final mobileBp = config.mobileBreakpoint;
      final mobileLo = mobileBp - band / 2;
      final mobileHi = mobileBp + band / 2;
      if (effectiveWidth > mobileLo && effectiveWidth < mobileHi) {
        final t = (effectiveWidth - mobileLo) / (mobileHi - mobileLo);
        final lower = _resolvedBaseForTier(
            tier: PxDeviceType.mobile, isLandscape: isLandscape, config: config);
        final upper = _resolvedBaseForTier(
            tier: PxDeviceType.tablet, isLandscape: isLandscape, config: config);
        return (base: Size.lerp(lower, upper, t)!, tierBlend: t);
      }

      final tabletBp = config.tabletBreakpoint;
      final tabletLo = tabletBp - band / 2;
      final tabletHi = tabletBp + band / 2;
      if (effectiveWidth > tabletLo && effectiveWidth < tabletHi) {
        final t = (effectiveWidth - tabletLo) / (tabletHi - tabletLo);
        final lower = _resolvedBaseForTier(
            tier: PxDeviceType.tablet, isLandscape: isLandscape, config: config);
        final upper = _resolvedBaseForTier(
            tier: PxDeviceType.desktop, isLandscape: isLandscape, config: config);
        return (base: Size.lerp(lower, upper, t)!, tierBlend: t);
      }
    }
    return (
      base: _resolvedBaseForTier(
          tier: deviceType, isLandscape: isLandscape, config: config),
      tierBlend: 0.0,
    );
  }

  // ============== Derived getters ==============

  /// `true` if [tierBlend] indicates the base size is currently being
  /// interpolated between two tiers (i.e. within a [PxResponsiveConfig.transitionBand]).
  bool get isInTransition => tierBlend > 0 && tierBlend < 1;

  /// Raw (unclamped) scale factor for width. Exposed for diagnostics.
  double get rawScaleW =>
      activeBaseSize.width > 0 ? effectiveWidth / activeBaseSize.width : 1.0;

  /// Raw (unclamped) scale factor for height. Exposed for diagnostics.
  double get rawScaleH => activeBaseSize.height > 0
      ? screenSize.height / activeBaseSize.height
      : 1.0;

  /// `true` if the current screen width is in the mobile range.
  bool get isMobile => deviceType == PxDeviceType.mobile;

  /// `true` if the current screen width is in the tablet range.
  bool get isTablet => deviceType == PxDeviceType.tablet;

  /// `true` if the current screen width is in the desktop range.
  bool get isDesktop => deviceType == PxDeviceType.desktop;

  /// `true` if the screen is in landscape orientation (width > height).
  bool get isLandscape => screenSize.width > screenSize.height;

  /// `true` if the screen is in portrait orientation (height >= width).
  bool get isPortrait => !isLandscape;

  /// The current screen orientation as a [PxOrientation] enum.
  PxOrientation get orientation =>
      isLandscape ? PxOrientation.landscape : PxOrientation.portrait;

  /// The current screen width, ignoring [PxResponsiveConfig.maxWidth].
  double get screenWidth => screenSize.width;

  /// The current screen height.
  double get screenHeight => screenSize.height;

  /// The top safe area inset (status bar, notch).
  double get safeAreaTop => safeAreaPadding.top;

  /// The bottom safe area inset (home indicator).
  double get safeAreaBottom => safeAreaPadding.bottom;

  /// The left safe area inset.
  double get safeAreaLeft => safeAreaPadding.left;

  /// The right safe area inset.
  double get safeAreaRight => safeAreaPadding.right;

  /// The screen height minus top and bottom safe area insets.
  double get safeScreenHeight =>
      screenSize.height - safeAreaPadding.top - safeAreaPadding.bottom;

  // ============== Scaling methods ==============

  /// Scales [value] by [scaleW].
  double w(num value) => value * scaleW;

  /// Scales [value] by [scaleH].
  double h(num value) => value * scaleH;

  /// Scales [value] by [scaleSp].
  double sp(num value) => value * scaleSp;

  /// Scales [value] by [scaleR].
  double r(num value) => value * scaleR;

  /// [value] as a percentage of [effectiveWidth].
  double wf(num value) => (value / 100) * effectiveWidth;

  /// [value] as a percentage of [screenHeight].
  double hf(num value) => (value / 100) * screenHeight;

  /// Returns the appropriate value based on [deviceType].
  T value<T>({required T mobile, T? tablet, T? desktop}) {
    if (isDesktop) return desktop ?? tablet ?? mobile;
    if (isTablet) return tablet ?? mobile;
    return mobile;
  }

  /// Returns the appropriate value based on [orientation].
  T orientationValue<T>({required T portrait, required T landscape}) =>
      isLandscape ? landscape : portrait;

  // ============== Rebuild predicates ==============

  /// Whether a widget tree built from [other] should be treated as
  /// meaningfully different from one built from `this`, for the purpose of
  /// the force-rebuild walk performed by [PxResponsiveWrapper].
  ///
  /// This is deliberately a *different* predicate from [operator ==]:
  /// [operator ==] (used by [PxResponsiveScope.updateShouldNotify]) is exact
  /// field equality, always correct for genuine [InheritedWidget] dependents.
  /// This method exists so [PxResponsiveConfig.rebuildEpsilon] can suppress
  /// walking the whole tree for sub-threshold continuous changes (e.g. while
  /// dragging a desktop window edge) while still reacting immediately to any
  /// discrete change.
  bool requiresRebuild(PxResponsiveData other, {double epsilon = 0.0}) {
    if (identical(this, other)) return false;
    if (deviceType != other.deviceType) return true;
    if (isLandscape != other.isLandscape) return true;
    if (activeBaseSize != other.activeBaseSize) return true;
    if (config != other.config) return true;
    if (safeAreaPadding != other.safeAreaPadding) return true;
    if (devicePixelRatio != other.devicePixelRatio) return true;

    if (epsilon <= 0) {
      return scaleW != other.scaleW ||
          scaleH != other.scaleH ||
          scaleSp != other.scaleSp ||
          scaleR != other.scaleR ||
          effectiveWidth != other.effectiveWidth ||
          screenSize != other.screenSize;
    }
    return _relativeChange(scaleW, other.scaleW) > epsilon ||
        _relativeChange(scaleH, other.scaleH) > epsilon ||
        _relativeChange(scaleSp, other.scaleSp) > epsilon ||
        _relativeChange(scaleR, other.scaleR) > epsilon ||
        _relativeChange(effectiveWidth, other.effectiveWidth) > epsilon ||
        _relativeChange(screenSize.height, other.screenSize.height) > epsilon;
  }

  static double _relativeChange(double a, double b) {
    final base = math.max(a.abs(), b.abs());
    if (base == 0) return 0;
    return (a - b).abs() / base;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PxResponsiveData &&
        other.screenSize == screenSize &&
        other.effectiveWidth == effectiveWidth &&
        other.activeBaseSize == activeBaseSize &&
        other.config == config &&
        other.safeAreaPadding == safeAreaPadding &&
        other.devicePixelRatio == devicePixelRatio &&
        other.deviceType == deviceType &&
        other.tierBlend == tierBlend &&
        other.scaleW == scaleW &&
        other.scaleH == scaleH &&
        other.scaleSp == scaleSp &&
        other.scaleR == scaleR;
  }

  @override
  int get hashCode => Object.hashAll([
        screenSize,
        effectiveWidth,
        activeBaseSize,
        config,
        safeAreaPadding,
        devicePixelRatio,
        deviceType,
        tierBlend,
        scaleW,
        scaleH,
        scaleSp,
        scaleR,
      ]);

  @override
  String toString() {
    return 'PxResponsiveData('
        'screenSize: $screenSize, '
        'effectiveWidth: ${effectiveWidth.toStringAsFixed(1)}, '
        'deviceType: $deviceType, '
        'orientation: $orientation, '
        'activeBaseSize: $activeBaseSize, '
        '${isInTransition ? 'tierBlend: ${tierBlend.toStringAsFixed(2)}, ' : ''}'
        'scaleW: ${scaleW.toStringAsFixed(3)}, '
        'scaleH: ${scaleH.toStringAsFixed(3)}, '
        'scaleSp: ${scaleSp.toStringAsFixed(3)}, '
        'scaleR: ${scaleR.toStringAsFixed(3)}, '
        'safeArea: $safeAreaPadding)';
  }
}
