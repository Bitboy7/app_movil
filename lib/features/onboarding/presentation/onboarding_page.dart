import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart' show AppColors;

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  final _pages = [
    _OnboardingContent(
      emoji: '🌅',
      title: 'Crea tu rutina diaria',
      description:
          'Organiza tus tareas con horarios y categorías. Construye hábitos que transformen tu día a día.',
      color: AppColors.primary,
    ),
    _OnboardingContent(
      emoji: '🐣',
      title: 'Conoce a tu compañero',
      description:
          'Un pequeño amigo que evoluciona contigo. Completa tareas para ganar XP, monedas y desbloquear accesorios.',
      color: AppColors.secondary,
    ),
    _OnboardingContent(
      emoji: '✨',
      title: 'Mejora cada día',
      description:
          'Mantén tu racha, sube de nivel y personaliza a tu personaje. ¡Tu disciplina tiene recompensa!',
      color: AppColors.accent,
    ),
  ];

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: 400.ms,
        curve: Curves.easeOut,
      );
    } else {
      context.go('/home');
    }
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 1),
            Expanded(
              flex: 6,
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemCount: _pages.length,
                itemBuilder: (context, index) {
                  final page = _pages[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                page.color.withValues(alpha: 0.15),
                                page.color.withValues(alpha: 0.05),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(page.emoji,
                                style: const TextStyle(fontSize: 64)),
                          ),
                        ).animate().scale(
                            duration: 600.ms,
                            curve: Curves.elasticOut,
                            begin: const Offset(0.5, 0.5)),
                        const SizedBox(height: 40),
                        Text(page.title,
                            style: theme.textTheme.displayMedium,
                            textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        Text(page.description,
                            style: theme.textTheme.bodyLarge?.copyWith(
                                color: theme.textTheme.bodyMedium?.color),
                            textAlign: TextAlign.center),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_pages.length, (i) {
                      return AnimatedContainer(
                        duration: 300.ms,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: _currentPage == i ? 24 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _currentPage == i
                              ? _pages[i].color
                              : _pages[i].color.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextPage,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _pages[_currentPage].color,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16)),
                      ),
                      child: Text(
                        _currentPage == _pages.length - 1
                            ? 'Comenzar'
                            : 'Siguiente',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingContent {
  final String emoji;
  final String title;
  final String description;
  final Color color;

  const _OnboardingContent({
    required this.emoji,
    required this.title,
    required this.description,
    required this.color,
  });
}
