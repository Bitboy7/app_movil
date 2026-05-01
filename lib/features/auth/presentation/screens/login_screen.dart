import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../domain/models/user.dart';
import '../providers/auth_providers.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _gradientController;
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void initState() {
    super.initState();
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) return;

    await ref.read(authProvider.notifier).login(email, password);

    if (mounted && context.mounted) {
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authProvider);
    final isLoading = authState.status == AuthStatus.loading;

    return Scaffold(
      body: Stack(
        children: [
          AnimatedBuilder(
            animation: _gradientController,
            builder: (context, _) {
              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(
                      -0.5 + _gradientController.value * 0.5,
                      -0.3 + _gradientController.value * 0.3,
                    ),
                    end: Alignment(
                      0.5 - _gradientController.value * 0.5,
                      0.8 - _gradientController.value * 0.3,
                    ),
                    colors: const [
                      AppColors.primaryDark,
                      AppColors.primary,
                      AppColors.secondary,
                    ],
                  ),
                ),
              );
            },
          ),

          SafeArea(
            child: Column(
              children: [
                Expanded(
                  flex: 4,
                  child: Stack(
                    children: [
                      Positioned(
                        top: 10,
                        left: 20,
                        child: AnimatedBuilder(
                          animation: _gradientController,
                          builder: (context, _) => Container(
                            width: 70 + _gradientController.value * 25,
                            height: 70 + _gradientController.value * 25,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(
                                alpha: 0.06 + _gradientController.value * 0.04,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        top: 50,
                        right: 30,
                        child: AnimatedBuilder(
                          animation: _gradientController,
                          builder: (context, _) => Container(
                            width: 45 + _gradientController.value * 15,
                            height: 45 + _gradientController.value * 15,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(
                                alpha: 0.05 + _gradientController.value * 0.03,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 30,
                        left: 50,
                        child: AnimatedBuilder(
                          animation: _gradientController,
                          builder: (context, _) => Container(
                            width: 55 + _gradientController.value * 20,
                            height: 55 + _gradientController.value * 20,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(
                                alpha: 0.07 + _gradientController.value * 0.03,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 10,
                        right: 50,
                        child: AnimatedBuilder(
                          animation: _gradientController,
                          builder: (context, _) => Container(
                            width: 35 + _gradientController.value * 10,
                            height: 35 + _gradientController.value * 10,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withValues(
                                alpha: 0.04 + _gradientController.value * 0.02,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(22),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: const Icon(
                                Icons.pets_rounded,
                                size: 52,
                                color: Colors.white,
                              ),
                            ).animate().scale(
                              delay: 200.ms,
                              duration: 800.ms,
                              begin: const Offset(0.01, 0.01),
                              curve: Curves.elasticOut,
                            ),
                            const SizedBox(height: 20),
                            Text(
                              'Bibu',
                              style: theme.textTheme.headlineMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.2,
                              ),
                            ).animate().fadeIn(delay: 100.ms, duration: 500.ms).slideY(begin: 0.2),
                            const SizedBox(height: 8),
                            Text(
                              'Tu rutina con vida',
                              style: theme.textTheme.bodyLarge?.copyWith(
                                color: Colors.white.withValues(alpha: 0.85),
                                letterSpacing: 0.5,
                              ),
                            ).animate().fadeIn(delay: 200.ms, duration: 500.ms).slideY(begin: 0.2),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  flex: 6,
                  child: Container(
                    decoration: BoxDecoration(
                      color: theme.scaffoldBackgroundColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(36),
                        topRight: Radius.circular(36),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Iniciar Sesión',
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ).animate().fadeIn(duration: 400.ms).slideX(begin: -0.05),

                          const SizedBox(height: 8),

                          Text(
                            'Accede para sincronizar tu progreso',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.textSecondaryLight,
                            ),
                          ).animate().fadeIn(delay: 100.ms, duration: 400.ms).slideX(begin: -0.05),

                          const SizedBox(height: 32),

                          TextField(
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            decoration: InputDecoration(
                              labelText: 'Correo electrónico',
                              prefixIcon: const Icon(Icons.email_rounded),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ).animate().fadeIn(delay: 150.ms, duration: 400.ms).slideY(begin: 0.1),

                          const SizedBox(height: 16),

                          TextField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Contraseña',
                              prefixIcon: const Icon(Icons.lock_rounded),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_rounded
                                      : Icons.visibility_rounded,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscurePassword = !_obscurePassword;
                                  });
                                },
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                          ).animate().fadeIn(delay: 250.ms, duration: 400.ms).slideY(begin: 0.1),

                          const SizedBox(height: 8),

                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {},
                              child: const Text('¿Olvidaste tu contraseña?'),
                            ),
                          ),

                          const SizedBox(height: 8),

                          SizedBox(
                            width: double.infinity,
                            height: 56,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                gradient: AppColors.gradientWarm,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.primary.withValues(alpha: 0.3),
                                    blurRadius: 12,
                                    offset: const Offset(0, 4),
                                  ),
                                ],
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: isLoading ? null : _handleLogin,
                                  borderRadius: BorderRadius.circular(16),
                                  child: Center(
                                    child: isLoading
                                        ? const SizedBox(
                                            width: 24,
                                            height: 24,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2.5,
                                            ),
                                          )
                                        : const Text(
                                            'Iniciar Sesión',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 17,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                  ),
                                ),
                              ),
                            ),
                          ).animate().fadeIn(delay: 350.ms, duration: 400.ms).scaleXY(begin: 0.95),

                          const SizedBox(height: 28),

                          Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  'o continúa con',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: AppColors.textTertiaryLight,
                                  ),
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),

                          const SizedBox(height: 24),

                          Row(
                            children: [
                              Expanded(child: _buildGoogleButton(theme)),
                              const SizedBox(width: 16),
                              Expanded(child: _buildAppleButton(theme)),
                            ],
                          ),

                          const SizedBox(height: 28),

                          Center(
                            child: TextButton(
                              onPressed: () => context.pop(),
                              style: TextButton.styleFrom(
                                foregroundColor: AppColors.textSecondaryLight,
                              ),
                              child: const Text('Quizás más tarde'),
                            ),
                          ).animate().fadeIn(delay: 500.ms),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleButton(ThemeData theme) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FaIcon(FontAwesomeIcons.google, size: 20),
          const SizedBox(width: 10),
          Text(
            'Google',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppleButton(ThemeData theme) {
    return OutlinedButton(
      onPressed: () {},
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const FaIcon(FontAwesomeIcons.apple, size: 22),
          const SizedBox(width: 10),
          Text(
            'Apple',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
