import 'package:flutter/widgets.dart';

/// Represents the current device orientation.
///
/// Example:
/// ```dart
/// if (orientation == PxOrientation.landscape) {
///   return LandscapeLayout();
/// }
/// ```
enum PxOrientation {
  /// Portrait orientation: height is greater than or equal to width.
  portrait,

  /// Landscape orientation: width is greater than height.
  landscape,
}

/// Which screen dimension(s) decide the discrete [PxDeviceType] breakpoint.
///
/// See [PxResponsiveConfig.breakpointAxis].
enum PxBreakpointAxis {
  /// [PxResponsiveConfig.mobileBreakpoint] is compared against
  /// `min(effectiveWidth, screenHeight)` ("is this a phone, in either
  /// orientation?"), while [PxResponsiveConfig.tabletBreakpoint] is compared
  /// against `effectiveWidth` ("is this a desktop-class wide window?").
  ///
  /// This is the default and the recommended axis: it correctly classifies
  /// a landscape phone as mobile (a pure width check would call it a
  /// tablet) while still correctly classifying a short desktop monitor as
  /// desktop (a pure shortest-side check would call every desktop a
  /// tablet, since most monitors are under 1200px tall).
  hybrid,

  /// Both breakpoints compare against `effectiveWidth` only. This matches
  /// `px_responsive` 0.1.x's behaviour (minus the `effectiveWidth` vs
  /// actual-width distinction — see the [PxResponsiveConfig.maxWidth] docs).
  width,

  /// Both breakpoints compare against `min(effectiveWidth, screenHeight)`.
  /// Not recommended as a default: it classifies most desktop monitors as
  /// tablets, since their height is usually well under 1200px.
  shortestSide,
}

/// How [PxResponsiveConfig.maxWidth] affects layout once the screen exceeds it.
enum PxMaxWidthBehavior {
  /// Physically constrains the content to [PxResponsiveConfig.maxWidth],
  /// centering it and leaving empty space (optionally filled with
  /// [PxResponsiveConfig.maxWidthBackground]) on either side. This is the
  /// default, and matches the "centered content area" ultra-wide pattern
  /// described throughout this package's documentation.
  constrain,

  /// Only caps the *scale factor* — content still stretches to fill the
  /// full screen width, just without scaling proportionally past
  /// [PxResponsiveConfig.maxWidth]. This is `px_responsive` 0.1.x's
  /// behaviour; kept for anyone who relied on the full-bleed layout.
  scaleOnly,
}

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
///   maxWidth: 1920, // Prevent scaling beyond 1920px width, and center content
/// );
/// ```
///
/// ## Why use maxWidth?
///
/// On ultra-wide screens (e.g., 3840px or 5120px), scaling UI elements
/// proportionally can make them excessively wide while the height remains normal.
/// Setting [maxWidth] (with the default [maxWidthBehavior] of
/// [PxMaxWidthBehavior.constrain]) physically centers the content within a
/// column of that width, leaving empty space on either side — a common
/// design pattern for very wide displays. Use [maxWidthBehavior] =
/// [PxMaxWidthBehavior.scaleOnly] to only cap the scale factor without
/// constraining the layout.
class PxResponsiveConfig {
  /// Base design size for Desktop layouts.
  ///
  /// This should match your design tool's desktop artboard size.
  /// Common values: Size(1920, 1080), Size(1440, 900), Size(1366, 768)
  final Size desktop;

  /// Base design size for Desktop layouts in landscape orientation.
  ///
  /// When set and the device is in landscape, this size is used instead of
  /// [desktop] for scaling calculations. If null, [desktop] is used —
  /// flipped automatically when [autoFlipLandscapeBase] is `true` (the
  /// default) and [desktop] is taller than it is wide.
  final Size? desktopLandscape;

  /// Base design size for Tablet layouts.
  ///
  /// This should match your design tool's tablet artboard size.
  /// Common values: Size(834, 1194), Size(768, 1024), Size(1024, 768)
  final Size tablet;

  /// Base design size for Tablet layouts in landscape orientation.
  ///
  /// When set and the device is in landscape, this size is used instead of
  /// [tablet] for scaling calculations. If null, [tablet] is used —
  /// flipped automatically when [autoFlipLandscapeBase] is `true` (the
  /// default) and [tablet] is taller than it is wide.
  final Size? tabletLandscape;

  /// Base design size for Mobile layouts.
  ///
  /// This should match your design tool's mobile artboard size.
  /// Common values: Size(375, 812), Size(360, 640), Size(414, 896)
  final Size mobile;

