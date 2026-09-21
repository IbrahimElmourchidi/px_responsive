import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'px_responsive_config.dart';
import 'px_responsive_core.dart';
import 'px_responsive_data.dart';

// ============================================================================
// PxResponsiveScope - the InheritedWidget carrying PxResponsiveData
// ============================================================================

/// An [InheritedWidget] that makes the current [PxResponsiveData] snapshot
/// available to descendants via [BuildContext], so genuine
/// `dependOnInheritedWidgetOfExactType` reads (all of this package's own
/// widgets, plus `context.responsive`) rebuild correctly and efficiently
/// when the screen size changes — no subtree walk required for them.
///
/// Published automatically by [PxResponsiveWrapper] and
/// [PxResponsiveMediaQueryWrapper]; you don't create this directly.
///
/// Note: this alone does **not** make a bare `200.w` reactive, because this
/// widget's own `build()` still returns the same `child` instance passed to
/// the wrapper, which re-triggers Flutter's identical-widget short-circuit
/// one level down. That's what the wrapper's force-rebuild walk is for —
/// see `PxResponsiveWrapper.forceRebuildOnChange`.
class PxResponsiveScope extends InheritedWidget {
  /// Creates a scope carrying [data].
  const PxResponsiveScope({
    super.key,
    required this.data,
    required super.child,
  });

  /// The current responsive snapshot.
  final PxResponsiveData data;

  /// Reads the nearest [PxResponsiveScope]'s data, creating a build
  /// dependency: the calling widget rebuilds whenever that data changes.
  ///
  /// Throws in debug mode if no scope is found. Use [maybeOf] if the
  /// context might be outside any [PxResponsiveWrapper].
  static PxResponsiveData of(BuildContext context) {
    final data = maybeOf(context);
    assert(
      data != null,
      'PxResponsiveScope.of() was called with a context that does not have '
      'a PxResponsiveWrapper (or PxResponsiveMediaQueryWrapper) ancestor.\n'
      'Wrap your app in PxResponsiveWrapper, or use maybeOf() if this '
      'widget may legitimately be built outside one.',
    );
    return data!;
  }

  /// Like [of], but returns `null` instead of throwing when no scope is
  /// found above [context].
  static PxResponsiveData? maybeOf(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<PxResponsiveScope>()
        ?.data;
  }

  /// Reads the nearest [PxResponsiveScope]'s data without creating a build
  /// dependency (the calling widget will *not* rebuild when it changes).
  static PxResponsiveData? readOf(BuildContext context) {
    return context.getInheritedWidgetOfExactType<PxResponsiveScope>()?.data;
  }

  @override
  bool updateShouldNotify(PxResponsiveScope oldWidget) => data != oldWidget.data;
}

/// Reads the responsive data available to [context]: the nearest
/// [PxResponsiveScope] if there is one (creating a rebuild dependency on
/// it), otherwise the [PxResponsive] singleton's current snapshot.
///
/// This is the one helper every widget in this package uses to read
/// responsive data, so they all agree on which snapshot is "current" and
/// stay reactive to [PxResponsiveScope] when nested inside one.
PxResponsiveData pxDataOf(BuildContext context) =>
    PxResponsiveScope.maybeOf(context) ?? PxResponsive().data;

// ============================================================================
// PxResponsiveRebuildBoundary - opt a subtree out of the force-rebuild walk
// ============================================================================

/// Marks a subtree as exempt from [PxResponsiveWrapper]'s force-rebuild
/// walk.
///
/// Wrap an expensive, visually-static subtree (a map, a video player, a
/// long `const` list) in this widget when you've profiled a resize-heavy
/// desktop app and found the walk costly. It does not affect
/// [PxResponsiveScope] dependents inside it (a package widget or
/// `context.responsive` read below this boundary still rebuilds normally)
/// — it only stops the *walk* from force-marking non-dependent widgets
/// (e.g. a bare `200.w`) inside it as needing a rebuild.
class PxResponsiveRebuildBoundary extends StatelessWidget {
  /// Creates a rebuild boundary around [child].
  const PxResponsiveRebuildBoundary({super.key, required this.child});

  /// The subtree to exempt from the force-rebuild walk.
  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}

// ============================================================================
// Shared build helper used by both PxResponsiveWrapper implementations
// ============================================================================

