import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'features/feed/feed_screen.dart';
import 'features/reader/reader_screen.dart';
import 'features/listen/listen_screen.dart';
import 'features/collection/collection_screen.dart';
import 'features/review/reading_review_screen.dart';
import 'features/preferences/preferences_screen.dart';
import 'features/shell/home_shell.dart';
import 'features/preferences/preferences_controller.dart';
import 'features/affiliate/screens/affiliate_home_screen.dart';
import 'features/affiliate/screens/product_detail_screen.dart';
import 'features/affiliate/screens/publish_product_screen.dart';
import 'features/affiliate/screens/register_screen.dart';
import 'features/affiliate/screens/points_screen.dart';
import 'features/affiliate/screens/affiliate_settings_screen.dart';
import 'features/affiliate/providers/affiliate_providers.dart';
import 'features/affiliate/widgets/affiliate_popup.dart';
import 'shared/models/content.dart';

final _navigatorKey = GlobalKey<NavigatorState>();

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _navigatorKey,
    initialLocation: '/feed',
    routes: [
      ShellRoute(
        builder: (_, __, child) => HomeShell(child: child),
        routes: [
          GoRoute(path: '/feed', builder: (_, __) => const FeedScreen()),
          GoRoute(path: '/listen', builder: (_, __) => const ListenScreen()),
          GoRoute(path: '/collection', builder: (_, __) => const CollectionScreen()),
          GoRoute(path: '/review', builder: (_, __) => const ReadingReviewScreen()),
          GoRoute(path: '/preferences', builder: (_, __) => const PreferencesScreen()),
        ],
      ),
      GoRoute(
        path: '/reader/:id',
        builder: (_, state) => ReaderScreen(contentId: state.pathParameters['id']!),
      ),
      GoRoute(
        path: '/affiliate',
        builder: (_, __) => const AffiliateHomeScreen(),
        routes: [
          GoRoute(
            path: 'product/:id',
            builder: (_, state) => ProductDetailScreen(
              productId: state.pathParameters['id']!,
            ),
          ),
          GoRoute(
            path: 'publish',
            builder: (_, __) => const PublishProductScreen(),
          ),
          GoRoute(
            path: 'register',
            builder: (_, __) => const RegisterScreen(),
          ),
          GoRoute(
            path: 'points',
            builder: (_, __) => const PointsScreen(),
          ),
          GoRoute(
            path: 'settings',
            builder: (_, __) => const AffiliateSettingsScreen(),
          ),
        ],
      ),
    ],
  );
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  final prefs = ref.watch(preferencesControllerProvider);
  switch (prefs.themeMode) {
    case AppThemeMode.light:
      return ThemeMode.light;
    case AppThemeMode.dark:
      return ThemeMode.dark;
    case AppThemeMode.reading:
      return ThemeMode.light;
    case AppThemeMode.system:
      return ThemeMode.system;
  }
});

ThemeData _readingTheme() {
  return FlexThemeData.light(
    scheme: FlexScheme.sakura,
    appBarStyle: FlexAppBarStyle.background,
    useMaterial3: true,
    subThemesData: const FlexSubThemesData(
      inputDecoratorBorderType: FlexInputBorderType.outline,
    ),
  ).copyWith(
    scaffoldBackgroundColor: const Color(0xFFF5E6D3),
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF8D6E63),
      brightness: Brightness.light,
    ),
  );
}

class YoyotimeApp extends ConsumerWidget {
  const YoyotimeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final themeMode = ref.watch(themeModeProvider);

    ref.listen<bool>(popupVisibleProvider, (_, visible) {
      if (!visible) return;
      showDialog(
        context: _navigatorKey.currentContext!,
        barrierDismissible: false,
        builder: (_) => const AffiliatePopup(),
      ).then((_) => ref.read(popupVisibleProvider.notifier).hide());
    });

    final lightTheme = FlexThemeData.light(
      scheme: FlexScheme.green,
      appBarStyle: FlexAppBarStyle.background,
      useMaterial3: true,
    );

    final darkTheme = FlexThemeData.dark(
      scheme: FlexScheme.green,
      appBarStyle: FlexAppBarStyle.background,
      useMaterial3: true,
    );

    final readingTheme = _readingTheme();

    return MaterialApp.router(
      title: '悠悠时光',
      routerConfig: router,
      theme: themeMode == ThemeMode.light ? lightTheme : lightTheme,
      darkTheme: darkTheme,
      themeMode: themeMode,
      debugShowCheckedModeBanner: false,
    );
  }
}