  /// Base design size for Mobile layouts in landscape orientation.
  ///
  /// When set and the device is in landscape, this size is used instead of
  /// [mobile] for scaling calculations. If null, [mobile] is used —
  /// flipped automatically when [autoFlipLandscapeBase] is `true` (the
  /// default) and [mobile] is taller than it is wide.
  ///
  /// Example:
  /// ```dart
  /// PxResponsiveConfig(
  ///   mobile: Size(375, 812),
  ///   mobileLandscape: Size(812, 375),
  /// )
  /// ```
  final Size? mobileLandscape;

  /// The width threshold below which the layout is considered Mobile.
  ///
  /// Default: 600 logical pixels. Compared against a dimension chosen by
  /// [breakpointAxis] — by default, `min(effectiveWidth, screenHeight)`, so
  /// a landscape phone is still correctly detected as mobile.
  final double mobileBreakpoint;

  /// The width threshold at or above which the layout is considered Desktop.
  ///
  /// Default: 1200 logical pixels. Compared against a dimension chosen by
  /// [breakpointAxis] — by default, `effectiveWidth`. Between
  /// [mobileBreakpoint] and [tabletBreakpoint], tablet base size is used.
  final double tabletBreakpoint;

  /// Which screen dimension(s) [mobileBreakpoint] and [tabletBreakpoint]
  /// are compared against.
  ///
  /// Default: [PxBreakpointAxis.hybrid].
  final PxBreakpointAxis breakpointAxis;

  /// The width (in logical pixels) of a blending band centered on each of
  /// [mobileBreakpoint] and [tabletBreakpoint], within which [activeBaseSize]
  /// —and therefore every scale factor— is linearly interpolated between
  /// the two adjacent tiers' base sizes instead of switching abruptly.
  ///
  /// Default: `0` (disabled — matches `px_responsive` 0.1.x's hard switch).
  ///
  /// Without a transition band, crossing a breakpoint can be a large,
  /// visible jump: with the default configuration, `16.sp` renders at
  /// 23.0px at width 1199 and 10.0px at width 1200. Setting
  /// `transitionBand: 100` spreads that same change continuously across
  /// widths 1150–1250.
  ///
  /// [PxDeviceType] itself is never blended — it always switches exactly at
  /// the breakpoint, since widgets like [PxResponsiveBuilder] must return a
  /// single, discrete tree. Only the base size (and thus the scale factors)
  /// becomes continuous; see `PxResponsiveData.tierBlend`.
  ///
  /// Must be strictly less than `tabletBreakpoint - mobileBreakpoint`, so
  /// the two bands never overlap.
  final double transitionBand;

  /// Whether to automatically use a flipped (width/height swapped) base
  /// size in landscape when no explicit `*Landscape` size is configured
  /// for the active tier.
  ///
  /// Default: `true`. Only applies when the portrait base for that tier is
  /// taller than it is wide (desktop bases are left untouched, since they
  /// are already landscape-shaped).
  ///
  /// Without this, a landscape phone using a portrait mobile base (e.g.
  /// 375×812) produces a severely under-scaled height — `scaleH` computed
  /// against a base of 812 on a screen that is actually ~375–430px tall.
  final bool autoFlipLandscapeBase;

  /// Maximum width for scaling calculations.
  ///
  /// When the actual screen width exceeds this value, the package uses
  /// [maxWidth] for scaling calculations instead of the actual width, and
  /// (per [maxWidthBehavior]) may also physically constrain the layout.
  ///
  /// Example:
  /// ```dart
  /// PxResponsiveConfig(
  ///   desktop: Size(1920, 1080),
  ///   maxWidth: 1920, // Cap scaling at 1920px, and center content
  /// )
  /// ```
  ///
  /// On a 3840px wide screen, with the default [maxWidthBehavior]:
  /// - Elements maintain 100% of design size
  /// - Content is centered in a 1920px-wide column with empty space on
  ///   either side (paint that space with [maxWidthBackground])
  ///
  /// Set to null (default) to disable width capping.
  final double? maxWidth;

  /// How [maxWidth] affects layout. Default: [PxMaxWidthBehavior.constrain].
  final PxMaxWidthBehavior maxWidthBehavior;

  /// Color painted behind the empty space left on either side when
  /// [maxWidth] is set, [maxWidthBehavior] is [PxMaxWidthBehavior.constrain],
  /// and the screen is wider than [maxWidth].
  ///
  /// Default: `null`, which paints nothing (transparent) — on the common
  /// `runApp(PxResponsiveWrapper(child: MaterialApp(...)))` structure, that
  /// means whatever is behind the window (typically black).
  final Color? maxWidthBackground;

