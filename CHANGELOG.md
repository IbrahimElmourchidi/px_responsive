# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-03-21

### Added

- **Orientation support** — `isLandscape`, `isPortrait`, `orientation` getters and `orientationValue<T>()` on both `PxResponsive` and as global helpers
- **`PxOrientation` enum** — `portrait` / `landscape` values
- **Landscape design sizes** — optional `mobileLandscape`, `tabletLandscape`, `desktopLandscape` in `PxResponsiveConfig`; the active base size switches automatically when the device rotates
- **Safe area awareness** — `safeAreaTop`, `safeAreaBottom`, `safeAreaLeft`, `safeAreaRight`, `safeScreenHeight` on `PxResponsive`; populated automatically from `MediaQuery.padding` inside `PxResponsiveWrapper`
- **`PxResponsiveMediaQueryWrapper`** — alternative to `PxResponsiveWrapper` that reads screen size from `MediaQuery` instead of `LayoutBuilder`; useful when the wrapper is placed inside a constrained subtree
- **`BuildContext` extensions** (`PxResponsiveContextExtension`) — `context.isMobile`, `context.isTablet`, `context.isDesktop`, `context.deviceType`, `context.screenWidth`, `context.screenHeight`, `context.isLandscape`, `context.isPortrait`
- **`TextStyle.responsive`** — scales `fontSize` by `scaleSp`, `letterSpacing` and `wordSpacing` by `scaleW`
- **`Icon.responsive`** — scales icon `size` by `scaleSp`
- **Spacing extensions** (`PxResponsiveSpacingExtension`) — `num.verticalSpace` → `SizedBox(height: value.h)`, `num.horizontalSpace` → `SizedBox(width: value.w)`
- **Radius clamping** — `.rMin(min)`, `.rMax(max)`, `.rClamp(min, max)` on `num` (mirrors existing `.wClamp` / `.hClamp` / `.spClamp`)
- **`PxResponsiveDebug`** — overlay widget that displays device type, screen dimensions, orientation, active base size and all scale factors; controlled by an `enabled` flag
- **`PxResponsivePadding`** — widget that selects device-specific `EdgeInsets` with an optional `scale: true` flag to apply `.scaled` automatically
- **`PxResponsiveGrid`** — `GridView`-based widget with per-device `mobileColumns`, `tabletColumns`, `desktopColumns`; configurable `spacing`, `runSpacing`, `childAspectRatio`, `shrinkWrap`, and `physics`
- **`AnimatedPxResponsiveBuilder`** — wraps layouts in `AnimatedSwitcher` so desktop window resizes transition smoothly between device types; supports custom duration, curves and transition builders
- **`PxPlatformType` enum** — `android`, `ios`, `web`, `macos`, `windows`, `linux`, `fuchsia`
- **Platform detection helpers** — `platformType`, `isNativeMobile`, `isNativeDesktop`, `isPlatformWeb` top-level getters
- **`orientationValue<T>()` global function** — mirror of `PxResponsive().orientationValue()`
- Greatly expanded test suite: orientation tests, safe area tests, clamping tests, `TextStyle.responsive` tests, spacing tests, plus a new `px_responsive_widget_test.dart` covering all widgets

### Changed

- `PxResponsive.init()` now accepts an optional `safeAreaPadding` parameter (defaults to `EdgeInsets.zero` — fully backward-compatible)
- `PxResponsiveWrapper` now passes `MediaQuery.padding` as `safeAreaPadding` to `init()`
- `PxResponsive.reset()` now resets `safeAreaPadding` to `EdgeInsets.zero`
- `PxResponsive.toString()` now includes orientation and safe area in output
- `PxResponsiveConfig.copyWith()` gains `desktopLandscape`, `tabletLandscape`, `mobileLandscape` parameters
- SDK constraint widened from `<4.0.0` to `<5.0.0`
- Supported platforms expanded: added `macos`, `linux`, `windows` to `pubspec.yaml`
- Version bumped to `0.1.0`

---

## [0.0.4] - 2025-01-15
- Updated the license

## [0.0.3] - 2025-01-15
- Updated the documentation

## [0.0.2] - 2025-01-15

### Added

- `maxWidth` parameter in `PxResponsiveConfig` to constrain maximum screen width
- Maximum width limiting to prevent UI elements from becoming too large on ultra-wide displays
- Automatic width capping when screen exceeds `maxWidth` threshold
- Documentation for `maxWidth` usage and best practices

### Changed

- Scale factor calculations now respect `maxWidth` constraint when specified
- Improved handling of ultra-wide screen scenarios (4K, ultrawide monitors)

## [0.0.1] - 2025-01-10

### Added

- Initial release of px_responsive
- `PxResponsiveConfig` — configuration class for design baselines and breakpoints
- `PxResponsive` — singleton core for calculating scale factors
- `PxResponsiveWrapper` — widget wrapper for initializing the responsive system
- Numeric extensions (`.w`, `.h`, `.sp`, `.r`, `.wf`, `.hf`)
- Parent-relative extensions (`.wr()`, `.hr()`)
- Clamping methods (`.wMin()`, `.wMax()`, `.wClamp()`, `.hMin()`, `.hMax()`, `.hClamp()`, `.spMin()`, `.spMax()`, `.spClamp()`)
- `EdgeInsets` extensions (`.w`, `.scaled`, `.r`)
- `Size` extensions (`.scaled`, `.w`, `.r`)
- `BorderRadius` extensions (`.r`)
- `PxResponsiveBuilder` — widget for device-specific layouts
- `PxResponsiveValue` — widget for device-specific values
- `PxResponsiveVisibility` — widget for conditional visibility
- Scale factor clamping to prevent extreme UI scaling
- Separate text scale factor limit (`maxTextScaleFactor`)
- Full documentation for all public APIs
