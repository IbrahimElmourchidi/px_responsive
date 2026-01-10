import 'package:flutter/widgets.dart';
import 'package:px_responsive/src/px_responsive_config.dart';
import 'package:px_responsive/src/px_responsive_core.dart';
import 'package:px_responsive/px_responsive.dart';

// ============================================================================
// RESPONSIVE BUILDER - Build different widgets per device type
// ============================================================================

/// A builder widget that builds different layouts based on device type.
///
/// Use this widget when you need completely different widget trees
/// for different device types (mobile, tablet, desktop).
///
/// ## When to Use
///
/// - Different page layouts per device (e.g., single column vs multi-column)
/// - Different navigation patterns (bottom nav vs side nav)
/// - Completely different UI structures that can't be achieved with just scaling
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
/// ## With Fallback
///
/// If [tablet] or [desktop] are not provided, they fall back to smaller sizes:
///
/// ```dart
/// PxResponsiveBuilder(
///   mobile: (context) => const MobileLayout(),
///   desktop: (context) => const DesktopLayout(),
///   // Tablet will use MobileLayout
/// )
///
/// PxResponsiveBuilder(
///   mobile: (context) => const MobileLayout(),
///   // Both tablet and desktop will use MobileLayout
/// )
/// ```
///
/// ## Real-World Example
///
/// ```dart
/// PxResponsiveBuilder(
///   mobile: (context) => Scaffold(
///     appBar: AppBar(title: const Text('My App')),
///     drawer: const NavigationDrawer(),
///     body: const ContentList(),
///     bottomNavigationBar: const BottomNavBar(),
///   ),
///   tablet: (context) => Scaffold(
///     body: Row(
///       children: [
///         const NavigationRail(),
///         const Expanded(child: ContentList()),
///       ],
///     ),
///   ),
///   desktop: (context) => Scaffold(
///     body: Row(
///       children: [
///         const SideNavigation(expanded: true),
///         const Expanded(child: ContentList()),
///         const DetailPanel(),
///       ],
///     ),
///   ),
/// )
/// ```
///
/// ## Comparison with responsiveValue
///
/// Use [PxResponsiveBuilder] when you need different widget trees.
/// Use [responsiveValue] when you need different values for the same widget.
///
/// ```dart
/// // Use PxResponsiveBuilder for different structures
/// PxResponsiveBuilder(
///   mobile: (context) => ListView(...),
///   desktop: (context) => GridView(...),
/// )
///
/// // Use responsiveValue for different values
/// Container(
///   width: responsiveValue(mobile: 100.w, desktop: 200.w),
/// )
/// ```
///
/// See also:
/// - [PxResponsiveValue] for providing different values (not widgets)
/// - [PxResponsiveVisibility] for showing/hiding widgets
/// - [responsiveValue] for inline value selection
class PxResponsiveBuilder extends StatelessWidget {
  /// Builder function for mobile layout.
  ///
  /// Called when screen width < [PxResponsiveConfig.mobileBreakpoint].
  ///
  /// This is required and serves as the fallback for [tablet] and [desktop]
  /// if they are not provided.
  final WidgetBuilder mobile;

  /// Builder function for tablet layout.
  ///
  /// Called when [PxResponsiveConfig.mobileBreakpoint] <= width < [PxResponsiveConfig.tabletBreakpoint].
  ///
  /// If null, falls back to [mobile].
  final WidgetBuilder? tablet;

  /// Builder function for desktop layout.
  ///
  /// Called when screen width >= [PxResponsiveConfig.tabletBreakpoint].
  ///
  /// If null, falls back to [tablet]. If [tablet] is also null, falls back to [mobile].
  final WidgetBuilder? desktop;

