# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.2.0] - 2026-09-21

This release fixes the package's central defect: **screen-size changes did
not reliably reach the widget tree.** Because `PxResponsiveWrapper` returned
the same child widget instance on every rebuild, Flutter's identical-widget
diffing silently stopped propagation, so a plain `200.w` could go stale
after a resize or rotation until something unrelated happened to rebuild
that part of the tree. Alongside that: a large scale-factor jump at each
breakpoint, `maxWidth` not matching its own documented centering behaviour,
a `PxResponsiveDebug` crash in its own documented placement, and landscape
phones being misclassified as tablets.

### Fixed / Changed (see "Breaking changes" below for full details)

- **Reactivity.** `PxResponsiveWrapper` and `PxResponsiveMediaQueryWrapper`
  now publish a `PxResponsiveData` snapshot two ways every layout pass: via
  a new `PxResponsiveScope` (`InheritedWidget`) that this package's own
  widgets and `context.responsive` depend on correctly, and — by walking
  the subtree and marking every descendant dirty when the data actually
  changed — so plain `.w`/`.h`/`.sp`/`.r` reads stay correct too, without
  requiring a rewrite of existing call sites. Controlled by the new
  `forceRebuildOnChange` flag (default `true`); see `PxResponsiveRebuildBoundary`
  to exempt a subtree, and `PxResponsiveConfig.rebuildEpsilon` to tolerate
  small changes without a full-tree rebuild.
- **`maxWidth` now actually centers content** (the behaviour its own doc
  comments always described): past `maxWidth`, the app is physically
  constrained and centered in a column of that width, with empty space on
  either side (paint it with the new `maxWidthBackground`). The old
  scale-factor-only behaviour is preserved via
  `maxWidthBehavior: PxMaxWidthBehavior.scaleOnly`.
- **Hybrid breakpoint detection** (`PxResponsiveConfig.breakpointAxis`,
  default `PxBreakpointAxis.hybrid`): `mobileBreakpoint` is now compared
  against `min(effectiveWidth, screenHeight)` and `tabletBreakpoint`
  against `effectiveWidth`, so a landscape phone is correctly detected as
  mobile (previously misclassified as tablet) while a short desktop
  monitor is still correctly detected as desktop.
- **`autoFlipLandscapeBase`** (default `true`): in landscape, when no
  explicit `*Landscape` size is configured, a portrait-shaped base size is
  automatically flipped (width/height swapped) instead of producing a
  severely under-scaled height.
- **`transitionBand`** (default `0`, disabled): blends `activeBaseSize`
  linearly across a band around each breakpoint, so crossing one no longer
  causes a large one-pixel jump (e.g. `16.sp` rendering at 23.0px at width
  1199 and 10.0px at width 1200 with the default configuration).
  `PxDeviceType` itself always still switches exactly at the breakpoint.
- **`PxResponsiveDebug`** no longer crashes when placed above `MaterialApp`
  (its own documented position) — it now supplies its own `Directionality`
  and uses a non-directional `Stack` alignment.
- **`minScaleFactor` now defaults to `null`** (was `0.5`): a floor
  guarantees overflow on screens narrower than `base.width * minScaleFactor`
  rather than protecting against anything; set it explicitly if you want one.
- Reading a derived value (a scale factor, `deviceType`, `effectiveWidth`,
  `.value()`) before any wrapper has built now asserts in debug mode,
  instead of silently returning a value clamped to the old floor default.
  Screen-dimension getters (`screenWidth`, `safeArea*`, `config`, ...)
  still return zeroed defaults without asserting.
- `PxResponsiveConfig.copyWith()` can now clear nullable fields (`maxWidth`,
  `minScaleFactor`, `maxScaleFactor`, `maxTextScaleFactor`, the `*Landscape`
  sizes, `maxWidthBackground`) by passing `null` explicitly.
- `Icon.responsive` now forwards every `Icon` field (previously dropped
  `key`, `applyTextScaling`, `blendMode`, `fontWeight`).
- **`PxResponsiveGrid.builder`** constructor (`itemCount` + `itemBuilder`)
  for lazily-built grids; the existing `children:` constructor is unchanged.
- **`EdgeInsetsDirectional`** extension (`.w`, `.scaled`, `.r`), mirroring
  the existing `EdgeInsets` extension, for RTL-aware code.
- **`context.orientation`** added to `PxResponsiveContextExtension`.
- The top-level global getters/functions (`isMobile`, `screenWidth`,
  `orientation`, `deviceType`, `platformType`, `responsiveValue`, ...) are
  now `@Deprecated` on the main `package:px_responsive/px_responsive.dart`
  entrypoint — they pollute the importing file's global namespace and don't
  participate in `PxResponsiveScope`'s reactivity. Prefer `context.responsive`
  or `PxResponsive()`. A verbatim, non-deprecated replacement is available
  via `import 'package:px_responsive/globals.dart'`. Will be removed from
  the main entrypoint in 0.3.0.
- Fixed the widget test harness (`buildTestApp`/`pumpResponsive` in
  `px_responsive_widget_test.dart`), which previously placed a `SizedBox`
  *inside* the wrapper, making its `size:` parameter inert — every
  size-dependent test silently ran at the 800×600 default test surface.
  It now sets `tester.view.physicalSize` instead. The suite also gained
  tests that assert on the *rendered* widget tree after a resize, not just
  on the singleton's own getters.

### Breaking changes

If you're upgrading from 0.1.x, the changes most likely to affect you:

1. **`minScaleFactor` default `0.5` → `null`.** If you relied on the
   implicit floor, set `minScaleFactor: 0.5` explicitly.
2. **Landscape phones now classify as mobile, not tablet** (see "Hybrid
   breakpoint detection" above). Set `breakpointAxis: PxBreakpointAxis.width`
   to restore the exact 0.1.x tier logic.
3. **Breakpoints now compare against `effectiveWidth`, not the actual
   screen width**, when `maxWidth` is set. This only differs from 0.1.x
   behaviour once the screen exceeds `maxWidth`.
4. **`maxWidth` now physically centers and constrains content by default**
   (see above). A 2560px screen with `maxWidth: 1920` gains 320px of empty
   space per side, painted with whatever is behind the wrapper unless you
   set `maxWidthBackground`. Set `maxWidthBehavior: PxMaxWidthBehavior.scaleOnly`
   to keep exact 0.1.x behaviour.
5. **`context.responsive` now returns `PxResponsiveData`, not `PxResponsive`.**
   Both expose the same scale/device-type/orientation getters, but code that
   held onto the returned type directly needs updating.
6. **Reading a scale factor, `deviceType`, `effectiveWidth`, or calling
   `.value()` before any `PxResponsiveWrapper` has built now asserts** in
   debug mode, rather than silently returning a value derived from the old
   `0.5` floor.
7. Top-level global getters are deprecated on the main entrypoint (see above)
   — purely a lint-level change, not a behavioural one, until 0.3.0.

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
- SDK constraint kept at `<4.0.0` (pub.dev does not accept constraints that allow non-existent Dart versions)
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
