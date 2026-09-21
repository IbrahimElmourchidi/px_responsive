import 'package:flutter/widgets.dart';
import 'px_responsive_config.dart';
import 'px_responsive_core.dart';
import 'px_responsive_data.dart';
import 'px_responsive_scope.dart';

// ============================================================================
// MAIN WRAPPER - Use this at the root of your app
// ============================================================================

/// A wrapper widget that initializes the responsive scaling system.
///
/// This widget must wrap your app's root widget (typically [MaterialApp] or
/// [CupertinoApp]) to enable responsive scaling throughout your application.
///
/// ## Basic Usage
///
/// ```dart
/// void main() {
///   runApp(
///     PxResponsiveWrapper(
///       config: const PxResponsiveConfig(
///         desktop: Size(1920, 1080),
///         tablet: Size(834, 1194),
///         mobile: Size(375, 812),
///       ),
///       child: const MyApp(),
///     ),
///   );
/// }
/// ```
///
/// ## With maxWidth for Ultra-Wide Screens
///
/// ```dart
/// void main() {
///   runApp(
///     PxResponsiveWrapper(
///       config: const PxResponsiveConfig(
///         desktop: Size(1920, 1080),
///         tablet: Size(834, 1194),
///         mobile: Size(375, 812),
///         maxWidth: 1920, // Cap scaling at 1920px, and center content
///       ),
///       child: const MyApp(),
///     ),
///   );
/// }
/// ```
///
/// On a 3840px wide screen, elements will scale as if the screen
/// is 1920px wide, and the whole app is centered in a 1920px-wide column
/// with empty space on either side (see [PxResponsiveConfig.maxWidthBackground]
/// to paint that space, and [PxResponsiveConfig.maxWidthBehavior] to opt out
/// of the centering and only cap the scale factor).
///
/// ## Using the Builder
///
/// ```dart
/// PxResponsiveWrapper(
///   config: const PxResponsiveConfig(),
///   builder: (context, responsive) {
///     // Access PxResponsive instance directly
///     print('Current scale: ${responsive.scaleW}');
///     return const MyApp();
///   },
/// )
/// ```
///
/// ## Reactivity
///
/// On every layout pass, this widget re-derives its [PxResponsiveData]
/// snapshot and publishes it two ways: through a [PxResponsiveScope] (so
/// this package's own widgets and `context.responsive` rebuild correctly),
/// and — when [forceRebuildOnChange] is `true` (the default) — by walking
/// its subtree and marking every descendant dirty, so plain `200.w`-style
/// reads pick up the new value even though their widget instance didn't
/// change. Set `forceRebuildOnChange: false` only if your app exclusively
/// reads through [PxResponsiveScope]/`context.responsive` and you've
/// profiled the walk as a real cost; see [PxResponsiveRebuildBoundary] for
/// a more surgical opt-out.
///
/// ## Nested wrappers
///
/// Only the root-most [PxResponsiveWrapper] (the one with no
/// [PxResponsiveScope] above it) writes to the static [PxResponsive]
/// singleton. A nested wrapper still works correctly for anything that
/// reads through [PxResponsiveScope]/`context.responsive` beneath it, but
/// bare `.w`/`.h`/`.sp`/`.r` reads inside it use the *root* wrapper's data,
/// not the nested one's — nest wrappers only when you specifically need a
/// different [PxResponsiveConfig] for a subtree accessed via context.
class PxResponsiveWrapper extends StatelessWidget {
  /// The child widget to render.
  ///
  /// Typically your [MaterialApp] or [CupertinoApp].
  final Widget? child;

  /// A builder function that provides access to the [PxResponsive] instance.
  ///
  /// Use this when you need direct access to the responsive instance
  /// at the root level. Either [child] or [builder] must be provided.
  final Widget Function(BuildContext context, PxResponsive responsive)? builder;

  /// Configuration for the responsive system.
  ///
  /// Defines the base design sizes, breakpoints, and scaling constraints.
  final PxResponsiveConfig config;

  /// Whether to force a rebuild of every descendant when the responsive
  /// data changes, so plain `num` extensions like `.w`/`.h`/`.sp` stay
  /// correct after a resize/rotation even though their widget instance is
  /// unchanged. Default: `true`. See the "Reactivity" section above.
  final bool forceRebuildOnChange;

  /// Creates a responsive wrapper.
  ///
  /// Either [child] or [builder] must be provided, but not both.
  ///
  /// Example with child:
  /// ```dart
  /// PxResponsiveWrapper(
  ///   config: const PxResponsiveConfig(),
  ///   child: const MyApp(),
  /// )
  /// ```
  ///
  /// Example with builder:
  /// ```dart
  /// PxResponsiveWrapper(
  ///   config: const PxResponsiveConfig(),
  ///   builder: (context, responsive) => const MyApp(),
  /// )
  /// ```
  const PxResponsiveWrapper({
    super.key,
    this.child,
    this.builder,
    this.config = const PxResponsiveConfig(),
    this.forceRebuildOnChange = true,
  }) : assert(
          child != null || builder != null,
          'Either child or builder must be provided',
        );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get device pixel ratio and safe area from MediaQuery if available
        double devicePixelRatio = 1.0;
        EdgeInsets safeAreaPadding = EdgeInsets.zero;
        final mediaQuery = MediaQuery.maybeOf(context);
        if (mediaQuery != null) {
          devicePixelRatio = mediaQuery.devicePixelRatio;
          safeAreaPadding = mediaQuery.padding;
        }

        final candidate = PxResponsiveData.fromSize(
          size: Size(constraints.maxWidth, constraints.maxHeight),
          config: config,
          devicePixelRatio: devicePixelRatio,
          safeAreaPadding: safeAreaPadding,
        );

        return pxBuildResponsiveSubtree(
          context: context,
          incomingConstraints: constraints,
          candidate: candidate,
          forceRebuildOnChange: forceRebuildOnChange,
          buildChild: (data) {
            if (builder != null) return builder!(context, PxResponsive());
            return child!;
          },
        );
      },
    );
  }
}
