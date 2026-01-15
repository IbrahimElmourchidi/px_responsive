# px_responsive

A powerful tri-tier responsive design system for Flutter that automatically scales your UI across mobile, tablet, and desktop platforms based on your Figma/XD design specifications.

[![pub package](https://img.shields.io/pub/v/px_responsive.svg)](https://pub.dev/packages/px_responsive)
[![License: BSD-3](https://img.shields.io/badge/License-BSD3-blue.svg)](https://opensource.org/licenses/BSD-3-Clause)

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
  - [Object Extensions](#object-extensions)
  - [Global Getters](#global-getters)
  - [Global Functions](#global-functions)
- [Responsive Widgets](#responsive-widgets)
  - [PxResponsiveBuilder](#pxresponsivebuilder)
  - [PxResponsiveValue](#pxresponsivevalue)
  - [PxResponsiveVisibility](#pxresponsivevisibility)
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
- 📱 **Device Detection** — Simple `isMobile`, `isTablet`, `isDesktop` getters
- 🖥️ **Ultra-Wide Support** — Optional `maxWidth` cap for large displays
- 🧩 **Rich Widget Library** — Responsive builders, visibility controls, and value providers
- ✨ **Intuitive API** — Clean extension syntax (`.w`, `.h`, `.sp`, `.r`)
- 🌐 **WASM Compatible** — Pure Dart implementation, works everywhere Flutter runs

---

## Installation

Add `px_responsive` to your `pubspec.yaml`:

```yaml
dependencies:
  px_responsive: ^0.0.1
```

Then run:

```bash
flutter pub get
```

---

## Quick Start

### 1. Wrap Your App

Wrap your root widget with `PxResponsiveWrapper` and provide your design specifications:

```dart
import 'package:flutter/material.dart';
import 'package:px_responsive/px_responsive.dart';

void main() {
  runApp(
    PxResponsiveWrapper(
      config: const PxResponsiveConfig(
        // Your design tool's artboard sizes
        desktop: Size(1920, 1080),
        tablet: Size(834, 1194),
        mobile: Size(375, 812),
        
        // Breakpoints (when to switch layouts)
        mobileBreakpoint: 600,
        tabletBreakpoint: 1200,
      ),
      child: const MyApp(),
    ),
  );
}
```

### 2. Use Extensions in Your Widgets

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200.w,              // Scaled width
      height: 150.h,             // Scaled height
      padding: EdgeInsets.all(16.r),  // Scaled padding
      child: Text(
        'Hello World',
        style: TextStyle(fontSize: 18.sp),  // Scaled font
      ),
    );
  }
}
```

### 3. Adapt to Device Types

```dart
Widget build(BuildContext context) {
  if (isMobile) {
    return MobileLayout();
  } else if (isTablet) {
    return TabletLayout();
  } else {
    return DesktopLayout();
  }
}
```

---

## How It Works

### The Scaling Formula

When you use `200.w`, the package calculates:

```
result = 200 × (currentScreenWidth ÷ activeBaseDesignWidth)
```

### Automatic Base Switching

The package automatically selects the appropriate base design based on screen width:

| Screen Width | Active Base | Example |
|--------------|-------------|---------|
| < 600px | Mobile (375×812) | Phones |
| 600px – 1199px | Tablet (834×1194) | Tablets, small laptops |
| ≥ 1200px | Desktop (1920×1080) | Desktops, large screens |

### Visual Example

```
Mobile Design (375px wide)          Your Phone (390px wide)
┌─────────────────┐                 ┌─────────────────┐
│  Button: 100px  │      →          │  Button: 104px  │
│  Font: 16px     │   Scaling       │  Font: 16.6px   │
└─────────────────┘                 └─────────────────┘

Scale Factor: 390 ÷ 375 = 1.04
```

---

## API Reference

### Core Extensions

These are the primary extensions you'll use most often.

| Extension | Description | Use Case |
|-----------|-------------|----------|
| `.w` | Width scaling | Container widths, horizontal padding/margins |
| `.h` | Height scaling | Container heights, vertical padding/margins |
| `.sp` | Font scaling | Text sizes (has tighter max constraint) |
| `.r` | Radius scaling | Border radius, circular elements |

```dart
Container(
  width: 300.w,                    // Scales with screen width
  height: 200.h,                   // Scales with screen height
  decoration: BoxDecoration(
    borderRadius: BorderRadius.circular(12.r),  // Uniform scaling
  ),
  child: Text(
    'Responsive Text',
    style: TextStyle(fontSize: 16.sp),  // Won't get too large
  ),
)
```

#### When to Use Each

| Scenario | Recommended Extension |
|----------|----------------------|
| Container/Card width | `.w` |
| Container/Card height | `.h` |
| Horizontal padding | `.w` |
| Vertical padding | `.h` |
| Symmetric padding | `.r` or `.w` |
| Font sizes | `.sp` |
| Icon sizes | `.sp` or `.r` |
| Border radius | `.r` |
| Avatar/Circle dimensions | `.r` |
| Spacing between items | `.w` (horizontal) or `.h` (vertical) |

---

### Screen Percentage Extensions

Use these when you want a percentage of the full screen.

| Extension | Description | Example |
|-----------|-------------|---------|
| `.wf` | Percentage of screen width | `50.wf` = 50% of width |
| `.hf` | Percentage of screen height | `25.hf` = 25% of height |

```dart
Container(
  width: 80.wf,   // 80% of screen width
  height: 50.hf,  // 50% of screen height
  child: Text('Full-width card'),
)
```

#### Best Use Cases

- Full-width containers: `100.wf`
- Half-screen layouts: `50.wf`
- Modal dialogs: `90.wf` width, `80.hf` height
- Hero sections: `100.wf` width, `60.hf` height

---

### Parent-Relative Extensions

Use these when you need sizing relative to a parent widget, not the screen.

| Extension | Description |
|-----------|-------------|
| `.wr(context)` | Percentage of parent width |
| `.hr(context)` | Percentage of parent height |

**Setup Required:** Wrap the parent with `PxRelativeSizeProvider`:

```dart
PxRelativeSizeProvider(
  child: Row(
    children: [
      Container(
        width: 30.wr(context),  // 30% of Row's width
        child: Sidebar(),
      ),
      Container(
        width: 70.wr(context),  // 70% of Row's width
        child: MainContent(),
      ),
    ],
  ),
)
```

#### Best Use Cases

- Split layouts within a container
- Proportional grid items
- Nested responsive layouts

---

### Clamping Methods

Prevent values from going too small or too large.

| Method | Description | Example |
|--------|-------------|---------|
| `.wMin(min)` | Width with minimum | `200.wMin(150)` — at least 150 |
| `.wMax(max)` | Width with maximum | `200.wMax(300)` — at most 300 |
| `.wClamp(min, max)` | Width within range | `200.wClamp(150, 300)` |
| `.hMin(min)` | Height with minimum | `100.hMin(80)` |
| `.hMax(max)` | Height with maximum | `100.hMax(120)` |
| `.hClamp(min, max)` | Height within range | `100.hClamp(80, 120)` |
| `.spMin(min)` | Font with minimum | `14.spMin(12)` |
| `.spMax(max)` | Font with maximum | `24.spMax(32)` |
| `.spClamp(min, max)` | Font within range | `16.spClamp(14, 20)` |

```dart
Container(
  // Width scales but never below 200 or above 500
  width: 300.wClamp(200, 500),
  
  child: Text(
    'Readable Text',
    // Font scales but stays between 14 and 22
    style: TextStyle(fontSize: 18.spClamp(14, 22)),
  ),
)
```

#### Best Use Cases

- Buttons that shouldn't be too small on tiny screens
- Text that must remain readable
- Images that shouldn't exceed a certain size
- Cards with minimum touch targets

---

### Object Extensions

Scale entire objects at once.

#### EdgeInsets Extensions

| Extension | Description |
|-----------|-------------|
| `.w` | All sides scaled by width factor |
| `.scaled` | Horizontal by width, vertical by height |
| `.r` | All sides scaled by radius factor |

```dart
// All sides scale uniformly
padding: EdgeInsets.all(16).w

// Horizontal and vertical scale independently
padding: EdgeInsets.symmetric(
  horizontal: 20,
  vertical: 16,
).scaled

// Uniform scaling for symmetric padding
margin: EdgeInsets.all(12).r
```

#### Size Extensions

| Extension | Description |
|-----------|-------------|
| `.scaled` | Width by scaleW, height by scaleH |
| `.w` | Both dimensions by scaleW |
| `.r` | Both dimensions by scaleR (uniform) |

```dart
// Aspect-ratio aware scaling
Size imageSize = Size(400, 300).scaled;

// Square that stays square
Size avatarSize = Size(80, 80).r;
```

#### BorderRadius Extensions

| Extension | Description |
|-----------|-------------|
| `.r` | All corners scaled by radius factor |

```dart
decoration: BoxDecoration(
  borderRadius: BorderRadius.circular(16).r,
)

// Or with different corners
borderRadius: BorderRadius.only(
  topLeft: Radius.circular(20),
  topRight: Radius.circular(20),
).r
```

---

### Global Getters

Quick access to device information without calling `PxResponsive()`.

| Getter | Type | Description |
|--------|------|-------------|
| `isMobile` | `bool` | True if width < mobileBreakpoint |
| `isTablet` | `bool` | True if between breakpoints |
| `isDesktop` | `bool` | True if width ≥ tabletBreakpoint |
| `deviceType` | `PxDeviceType` | Enum: `.mobile`, `.tablet`, `.desktop` |
| `screenWidth` | `double` | Actual screen width |
| `screenHeight` | `double` | Actual screen height |
| `effectiveWidth` | `double` | Width used for scaling (respects maxWidth) |

```dart
// Simple boolean checks
if (isMobile) {
  return CompactView();
}

// Switch on device type
switch (deviceType) {
  case PxDeviceType.mobile:
    return MobileLayout();
  case PxDeviceType.tablet:
    return TabletLayout();
  case PxDeviceType.desktop:
    return DesktopLayout();
}

// Use dimensions directly
final isLandscape = screenWidth > screenHeight;
```

---

### Global Functions

#### responsiveValue

Returns different values based on device type.

```dart
T responsiveValue<T>({
  required T mobile,
  T? tablet,
  T? desktop,
})
```

```dart
// Different column counts
int columns = responsiveValue(
  mobile: 1,
  tablet: 2,
  desktop: 4,
);

// Different padding
double padding = responsiveValue(
  mobile: 16.0,
  tablet: 24.0,
  desktop: 32.0,
);

// Different widgets
Widget icon = responsiveValue(
  mobile: Icon(Icons.menu),
  desktop: Icon(Icons.dashboard),
);
```

**Fallback Behavior:**
- If `tablet` is null → uses `mobile`
- If `desktop` is null → uses `tablet` (or `mobile` if tablet is also null)

---

## Responsive Widgets

### PxResponsiveBuilder

Build completely different widget trees for each device type.

```dart
PxResponsiveBuilder(
  mobile: (context) => MobileLayout(),
  tablet: (context) => TabletLayout(),
  desktop: (context) => DesktopLayout(),
)
```

**When to Use:**
- Completely different layouts per device
- Different navigation patterns (drawer vs sidebar)
- Different component hierarchies

```dart
// Navigation example
PxResponsiveBuilder(
  mobile: (context) => Scaffold(
    drawer: NavigationDrawer(),
    body: Content(),
  ),
  desktop: (context) => Row(
    children: [
      SideNavigation(),
      Expanded(child: Content()),
    ],
  ),
)
```

---

### PxResponsiveValue

Provide different values and build with them.

```dart
PxResponsiveValue<int>(
  mobile: 1,
  tablet: 2,
  desktop: 4,
  builder: (context, columnCount) {
    return GridView.count(
      crossAxisCount: columnCount,
      children: items,
    );
  },
)
```

**When to Use:**
- Same widget structure, different parameters
- Grid layouts with varying columns
- Dynamic spacing or sizing

```dart
// Dynamic grid
PxResponsiveValue<int>(
  mobile: 2,
  tablet: 3,
  desktop: 5,
  builder: (context, columns) => GridView.builder(
    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: columns,
    ),
    itemBuilder: (context, index) => ProductCard(products[index]),
  ),
)
```

---

### PxResponsiveVisibility

Show or hide widgets based on device type.

#### Default Constructor

```dart
PxResponsiveVisibility(
  visibleOnMobile: false,
  visibleOnTablet: true,
  visibleOnDesktop: true,
  child: Sidebar(),
)
```

#### Named Constructors

| Constructor | Visible On |
|-------------|------------|
| `.mobile()` | Mobile only |
| `.tablet()` | Tablet only |
| `.desktop()` | Desktop only |
| `.tabletUp()` | Tablet + Desktop |
| `.tabletDown()` | Mobile + Tablet |

```dart
// Sidebar only on desktop
PxResponsiveVisibility.desktop(
  child: Sidebar(),
)

// Mobile menu button
PxResponsiveVisibility.mobile(
  child: IconButton(
    icon: Icon(Icons.menu),
    onPressed: openDrawer,
  ),
)

// Show on tablet and up
PxResponsiveVisibility.tabletUp(
  child: ExtendedNavigation(),
  replacement: CompactNavigation(), // Shown when hidden
)
```

#### Options

| Property | Description |
|----------|-------------|
| `replacement` | Widget shown when child is hidden |
| `maintainState` | Keep child's state when hidden (uses Offstage) |

```dart
PxResponsiveVisibility.desktop(
  maintainState: true,  // Keep sidebar state when switching to tablet
  child: Sidebar(),
  replacement: CollapsedSidebar(),
)
```

**When to Use:**
- Hiding navigation elements on mobile
- Showing/hiding sidebars
- Conditional feature visibility
- Progressive disclosure of UI elements

---

## Configuration Options

### PxResponsiveConfig

```dart
const PxResponsiveConfig({
  // Base design sizes from your design tool
  Size desktop = const Size(1920, 1080),
  Size tablet = const Size(834, 1194),
  Size mobile = const Size(375, 812),
  
  // Breakpoints
  double mobileBreakpoint = 600,    // Below this = mobile
  double tabletBreakpoint = 1200,   // Above this = desktop
  
  // Scaling constraints
  double? maxWidth,                 // Cap width for ultra-wide screens
  double? minScaleFactor = 0.5,     // Elements won't shrink below 50%
  double? maxScaleFactor = 2.0,     // Elements won't grow beyond 200%
  double? maxTextScaleFactor = 1.5, // Text won't grow beyond 150%
})
```

### Common Design Sizes

| Platform | Common Sizes |
|----------|--------------|
| Mobile | 375×812 (iPhone X), 360×640 (Android), 414×896 (iPhone Plus) |
| Tablet | 834×1194 (iPad Pro 11"), 768×1024 (iPad), 1024×768 (Landscape) |
| Desktop | 1920×1080 (Full HD), 1440×900 (MacBook), 1366×768 (Laptop) |

### Configuration Examples

#### Standard Setup

```dart
PxResponsiveConfig(
  desktop: Size(1440, 900),
  tablet: Size(768, 1024),
  mobile: Size(375, 812),
)
```

#### With Ultra-Wide Support

```dart
PxResponsiveConfig(
  desktop: Size(1920, 1080),
  tablet: Size(834, 1194),
  mobile: Size(375, 812),
  maxWidth: 1920,  // Content won't stretch beyond 1920px
)
```

#### Conservative Scaling

```dart
PxResponsiveConfig(
  desktop: Size(1920, 1080),
  tablet: Size(834, 1194),
  mobile: Size(375, 812),
  minScaleFactor: 0.8,      // Don't shrink too much
  maxScaleFactor: 1.5,      // Don't grow too much
  maxTextScaleFactor: 1.2,  // Keep text readable
)
```

---

## Best Practices

### 1. Match Your Design Tool

Always use the exact artboard sizes from your design tool:

```dart
// If your Figma mobile frame is 390×844
mobile: Size(390, 844),

// If your XD desktop artboard is 1440×900
desktop: Size(1440, 900),
```

### 2. Use Appropriate Extensions

```dart
// ✅ Good
width: 200.w,           // Horizontal → use .w
height: 100.h,          // Vertical → use .h
fontSize: 16.sp,        // Text → use .sp
borderRadius: 12.r,     // Radius → use .r

// ❌ Avoid
width: 200.h,           // Don't use .h for width
fontSize: 16.w,         // Don't use .w for fonts
```

### 3. Clamp Critical Values

```dart
// Ensure buttons are always tappable (min 44px)
height: 48.hMin(44),

// Ensure text is always readable
fontSize: 14.spMin(12),

// Prevent images from getting too large
width: 400.wMax(500),
```

### 4. Use Device-Specific Values

```dart
// Different spacing per device
padding: EdgeInsets.all(
  responsiveValue(mobile: 12, tablet: 16, desktop: 24).w
),

// Different layouts
crossAxisCount: responsiveValue(mobile: 2, tablet: 3, desktop: 4),
```

### 5. Combine Extensions Thoughtfully

```dart
// Responsive padding with scaling
padding: EdgeInsets.symmetric(
  horizontal: responsiveValue(mobile: 16, tablet: 24, desktop: 32).w,
  vertical: responsiveValue(mobile: 12, tablet: 16, desktop: 20).h,
),
```

---

## Ultra-Wide Screen Support

On ultra-wide monitors (3840px+), UI elements can become excessively large. Use `maxWidth` to cap scaling:

### Without maxWidth

```
Screen: 3840px → Scale: 3840/1920 = 2.0×
A 200px button becomes 400px (too large!)
```

### With maxWidth: 1920

```
Screen: 3840px → Effective: 1920px → Scale: 1.0×
A 200px button stays 200px (centered on screen)
```

### Implementation

```dart
PxResponsiveWrapper(
  config: PxResponsiveConfig(
    desktop: Size(1920, 1080),
    maxWidth: 1920,  // ← Add this
  ),
  child: MyApp(),
)
```

### Centering Content

When using `maxWidth`, center your content for the best appearance:

```dart
Scaffold(
  body: Center(
    child: ConstrainedBox(
      constraints: BoxConstraints(maxWidth: 1920),
      child: YourContent(),
    ),
  ),
)
```

---

## Complete Example

```dart
import 'package:flutter/material.dart';
import 'package:px_responsive/px_responsive.dart';

void main() {
  runApp(
    PxResponsiveWrapper(
      config: const PxResponsiveConfig(
        desktop: Size(1920, 1080),
        tablet: Size(834, 1194),
        mobile: Size(375, 812),
        maxWidth: 1920,
      ),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'px_responsive Demo',
          style: TextStyle(fontSize: 20.sp),
        ),
        // Show menu button only on mobile
        leading: PxResponsiveVisibility.mobile(
          child: IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {},
          ),
        ),
      ),
      body: Row(
        children: [
          // Sidebar only on desktop
          PxResponsiveVisibility.desktop(
            child: Container(
              width: 250.w,
              color: Colors.grey[200],
              child: const Center(child: Text('Sidebar')),
            ),
          ),
          
          // Main content
          Expanded(
            child: Padding(
              padding: EdgeInsets.all(
                responsiveValue(mobile: 16, tablet: 24, desktop: 32).w,
              ),
              child: PxResponsiveValue<int>(
                mobile: 1,
                tablet: 2,
                desktop: 3,
                builder: (context, columns) {
                  return GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      spacing: 16.w,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: 9,
                    itemBuilder: (context, index) => Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.star, size: 40.sp),
                            SizedBox(height: 8.h),
                            Text(
                              'Item $index',
                              style: TextStyle(fontSize: 16.sp),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      
      // Bottom navigation only on mobile
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

This package is fully compatible with Flutter's WebAssembly (WASM) compilation target. It uses only:

- Pure Dart code
- Standard Flutter widgets
- No platform-specific plugins

Simply compile your Flutter web app to WASM as usual:

```bash
flutter build web --wasm
```

---

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

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