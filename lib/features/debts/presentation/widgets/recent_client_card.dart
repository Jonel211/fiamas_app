import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../customers/data/models/cliente_model.dart';

class RecentClientCard extends StatelessWidget {
  const RecentClientCard({
    super.key,
    required this.name,
    required this.phone,
    this.imageUrl,
    required this.score,
    required this.categoria,
    this.onTap,
  });

  final String name;
  final String phone;
  final String? imageUrl;
  final int score;
  final String categoria;
  final VoidCallback? onTap;

  String get _initials {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return 'C';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final nivel = nivelScore(score, categoria);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.mist),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.mist,
                shape: BoxShape.circle,
                image: (imageUrl != null && imageUrl!.isNotEmpty)
                    ? DecorationImage(
                        image: NetworkImage(imageUrl!),
                        fit: BoxFit.cover,
                        onError: (_, _) {},
                      )
                    : null,
              ),
              child: (imageUrl != null && imageUrl!.isNotEmpty)
                  ? null
                  : Text(
                      _initials,
                      style: const TextStyle(
                        color: AppColors.ink,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    phone,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: nivel.color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                nivel.etiqueta,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: nivel.color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}