  /// Minimum scale factor to prevent elements from becoming too small.
  ///
  /// Default: `null` (disabled). Set a floor only if you understand the
  /// tradeoff: a floor guarantees that on a screen narrower than
  /// `base.width * minScaleFactor`, scaled content will overflow the
  /// viewport rather than shrink further.
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

  /// Relative-change threshold below which [PxResponsiveWrapper] skips its
  /// force-rebuild subtree walk after a screen size change.
  ///
  /// Default: `0.0` (any change, however small, triggers a rebuild — the
  /// correct choice for most apps). On a large desktop app where a window
  /// drag visibly costs frames, a small threshold like `0.005` (0.5%) trades
  /// a bounded amount of staleness for fewer rebuilds; because the
  /// comparison is always against the last *applied* snapshot, error never
  /// accumulates, but the app can sit up to `rebuildEpsilon` stale at rest.
  /// For per-subtree control instead, wrap non-responsive subtrees (a map,
  /// a video player, a long const list) in `PxResponsiveRebuildBoundary`.
  final double rebuildEpsilon;

  /// Creates a responsive design configuration.
  ///
  /// All size parameters should use logical pixels.
  const PxResponsiveConfig({
    this.desktop = const Size(1920, 1080),
    this.desktopLandscape,
    this.tablet = const Size(834, 1194),
    this.tabletLandscape,
    this.mobile = const Size(375, 812),
    this.mobileLandscape,
    this.mobileBreakpoint = 600,
    this.tabletBreakpoint = 1200,
    this.breakpointAxis = PxBreakpointAxis.hybrid,
    this.transitionBand = 0.0,
    this.autoFlipLandscapeBase = true,
    this.maxWidth,
    this.maxWidthBehavior = PxMaxWidthBehavior.constrain,
    this.maxWidthBackground,
    this.minScaleFactor,
    this.maxScaleFactor = 2.0,
    this.maxTextScaleFactor = 1.5,
    this.rebuildEpsilon = 0.0,
  })  : assert(mobileBreakpoint > 0, 'mobileBreakpoint must be positive'),
        assert(
          tabletBreakpoint > mobileBreakpoint,
          'tabletBreakpoint must be greater than mobileBreakpoint',
        ),
        assert(
          transitionBand >= 0,
          'transitionBand must be >= 0',
        ),
        assert(
          transitionBand < tabletBreakpoint - mobileBreakpoint,
          'transitionBand must be strictly less than '
          '(tabletBreakpoint - mobileBreakpoint), otherwise the transition '
          'bands around the two breakpoints would overlap.',
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
        ),
        assert(
          rebuildEpsilon >= 0,
          'rebuildEpsilon must be >= 0',
        );

  /// Sentinel used by [copyWith] to distinguish "not provided" (keep the
  /// current value) from "explicitly provided as null" (clear it) for
  /// nullable fields.
  static const Object _unset = Object();

