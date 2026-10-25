import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Contenido del registro de cliente: descarga de la app.
/// Se usa en el panel de la bienvenida y en `RegisterClientScreen`.
class RegisterClientContent extends StatelessWidget {
  const RegisterClientContent({super.key});

  void _openStore(BuildContext context, String platform) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Descarga para $platform próximamente disponible'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Crear tu cuenta',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: AppColors.ink,
          ),
        ),
        const SizedBox(height: 10),
        const Text(
          'Empieza a ver tus notas de crédito',
          style: TextStyle(fontSize: 18, color: AppColors.ink, height: 1.3),
        ),
        const SizedBox(height: 32),
        const Center(
          child: Text(
            'Descargue la app para su\ndispositivo aquí',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: AppColors.teal,
              height: 1.35,
            ),
          ),
        ),
        const SizedBox(height: 28),
        StoreButton(
          label: 'Android',
          icon: const _GooglePlayBadge(),
          onTap: () => _openStore(context, 'Android'),
        ),
        const SizedBox(height: 16),
        StoreButton(
          label: 'iPhone',
          icon: const _AppStoreBadge(),
          onTap: () => _openStore(context, 'iPhone'),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

/// Botón dorado con badge de tienda y texto blanco.
class StoreButton extends StatelessWidget {
  const StoreButton({
    super.key,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  final String label;
  final Widget icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.gold,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              icon,
              const SizedBox(width: 14),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GooglePlayBadge extends StatelessWidget {
  const _GooglePlayBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(painter: _PlayStorePainter()),
    );
  }
}

class _PlayStorePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final pTop = Offset(w * 0.15, h * 0.12);
    final pBottom = Offset(w * 0.15, h * 0.88);
    final pRight = Offset(w * 0.88, h * 0.5);
    final pInner = Offset(w * 0.52, h * 0.5);

    final pathLeft = Path()
      ..moveTo(pTop.dx, pTop.dy)
      ..lineTo(pBottom.dx, pBottom.dy)
      ..lineTo(pInner.dx, pInner.dy)
      ..close();
    canvas.drawPath(pathLeft, Paint()..color = const Color(0xFFC78F28));

    final pathTop = Path()
      ..moveTo(pTop.dx, pTop.dy)
      ..lineTo(pInner.dx, pInner.dy)
      ..lineTo(pRight.dx, pRight.dy)
      ..close();
    canvas.drawPath(pathTop, Paint()..color = const Color(0xFFE8B652));

    final pathBottom = Path()
      ..moveTo(pBottom.dx, pBottom.dy)
      ..lineTo(pInner.dx, pInner.dy)
      ..lineTo(pRight.dx, pRight.dy)
      ..close();
    canvas.drawPath(pathBottom, Paint()..color = const Color(0xFFB87E1C));

    final pathRight = Path()
      ..moveTo(pInner.dx, pInner.dy)
      ..lineTo(w * 0.75, h * 0.32)
      ..lineTo(pRight.dx, pRight.dy)
      ..lineTo(w * 0.75, h * 0.68)
      ..close();
    canvas.drawPath(pathRight, Paint()..color = const Color(0xFFF5CE68));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _AppStoreBadge extends StatelessWidget {
  const _AppStoreBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 36,
      height: 36,
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
      ),
      child: CustomPaint(painter: _AppStorePainter()),
    );
  }
}

class _AppStorePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFFD69A30)
      ..strokeWidth = size.width * 0.16
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final w = size.width;
    final h = size.height;

    canvas.drawLine(
        Offset(w * 0.22, h * 0.88), Offset(w * 0.48, h * 0.15), paint);
    canvas.drawLine(
        Offset(w * 0.78, h * 0.88), Offset(w * 0.52, h * 0.15), paint);
    canvas.drawLine(
        Offset(w * 0.25, h * 0.62), Offset(w * 0.75, h * 0.62), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}