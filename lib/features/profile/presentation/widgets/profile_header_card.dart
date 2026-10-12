import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'profile_badge.dart';

/// Tarjeta superior del perfil: avatar con inicial, nombre, correo y estado.
class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({
    super.key,
    required this.name,
    required this.email,
    this.verified = true,
    this.onChangePhoto,
  });

  static const double _avatarSize = 96;

  final String name;
  final String email;
  final bool verified;
  final VoidCallback? onChangePhoto;

  String get _initial {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
  }

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
          // Avatar con botón de cámara
          SizedBox(
            width: _avatarSize,
            height: _avatarSize,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: _avatarSize,
                  height: _avatarSize,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    _initial,
                    style: const TextStyle(
                      fontSize: 42,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
                Positioned(
                  right: -4,
                  bottom: -4,
                  child: Material(
                    color: AppColors.surface,
                    shape: const CircleBorder(),
                    elevation: 2,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onChangePhoto,
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.photo_camera_outlined,
                          size: 18,
                          color: AppColors.teal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text(
            name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(fontSize: 13, color: AppColors.inkMuted),
          ),
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