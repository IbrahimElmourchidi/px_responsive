import 'package:flutter/widgets.dart';
import 'px_responsive_config.dart';
import 'px_responsive_core.dart';

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
///         maxWidth: 1920, // Cap scaling at 1920px
///       ),
///       child: const MyApp(),
///     ),
///   );
/// }
/// ```
///
/// On a 3840px wide screen, elements will scale as if the screen
/// is 1920px wide, creating a centered content area with margins.
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
  }) : assert(
          child != null || builder != null,
          'Either child or builder must be provided',
        );

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Get device pixel ratio from MediaQuery if available
        double devicePixelRatio = 1.0;
        final mediaQuery = MediaQuery.maybeOf(context);
        if (mediaQuery != null) {
          devicePixelRatio = mediaQuery.devicePixelRatio;
        }

        // Initialize the responsive singleton with current constraints
        PxResponsive().init(
          constraints: constraints,
          config: config,
          devicePixelRatio: devicePixelRatio,
        );

        // Use builder if provided, otherwise use child
        if (builder != null) {
          return builder!(context, PxResponsive());
        }
        return child!;
      },
    );
  }
}
