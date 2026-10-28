import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'profile_avatar.dart';
import 'profile_badge.dart';

/// Tarjeta superior del perfil: avatar, nombre, correo y estado.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.name,
    required this.email,
    this.imageUrl,
    this.verified = true,
    this.onChangePhoto,
  });

  final String name;
  final String email;
  final String? imageUrl;
  final bool verified;
  final VoidCallback? onChangePhoto;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 28, 20, 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          ProfileAvatar(
            name: name,
            imageUrl: imageUrl,
            onChangePhoto: onChangePhoto,
          ),
          const SizedBox(height: 18),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.ink),
          ),
          const SizedBox(height: 4),
          Text(email, style: const TextStyle(fontSize: 13, color: AppColors.inkMuted)),
          if (verified) ...[
            const SizedBox(height: 14),
            const ProfileBadge(
              label: 'Cuenta verificada',
              icon: Icons.verified_outlined,
              large: true,
            ),
          ],
        ],
      ),
    );
  }
}