import 'dart:io';
import 'package:flutter/material.dart';

import '../utils/image_url.dart';

/// Pantalla a pantalla completa con zoom, pan y doble tap para resetear.
/// Soporta imágenes de red (URL) o archivos locales (File).
class ImageZoomScreen extends StatefulWidget {
  const ImageZoomScreen({
    super.key,
    this.imageUrl,
    this.localFile,
  }) : assert(
          imageUrl != null || localFile != null,
          'Debe proporcionar imageUrl o localFile',
        );

  final String? imageUrl;
  final File? localFile;

  @override
  State<ImageZoomScreen> createState() => _ImageZoomScreenState();
}

class _ImageZoomScreenState extends State<ImageZoomScreen> {
  final TransformationController _controller = TransformationController();
  bool _hasError = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _resetZoom() {
    _controller.value = Matrix4.identity();
  }

  Widget _buildImage() {
    if (widget.localFile != null) {
      return Image.file(
        widget.localFile!,
        fit: BoxFit.contain,
        errorBuilder: (_, _, _) => _errorWidget(),
      );
    }

    final url = resolveImageUrl(widget.imageUrl);
    if (url == null) return _errorWidget();

    return Image.network(
      url,
      fit: BoxFit.contain,
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;
        return const Center(
          child: CircularProgressIndicator(color: Colors.white),
        );
      },
      errorBuilder: (_, _, _) => _errorWidget(),
    );
  }

  Widget _errorWidget() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_hasError) setState(() => _hasError = true);
    });
    return const Center(
      child: Icon(
        Icons.broken_image_rounded,
        color: Colors.white54,
        size: 64,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Imagen con zoom
          GestureDetector(
            onDoubleTap: _resetZoom,
            child: InteractiveViewer(
              transformationController: _controller,
              minScale: 1.0,
              maxScale: 5.0,
              boundaryMargin: const EdgeInsets.all(80),
              child: _buildImage(),
            ),
          ),

          // 2. Botón cerrar en esquina superior izquierda
          Positioned(
            top: MediaQuery.of(context).padding.top + 8,
            left: 12,
            child: IconButton(
              onPressed: () => Navigator.of(context).pop(),
              icon: const Icon(Icons.close_rounded, color: Colors.white, size: 26),
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