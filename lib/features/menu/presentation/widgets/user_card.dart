import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_avatar.dart';

/// Tarjeta de usuario con avatar, nombre y teléfono.
/// Si recibe [onTap], toda la tarjeta es tocable.
class UserCard extends StatelessWidget {
  const UserCard({
    super.key,
    required this.name,
    required this.phone,
    this.imageUrl,
    this.onTap,
  });

  final String name;
  final String phone;
  final String? imageUrl;
  final VoidCallback? onTap;

  static const double _avatarSize = 52;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.mist),
          ),
          child: Row(
            children: [
              // Avatar circular con la foto del tendero o sus iniciales
              AppAvatar.tendero(
                imageUrl: imageUrl,
                name: name,
                size: _avatarSize,
              ),
              const SizedBox(width: 14),
              // Nombre + teléfono
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      phone,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.chevron_right, color: AppColors.inkMuted),
            ],
          ),
        ),
      ),
    );
  }
}