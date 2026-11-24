import 'package:flutter/material.dart';

import 'app_avatar.dart';

/// Foto de la tienda en formato cuadrado con bordes redondeados.
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

  @override
  Widget build(BuildContext context) {
    return AppAvatar.tienda(
      imageUrl: imageUrl,
      name: name,
      size: size,
      borderRadius: BorderRadius.circular(size * 0.26),
    );
  }
}
