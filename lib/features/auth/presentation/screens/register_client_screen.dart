import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';

/// Registro del cliente: en vez de un formulario, escanea un código
/// que le entrega el tendero para crear su cuenta.
class RegisterClientScreen extends StatelessWidget {
  const RegisterClientScreen({super.key});

  // Mismo logo y medidas que la pantalla de registro del tendero.
  static const String _logo = 'assets/images/logo-os.png';
  static const double _headerHeight = 130;
  static const double _logoHeight = 240;

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
    return Scaffold(
      backgroundColor: AppColors.skyBlue,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const _Header(
              logoPath: _logo,
              height: _headerHeight,
              logoHeight: _logoHeight,
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: CustomScrollView(
                  slivers: [
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(28, 32, 28, 32),
                        child: Column(
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
                            const SizedBox(height: 14),
                            const Text(
                              'Empieza a ver tus notas de\ncredito',
                              style: TextStyle(
                                fontSize: 20,
                                color: AppColors.ink,
                                height: 1.3,
                              ),
                            ),
                            const Spacer(flex: 2),
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
                            const SizedBox(height: 36),
                            _StoreButton(
                              label: 'Android',
                              icon: const _GooglePlayBadge(),
                              onTap: () => _openStore(context, 'Android'),
                            ),
                            const SizedBox(height: 18),
                            _StoreButton(
                              label: 'iPhone',
                              icon: const _AppStoreBadge(),
                              onTap: () => _openStore(context, 'iPhone'),
                            ),
                            const Spacer(flex: 3),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Franja azul claro con el logo centrado.
class _Header extends StatelessWidget {
  const _Header({
    required this.logoPath,
    required this.height,
    required this.logoHeight,
  });

  final String logoPath;
  final double height;
  final double logoHeight;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.center,
        children: [
          OverflowBox(
            maxWidth: double.infinity,
            maxHeight: double.infinity,
            child: Image.asset(
              logoPath,
              height: logoHeight,
              fit: BoxFit.contain,
              errorBuilder: (_, _, _) => const Text(
                'FIAMAS',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Botón dorado con badge de tienda y texto blanco.
class _StoreButton extends StatelessWidget {
  const _StoreButton({
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
      elevation: 0,
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
      child: CustomPaint(
        painter: _PlayStorePainter(),
      ),
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

    // Left base
    final pathLeft = Path()
      ..moveTo(pTop.dx, pTop.dy)
      ..lineTo(pBottom.dx, pBottom.dy)
      ..lineTo(pInner.dx, pInner.dy)
      ..close();
    canvas.drawPath(pathLeft, Paint()..color = const Color(0xFFC78F28));

    // Top fold
    final pathTop = Path()
      ..moveTo(pTop.dx, pTop.dy)
      ..lineTo(pInner.dx, pInner.dy)
      ..lineTo(pRight.dx, pRight.dy)
      ..close();
    canvas.drawPath(pathTop, Paint()..color = const Color(0xFFE8B652));

    // Bottom fold
    final pathBottom = Path()
      ..moveTo(pBottom.dx, pBottom.dy)
      ..lineTo(pInner.dx, pInner.dy)
      ..lineTo(pRight.dx, pRight.dy)
      ..close();
    canvas.drawPath(pathBottom, Paint()..color = const Color(0xFFB87E1C));

    // Right tip fold
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
      child: CustomPaint(
        painter: _AppStorePainter(),
      ),
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

    // Left bar (diagonal)
    canvas.drawLine(
      Offset(w * 0.22, h * 0.88),
      Offset(w * 0.48, h * 0.15),
      paint,
    );

    // Right bar (diagonal)
    canvas.drawLine(
      Offset(w * 0.78, h * 0.88),
      Offset(w * 0.52, h * 0.15),
      paint,
    );

    // Horizontal bar
    canvas.drawLine(
      Offset(w * 0.25, h * 0.62),
      Offset(w * 0.75, h * 0.62),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}