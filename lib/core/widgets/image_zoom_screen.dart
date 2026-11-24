import 'dart:io';

import 'package:flutter/material.dart';

import '../utils/image_url.dart';

/// Visor de imágenes a pantalla completa con zoom y desplazamiento acotado.
/// Soporta imágenes de red, archivos locales y un placeholder.
class ImageZoomScreen extends StatefulWidget {
  const ImageZoomScreen({
    super.key,
    this.imageUrl,
    this.localFile,
    this.placeholder,
  });

  final String? imageUrl;
  final File? localFile;
  final Widget? placeholder;

  @override
  State<ImageZoomScreen> createState() => _ImageZoomScreenState();
}

class _ImageZoomScreenState extends State<ImageZoomScreen> {
  static const double _minScale = 1.0;
  static const double _maxScale = 4.0;
  static const double _doubleTapScale = 2.5;

  final TransformationController _controller = TransformationController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _placeholder() {
    return Center(
      child: widget.placeholder ??
          const Icon(Icons.person_rounded, color: Colors.white54, size: 96),
    );
  }

  Widget _buildImage() {
    if (widget.localFile != null) {
      return Image.file(
        widget.localFile!,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _placeholder(),
      );
    }

    final url = resolveImageUrl(widget.imageUrl);
    if (url == null) return _placeholder();

    return Image.network(
      url,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      },
      errorBuilder: (_, _, _) => _placeholder(),
    );
  }

  void _handleInteractionEnd(ScaleEndDetails details) {
    if (_controller.value.getMaxScaleOnAxis() < _minScale) {
      _controller.value = Matrix4.identity();
    }
  }

  void _handleDoubleTap() {
    if (_controller.value.getMaxScaleOnAxis() > _minScale) {
      _controller.value = Matrix4.identity();
      return;
    }

    final size = MediaQuery.sizeOf(context);
    final center = Offset(size.width / 2, size.height / 2);
    _controller.value = Matrix4.identity()
      ..translateByDouble(center.dx, center.dy, 0, 1)
      ..scaleByDouble(_doubleTapScale, _doubleTapScale, 1, 1)
      ..translateByDouble(-center.dx, -center.dy, 0, 1);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          GestureDetector(
            onDoubleTap: _handleDoubleTap,
            child: InteractiveViewer(
              transformationController: _controller,
              minScale: _minScale,
              maxScale: _maxScale,
              boundaryMargin: EdgeInsets.zero,
              onInteractionEnd: _handleInteractionEnd,
              child: SizedBox.expand(child: _buildImage()),
            ),
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 26,
              ),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.55),
                minimumSize: const Size(40, 40),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
