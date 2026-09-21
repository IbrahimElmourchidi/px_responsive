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
///
/// See `px_responsive_globals.dart` (exported, non-deprecated, via
/// `package:px_responsive/globals.dart`) for the `platformType`,
/// `isNativeMobile`, `isNativeDesktop` and `isPlatformWeb` getters that
/// classify [PxPlatformType].
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
