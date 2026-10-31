import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/step_indicator.dart';

/// Layout rediseñado para el flujo de recuperación de contraseña:
/// - Fondo azul con imagen del tendero
/// - Logo FIAMAS blanco centrado
/// - Card blanca anclada en la parte inferior
class AuthFlowLayout extends StatelessWidget {
  const AuthFlowLayout({
    super.key,
    required this.currentStep,
    required this.children,
  });

  static const double _headerHeight = 280;
  static const double _logoHeight = 120;

  final int currentStep;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.skyBlue,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            // FONDO AZUL CON IMAGEN DEL TENDERO
            SizedBox(
              height: _headerHeight,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Imagen de fondo del tendero (silueta)
                  Opacity(
                    opacity: 0.15,
                    child: Image.asset(
                      'assets/images/tendero.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(),
                    ),
                  ),
                  // Gradiente azul sobre la imagen
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          AppColors.skyBlue.withOpacity(0.9),
                          AppColors.skyBlue.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  // Logo FIAMAS blanco centrado
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Image.asset(
                          'assets/images/logo-os.png', // Logo blanco/oscuro
                          height: _logoHeight,
                          errorBuilder: (_, __, ___) => const Text(
                            'FIAMAS',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 2,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // CARD BLANCA ANCLADA EN LA PARTE INFERIOR
            Positioned.fill(
              top: _headerHeight - 40, // Superposición para efecto moderno
              child: Container(
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 20,
                      offset: Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    40,
                    24,
                    24 + MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Indicador de pasos
                      Center(child: StepIndicator(currentStep: currentStep)),
                      const SizedBox(height: 32),
                      // Contenido dinámico
                      ...children,
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Estilos de texto comunes de estas pantallas.
class AuthFlowText {
  AuthFlowText._();

  static const TextStyle title = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.ink,
    letterSpacing: -0.5,
  );

  static const TextStyle body = TextStyle(
    fontSize: 15,
    color: AppColors.inkMuted,
    height: 1.5,
  );

  static const TextStyle hint = TextStyle(
    fontSize: 13,
    color: AppColors.inkMuted,
    height: 1.4,
  );
}
