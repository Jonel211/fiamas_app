import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/step_indicator.dart';

/// Estructura compartida por las pantallas de recuperar contraseña:
/// franja azul con el logo, panel blanco, indicador de pasos y contenido.
class AuthFlowLayout extends StatelessWidget {
  const AuthFlowLayout({
    super.key,
    required this.currentStep,
    required this.children,
  });

  // Logo vertical y medidas. Sube _logoHeight para agrandar el logo.
  static const String _logo = 'assets/images/fiamas-vertical.png';
  static const double _headerHeight = 300;
  static const double _logoHeight = 250;

  /// Paso actual del proceso (1, 2 o 3).
  final int currentStep;

  /// Contenido que va debajo del indicador de pasos.
  final List<Widget> children;

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
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    24,
                    24,
                    24,
                    24 + MediaQuery.of(context).padding.bottom,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(child: StepIndicator(currentStep: currentStep)),
                      const SizedBox(height: 28),
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

/// Estilos de texto comunes de estas pantallas.
class AuthFlowText {
  AuthFlowText._();

  static const TextStyle title = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.ink,
  );

  static const TextStyle body = TextStyle(
    fontSize: 16,
    color: AppColors.ink,
    height: 1.35,
  );

  static const TextStyle hint = TextStyle(
    fontSize: 13,
    color: AppColors.ink,
    height: 1.35,
  );
}