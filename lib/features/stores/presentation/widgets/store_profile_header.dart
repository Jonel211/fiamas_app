import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class StoreProfileHeader extends StatelessWidget {
  final String? logoUrl;

  const StoreProfileHeader({super.key, this.logoUrl});

  static const double _logoSize = 80;

  Widget _fallbackIcon() {
    return const Icon(Icons.storefront_rounded, size: 40, color: AppColors.teal);
  }

  Widget _logo() {
    if (logoUrl == null || logoUrl!.isEmpty) return _fallbackIcon();

    return Image.network(
      logoUrl!,
      key: ValueKey(logoUrl),
      width: _logoSize,
      height: _logoSize,
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => _fallbackIcon(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Container(
          width: _logoSize,
          height: _logoSize,
          alignment: Alignment.center,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            border: Border.all(color: AppColors.teal.withValues(alpha: 0.45)),
          ),
          child: _logo(),
        ),
      ),
    );
  }
}
