import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/language_selection_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/profile_screen.dart';
import '../features/splash/presentation/screens/splash_screen.dart';
import '../features/news/presentation/screens/article_detail_screen.dart';
import '../features/news/presentation/screens/discover_screen.dart';
import '../features/news/presentation/screens/home_screen.dart';
import '../models/news_item.dart';
import '../providers/auth_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/splash_provider.dart';
import '../ui/widgets/main_shell.dart';

// Router provider — needs access to auth state via Riverpod
final appRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey           = GlobalKey<NavigatorState>(debugLabel: 'root');
  final shellNavigatorHomeKey      = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
  final shellNavigatorDiscoverKey  = GlobalKey<NavigatorState>(debugLabel: 'shellDiscover');
  final shellNavigatorProfileKey   = GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

  final authState       = ref.watch(authStateProvider);
  final hasSeenSplash   = ref.watch(splashFinishedProvider);
  final settingsAsync   = ref.watch(settingsProvider);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    redirect: (context, state) {
      final isSplashRoute   = state.matchedLocation == '/splash';
      final isLoginRoute    = state.matchedLocation == '/login';
      final isLangRoute     = state.matchedLocation == '/language';

      if (!hasSeenSplash) {
        if (!isSplashRoute) return '/splash';
        return null;
      }

      final isLoggedIn = authState.value != null;
      final isLoading  = authState.isLoading || settingsAsync.isLoading;

      if (isLoading) return null; // Wait for auth + settings

      if (!isLoggedIn) {
        if (!isLoginRoute) return '/login';
        return null;
      }

      // Logged in — check language selection
      final languageSelected = settingsAsync.value?.languageSelected ?? false;
      if (isLoggedIn && !languageSelected && !isLangRoute) {
        return '/language';
      }

      // Already done setup — bounce away from auth screens
      if (isLoggedIn && languageSelected && (isLoginRoute || isSplashRoute || isLangRoute)) {
        return '/';
      }

      return null;
    },
    routes: <RouteBase>[
      // Splash — outside the shell
      GoRoute(
        path: '/splash',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const SplashScreen(),
      ),

      // Login — outside the shell
      GoRoute(
        path: '/login',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LoginScreen(),
      ),

      // Language selection — shown once after first login
      GoRoute(
        path: '/language',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => const LanguageSelectionScreen(),
      ),

      StatefulShellRoute(
        builder: (BuildContext context, GoRouterState state,
            StatefulNavigationShell navigationShell) {
          return MainShell(navigationShell: navigationShell);
        },
        navigatorContainerBuilder: (BuildContext context,
            StatefulNavigationShell navigationShell,
            List<Widget> children) {
          return AnimatedBranchContainer(
            currentIndex: navigationShell.currentIndex,
            children: children,
          );
        },
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            navigatorKey: shellNavigatorHomeKey,
            routes: <RouteBase>[
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
                routes: [
                  GoRoute(
                    path: 'article',
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final extra   = state.extra as Map<String, dynamic>;
                      final article = extra['article'] as NewsItem;
                      final heroTag = extra['heroTag'] as String;
                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: ArticleDetailScreen(article: article, heroTag: heroTag),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorDiscoverKey,
            routes: <RouteBase>[
              GoRoute(
                path: '/discover',
                builder: (context, state) => const DiscoverScreen(),
                routes: [
                  GoRoute(
                    path: 'article',
                    parentNavigatorKey: rootNavigatorKey,
                    pageBuilder: (context, state) {
                      final extra   = state.extra as Map<String, dynamic>;
                      final article = extra['article'] as NewsItem;
                      final heroTag = extra['heroTag'] as String;
                      return CustomTransitionPage(
                        key: state.pageKey,
                        child: ArticleDetailScreen(article: article, heroTag: heroTag),
                        transitionsBuilder: (context, animation, secondaryAnimation, child) {
                          return FadeTransition(opacity: animation, child: child);
                        },
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
          StatefulShellBranch(
            navigatorKey: shellNavigatorProfileKey,
            routes: <RouteBase>[
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
});
