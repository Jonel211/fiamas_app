import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Avatar circular con la inicial del nombre y botón de cámara.
class ProfileAvatar extends StatelessWidget {
  const ProfileAvatar({
    super.key,
    required this.name,
    this.size = 96,
    this.onChangePhoto,
  });

  final String name;
  final double size;
  final VoidCallback? onChangePhoto;

  String get _initial {
    final trimmed = name.trim();
    return trimmed.isEmpty ? '?' : trimmed[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: const BoxDecoration(
              color: AppColors.teal,
              shape: BoxShape.circle,
            ),
            child: Text(
              _initial,
              style: TextStyle(
                fontSize: size * 0.44,
                fontWeight: FontWeight.w700,
                color: Colors.white,
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
                onTap: onChangePhoto,
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