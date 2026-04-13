import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/presentation/screens/language_selection_screen.dart';
import '../features/auth/presentation/screens/legal_document_screen.dart';
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

/// A notifier that triggers router refreshes when auth or basic setup state changes.
/// This prevents the entire GoRouter object from being re-created when settings change,
/// which would otherwise reset the navigation stack.
class AppRouterNotifier extends ChangeNotifier {
  final Ref _ref;

  AppRouterNotifier(this._ref) {
    // Listen to changes in auth state
    _ref.listen(authStateProvider, (prev, next) {
      if (prev?.value != next.value) notifyListeners();
    });

    // Listen to splash finish
    _ref.listen(splashFinishedProvider, (prev, next) {
      if (prev != next) notifyListeners();
    });

    // Listen ONLY to languageSelection completeness in settings
    _ref.listen(settingsProvider, (prev, next) {
      final prevLang = prev?.value?.languageSelected;
      final nextLang = next.value?.languageSelected;
      if (prevLang != nextLang) notifyListeners();
    });
  }
}

// Router provider
final appRouterProvider = Provider<GoRouter>((ref) {
  final rootNavigatorKey           = GlobalKey<NavigatorState>(debugLabel: 'root');
  final shellNavigatorHomeKey      = GlobalKey<NavigatorState>(debugLabel: 'shellHome');
  final shellNavigatorDiscoverKey  = GlobalKey<NavigatorState>(debugLabel: 'shellDiscover');
  final shellNavigatorProfileKey   = GlobalKey<NavigatorState>(debugLabel: 'shellProfile');

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: '/splash',
    refreshListenable: AppRouterNotifier(ref),
    redirect: (context, state) {
      final hasSeenSplash   = ref.read(splashFinishedProvider);
      final authState       = ref.read(authStateProvider);
      final settingsAsync   = ref.read(settingsProvider);

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

      // Legal Document
      GoRoute(
        path: '/legal',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final extra = state.extra as Map<String, String>;
          return LegalDocumentScreen(
            title: extra['title']!,
            content: extra['content']!,
          );
        },
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
