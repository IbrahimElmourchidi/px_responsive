import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'px_responsive_config.dart';
import 'px_responsive_core.dart';

// ============================================================================
// GLOBAL GETTERS - Simple access to device type without PxResponsive()
// ============================================================================

/// Returns `true` if the current screen width is in the mobile range.
///
/// Equivalent to: `PxResponsive().isMobile`
///
/// Example:
/// ```dart
/// if (isMobile) {
///   return MobileLayout();
/// }
/// ```
bool get isMobile => PxResponsive().isMobile;

/// Returns `true` if the current screen width is in the tablet range.
///
/// Equivalent to: `PxResponsive().isTablet`
///
/// Example:
/// ```dart
/// if (isTablet) {
///   return TabletLayout();
/// }
/// ```
bool get isTablet => PxResponsive().isTablet;

/// Returns `true` if the current screen width is in the desktop range.
///
/// Equivalent to: `PxResponsive().isDesktop`
///
/// Example:
/// ```dart
/// if (isDesktop) {
///   return DesktopLayout();
/// }
/// ```
bool get isDesktop => PxResponsive().isDesktop;

/// Returns the current device type as [PxDeviceType] enum.
///
/// Equivalent to: `PxResponsive().deviceType`
///
/// Example:
/// ```dart
/// switch (deviceType) {
///   case PxDeviceType.mobile:
///     // Mobile code
///   case PxDeviceType.tablet:
///     // Tablet code
///   case PxDeviceType.desktop:
///     // Desktop code
/// }
/// ```
PxDeviceType get deviceType => PxResponsive().deviceType;

/// Returns the current screen width in logical pixels.
///
/// This is the actual screen width, not affected by [PxResponsiveConfig.maxWidth].
///
/// Equivalent to: `PxResponsive().screenWidth`
double get screenWidth => PxResponsive().screenWidth;

/// Returns the current screen height in logical pixels.
///
/// Equivalent to: `PxResponsive().screenHeight`
double get screenHeight => PxResponsive().screenHeight;

/// Returns the effective width used for scaling calculations.
///
/// When [PxResponsiveConfig.maxWidth] is set, this returns min(screenWidth, maxWidth).
/// Otherwise, it returns the actual screen width.
///
/// Equivalent to: `PxResponsive().effectiveWidth`
///
/// Example:
/// ```dart
/// // With maxWidth: 1920
/// print('Actual: $screenWidth'); // 2560
/// print('Effective: $effectiveWidth'); // 1920
/// ```
double get effectiveWidth => PxResponsive().effectiveWidth;

// ============================================================================
// GLOBAL FUNCTIONS
// ============================================================================

/// Returns the appropriate value based on current device type.
///
/// The [mobile] value is required and serves as the fallback.
/// If [tablet] is null, [mobile] will be used for tablet screens.
/// If [desktop] is null, [tablet] or [mobile] will be used for desktop screens.
///
/// Example:
/// ```dart
/// int columns = responsiveValue(
///   mobile: 1,
///   tablet: 2,
///   desktop: 4,
/// );
/// ```
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
///
/// These extensions provide a simple and intuitive API for scaling
/// numeric values based on the current screen size and design specifications.
///
/// ## Basic Usage
///
/// ```dart
/// Container(
///   width: 200.w,    // Scales based on width
///   height: 100.h,   // Scales based on height
///   padding: EdgeInsets.all(16.r), // Scales for radius
///   child: Text(
///     'Hello',
///     style: TextStyle(fontSize: 18.sp), // Scales for text
///   ),
/// )
/// ```
///
/// ## With maxWidth
///
/// When [PxResponsiveConfig.maxWidth] is set to 1920:
/// ```dart
/// // On 1600px screen
/// 200.w // = 200 * (1600 / 1920) = ~166.67
///
/// // On 2560px screen
/// 200.w // = 200 * (1920 / 1920) = 200 (capped at maxWidth)
/// ```
extension PxResponsiveNumExtension on num {
  // ==================== Core Scaling ====================

  /// Scales this value based on width ratio.
  ///
  /// Formula: `value * (effectiveWidth / activeBaseSize.width)`
  ///
  /// Use for: Container widths, horizontal padding, horizontal margins
  ///
  /// Example:
  /// ```dart
  /// width: 200.w // Scales 200 from your design
  /// ```
  double get w => this * PxResponsive().scaleW;

  /// Scales this value based on height ratio.
  ///
  /// Formula: `value * (screenHeight / activeBaseSize.height)`
  ///
  /// Use for: Container heights, vertical padding, vertical margins
  ///
  /// Example:
  /// ```dart
  /// height: 100.h // Scales 100 from your design
  /// ```
  double get h => this * PxResponsive().scaleH;

