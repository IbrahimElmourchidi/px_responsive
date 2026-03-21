import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:px_responsive/px_responsive.dart';

/// Helper that wraps [child] in a [PxResponsiveWrapper] with the given
/// screen [size].
Widget buildTestApp({
  required Widget child,
  Size size = const Size(375, 812),
  PxResponsiveConfig config = const PxResponsiveConfig(),
}) {
  return PxResponsiveWrapper(
    config: config,
    child: SizedBox(
      width: size.width,
      height: size.height,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: child,
      ),
    ),
  );
}

void main() {
  setUp(() => PxResponsive().reset());

  // ===========================================================================
  // PxResponsiveWrapper
  // ===========================================================================

  group('PxResponsiveWrapper', () {
    testWidgets('initialises singleton on build', (tester) async {
      await tester.pumpWidget(
        buildTestApp(child: const SizedBox.shrink()),
      );
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
  });

  // ===========================================================================
  // PxResponsiveBuilder
  // ===========================================================================

  group('PxResponsiveBuilder', () {
    testWidgets('shows mobile layout on mobile', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: PxResponsiveBuilder(
            mobile: (_) => const Text('mobile'),
            tablet: (_) => const Text('tablet'),
            desktop: (_) => const Text('desktop'),
          ),
        ),
      );
      expect(find.text('mobile'), findsOneWidget);
      expect(find.text('tablet'), findsNothing);
    });

    testWidgets('shows tablet layout on tablet', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          size: const Size(834, 1194),
          child: PxResponsiveBuilder(
            mobile: (_) => const Text('mobile'),
            tablet: (_) => const Text('tablet'),
          ),
        ),
      );
      expect(find.text('tablet'), findsOneWidget);
    });

    testWidgets('falls back to mobile when tablet is null on tablet',
        (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          size: const Size(834, 1194),
          child: PxResponsiveBuilder(
            mobile: (_) => const Text('mobile'),
          ),
        ),
      );
      expect(find.text('mobile'), findsOneWidget);
    });

    testWidgets('shows desktop layout on desktop', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          size: const Size(1920, 1080),
          child: PxResponsiveBuilder(
            mobile: (_) => const Text('mobile'),
            desktop: (_) => const Text('desktop'),
          ),
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
      await tester.pumpWidget(
        buildTestApp(
          child: PxResponsiveValue<int>(
            mobile: 1,
            tablet: 2,
            desktop: 4,
            builder: (_, v) => Text('$v'),
          ),
        ),
      );
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('provides desktop value on desktop', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          size: const Size(1920, 1080),
          child: PxResponsiveValue<int>(
            mobile: 1,
            desktop: 4,
            builder: (_, v) => Text('$v'),
          ),
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
      await tester.pumpWidget(
        buildTestApp(
          child: const PxResponsiveVisibility.mobile(
            child: Text('only mobile'),
          ),
        ),
      );
      expect(find.text('only mobile'), findsOneWidget);
    });

    testWidgets('.mobile() hides on desktop', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          size: const Size(1920, 1080),
          child: const PxResponsiveVisibility.mobile(
            child: Text('only mobile'),
          ),
        ),
      );
      expect(find.text('only mobile'), findsNothing);
    });

    testWidgets('.tabletUp() shows on tablet and desktop', (tester) async {
      for (final w in [834.0, 1920.0]) {
        PxResponsive().reset();
        await tester.pumpWidget(
          buildTestApp(
            size: Size(w, 1000),
            child: const PxResponsiveVisibility.tabletUp(
              child: Text('tablet up'),
            ),
          ),
        );
        expect(find.text('tablet up'), findsOneWidget,
            reason: 'Expected visible at width $w');
      }
    });

    testWidgets('maintainState uses Offstage', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          size: const Size(1920, 1080),
          child: const PxResponsiveVisibility.mobile(
            maintainState: true,
            child: Text('hidden but in tree'),
          ),
        ),
      );
      // Widget is in tree (Offstage) but not visible
      expect(find.text('hidden but in tree'), findsOneWidget);
      final offstage = tester.widget<Offstage>(find.byType(Offstage));
      expect(offstage.offstage, true);
    });

    testWidgets('shows replacement when hidden', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          size: const Size(1920, 1080),
          child: const PxResponsiveVisibility.mobile(
            replacement: Text('replacement'),
            child: Text('original'),
          ),
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
      await tester.pumpWidget(
        buildTestApp(
          child: const PxResponsivePadding(
            mobile: EdgeInsets.all(8),
            desktop: EdgeInsets.all(32),
            child: SizedBox.shrink(),
          ),
        ),
      );
      final padding = tester.widget<Padding>(find.byType(Padding));
      expect(padding.padding, const EdgeInsets.all(8));
    });

    testWidgets('applies desktop padding on desktop', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          size: const Size(1920, 1080),
          child: const PxResponsivePadding(
            mobile: EdgeInsets.all(8),
            desktop: EdgeInsets.all(32),
            child: SizedBox.shrink(),
          ),
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
      await tester.pumpWidget(
        buildTestApp(
          child: PxRelativeSizeProvider(
            child: Builder(
              builder: (context) {
                measured = 50.wr(context);
                return const SizedBox.shrink();
              },
            ),
          ),
        ),
      );
      // Parent is the full 375 px from buildTestApp
      expect(measured, isNotNull);
    });
  });

  // ===========================================================================
  // PxResponsiveDebug
  // ===========================================================================

  group('PxResponsiveDebug', () {
    testWidgets('renders child when disabled', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const PxResponsiveDebug(
            enabled: false,
            child: Text('content'),
          ),
        ),
      );
      expect(find.text('content'), findsOneWidget);
      expect(find.byType(Stack), findsNothing);
    });

    testWidgets('renders overlay Stack when enabled', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: const PxResponsiveDebug(
            child: Text('content'),
          ),
        ),
      );
      expect(find.text('content'), findsOneWidget);
      expect(find.byType(Stack), findsOneWidget);
    });
  });

  // ===========================================================================
  // AnimatedPxResponsiveBuilder
  // ===========================================================================

  group('AnimatedPxResponsiveBuilder', () {
    testWidgets('shows correct layout for device type', (tester) async {
      await tester.pumpWidget(
        buildTestApp(
          child: AnimatedPxResponsiveBuilder(
            mobile: (_) => const Text('mobile'),
            desktop: (_) => const Text('desktop'),
          ),
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
      await tester.pumpWidget(
        buildTestApp(
          child: PxResponsiveGrid(
            mobileColumns: 2,
            spacing: 8,
            shrinkWrap: true,
            children: List.generate(
              4,
              (i) => Text('item$i'),
            ),
          ),
        ),
      );
      expect(find.text('item0'), findsOneWidget);
      expect(find.text('item3'), findsOneWidget);
    });
  });
}
