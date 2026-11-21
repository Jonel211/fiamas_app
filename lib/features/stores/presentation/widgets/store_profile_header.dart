import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/zoomable_image.dart';

class StoreProfileHeader extends StatelessWidget {
  final String? logoUrl;
  final String nombre;

  const StoreProfileHeader({
    super.key,
    this.logoUrl,
    this.nombre = '',
  });

  static const double _logoSize = 80;

  @override
  Widget build(BuildContext context) {
    final logoWidget = AppAvatar(
      imageUrl: logoUrl,
      name: nombre,
      size: _logoSize,
      backgroundColor: Colors.white,
      foregroundColor: AppColors.teal,
      borderColor: AppColors.teal.withValues(alpha: 0.45),
      borderWidth: 1,
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
