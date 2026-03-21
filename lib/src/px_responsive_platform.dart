import 'package:flutter/foundation.dart';

// ============================================================================
// PLATFORM TYPE DETECTION
// ============================================================================

/// Enum representing the underlying runtime platform.
///
/// Unlike [PxDeviceType] (which is based on screen width), [PxPlatformType]
/// reflects the actual OS the app is running on.
///
/// Example:
/// ```dart
/// if (platformType == PxPlatformType.ios) {
///   // Use Cupertino-style UI
/// }
/// ```
enum PxPlatformType {
  /// Android mobile / tablet.
  android,

  /// Apple iOS / iPadOS.
  ios,

  /// Web (any browser, any OS).
  web,

  /// macOS desktop.
  macos,

  /// Windows desktop.
  windows,

  /// Linux desktop.
  linux,

  /// Google Fuchsia.
  fuchsia,
}

/// Returns the current [PxPlatformType] based on [kIsWeb] and
/// [defaultTargetPlatform].
///
/// Example:
/// ```dart
/// if (platformType == PxPlatformType.web) {
///   openBrowserLink(url);
/// }
/// ```
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
///
/// Example:
/// ```dart
/// if (isNativeMobile) {
///   requestCameraPermission();
/// }
/// ```
bool get isNativeMobile =>
    platformType == PxPlatformType.android ||
    platformType == PxPlatformType.ios;

/// Returns `true` if the app is running on a native desktop platform
/// (macOS, Windows, or Linux).
bool get isNativeDesktop =>
    platformType == PxPlatformType.macos ||
    platformType == PxPlatformType.windows ||
    platformType == PxPlatformType.linux;

/// Returns `true` if the app is running in a web browser.
bool get isPlatformWeb => platformType == PxPlatformType.web;
