import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final _pageController = PageController();
  int _currentPage = 0;

  static const _pages = [
    _OnboardingContent(
      lottiePath: 'assets/lottie/checklist.json',
      title: 'Crea tu rutina diaria',
      description:
          'Organiza tus tareas con horarios y categorías. Construye hábitos que transformen tu día a día.',
      color: AppColors.primary,
      bgTop: AppColors.primaryDark,
      bgBottom: AppColors.primaryLight,
    ),
    _OnboardingContent(
      lottiePath: 'assets/lottie/Hatch.json',
      title: 'Conoce a tu compañero',
      description:
          'Un pequeño amigo que evoluciona contigo. Completa tareas para ganar XP, monedas y desbloquear accesorios.',
      color: AppColors.secondary,
      bgTop: Color(0xFFE84A72),
      bgBottom: AppColors.secondaryLight,
    ),
    _OnboardingContent(
      lottiePath: 'assets/lottie/progress.json',
      title: 'Mejora cada día',
      description:
          '¡Tu disciplina tiene recompensa! Mantén tu racha, sube de nivel y personaliza a tu personaje.',
      color: AppColors.accent,
      bgTop: Color(0xFF0DA8B8),
      bgBottom: AppColors.accentLight,
    ),
  ];

  Future<void> _complete() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_done', true);
    if (!mounted) return;
    context.go('/home');
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOut,
      );
    } else {
      _complete();
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
    final size = MediaQuery.sizeOf(context);
    final page = _pages[_currentPage];

    return Scaffold(
      body: Stack(
        children: [
          // Animated colored background for the top area
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              height: size.height * 0.54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [page.bgTop, page.bgBottom],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(48),
                  bottomRight: Radius.circular(48),
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Skip button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: _currentPage < _pages.length - 1 ? 1.0 : 0.0,
                        child: TextButton(
                          onPressed:
                              _currentPage < _pages.length - 1 ? _complete : null,
                          child: const Text(
                            'Omitir',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // Illustration — PageView for horizontal swipe gesture
                SizedBox(
                  height: size.height * 0.42,
                  child: PageView.builder(
                    controller: _pageController,
                    onPageChanged: (i) => setState(() => _currentPage = i),
                    itemCount: _pages.length,
                    itemBuilder: (context, index) {
                      final p = _pages[index];
                      return Center(
                        child: Container(
                          width: 200,
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.2),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.white.withValues(alpha: 0.35),
                                blurRadius: 64,
                                spreadRadius: 18,
                              ),
                            ],
                          ),
                          child: Lottie.asset(
                            p.lottiePath,
                            width: 180,
                            height: 180,
                            repeat: true,
                          ),
                        )
                            .animate()
                            .scale(
                              duration: 600.ms,
                              curve: Curves.elasticOut,
                              begin: const Offset(0.5, 0.5),
                            )
                            .fadeIn(duration: 300.ms),
                      );
                    },
                  ),
                ),

                // Text area — AnimatedSwitcher re-animates on every page change
                Expanded(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween<Offset>(
                          begin: const Offset(0, 0.12),
                          end: Offset.zero,
                        ).animate(CurvedAnimation(
                          parent: animation,
                          curve: Curves.easeOut,
                        )),
                        child: child,
                      ),
                    ),
                    child: Padding(
                      key: ValueKey(_currentPage),
                      padding: const EdgeInsets.symmetric(horizontal: 40),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            page.title,
                            style: theme.textTheme.displayMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            page.description,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.textTheme.bodyMedium?.color,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Dots + button
                Padding(
                  padding: const EdgeInsets.fromLTRB(32, 0, 32, 40),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(_pages.length, (i) {
                          final isActive = _currentPage == i;
                          return AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            margin: const EdgeInsets.symmetric(horizontal: 4),
                            width: isActive ? 24 : 8,
                            height: 8,
                            decoration: BoxDecoration(
                              color: isActive
                                  ? _pages[i].color
                                  : _pages[i].color.withValues(alpha: 0.25),
                              borderRadius: BorderRadius.circular(4),
                              boxShadow: isActive
                                  ? [
                                      BoxShadow(
                                        color: _pages[i]
                                            .color
                                            .withValues(alpha: 0.55),
                                        blurRadius: 10,
                                        spreadRadius: 1,
                                      ),
                                    ]
                                  : [],
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          child: ElevatedButton(
                            onPressed: _nextPage,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: page.color,
                              padding:
                                  const EdgeInsets.symmetric(vertical: 18),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              _currentPage == _pages.length - 1
                                  ? 'Comenzar 🚀'
                                  : 'Siguiente',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _OnboardingContent {
  final String lottiePath;
  final String title;
  final String description;
  final Color color;
  final Color bgTop;
  final Color bgBottom;

  const _OnboardingContent({
    required this.lottiePath,
    required this.title,
    required this.description,
    required this.color,
    required this.bgTop,
    required this.bgBottom,
  });
}
