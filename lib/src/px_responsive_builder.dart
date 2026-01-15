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
///
/// ## With maxWidth Example
///
/// ```dart
/// // Even on ultra-wide screens, the desktop layout will use
/// // the maxWidth for scaling calculations
/// PxResponsiveBuilder(
///   mobile: (context) => ListView(children: mobileItems),
///   tablet: (context) => GridView.count(crossAxisCount: 2, children: items),
///   desktop: (context) => GridView.count(crossAxisCount: 4, children: items),
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

  /// Creates a responsive builder widget.
  ///
  /// The [mobile] builder is required and serves as the fallback.
  /// If [tablet] is null, [mobile] will be used for tablet screens.
  /// If [desktop] is null, [tablet] or [mobile] will be used for desktop screens.
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
///
/// ## With Styling Example
///
/// ```dart
/// PxResponsiveValue<double>(
///   mobile: 16,
///   tablet: 20,
///   desktop: 24,
///   builder: (context, fontSize) {
///     return Text(
///       'Responsive Text',
///       style: TextStyle(fontSize: fontSize.sp),
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

  /// Creates a responsive value widget.
  ///
  /// The [mobile] value is required and serves as the fallback.
  /// If [tablet] is null, [mobile] will be used for tablet screens.
  /// If [desktop] is null, [tablet] or [mobile] will be used for desktop screens.
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
///
/// ## Named Constructor Examples
///
/// ```dart
/// // Show only on mobile
/// PxResponsiveVisibility.mobile(
///   child: const MobileMenu(),
/// )
///
/// // Show on tablet and above
/// PxResponsiveVisibility.tabletUp(
///   child: const DesktopMenu(),
/// )
///
/// // Show with replacement when hidden
/// PxResponsiveVisibility.desktop(
///   child: const FullSidebar(),
///   replacement: const CollapsedSidebar(),
/// )
/// ```
class PxResponsiveVisibility extends StatelessWidget {
  /// The widget to show when visibility conditions are met.
  final Widget child;

  /// Whether to show the child on mobile devices.
  final bool visibleOnMobile;

  /// Whether to show the child on tablet devices.
  final bool visibleOnTablet;

  /// Whether to show the child on desktop devices.
  final bool visibleOnDesktop;

  /// Widget to show when child is hidden. Defaults to [SizedBox.shrink()].
  final Widget? replacement;

  /// If true, the child's state is maintained even when hidden using [Offstage].
  /// If false (default), the child is completely removed from the tree.
  final bool maintainState;

  /// Creates a visibility widget with custom visibility rules.
  ///
  /// By default, the child is visible on all device types.
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
  ///
  /// Example:
  /// ```dart
  /// PxResponsiveVisibility.mobile(
  ///   child: const MobileOnlyWidget(),
  /// )
  /// ```
  const PxResponsiveVisibility.mobile({
    super.key,
    required this.child,
    this.replacement,
    this.maintainState = false,
  })  : visibleOnMobile = true,
        visibleOnTablet = false,
        visibleOnDesktop = false;

  /// Creates a visibility widget that only shows on tablet.
  ///
  /// Example:
  /// ```dart
  /// PxResponsiveVisibility.tablet(
  ///   child: const TabletOnlyWidget(),
  /// )
  /// ```
  const PxResponsiveVisibility.tablet({
    super.key,
    required this.child,
    this.replacement,
    this.maintainState = false,
  })  : visibleOnMobile = false,
        visibleOnTablet = true,
        visibleOnDesktop = false;

  /// Creates a visibility widget that only shows on desktop.
  ///
  /// Example:
  /// ```dart
  /// PxResponsiveVisibility.desktop(
  ///   child: const DesktopOnlyWidget(),
  /// )
  /// ```
  const PxResponsiveVisibility.desktop({
    super.key,
    required this.child,
    this.replacement,
    this.maintainState = false,
  })  : visibleOnMobile = false,
        visibleOnTablet = false,
        visibleOnDesktop = true;

  /// Creates a visibility widget that shows on tablet and desktop (not mobile).
  ///
  /// Example:
  /// ```dart
  /// PxResponsiveVisibility.tabletUp(
  ///   child: const LargeScreenWidget(),
  /// )
  /// ```
  const PxResponsiveVisibility.tabletUp({
    super.key,
    required this.child,
    this.replacement,
    this.maintainState = false,
  })  : visibleOnMobile = false,
        visibleOnTablet = true,
        visibleOnDesktop = true;

  /// Creates a visibility widget that shows on mobile and tablet (not desktop).
  ///
  /// Example:
  /// ```dart
  /// PxResponsiveVisibility.tabletDown(
  ///   child: const SmallScreenWidget(),
  /// )
  /// ```
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
