import 'package:flutter/foundation.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/reporte_resumen_model.dart';

enum TipoReporte { general, fiados, fiadosPorCobrar, cobros, productos }

class PdfService {
  static const _colorTeal = PdfColor.fromInt(0xFF1D9492);
  static const _colorInk = PdfColor.fromInt(0xFF1E2025);
  static const _colorMuted = PdfColor.fromInt(0xFF8E9BAE);

  static final _moneda = NumberFormat('#,##0.00');

  static double _num(dynamic v) {
    if (v is num) return v.toDouble();
    return double.tryParse(v?.toString() ?? '') ?? 0.0;
  }

  static String _fecha(dynamic v) {
    final s = v?.toString() ?? '';
    if (s.isEmpty) return '-';
    try {
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(s).toLocal());
    } catch (_) {
      return s;
    }
  }

  static String _cliente(dynamic c) {
    if (c is Map) {
      final n = '${c['nombres'] ?? ''} ${c['apellidos'] ?? ''}'.trim();
      if (n.isNotEmpty) return n;
    }
    return 'Cliente';
  }

  static Future<void> generarReporte({
    required ReporteResumenModel resumen,
    required String nombreTienda,
    required String periodo,
    required TipoReporte tipo,
    String? clienteNombre,
  }) async {
    final pdf = pw.Document();

    String tituloReporte = 'Reporte General';
    if (tipo == TipoReporte.fiados) tituloReporte = 'Reporte de Fiados';
    if (tipo == TipoReporte.fiadosPorCobrar) tituloReporte = 'Reporte de Fiados por Cobrar';
    if (tipo == TipoReporte.cobros) tituloReporte = 'Reporte de Cobros';
    if (tipo == TipoReporte.productos) tituloReporte = 'Reporte de Productos Más Vendidos';

    final periodoTxt = {
          'hoy': 'HOY',
          'semana': 'ESTA SEMANA',
          'mes': 'MES ACTUAL',
        }[periodo] ??
        'HISTÓRICO';

    debugPrint('>>> PDF tipo=$tipo fiados=${resumen.listaFiados.length} '
        'cobros=${resumen.listaCobros.length} top=${resumen.topProductos.length}');

    final contenido = <pw.Widget>[
      // Cabecera
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('FIAMAS',
                  style: pw.TextStyle(
                      fontSize: 24, fontWeight: pw.FontWeight.bold, color: _colorTeal)),
              pw.SizedBox(height: 4),
              pw.Text(tituloReporte,
                  style: pw.TextStyle(
                      fontSize: 16, color: _colorInk, fontWeight: pw.FontWeight.bold)),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(nombreTienda,
                  style: pw.TextStyle(
                      fontSize: 14, fontWeight: pw.FontWeight.bold, color: _colorInk)),
              if (clienteNombre != null)
                pw.Text('Cliente: $clienteNombre',
                    style: pw.TextStyle(
                        fontSize: 12, color: _colorTeal, fontWeight: pw.FontWeight.bold)),
              pw.Text('Periodo: $periodoTxt',
                  style: pw.TextStyle(fontSize: 12, color: _colorMuted)),
              pw.Text(
                  'Fecha de emisión: ${DateFormat('dd/MM/yyyy').format(DateTime.now())}',
                  style: pw.TextStyle(fontSize: 10, color: _colorMuted)),
            ],
          ),
        ],
      ),
      pw.SizedBox(height: 20),
      pw.Divider(color: _colorMuted),
      pw.SizedBox(height: 20),
    ];

    switch (tipo) {
      case TipoReporte.general:
        contenido.addAll(_seccionGeneral(resumen));
        break;
      case TipoReporte.fiados:
        contenido.addAll([
          _titulo('Lista de Fiados'),
          pw.SizedBox(height: 12),
          _tablaFiados(resumen.listaFiados, soloPendientes: false),
        ]);
        break;
      case TipoReporte.fiadosPorCobrar:
        contenido.addAll([
          _titulo('Lista de Fiados Pendientes'),
          pw.SizedBox(height: 12),
          _tablaFiados(resumen.listaFiados, soloPendientes: true),
        ]);
        break;
      case TipoReporte.cobros:
        contenido.addAll([
          _titulo('Lista de Cobros Realizados'),
          pw.SizedBox(height: 12),
          _tablaCobros(resumen.listaCobros),
        ]);
        break;
      case TipoReporte.productos:
        contenido.addAll([
          _titulo('Top Productos Más Vendidos'),
          pw.SizedBox(height: 12),
          _tablaProductos(resumen.topProductos),
        ]);
        break;
    }

    contenido.addAll([
      pw.SizedBox(height: 40),
      pw.Divider(color: _colorMuted),
      pw.Center(
        child: pw.Text('Generado automáticamente por la aplicación Fiamas.',
            style: pw.TextStyle(fontSize: 10, color: _colorMuted)),
      ),
    ]);

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) => contenido,
      ),
    );

    final bytes = await pdf.save();
    await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => bytes);
  }

  static pw.Widget _titulo(String texto) => pw.Text(texto,
      style: pw.TextStyle(
          fontSize: 18, fontWeight: pw.FontWeight.bold, color: _colorInk));

  static List<pw.Widget> _seccionGeneral(ReporteResumenModel r) {
    return [
      _titulo('Resumen General'),
      pw.SizedBox(height: 12),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _card('Ventas Totales (Fiados)', 'S/ ${_moneda.format(r.montoTotalFiado)}', _colorTeal),
          _card('Por Cobrar', 'S/ ${_moneda.format(r.porCobrar)}', PdfColors.orange800),
          _card('Cobros Realizados', 'S/ ${_moneda.format(r.montoTotalCobrado)}', PdfColors.green800),
        ],
      ),
      pw.SizedBox(height: 20),
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          _card('Total Fiados', '${r.totalFiados} ops', _colorInk),
          _card('Clientes Pendientes', '${r.clientesPendientes} clientes', _colorInk),
          _card('Cobros Registrados', '${r.totalCobros} cobros', _colorInk),
        ],
      ),
    ];
  }

  static pw.Widget _card(String title, String value, PdfColor color) {
    return pw.Container(
      width: 150,
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontSize: 10, color: PdfColors.grey600)),
          pw.SizedBox(height: 6),
          pw.Text(value,
              style: pw.TextStyle(
                  fontSize: 14, fontWeight: pw.FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  static pw.Widget _vacio() => pw.Text('No hay registros para mostrar con estos filtros.',
      style: pw.TextStyle(color: _colorMuted));

  static pw.Widget _tabla(List<String> headers, List<List<String>> data) {
    return pw.TableHelper.fromTextArray(
      headers: headers,
      data: data,
      headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: PdfColors.white),
      headerDecoration: const pw.BoxDecoration(color: _colorTeal),
      cellAlignment: pw.Alignment.centerLeft,
      cellPadding: const pw.EdgeInsets.symmetric(vertical: 6, horizontal: 4),
      oddRowDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
    );
  }

  static pw.Widget _tablaFiados(List<Map<String, dynamic>> fiados,
      {required bool soloPendientes}) {
    final filtrados = soloPendientes
        ? fiados
            .where((f) => f['estado'] != 'pagado' && f['estado'] != 'cancelado')
            .toList()
        : fiados;

    if (filtrados.isEmpty) return _vacio();

    double suma = 0;
    final filas = filtrados.map((f) {
      final total = _num(f['monto_total']);
      final saldo = total - _num(f['monto_pagado']);
      suma += soloPendientes ? saldo : total;
      return [
        _fecha(f['creado_en']),
        _cliente(f['cliente']),
        (f['estado']?.toString() ?? 'pendiente').toUpperCase(),
        'S/ ${_moneda.format(total)}',
        if (soloPendientes) 'S/ ${_moneda.format(saldo)}',
      ];
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _tabla(
          ['Fecha', 'Cliente', 'Estado', 'Total', if (soloPendientes) 'Saldo'],
          filas,
        ),
        pw.SizedBox(height: 12),
        pw.Text(
          soloPendientes
              ? 'Saldo total por cobrar: S/ ${_moneda.format(suma)}'
              : 'Total fiado: S/ ${_moneda.format(suma)}',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: _colorInk),
        ),
      ],
    );
  }

  static pw.Widget _tablaCobros(List<Map<String, dynamic>> cobros) {
    if (cobros.isEmpty) return _vacio();

    double suma = 0;
    final filas = cobros.map((c) {
      final monto = _num(c['monto']);
      suma += monto;
      return [
        _fecha(c['fecha_pago']),
        _cliente(c['cliente']),
        'S/ ${_moneda.format(monto)}',
      ];
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _tabla(['Fecha', 'Cliente', 'Monto'], filas),
        pw.SizedBox(height: 12),
        pw.Text('Total cobrado: S/ ${_moneda.format(suma)}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: _colorInk)),
      ],
    );
  }

  static pw.Widget _tablaProductos(List<Map<String, dynamic>> productos) {
    if (productos.isEmpty) return _vacio();

    final filas = <List<String>>[];
    for (var i = 0; i < productos.length; i++) {
      final cant = _num(productos[i]['cantidad']);
      filas.add([
        '${i + 1}',
        (productos[i]['nombre'] ?? 'Producto').toString(),
        cant % 1 == 0 ? cant.toInt().toString() : cant.toStringAsFixed(2),
      ]);
    }
    return _tabla(['#', 'Producto', 'Cantidad vendida'], filas);
  }
}