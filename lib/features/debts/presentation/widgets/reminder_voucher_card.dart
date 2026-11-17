import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/whatsapp_reminder.dart';
import '../../domain/debt.dart';

/// Un producto dentro de un fiado.
class VoucherItem {
  const VoucherItem({
    required this.nombre,
    required this.cantidad,
    required this.subtotal,
  });

  final String nombre;
  final double cantidad;
  final double subtotal;
}

/// Un fiado pendiente dentro del voucher.
class VoucherLinea {
  const VoucherLinea({
    required this.fecha,
    required this.detalle,
    required this.monto,
    this.original,
    this.pagado = 0,
    this.items = const [],
  });

  final String fecha;
  final String detalle;
  final double monto; // lo que resta por pagar
  final double? original; // monto original del fiado
  final double pagado; // lo abonado hasta ahora
  final List<VoucherItem> items;

  double get montoOriginal => original ?? monto;

  static String _fecha(String label) {
    final m = RegExp(r'(\d{4})-(\d{2})-(\d{2})').firstMatch(label);
    if (m != null) return '${m[3]}/${m[2]}/${m[1]}';
    return label.replaceFirst('Creado: ', '');
  }

  /// Convierte los fiados pendientes en líneas del voucher.
  static List<VoucherLinea> desdeDeudas(List<Debt> deudas) {
    return deudas
        .where((d) => d.status != DebtStatus.pagado && d.remainingAmount > 0)
        .map((d) {
      final productos = d.items.isEmpty
          ? 'Sin detalle de productos'
          : d.items.map((i) => i.productName).join(', ');
      return VoucherLinea(
        fecha: _fecha(d.dateLabel),
        detalle: productos,
        monto: d.remainingAmount,
        original: d.amount,
        pagado: d.paidAmount,
        items: d.items
            .map((i) => VoucherItem(
                  nombre: i.productName,
                  cantidad: i.quantity,
                  subtotal: i.subtotal,
                ))
            .toList(),
      );
    }).toList();
  }
}

/// Tarjeta tipo voucher que se captura como imagen para enviar por WhatsApp.
class ReminderVoucherCard extends StatelessWidget {
  const ReminderVoucherCard({
    super.key,
    required this.nombreTienda,
    this.ruc,
    this.logoTiendaUrl,
    required this.nombreCliente,
    required this.lineas,
    required this.total,
    required this.tono,
    required this.emision,
    this.width = 380,
  });

  final String nombreTienda;
  final String? ruc;
  final String? logoTiendaUrl; // ya no se dibuja; se conserva por compatibilidad
  final String nombreCliente;
  final List<VoucherLinea> lineas;
  final double total;
  final TonoRecordatorio tono;
  final DateTime emision;
  final double width;

  static const _maxFiados = 8;
  static const _maxProductos = 6;

  Color get _color => tono == TonoRecordatorio.urgente
      ? AppColors.danger
      : tono == TonoRecordatorio.firme
          ? AppColors.gold
          : AppColors.teal;

  String get titulo => tono == TonoRecordatorio.urgente
      ? 'Pago pendiente: atención inmediata'
      : tono == TonoRecordatorio.firme
          ? 'Aviso de pago pendiente'
          : 'Recordatorio de pago';

  String get _mensaje => tono == TonoRecordatorio.urgente
      ? 'Tu deuda requiere atención inmediata. Comunícate con nosotros hoy para regularizarla.'
      : tono == TonoRecordatorio.firme
          ? 'Tu saldo pendiente debe regularizarse pronto. Por favor, comunícate con nosotros.'
          : 'Te recordamos con cariño que tienes un saldo pendiente. ¡Gracias!';

  String _money(double v) => 'S/ ${v.toStringAsFixed(2)}';

  String _cant(double v) =>
      v % 1 == 0 ? v.toInt().toString() : v.toStringAsFixed(2);

