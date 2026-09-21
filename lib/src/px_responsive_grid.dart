import 'package:flutter/widgets.dart';
import 'px_responsive_scope.dart';

// ============================================================================
// RESPONSIVE GRID WIDGET
// ============================================================================

/// A grid widget that automatically selects the number of columns based on
/// the current device type.
///
/// [PxResponsiveGrid] removes the boilerplate of computing column counts and
/// wiring them into a [GridView] every time you build a responsive grid.
///
/// ## Basic Usage
///
/// ```dart
/// PxResponsiveGrid(
///   mobileColumns: 1,
///   tabletColumns: 2,
///   desktopColumns: 4,
///   spacing: 16.r,
///   children: productCards,
/// )
/// ```
///
/// ## With Aspect Ratio
///
/// ```dart
/// PxResponsiveGrid(
///   mobileColumns: 2,
///   desktopColumns: 4,
///   spacing: 12.r,
///   childAspectRatio: 3 / 4,
///   children: items,
/// )
/// ```
///
/// ## Lazy Building
///
/// The default constructor takes an eagerly-built `children` list, which
/// defeats [GridView.builder]'s laziness for very long lists. Use
/// [PxResponsiveGrid.builder] to build items on demand instead:
///
/// ```dart
/// PxResponsiveGrid.builder(
///   mobileColumns: 2,
///   desktopColumns: 4,
///   spacing: 12.r,
///   itemCount: products.length,
///   itemBuilder: (context, index) => ProductCard(products[index]),
/// )
/// ```
class PxResponsiveGrid extends StatelessWidget {
  /// Number of columns on mobile devices.
  ///
  /// Required. Also used as the fallback when [tabletColumns] or
  /// [desktopColumns] are null.
  final int mobileColumns;

  /// Number of columns on tablet devices.
  ///
  /// Falls back to [mobileColumns] when null.
  final int? tabletColumns;

  /// Number of columns on desktop devices.
  ///
  /// Falls back to [tabletColumns], then [mobileColumns], when null.
  final int? desktopColumns;

  /// Cross-axis (column) spacing between grid items.
  final double spacing;

  /// Main-axis (row) spacing between grid items.
  ///
  /// Defaults to [spacing] when null.
  final double? runSpacing;

  /// The ratio of the cross-axis extent to the main-axis extent of each item.
  ///
  /// Default: `1.0` (square items)
  final double childAspectRatio;

  /// Whether the grid should shrink-wrap its content.
  ///
  /// Set to `true` when the grid is inside a [Column] or other
  /// non-scrollable parent. Default: `false`.
  final bool shrinkWrap;

  /// How the scroll view should respond to user input.
  final ScrollPhysics? physics;

  /// An optional scroll controller.
  final ScrollController? controller;

  /// The widgets to lay out in the grid. Non-null only when constructed via
  /// the default (eager) constructor.
  final List<Widget>? children;

  /// The number of items to build. Non-null only when constructed via
  /// [PxResponsiveGrid.builder].
  final int? itemCount;

  /// Builds the item at the given index. Non-null only when constructed via
  /// [PxResponsiveGrid.builder].
  final IndexedWidgetBuilder? itemBuilder;

  /// Creates a responsive grid widget from an eagerly-built [children] list.
  const PxResponsiveGrid({
    super.key,
    required this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    required this.spacing,
    this.runSpacing,
    this.childAspectRatio = 1.0,
    this.shrinkWrap = false,
    this.physics,
    this.controller,
    required this.children,
  })  : itemCount = null,
        itemBuilder = null;

  /// Creates a responsive grid widget that builds its [itemCount] items
  /// lazily via [itemBuilder], preserving [GridView.builder]'s laziness for
  /// long lists.
  const PxResponsiveGrid.builder({
    super.key,
    required this.mobileColumns,
    this.tabletColumns,
    this.desktopColumns,
    required this.spacing,
    this.runSpacing,
    this.childAspectRatio = 1.0,
    this.shrinkWrap = false,
    this.physics,
    this.controller,
    required this.itemCount,
    required this.itemBuilder,
  }) : children = null;

  @override
  Widget build(BuildContext context) {
    final data = pxDataOf(context);
    final int columns;

    if (data.isDesktop) {
      columns = desktopColumns ?? tabletColumns ?? mobileColumns;
    } else if (data.isTablet) {
      columns = tabletColumns ?? mobileColumns;
    } else {
      columns = mobileColumns;
    }

    final resolvedChildren = children;

    return GridView.builder(
      shrinkWrap: shrinkWrap,
      physics: physics,
      controller: controller,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: spacing,
        mainAxisSpacing: runSpacing ?? spacing,
        childAspectRatio: childAspectRatio,
      ),
      itemCount: resolvedChildren?.length ?? itemCount!,
      itemBuilder: resolvedChildren != null
          ? (context, index) => resolvedChildren[index]
          : itemBuilder!,
    );
  }
}
