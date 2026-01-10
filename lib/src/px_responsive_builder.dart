import 'package:flutter/widgets.dart';
import 'px_responsive_config.dart';
import 'px_responsive_core.dart';

// ============================================================================
// RESPONSIVE BUILDER - Build different widgets per device type
// ============================================================================

/// A builder widget that builds different layouts based on device type.
///
/// Use this widget when you need completely different widget trees
/// for different device types (mobile, tablet, desktop).
///
/// ## Basic Example
///
/// ```dart
/// PxResponsiveBuilder(
///   mobile: (context) => const MobileLayout(),
///   tablet: (context) => const TabletLayout(),
///   desktop: (context) => const DesktopLayout(),
/// )
/// ```
class PxResponsiveBuilder extends StatelessWidget {
  /// Builder function for mobile layout.
  /// Called when screen width < [PxResponsiveConfig.mobileBreakpoint].
  final WidgetBuilder mobile;

  /// Builder function for tablet layout.
  /// Called when [PxResponsiveConfig.mobileBreakpoint] <= width < [PxResponsiveConfig.tabletBreakpoint].
  final WidgetBuilder? tablet;

  /// Builder function for desktop layout.
  /// Called when screen width >= [PxResponsiveConfig.tabletBreakpoint].
  final WidgetBuilder? desktop;

  const PxResponsiveBuilder({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = PxResponsive();
    if (responsive.isDesktop) {
      return (desktop ?? tablet ?? mobile)(context);
    }
    if (responsive.isTablet) {
      return (tablet ?? mobile)(context);
    }
    return mobile(context);
  }
}

// ============================================================================
// RESPONSIVE VALUE - Provide different values per device type
// ============================================================================

/// A widget that provides different values based on device type.
///
/// ## Basic Example
///
/// ```dart
/// PxResponsiveValue<int>(
///   mobile: 2,
///   tablet: 3,
///   desktop: 4,
///   builder: (context, columnCount) {
///     return GridView.count(
///       crossAxisCount: columnCount,
///       children: items,
///     );
///   },
/// )
/// ```
class PxResponsiveValue<T> extends StatelessWidget {
  /// Value for mobile layout.
  final T mobile;

  /// Value for tablet layout.
  final T? tablet;

  /// Value for desktop layout.
  final T? desktop;

  /// Builder function that receives the appropriate value for current device.
  final Widget Function(BuildContext context, T value) builder;

  const PxResponsiveValue({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    final responsive = PxResponsive();
    T value;
    if (responsive.isDesktop) {
      value = desktop ?? tablet ?? mobile;
    } else if (responsive.isTablet) {
      value = tablet ?? mobile;
    } else {
      value = mobile;
    }

    return builder(context, value);
  }
}

// ============================================================================
// RESPONSIVE VISIBILITY - Show/hide widgets per device type
// ============================================================================

/// A widget that conditionally shows or hides its child based on device type.
///
/// ## Basic Example
///
/// ```dart
/// PxResponsiveVisibility(
///   visibleOnMobile: false,
///   visibleOnTablet: true,
///   visibleOnDesktop: true,
///   child: const Sidebar(),
/// )
/// ```
class PxResponsiveVisibility extends StatelessWidget {
  final Widget child;
  final bool visibleOnMobile;
  final bool visibleOnTablet;
  final bool visibleOnDesktop;
  final Widget? replacement;
  final bool maintainState;

  const PxResponsiveVisibility({
    super.key,
    required this.child,
    this.visibleOnMobile = true,
    this.visibleOnTablet = true,
    this.visibleOnDesktop = true,
    this.replacement,
    this.maintainState = false,
  });

  /// Creates a visibility widget that only shows on mobile.
  const PxResponsiveVisibility.mobile({
    super.key,
    required this.child,
    this.replacement,
    this.maintainState = false,
  })  : visibleOnMobile = true,
        visibleOnTablet = false,
        visibleOnDesktop = false;

  /// Creates a visibility widget that only shows on tablet.
  const PxResponsiveVisibility.tablet({
    super.key,
    required this.child,
    this.replacement,
    this.maintainState = false,
  })  : visibleOnMobile = false,
        visibleOnTablet = true,
        visibleOnDesktop = false;

  /// Creates a visibility widget that only shows on desktop.
  const PxResponsiveVisibility.desktop({
    super.key,
    required this.child,
    this.replacement,
    this.maintainState = false,
  })  : visibleOnMobile = false,
        visibleOnTablet = false,
        visibleOnDesktop = true;

  /// Creates a visibility widget that shows on tablet and desktop (not mobile).
  const PxResponsiveVisibility.tabletUp({
    super.key,
    required this.child,
    this.replacement,
    this.maintainState = false,
  })  : visibleOnMobile = false,
        visibleOnTablet = true,
        visibleOnDesktop = true;

  /// Creates a visibility widget that shows on mobile and tablet (not desktop).
  const PxResponsiveVisibility.tabletDown({
    super.key,
    required this.child,
    this.replacement,
    this.maintainState = false,
  })  : visibleOnMobile = true,
        visibleOnTablet = true,
        visibleOnDesktop = false;

  @override
  Widget build(BuildContext context) {
    final responsive = PxResponsive();
    bool isVisible;
    if (responsive.isDesktop) {
      isVisible = visibleOnDesktop;
    } else if (responsive.isTablet) {
      isVisible = visibleOnTablet;
    } else {
      isVisible = visibleOnMobile;
    }

    if (maintainState) {
      return Offstage(
        offstage: !isVisible,
        child: child,
      );
    }

    return isVisible ? child : (replacement ?? const SizedBox.shrink());
  }
}
