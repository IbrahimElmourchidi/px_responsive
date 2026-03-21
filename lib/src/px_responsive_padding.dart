import 'package:flutter/widgets.dart';
import 'px_responsive_core.dart';
import 'px_responsive_extensions.dart';

// ============================================================================
// RESPONSIVE PADDING WIDGET
// ============================================================================

/// A widget that applies device-specific responsive padding to its child.
///
/// Wrapping a widget in [PxResponsivePadding] reduces the boilerplate of
/// selecting and optionally scaling an [EdgeInsets] per device type.
///
/// ## Basic Usage
///
/// ```dart
/// PxResponsivePadding(
///   mobile: const EdgeInsets.all(12),
///   tablet: const EdgeInsets.all(20),
///   desktop: const EdgeInsets.all(32),
///   child: const MyContent(),
/// )
/// ```
///
/// ## With Automatic Scaling
///
/// Set [scale] to `true` to additionally apply `.scaled` on the selected
/// [EdgeInsets], which scales horizontal values by [PxResponsive.scaleW]
/// and vertical values by [PxResponsive.scaleH]:
///
/// ```dart
/// PxResponsivePadding(
///   mobile: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
///   scale: true,
///   child: const MyContent(),
/// )
/// ```
class PxResponsivePadding extends StatelessWidget {
  /// Padding applied on mobile devices.
  ///
  /// Required. Also used as the fallback when [tablet] or [desktop] are null.
  final EdgeInsets mobile;

  /// Padding applied on tablet devices.
  ///
  /// Falls back to [mobile] when null.
  final EdgeInsets? tablet;

  /// Padding applied on desktop devices.
  ///
  /// Falls back to [tablet], then [mobile], when null.
  final EdgeInsets? desktop;

  /// The widget to pad.
  final Widget child;

  /// Whether to additionally scale the selected [EdgeInsets] using
  /// [PxResponsiveEdgeInsetsExtension.scaled].
  ///
  /// When `true`, horizontal values are multiplied by [PxResponsive.scaleW]
  /// and vertical values by [PxResponsive.scaleH].
  ///
  /// Default: `false`
  final bool scale;

  /// Creates a responsive padding widget.
  const PxResponsivePadding({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    required this.child,
    this.scale = false,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = PxResponsive();
    EdgeInsets padding;

    if (responsive.isDesktop) {
      padding = desktop ?? tablet ?? mobile;
    } else if (responsive.isTablet) {
      padding = tablet ?? mobile;
    } else {
      padding = mobile;
    }

    if (scale) {
      padding = padding.scaled;
    }

    return Padding(padding: padding, child: child);
  }
}
