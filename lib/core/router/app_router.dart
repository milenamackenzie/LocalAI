import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../presentation/blocs/auth_bloc.dart';
import '../../presentation/pages/home/main_page.dart';
import '../../presentation/pages/home/top_rated_page.dart';
import '../../presentation/pages/home/recommendation_page.dart';
import '../../presentation/pages/theme_preview_page.dart';
import '../../presentation/pages/auth/login_page.dart';
import '../../presentation/pages/auth/register_page.dart';
import '../../presentation/pages/auth/user_preference_page.dart';
import '../../presentation/pages/search/search_overlay.dart';
import '../../presentation/pages/search/search_results_page.dart';
import '../../presentation/pages/search/chat_history_page.dart';
import '../../presentation/pages/details/location_detail_page.dart';
import '../../presentation/pages/profile/bookmarks_page.dart';
import '../../presentation/pages/profile/settings_page.dart';
import '../../presentation/pages/app_pages.dart';

class AppRouter {
  static final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();

  static GoRouter createRouter(AuthBloc authBloc) {
    return GoRouter(
      navigatorKey: rootNavigatorKey,
      initialLocation: '/',
      debugLogDiagnostics: true,
      refreshListenable: _GoRouterRefreshStream(authBloc.stream),
      
      // Auth Guard
      redirect: (context, state) {
        final authState = authBloc.state;
        final loggingIn = state.matchedLocation == '/login' || 
                         state.matchedLocation == '/register' ||
                         state.matchedLocation == '/preferences';

        if (authState is Unauthenticated || authState is AuthInitial) {
          if (loggingIn) return null;
          return '/login';
        }

        if (authState is Authenticated && loggingIn) {
          return '/';
        }

        return null;
      },
      
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const MainPage(),
        ),
        GoRoute(
          path: '/recommendations',
          builder: (context, state) => const RecommendationPage(),
        ),
        GoRoute(
          path: '/search',
          pageBuilder: (context, state) => CustomTransitionPage(
            key: state.pageKey,
            child: const SearchOverlay(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(opacity: animation, child: child);
            },
          ),
        ),
        GoRoute(
          path: '/search-results',
          builder: (context, state) {
            final query = state.extra as String? ?? '';
            return SearchResultsPage(query: query);
          },
        ),
        GoRoute(
          path: '/chat-history',
          builder: (context, state) => const ChatHistoryPage(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: '/preferences',
          builder: (context, state) => const UserPreferencePage(),
        ),
        GoRoute(
          path: '/profile',
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: '/bookmarks',
          builder: (context, state) => const BookmarksPage(),
        ),
        GoRoute(
          path: '/settings',
          builder: (context, state) => const SettingsPage(),
        ),
        GoRoute(
          path: '/recommendation/:id',
          builder: (context, state) {
            final id = state.pathParameters['id'] ?? '0';
            return LocationDetailPage(id: id);
          },
        ),
        GoRoute(
          path: '/theme-preview',
          builder: (context, state) => const ThemePreviewPage(),
        ),
      ],
      
      errorBuilder: (context, state) => const NotFoundPage(),
    );
  }
}

// Helper class to convert Stream to ChangeNotifier for GoRouter
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
      (dynamic _) => notifyListeners(),
    );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