  /// Scales this value for fonts (Scalable Pixels).
  ///
  /// Formula: `value * scaleW` (but with tighter max constraint)
  ///
  /// Use for: Font sizes, text-related dimensions
  ///
  /// Example:
  /// ```dart
  /// fontSize: 16.sp // Scales 16 from your design
  /// ```
  ///
  /// Note: Text scaling is capped at [PxResponsiveConfig.maxTextScaleFactor]
  /// (default 1.5) to prevent text from becoming too large.
  double get sp => this * PxResponsive().scaleSp;

  /// Scales this value for radius/diagonal elements.
  ///
  /// Formula: `value * min(scaleW, scaleH)`
  ///
  /// Use for: Border radius, circular avatars, circular progress indicators
  ///
  /// Example:
  /// ```dart
  /// borderRadius: BorderRadius.circular(12.r)
  /// ```
  ///
  /// Using the minimum scale prevents distortion in circular elements.
  double get r => this * PxResponsive().scaleR;

  // ==================== Percentage of Screen ====================

  /// Returns this value as a percentage of the full window width.
  ///
  /// Formula: `(value / 100) * effectiveWidth`
  ///
  /// Example:
  /// ```dart
  /// width: 50.wf // 50% of effective screen width
  /// ```
  ///
  /// On a 1920px screen: `50.wf = 960`
  double get wf => (this / 100) * PxResponsive().effectiveWidth;

  /// Returns this value as a percentage of the full window height.
  ///
  /// Formula: `(value / 100) * screenHeight`
  ///
  /// Example:
  /// ```dart
  /// height: 75.hf // 75% of screen height
  /// ```
  ///
  /// On a 1080px tall screen: `75.hf = 810`
  double get hf => (this / 100) * PxResponsive().screenHeight;

  // ==================== Clamping Methods ====================

  /// Returns this value scaled by width with a custom minimum.
  ///
  /// Ensures the result is never less than [minimum].
  ///
  /// Example:
  /// ```dart
  /// width: 200.wMin(150) // At least 150, but scales if larger
  /// ```
  double wMin(double minimum) => math.max(w, minimum);

  /// Returns this value scaled by width with a custom maximum.
  ///
  /// Ensures the result is never greater than [maximum].
  ///
  /// Example:
  /// ```dart
  /// width: 200.wMax(250) // At most 250, but scales if smaller
  /// ```
  double wMax(double maximum) => math.min(w, maximum);

  /// Returns this value scaled by width, clamped between min and max.
  ///
  /// Example:
  /// ```dart
  /// width: 200.wClamp(150, 250) // Between 150 and 250
  /// ```
  double wClamp(double minimum, double maximum) => w.clamp(minimum, maximum);

  /// Returns this value scaled by height with a custom minimum.
  ///
  /// Example:
  /// ```dart
  /// height: 100.hMin(80) // At least 80, but scales if larger
  /// ```
  double hMin(double minimum) => math.max(h, minimum);

  /// Returns this value scaled by height with a custom maximum.
  ///
  /// Example:
  /// ```dart
  /// height: 100.hMax(120) // At most 120, but scales if smaller
  /// ```
  double hMax(double maximum) => math.min(h, maximum);

  /// Returns this value scaled by height, clamped between min and max.
  ///
  /// Example:
  /// ```dart
  /// height: 100.hClamp(80, 120) // Between 80 and 120
  /// ```
  double hClamp(double minimum, double maximum) => h.clamp(minimum, maximum);

  /// Returns this value scaled for fonts with a custom minimum.
  ///
  /// Example:
  /// ```dart
  /// fontSize: 14.spMin(12) // At least 12, but scales if larger
  /// ```
  double spMin(double minimum) => math.max(sp, minimum);

  /// Returns this value scaled for fonts with a custom maximum.
  ///
  /// Example:
  /// ```dart
  /// fontSize: 18.spMax(24) // At most 24, but scales if smaller
  /// ```
  double spMax(double maximum) => math.min(sp, maximum);

  /// Returns this value scaled for fonts, clamped between min and max.
  ///
  /// Example:
  /// ```dart
  /// fontSize: 16.spClamp(12, 20) // Between 12 and 20
  /// ```
  double spClamp(double minimum, double maximum) => sp.clamp(minimum, maximum);
}

// ============================================================================
// PARENT-RELATIVE SIZING
// ============================================================================

/// A widget that provides parent-relative sizing for its child.
///
/// Wrap a parent widget with [PxRelativeSizeProvider] to enable the
/// `.wr()` and `.hr()` extensions in descendant widgets.
///
/// ## Example
///
/// ```dart
/// PxRelativeSizeProvider(
///   child: Container(
///     width: 80.wr(context), // 80% of parent width
///     height: 50.hr(context), // 50% of parent height
///     child: Text('Relative sized'),
///   ),
/// )
/// ```
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
///
/// These extensions require the parent widget to be wrapped with
/// [PxRelativeSizeProvider].
extension PxResponsiveRelativeExtension on num {
  /// Returns this value as a percentage of the parent's width.
  ///
  /// Requires the parent to be wrapped with [PxRelativeSizeProvider].
  /// Falls back to screen width if no provider is found.
  ///
  /// Example:
  /// ```dart
  /// PxRelativeSizeProvider(
  ///   child: Container(
  ///     width: 80.wr(context), // 80% of parent's width
  ///   ),
  /// )
  /// ```
  double wr(BuildContext context) {
    final parentSize = _PxRelativeSizeInherited.of(context);
    if (parentSize != null) {
      return (this / 100) * parentSize.width;
    }
    // Fallback: use effective screen width
    return (this / 100) * PxResponsive().effectiveWidth;
  }