  /// Creates a responsive builder widget.
  ///
  /// [mobile] is required and serves as the fallback for other device types.
  ///
  /// ## Parameters
  ///
  /// - [mobile]: Required. Builder for mobile layout.
  /// - [tablet]: Optional. Builder for tablet layout. Falls back to [mobile].
  /// - [desktop]: Optional. Builder for desktop layout. Falls back to [tablet] or [mobile].
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
/// Similar to [PxResponsiveBuilder] but instead of building different widgets,
/// it provides a value to a builder function. This is useful when the widget
/// structure is the same but configuration differs.
///
/// ## When to Use
///
/// - Same widget structure with different configuration per device
/// - Grid column counts
/// - Axis counts for lists
/// - Spacing values
/// - Any typed value that varies by device
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
/// ## With Complex Types
///
/// ```dart
/// PxResponsiveValue<EdgeInsets>(
///   mobile: const EdgeInsets.all(8),
///   tablet: const EdgeInsets.all(16),
///   desktop: const EdgeInsets.all(24),
///   builder: (context, padding) {
///     return Padding(
///       padding: padding,
///       child: const Content(),
///     );
///   },
/// )
/// ```
///
/// ## With Custom Objects
///
/// ```dart
/// class LayoutConfig {
///   final int columns;
///   final double spacing;
///   final bool showSidebar;
///
///   const LayoutConfig({
///     required this.columns,
///     required this.spacing,
///     required this.showSidebar,
///   });
/// }
///
/// PxResponsiveValue<LayoutConfig>(
///   mobile: const LayoutConfig(columns: 1, spacing: 8, showSidebar: false),
///   tablet: const LayoutConfig(columns: 2, spacing: 12, showSidebar: false),
///   desktop: const LayoutConfig(columns: 3, spacing: 16, showSidebar: true),
///   builder: (context, config) {
///     return Row(
///       children: [
///         if (config.showSidebar) const Sidebar(),
///         Expanded(
///           child: GridView.count(
///             crossAxisCount: config.columns,
///             mainAxisSpacing: config.spacing,
///             crossAxisSpacing: config.spacing,
///             children: items,
///           ),
///         ),
///       ],
///     );
///   },
/// )
/// ```
///
/// ## Fallback Behavior
///
/// Like [PxResponsiveBuilder], values fall back to smaller sizes:
/// - Desktop uses [desktop] ?? [tablet] ?? [mobile]
/// - Tablet uses [tablet] ?? [mobile]
/// - Mobile always uses [mobile]
///
/// ## Comparison with responsiveValue Function
///
/// [PxResponsiveValue] is a widget, [responsiveValue] is a function.
/// Use the function for inline values, use the widget when you need
/// the value in a builder context.
///
/// ```dart
/// // Function (inline)
/// Container(width: responsiveValue(mobile: 100, desktop: 200))
///
/// // Widget (builder context)
/// PxResponsiveValue<int>(
///   mobile: 2,
///   desktop: 4,
///   builder: (context, count) => GridView.count(crossAxisCount: count),
/// )
/// ```
class PxResponsiveValue<T> extends StatelessWidget {
  /// Value for mobile layout.
  ///
  /// This is required and serves as the fallback for [tablet] and [desktop].
  final T mobile;

  /// Value for tablet layout.
  ///
  /// If null, falls back to [mobile].
  final T? tablet;

  /// Value for desktop layout.
  ///
  /// If null, falls back to [tablet]. If [tablet] is also null, falls back to [mobile].
  final T? desktop;

  /// Builder function that receives the appropriate value for current device.
  ///
  /// This is called with the selected value based on device type.
  final Widget Function(BuildContext context, T value) builder;

  /// Creates a responsive value widget.
  ///
  /// ## Parameters
  ///
  /// - [mobile]: Required. Value for mobile devices.
  /// - [tablet]: Optional. Value for tablets. Falls back to [mobile].
  /// - [desktop]: Optional. Value for desktop. Falls back to [tablet] or [mobile].
  /// - [builder]: Required. Builder that receives the selected value.
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
/// Use this for showing different UI elements on different devices,
/// such as navigation patterns, optional panels, or device-specific features.
///
/// ## Basic Example
///
/// ```dart
/// // Only show sidebar on tablet and desktop
/// PxResponsiveVisibility(
///   visibleOnMobile: false,
///   visibleOnTablet: true,
///   visibleOnDesktop: true,
///   child: const Sidebar(),
/// )
/// ```
///
/// ## Named Constructors
///
/// For common patterns, use the named constructors:
///
/// ```dart
/// // Only on mobile
/// PxResponsiveVisibility.mobile(child: const BottomNavBar())
///
/// // Only on tablet
/// PxResponsiveVisibility.tablet(child: const TabletMenu())
///
/// // Only on desktop
/// PxResponsiveVisibility.desktop(child: const DesktopToolbar())
///
/// // Tablet and desktop (not mobile)
/// PxResponsiveVisibility.tabletUp(child: const SideNavigation())
///
/// // Mobile and tablet (not desktop)
/// PxResponsiveVisibility.tabletDown(child: const CompactHeader())
/// ```
///
/// ## With Replacement Widget
///
/// Show an alternative widget when hidden:
///
/// ```dart
/// PxResponsiveVisibility(
///   visibleOnMobile: false,
///   visibleOnTablet: true,
///   visibleOnDesktop: true,
///   replacement: const MobileDrawerButton(),
///   child: const SideNavigation(),
/// )
/// ```
///
/// ## Maintaining State
///
/// Use [maintainState] to keep the widget in the tree but hidden:
///
/// ```dart
/// PxResponsiveVisibility.desktop(
///   maintainState: true, // Widget stays in tree, just hidden
///   child: const ExpensiveWidget(),
/// )
/// ```
///
/// This is useful when:
/// - The child has state you want to preserve across device changes
/// - The child is expensive to rebuild
/// - You're animating visibility changes
///
/// ## Real-World Example
///
/// ```dart
/// Scaffold(
///   body: Row(
///     children: [
///       // Side navigation only on tablet and desktop
///       PxResponsiveVisibility.tabletUp(
///         child: const SideNavigation(),
///       ),
///       // Main content
///       const Expanded(child: MainContent()),
///       // Detail panel only on desktop
///       PxResponsiveVisibility.desktop(
///         child: const DetailPanel(),
///       ),
///     ],
///   ),
///   // Bottom navigation only on mobile
///   bottomNavigationBar: PxResponsiveVisibility.mobile(
///     child: const BottomNavBar(),
///   ),
/// )
/// ```
///
/// ## Visibility Summary
///
/// | Constructor | Mobile | Tablet | Desktop |
/// |-------------|--------|--------|---------|
/// | `.mobile()` | ✅ | ❌ | ❌ |
/// | `.tablet()` | ❌ | ✅ | ❌ |
/// | `.desktop()` | ❌ | ❌ | ✅ |
/// | `.tabletUp()` | ❌ | ✅ | ✅ |
/// | `.tabletDown()` | ✅ | ✅ | ❌ |
///
/// See also:
/// - [PxResponsiveBuilder] for completely different layouts
/// - [PxResponsiveValue] for different values with same structure
class PxResponsiveVisibility extends StatelessWidget {
  /// The child widget to conditionally show.
  final Widget child;

