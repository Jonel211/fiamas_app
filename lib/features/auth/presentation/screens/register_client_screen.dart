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

  void _onScan(BuildContext context) {
    // TODO: abrir el escáner de la cámara (lib/core/hardware) y, con el
    // código leído, crear la cuenta del cliente en la API.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('El escáner estará disponible pronto')),
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
                // Rellena todo el panel; si el contenido no cabe, se desplaza.
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
                            const SizedBox(height: 18),
                            const Text(
                              'Empieza a ver tus notas de crédito',
                              style: TextStyle(
                                fontSize: 20,
                                color: AppColors.ink,
                                height: 1.3,
                              ),
                            ),

                            // Instrucción y botón. Para subirlos o bajarlos
                            // cambia los flex: menos arriba / más abajo = sube.
                            const Spacer(flex: 1),
                            const Center(child: _Instruction()),
                            const SizedBox(height: 36),
                            Center(
                              child: _ScanButton(onTap: () => _onScan(context)),
                            ),
                            const Spacer(flex: 4),
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
          // OverflowBox: el PNG trae espacio transparente alrededor, así
          // que se dibuja más grande que la franja sin recortarse.
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

class _Instruction extends StatelessWidget {
  const _Instruction();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 8),
      child: Text(
        'Haga clic en el botón para crear su cuenta',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w700,
          color: AppColors.teal,
          height: 1.35,
        ),
      ),
    );
  }
}

/// Botón dorado grande con el ícono de escáner.
class _ScanButton extends StatelessWidget {
  const _ScanButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.gold,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: SizedBox(
          width: 200,
          height: 180,
          child: Center(
            child: Image.asset(
              'assets/icons/scanner.png',
              width: 100,
              height: 120,
              fit: BoxFit.contain,
            ),
          ),
        ),
      ),
    );
  }
}