import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/data/models/tienda_model.dart';

class StoreListItem extends StatelessWidget {
  const StoreListItem({
    super.key,
    required this.store,
    this.onTap,
    this.onEdit,
  });

  final TiendaModel store;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  static const double _circleSize = 120;

  Widget _fallbackIcon() {
    return const Icon(
      Icons.storefront_rounded,
      color: AppColors.ink,
      size: 54,
    );
  }

  Widget _circleContent() {
    final url = store.logoUrl;
    if (url == null || url.isEmpty) return _fallbackIcon();

    return Image.network(
      url,
      key: ValueKey(url),
      width: _circleSize,
      height: _circleSize,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallbackIcon(),
    );
  }

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
                Container(
                  width: _circleSize,
                  height: _circleSize,
                  alignment: Alignment.center,
                  clipBehavior: Clip.antiAlias,
                  decoration: const BoxDecoration(
                    color: AppColors.skyBlue,
                    shape: BoxShape.circle,
                  ),
                  child: _circleContent(),
                ),
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
          const SizedBox(height: 8),
          Flexible(
            child: Text(
              store.nombre,
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
          ),
          const SizedBox(height: 2),
          Flexible(
            child: Text(
              store.direccion ?? 'Sin dirección',
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 13, color: AppColors.inkMuted),
            ),
          ),
        ],
      ),
    );
  }
}