import 'package:flutter/material.dart';

import 'image_zoom_screen.dart';

/// Widget reutilizable que envuelve cualquier imagen y permite hacer tap
/// para verla en pantalla completa con zoom (pinch, pan, doble tap).
class ZoomableImage extends StatelessWidget {
  const ZoomableImage({
    super.key,
    required this.image,
    required this.imageUrl,
    this.placeholder,
    this.showZoomHint = true,
  });

  final Widget image;
  final String imageUrl;
  final Widget? placeholder;
  final bool showZoomHint;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => ImageZoomScreen(
              imageUrl: imageUrl,
              placeholder: placeholder,
            ),
          ),
        );
      },
      child: Stack(
        children: [
          image,
          if (showZoomHint)
            Positioned(
              right: 4,
              bottom: 4,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Icon(
                  Icons.zoom_in_rounded,
                  size: 14,
                  color: Colors.white,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
