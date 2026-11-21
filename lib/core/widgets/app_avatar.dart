import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../utils/image_url.dart';

/// Avatar circular reutilizable para tenderos, tiendas y clientes.
class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 40,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderWidth = 0,
    this.fontSize,
    this.fallback,
  });

  const AppAvatar.tendero({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 40,
    this.borderColor,
    this.borderWidth = 0,
    this.fontSize,
    this.fallback,
  }) : backgroundColor = AppColors.teal,
       foregroundColor = Colors.white;

  const AppAvatar.cliente({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 40,
    this.borderColor,
    this.borderWidth = 0,
    this.fontSize,
    this.fallback,
  }) : backgroundColor = AppColors.teal,
       foregroundColor = Colors.white;

  const AppAvatar.tienda({
    super.key,
    this.imageUrl,
    required this.name,
    this.size = 40,
    this.borderColor,
    this.borderWidth = 0,
    this.fontSize,
    this.fallback,
  }) : backgroundColor = AppColors.gold,
       foregroundColor = AppColors.ink;

  final String? imageUrl;
  final String name;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final double borderWidth;
  final double? fontSize;

  /// Permite conservar un ícono propio (por ejemplo, el logo de una tienda)
  /// cuando no hay imagen. Si es null se usan las iniciales.
  final Widget? fallback;

  String get _initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();

    final first = parts.first.substring(0, 1);
    final last = parts.last.substring(0, 1);
    return (first + last).toUpperCase();
  }

  Widget _fallbackContent(Color foreground) {
    if (fallback != null) return Center(child: fallback);

    return Center(
      child: Text(
        _initials,
        maxLines: 1,
        style: TextStyle(
          color: foreground,
          fontSize: fontSize ?? size * 0.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final background = backgroundColor ?? AppColors.teal;
    final foreground = foregroundColor ?? AppColors.onBrand;
    final url = resolveImageUrl(imageUrl);
    final border = borderWidth > 0
        ? Border.all(
            color: borderColor ?? background,
            width: borderWidth,
          )
        : null;

    Widget content;
    if (url == null) {
      content = _fallbackContent(foreground);
    } else {
      content = Image.network(
        url,
        key: ValueKey(url),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) => _fallbackContent(foreground),
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : _fallbackContent(foreground),
      );
    }

    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      clipBehavior: Clip.antiAlias,
      padding: border == null ? null : EdgeInsets.all(borderWidth),
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: border,
      ),
      child: content,
    );
  }
}
