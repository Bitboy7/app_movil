import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_duration.dart';
import '../../core/routing/hero_tags.dart';

class ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final double size;
  final VoidCallback? onTap;

  const ProfileAvatar({
    super.key,
    required this.photoUrl,
    this.size = 88,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final iconSize = size * 0.5;
    final IconData fallbackIcon = Icons.person_rounded;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedScale(
        scale: 1.0,
        duration: AppDuration.micro,
        curve: Curves.easeInOut,
        child: Hero(
          tag: HeroTags.profileAvatar,
          createRectTween: (begin, end) {
            return MaterialRectCenterArcTween(begin: begin, end: end);
          },
          flightShuttleBuilder: (
            flightContext,
            animation,
            flightDirection,
            fromHeroContext,
            toHeroContext,
          ) {
            return AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                final t = Curves.easeInOutCubic.transform(animation.value);
                return Transform.scale(
                  scale: 1.0 + (0.06 * (1 - (t - 0.5).abs() * 2)),
                  child: child,
                );
              },
              child: Material(
                color: Colors.transparent,
                elevation: 8,
                shadowColor: Colors.black.withValues(alpha: 0.25),
                child: ClipOval(
                  child: _buildAvatarContent(fallbackIcon, iconSize),
                ),
              ),
            );
          },
          child: Material(
            color: Colors.transparent,
            child: _buildAvatarContent(fallbackIcon, iconSize),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatarContent(IconData fallbackIcon, double iconSize) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: photoUrl == null ? AppColors.gradientWarm : null,
        color: photoUrl != null ? AppColors.primary.withValues(alpha: 0.1) : null,
        shape: BoxShape.circle,
        border: photoUrl != null
            ? Border.all(
                color: AppColors.primary.withValues(alpha: 0.2),
                width: 2,
              )
            : null,
        image: photoUrl != null
            ? DecorationImage(
                image: photoUrl!.startsWith('http')
                    ? NetworkImage(photoUrl!) as ImageProvider
                    : FileImage(File(photoUrl!)),
                fit: BoxFit.cover,
              )
            : null,
      ),
      child: photoUrl == null
          ? Icon(fallbackIcon, size: iconSize, color: Colors.white)
          : null,
    );
  }
}