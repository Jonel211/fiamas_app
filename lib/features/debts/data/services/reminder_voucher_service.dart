import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/utils/whatsapp_reminder.dart';
import '../../../auth/data/models/tienda_model.dart';
import '../../presentation/widgets/reminder_voucher_card.dart';
import 'qr_export_service.dart';

enum ResultadoEnvio { directo, hojaCompartir, error }

/// Genera el voucher como imagen y lo envía por WhatsApp.
class ReminderVoucherService {
  static const _canal = MethodChannel('fiamas/whatsapp');

  /// Dibuja la tarjeta fuera de pantalla y la captura como PNG.
  static Future<Uint8List?> render(
    BuildContext context,
    ReminderVoucherCard card,
  ) async {
    try {
      await precacheImage(const AssetImage('assets/images/logoo.png'), context);
    } catch (_) {}
    final url = card.logoTiendaUrl;
    if (url != null && url.isNotEmpty && context.mounted) {
      try {
        await precacheImage(NetworkImage(url), context)
            .timeout(const Duration(seconds: 5));
      } catch (_) {}
    }
    if (!context.mounted) return null;

    final key = GlobalKey();
    final overlay = Overlay.of(context, rootOverlay: true);
    final entry = OverlayEntry(
      builder: (_) => Positioned(
        left: -10000,
        top: 0,
        child: Material(
          type: MaterialType.transparency,
          child: RepaintBoundary(key: key, child: card),
        ),
      ),
    );
    overlay.insert(entry);

    try {
      Uint8List? bytes;
      for (var i = 0; i < 4 && bytes == null; i++) {
        await WidgetsBinding.instance.endOfFrame;
        await Future.delayed(const Duration(milliseconds: 120));
        bytes = await QrExportService.captureWidgetAsPng(key, pixelRatio: 3.0);
      }
      return bytes;
    } finally {
      entry.remove();
    }
  }

  static Future<File> _guardar(Uint8List bytes) async {
    final dir = await getTemporaryDirectory();
    final file = File(
      '${dir.path}/recordatorio_${DateTime.now().millisecondsSinceEpoch}.png',
    );
    return file.writeAsBytes(bytes);
  }

  /// Android: abre el chat del número con la imagen adjunta.
  static Future<bool> _enviarAlChat(
    String ruta,
    String telefono,
    String caption,
  ) async {
    if (!Platform.isAndroid) return false;
    try {
      final ok = await _canal.invokeMethod<bool>('enviarImagen', {
        'telefono': telefono,
        'ruta': ruta,
        'texto': caption,
      });
      return ok ?? false;
    } catch (e) {
      debugPrint('Canal WhatsApp falló: $e');
      return false;
    }
  }

  /// Respaldo: hoja de compartir del sistema.
  static Future<void> _hojaCompartir(String ruta, String caption) async {
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(ruta, mimeType: 'image/png')],
        text: caption,
      ),
    );
  }

  /// Flujo completo: arma el voucher, lo captura y lo envía.
  static Future<ResultadoEnvio> enviarRecordatorio(
    BuildContext context, {
    required TiendaModel? tienda,
    required String nombreCliente,
    required String telefono,
    required List<VoucherLinea> lineas,
    required double total,
    required TonoRecordatorio tono,
  }) async {
    final nombreTienda =
        (tienda?.nombre.isNotEmpty ?? false) ? tienda!.nombre : 'Mi tienda';

    final card = ReminderVoucherCard(
      nombreTienda: nombreTienda,
      ruc: tienda?.ruc,
      logoTiendaUrl: tienda?.logoUrl,
      nombreCliente: nombreCliente,
      lineas: lineas,
      total: total,
      tono: tono,
      emision: DateTime.now(),
    );

    final bytes = await render(context, card);
    if (bytes == null) return ResultadoEnvio.error;

    final archivo = await _guardar(bytes);
    final caption = '${card.titulo} · $nombreTienda · '
        'Saldo pendiente: S/ ${total.toStringAsFixed(2)}';

    final numero = normalizarTelefonoWhatsapp(telefono);
    if (await _enviarAlChat(archivo.path, numero, caption)) {
      return ResultadoEnvio.directo;
    }

    await _hojaCompartir(archivo.path, caption);
    return ResultadoEnvio.hojaCompartir;
  }
}