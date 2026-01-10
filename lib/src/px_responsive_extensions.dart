import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'px_responsive_config.dart';
import 'px_responsive_core.dart';

// ============================================================================
// GLOBAL GETTERS - Simple access to device type without PxResponsive()
// ============================================================================

/// Returns `true` if the current screen width is in the mobile range.
bool get isMobile => PxResponsive().isMobile;

/// Returns `true` if the current screen width is in the tablet range.
bool get isTablet => PxResponsive().isTablet;

/// Returns `true` if the current screen width is in the desktop range.
bool get isDesktop => PxResponsive().isDesktop;

/// Returns the current device type as [PxDeviceType] enum.
PxDeviceType get deviceType => PxResponsive().deviceType;

/// Returns the current screen width in logical pixels.
double get screenWidth => PxResponsive().screenWidth;

/// Returns the current screen height in logical pixels.
double get screenHeight => PxResponsive().screenHeight;

// ============================================================================
// GLOBAL FUNCTIONS
// ============================================================================

/// Returns the appropriate value based on current device type.
T responsiveValue<T>({
  required T mobile,
  T? tablet,
  T? desktop,
}) {
  return PxResponsive().value(
    mobile: mobile,
    tablet: tablet,
    desktop: desktop,
  );
}

// ============================================================================
// NUM EXTENSIONS - Core responsive scaling
// ============================================================================

/// Extensions on [num] for responsive scaling.
extension PxResponsiveNumExtension on num {
  // ==================== Core Scaling ====================

  /// Scales this value based on width ratio.
  double get w => this * PxResponsive().scaleW;

  /// Scales this value based on height ratio.
  double get h => this * PxResponsive().scaleH;

  /// Scales this value for fonts (Scalable Pixels).
  double get sp => this * PxResponsive().scaleSp;

  /// Scales this value for radius/diagonal elements.
  double get r => this * PxResponsive().scaleR;

  // ==================== Percentage of Screen ====================

  /// Returns this value as a percentage of the full window width.
  double get wf => (this / 100) * PxResponsive().screenWidth;

  /// Returns this value as a percentage of the full window height.
  double get hf => (this / 100) * PxResponsive().screenHeight;

  // ==================== Clamping Methods ====================

  /// Returns this value scaled by width with a custom minimum.
  double wMin(double minimum) => math.max(w, minimum);

  /// Returns this value scaled by width with a custom maximum.
  double wMax(double maximum) => math.min(w, maximum);

  /// Returns this value scaled by width, clamped between min and max.
  double wClamp(double minimum, double maximum) => w.clamp(minimum, maximum);

  /// Returns this value scaled by height with a custom minimum.
  double hMin(double minimum) => math.max(h, minimum);

  /// Returns this value scaled by height with a custom maximum.
  double hMax(double maximum) => math.min(h, maximum);

  /// Returns this value scaled by height, clamped between min and max.
  double hClamp(double minimum, double maximum) => h.clamp(minimum, maximum);

  /// Returns this value scaled for fonts with a custom minimum.
  double spMin(double minimum) => math.max(sp, minimum);

  /// Returns this value scaled for fonts with a custom maximum.
  double spMax(double maximum) => math.min(sp, maximum);

  /// Returns this value scaled for fonts, clamped between min and max.
  double spClamp(double minimum, double maximum) => sp.clamp(minimum, maximum);
}

// ============================================================================
// PARENT-RELATIVE SIZING
// ============================================================================

/// A widget that provides parent-relative sizing for its child.
///
/// Wrap a parent widget with [PxRelativeSizeProvider] to enable the
/// `.wr()` and `.hr()` extensions.
class PxRelativeSizeProvider extends StatelessWidget {
  /// The child widget that will have access to relative sizing.
  final Widget child;

  /// Creates a relative size provider.
  const PxRelativeSizeProvider({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return _PxRelativeSizeInherited(
          parentSize: Size(constraints.maxWidth, constraints.maxHeight),
          child: child,
        );
      },
    );
  }
}

/// Internal inherited widget to pass parent size down the tree.
class _PxRelativeSizeInherited extends InheritedWidget {
  final Size parentSize;

