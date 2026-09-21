// ============================================================================
// GLOBAL GETTERS AND FUNCTIONS
// ============================================================================
//
// The canonical, non-deprecated implementations of every top-level getter
// and function this package exposes. `package:px_responsive/globals.dart`
// re-exports this file verbatim; `package:px_responsive/px_responsive.dart`
// (the main barrel) instead exports deprecated thin wrappers around these
// from `px_responsive_globals_deprecated.dart`, so importing the main
// barrel alone still surfaces a deprecation hint pointing here.
import 'package:flutter/foundation.dart' show kIsWeb, TargetPlatform, defaultTargetPlatform;
import 'px_responsive_config.dart';
import 'px_responsive_core.dart';
import 'px_responsive_platform.dart';

/// Returns `true` if the current screen width is in the mobile range.
///
/// Equivalent to: `PxResponsive().isMobile`
bool get isMobile => PxResponsive().isMobile;

/// Returns `true` if the current screen width is in the tablet range.
///
/// Equivalent to: `PxResponsive().isTablet`
bool get isTablet => PxResponsive().isTablet;

/// Returns `true` if the current screen width is in the desktop range.
///
/// Equivalent to: `PxResponsive().isDesktop`
bool get isDesktop => PxResponsive().isDesktop;

/// Returns the current device type as [PxDeviceType] enum.
///
/// Equivalent to: `PxResponsive().deviceType`
PxDeviceType get deviceType => PxResponsive().deviceType;

/// Returns the current screen width in logical pixels.
///
/// Equivalent to: `PxResponsive().screenWidth`
double get screenWidth => PxResponsive().screenWidth;

/// Returns the current screen height in logical pixels.
///
/// Equivalent to: `PxResponsive().screenHeight`
double get screenHeight => PxResponsive().screenHeight;

/// Returns the effective width used for scaling calculations.
///
/// Equivalent to: `PxResponsive().effectiveWidth`
double get effectiveWidth => PxResponsive().effectiveWidth;

/// Returns `true` if the screen is in landscape orientation.
///
/// Equivalent to: `PxResponsive().isLandscape`
bool get isLandscape => PxResponsive().isLandscape;

/// Returns `true` if the screen is in portrait orientation.
///
/// Equivalent to: `PxResponsive().isPortrait`
bool get isPortrait => PxResponsive().isPortrait;

/// Returns the current screen orientation as a [PxOrientation] enum.
///
/// Equivalent to: `PxResponsive().orientation`
PxOrientation get orientation => PxResponsive().orientation;

/// Returns the appropriate value based on current device type.
///
/// Equivalent to: `PxResponsive().value(...)`
T responsiveValue<T>({required T mobile, T? tablet, T? desktop}) {
  return PxResponsive().value(mobile: mobile, tablet: tablet, desktop: desktop);
}

/// Returns the appropriate value based on the current screen orientation.
///
/// Equivalent to: `PxResponsive().orientationValue(...)`
T orientationValue<T>({required T portrait, required T landscape}) =>
    PxResponsive().orientationValue(portrait: portrait, landscape: landscape);

// ============================================================================
// PLATFORM GETTERS
// ============================================================================

/// Returns the current [PxPlatformType] based on [kIsWeb] and
/// [defaultTargetPlatform].
PxPlatformType get platformType {
  if (kIsWeb) return PxPlatformType.web;
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
      return PxPlatformType.android;
    case TargetPlatform.iOS:
      return PxPlatformType.ios;
    case TargetPlatform.macOS:
      return PxPlatformType.macos;
    case TargetPlatform.windows:
      return PxPlatformType.windows;
    case TargetPlatform.linux:
      return PxPlatformType.linux;
    case TargetPlatform.fuchsia:
      return PxPlatformType.fuchsia;
  }
}

/// Returns `true` if the app is running on a native mobile platform
/// (Android or iOS).
bool get isNativeMobile =>
    platformType == PxPlatformType.android || platformType == PxPlatformType.ios;

/// Returns `true` if the app is running on a native desktop platform
/// (macOS, Windows, or Linux).
bool get isNativeDesktop =>
    platformType == PxPlatformType.macos ||
    platformType == PxPlatformType.windows ||
    platformType == PxPlatformType.linux;

/// Returns `true` if the app is running in a web browser.
bool get isPlatformWeb => platformType == PxPlatformType.web;
