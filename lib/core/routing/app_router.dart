import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/routine/presentation/screens/home_page.dart';
import '../../features/routine/presentation/screens/task_form_page.dart';
import '../../features/pet/presentation/screens/pet_screen.dart';
import '../../features/stats/presentation/screens/stats_page.dart';
import '../../features/onboarding/presentation/onboarding_page.dart';
import '../../shared/widgets/app_bottom_nav.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();
final _shellNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/home',
  routes: [
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingPage(),
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
  ],
);
