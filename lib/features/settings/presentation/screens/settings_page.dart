import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:io';
import '../../../../core/theme/app_colors.dart';
import '../providers/settings_providers.dart';
import '../providers/profile_providers.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDarkMode = ref.watch(isDarkModeProvider);
    final userName = ref.watch(userNameProvider);
    final userEmail = ref.watch(userEmailProvider);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Ajustes'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildProfileSection(context, ref, userName, userEmail, ref.watch(userPhotoUrlProvider)),
            const SizedBox(height: 32),
            _buildSectionTitle(context, 'Preferencias'),
            const SizedBox(height: 16),
            _buildSettingsCard(
              context,
              children: [
                _buildSwitchTile(
                  context,
                  icon: Icons.dark_mode_rounded,
                  title: 'Modo Oscuro',
                  subtitle: 'Cambia la apariencia de la app',
                  value: isDarkMode,
                  onChanged: (_) => ref.read(themeModeProvider.notifier).toggleDarkMode(),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(context, 'Cuenta'),
            const SizedBox(height: 16),
            _buildSettingsCard(
              context,
              children: [
                _buildTapTile(
                  context,
                  icon: Icons.person_rounded,
                  title: 'Editar Perfil',
                  subtitle: 'Actualiza tu información personal',
                  onTap: () => context.push('/settings/edit-profile'),
                ),
                const Divider(height: 1),
                _buildTapTile(
                  context,
                  icon: Icons.lock_rounded,
                  title: 'Privacidad',
                  subtitle: 'Gestiona tus datos',
                  onTap: () => _showComingSoonSnackBar(context),
                ),
                const Divider(height: 1),
                _buildTapTile(
                  context,
                  icon: Icons.language_rounded,
                  title: 'Idioma',
                  subtitle: 'Español',
                  onTap: () => _showComingSoonSnackBar(context),
                ),
              ],
            ),
            const SizedBox(height: 32),
            _buildSectionTitle(context, 'Acerca de'),
            const SizedBox(height: 16),
            _buildSettingsCard(
              context,
              children: [
                _buildTapTile(
                  context,
                  icon: Icons.info_rounded,
                  title: 'Acerca de Bibu',
                  subtitle: 'Versión 1.0.0',
                  onTap: () => _showAboutDialog(context),
                ),
                const Divider(height: 1),
                _buildTapTile(
                  context,
                  icon: Icons.description_rounded,
                  title: 'Términos y Condiciones',
                  subtitle: 'Lee nuestros términos',
                  onTap: () => _showComingSoonSnackBar(context),
                ),
                const Divider(height: 1),
                _buildTapTile(
                  context,
                  icon: Icons.privacy_tip_rounded,
                  title: 'Política de Privacidad',
                  subtitle: 'Cómo protegemos tus datos',
                  onTap: () => _showComingSoonSnackBar(context),
                ),
              ],
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _showLogoutConfirmation(context),
                icon: const Icon(Icons.logout_rounded),
                label: const Text('Cerrar Sesión'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileSection(BuildContext context, WidgetRef ref, String name, String email, String? photoUrl) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.gradientWarm,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              image: photoUrl != null
                  ? DecorationImage(
                      image: FileImage(File(photoUrl)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: photoUrl == null
                ? const Icon(Icons.person_rounded, size: 40, color: Colors.white)
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  email,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.push('/settings/edit-profile'),
            icon: const Icon(Icons.edit_rounded, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: theme.textTheme.titleMedium?.copyWith(
          color: AppColors.textTertiaryLight,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(BuildContext context, {required List<Widget> children}) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
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
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: AppColors.primary, size: 22),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text(subtitle, style: theme.textTheme.bodySmall),
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
  }) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: AppColors.primary, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 2),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppColors.textTertiaryLight),
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

  void _showLogoutConfirmation(BuildContext context) {
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
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Cerrar Sesión'),
          ),
        ],
      ),
    );
  }
}