import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Selector de foto de tienda: círculo gris con cámara grande
/// y badge dorado de edición en la esquina superior derecha.
class StorePhotoPicker extends StatelessWidget {
  const StorePhotoPicker({super.key, this.onTap});

  final VoidCallback? onTap;

  static const double _circleSize = 110;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Círculo con cámara
          Container(
            width: _circleSize,
            height: _circleSize,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.mist,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.photo_camera_outlined,
              color: AppColors.ink,
              size: 44,
            ),
          ),

          // Badge dorado de edición (esquina superior derecha)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 32,
              height: 32,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                color: AppColors.gold,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.edit_rounded,
                color: Colors.white,
                size: 15,
              ),
            ),
          ),
        ],
      ),
    );
  }
}