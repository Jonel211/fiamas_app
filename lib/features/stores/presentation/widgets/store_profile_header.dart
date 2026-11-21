import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/zoomable_image.dart';

class StoreProfileHeader extends StatelessWidget {
  final String? logoUrl;

  const StoreProfileHeader({super.key, this.logoUrl});

  static const double _logoSize = 80;

  @override
  Widget build(BuildContext context) {
    final logoWidget = AppAvatar(
      imageUrl: logoUrl,
      name: '',
      size: _logoSize,
      backgroundColor: Colors.white,
      foregroundColor: AppColors.teal,
      borderColor: AppColors.teal.withValues(alpha: 0.45),
      borderWidth: 1,
      fallback: const Icon(
        Icons.storefront_rounded,
        size: 40,
        color: AppColors.teal,
      ),
    );

    if (logoUrl == null || logoUrl!.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: logoWidget,
        ),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: ZoomableImage(imageUrl: logoUrl!, image: logoWidget),
      ),
    );
  }
}
