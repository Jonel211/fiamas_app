import 'dart:io';

import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_avatar.dart';
import '../../../../core/widgets/image_zoom_screen.dart';

/// Avatar circular con la foto del tendero (o su inicial) y botón de cámara.
/// Al hacer tap sobre la foto se abre en pantalla completa con zoom.
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

  Widget _photoView() {
    if (localFile != null) {
      return Image.file(localFile!, width: size, height: size, fit: BoxFit.cover);
    }
    return AppAvatar.tendero(
      imageUrl: imageUrl,
      name: name,
      size: size,
      fontSize: size * 0.44,
    );
  }

  bool get _hasRealImage =>
      localFile != null || (imageUrl?.trim().isNotEmpty ?? false);

  void _openZoom(BuildContext context) {
    if (!_hasRealImage) return;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ImageZoomScreen(
          imageUrl: localFile != null ? null : imageUrl,
          localFile: localFile,
          placeholder: AppAvatar.tendero(name: name, size: 160),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: loading ? null : () => _openZoom(context),
            child: ClipOval(child: _photoView()),
          ),
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