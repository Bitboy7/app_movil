import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../../../../core/theme/app_colors.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../providers/settings_providers.dart';
import '../providers/profile_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(isDarkModeProvider);
    final authState = ref.watch(authProvider);
    final isLoggedIn = authState.isLoggedIn;
    final userName = ref.watch(userNameProvider);
    final userEmail = ref.watch(userEmailProvider);
    final photoUrl = ref.watch(userPhotoUrlProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          isLoggedIn ? 'Perfil' : 'Ajustes',
          style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isLoggedIn) ...[
              const SizedBox(height: 8),
              _buildProfileHeader(context, userName, userEmail, photoUrl),
              const SizedBox(height: 32),
            ] else ...[
              const SizedBox(height: 8),
              _buildLoginPromptCard(context),
              const SizedBox(height: 32),
            ],
            _buildSectionTitle(context, 'Preferencias'),
            const SizedBox(height: 12),
            _buildSettingsCard(
              context,
              children: [
                _buildSwitchTile(
                  context,
                  icon: Icons.dark_mode_outlined,
                  title: 'Modo Oscuro',
                  subtitle: 'Cambia la apariencia de la app',
                  value: isDarkMode,
                  onChanged: (_) => ref.read(themeModeProvider.notifier).toggleDarkMode(),
                ),
                _buildDivider(),
                _buildTapTile(
                  context,
                  icon: Icons.notifications_outlined,
                  title: 'Notificaciones',
                  subtitle: 'Próximamente',
                  onTap: () => _showComingSoonSnackBar(context),
                  isPlaceholder: true,
                ),
                _buildDivider(),
                _buildTapTile(
                  context,
                  icon: Icons.language_outlined,
                  title: 'Idioma',
                  subtitle: 'Español',
                  onTap: () => _showComingSoonSnackBar(context),
                ),
              ],
            ),
            const SizedBox(height: 28),
            _buildSectionTitle(context, 'Cuenta'),
            const SizedBox(height: 12),
            _buildSettingsCard(
              context,
              children: [
                if (isLoggedIn)
                  _buildTapTile(
                    context,
                    icon: Icons.person_outline_rounded,
                    title: 'Editar Perfil',
                    subtitle: 'Actualiza tu información personal',
                    onTap: () => context.push('/settings/edit-profile'),
                  ),
                if (isLoggedIn) _buildDivider(),
                _buildTapTile(
                  context,
                  icon: Icons.lock_outline_rounded,
                  title: 'Privacidad',
                  subtitle: 'Gestiona tus datos',
                  onTap: () => _showComingSoonSnackBar(context),
                ),
                _buildDivider(),
                _buildTapTile(
                  context,
                  icon: Icons.shield_outlined,
                  title: 'Seguridad',
                  subtitle: 'Cambia tu contraseña',
                  onTap: () => _showComingSoonSnackBar(context),
                  isPlaceholder: true,
                ),
              ],
            ),
            const SizedBox(height: 28),
            _buildSectionTitle(context, 'Acerca de'),
            const SizedBox(height: 12),
            _buildSettingsCard(
              context,
              children: [
                _buildTapTile(
                  context,
                  icon: Icons.info_outline_rounded,
                  title: 'Acerca de Bibu',
                  subtitle: 'Versión 1.0.0',
                  onTap: () => _showAboutDialog(context),
                ),
                _buildDivider(),
                _buildTapTile(
                  context,
                  icon: Icons.description_outlined,
                  title: 'Términos y Condiciones',
                  subtitle: 'Lee nuestros términos',
                  onTap: () => _showComingSoonSnackBar(context),
                ),
                _buildDivider(),
                _buildTapTile(
                  context,
                  icon: Icons.privacy_tip_outlined,
                  title: 'Política de Privacidad',
                  subtitle: 'Cómo protegemos tus datos',
                  onTap: () => _showComingSoonSnackBar(context),
                ),
              ],
            ),
            const SizedBox(height: 28),
            if (isLoggedIn) ...[
              Center(
                child: GestureDetector(
                  onTap: () => _showLogoutConfirmation(context, ref),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'Cerrar Sesión',
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: AppColors.error,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(BuildContext context, String name, String email, String? photoUrl) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.2 : 0.04),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 2,
              ),
              image: photoUrl != null
                  ? DecorationImage(
                      image: FileImage(File(photoUrl)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: photoUrl == null
                ? Icon(Icons.person_rounded, size: 44, color: AppColors.primary)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: AppColors.textSecondaryLight,
            ),
          ),
          const SizedBox(height: 20),
          _buildEditProfileButton(context),
        ],
      ),
    );
  }

  Widget _buildEditProfileButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.gradientWarm,
        borderRadius: BorderRadius.circular(20),
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
          onTap: () => context.push('/settings/edit-profile'),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                Text(
                  'Editar Perfil',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: theme.textTheme.titleSmall?.copyWith(
          color: AppColors.textTertiaryLight,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required List<Widget> children}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.15 : 0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      indent: 60,
      endIndent: 16,
      color: AppColors.textTertiaryLight.withValues(alpha: 0.15),
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: AppColors.textSecondaryLight, size: 22),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.bodyLarge),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textTertiaryLight,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeTrackColor: AppColors.primary.withValues(alpha: 0.5),
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTapTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isPlaceholder = false,
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondaryLight, size: 22),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isPlaceholder
                          ? AppColors.textTertiaryLight.withValues(alpha: 0.6)
                          : AppColors.textTertiaryLight,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textTertiaryLight, size: 20),
          ],
        ),
      ),
    );
  }

  void _showComingSoonSnackBar(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Próximamente'),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.gradientWarm,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.pets_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Text('Bibu'),
          ],
        ),
        content: const Text(
          'Bibu es tu compañero de rutinas. Mantén tus hábitos mientras cuidas de tu mascota virtual.\n\nVersión 1.0.0',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginPromptCard(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        gradient: AppColors.gradientWarm,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_upload_rounded, size: 36, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            'Iniciar sesión',
            style: theme.textTheme.titleLarge?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Guarda tu progreso y sincroniza tus datos',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
            ),
          ),
          const SizedBox(height: 20),
          _buildLoginButton(context),
        ],
      ),
    );
  }

  Widget _buildLoginButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.push('/login'),
          borderRadius: BorderRadius.circular(20),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 10),
            child: Text(
              'Acceder',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutConfirmation(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Cerrar Sesión'),
        content: const Text('¿Estás seguro de que quieres cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(authProvider.notifier).logout();
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}