  /// Returns this value as a percentage of the parent's height.
  ///
  /// Requires the parent to be wrapped with [PxRelativeSizeProvider].
  /// Falls back to screen height if no provider is found.
  ///
  /// Example:
  /// ```dart
  /// PxRelativeSizeProvider(
  ///   child: Container(
  ///     height: 50.hr(context), // 50% of parent's height
  ///   ),
  /// )
  /// ```
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
///
/// These extensions allow you to scale entire [EdgeInsets] objects
/// at once, maintaining their proportions.
extension PxResponsiveEdgeInsetsExtension on EdgeInsets {
  /// Returns a new [EdgeInsets] with all values scaled by width factor.
  ///
  /// Example:
  /// ```dart
  /// padding: EdgeInsets.all(16).w
  /// // All sides scaled by width ratio
  /// ```
  EdgeInsets get w => copyWith(
        left: left * PxResponsive().scaleW,
        top: top * PxResponsive().scaleW,
        right: right * PxResponsive().scaleW,
        bottom: bottom * PxResponsive().scaleW,
      );

  /// Returns a new [EdgeInsets] with horizontal scaled by width, vertical by height.
  ///
  /// This provides more accurate scaling for padding/margins that should
  /// respect both dimensions independently.
  ///
  /// Example:
  /// ```dart
  /// padding: EdgeInsets.symmetric(
  ///   horizontal: 20,
  ///   vertical: 10,
  /// ).scaled
  /// // horizontal: 20 * scaleW, vertical: 10 * scaleH
  /// ```
  EdgeInsets get scaled => copyWith(
        left: left * PxResponsive().scaleW,
        top: top * PxResponsive().scaleH,
        right: right * PxResponsive().scaleW,
        bottom: bottom * PxResponsive().scaleH,
      );

  /// Returns a new [EdgeInsets] with all values scaled by radius factor.
  ///
  /// Example:
  /// ```dart
  /// padding: EdgeInsets.all(12).r
  /// // All sides scaled by min(scaleW, scaleH)
  /// ```
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
///
/// These extensions allow you to scale [Size] objects while maintaining
/// proper aspect ratios.
extension PxResponsiveSizeExtension on Size {
  /// Returns a new [Size] with width scaled by scaleW and height by scaleH.
  ///
  /// This maintains the aspect ratio relative to the design specifications.
  ///
  /// Example:
  /// ```dart
  /// Size imageSize = Size(400, 300).scaled
  /// // width: 400 * scaleW, height: 300 * scaleH
  /// ```
  Size get scaled => Size(
        width * PxResponsive().scaleW,
        height * PxResponsive().scaleH,
      );

  /// Returns a new [Size] with both dimensions scaled by scaleW.
  ///
  /// Use when you want uniform scaling based on width.
  ///
  /// Example:
  /// ```dart
  /// Size boxSize = Size(200, 200).w
  /// // Both dimensions scaled by width ratio
  /// ```
  Size get w => Size(
        width * PxResponsive().scaleW,
        height * PxResponsive().scaleW,
      );

  /// Returns a new [Size] with both dimensions scaled by scaleR.
  ///
  /// Use for circular or square elements that should maintain
  /// their shape across different screen sizes.
  ///
  /// Example:
  /// ```dart
  /// Size avatarSize = Size(80, 80).r
  /// // Both dimensions scaled by min(scaleW, scaleH)
  /// ```
  Size get r => Size(
        width * PxResponsive().scaleR,
        height * PxResponsive().scaleR,
      );
}

// ============================================================================
// BORDERRADIUS EXTENSIONS
// ============================================================================

/// Extensions on [BorderRadius] for responsive scaling.
///
/// These extensions scale border radii to maintain proportional
/// corner rounding across different screen sizes.
extension PxResponsiveBorderRadiusExtension on BorderRadius {
  /// Returns a new [BorderRadius] with all radii scaled by scaleR.
  ///
  /// Using the radius scale factor ensures that rounded corners
  /// maintain their visual appearance across different screen sizes.
  ///
  /// Example:
  /// ```dart
  /// decoration: BoxDecoration(
  ///   borderRadius: BorderRadius.circular(16).r,
  /// )
  /// // All corners scaled by min(scaleW, scaleH)
  /// ```
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
