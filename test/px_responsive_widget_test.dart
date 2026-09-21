import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:px_responsive/px_responsive.dart';

/// Builds the widget tree used by [pumpResponsive]: a [PxResponsiveWrapper]
/// wrapping [child] in a [Directionality].
///
/// This does *not* itself control the screen size — [pumpResponsive] sets
/// that via `tester.view.physicalSize` before pumping, since the wrapper's
/// `LayoutBuilder` reads the real test surface, not a `SizedBox` placed
/// inside it (a `SizedBox` inside the wrapper only constrains layout, it
/// does not change what `LayoutBuilder` reports as available).
Widget buildTestApp({
  required Widget child,
  PxResponsiveConfig config = const PxResponsiveConfig(),
  bool forceRebuildOnChange = true,
}) {
  return PxResponsiveWrapper(
    config: config,
    forceRebuildOnChange: forceRebuildOnChange,
    child: Directionality(
      textDirection: TextDirection.ltr,
      child: child,
    ),
  );
}

/// Pumps [child] wrapped in [buildTestApp] at the given screen [size].
///
/// Sets `tester.view.physicalSize` (with `devicePixelRatio` forced to 1.0,
/// so physical == logical pixels) before pumping, and tears the view back
/// down afterwards so size doesn't leak between tests.
Future<void> pumpResponsive(
  WidgetTester tester, {
  required Widget child,
  Size size = const Size(375, 812),
  PxResponsiveConfig config = const PxResponsiveConfig(),
  bool forceRebuildOnChange = true,
}) async {
  tester.view.devicePixelRatio = 1.0;
  tester.view.physicalSize = size;
  addTearDown(tester.view.reset);
  await tester.pumpWidget(buildTestApp(
    child: child,
    config: config,
    forceRebuildOnChange: forceRebuildOnChange,
  ));
}

