import 'package:flutter/material.dart';

class ImagePlaceholder extends StatelessWidget {
  const ImagePlaceholder({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shortestSide = constraints.biggest.shortestSide;
        final iconSize = shortestSide.isFinite
            ? (shortestSide * 0.4).clamp(24.0, 48.0).toDouble()
            : 36.0;

        return ColoredBox(
          color: const Color(0xFFE8E8E8),
          child: Center(
            child: Icon(
              Icons.inventory_2_rounded,
              size: iconSize,
              color: Colors.grey.shade500,
            ),
          ),
        );
      },
    );
  }
}
