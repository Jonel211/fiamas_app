import 'dart:io';

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Avatar circular con la foto del tendero (o su inicial) y botón de cámara.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    this.imageUrl,
    this.localFile,
    this.loading = false,
    this.size = 96,
    this.onChangePhoto,
  });

  final String name;
  final String? imageUrl;
  final File? localFile;
  final bool loading;
  final double size;
  final VoidCallback? onChangePhoto;

  String get _initial {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
  }

  Widget _initialView() {
    return Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      color: AppColors.teal,
      child: Text(
        _initial,
        style: TextStyle(
          fontSize: size * 0.44,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _photoView() {
    if (localFile != null) {
      return Image.file(localFile!, width: size, height: size, fit: BoxFit.cover);
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return Image.network(
        imageUrl!,
        key: ValueKey(imageUrl),
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _initialView(),
      );
    }
    return _initialView();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          ClipOval(child: _photoView()),
          if (loading)
            Positioned.fill(
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  color: Colors.black38,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  ),
                ),
              ),
            ),
          Positioned(
            right: -4,
            bottom: -4,
            child: Material(
              color: AppColors.surface,
              shape: const CircleBorder(),
              elevation: 2,
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: loading ? null : onChangePhoto,
                child: const Padding(
                  padding: EdgeInsets.all(8),
                  child: Icon(Icons.photo_camera_outlined, size: 18, color: AppColors.teal),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}