void main() {
  setUp(() => PxResponsive().reset());

  // ===========================================================================
  // PxResponsiveWrapper
  // ===========================================================================

  group('PxResponsiveWrapper', () {
    testWidgets('initialises singleton on build', (tester) async {
      await pumpResponsive(tester, child: const SizedBox.shrink());
      expect(PxResponsive().isInitialized, true);
    });

    testWidgets('builder variant provides PxResponsive instance',
        (tester) async {
      PxResponsive? captured;
      await tester.pumpWidget(
        PxResponsiveWrapper(
          builder: (context, responsive) {
            captured = responsive;
            return const SizedBox.shrink();
          },
        ),
      );
      expect(captured, isNotNull);
      expect(captured!.isInitialized, true);
    });

    testWidgets('resized descendant picks up the new scale (reactivity)',
        (tester) async {
      addTearDown(tester.view.reset);
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(400, 900);

      await tester.pumpWidget(buildTestApp(
        // Align gives the SizedBox loose constraints, so it can actually
        // be its requested size instead of being stretched to fill the
        // tight constraints a root-level widget otherwise receives.
        child: Align(
          alignment: Alignment.topLeft,
          child: Builder(
            builder: (context) => SizedBox(
              key: const Key('box'),
              width: 200.w,
              height: 100.h,
            ),
          ),
        ),
      ));

      final before = tester.getSize(find.byKey(const Key('box')));
      expect(before.width, closeTo(200 * PxResponsive().scaleW, 0.01));

      tester.view.physicalSize = const Size(1400, 900);
      await tester.pumpAndSettle();

      final after = tester.getSize(find.byKey(const Key('box')));
      // The whole point of the force-rebuild walk: the rendered box tracks
      // the resize, not just the singleton's own getters.
      expect(after.width, closeTo(200 * PxResponsive().scaleW, 0.01));
      expect(after.width, isNot(closeTo(before.width, 0.01)));
    });

    testWidgets(
        'forceRebuildOnChange: false leaves a bare .w read stale after resize',
        (tester) async {
      addTearDown(tester.view.reset);
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(400, 900);

      await tester.pumpWidget(buildTestApp(
        forceRebuildOnChange: false,
        child: Align(
          alignment: Alignment.topLeft,
          child: Builder(
            builder: (context) =>
                SizedBox(key: const Key('box'), width: 200.w, height: 100.h),
          ),
        ),
      ));

      final before = tester.getSize(find.byKey(const Key('box')));

      tester.view.physicalSize = const Size(1400, 900);
      await tester.pumpAndSettle();

      final after = tester.getSize(find.byKey(const Key('box')));
      // Documenting the opt-out's tradeoff: the singleton *is* updated...
      expect(PxResponsive().scaleW, isNot(closeTo(before.width / 200, 0.01)));
      // ...but this non-dependent widget instance was never marked dirty.
      expect(after.width, closeTo(before.width, 0.01));
    });

    testWidgets('a non-const config rebuilt every frame does not loop',
        (tester) async {
      addTearDown(tester.view.reset);
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(400, 900);

      var buildCount = 0;
      await tester.pumpWidget(
        StatefulBuilder(
          builder: (context, setState) {
            buildCount++;
            // Deliberately non-const: a fresh (but value-equal) config on
            // every build, to prove `requiresRebuild`'s value comparison
            // (not `identical`) is what keeps this from rebuilding forever.
            // A const config here would be canonicalized to one identical
            // instance and wouldn't exercise that comparison at all.
            // ignore: prefer_const_constructors
            return PxResponsiveWrapper(
              // ignore: prefer_const_constructors
              config: PxResponsiveConfig(mobileBreakpoint: 601),
              child: const SizedBox.shrink(),
            );
          },
        ),
      );
      await tester.pumpAndSettle();
      expect(buildCount, 1);
      expect(PxResponsive().isInitialized, true);
    });

    testWidgets('two live routes at different sizes use independent scales',
        (tester) async {
      addTearDown(tester.view.reset);
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(400, 900);

      Widget page() => Align(
            alignment: Alignment.topLeft,
            child: SizedBox(key: const Key('box'), width: 200.w),
          );

      final navigatorKey = GlobalKey<NavigatorState>();
      await tester.pumpWidget(buildTestApp(
        child: Navigator(
          key: navigatorKey,
          onGenerateRoute: (settings) =>
              PageRouteBuilder(pageBuilder: (context, _, __) => page()),
        ),
      ));
      final route1Width = tester.getSize(find.byKey(const Key('box'))).width;

      tester.view.physicalSize = const Size(1400, 900);
      await tester.pumpAndSettle();

      navigatorKey.currentState!
          .push(PageRouteBuilder(pageBuilder: (context, _, __) => page()));
      await tester.pumpAndSettle();

      final route2Width = tester.getSize(find.byKey(const Key('box'))).width;
      // Both routes now read the same (post-resize) singleton scale, so a
      // freshly-built route is never stuck at the scale that was current
      // when its ancestor last rebuilt.
      expect(route2Width, closeTo(200 * PxResponsive().scaleW, 0.01));
      expect(route1Width, isNot(closeTo(route2Width, 0.01)));
    });
  });

  // ===========================================================================
  // PxResponsiveBuilder
  // ===========================================================================

  group('PxResponsiveBuilder', () {
    testWidgets('shows mobile layout on mobile', (tester) async {
      await pumpResponsive(
        tester,
        child: PxResponsiveBuilder(
          mobile: (_) => const Text('mobile'),
          tablet: (_) => const Text('tablet'),
          desktop: (_) => const Text('desktop'),
        ),
      );
      expect(find.text('mobile'), findsOneWidget);
      expect(find.text('tablet'), findsNothing);
    });

    testWidgets('shows tablet layout on tablet', (tester) async {
      await pumpResponsive(
        tester,
        size: const Size(834, 1194),
        child: PxResponsiveBuilder(
          mobile: (_) => const Text('mobile'),
          tablet: (_) => const Text('tablet'),
        ),
      );
      expect(find.text('tablet'), findsOneWidget);
    });

    testWidgets('falls back to mobile when tablet is null on tablet',
        (tester) async {
      await pumpResponsive(
        tester,
        size: const Size(834, 1194),
        child: PxResponsiveBuilder(
          mobile: (_) => const Text('mobile'),
        ),
      );
      expect(find.text('mobile'), findsOneWidget);
    });

    testWidgets('shows desktop layout on desktop', (tester) async {
      await pumpResponsive(
        tester,
        size: const Size(1920, 1080),
        child: PxResponsiveBuilder(
          mobile: (_) => const Text('mobile'),
          desktop: (_) => const Text('desktop'),
        ),
      );
      expect(find.text('desktop'), findsOneWidget);
    });
  });

  // ===========================================================================
  // PxResponsiveValue
  // ===========================================================================

  group('PxResponsiveValue', () {
    testWidgets('provides mobile value on mobile', (tester) async {
      await pumpResponsive(
        tester,
        child: PxResponsiveValue<int>(
          mobile: 1,
          tablet: 2,
          desktop: 4,
          builder: (_, v) => Text('$v'),
        ),
      );
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('provides desktop value on desktop', (tester) async {
      await pumpResponsive(
        tester,
        size: const Size(1920, 1080),
        child: PxResponsiveValue<int>(
          mobile: 1,
          desktop: 4,
          builder: (_, v) => Text('$v'),
        ),
      );
      expect(find.text('4'), findsOneWidget);
    });
  });

  // ===========================================================================
  // PxResponsiveVisibility
  // ===========================================================================

  group('PxResponsiveVisibility', () {
    testWidgets('.mobile() shows only on mobile', (tester) async {
      await pumpResponsive(
        tester,
        child: const PxResponsiveVisibility.mobile(
          child: Text('only mobile'),
        ),
      );
      expect(find.text('only mobile'), findsOneWidget);
    });

    testWidgets('.mobile() hides on desktop', (tester) async {
      await pumpResponsive(
        tester,
        size: const Size(1920, 1080),
        child: const PxResponsiveVisibility.mobile(
          child: Text('only mobile'),
        ),
      );
      expect(find.text('only mobile'), findsNothing);
    });

    testWidgets('.tabletUp() shows on tablet and desktop', (tester) async {
      for (final w in [834.0, 1920.0]) {
        PxResponsive().reset();
        await pumpResponsive(
          tester,
          size: Size(w, 1000),
          child: const PxResponsiveVisibility.tabletUp(
            child: Text('tablet up'),
          ),
        );
        expect(find.text('tablet up'), findsOneWidget,
            reason: 'Expected visible at width $w');
      }
    });

    testWidgets('maintainState uses Offstage', (tester) async {
      await pumpResponsive(
        tester,
        size: const Size(1920, 1080),
        child: const PxResponsiveVisibility.mobile(
          maintainState: true,
          child: Text('hidden but in tree'),
        ),
      );
      // Widget is in tree (Offstage) but not visible. `find.text` skips
      // offstage widgets by default, so opt out to confirm it's present.
      expect(
        find.text('hidden but in tree', skipOffstage: false),
        findsOneWidget,
      );
      final offstage = tester.widget<Offstage>(find.byType(Offstage));
      expect(offstage.offstage, true);
    });

    testWidgets('shows replacement when hidden', (tester) async {
      await pumpResponsive(
        tester,
        size: const Size(1920, 1080),
        child: const PxResponsiveVisibility.mobile(
          replacement: Text('replacement'),
          child: Text('original'),
        ),
      );
      expect(find.text('original'), findsNothing);
      expect(find.text('replacement'), findsOneWidget);
    });
  });

  // ===========================================================================
  // PxResponsivePadding
  // ===========================================================================

  group('PxResponsivePadding', () {
    testWidgets('applies mobile padding on mobile', (tester) async {
      await pumpResponsive(
        tester,
        child: const PxResponsivePadding(
          mobile: EdgeInsets.all(8),
          desktop: EdgeInsets.all(32),
          child: SizedBox.shrink(),
        ),
      );
      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, const EdgeInsets.all(8));
    });

    testWidgets('applies desktop padding on desktop', (tester) async {
      await pumpResponsive(
        tester,
        size: const Size(1920, 1080),
        child: const PxResponsivePadding(
          mobile: EdgeInsets.all(8),
          desktop: EdgeInsets.all(32),
          child: SizedBox.shrink(),
        ),
      );
      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, const EdgeInsets.all(32));
    });
  });

  // ===========================================================================
  // PxRelativeSizeProvider
  // ===========================================================================

  group('PxRelativeSizeProvider', () {
    testWidgets('.wr(context) returns percentage of parent width',
        (tester) async {
      double? measured;
      await pumpResponsive(
        tester,
        child: PxRelativeSizeProvider(
          child: Builder(
            builder: (context) {
              measured = 50.wr(context);
              return const SizedBox.shrink();
            },
          ),
        ),
      );
      // Parent is the full 375 px from pumpResponsive's default size.
      expect(measured, isNotNull);
    });
  });

  // ===========================================================================
  // PxResponsiveDebug
  // ===========================================================================

  group('PxResponsiveDebug', () {
    testWidgets('renders child when disabled', (tester) async {
      await pumpResponsive(
        tester,
        child: const PxResponsiveDebug(
          enabled: false,
          child: Text('content'),
        ),
      );
      expect(find.text('content'), findsOneWidget);
      expect(find.byType(Stack), findsNothing);
    });

    testWidgets('renders overlay Stack when enabled', (tester) async {
      await pumpResponsive(
        tester,
        child: const PxResponsiveDebug(
          child: Text('content'),
        ),
      );
      expect(find.text('content'), findsOneWidget);
      expect(find.byType(Stack), findsOneWidget);
    });

    testWidgets('renders above MaterialApp without a Directionality ancestor',
        (tester) async {
      // Regression test: PxResponsiveDebug's own documented placement is
      // above MaterialApp, where no Directionality is available yet.
      addTearDown(tester.view.reset);
      tester.view.devicePixelRatio = 1.0;
      tester.view.physicalSize = const Size(375, 812);

      await tester.pumpWidget(
        const PxResponsiveWrapper(
          child: PxResponsiveDebug(
            child: Directionality(
              textDirection: TextDirection.ltr,
              child: Text('content'),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
      expect(find.text('content'), findsOneWidget);
    });
  });

  // ===========================================================================
  // AnimatedPxResponsiveBuilder
  // ===========================================================================

  group('AnimatedPxResponsiveBuilder', () {
    testWidgets('shows correct layout for device type', (tester) async {
      await pumpResponsive(
        tester,
        child: AnimatedPxResponsiveBuilder(
          mobile: (_) => const Text('mobile'),
          desktop: (_) => const Text('desktop'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('mobile'), findsOneWidget);
    });
  });

  // ===========================================================================
  // PxResponsiveGrid
  // ===========================================================================

  group('PxResponsiveGrid', () {
    testWidgets('renders all children', (tester) async {
      await pumpResponsive(
        tester,
        child: PxResponsiveGrid(
          mobileColumns: 2,
          spacing: 8,
          shrinkWrap: true,
          children: List.generate(
            4,
            (i) => Text('item$i'),
          ),
        ),
      );
      expect(find.text('item0'), findsOneWidget);
      expect(find.text('item3'), findsOneWidget);
    });

    testWidgets('.builder renders items lazily by itemCount', (tester) async {
      await pumpResponsive(
        tester,
        child: PxResponsiveGrid.builder(
          mobileColumns: 2,
          spacing: 8,
          shrinkWrap: true,
          itemCount: 4,
          itemBuilder: (context, i) => Text('lazy$i'),
        ),
      );
      expect(find.text('lazy0'), findsOneWidget);
      expect(find.text('lazy3'), findsOneWidget);
    });
  });

  // ===========================================================================
  // Tier detection (PxBreakpointAxis.hybrid)
  // ===========================================================================

  group('Hybrid tier detection', () {
    testWidgets('landscape phone (844x390) is classified as mobile',
        (tester) async {
      await pumpResponsive(
        tester,
        size: const Size(844, 390),
        child: Builder(
          builder: (context) => Text(context.deviceType.name),
        ),
      );
      expect(find.text('mobile'), findsOneWidget);
    });

    testWidgets('short desktop monitor (1920x1080) is classified as desktop',
        (tester) async {
      await pumpResponsive(
        tester,
        size: const Size(1920, 1080),
        child: Builder(
          builder: (context) => Text(context.deviceType.name),
        ),
      );
      expect(find.text('desktop'), findsOneWidget);
    });

    testWidgets('iPad landscape (1194x834) is classified as tablet',
        (tester) async {
      await pumpResponsive(
        tester,
        size: const Size(1194, 834),
        child: Builder(
          builder: (context) => Text(context.deviceType.name),
        ),
      );
      expect(find.text('tablet'), findsOneWidget);
    });
  });

  // ===========================================================================
  // transitionBand
  // ===========================================================================

  group('transitionBand', () {
    testWidgets('scale factor is continuous across the tablet breakpoint',
        (tester) async {
      const config = PxResponsiveConfig(transitionBand: 100);
      double scaleAt(double width) {
        PxResponsive().init(
          constraints: BoxConstraints.tightFor(width: width, height: 900),
          config: config,
        );
        return PxResponsive().scaleW;
      }

      // Without transitionBand, crossing 1199 -> 1200 jumps scaleW by
      // ~0.81 in one pixel (see the no-band case below). Spread across a
      // 100px band, every single-pixel step should be roughly 1/100th of
      // that: sample every integer width in the band and check no step is
      // anywhere near the un-banded jump.
      double? previous;
      var maxStep = 0.0;
      for (var width = 1150; width <= 1250; width++) {
        final scale = scaleAt(width.toDouble());
        if (previous != null) {
          maxStep = maxStep > (scale - previous).abs()
              ? maxStep
              : (scale - previous).abs();
        }
        previous = scale;
      }
      expect(maxStep, lessThan(0.05));
    });

    test('the hard-switch (no band) jump this feature smooths over', () {
      const config = PxResponsiveConfig(); // transitionBand: 0 (default)
      // height: 1600 keeps both samples in portrait, so this isolates the
      // breakpoint jump itself from the (separately correct) landscape
      // auto-flip behavior.
      PxResponsive().init(
        constraints: const BoxConstraints.tightFor(width: 1199, height: 1600),
        config: config,
      );
      final before = PxResponsive().scaleW;
      PxResponsive().init(
        constraints: const BoxConstraints.tightFor(width: 1200, height: 1600),
        config: config,
      );
      final after = PxResponsive().scaleW;
      // Documents the discontinuity transitionBand exists to fix: 16.sp
      // renders at 23.0px at width 1199 and 10.0px at width 1200.
      expect((after - before).abs(), greaterThan(0.5));
    });

    testWidgets('deviceType still switches exactly at the breakpoint',
        (tester) async {
      const config = PxResponsiveConfig(transitionBand: 100);
      PxResponsive().init(
        constraints: const BoxConstraints.tightFor(width: 1199, height: 900),
        config: config,
      );
      expect(PxResponsive().deviceType, PxDeviceType.tablet);
      expect(PxResponsive().isInTransition, true);

      PxResponsive().init(
        constraints: const BoxConstraints.tightFor(width: 1200, height: 900),
        config: config,
      );
      expect(PxResponsive().deviceType, PxDeviceType.desktop);
      expect(PxResponsive().isInTransition, true);
    });
  });

  // ===========================================================================
  // maxWidth centering
  // ===========================================================================

  group('maxWidth centering', () {
    testWidgets('constrains and centers content past maxWidth',
        (tester) async {
      await pumpResponsive(
        tester,
        size: const Size(3840, 1200),
        config: const PxResponsiveConfig(maxWidth: 1920),
        child: Container(key: const Key('content'), color: const Color(0xFFFF0000)),
      );
      final box = tester.getSize(find.byKey(const Key('content')));
      expect(box.width, 1920);
      expect(PxResponsive().effectiveWidth, 1920);
    });

    testWidgets('scaleOnly behavior does not constrain layout width',
        (tester) async {
      await pumpResponsive(
        tester,
        size: const Size(3840, 1200),
        config: const PxResponsiveConfig(
          maxWidth: 1920,
          maxWidthBehavior: PxMaxWidthBehavior.scaleOnly,
        ),
        child: Container(key: const Key('content'), color: const Color(0xFFFF0000)),
      );
      final box = tester.getSize(find.byKey(const Key('content')));
      expect(box.width, 3840);
      expect(PxResponsive().effectiveWidth, 1920);
    });

    testWidgets('below maxWidth, tree shape is unaffected', (tester) async {
      await pumpResponsive(
        tester,
        size: const Size(1600, 900),
        config: const PxResponsiveConfig(maxWidth: 1920),
        child: const SizedBox.shrink(),
      );
      expect(find.byType(Center), findsNothing);
      expect(find.byType(ConstrainedBox), findsNothing);
    });
  });
}