  const _PxRelativeSizeInherited({
    required this.parentSize,
    required super.child,
  });

  static Size? of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<_PxRelativeSizeInherited>();
    return inherited?.parentSize;
  }

  @override
  bool updateShouldNotify(_PxRelativeSizeInherited oldWidget) {
    return parentSize != oldWidget.parentSize;
  }
}

/// Extensions on [num] for parent-relative sizing.
extension PxResponsiveRelativeExtension on num {
  /// Returns this value as a percentage of the parent's width.
  /// Requires the parent to be wrapped with [PxRelativeSizeProvider].
  double wr(BuildContext context) {
    final parentSize = _PxRelativeSizeInherited.of(context);
    if (parentSize != null) {
      return (this / 100) * parentSize.width;
    }
    // Fallback: use screen width
    return (this / 100) * PxResponsive().screenWidth;
  }

  /// Returns this value as a percentage of the parent's height.
  /// Requires the parent to be wrapped with [PxRelativeSizeProvider].
  double hr(BuildContext context) {
    final parentSize = _PxRelativeSizeInherited.of(context);
    if (parentSize != null) {
      return (this / 100) * parentSize.height;
    }
    // Fallback: use screen height
    return (this / 100) * PxResponsive().screenHeight;
  }
}

// ============================================================================
// EDGEINSETS EXTENSIONS
// ============================================================================

/// Extensions on [EdgeInsets] for responsive scaling.
extension PxResponsiveEdgeInsetsExtension on EdgeInsets {
  /// Returns a new [EdgeInsets] with all values scaled by width factor.
  EdgeInsets get w => copyWith(
        left: left * PxResponsive().scaleW,
        top: top * PxResponsive().scaleW,
        right: right * PxResponsive().scaleW,
        bottom: bottom * PxResponsive().scaleW,
      );

  /// Returns a new [EdgeInsets] with horizontal scaled by width, vertical by height.
  EdgeInsets get scaled => copyWith(
        left: left * PxResponsive().scaleW,
        top: top * PxResponsive().scaleH,
        right: right * PxResponsive().scaleW,
        bottom: bottom * PxResponsive().scaleH,
      );

  /// Returns a new [EdgeInsets] with all values scaled by radius factor.
  EdgeInsets get r => copyWith(
        left: left * PxResponsive().scaleR,
        top: top * PxResponsive().scaleR,
        right: right * PxResponsive().scaleR,
        bottom: bottom * PxResponsive().scaleR,
      );
}

// ============================================================================
// SIZE EXTENSIONS
// ============================================================================

/// Extensions on [Size] for responsive scaling.
extension PxResponsiveSizeExtension on Size {
  /// Returns a new [Size] with width scaled by scaleW and height by scaleH.
  Size get scaled => Size(
        width * PxResponsive().scaleW,
        height * PxResponsive().scaleH,
      );

  /// Returns a new [Size] with both dimensions scaled by scaleW.
  Size get w => Size(
        width * PxResponsive().scaleW,
        height * PxResponsive().scaleW,
      );

  /// Returns a new [Size] with both dimensions scaled by scaleR.
  Size get r => Size(
        width * PxResponsive().scaleR,
        height * PxResponsive().scaleR,
      );
}

// ============================================================================
// BORDERRADIUS EXTENSIONS
// ============================================================================

/// Extensions on [BorderRadius] for responsive scaling.
extension PxResponsiveBorderRadiusExtension on BorderRadius {
  /// Returns a new [BorderRadius] with all radii scaled by scaleR.
  BorderRadius get r {
    final scale = PxResponsive().scaleR;
    return copyWith(
      topLeft: Radius.elliptical(
        topLeft.x * scale,
        topLeft.y * scale,
      ),
      topRight: Radius.elliptical(
        topRight.x * scale,
        topRight.y * scale,
      ),
      bottomLeft: Radius.elliptical(
        bottomLeft.x * scale,
        bottomLeft.y * scale,
      ),
      bottomRight: Radius.elliptical(
        bottomRight.x * scale,
        bottomRight.y * scale,
      ),
    );
  }
}
