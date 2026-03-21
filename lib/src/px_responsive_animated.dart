import 'package:flutter/widgets.dart';
import 'px_responsive_core.dart';

// ============================================================================
// ANIMATED RESPONSIVE BUILDER
// ============================================================================

/// A responsive builder that smoothly transitions between device layouts using
/// [AnimatedSwitcher].
///
/// On desktop, resizing the window can cause abrupt layout jumps. This widget
/// wraps each layout in a [KeyedSubtree] keyed on the active [PxDeviceType]
/// so that [AnimatedSwitcher] detects the change and plays the transition.
///
/// ## Basic Usage
///
/// ```dart
/// AnimatedPxResponsiveBuilder(
///   duration: Duration(milliseconds: 300),
///   mobile: (context) => MobileLayout(),
///   tablet: (context) => TabletLayout(),
///   desktop: (context) => DesktopLayout(),
/// )
/// ```
///
/// ## Fallback Behaviour
///
/// Same as [PxResponsiveBuilder]: desktop → tablet → mobile.
class AnimatedPxResponsiveBuilder extends StatelessWidget {
  /// The animation duration for layout transitions.
  ///
  /// Default: 300 milliseconds.
  final Duration duration;

  /// Optional curve for the transition animation.
  ///
  /// Default: [Curves.easeInOut].
  final Curve switchInCurve;

  /// Optional curve for the outgoing layout animation.
  ///
  /// Default: [Curves.easeInOut].
  final Curve switchOutCurve;

  /// Builder for the mobile layout.
  ///
  /// Required. Also used as the fallback for [tablet] and [desktop].
  final WidgetBuilder mobile;

  /// Builder for the tablet layout.
  ///
  /// Falls back to [mobile] when null.
  final WidgetBuilder? tablet;

  /// Builder for the desktop layout.
  ///
  /// Falls back to [tablet], then [mobile], when null.
  final WidgetBuilder? desktop;

  /// An optional custom transition builder passed to [AnimatedSwitcher].
  ///
  /// Defaults to a fade transition.
  final AnimatedSwitcherTransitionBuilder? transitionBuilder;

  /// Creates an animated responsive builder.
  const AnimatedPxResponsiveBuilder({
    super.key,
    this.duration = const Duration(milliseconds: 300),
    this.switchInCurve = Curves.easeInOut,
    this.switchOutCurve = Curves.easeInOut,
    required this.mobile,
    this.tablet,
    this.desktop,
    this.transitionBuilder,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = PxResponsive();

    final WidgetBuilder activeBuilder;
    if (responsive.isDesktop) {
      activeBuilder = desktop ?? tablet ?? mobile;
    } else if (responsive.isTablet) {
      activeBuilder = tablet ?? mobile;
    } else {
      activeBuilder = mobile;
    }

    return AnimatedSwitcher(
      duration: duration,
      switchInCurve: switchInCurve,
      switchOutCurve: switchOutCurve,
      transitionBuilder: transitionBuilder ??
          (child, animation) => FadeTransition(opacity: animation, child: child),
      child: KeyedSubtree(
        key: ValueKey(responsive.deviceType),
        child: activeBuilder(context),
      ),
    );
  }
}