  /// Creates a copy of this config with the given fields replaced.
  ///
  /// Nullable fields ([desktopLandscape], [tabletLandscape], [mobileLandscape],
  /// [maxWidth], [maxWidthBackground], [minScaleFactor], [maxScaleFactor],
  /// [maxTextScaleFactor]) accept an untyped value so that passing an
  /// explicit `null` clears the field, distinct from omitting the
  /// parameter (which keeps the current value):
  ///
  /// ```dart
  /// final withoutCap = config.copyWith(maxWidth: null); // clears maxWidth
  /// final unchanged = config.copyWith();                // keeps maxWidth
  /// ```
  PxResponsiveConfig copyWith({
    Size? desktop,
    Object? desktopLandscape = _unset,
    Size? tablet,
    Object? tabletLandscape = _unset,
    Size? mobile,
    Object? mobileLandscape = _unset,
    double? mobileBreakpoint,
    double? tabletBreakpoint,
    PxBreakpointAxis? breakpointAxis,
    double? transitionBand,
    bool? autoFlipLandscapeBase,
    Object? maxWidth = _unset,
    PxMaxWidthBehavior? maxWidthBehavior,
    Object? maxWidthBackground = _unset,
    Object? minScaleFactor = _unset,
    Object? maxScaleFactor = _unset,
    Object? maxTextScaleFactor = _unset,
    double? rebuildEpsilon,
  }) {
    return PxResponsiveConfig(
      desktop: desktop ?? this.desktop,
      desktopLandscape: identical(desktopLandscape, _unset)
          ? this.desktopLandscape
          : desktopLandscape as Size?,
      tablet: tablet ?? this.tablet,
      tabletLandscape: identical(tabletLandscape, _unset)
          ? this.tabletLandscape
          : tabletLandscape as Size?,
      mobile: mobile ?? this.mobile,
      mobileLandscape: identical(mobileLandscape, _unset)
          ? this.mobileLandscape
          : mobileLandscape as Size?,
      mobileBreakpoint: mobileBreakpoint ?? this.mobileBreakpoint,
      tabletBreakpoint: tabletBreakpoint ?? this.tabletBreakpoint,
      breakpointAxis: breakpointAxis ?? this.breakpointAxis,
      transitionBand: transitionBand ?? this.transitionBand,
      autoFlipLandscapeBase:
          autoFlipLandscapeBase ?? this.autoFlipLandscapeBase,
      maxWidth: identical(maxWidth, _unset) ? this.maxWidth : maxWidth as double?,
      maxWidthBehavior: maxWidthBehavior ?? this.maxWidthBehavior,
      maxWidthBackground: identical(maxWidthBackground, _unset)
          ? this.maxWidthBackground
          : maxWidthBackground as Color?,
      minScaleFactor: identical(minScaleFactor, _unset)
          ? this.minScaleFactor
          : minScaleFactor as double?,
      maxScaleFactor: identical(maxScaleFactor, _unset)
          ? this.maxScaleFactor
          : maxScaleFactor as double?,
      maxTextScaleFactor: identical(maxTextScaleFactor, _unset)
          ? this.maxTextScaleFactor
          : maxTextScaleFactor as double?,
      rebuildEpsilon: rebuildEpsilon ?? this.rebuildEpsilon,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PxResponsiveConfig &&
        other.desktop == desktop &&
        other.desktopLandscape == desktopLandscape &&
        other.tablet == tablet &&
        other.tabletLandscape == tabletLandscape &&
        other.mobile == mobile &&
        other.mobileLandscape == mobileLandscape &&
        other.mobileBreakpoint == mobileBreakpoint &&
        other.tabletBreakpoint == tabletBreakpoint &&
        other.breakpointAxis == breakpointAxis &&
        other.transitionBand == transitionBand &&
        other.autoFlipLandscapeBase == autoFlipLandscapeBase &&
        other.maxWidth == maxWidth &&
        other.maxWidthBehavior == maxWidthBehavior &&
        other.maxWidthBackground == maxWidthBackground &&
        other.minScaleFactor == minScaleFactor &&
        other.maxScaleFactor == maxScaleFactor &&
        other.maxTextScaleFactor == maxTextScaleFactor &&
        other.rebuildEpsilon == rebuildEpsilon;
  }

  @override
  int get hashCode => Object.hashAll([
        desktop,
        desktopLandscape,
        tablet,
        tabletLandscape,
        mobile,
        mobileLandscape,
        mobileBreakpoint,
        tabletBreakpoint,
        breakpointAxis,
        transitionBand,
        autoFlipLandscapeBase,
        maxWidth,
        maxWidthBehavior,
        maxWidthBackground,
        minScaleFactor,
        maxScaleFactor,
        maxTextScaleFactor,
        rebuildEpsilon,
      ]);

  @override
  String toString() {
    return 'PxResponsiveConfig('
        'desktop: $desktop, '
        'desktopLandscape: $desktopLandscape, '
        'tablet: $tablet, '
        'tabletLandscape: $tabletLandscape, '
        'mobile: $mobile, '
        'mobileLandscape: $mobileLandscape, '
        'mobileBreakpoint: $mobileBreakpoint, '
        'tabletBreakpoint: $tabletBreakpoint, '
        'breakpointAxis: $breakpointAxis, '
        'transitionBand: $transitionBand, '
        'autoFlipLandscapeBase: $autoFlipLandscapeBase, '
        'maxWidth: $maxWidth, '
        'maxWidthBehavior: $maxWidthBehavior, '
        'maxWidthBackground: $maxWidthBackground, '
        'minScaleFactor: $minScaleFactor, '
        'maxScaleFactor: $maxScaleFactor, '
        'maxTextScaleFactor: $maxTextScaleFactor, '
        'rebuildEpsilon: $rebuildEpsilon)';
  }
}

/// Enum representing the current device type based on screen width.
///
/// Use with [deviceType] global getter or `PxResponsive.deviceType`:
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
