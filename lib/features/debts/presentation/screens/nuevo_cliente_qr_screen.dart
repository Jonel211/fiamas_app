import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header_config.dart';
import '../../../auth/data/models/tienda_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/tienda_provider.dart';

class NuevoClienteQrScreen extends StatefulWidget {
  const NuevoClienteQrScreen({super.key});

  @override
  State<NuevoClienteQrScreen> createState() => _NuevoClienteQrScreenState();
}

class _NuevoClienteQrScreenState extends State<NuevoClienteQrScreen> {
  @override
  void initState() {
    super.initState();
    // La lista de tiendas solo se llena al abrir "Mis Tiendas"; si está vacía, se carga aquí.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final tp = context.read<TiendaProvider>();
      if (tp.tiendas.isEmpty) tp.cargarMisTiendas();
    });
  }

  /// Misma regla que el resto de la app: tienda elegida o, si no, la del login.
  TiendaModel? _tiendaActual(TiendaProvider tp, String? idLogin) {
    final id = tp.tiendaSeleccionadaId ?? idLogin;
    if (id == null) return null;
    final index = tp.tiendas.indexWhere((t) => t.id == id);
    return index == -1 ? null : tp.tiendas[index];
  }

  @override
  Widget build(BuildContext context) {
    final tiendaProvider = context.watch<TiendaProvider>();
    final idLogin = context.watch<AuthProvider>().user?.tiendaId;

    final tiendaActual = _tiendaActual(tiendaProvider, idLogin);
    final qrToken = tiendaActual?.qrToken;
    final nombreTienda = tiendaActual?.nombre ?? 'tu tienda';
    final tieneQr = qrToken != null && qrToken.isNotEmpty;

    Widget contenidoQr;
    if (tieneQr) {
      // Siempre el mismo token guardado de la tienda: no se genera uno nuevo.
      contenidoQr = QrImageView(
        data: qrToken,
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
      );
    } else if (tiendaProvider.isLoading || (tiendaProvider.tiendas.isEmpty && tiendaProvider.error == null)) {
      contenidoQr = const SizedBox(
        width: 200,
        height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    } else {
      contenidoQr = SizedBox(
        width: 200,
        height: 200,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                tiendaProvider.error ?? 'Esta tienda no tiene un código QR disponible.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppColors.inkMuted, fontSize: 13),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () => context.read<TiendaProvider>().cargarMisTiendas(),
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    return AppHeaderConfig(
      title: 'Código QR de la tienda',
      showBack: true,
      child: Scaffold(
        backgroundColor: AppColors.ivory,
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                'QR de $nombreTienda',
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppColors.ink),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Pídele a tu cliente que abra su app de Fiamas y escanee este código para vincularse a $nombreTienda.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppColors.inkMuted, height: 1.4),
              ),
              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: contenidoQr,
              ),

              const SizedBox(height: 40),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.skyBlue.withValues(alpha: 0.2),
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