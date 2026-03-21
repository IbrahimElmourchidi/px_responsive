import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:px_responsive/px_responsive.dart';

void main() {
  setUp(() {
    PxResponsive().reset();
  });

  group('PxResponsiveConfig', () {
    test('default values are correct', () {
      const config = PxResponsiveConfig();
      expect(config.desktop, const Size(1920, 1080));
      expect(config.tablet, const Size(834, 1194));
      expect(config.mobile, const Size(375, 812));
      expect(config.mobileBreakpoint, 600);
      expect(config.tabletBreakpoint, 1200);
    });

    test('copyWith works correctly', () {
      const config = PxResponsiveConfig();
      final newConfig = config.copyWith(mobileBreakpoint: 500);
      expect(newConfig.mobileBreakpoint, 500);
      expect(newConfig.tabletBreakpoint, 1200);
    });

    test('landscape sizes default to null', () {
      const config = PxResponsiveConfig();
      expect(config.mobileLandscape, isNull);
      expect(config.tabletLandscape, isNull);
      expect(config.desktopLandscape, isNull);
    });

    test('copyWith preserves landscape sizes', () {
      const landscape = Size(812, 375);
      const config = PxResponsiveConfig();
      final updated = config.copyWith(mobileLandscape: landscape);
      expect(updated.mobileLandscape, landscape);
      expect(updated.tabletLandscape, isNull);
    });

    test('equality compares landscape fields', () {
      const a = PxResponsiveConfig(mobileLandscape: Size(812, 375));
      const b = PxResponsiveConfig(mobileLandscape: Size(812, 375));
      const c = PxResponsiveConfig();
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });

  group('PxResponsive', () {
    test('singleton returns same instance', () {
      final instance1 = PxResponsive();
      final instance2 = PxResponsive();
      expect(identical(instance1, instance2), true);
    });

    test('init sets values correctly for mobile', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 375, maxHeight: 812),
        config: const PxResponsiveConfig(),
      );

      expect(PxResponsive().screenWidth, 375);
      expect(PxResponsive().screenHeight, 812);
      expect(PxResponsive().isMobile, true);
      expect(PxResponsive().isTablet, false);
      expect(PxResponsive().isDesktop, false);
      expect(PxResponsive().deviceType, PxDeviceType.mobile);
    });

    test('init sets values correctly for tablet', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 834, maxHeight: 1194),
        config: const PxResponsiveConfig(),
      );

      expect(PxResponsive().isMobile, false);
      expect(PxResponsive().isTablet, true);
      expect(PxResponsive().isDesktop, false);
      expect(PxResponsive().deviceType, PxDeviceType.tablet);
    });

    test('init sets values correctly for desktop', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 1920, maxHeight: 1080),
        config: const PxResponsiveConfig(),
      );

      expect(PxResponsive().isMobile, false);
      expect(PxResponsive().isTablet, false);
      expect(PxResponsive().isDesktop, true);
      expect(PxResponsive().deviceType, PxDeviceType.desktop);
    });

    test('scale factors are calculated correctly', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 375, maxHeight: 812),
        config: const PxResponsiveConfig(),
      );

      expect(PxResponsive().scaleW, 1.0);
      expect(PxResponsive().scaleH, 1.0);
    });

    test('value method returns correct value per device', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 375, maxHeight: 812),
        config: const PxResponsiveConfig(),
      );

      final result = PxResponsive().value(
        mobile: 'mobile',
        tablet: 'tablet',
        desktop: 'desktop',
      );
      expect(result, 'mobile');
    });

    test('value method falls back correctly', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 834, maxHeight: 1194),
        config: const PxResponsiveConfig(),
      );

      final result = PxResponsive().value(
        mobile: 'mobile',
        desktop: 'desktop',
      );
      expect(result, 'mobile'); // tablet falls back to mobile
    });

    test('maxWidth caps effectiveWidth', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 2560, maxHeight: 1440),
        config: const PxResponsiveConfig(maxWidth: 1920),
      );

      expect(PxResponsive().effectiveWidth, 1920);
      expect(PxResponsive().screenWidth, 2560);
    });

    test('minScaleFactor clamps small scales', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 100, maxHeight: 100),
        config: const PxResponsiveConfig(minScaleFactor: 0.8),
      );
      expect(PxResponsive().scaleW, greaterThanOrEqualTo(0.8));
    });

    test('maxScaleFactor clamps large scales', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 9999, maxHeight: 9999),
        config: const PxResponsiveConfig(maxScaleFactor: 3.0),
      );
      expect(PxResponsive().scaleW, lessThanOrEqualTo(3.0));
    });

    test('reset clears all state', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 375, maxHeight: 812),
        config: const PxResponsiveConfig(),
      );
      PxResponsive().reset();
      expect(PxResponsive().isInitialized, false);
      expect(PxResponsive().screenWidth, 0);
      expect(PxResponsive().safeAreaTop, 0);
    });
  });

  // ============================================================
  // Orientation
  // ============================================================

  group('Orientation', () {
    test('isPortrait when height > width', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 375, maxHeight: 812),
        config: const PxResponsiveConfig(),
      );
      expect(PxResponsive().isPortrait, true);
      expect(PxResponsive().isLandscape, false);
      expect(PxResponsive().orientation, PxOrientation.portrait);
    });

    test('isLandscape when width > height', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 812, maxHeight: 375),
        config: const PxResponsiveConfig(),
      );
      expect(PxResponsive().isLandscape, true);
      expect(PxResponsive().isPortrait, false);
      expect(PxResponsive().orientation, PxOrientation.landscape);
    });

    test('orientationValue returns portrait value', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 375, maxHeight: 812),
        config: const PxResponsiveConfig(),
      );
      final value = PxResponsive().orientationValue(
        portrait: 'portrait',
        landscape: 'landscape',
      );
      expect(value, 'portrait');
    });

    test('orientationValue returns landscape value', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 812, maxHeight: 375),
        config: const PxResponsiveConfig(),
      );
      final value = PxResponsive().orientationValue(
        portrait: 'portrait',
        landscape: 'landscape',
      );
      expect(value, 'landscape');
    });

    test('uses mobileLandscape base size in landscape', () {
      const landscapeSize = Size(812, 375);
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 500, maxHeight: 300),
        config: const PxResponsiveConfig(mobileLandscape: landscapeSize),
      );
      expect(PxResponsive().activeBaseSize, landscapeSize);
    });
  });

  // ============================================================
  // Safe area
  // ============================================================

  group('Safe area', () {
    test('safeAreaTop returns top inset', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 375, maxHeight: 812),
        config: const PxResponsiveConfig(),
        safeAreaPadding: const EdgeInsets.only(top: 44, bottom: 34),
      );
      expect(PxResponsive().safeAreaTop, 44);
      expect(PxResponsive().safeAreaBottom, 34);
    });

    test('safeScreenHeight excludes safe area', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 375, maxHeight: 812),
        config: const PxResponsiveConfig(),
        safeAreaPadding: const EdgeInsets.only(top: 44, bottom: 34),
      );
      expect(PxResponsive().safeScreenHeight, 812 - 44 - 34);
    });

    test('safe area resets to zero on reset()', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 375, maxHeight: 812),
        config: const PxResponsiveConfig(),
        safeAreaPadding: const EdgeInsets.only(top: 44),
      );
      PxResponsive().reset();
      expect(PxResponsive().safeAreaTop, 0);
    });
  });

  // ============================================================
  // Extensions
  // ============================================================

  group('Extensions', () {
    setUp(() {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 375, maxHeight: 812),
        config: const PxResponsiveConfig(),
      );
    });

    test('.w extension scales correctly', () {
      expect(100.w, 100 * PxResponsive().scaleW);
    });

    test('.h extension scales correctly', () {
      expect(100.h, 100 * PxResponsive().scaleH);
    });

    test('.sp extension scales correctly', () {
      expect(16.sp, 16 * PxResponsive().scaleSp);
    });

    test('.r extension scales correctly', () {
      expect(12.r, 12 * PxResponsive().scaleR);
    });

    test('.wf extension calculates percentage correctly', () {
      expect(50.wf, 0.5 * PxResponsive().screenWidth);
    });

    test('.hf extension calculates percentage correctly', () {
      expect(50.hf, 0.5 * PxResponsive().screenHeight);
    });

    test('clamping methods work correctly', () {
      expect(100.wMin(150), 150);
      expect(100.wMax(50), 50);
      expect(100.wClamp(80, 120), closeTo(100, 1));
    });

    test('.rMin returns minimum when scaled value is smaller', () {
      final scaled = 1.r;
      expect(1.rMin(scaled + 10), scaled + 10);
    });

    test('.rMax returns maximum when scaled value is larger', () {
      final scaled = 100.r;
      expect(100.rMax(scaled - 10), scaled - 10);
    });

    test('.rClamp clamps radius between min and max', () {
      final result = 100.rClamp(0, 999);
      expect(result, closeTo(100.r, 0.001));
    });

    test('.verticalSpace returns SizedBox with height', () {
      final box = 16.verticalSpace;
      expect(box.height, closeTo(16 * PxResponsive().scaleH, 0.001));
      expect(box.width, isNull);
    });

    test('.horizontalSpace returns SizedBox with width', () {
      final box = 8.horizontalSpace;
      expect(box.width, closeTo(8 * PxResponsive().scaleW, 0.001));
      expect(box.height, isNull);
    });

    test('EdgeInsets .scaled applies correct axes', () {
      const insets = EdgeInsets.symmetric(horizontal: 20, vertical: 10);
      final scaled = insets.scaled;
      expect(scaled.left, closeTo(20 * PxResponsive().scaleW, 0.001));
      expect(scaled.top, closeTo(10 * PxResponsive().scaleH, 0.001));
    });

    test('Size .scaled applies correct axes', () {
      const s = Size(200, 100);
      final scaled = s.scaled;
      expect(scaled.width, closeTo(200 * PxResponsive().scaleW, 0.001));
      expect(scaled.height, closeTo(100 * PxResponsive().scaleH, 0.001));
    });

    test('BorderRadius .r applies scaleR', () {
      final br = BorderRadius.circular(12).r;
      expect(br.topLeft.x, closeTo(12 * PxResponsive().scaleR, 0.001));
    });

    test('TextStyle .responsive scales fontSize', () {
      const style = TextStyle(fontSize: 16);
      final responsive = style.responsive;
      expect(
        responsive.fontSize,
        closeTo(16 * PxResponsive().scaleSp, 0.001),
      );
    });
  });

  // ============================================================
  // responsiveValue / orientationValue global functions
  // ============================================================

  group('responsiveValue', () {
    test('returns mobile value on mobile', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 375, maxHeight: 812),
        config: const PxResponsiveConfig(),
      );

      final result = responsiveValue(
        mobile: 100,
        tablet: 200,
        desktop: 300,
      );
      expect(result, 100);
    });

    test('returns tablet value on tablet', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 834, maxHeight: 1194),
        config: const PxResponsiveConfig(),
      );

      final result = responsiveValue(
        mobile: 100,
        tablet: 200,
        desktop: 300,
      );
      expect(result, 200);
    });

    test('returns desktop value on desktop', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 1920, maxHeight: 1080),
        config: const PxResponsiveConfig(),
      );

      final result = responsiveValue(
        mobile: 100,
        tablet: 200,
        desktop: 300,
      );
      expect(result, 300);
    });
  });

  group('orientationValue global function', () {
    test('returns portrait value in portrait', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 375, maxHeight: 812),
        config: const PxResponsiveConfig(),
      );
      expect(
        orientationValue(portrait: 'p', landscape: 'l'),
        'p',
      );
    });

    test('returns landscape value in landscape', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 812, maxHeight: 375),
        config: const PxResponsiveConfig(),
      );
      expect(
        orientationValue(portrait: 'p', landscape: 'l'),
        'l',
      );
    });
  });

  // ============================================================
  // Global getters
  // ============================================================

  group('Global getters', () {
    test('isMobile getter works', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 375, maxHeight: 812),
        config: const PxResponsiveConfig(),
      );
      expect(isMobile, true);
    });

    test('isTablet getter works', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 834, maxHeight: 1194),
        config: const PxResponsiveConfig(),
      );
      expect(isTablet, true);
    });

    test('isDesktop getter works', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 1920, maxHeight: 1080),
        config: const PxResponsiveConfig(),
      );
      expect(isDesktop, true);
    });

    test('screenWidth and screenHeight getters work', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 375, maxHeight: 812),
        config: const PxResponsiveConfig(),
      );
      expect(screenWidth, 375);
      expect(screenHeight, 812);
    });

    test('isLandscape / isPortrait global getters work', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 812, maxHeight: 375),
        config: const PxResponsiveConfig(),
      );
      expect(isLandscape, true);
      expect(isPortrait, false);
    });

    test('orientation global getter works', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 375, maxHeight: 812),
        config: const PxResponsiveConfig(),
      );
      expect(orientation, PxOrientation.portrait);
    });
  });

  // ============================================================
  // Edge cases
  // ============================================================

  group('Edge cases', () {
    test('zero width does not crash scale calculation', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 0, maxHeight: 0),
        config: const PxResponsiveConfig(minScaleFactor: 0.6),
      );
      expect(PxResponsive().scaleW, greaterThanOrEqualTo(0.6));
    });

    test('extreme width is capped by maxScaleFactor', () {
      PxResponsive().init(
        constraints: const BoxConstraints(maxWidth: 100000, maxHeight: 100000),
        config: const PxResponsiveConfig(maxScaleFactor: 3.0),
      );
      expect(PxResponsive().scaleW, lessThanOrEqualTo(3.0));
    });
  });
}
