import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:qr_flutter/qr_flutter.dart';

/// Servicio para exportar el QR de la tienda como imagen PNG o PDF.
class QrExportService {
  /// Captura un widget (con su GlobalKey + RepaintBoundary) como PNG.
  static Future<Uint8List?> captureWidgetAsPng(
    GlobalKey key, {
    double pixelRatio = 3.0,
  }) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: pixelRatio);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      image.dispose();
      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('❌ Error capturando widget: $e');
      return null;
    }
  }

  /// Guarda un PNG en un archivo temporal y lo comparte.
  static Future<void> shareImage(Uint8List bytes, String fileName) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(bytes);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'image/png')],
        subject: 'Código QR de mi tienda',
        text: 'Escanea este código para vincularme a mi tienda en Fiamas',
      ),
    );
  }

  /// Genera un PDF con branding Fiamas + QR + instrucciones.
  static Future<Uint8List> generatePdf({
    required String nombreTienda,
    required String qrData,
    required Uint8List qrImageBytes,
    Uint8List? logoBytes,
  }) async {
    final pdf = pw.Document();

    // Convertir bytes a pw.MemoryImage para el PDF
    final qrImage = pw.MemoryImage(qrImageBytes);
    final logoImage = logoBytes != null ? pw.MemoryImage(logoBytes) : null;

    // Colores Fiamas (teal oscuro)
    final fiamasTeal = PdfColor.fromInt(0xFF1A7A76);
    final fiamasDark = PdfColor.fromInt(0xFF1E293B);
    final fiamasMuted = PdfColor.fromInt(0xFF64748B);
    final fiamasLight = PdfColor.fromInt(0xFFF8FAFC);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (context) => pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.center,
          children: [
            // ─── HEADER ───
            pw.Container(
              width: double.infinity,
              padding: const pw.EdgeInsets.symmetric(vertical: 16),
              decoration: pw.BoxDecoration(
                color: fiamasTeal,
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  if (logoImage != null)
                    pw.Image(logoImage, width: 40, height: 40)
                  else
                    pw.Container(
                      width: 40,
                      height: 40,
                      decoration: pw.BoxDecoration(
                        color: PdfColors.white,
                        shape: pw.BoxShape.circle,
                      ),
                      child: pw.Center(
                        child: pw.Text(
                          'F',
                          style: pw.TextStyle(
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                            color: fiamasTeal,
                          ),
                        ),
                      ),
                    ),
                  pw.SizedBox(width: 12),
                  pw.Text(
                    'FIAMAS',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                  ),
                ],
              ),
            ),

            pw.SizedBox(height: 32),

            // ─── TÍTULO ───
            pw.Text(
              'Código QR de Vinculación',
              style: pw.TextStyle(fontSize: 18, color: fiamasMuted),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              nombreTienda,
              style: pw.TextStyle(
                fontSize: 28,
                fontWeight: pw.FontWeight.bold,
                color: fiamasDark,
              ),
            ),

            pw.SizedBox(height: 32),

            // ─── QR EN MARCO ───
            pw.Container(
              padding: const pw.EdgeInsets.all(24),
              decoration: pw.BoxDecoration(
                color: fiamasLight,
                borderRadius: pw.BorderRadius.circular(20),
                border: pw.Border.all(color: fiamasTeal, width: 2),
              ),
              child: pw.Image(qrImage, width: 260, height: 260),
            ),

            pw.SizedBox(height: 32),

            // ─── INSTRUCCIONES ───
            pw.Container(
              padding: const pw.EdgeInsets.all(20),
              decoration: pw.BoxDecoration(
                color: PdfColors.grey200,
                borderRadius: pw.BorderRadius.circular(12),
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    '¿Cómo vincularse a esta tienda?',
                    style: pw.TextStyle(
                      fontSize: 14,
                      fontWeight: pw.FontWeight.bold,
                      color: fiamasDark,
                    ),
                  ),
                  pw.SizedBox(height: 12),
                  _buildStep('1', 'Abre la app de Fiamas en tu celular'),
                  _buildStep('2', 'Inicia sesión con tu número de celular'),
                  _buildStep('3', 'Toca el botón "Escanear QR"'),
                  _buildStep('4', 'Apunta la cámara a este código'),
                  _buildStep('5', '¡Listo! Quedarás vinculado a la tienda'),
                ],
              ),
            ),

            pw.SizedBox(height: 24),

            // ─── FOOTER ───
            pw.Text(
              'Generado desde Fiamas · Tienda local a digital',
              style: pw.TextStyle(fontSize: 10, color: fiamasMuted),
            ),
          ],
        ),
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildStep(String number, String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Container(
            width: 22,
            height: 22,
            decoration: pw.BoxDecoration(
              color: PdfColor.fromInt(0xFF1A7A76),
              shape: pw.BoxShape.circle,
            ),
            child: pw.Center(
              child: pw.Text(
                number,
                style: pw.TextStyle(
                  fontSize: 11,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.white,
                ),
              ),
            ),
          ),
          pw.SizedBox(width: 10),
          pw.Expanded(
            child: pw.Text(text, style: const pw.TextStyle(fontSize: 11)),
          ),
        ],
      ),
    );
  }

  /// Renderiza el QR a bytes PNG (sin widget de Flutter) para usar en PDF.
  static Future<Uint8List> renderQrToBytes(
    String data, {
    int size = 512,
  }) async {
    final painter = QrPainter(
      data: data,
      version: QrVersions.auto,
      gapless: false,
      eyeStyle: const QrEyeStyle(
        eyeShape: QrEyeShape.square,
        color: Color(0xFF1E293B),
      ),
      dataModuleStyle: const QrDataModuleStyle(
        dataModuleShape: QrDataModuleShape.square,
        color: Color(0xFF1E293B),
      ),
    );

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.toDouble(), size.toDouble()),
      Paint()..color = const Color(0xFFFFFFFF),
    );
    painter.paint(canvas, Size(size.toDouble(), size.toDouble()));

    final image = await recorder.endRecording().toImage(size, size);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /// Comparte un PDF generado.
  static Future<void> sharePdf(Uint8List pdfBytes, String fileName) async {
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/$fileName');
    await file.writeAsBytes(pdfBytes);

    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path, mimeType: 'application/pdf')],
        subject: 'Código QR de mi tienda',
        text: 'Aquí está el código QR para vincularse a mi tienda en Fiamas',
      ),
    );
  }
}
