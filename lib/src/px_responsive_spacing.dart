import 'package:flutter/widgets.dart';
import 'px_responsive_core.dart';

// ============================================================================
// SPACING EXTENSIONS - Shorthand SizedBox helpers
// ============================================================================

/// Extensions on [num] for responsive spacing shorthands.
///
/// These extensions provide a concise alternative to `SizedBox(height: 16.h)`:
///
/// ```dart
/// // Before
/// SizedBox(height: 16.h),
///
/// // After
/// 16.verticalSpace,
/// ```
extension PxResponsiveSpacingExtension on num {
  /// Returns a [SizedBox] with height scaled by [PxResponsive.scaleH].
  ///
  /// Example:
  /// ```dart
  /// Column(
  ///   children: [
  ///     Text('Title'),
  ///     16.verticalSpace,
  ///     Text('Body'),
  ///   ],
  /// )
  /// ```
  SizedBox get verticalSpace =>
      SizedBox(height: toDouble() * PxResponsive().scaleH);

  /// Returns a [SizedBox] with width scaled by [PxResponsive.scaleW].
  ///
  /// Example:
  /// ```dart
  /// Row(
  ///   children: [
  ///     Icon(Icons.home),
  ///     8.horizontalSpace,
  ///     Text('Home'),
  ///   ],
  /// )
  /// ```
  SizedBox get horizontalSpace =>
      SizedBox(width: toDouble() * PxResponsive().scaleW);
}