/// Builds the scope + (optional) maxWidth-centering + force-rebuild-walk
/// subtree shared by [PxResponsiveWrapper] and [PxResponsiveMediaQueryWrapper].
///
/// This is the single place that:
/// - decides whether to reuse the previous [PxResponsiveData] snapshot
///   (below [PxResponsiveConfig.rebuildEpsilon]) or publish [candidate],
/// - writes the [PxResponsive] singleton, but only when this is the
///   root-most scope (no [PxResponsiveScope] already above [context]),
/// - performs the force-rebuild walk when the published data changed and
///   [forceRebuildOnChange] is true,
/// - applies [PxResponsiveConfig.maxWidth] centering.
Widget pxBuildResponsiveSubtree({
  required BuildContext context,
  required BoxConstraints incomingConstraints,
  required PxResponsiveData candidate,
  required bool forceRebuildOnChange,
  required Widget Function(PxResponsiveData data) buildChild,
}) {
  final element = context as Element;
  final epsilon = candidate.config.rebuildEpsilon;

  final previous = _findPreviousScopeData(element);
  final bool changed;
  final PxResponsiveData data;
  if (previous == null) {
    data = candidate;
    changed = false;
  } else if (previous.requiresRebuild(candidate, epsilon: epsilon)) {
    data = candidate;
    changed = true;
  } else {
    data = previous;
    changed = false;
  }

  final isRootScope = PxResponsiveScope.maybeOf(context) == null;
  if (isRootScope) {
    PxResponsive().attach(data);
  }

  if (changed && forceRebuildOnChange) {
    final rootOwner = element.owner;
    element.visitChildren((child) => _markSubtree(child, rootOwner));
  }

  Widget result = PxResponsiveScope(data: data, child: buildChild(data));

  final maxWidth = data.config.maxWidth;
  if (maxWidth != null &&
      data.config.maxWidthBehavior == PxMaxWidthBehavior.constrain &&
      incomingConstraints.maxWidth.isFinite &&
      incomingConstraints.maxWidth > maxWidth) {
    final capped = incomingConstraints.copyWith(
      maxWidth: maxWidth,
      minWidth: math.min(incomingConstraints.minWidth, maxWidth),
    );
    result = Center(child: ConstrainedBox(constraints: capped, child: result));
    final background = data.config.maxWidthBackground;
    if (background != null) {
      result = ColoredBox(color: background, child: result);
    }
  }

  return result;
}

/// Looks for the previously-emitted [PxResponsiveScope] among [root]'s
/// current children, descending through the small set of widget types this
/// helper itself may have inserted above it (the maxWidth-centering
/// wrappers). Any other widget type means we've reached the boundary of
/// what this helper controls, so the search stops there.
PxResponsiveData? _findPreviousScopeData(Element root) {
  PxResponsiveData? found;
  void visit(Element element) {
    if (found != null) return;
    final widget = element.widget;
    if (widget is PxResponsiveScope) {
      found = widget.data;
      return;
    }
    if (widget is ColoredBox || widget is Center || widget is ConstrainedBox) {
      element.visitChildren(visit);
    }
  }

  root.visitChildren(visit);
  return found;
}

/// Recursively marks [element] and its descendants as needing to rebuild,
/// so that widgets which read responsive data without depending on
/// [PxResponsiveScope] (chiefly the `num` extensions like `.w`/`.h`/`.sp`)
/// pick up the new values even though their widget instance is unchanged.
///
/// This is legal to call here: it runs from inside the enclosing
/// `LayoutBuilder`'s builder callback, which executes within a real
/// `BuildOwner.buildScope`, so every element visited is a descendant of the
/// current build target and the marks flush in this same layout pass (no
/// stale frame).
void _markSubtree(Element element, Object? rootOwner) {
  final widget = element.widget;

  // Opt-out: don't force-rebuild this subtree at all.
  if (widget is PxResponsiveRebuildBoundary) return;

  // A nested PxResponsiveWrapper/MediaQueryWrapper owns its own scope and
  // will refresh it independently; don't force *it* to rebuild, but still
  // walk into its children in case something inside reads the outer
  // (root) singleton via a bare `.w` rather than this inner scope.
  if (widget is PxResponsiveScope) {
    element.visitChildren((child) => _markSubtree(child, rootOwner));
    return;
  }

  // Skip elements belonging to a different BuildOwner (e.g. a second View
  // in a multi-window app) — marking across owners is not meaningful here.
  if (rootOwner != null && !identical(element.owner, rootOwner)) return;

  final isRebuildableComponent = element is ComponentElement && element is! ProxyElement;
  final isNestedLayoutBuilder = widget is AbstractLayoutBuilder;
  if (isRebuildableComponent || isNestedLayoutBuilder) {
    element.markNeedsBuild();
  }

  element.visitChildren((child) => _markSubtree(child, rootOwner));
}