  /// Whether to show the child on mobile devices.
  ///
  /// Default: `true`
  final bool visibleOnMobile;

  /// Whether to show the child on tablet devices.
  ///
  /// Default: `true`
  final bool visibleOnTablet;

  /// Whether to show the child on desktop devices.
  ///
  /// Default: `true`
  final bool visibleOnDesktop;

  /// Optional replacement widget when child is hidden.
  ///
  /// If null, uses `SizedBox.shrink()` (takes no space).
  ///
  /// ## Example
  ///
  /// ```dart
  /// PxResponsiveVisibility.tabletUp(
  ///   replacement: const IconButton(
  ///     icon: Icon(Icons.menu),
  ///     onPressed: openDrawer,
  ///   ),
  ///   child: const SideNavigation(),
  /// )
  /// ```
  final Widget? replacement;

  /// Whether to maintain the child's state when hidden.
  ///
  /// If `true`, wraps child in [Offstage] instead of replacing it.
  /// The child remains in the widget tree but is not painted or
  /// interactive.
  ///
  /// Default: `false`
  ///
  /// ## When to Use
  ///
  /// - Child has state you want to preserve
  /// - Child is expensive to rebuild
  /// - You need to animate visibility transitions
  ///
  /// ## Example
  ///
  /// ```dart
  /// PxResponsiveVisibility.desktop(
  ///   maintainState: true,
  ///   child: const VideoPlayer(), // Keeps playing when hidden
  /// )
  /// ```
  final bool maintainState;

  /// Creates a responsive visibility widget.
  ///
  /// By default, the child is visible on all device types.
  /// Set [visibleOnMobile], [visibleOnTablet], or [visibleOnDesktop]
  /// to `false` to hide on specific devices.
  ///
  /// ## Parameters
  ///
  /// - [child]: Required. The widget to conditionally show.
  /// - [visibleOnMobile]: Show on mobile. Default: `true`
  /// - [visibleOnTablet]: Show on tablet. Default: `true`
  /// - [visibleOnDesktop]: Show on desktop. Default: `true`
  /// - [replacement]: Widget to show when hidden. Default: `SizedBox.shrink()`
  /// - [maintainState]: Keep child in tree when hidden. Default: `false`
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
  /// Visible: Mobile ✅ | Tablet ❌ | Desktop ❌
  ///
  /// ## Example
  ///
  /// ```dart
  /// PxResponsiveVisibility.mobile(
  ///   child: const BottomNavigationBar(),
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
  /// Visible: Mobile ❌ | Tablet ✅ | Desktop ❌
  ///
  /// ## Example
  ///
  /// ```dart
  /// PxResponsiveVisibility.tablet(
  ///   child: const TabletSpecificWidget(),
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
  /// Visible: Mobile ❌ | Tablet ❌ | Desktop ✅
  ///
  /// ## Example
  ///
  /// ```dart
  /// PxResponsiveVisibility.desktop(
  ///   child: const DesktopToolbar(),
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
  /// Visible: Mobile ❌ | Tablet ✅ | Desktop ✅
  ///
  /// Use for elements that need more screen space, like side navigation.
  ///
  /// ## Example
  ///
  /// ```dart
  /// PxResponsiveVisibility.tabletUp(
  ///   child: const SideNavigation(),
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
  /// Visible: Mobile ✅ | Tablet ✅ | Desktop ❌
  ///
  /// Use for mobile-oriented elements that aren't needed on desktop.
  ///
  /// ## Example
  ///
  /// ```dart
  /// PxResponsiveVisibility.tabletDown(
  ///   child: const TouchOptimizedControls(),
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

    // If maintainState is true, use Offstage to keep widget in tree
    if (maintainState) {
      return Offstage(
        offstage: !isVisible,
        child: child,
      );
    }

    // Otherwise, swap between child and replacement
    return isVisible ? child : (replacement ?? const SizedBox.shrink());
  }
}
