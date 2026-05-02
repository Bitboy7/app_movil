import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  final Widget child;
  const AppBottomNav({super.key, required this.child});

  static const _routes = ['/home', '/pet', '/stats', '/settings'];
  static const _labels = ['Inicio', 'Mascota', 'Stats', 'Ajustes'];
  static const _icons = [
    Icons.home_outlined,
    Icons.favorite_outline_rounded,
    Icons.bar_chart_outlined,
    Icons.settings_outlined,
  ];
  static const _selectedIcons = [
    Icons.home_rounded,
    Icons.favorite_rounded,
    Icons.bar_chart_rounded,
    Icons.settings_rounded,
  ];

  int _indexFromLocation(String location) {
    if (location.startsWith('/home')) return 0;
    if (location.startsWith('/pet')) return 1;
    if (location.startsWith('/stats')) return 2;
    if (location.startsWith('/settings')) return 3;
    return 0;
  }

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
        child: _ExpandableNavBarContent(currentIndex: currentIndex),
      ),
    );
  }
}

class _ExpandableNavBarContent extends StatelessWidget {
  final int currentIndex;
  const _ExpandableNavBarContent({required this.currentIndex});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 64,
      child: Row(
        children: List.generate(AppBottomNav._routes.length, (index) {
          final isSelected = index == currentIndex;
          return Expanded(
            child: GestureDetector(
              onTap: () => context.go(AppBottomNav._routes[index]),
              behavior: HitTestBehavior.opaque,
              child: Center(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 350),
                  curve: Curves.easeInOutCubic,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.12)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      AnimatedScale(
                        scale: isSelected ? 1.0 : 0.85,
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 250),
                          switchInCurve: Curves.easeOut,
                          switchOutCurve: Curves.easeIn,
                          transitionBuilder: (child, animation) =>
                              ScaleTransition(scale: animation, child: child),
                          child: Icon(
                            key: ValueKey(
                              isSelected
                                  ? AppBottomNav._selectedIcons[index]
                                  : AppBottomNav._icons[index],
                            ),
                            isSelected
                                ? AppBottomNav._selectedIcons[index]
                                : AppBottomNav._icons[index],
                            size: 24,
                            color: isSelected
                                ? AppColors.primary
                                : theme.colorScheme.onSurface.withValues(alpha: 0.35),
                          ),
                        ),
                      ),
                      ClipRect(
                        child: AnimatedSize(
                          duration: const Duration(milliseconds: 350),
                          curve: Curves.easeInOutCubic,
                          alignment: Alignment.centerLeft,
                          child: isSelected
                              ? Padding(
                                  padding: const EdgeInsets.only(left: 5),
                                  child: ConstrainedBox(
                                    constraints: const BoxConstraints(maxWidth: 48),
                                    child: Text(
                                      AppBottomNav._labels[index],
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.primary,
                                      ),
                                    ),
                                  ),
                                )
                              : const SizedBox(width: 0),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
