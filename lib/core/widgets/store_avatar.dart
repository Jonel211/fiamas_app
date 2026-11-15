import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

/// Avatar circular para una tienda.
///
/// Muestra la imagen cuando [imageUrl] es válida y cae a la inicial del
/// nombre cuando no hay imagen o la URL falla.
class StoreAvatar extends StatelessWidget {
  const StoreAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 40,
  });

  final String? imageUrl;
  final String name;
  final double size;

  String get _initial {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
  }

  Widget _fallback() {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        color: AppColors.gold,
        shape: BoxShape.circle,
      ),
      child: Text(
        _initial,
        style: TextStyle(
          color: AppColors.ink,
          fontSize: size * 0.45,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final url = imageUrl?.trim();
    if (url == null || url.isEmpty) return _fallback();

    return ClipOval(
      child: SizedBox(
        width: size,
        height: size,
        child: Image.network(
          url,
          key: ValueKey(url),
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _fallback(),
          loadingBuilder: (context, child, progress) =>
              progress == null ? child : _fallback(),
        ),
      ),
    );
  }
}
