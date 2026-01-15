/// A powerful tri-tier responsive design system for Flutter.
///
/// This package provides automatic UI scaling across mobile, tablet, and desktop
/// platforms based on your Figma/XD design specifications.
///
/// ## Getting Started
///
/// 1. Wrap your app with [PxResponsiveWrapper]:
///
/// ```dart
/// void main() {
///   runApp(
///     PxResponsiveWrapper(
///       config: const PxResponsiveConfig(
///         desktop: Size(1920, 1080),
///         tablet: Size(834, 1194),
///         mobile: Size(375, 812),
///         maxWidth: 1920, // Optional: cap scaling at 1920px
///       ),
///       child: const MyApp(),
///     ),
///   );
/// }
/// ```
///
/// 2. Use the extensions in your widgets:
///
/// ```dart
/// Container(
///   width: 200.w,   // Scales width based on design
///   height: 100.h,  // Scales height based on design
///   child: Text(
///     'Hello',
///     style: TextStyle(fontSize: 16.sp),
///   ),
/// )
/// ```
///
/// 3. Check device type with simple global getters:
///
/// ```dart
/// if (isMobile) {
///   // Mobile-specific code
/// }
/// ```
///
/// 4. Use [responsiveValue] for device-specific values:
///
/// ```dart
/// width: responsiveValue(mobile: 120.w, tablet: 160.w, desktop: 200.w)
/// ```
///
/// ## Extensions Reference
///
/// | Extension | Description |
/// |-----------|-------------|
/// | `.w` | Width scaled by design ratio |
/// | `.h` | Height scaled by design ratio |
/// | `.sp` | Font size (with tighter max) |
/// | `.r` | Radius using min(scaleW, scaleH) |
/// | `.wf` | Percentage of window width |
/// | `.hf` | Percentage of window height |
/// | `.wr(context)` | Percentage of parent width |
/// | `.hr(context)` | Percentage of parent height |
///
/// ## Global Getters
///
/// | Getter | Type | Description |
/// |--------|------|-------------|
/// | [isMobile] | `bool` | True if mobile layout |
/// | [isTablet] | `bool` | True if tablet layout |
/// | [isDesktop] | `bool` | True if desktop layout |
/// | [deviceType] | `PxDeviceType` | Current device type enum |
/// | [screenWidth] | `double` | Current screen width |
/// | [screenHeight] | `double` | Current screen height |
///
/// ## WebAssembly (WASM) Support
///
/// This package is fully compatible with Flutter's WASM compilation target.
/// It uses only pure Dart code and Flutter widgets without any platform-specific
/// dependencies, making it suitable for web applications compiled to WASM.
library;

export 'src/px_responsive_config.dart';
export 'src/px_responsive_core.dart';
export 'src/px_responsive_wrapper.dart';
export 'src/px_responsive_extensions.dart';
export 'src/px_responsive_builder.dart';