  String get _fechaEmision {
    String d(int n) => n.toString().padLeft(2, '0');
    return '${d(emision.day)}/${d(emision.month)}/${emision.year} '
        '${d(emision.hour)}:${d(emision.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    final visibles = lineas.length > _maxFiados
        ? lineas.take(_maxFiados - 1).toList()
        : lineas;
    final ocultos = lineas.length - visibles.length;
    final tieneRuc = ruc != null && ruc!.trim().isNotEmpty;

    final totalOriginal = lineas.fold<double>(0, (s, l) => s + l.montoOriginal);
    final totalPagado = lineas.fold<double>(0, (s, l) => s + l.pagado);

    return Container(
      width: width,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ── Encabezado Fiamas (centrado) ──
          Container(
            color: _color,
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
            child: Column(
              children: [
                SizedBox(
                  height: 46,
                  child: Image.asset(
                    'assets/images/logoo.png',
                    fit: BoxFit.contain,
                    errorBuilder: (_, _, _) => const Icon(
                      Icons.storefront_rounded,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'FIAMAS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  titulo,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Tienda (centrado) ──
                Text(
                  'Negocio $nombreTienda',
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                if (tieneRuc) ...[
                  const SizedBox(height: 2),
                  Text(
                    'RUC: ${ruc!.trim()}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.mist),
                const SizedBox(height: 14),

                // ── Cliente y fecha (centrado) ──
                const Text(
                  'CLIENTE',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.8,
                    color: AppColors.inkMuted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  nombreCliente,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Emitido: $_fechaEmision',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.inkMuted,
                  ),
                ),
                const SizedBox(height: 14),
                const Divider(height: 1, color: AppColors.mist),
                const SizedBox(height: 14),

                // ── Fiados con sus productos ──
                const Text(
                  'DETALLE DE FIADOS PENDIENTES',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.6,
                    color: AppColors.inkMuted,
                  ),
                ),
                const SizedBox(height: 12),

                for (final l in visibles) _bloqueFiado(l),

                if (ocultos > 0)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'y $ocultos fiados más',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                        color: AppColors.inkMuted,
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ── Resumen de cuenta ──
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: _color.withValues(alpha: 0.5), width: 1.5),
            ),
            child: Column(
              children: [
                Text(
                  'RESUMEN DE CUENTA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                    color: _color,
                  ),
                ),
                const SizedBox(height: 12),
                _filaResumen('Total deuda original', _money(totalOriginal)),
                const SizedBox(height: 6),
                _filaResumen('Total pagado', _money(totalPagado)),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 10),
                  child: Divider(height: 1, color: AppColors.mist),
                ),
                const Text(
                  'TOTAL A PAGAR',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _money(total),
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: _color,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
            child: Text(
              _mensaje,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                height: 1.4,
                color: AppColors.ink,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bloqueFiado(VoucherLinea l) {
    final visibles = l.items.length > _maxProductos
        ? l.items.take(_maxProductos - 1).toList()
        : l.items;
    final ocultos = l.items.length - visibles.length;
    final huboAbono = l.pagado > 0.001;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mist),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Fiado del ${l.fecha}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: AppColors.inkMuted,
                ),
              ),
              Text(
                _money(l.montoOriginal),
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (l.items.isEmpty)
            Text(
              l.detalle,
              style: const TextStyle(fontSize: 13, color: AppColors.ink),
            )
          else
            for (final i in visibles)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${_cant(i.cantidad)} × ${i.nombre}',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 1),
                          Text(
                            'S/ ${_precioUnitario(i)} c/u',
                            style: const TextStyle(
                              fontSize: 11,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        _money(i.subtotal),
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          if (ocultos > 0)
            Text(
              'y $ocultos productos más',
              style: const TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: AppColors.inkMuted,
              ),
            ),
          if (huboAbono) ...[
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Divider(height: 1, color: AppColors.mist),
            ),
            _filaResumen('Pagado', _money(l.pagado), chico: true),
            const SizedBox(height: 3),
            _filaResumen('Resta', _money(l.monto), chico: true, negrita: true),
          ],
        ],
      ),
    );
  }

  /// Precio unitario derivado del subtotal y la cantidad (fiado_detalle).
  String _precioUnitario(VoucherItem i) {
    final unitario = i.cantidad > 0 ? i.subtotal / i.cantidad : i.subtotal;
    return unitario.toStringAsFixed(2);
  }

  Widget _filaResumen(
    String label,
    String valor, {
    bool chico = false,
    bool negrita = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: chico ? 12 : 13,
            color: AppColors.ink,
            fontWeight: negrita ? FontWeight.w800 : FontWeight.w500,
          ),
        ),
        Text(
          valor,
          style: TextStyle(
            fontSize: chico ? 12 : 14,
            color: AppColors.ink,
            fontWeight: negrita ? FontWeight.w800 : FontWeight.w700,
          ),
        ),
      ],
    );
  }
}