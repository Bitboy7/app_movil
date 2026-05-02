import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/routine/presentation/screens/home_page.dart';
import '../../features/routine/presentation/screens/task_form_page.dart';
import '../../features/pet/presentation/screens/pet_screen.dart';
import '../../features/pet/presentation/screens/pet_selection_page.dart';
import '../../features/stats/presentation/screens/stats_page.dart';
import '../../features/settings/presentation/screens/settings_page.dart';
import '../../features/settings/presentation/screens/edit_profile_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../features/onboarding/presentation/splash_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../shared/widgets/app_bottom_nav.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

CustomTransitionPage<void> _fadePage(LocalKey key, Widget child) =>
    CustomTransitionPage<void>(
      key: key,
      child: child,
      transitionDuration: const Duration(milliseconds: 500),
      transitionsBuilder: (context, animation, _, child) => FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeOut),
        child: child,
      ),
    );

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  routes: [
    GoRoute(
      path: '/splash',
      pageBuilder: (context, state) =>
          _fadePage(state.pageKey, const SplashScreen()),
    ),
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) =>
          _fadePage(state.pageKey, const OnboardingPage()),
    ),
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => CustomTransitionPage<void>(
        key: state.pageKey,
        child: const LoginScreen(),
        transitionDuration: const Duration(milliseconds: 400),
        transitionsBuilder: (context, animation, _, child) => SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.15),
            end: Offset.zero,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutCubic,
          )),
          child: FadeTransition(
            opacity: animation,
            child: child,
          ),
        ),
      ),
    ),
    ShellRoute(
      navigatorKey: _shellNavigatorKey,
      builder: (context, state, child) => AppBottomNav(child: child),
      routes: [
        GoRoute(
          path: '/home',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: HomePage(),
          ),
        ),
        GoRoute(
          path: '/pet',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: PetScreen(),
          ),
        ),
        GoRoute(
          path: '/stats',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: StatsPage(),
          ),
        ),
        GoRoute(
          path: '/settings',
          pageBuilder: (context, state) => const NoTransitionPage(
            child: SettingsPage(),
          ),
        ),
      ],
    ),
    GoRoute(
      path: '/task/new',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const TaskFormPage(),
    ),
    GoRoute(
      path: '/task/:id',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return TaskFormPage(taskId: id);
      },
    ),
    GoRoute(
      path: '/settings/edit-profile',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) => const EditProfilePage(),
    ),
    GoRoute(
      path: '/pet/select',
      parentNavigatorKey: _rootNavigatorKey,
      builder: (context, state) {
        final isOnboarding = state.extra as bool? ?? false;
        return PetSelectionPage(isOnboarding: isOnboarding);
      },
    ),
  ],
);
