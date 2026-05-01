import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final Widget child;
  const AppBottomNav({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.path;
    final currentIndex = _indexFromLocation(location);

    return Scaffold(
      body: child,
      floatingActionButton: Container(
        margin: const EdgeInsets.only(top: 8),
        child: FloatingActionButton(
          backgroundColor: AppColors.primary,
          onPressed: () => context.push('/task/new'),
          elevation: 8,
          shape: const CircleBorder(),
          child: const Icon(Icons.add_rounded, color: Colors.white, size: 28),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      extendBody: true,
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            final routes = ['/home', '/pet', '/stats', '/settings'];
            context.go(routes[index]);
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          height: 64,
          indicatorColor: AppColors.primary.withValues(alpha: 0.12),
          labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'Inicio',
            ),
            NavigationDestination(
              icon: Icon(Icons.favorite_outline_rounded),
              selectedIcon: Icon(Icons.favorite_rounded),
              label: 'Mascota',
            ),
            NavigationDestination(
              icon: Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart_rounded),
              label: 'Stats',
            ),
            NavigationDestination(
              icon: Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded),
              label: 'Ajustes',
            ),
          ],
        ),
      ),
    );
  }

  int _indexFromLocation(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/pet')) return 1;
    if (location.startsWith('/stats')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }
}