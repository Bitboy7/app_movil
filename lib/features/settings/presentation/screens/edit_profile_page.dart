import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_duration.dart';
import '../../../../core/theme/app_easing.dart';
import '../../../../features/auth/presentation/providers/auth_providers.dart';
import '../../../../shared/widgets/profile_avatar.dart';
import '../providers/profile_providers.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  String? _photoUrl;
  bool _isLoading = false;
  bool _isGoogleUser = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    _isGoogleUser = ref.read(isGoogleUserProvider);
    await ref.read(profileEditProvider.notifier).loadProfile();
    final profileState = ref.read(profileEditProvider);
    _nameController.text = profileState.name;
    _emailController.text = profileState.email;
    setState(() {
      _photoUrl = profileState.photoUrl;
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final appDir = await getApplicationDocumentsDirectory();
      final fileName = 'profile_photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      final savedImage = await File(image.path).copy('${appDir.path}/$fileName');
      setState(() {
        _photoUrl = savedImage.path;
      });
    }
  }

  Future<void> _saveProfile() async {
    setState(() => _isLoading = true);
    if (_isGoogleUser) {
      await ref.read(profileEditProvider.notifier).savePhotoOnly(_photoUrl);
    } else {
      await ref.read(profileEditProvider.notifier).saveProfile(
            name: _nameController.text.trim(),
            email: _emailController.text.trim(),
            photoUrl: _photoUrl,
          );
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Editar Perfil'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Stack(
              children: [
                ProfileAvatar(
                  photoUrl: _photoUrl,
                  size: 100,
                  onTap: _pickImage,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(Icons.camera_alt_rounded, color: Colors.white, size: 16),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Toca para cambiar la foto',
              style: theme.textTheme.bodySmall,
            ).animate().fadeIn(
                  duration: AppDuration.standard,
                  delay: AppDuration.standard,
                  curve: AppEasing.appear,
                ),
            if (_isGoogleUser) ...[
              const SizedBox(height: 24),
              _buildGoogleInfoCard(context, isDark),
            ] else ...[
              const SizedBox(height: 32),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: const Icon(Icons.person_outline_rounded),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ).animate().fadeIn(
                    duration: AppDuration.standard,
                    delay: AppDuration.quick + AppDuration.micro,
                    curve: AppEasing.appear,
                  ).slideY(
                    begin: 0.1,
                    end: 0,
                    duration: AppDuration.standard,
                    delay: AppDuration.quick + AppDuration.micro,
                    curve: AppEasing.appear,
                  ),
              const SizedBox(height: 16),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  prefixIcon: const Icon(Icons.email_outlined),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                keyboardType: TextInputType.emailAddress,
              ).animate().fadeIn(
                    duration: AppDuration.standard,
                    delay: AppDuration.standard,
                    curve: AppEasing.appear,
                  ).slideY(
                    begin: 0.1,
                    end: 0,
                    duration: AppDuration.standard,
                    delay: AppDuration.standard,
                    curve: AppEasing.appear,
                  ),
            ],
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _saveProfile,
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : Text(_isGoogleUser ? 'Guardar foto' : 'Guardar cambios'),
              ),
            ).animate().fadeIn(
                  duration: AppDuration.standard,
                  delay: AppDuration.standard + AppDuration.micro,
                  curve: AppEasing.appear,
                ).slideY(
                  begin: 0.08,
                  end: 0,
                  duration: AppDuration.standard,
                  delay: AppDuration.standard + AppDuration.micro,
                  curve: AppEasing.appear,
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildGoogleInfoCard(BuildContext context, bool isDark) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.cardLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.lock_outline_rounded, size: 18, color: AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Cuenta de Google',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildDisabledField(
            icon: Icons.person_outline_rounded,
            label: 'Nombre',
            value: _nameController.text,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          _buildDisabledField(
            icon: Icons.email_outlined,
            label: 'Correo electrónico',
            value: _emailController.text,
            isDark: isDark,
          ),
          const SizedBox(height: 8),
          Text(
            'Tu nombre y correo están vinculados a tu cuenta de Google y no se pueden editar aquí.',
            style: theme.textTheme.bodySmall?.copyWith(
              color: isDark ? AppColors.textTertiaryDark : AppColors.textTertiaryLight,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(
          duration: AppDuration.standard,
          delay: AppDuration.quick + AppDuration.micro,
          curve: AppEasing.appear,
        ).slideY(
          begin: 0.08,
          end: 0,
          duration: AppDuration.standard,
          delay: AppDuration.quick + AppDuration.micro,
          curve: AppEasing.appear,
        );
  }

  Widget _buildDisabledField({
    required IconData icon,
    required String label,
    required String value,
    required bool isDark,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isDark ? AppColors.bgDark : AppColors.bgLight,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.textTertiaryLight),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.textTertiaryLight,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 14,
                    color: isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.lock_rounded, size: 14, color: AppColors.textTertiaryLight),
        ],
      ),
    );
  }
}