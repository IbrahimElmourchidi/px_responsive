# px_responsive

[![pub package](https://img.shields.io/pub/v/px_responsive.svg)](https://pub.dev/packages/px_responsive)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

A powerful tri-tier responsive design system for Flutter. Automatically scales UI elements across **mobile**, **tablet**, and **desktop** based on your Figma/XD design specifications.

## ✨ Features

- 🎯 **Design-Driven Scaling**: Match your Figma/XD artboard sizes exactly
- 📱 **Tri-Tier Support**: Separate base designs for mobile, tablet, and desktop
- 🔄 **Automatic Switching**: Seamlessly transitions between design bases at breakpoints
- 🛡️ **Safety Clamping**: Prevents UI from breaking on extreme screen sizes
- 📝 **Simple API**: Just use `.w`, `.h`, `.sp`, `.r` extensions
- 📐 **Percentage Sizing**: `.wf`, `.hf` for window percentage, `.wr()`, `.hr()` for parent percentage
- 🏗️ **Builder Widgets**: Create completely different layouts per device type

## 📦 Installation

```yaml
dependencies:
  px_responsive: ^0.0.1

```

## 🚀 Getting Started

### 1. Wrap Your App

```dart
import 'package:px_responsive/px_responsive.dart';

void main() {
  runApp(
    PxResponsiveWrapper(
      config: const PxResponsiveConfig(
        desktop: Size(1920, 1080),  // Your Figma desktop size
        tablet: Size(834, 1194),    // Your Figma tablet size
        mobile: Size(375, 812),     // Your Figma mobile size
      ),
      child: const MyApp(),
    ),
  );
}

```

### 2. Use the Extensions

```dart
Container(
  width: 200.w,   // Scaled width
  height: 100.h,  // Scaled height
  child: Text(
    'Hello',
    style: TextStyle(fontSize: 16.sp),
  ),
)

```

## 📐 Extension Reference

| Extension | Description |
| --- | --- |
| `.w` | Width scaled by design ratio |
| `.h` | Height scaled by design ratio |
| `.sp` | Font size (with tighter max) |
| `.r` | Radius using min(scaleW, scaleH) |
| `.wf` | Percentage of window width |
| `.hf` | Percentage of window height |
| `.wr(context)` | Percentage of parent width |
| `.hr(context)` | Percentage of parent height |

## 🎯 responsiveValue() - Different Values Per Device

Instead of verbose ternary operators:

```dart
// ❌ Old way
width: responsive.isDesktop ? 200.w : responsive.isTablet ? 160.w : 120.w

// ✅ New way
width: responsiveValue(mobile: 120.w, tablet: 160.w, desktop: 200.w)

```

Works with any type:

```dart
// Different colors per device
color: responsiveValue(
  mobile: Colors.red,
  tablet: Colors.orange,
  desktop: Colors.green,
)

// Optional fallbacks (tablet uses mobile if not specified)
padding: responsiveValue(mobile: 16.w, desktop: 32.w)

```

## 📐 Percentage Sizing

### Window Percentage (`.wf`, `.hf`)

```dart
Container(
  width: 50.wf,   // 50% of screen width
  height: 25.hf,  // 25% of screen height
)

```

### Parent Percentage (`.wr()`, `.hr()`)

Requires `PXReselativeSizeProvider` wrapper:

```dart
Container(
  width: 400,
  height: 300,
  child: PXReselativeSizeProvider(
    child: Builder(
      builder: (context) => Container(
        width: 50.wr(context),  // 200px (50% of 400)
        height: 25.hr(context), // 75px (25% of 300)
      ),
    ),
  ),
)

```

## 🏗️ Responsive Builders

### Different Layouts Per Device

```dart
PxResponsiveBuilder(
  mobile: (context) => MobileLayout(),
  tablet: (context) => TabletLayout(),
  desktop: (context) => DesktopLayout(),
)

```

### Responsive Values Widget

```dart
PxResponsiveValue<int>(
  mobile: 2,
  tablet: 3,
  desktop: 4,
  builder: (context, columnCount) {
    return GridView.count(crossAxisCount: columnCount);
  },
)

```

### Conditional Visibility

```dart
PxResponsiveVisibility.desktop(child: SideBar())
PxResponsiveVisibility.tabletUp(child: ExtendedMenu())
PxResponsiveVisibility.mobile(child: BottomNav())

```

## ⚙️ Configuration

```dart
PxResponsiveConfig(
  // Base design sizes
  desktop: Size(1920, 1080),
  tablet: Size(834, 1194),
  mobile: Size(375, 812),
  
  // Breakpoints
  mobileBreakpoint: 600,
  tabletBreakpoint: 1200,
  
  // Safety limits
  minScaleFactor: 0.5,
  maxScaleFactor: 2.0,
  maxTextScaleFactor: 1.5,
)

```

## 🔍 Device Type Checking

Simple global getters - no need to access `PxResponsive()`:

```dart
// Boolean checks
if (isMobile) {
  // Mobile-specific code
}

if (isTablet) {
  // Tablet-specific code
}

if (isDesktop) {
  // Desktop-specific code
}

// Enum for switch statements
switch (deviceType) {
  case EasyDeviceType.mobile:
    return MobileLayout();
  case EasyDeviceType.tablet:
    return TabletLayout();
  case EasyDeviceType.desktop:
    return DesktopLayout();
}

// Screen dimensions
print('Width: $screenWidth, Height: $screenHeight');

```

## 🔍 Full Access (Optional)

For more details, access the singleton:

```dart
final responsive = PxResponsive();

responsive.scaleW          // Width scale factor
responsive.scaleH          // Height scale factor
responsive.activeBaseSize  // Current base design size
responsive.devicePixelRatio

```

## 📊 How It Works

```
Your Design (Figma/XD)          Current Screen
┌─────────────────┐             ┌─────────────────┐
│ Mobile: 375x812 │             │ Screen: 390x844 │
│ Tablet: 834x1194│  ──────►    │                 │
│ Desktop:1920x1080             │ Scale: 1.04     │
└─────────────────┘             └─────────────────┘

200.w = 200 * (390/375) = 208px

```

## License

This project is licensed under the MIT License - see the [LICENSE](https://www.google.com/search?q=LICENSE) file for details.

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

👥 Contributors
We appreciate all contributions to this project! 






<a href="https://www.google.com/search?q=https://github.com/IbrahimElmourchidi/px_responsive/graphs/contributors">
<img src="https://www.google.com/search?q=https://contrib.rocks/image%3Frepo%3DIbrahimElmourchidi/px_responsive" />
</a>

```