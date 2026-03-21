import 'package:flutter/widgets.dart';
import 'px_responsive_config.dart';
import 'px_responsive_core.dart';

// ============================================================================
// MEDIA QUERY WRAPPER - Uses MediaQuery instead of LayoutBuilder
// ============================================================================

/// A wrapper that initializes the responsive system using [MediaQuery] instead
/// of [LayoutBuilder].
///
/// Use this when [PxResponsiveWrapper] does not work correctly because it is
/// placed inside a constrained widget (e.g., a [Dialog] or a nested scaffold),
/// which causes [LayoutBuilder] to report the parent's constraints rather
/// than the full screen size.
///
/// ## When to Use
///
/// Prefer [PxResponsiveWrapper] at the app root. Use
/// [PxResponsiveMediaQueryWrapper] when:
/// - You need screen dimensions inside a constrained subtree.
/// - The root wrapper is not accessible (e.g., in a plugin widget).
///
/// ## Basic Usage
///
/// ```dart
/// void main() {
///   runApp(
///     PxResponsiveMediaQueryWrapper(
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
class PxResponsiveMediaQueryWrapper extends StatelessWidget {
  /// The child widget to render.
  ///
  /// Typically your [MaterialApp] or [CupertinoApp].
  final Widget? child;

  /// A builder that provides direct access to the [PxResponsive] instance.
  ///
  /// Either [child] or [builder] must be provided.
  final Widget Function(BuildContext context, PxResponsive responsive)? builder;

  /// Configuration for the responsive system.
  final PxResponsiveConfig config;

  /// Creates a media-query-based responsive wrapper.
  ///
  /// Either [child] or [builder] must be provided, but not both.
  const PxResponsiveMediaQueryWrapper({
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
    final mediaQuery = MediaQuery.of(context);
    final size = mediaQuery.size;

    PxResponsive().init(
      constraints: BoxConstraints(
        maxWidth: size.width,
        maxHeight: size.height,
      ),
      config: config,
      devicePixelRatio: mediaQuery.devicePixelRatio,
      safeAreaPadding: mediaQuery.padding,
    );

    if (builder != null) {
      return builder!(context, PxResponsive());
    }
    return child!;
  }
}
