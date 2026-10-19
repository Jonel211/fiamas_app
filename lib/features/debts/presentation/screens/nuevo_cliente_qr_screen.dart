import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/simple_app_bar.dart';

class NuevoClienteQrScreen extends StatelessWidget {
  const NuevoClienteQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        children: [
          const SimpleAppBar(title: 'Código QR de la tienda'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Escanea este código',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pídele a tu cliente que abra su app de Fiamas y escanee este código para vincularse a tu tienda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.inkMuted,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Aquí iría el QR real. Por ahora, simulamos uno visualmente.
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 20,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Container(
                      width: 220,
                      height: 220,
                      color: AppColors.ink, // Placeholder negro
                      child: const Center(
                        child: Icon(
                          Icons.qr_code_2_rounded,
                          size: 180,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 40),

                  // Pasos
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.skyBlue.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _StepText(number: '1', text: 'Abre la app de Fiamas en el celular de tu cliente.'),
                        SizedBox(height: 12),
                        _StepText(number: '2', text: 'Ve a la opción "Escanear QR".'),
                        SizedBox(height: 12),
                        _StepText(number: '3', text: 'Apunta la cámara a este código.'),
                        SizedBox(height: 12),
                        _StepText(number: '4', text: '¡Listo! El cliente ya estará registrado en tu tienda.'),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Widget auxiliar para los pasos
class _StepText extends StatelessWidget {
  const _StepText({required this.number, required this.text});

  final String number;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 24,
          height: 24,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.teal,
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 13,
              color: AppColors.ink,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}