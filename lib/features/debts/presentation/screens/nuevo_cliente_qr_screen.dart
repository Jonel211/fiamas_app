import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header_config.dart';
import '../../../auth/data/models/tienda_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/tienda_provider.dart';
import '../../data/services/qr_export_service.dart';
import '../widgets/qr_share_card.dart';

class NuevoClienteQrScreen extends StatefulWidget {
  const NuevoClienteQrScreen({super.key});

  @override
  State<NuevoClienteQrScreen> createState() => _NuevoClienteQrScreenState();
}

class _NuevoClienteQrScreenState extends State<NuevoClienteQrScreen> {
  final GlobalKey _qrCardKey = GlobalKey();
  bool _isExportingImage = false;
  bool _isExportingPdf = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final tp = context.read<TiendaProvider>();
      if (tp.tiendas.isEmpty) tp.cargarMisTiendas();
    });
  }

  TiendaModel? _tiendaActual(TiendaProvider tp, String? idLogin) {
    final id = tp.tiendaSeleccionadaId ?? idLogin;
    if (id == null) return null;
    final index = tp.tiendas.indexWhere((t) => t.id == id);
    return index == -1 ? null : tp.tiendas[index];
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? AppColors.danger : AppColors.teal,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _exportarImagen() async {
    final tp = context.read<TiendaProvider>();
    final idLogin = context.read<AuthProvider>().user?.tiendaId;
    final tienda = _tiendaActual(tp, idLogin);
    final qrToken = tienda?.qrToken;

    if (qrToken == null || qrToken.isEmpty) {
      _snack('No hay QR disponible para exportar', error: true);
      return;
    }

    setState(() => _isExportingImage = true);
    // Esperar un frame para que RepaintBoundary tenga el widget renderizado
    await Future.delayed(const Duration(milliseconds: 300));

    try {
      final bytes = await QrExportService.captureWidgetAsPng(_qrCardKey);
      if (bytes == null) throw Exception('No se pudo capturar la imagen');

      final fileName = 'qr_${tienda!.nombre.replaceAll(' ', '_')}.png';
      await QrExportService.shareImage(bytes, fileName);
    } catch (e) {
      _snack('Error al exportar imagen: $e', error: true);
    } finally {
      if (mounted) setState(() => _isExportingImage = false);
    }
  }

  Future<void> _exportarPdf() async {
    final tp = context.read<TiendaProvider>();
    final idLogin = context.read<AuthProvider>().user?.tiendaId;
    final tienda = _tiendaActual(tp, idLogin);
    final qrToken = tienda?.qrToken;

    if (qrToken == null || qrToken.isEmpty) {
      _snack('No hay QR disponible para exportar', error: true);
      return;
    }

    setState(() => _isExportingPdf = true);

    try {
      // 1. Renderizar QR a bytes
      final Uint8List qrBytes = await QrExportService.renderQrToBytes(qrToken);

      // 2. Generar PDF
      final Uint8List pdfBytes = await QrExportService.generatePdf(
        nombreTienda: tienda!.nombre,
        qrData: qrToken,
        qrImageBytes: qrBytes,
      );

      // 3. Compartir PDF
      final fileName = 'QR_${tienda.nombre.replaceAll(' ', '_')}.pdf';
      await QrExportService.sharePdf(pdfBytes, fileName);
    } catch (e) {
      _snack('Error al exportar PDF: $e', error: true);
    } finally {
      if (mounted) setState(() => _isExportingPdf = false);
    }
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
      contenidoQr = RepaintBoundary(
        key: _qrCardKey,
        child: QrShareCard(
          nombreTienda: nombreTienda,
          qrData: qrToken!,
          logoUrl: tiendaActual?.logoUrl,
          size: 320,
        ),  
      );
    } else if (tiendaProvider.isLoading || (tiendaProvider.tiendas.isEmpty && tiendaProvider.error == null)) {
      contenidoQr = const SizedBox(
        width: 200, height: 200,
        child: Center(child: CircularProgressIndicator()),
      );
    } else {
      contenidoQr = SizedBox(
        width: 200, height: 200,
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
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
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
              const SizedBox(height: 24),

              // ✅ TARJETA QR ESTILO YAPE (capturable como imagen)
              contenidoQr,

              const SizedBox(height: 24),

              // ✅ BOTONES DE EXPORTACIÓN
              if (tieneQr)
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isExportingImage ? null : _exportarImagen,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: _isExportingImage
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.image_rounded, size: 18),
                        label: Text(_isExportingImage ? 'Generando...' : 'Imagen'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isExportingPdf ? null : _exportarPdf,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: AppColors.ink,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: _isExportingPdf
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.ink))
                            : const Icon(Icons.picture_as_pdf_rounded, size: 18),
                        label: Text(_isExportingPdf ? 'Generando...' : 'PDF'),
                      ),
                    ),
                  ],
                ),

              const SizedBox(height: 20),

              // ✅ INSTRUCCIONES
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
          width: 24, height: 24,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: AppColors.teal, shape: BoxShape.circle),
          child: Text(number, style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.ink, height: 1.4))),
      ],
    );
  }
}