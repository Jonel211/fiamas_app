import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/store.dart';

/// Tarjeta vertical de una tienda.
/// Círculo con ilustración + botón de edición flotante + nombre + ciudad.
class StoreListItem extends StatelessWidget {
  const StoreListItem({
    super.key,
    required this.store,
    this.onTap,
    this.onEdit,
  });

  final Store store;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  static const double _circleSize = 140;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: _circleSize,
            height: _circleSize,
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                // Círculo con la imagen de la tienda
                Container(
                  width: _circleSize,
                  height: _circleSize,
                  decoration: const BoxDecoration(
                    color: AppColors.skyBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.storefront_rounded,
                    color: AppColors.ink,
                    size: 62,
                  ),
                ),

                // Botón de edición flotante (esquina superior derecha)
                Positioned(
                  top: 4,
                  right: -4,
                  child: Material(
                    color: AppColors.gold,
                    shape: const CircleBorder(),
                    elevation: 3,
                    child: InkWell(
                      onTap: onEdit,
                      customBorder: const CircleBorder(),
                      child: const Padding(
                        padding: EdgeInsets.all(8),
                        child: Icon(
                          Icons.edit_rounded,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            store.name,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.ink,
              height: 1.2,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            store.city,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}