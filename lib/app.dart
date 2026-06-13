import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'features/feed/feed_screen.dart';
import 'features/reader/reader_screen.dart';
import 'features/preferences/preferences_screen.dart';
import 'features/shell/home_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/feed',
    routes: [
      ShellRoute(
        builder: (_, __, child) => HomeShell(child: child),
        routes: [
          GoRoute(path: '/feed', builder: (_, __) => const FeedScreen()),
          GoRoute(path: '/preferences', builder: (_, __) => const PreferencesScreen()),
        ],
      ),
      GoRoute(
        path: '/reader/:id',
        builder: (_, state) => ReaderScreen(contentId: state.pathParameters['id']!),
      ),
    ],
  );
});

class YoyotimeApp extends ConsumerWidget {
  const YoyotimeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: '悠悠时光',
      routerConfig: router,
      theme: FlexThemeData.light(
        scheme: FlexScheme.green,
        appBarStyle: FlexAppBarStyle.background,
        useMaterial3: true,
      ),
      darkTheme: FlexThemeData.dark(
        scheme: FlexScheme.green,
        appBarStyle: FlexAppBarStyle.background,
        useMaterial3: true,
      ),
      themeMode: ThemeMode.system,
      debugShowCheckedModeBanner: false,
    );
  }
}
