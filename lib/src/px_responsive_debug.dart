import 'package:flutter/widgets.dart';
import 'px_responsive_core.dart';

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
/// The overlay is positioned in the top-right corner by default.
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

    final r = PxResponsive();

    return Stack(
      children: [
        child,
        Positioned(
          top: 0,
          right: 0,
          child: IgnorePointer(
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
                    Text('device : ${r.deviceType.name}'),
                    Text(
                      'screen : '
                      '${r.screenWidth.toStringAsFixed(0)}×'
                      '${r.screenHeight.toStringAsFixed(0)}',
                    ),
                    Text('orient : ${r.orientation.name}'),
                    Text(
                      'base   : '
                      '${r.activeBaseSize.width.toStringAsFixed(0)}×'
                      '${r.activeBaseSize.height.toStringAsFixed(0)}',
                    ),
                    Text('scaleW : ${r.scaleW.toStringAsFixed(3)}'),
                    Text('scaleH : ${r.scaleH.toStringAsFixed(3)}'),
                    Text('scaleSp: ${r.scaleSp.toStringAsFixed(3)}'),
                    Text('scaleR : ${r.scaleR.toStringAsFixed(3)}'),
                    Text(
                      'effW   : ${r.effectiveWidth.toStringAsFixed(0)}',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
