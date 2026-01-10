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
  });

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
  });

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
  });
}
