import 'px_responsive_config.dart';
import 'px_responsive_globals.dart' as globals;
import 'px_responsive_platform.dart';

// ============================================================================
// DEPRECATED GLOBAL GETTERS - kept for 0.1.x compatibility, removed in 0.3.0
// ============================================================================
//
// These top-level getters pollute the global namespace of every file that
// imports `package:px_responsive/px_responsive.dart` — `isMobile`,
// `orientation` and `deviceType` in particular are common names that can
// collide with a user's own declarations.
//
// Each one below simply forwards to the real, non-deprecated implementation
// in `px_responsive_globals.dart`. Prefer, in order:
//   1. `context.responsive.isMobile` / `.deviceType` / `.screenWidth` — scope-aware.
//   2. `PxResponsive().isMobile` — the static path, unchanged.
//   3. `import 'package:px_responsive/globals.dart';` for a verbatim,
//      opt-in replacement of these exact names, without the deprecation hint.
//
// This file is exported by the main `package:px_responsive/px_responsive.dart`
// entrypoint in 0.2.x, and removed from it in 0.3.0.

const _msg =
    'Pollutes the global namespace. Use context.responsive, PxResponsive(), '
    'or import package:px_responsive/globals.dart for a verbatim, '
    'non-deprecated replacement. Will be removed from this entrypoint in 0.3.0.';

/// Returns `true` if the current screen width is in the mobile range.
@Deprecated(_msg)
bool get isMobile => globals.isMobile;

/// Returns `true` if the current screen width is in the tablet range.
@Deprecated(_msg)
bool get isTablet => globals.isTablet;

/// Returns `true` if the current screen width is in the desktop range.
@Deprecated(_msg)
bool get isDesktop => globals.isDesktop;

/// Returns the current device type as [PxDeviceType] enum.
@Deprecated(_msg)
PxDeviceType get deviceType => globals.deviceType;

/// Returns the current screen width in logical pixels.
@Deprecated(_msg)
double get screenWidth => globals.screenWidth;

/// Returns the current screen height in logical pixels.
@Deprecated(_msg)
double get screenHeight => globals.screenHeight;

/// Returns the effective width used for scaling calculations.
@Deprecated(_msg)
double get effectiveWidth => globals.effectiveWidth;

/// Returns `true` if the screen is in landscape orientation.
@Deprecated(_msg)
bool get isLandscape => globals.isLandscape;

/// Returns `true` if the screen is in portrait orientation.
@Deprecated(_msg)
bool get isPortrait => globals.isPortrait;

/// Returns the current screen orientation as a [PxOrientation] enum.
@Deprecated(_msg)
PxOrientation get orientation => globals.orientation;

/// Returns the appropriate value based on current device type.
@Deprecated(_msg)
T responsiveValue<T>({required T mobile, T? tablet, T? desktop}) =>
    globals.responsiveValue(mobile: mobile, tablet: tablet, desktop: desktop);

/// Returns the appropriate value based on the current screen orientation.
@Deprecated(_msg)
T orientationValue<T>({required T portrait, required T landscape}) =>
    globals.orientationValue(portrait: portrait, landscape: landscape);

/// Returns the current [PxPlatformType] based on the runtime platform.
@Deprecated(_msg)
PxPlatformType get platformType => globals.platformType;

/// Returns `true` if the app is running on a native mobile platform.
@Deprecated(_msg)
bool get isNativeMobile => globals.isNativeMobile;

/// Returns `true` if the app is running on a native desktop platform.
@Deprecated(_msg)
bool get isNativeDesktop => globals.isNativeDesktop;

/// Returns `true` if the app is running in a web browser.
@Deprecated(_msg)
bool get isPlatformWeb => globals.isPlatformWeb;
