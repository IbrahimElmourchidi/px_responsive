# px_responsive

A powerful tri-tier responsive design system for Flutter that automatically scales your UI across mobile, tablet, and desktop platforms based on your Figma/XD design specifications.

[![pub package](https://img.shields.io/pub/v/px_responsive.svg)](https://pub.dev/packages/px_responsive)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [How It Works](#how-it-works)
- [API Reference](#api-reference)
  - [Core Extensions](#core-extensions)
  - [Screen Percentage Extensions](#screen-percentage-extensions)
  - [Parent-Relative Extensions](#parent-relative-extensions)
  - [Clamping Methods](#clamping-methods)
  - [Spacing Shorthands](#spacing-shorthands)
  - [Object Extensions](#object-extensions)
  - [TextStyle & Icon Extensions](#textstyle--icon-extensions)
  - [Global Getters](#global-getters)
  - [Global Functions](#global-functions)
  - [BuildContext Extensions](#buildcontext-extensions)
- [Orientation Support](#orientation-support)
- [Safe Area Awareness](#safe-area-awareness)
- [Responsive Widgets](#responsive-widgets)
  - [PxResponsiveWrapper](#pxresponsivewrapper)
  - [PxResponsiveMediaQueryWrapper](#pxresponsivemediaquerywrapper)
  - [PxResponsiveBuilder](#pxresponsivebuilder)
  - [PxResponsiveValue](#pxresponsivevalue)
  - [PxResponsiveVisibility](#pxresponsivevisibility)
  - [PxResponsivePadding](#pxresponsivepadding)
  - [PxResponsiveGrid](#pxresponsivegrid)
  - [AnimatedPxResponsiveBuilder](#animatedpxresponsivebuilder)
  - [PxResponsiveDebug](#pxresponsivedebug)
- [Platform Detection](#platform-detection)
- [Configuration Options](#configuration-options)
- [Best Practices](#best-practices)
- [Ultra-Wide Screen Support](#ultra-wide-screen-support)
- [Complete Example](#complete-example)
- [WASM Support](#wasm-support)
- [License](#license)

---

## Features

- 🎯 **Tri-Tier Scaling** — Automatically switches between mobile, tablet, and desktop base designs
- 📐 **Design-to-Code Mapping** — Use exact values from your Figma/XD designs
- 🔒 **Safe Scaling** — Built-in min/max constraints prevent layout breaking
- 📱 **Device Detection** — Simple `isMobile`, `isTablet`, `isDesktop` getters and `BuildContext` extensions
- 🔄 **Orientation Support** — `isLandscape`/`isPortrait` getters, orientation-specific base sizes, `orientationValue<T>()`
- 🛡️ **Safe Area Awareness** — `safeAreaTop`, `safeAreaBottom`, `safeScreenHeight` populated automatically from `MediaQuery`
- 🖥️ **Ultra-Wide Support** — Optional `maxWidth` cap for large displays
- 🧩 **Rich Widget Library** — Responsive builders, visibility, padding, grid, animated transitions
- 🔍 **Debug Overlay** — `PxResponsiveDebug` shows active breakpoint and scale factors at a glance
- 🖥️ **Platform Detection** — `PxPlatformType` enum distinguishes Android, iOS, web, macOS, Windows, Linux
- ✨ **Intuitive API** — Clean extension syntax (`.w`, `.h`, `.sp`, `.r`, `.verticalSpace`, `.horizontalSpace`)
- 🌐 **WASM Compatible** — Pure Dart implementation, works everywhere Flutter runs

---

## Installation

Add `px_responsive` to your `pubspec.yaml`:

```yaml
dependencies:
  px_responsive: ^0.1.0
```

Then run:

```bash
flutter pub get
```

---

## Quick Start

### 1. Wrap Your App

```dart
import 'package:flutter/material.dart';
import 'package:px_responsive/px_responsive.dart';

void main() {
  runApp(
    const PxResponsiveWrapper(
      config: PxResponsiveConfig(
        desktop: Size(1920, 1080),
        tablet: Size(834, 1194),
        mobile: Size(375, 812),
        mobileBreakpoint: 600,
        tabletBreakpoint: 1200,
      ),
      child: MyApp(),
    ),
  );
}
```

### 2. Use Extensions in Your Widgets

```dart
Container(
  width: 200.w,
  height: 150.h,
  padding: EdgeInsets.all(16.r),
  child: Text(
    'Hello World',
    style: TextStyle(fontSize: 18.sp),
  ),
)
```

### 3. Use Spacing Shorthands

```dart
Column(
  children: [
    Text('Title'),
    16.verticalSpace,   // SizedBox(height: 16.h)
    Text('Body'),
  ],
)
```

### 4. Adapt to Device Types

```dart
// Global getters
if (isMobile) return MobileLayout();

// BuildContext extensions
if (context.isDesktop) return DesktopLayout();

// Responsive builder widget
PxResponsiveBuilder(
  mobile: (_) => MobileLayout(),
  tablet: (_) => TabletLayout(),
  desktop: (_) => DesktopLayout(),
)
```

---

## How It Works

### The Scaling Formula

```
result = value × (currentScreenWidth ÷ activeBaseDesignWidth)
```

### Automatic Base Switching

| Screen Width | Active Base | Typical Device |
|---|---|---|
| < 600 px | Mobile (375 × 812) | Phones |
| 600 – 1199 px | Tablet (834 × 1194) | Tablets, small laptops |
| ≥ 1200 px | Desktop (1920 × 1080) | Desktops, large screens |

---

## API Reference

### Core Extensions

| Extension | Description | Use Case |
|---|---|---|
| `.w` | Width scaling | Container widths, horizontal padding |
| `.h` | Height scaling | Container heights, vertical padding |
| `.sp` | Font scaling (tighter max) | Text sizes |
| `.r` | Radius scaling (min of w & h) | Border radius, circular elements |

```dart
Container(
  width: 300.w,
  height: 200.h,
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12.r),
  ),
  child: Text('Hello', style: TextStyle(fontSize: 16.sp)),
)
```

---

### Screen Percentage Extensions

| Extension | Description |
|---|---|
| `.wf` | Percentage of effective screen width |
| `.hf` | Percentage of screen height |

```dart
Container(width: 80.wf, height: 50.hf)
```

---

### Parent-Relative Extensions

Wrap the parent with `PxRelativeSizeProvider` to enable:

| Extension | Description |
|---|---|
| `.wr(context)` | Percentage of parent width |
| `.hr(context)` | Percentage of parent height |

```dart
PxRelativeSizeProvider(
  child: Row(
    children: [
      Container(width: 30.wr(context), child: Sidebar()),
      Container(width: 70.wr(context), child: MainContent()),
    ],
  ),
)
```

---

### Clamping Methods

| Method | Description |
|---|---|
| `.wMin(min)` / `.wMax(max)` / `.wClamp(min, max)` | Width with bounds |
| `.hMin(min)` / `.hMax(max)` / `.hClamp(min, max)` | Height with bounds |
| `.spMin(min)` / `.spMax(max)` / `.spClamp(min, max)` | Font with bounds |
| `.rMin(min)` / `.rMax(max)` / `.rClamp(min, max)` | Radius with bounds |

```dart
width: 200.wClamp(150, 300),   // Between 150 and 300
fontSize: 14.spMin(12),         // At least 12
borderRadius: 8.rMax(16),       // At most 16
```

---

### Spacing Shorthands

```dart
Column(
  children: [
    Text('Section Title'),
    24.verticalSpace,       // SizedBox(height: 24.h)
    Row(
      children: [
        Icon(Icons.home),
        8.horizontalSpace,  // SizedBox(width: 8.w)
        Text('Home'),
      ],
    ),
  ],
)
```

---

### Object Extensions

#### EdgeInsets

| Extension | Description |
|---|---|
| `.w` | All sides × scaleW |
| `.scaled` | Horizontal × scaleW, vertical × scaleH |
| `.r` | All sides × scaleR |

#### Size

| Extension | Description |
|---|---|
| `.scaled` | Width × scaleW, height × scaleH |
| `.w` | Both dimensions × scaleW |
| `.r` | Both dimensions × scaleR |

#### BorderRadius

| Extension | Description |
|---|---|
| `.r` | All corners × scaleR |

---

### TextStyle & Icon Extensions

Scale text styles and icons in one call:

```dart
// TextStyle — scales fontSize, letterSpacing, wordSpacing
Text(
  'Hello',
  style: TextStyle(fontSize: 16, letterSpacing: 0.5).responsive,
)

// Icon — scales size by scaleSp
Icon(Icons.home).responsive

// Or with a custom base size:
Icon(Icons.star, size: 32).responsive
```

---

### Global Getters

| Getter | Type | Description |
|---|---|---|
| `isMobile` | `bool` | True if width < mobileBreakpoint |
| `isTablet` | `bool` | True if between breakpoints |
| `isDesktop` | `bool` | True if width ≥ tabletBreakpoint |
| `deviceType` | `PxDeviceType` | `.mobile` / `.tablet` / `.desktop` |
| `screenWidth` | `double` | Actual screen width |
| `screenHeight` | `double` | Actual screen height |
| `effectiveWidth` | `double` | Width used for scaling (respects maxWidth) |
| `isLandscape` | `bool` | True if width > height |
| `isPortrait` | `bool` | True if height ≥ width |
| `orientation` | `PxOrientation` | `.portrait` / `.landscape` |

---

### Global Functions

```dart
// Device-type value picker
int columns = responsiveValue(mobile: 1, tablet: 2, desktop: 4);

// Orientation value picker
double padding = orientationValue(portrait: 16.0, landscape: 24.0);
```

---

### BuildContext Extensions

Access responsive information directly from any `BuildContext`:

```dart
Widget build(BuildContext context) {
  return Padding(
    padding: EdgeInsets.all(context.isMobile ? 12.w : 24.w),
    child: Text(
      '${context.deviceType.name} — '
      '${context.screenWidth.toStringAsFixed(0)} × '
      '${context.screenHeight.toStringAsFixed(0)}',
    ),
  );
}
```

| Extension | Type |
|---|---|
| `context.responsive` | `PxResponsive` |
| `context.isMobile` | `bool` |
| `context.isTablet` | `bool` |
| `context.isDesktop` | `bool` |
| `context.deviceType` | `PxDeviceType` |
| `context.screenWidth` | `double` |
| `context.screenHeight` | `double` |
| `context.isLandscape` | `bool` |
| `context.isPortrait` | `bool` |

---

## Orientation Support

Detect and react to device rotation anywhere in your widget tree.

```dart
// Global getters
if (isLandscape) return LandscapeLayout();

// Global function
double padding = orientationValue(portrait: 16.0, landscape: 24.0);

// PxResponsive instance
PxOrientation current = PxResponsive().orientation;

// BuildContext
if (context.isPortrait) return PortraitCard();
```

### Landscape-Specific Design Sizes

Provide alternate base sizes for landscape so scaling matches your landscape Figma frames:

```dart
PxResponsiveWrapper(
  config: const PxResponsiveConfig(
    mobile: Size(375, 812),
    mobileLandscape: Size(812, 375),   // used when phone rotates
    tablet: Size(834, 1194),
    tabletLandscape: Size(1194, 834),
  ),
  child: const MyApp(),
)
```

---

## Safe Area Awareness

Access system UI insets without calling `MediaQuery` manually:

```dart
final r = PxResponsive();

print(r.safeAreaTop);       // status bar / notch
print(r.safeAreaBottom);    // home indicator
print(r.safeScreenHeight);  // screenHeight - top - bottom

// Safe padding is captured automatically by PxResponsiveWrapper.
// For explicit control, pass it in init():
PxResponsive().init(
  constraints: constraints,
  config: config,
  safeAreaPadding: MediaQuery.paddingOf(context),
);
```

---

## Responsive Widgets

### PxResponsiveWrapper

Initialises the responsive singleton using `LayoutBuilder`. Place it above `MaterialApp`/`CupertinoApp`.

```dart
PxResponsiveWrapper(
  config: const PxResponsiveConfig(maxWidth: 1920),
  child: const MyApp(),
)
```

---

### PxResponsiveMediaQueryWrapper

Alternative wrapper that reads screen size from `MediaQuery` instead of `LayoutBuilder`. Use when the wrapper is inside a constrained subtree (e.g., a `Dialog`).

```dart
PxResponsiveMediaQueryWrapper(
  config: const PxResponsiveConfig(),
  child: const MyWidget(),
)
```

---

### PxResponsiveBuilder

Build completely different widget trees per device type.

```dart
PxResponsiveBuilder(
  mobile: (_) => const MobileLayout(),
  tablet: (_) => const TabletLayout(),
  desktop: (_) => const DesktopLayout(),
)
```

Fallback chain: desktop → tablet → mobile (if a builder is omitted).

---

### PxResponsiveValue

Provide different typed values and build with them.

```dart
PxResponsiveValue<int>(
  mobile: 1,
  tablet: 2,
  desktop: 4,
  builder: (context, columns) => GridView.count(
    crossAxisCount: columns,
    children: items,
  ),
)
```

---

### PxResponsiveVisibility

Show or hide widgets based on device type.

```dart
// Only on desktop
PxResponsiveVisibility.desktop(child: Sidebar())

// Mobile and tablet
PxResponsiveVisibility.tabletDown(child: CompactHeader())

// With replacement and state preservation
PxResponsiveVisibility.tabletUp(
  replacement: const MenuButton(),
  maintainState: true,
  child: SideNavigation(),
)
```

| Constructor | Mobile | Tablet | Desktop |
|---|---|---|---|
| `.mobile()` | ✅ | ❌ | ❌ |
| `.tablet()` | ❌ | ✅ | ❌ |
| `.desktop()` | ❌ | ❌ | ✅ |
| `.tabletUp()` | ❌ | ✅ | ✅ |
| `.tabletDown()` | ✅ | ✅ | ❌ |

---

### PxResponsivePadding

Apply device-specific padding with optional auto-scaling.

```dart
PxResponsivePadding(
  mobile: const EdgeInsets.all(12),
  tablet: const EdgeInsets.all(20),
  desktop: const EdgeInsets.all(32),
  scale: true,   // additionally applies .scaled
  child: const MyContent(),
)
```

---

### PxResponsiveGrid

A `GridView` with automatic column count selection.

```dart
PxResponsiveGrid(
  mobileColumns: 1,
  tabletColumns: 2,
  desktopColumns: 4,
  spacing: 16.r,
  childAspectRatio: 3 / 4,
  children: productCards,
)
```

| Parameter | Description |
|---|---|
| `mobileColumns` | Columns on mobile (required) |
| `tabletColumns` | Columns on tablet (falls back to mobile) |
| `desktopColumns` | Columns on desktop (falls back to tablet) |
| `spacing` | Cross-axis spacing |
| `runSpacing` | Main-axis spacing (defaults to `spacing`) |
| `childAspectRatio` | Width / height ratio of each item |
| `shrinkWrap` | Set `true` inside non-scrollable parents |

---

### AnimatedPxResponsiveBuilder

Smoothly transitions between layouts when the device type changes (e.g., desktop window resize).

```dart
AnimatedPxResponsiveBuilder(
  duration: const Duration(milliseconds: 300),
  switchInCurve: Curves.easeOut,
  mobile: (_) => const MobileLayout(),
  tablet: (_) => const TabletLayout(),
  desktop: (_) => const DesktopLayout(),
)
```

Uses `AnimatedSwitcher` with `FadeTransition` by default. Pass a custom `transitionBuilder` for other effects.

---

### PxResponsiveDebug

Overlay that shows current breakpoint, scale factors, and orientation during development.

```dart
PxResponsiveWrapper(
  config: config,
  child: PxResponsiveDebug(
    enabled: kDebugMode,   // remove in release
    child: const MyApp(),
  ),
)
```

The overlay is positioned top-right and shows:

```
device : mobile
screen : 375×812
orient : portrait
base   : 375×812
scaleW : 1.000
scaleH : 1.000
scaleSp: 1.000
scaleR : 1.000
effW   : 375
```

---

## Platform Detection

Detect the underlying OS independently of screen width:

```dart
import 'package:px_responsive/px_responsive.dart';

// Top-level getters
if (isNativeMobile) requestCameraPermission();
if (isNativeDesktop) showMenuBar();
if (isPlatformWeb) openBrowserLink(url);

// Full enum
switch (platformType) {
  case PxPlatformType.ios:
    return const CupertinoButton(child: Text('OK'), onPressed: null);
  case PxPlatformType.android:
    return ElevatedButton(onPressed: null, child: const Text('OK'));
  default:
    return TextButton(onPressed: null, child: const Text('OK'));
}
```

| Getter | Description |
|---|---|
| `platformType` | `PxPlatformType` enum value |
| `isNativeMobile` | `true` for Android or iOS |
| `isNativeDesktop` | `true` for macOS, Windows, or Linux |
| `isPlatformWeb` | `true` when running in a browser |

---

## Configuration Options

### PxResponsiveConfig

```dart
const PxResponsiveConfig({
  // Portrait design sizes (required baselines)
  Size desktop = const Size(1920, 1080),
  Size tablet  = const Size(834, 1194),
  Size mobile  = const Size(375, 812),

  // Landscape design sizes (optional — activates on rotation)
  Size? desktopLandscape,
  Size? tabletLandscape,
  Size? mobileLandscape,

  // Breakpoints
  double mobileBreakpoint = 600,    // below this → mobile
  double tabletBreakpoint = 1200,   // above this → desktop

  // Ultra-wide cap
  double? maxWidth,                 // null = no cap

  // Scaling constraints
  double? minScaleFactor = 0.5,
  double? maxScaleFactor = 2.0,
  double? maxTextScaleFactor = 1.5,
})
```

### Common Configurations

#### Standard Setup

```dart
const PxResponsiveConfig(
  desktop: Size(1440, 900),
  tablet: Size(768, 1024),
  mobile: Size(375, 812),
)
```

#### With Landscape Support

```dart
const PxResponsiveConfig(
  mobile: Size(375, 812),
  mobileLandscape: Size(812, 375),
  tablet: Size(834, 1194),
  tabletLandscape: Size(1194, 834),
)
```

#### With Ultra-Wide Cap

```dart
const PxResponsiveConfig(
  desktop: Size(1920, 1080),
  maxWidth: 1920,
)
```

#### Conservative Scaling

```dart
const PxResponsiveConfig(
  minScaleFactor: 0.8,
  maxScaleFactor: 1.5,
  maxTextScaleFactor: 1.2,
)
```

---

## Best Practices

### 1. Match Your Design Tool

```dart
// If your Figma mobile frame is 390×844
mobile: Size(390, 844),
desktop: Size(1440, 900),
```

### 2. Use the Right Extension

| Scenario | Extension |
|---|---|
| Container width | `.w` |
| Container height | `.h` |
| Font size | `.sp` |
| Border radius / circles | `.r` |
| Vertical gap | `.verticalSpace` |
| Horizontal gap | `.horizontalSpace` |

### 3. Clamp Critical Values

```dart
height: 48.hMin(44),           // Always tappable
fontSize: 14.spMin(12),        // Always readable
borderRadius: 8.rClamp(4, 16), // Stays proportional
```

### 4. Use the Debug Overlay During Development

```dart
PxResponsiveDebug(
  enabled: kDebugMode,
  child: MyApp(),
)
```

---

## Ultra-Wide Screen Support

Use `maxWidth` to prevent UI from stretching on 4K/ultrawide monitors:

```
Without maxWidth: 3840 px → scale 2.0 × → 200 px button becomes 400 px
With maxWidth 1920: 3840 px → effective 1920 px → scale 1.0 × → 200 px
```

```dart
PxResponsiveWrapper(
  config: const PxResponsiveConfig(
    desktop: Size(1920, 1080),
    maxWidth: 1920,
  ),
  child: MyApp(),
)
```

---

## Complete Example

```dart
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:px_responsive/px_responsive.dart';

void main() {
  runApp(
    const PxResponsiveWrapper(
      config: PxResponsiveConfig(
        mobileLandscape: Size(812, 375),
        maxWidth: 1920,
      ),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: PxResponsiveDebug(
        enabled: kDebugMode,
        child: const HomePage(),
      ),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My App', style: TextStyle(fontSize: 20.sp)),
        leading: PxResponsiveVisibility.mobile(
          child: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
        ),
      ),
      body: Row(
        children: [
          PxResponsiveVisibility.desktop(
            child: Container(
              width: 240.w,
              color: Colors.grey[100],
              child: const Center(child: Text('Sidebar')),
            ),
          ),
          Expanded(
            child: PxResponsivePadding(
              mobile: const EdgeInsets.all(12),
              desktop: const EdgeInsets.all(32),
              scale: true,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hello, ${context.deviceType.name}!',
                    style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                  ),
                  16.verticalSpace,
                  Text(
                    orientationValue(
                      portrait: 'Portrait mode',
                      landscape: 'Landscape mode',
                    ),
                    style: TextStyle(fontSize: 14.sp),
                  ),
                  16.verticalSpace,
                  PxResponsiveGrid(
                    mobileColumns: 2,
                    tabletColumns: 3,
                    desktopColumns: 4,
                    spacing: 12.r,
                    shrinkWrap: true,
                    children: List.generate(
                      8,
                      (i) => Card(
                        child: Center(
                          child: Text('Item $i', style: TextStyle(fontSize: 14.sp)),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: PxResponsiveVisibility.mobile(
        child: BottomNavigationBar(
          items: const [
            BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
            BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
            BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
          ],
        ),
      ),
    );
  }
}
```

---

## WASM Support

This package is fully compatible with Flutter's WebAssembly (WASM) compilation target. It uses only pure Dart code and standard Flutter widgets with no platform-specific plugins.

```bash
flutter build web --wasm
```

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 🤝 About the Author

<div align="center">
<a href="https://github.com/IbrahimElmourchidi">
<img src="https://github.com/IbrahimElmourchidi.png" width="80" alt="Ibrahim El Mourchidi" style="border-radius: 50%;">
</a>
<h3>Ibrahim El Mourchidi</h3>
<p>Flutter & Firebase Developer • Cairo, Egypt</p>
<p>
<a href="https://github.com/IbrahimElmourchidi">
<img src="https://img.shields.io/github/followers/IbrahimElmourchidi?label=Follow&style=social" alt="GitHub Follow">
</a>
<a href="mailto:ibrahimelmourchidi@gmail.com">
<img src="https://img.shields.io/badge/Email-D14836?logo=gmail&logoColor=white" alt="Email">
</a>
<a href="https://www.linkedin.com/in/IbrahimElmourchidi">
<img src="https://img.shields.io/badge/LinkedIn-Profile-blue?style=flat&logo=linkedin" alt="LinkedIn Profile">
</a>
</p>
</div>

---

## 👥 Contributors

We appreciate all contributions to this project!

<a href="https://github.com/IbrahimElmourchidi/px_responsive/graphs/contributors">
  <img src="https://contrib.rocks/image?repo=IbrahimElmourchidi/px_responsive" />
</a>

---

## Support

If you find this package helpful, please give it a ⭐ on [GitHub](https://github.com/IbrahimElmourchidi/px_responsive)!

For bugs or feature requests, please [open an issue](https://github.com/IbrahimElmourchidi/px_responsive/issues).
