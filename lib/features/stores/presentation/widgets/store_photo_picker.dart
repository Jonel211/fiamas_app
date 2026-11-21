import 'dart:io';

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_avatar.dart';

class StorePhotoPicker extends StatelessWidget {
  const StorePhotoPicker({
    super.key,
    this.onTap,
    this.imageUrl,
    this.localFile,
  });

  final VoidCallback? onTap;
  final String? imageUrl;
  final File? localFile;

  static const double _circleSize = 110;

  Widget _content() {
    if (localFile != null) {
      return Image.file(
        localFile!,
        width: _circleSize,
        height: _circleSize,
        fit: BoxFit.cover,
      );
    }
    return AppAvatar(
      imageUrl: imageUrl,
      name: '',
      size: _circleSize,
      backgroundColor: AppColors.mist,
      foregroundColor: AppColors.ink,
      fallback: const Icon(
        Icons.photo_camera_outlined,
        color: AppColors.ink,
        size: 44,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: _circleSize,
            height: _circleSize,
            alignment: Alignment.center,
            clipBehavior: Clip.antiAlias,
            decoration: const BoxDecoration(
              color: AppColors.mist,
              shape: BoxShape.circle,
            ),
            child: _content(),
          ),
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