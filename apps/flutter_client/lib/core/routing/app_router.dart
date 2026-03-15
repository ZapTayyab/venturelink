import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'route_names.dart';
import '../../features/auth/domain/auth_notifier.dart';
import '../../features/auth/domain/auth_state.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/presentation/forgot_password_screen.dart';
import '../../features/auth/presentation/splash_screen.dart';
import '../../features/dashboard/presentation/founder_dashboard.dart';
import '../../features/dashboard/presentation/investor_dashboard.dart';
import '../../features/dashboard/presentation/admin_dashboard.dart';
import '../../features/startups/presentation/startup_list_screen.dart';
import '../../features/startups/presentation/startup_detail_screen.dart';
import '../../features/startups/presentation/create_startup_screen.dart';
import '../../features/startups/presentation/edit_startup_screen.dart';
import '../../features/funding_rounds/presentation/round_detail_screen.dart';
import '../../features/funding_rounds/presentation/create_round_screen.dart';
import '../../features/investments/presentation/invest_screen.dart';
import '../../features/investments/presentation/my_investments_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/admin/presentation/admin_startup_list_screen.dart';
import '../../features/admin/presentation/admin_startup_detail_screen.dart';
import '../../shared/enums/user_role.dart';

class RouterNotifier extends ChangeNotifier {
  AuthState _authState;
  bool _initialLoadDone = false;

  RouterNotifier(this._authState);

  AuthState get authState => _authState;
  bool get initialLoadDone => _initialLoadDone;

  void update(AuthState newState) {
    final wasLoading = _authState.isLoading;
    _authState = newState;
    // Mark initial load done once loading finishes the first time
    if (wasLoading && !newState.isLoading) {
      _initialLoadDone = true;
    }
    notifyListeners();
  }
}

final routerNotifierProvider =
    ChangeNotifierProvider<RouterNotifier>((ref) {
  final notifier = RouterNotifier(ref.read(authNotifierProvider));
  ref.listen<AuthState>(authNotifierProvider, (_, next) {
    notifier.update(next);
  });
  return notifier;
});

final routerProvider = Provider<GoRouter>((ref) {
  final routerNotifier = ref.watch(routerNotifierProvider);

  return GoRouter(
    initialLocation: RouteNames.splash,
    refreshListenable: routerNotifier,
    redirect: (context, state) {
      final authState = routerNotifier.authState;
      final isLoading = authState.isLoading;
      final isAuthenticated = authState.user != null;
      final initialLoadDone = routerNotifier.initialLoadDone;
      final path = state.matchedLocation;

      final authPaths = [
        RouteNames.login,
        RouteNames.register,
        RouteNames.forgotPassword,
        RouteNames.splash,
      ];

      // Only block on splash during very first load
      if (!initialLoadDone && path == RouteNames.splash) return null;

      // After initial load — never go back to splash
      if (initialLoadDone && path == RouteNames.splash) {
        return isAuthenticated ? RouteNames.dashboard : RouteNames.login;
      }

      // Not authenticated and trying to access protected route
      if (!isAuthenticated && !authPaths.contains(path)) {
        return RouteNames.login;
      }

      // Authenticated but on auth pages — go to dashboard
      if (isAuthenticated &&
          (path == RouteNames.login ||
              path == RouteNames.register ||
              path == RouteNames.forgotPassword ||
              path == RouteNames.splash)) {
        return RouteNames.dashboard;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: RouteNames.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: RouteNames.login,
        builder: (_, __) => const LoginScreen(),
      ),
      GoRoute(
        path: RouteNames.register,
        builder: (_, __) => const RegisterScreen(),
      ),
      GoRoute(
        path: RouteNames.forgotPassword,
        builder: (_, __) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: RouteNames.dashboard,
        builder: (context, state) {
          final role = routerNotifier.authState.user?.role;
          return switch (role) {
            UserRole.admin => const AdminDashboard(),
            UserRole.entrepreneur => const FounderDashboard(),
            _ => const InvestorDashboard(),
          };
        },
      ),
      GoRoute(
        path: RouteNames.startupList,
        builder: (_, __) => const StartupListScreen(),
      ),
      GoRoute(
        path: RouteNames.createStartup,
        builder: (_, __) => const CreateStartupScreen(),
      ),
      GoRoute(
        path: '/startups/:startupId',
        builder: (_, state) => StartupDetailScreen(
          startupId: state.pathParameters['startupId']!,
        ),
        routes: [
          GoRoute(
            path: 'edit',
            builder: (_, state) => EditStartupScreen(
              startupId: state.pathParameters['startupId']!,
            ),
          ),
          GoRoute(
            path: 'rounds/create',
            builder: (_, state) => CreateRoundScreen(
              startupId: state.pathParameters['startupId']!,
            ),
          ),
          GoRoute(
            path: 'rounds/:roundId',
            builder: (_, state) => RoundDetailScreen(
              startupId: state.pathParameters['startupId']!,
              roundId: state.pathParameters['roundId']!,
            ),
            routes: [
              GoRoute(
                path: 'invest',
                builder: (_, state) => InvestScreen(
                  startupId: state.pathParameters['startupId']!,
                  roundId: state.pathParameters['roundId']!,
                ),
              ),
            ],
          ),
        ],
      ),
      GoRoute(
        path: RouteNames.myInvestments,
        builder: (_, __) => const MyInvestmentsScreen(),
      ),
      GoRoute(
        path: RouteNames.profile,
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: RouteNames.adminPanel,
        builder: (_, __) => const AdminStartupListScreen(),
      ),
      GoRoute(
        path: '/admin/startups/:startupId',
        builder: (_, state) => AdminStartupDetailScreen(
          startupId: state.pathParameters['startupId']!,
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(child: Text('Page not found: ${state.error}')),
    ),
  );
});