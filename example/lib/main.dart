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
      title: 'px_responsive Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
      ),
      home: const PxResponsiveDebug(
        child: HomePage(),
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
        title: Text(
          'px_responsive v0.1.0',
          style: TextStyle(fontSize: 18.sp),
        ),
        actions: [
          // Only show device-type chip on tablet and above
          PxResponsiveVisibility.tabletUp(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Chip(
                label: Text(
                  context.deviceType.name.toUpperCase(),
                  style: TextStyle(fontSize: 11.sp),
                ),
              ),
            ),
          ),
        ],
      ),
      // Adaptive navigation: rail on tablet+, bottom bar on mobile
      body: PxResponsiveBuilder(
        mobile: (_) => const _MobileLayout(),
        tablet: (_) => const _WideLayout(),
        desktop: (_) => const _WideLayout(),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Mobile layout — bottom navigation bar
// ---------------------------------------------------------------------------

class _MobileLayout extends StatefulWidget {
  const _MobileLayout();

  @override
  State<_MobileLayout> createState() => _MobileLayoutState();
}

class _MobileLayoutState extends State<_MobileLayout> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.grid_view), label: 'Gallery'),
          BottomNavigationBarItem(
              icon: Icon(Icons.info_outline), label: 'About'),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Wide layout (tablet / desktop) — navigation rail + content
// ---------------------------------------------------------------------------

class _WideLayout extends StatefulWidget {
  const _WideLayout();

  @override
  State<_WideLayout> createState() => _WideLayoutState();
}

class _WideLayoutState extends State<_WideLayout> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        NavigationRail(
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          labelType: NavigationRailLabelType.all,
          destinations: const [
            NavigationRailDestination(icon: Icon(Icons.home), label: Text('Home')),
            NavigationRailDestination(
                icon: Icon(Icons.grid_view), label: Text('Gallery')),
            NavigationRailDestination(
                icon: Icon(Icons.info_outline), label: Text('About')),
          ],
        ),
        Expanded(child: _pages[_index]),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// Pages
// ---------------------------------------------------------------------------

const List<Widget> _pages = [
  _HomePage(),
  _GalleryPage(),
  _AboutPage(),
];

// ── Home page ───────────────────────────────────────────────────────────────

class _HomePage extends StatelessWidget {
  const _HomePage();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Welcome to px_responsive',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          12.verticalSpace,
          Text(
            'Screen: ${context.screenWidth.toStringAsFixed(0)} × '
            '${context.screenHeight.toStringAsFixed(0)} px',
            style: TextStyle(fontSize: 14.sp),
          ),
          4.verticalSpace,
          Text(
            'Device: ${context.deviceType.name}  •  '
            'Orientation: ${orientation.name}',
            style: TextStyle(fontSize: 14.sp),
          ),
          4.verticalSpace,
          Text(
            'scaleW: ${PxResponsive().scaleW.toStringAsFixed(3)}  '
            'scaleH: ${PxResponsive().scaleH.toStringAsFixed(3)}',
            style: TextStyle(fontSize: 14.sp),
          ),
          24.verticalSpace,
          _FeatureGrid(),
        ],
      ),
    );
  }
}

class _FeatureGrid extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final features = [
      ('Orientation', PxResponsive().orientation.name),
      ('Safe top', '${PxResponsive().safeAreaTop.toStringAsFixed(0)} px'),
      ('Safe bottom', '${PxResponsive().safeAreaBottom.toStringAsFixed(0)} px'),
      ('Safe height', '${PxResponsive().safeScreenHeight.toStringAsFixed(0)} px'),
      ('effectiveW', '${PxResponsive().effectiveWidth.toStringAsFixed(0)} px'),
      ('Platform', platformType.name),
    ];

    return PxResponsiveGrid(
      mobileColumns: 2,
      tabletColumns: 3,
      desktopColumns: 3,
      spacing: 12.r,
      childAspectRatio: 2,
      shrinkWrap: true,
      children: features
          .map(
            (f) => Card(
              child: Padding(
                padding: EdgeInsets.all(8.r),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      f.$1,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey,
                      ),
                    ),
                    4.verticalSpace,
                    Text(
                      f.$2,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }
}

// ── Gallery page ─────────────────────────────────────────────────────────────

class _GalleryPage extends StatelessWidget {
  const _GalleryPage();

  @override
  Widget build(BuildContext context) {
    return PxResponsiveGrid(
      mobileColumns: 2,
      tabletColumns: 3,
      desktopColumns: 4,
      spacing: 8.r,
      children: List.generate(
        12,
        (i) => Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: ColoredBox(
            color: Colors.primaries[i % Colors.primaries.length]
                .withValues(alpha: 0.7),
            child: Center(
              child: Text(
                'Item ${i + 1}',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── About page ───────────────────────────────────────────────────────────────

class _AboutPage extends StatelessWidget {
  const _AboutPage();

  @override
  Widget build(BuildContext context) {
    return PxResponsivePadding(
      mobile: const EdgeInsets.all(16),
      tablet: const EdgeInsets.all(24),
      desktop: const EdgeInsets.all(40),
      scale: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'px_responsive',
            style: TextStyle(fontSize: 28.sp, fontWeight: FontWeight.bold),
          ),
          8.verticalSpace,
          Text('Version 0.1.0', style: TextStyle(fontSize: 14.sp)),
          16.verticalSpace,
          const _AboutRow(label:'Orientation support', done: true),
          const _AboutRow(label:'Safe area awareness', done: true),
          const _AboutRow(label:'Context extensions', done: true),
          const _AboutRow(label:'TextStyle.responsive', done: true),
          const _AboutRow(label:'Icon.responsive', done: true),
          const _AboutRow(label:'verticalSpace / horizontalSpace', done: true),
          const _AboutRow(label:'rMin / rMax / rClamp', done: true),
          const _AboutRow(label:'PxResponsiveMediaQueryWrapper', done: true),
          const _AboutRow(label:'PxResponsiveDebug overlay', done: true),
          const _AboutRow(label:'PxResponsivePadding widget', done: true),
          const _AboutRow(label:'PxResponsiveGrid widget', done: true),
          const _AboutRow(label:'AnimatedPxResponsiveBuilder', done: true),
          const _AboutRow(label:'Platform type detection', done: true),
        ],
      ),
    );
  }
}

class _AboutRow extends StatelessWidget {
  const _AboutRow({required this.label, required this.done});

  final String label;
  final bool done;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(
            done ? Icons.check_circle : Icons.radio_button_unchecked,
            color: done ? Colors.green : Colors.grey,
            size: 20.r,
          ),
          8.horizontalSpace,
          Text(label, style: TextStyle(fontSize: 14.sp)),
        ],
      ),
    );
  }
}
