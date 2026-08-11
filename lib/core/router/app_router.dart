import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/two_factor_screen.dart';
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
      final location = state.matchedLocation;

      final isLoggingIn = location == '/login';
      final isTwoFactor = location == '/two-factor';

      // =========================================================
      // AUTH MASIH LOADING
      // =========================================================

      if (authState.isLoading) {
        return null;
      }

      // =========================================================
      // 2FA DIPERLUKAN
      // =========================================================

      if (authState.requiresTwoFactor) {
        if (isTwoFactor) {
          return null;
        }

        return '/two-factor';
      }

      // =========================================================
      // BELUM LOGIN
      // =========================================================

      if (!authState.isAuthenticated) {
        if (isLoggingIn) {
          return null;
        }

        return '/login';
      }

      // =========================================================
      // SUDAH LOGIN
      // =========================================================

      if (authState.isAuthenticated) {
        if (isLoggingIn || isTwoFactor) {
          return '/dashboard';
        }

        return null;
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
      // TWO FACTOR
      // =========================================================

      GoRoute(
        path: '/two-factor',
        builder: (context, state) {
          return const TwoFactorScreen();
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
              currentIndex:
                  navigationShell.currentIndex,
              onTap: (index) {
                navigationShell.goBranch(
                  index,
                  initialLocation:
                      index ==
                          navigationShell.currentIndex,
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