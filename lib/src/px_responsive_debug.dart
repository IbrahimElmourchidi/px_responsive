import 'package:flutter/widgets.dart';
import 'px_responsive_scope.dart';

// ============================================================================
// DEBUG OVERLAY - Visualise breakpoints and scale factors during development
// ============================================================================

/// A widget that overlays current responsive diagnostics on top of its child.
///
/// Useful during development to see the active device type, screen dimensions,
/// base design size, and scale factors at a glance.
///
/// The overlay is only rendered when [enabled] is `true`, so it is safe to
/// leave the widget in your tree guarded by `kDebugMode`:
///
/// ```dart
/// PxResponsiveWrapper(
///   config: config,
///   child: PxResponsiveDebug(
///     enabled: kDebugMode,
///     child: MyApp(),
///   ),
/// )
/// ```
///
/// This works whether placed above or below [MaterialApp]/[CupertinoApp] —
/// it supplies its own [Directionality] and doesn't depend on an ancestor
/// for one.
///
/// The overlay is positioned in the top-left corner by default.
class PxResponsiveDebug extends StatelessWidget {
  /// The child widget to render beneath the debug overlay.
  final Widget child;

  /// Whether to show the overlay.
  ///
  /// Set to `false` (or `!kDebugMode`) to disable in release builds.
  /// Default: `true`
  final bool enabled;

  /// Creates a responsive debug overlay widget.
  const PxResponsiveDebug({
    super.key,
    required this.child,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!enabled) return child;

    final data = pxDataOf(context);

    return Stack(
      alignment: Alignment.topLeft,
      children: [
        child,
        Positioned(
          top: 0,
          left: 0,
          child: IgnorePointer(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Container(
                padding: const EdgeInsets.all(8),
                color: const Color(0xB3000000), // black 70 %
                child: DefaultTextStyle(
                  style: const TextStyle(
                    color: Color(0xFFFFFFFF),
                    fontSize: 11,
                    fontFamily: 'monospace',
                    decoration: TextDecoration.none,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('device : ${data.deviceType.name}'),
                      Text(
                        'screen : '
                        '${data.screenWidth.toStringAsFixed(0)}×'
                        '${data.screenHeight.toStringAsFixed(0)}',
                      ),
                      Text('orient : ${data.orientation.name}'),
                      Text(
                        'base   : '
                        '${data.activeBaseSize.width.toStringAsFixed(0)}×'
                        '${data.activeBaseSize.height.toStringAsFixed(0)}',
                      ),
                      if (data.isInTransition)
                        Text('blend  : ${data.tierBlend.toStringAsFixed(2)}'),
                      Text('scaleW : ${data.scaleW.toStringAsFixed(3)}'),
                      Text('scaleH : ${data.scaleH.toStringAsFixed(3)}'),
                      Text('scaleSp: ${data.scaleSp.toStringAsFixed(3)}'),
                      Text('scaleR : ${data.scaleR.toStringAsFixed(3)}'),
                      Text(
                        'effW   : ${data.effectiveWidth.toStringAsFixed(0)}',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
