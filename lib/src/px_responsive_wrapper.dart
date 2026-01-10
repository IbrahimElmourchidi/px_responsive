import 'package:flutter/widgets.dart';
import 'px_responsive_config.dart';
import 'px_responsive_core.dart';

// ============================================================================
// MAIN WRAPPER - Use this at the root of your app
// ============================================================================

/// A wrapper widget that initializes the responsive scaling system.
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
class PxResponsiveWrapper extends StatelessWidget {
  /// The child widget to render.
  final Widget? child;

  /// A builder function that provides access to the [PxResponsive] instance.
  final Widget Function(BuildContext context, PxResponsive responsive)? builder;

  /// Configuration for the responsive system.
  final PxResponsiveConfig config;

  /// Creates a responsive wrapper.
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
        double devicePixelRatio = 1.0;
        final mediaQuery = MediaQuery.maybeOf(context);
        if (mediaQuery != null) {
          devicePixelRatio = mediaQuery.devicePixelRatio;
        }

        PxResponsive().init(
          constraints: constraints,
          config: config,
          devicePixelRatio: devicePixelRatio,
        );

        if (builder != null) {
          return builder!(context, PxResponsive());
        }
        return child!;
      },
    );
  }
}
