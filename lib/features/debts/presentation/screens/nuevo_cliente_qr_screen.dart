import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart'; 
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../auth/presentation/providers/tienda_provider.dart'; // <-- Importamos el de tiendas

class NuevoClienteQrScreen extends StatelessWidget {
  const NuevoClienteQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Obtenemos la lista de tiendas del provider
    final tiendaProvider = context.watch<TiendaProvider>();
    
    // Si hay tiendas cargadas, tomamos la primera (o la activa) y sacamos su qrToken
    final tiendaActual = tiendaProvider.tiendas.isNotEmpty ? tiendaProvider.tiendas.first : null;
    final qrToken = tiendaActual?.qrToken;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        children: [
          const AppHeader(title: 'Código QR de la tienda', showBack: true),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    'Escanea este código',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Pídele a tu cliente que abra su app de Fiamas y escanee este código para vincularse a tu tienda.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: AppColors.inkMuted, height: 1.4),
                  ),
                  const SizedBox(height: 40),

                  // QR REAL
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
                    child: (qrToken == null || qrToken.isEmpty)
                        ? const SizedBox(
                            width: 200, 
                            height: 200, 
                            child: Center(child: Text('Cargando QR...', style: TextStyle(color: Colors.grey))),
                          )
                        : QrImageView(
                            data: qrToken, // <-- ¡AQUÍ ESTÁ EL QR_TOKEN!
                            version: QrVersions.auto,
                            size: 200.0,
                            backgroundColor: Colors.white,
                            eyeStyle: const QrEyeStyle(
                              eyeShape: QrEyeShape.square,
                              color: AppColors.ink,
                            ),
                            dataModuleStyle: const QrDataModuleStyle(
                              dataModuleShape: QrDataModuleShape.square,
                              color: AppColors.ink,
                            ),
                          ),
                  ),
                  
                  const SizedBox(height: 40),

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
          decoration: const BoxDecoration(color: AppColors.teal, shape: BoxShape.circle),
          child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.ink, height: 1.4)),
        ),
      ],
    );
  }
}