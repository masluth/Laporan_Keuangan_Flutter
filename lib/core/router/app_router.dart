import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/dashboard/presentation/dashboard_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/reports/presentation/reports_screen.dart';
import '../../features/transactions/presentation/transactions_screen.dart';
import '../../shared/widgets/app_bottom_nav.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/login',

    redirect: (context, state) {
      final isLoggingIn = state.matchedLocation == '/login';

      // Auth masih loading.
      // Jangan lempar user ke dashboard sebelum status session diketahui.
      if (authState.isLoading) {
        return isLoggingIn ? null : '/login';
      }

      // Belum login → wajib ke login.
      if (!authState.isAuthenticated) {
        return isLoggingIn ? null : '/login';
      }

      // Sudah login → tidak boleh kembali ke login.
      if (authState.isAuthenticated && isLoggingIn) {
        return '/dashboard';
      }

      return null;
    },

    routes: [
      // =========================================================
      // LOGIN
      // =========================================================
      GoRoute(
        path: '/login',
        builder: (context, state) {
          return const LoginScreen();
        },
      ),

      // =========================================================
      // MAIN APPLICATION
      // =========================================================
      StatefulShellRoute.indexedStack(
        builder: (
          context,
          state,
          navigationShell,
        ) {
          return Scaffold(
            body: navigationShell,

            bottomNavigationBar: AppBottomNav(
              currentIndex: navigationShell.currentIndex,
              onTap: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation:
                      index == navigationShell.currentIndex,
                );
              },
            ),
          );
        },

        branches: [
          // =====================================================
          // DASHBOARD
          // =====================================================
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/dashboard',
                builder: (context, state) {
                  return const DashboardScreen();
                },
              ),
            ],
          ),

          // =====================================================
          // TRANSACTIONS
          // =====================================================
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/transactions',
                builder: (context, state) {
                  return const TransactionsScreen();
                },
              ),
            ],
          ),

          // =====================================================
          // REPORTS
          // =====================================================
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/reports',
                builder: (context, state) {
                  return const ReportsScreen();
                },
              ),
            ],
          ),

          // =====================================================
          // PROFILE
          // =====================================================
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) {
                  return const ProfileScreen();
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
});