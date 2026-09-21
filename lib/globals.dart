/// Opt-in entrypoint for `px_responsive`'s top-level global getters and
/// functions (`isMobile`, `screenWidth`, `orientation`, `platformType`, ...),
/// without the deprecation hints that importing them via
/// `package:px_responsive/px_responsive.dart` now carries.
///
/// Import this instead of (not in addition to — the two entrypoints declare
/// the same names and cannot both be imported unprefixed) the main barrel
/// if you specifically want these names and don't want deprecation noise:
///
/// ```dart
/// import 'package:px_responsive/globals.dart';
/// import 'package:px_responsive/px_responsive.dart' hide isMobile, isTablet,
///     isDesktop, deviceType, screenWidth, screenHeight, effectiveWidth,
///     isLandscape, isPortrait, orientation, responsiveValue, orientationValue,
///     platformType, isNativeMobile, isNativeDesktop, isPlatformWeb;
/// ```
///
/// New code should generally prefer `context.responsive` (scope-aware,
/// rebuilds correctly via `PxResponsiveScope`) or `PxResponsive()` (the
/// static path) over either of these global-getter entrypoints.
library;

export 'src/px_responsive_globals.dart';
