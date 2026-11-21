import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fiamas_app/core/constants/app_colors.dart';
import 'package:fiamas_app/core/utils/whatsapp_reminder.dart';
import 'package:fiamas_app/core/widgets/app_avatar.dart';
import 'package:fiamas_app/core/widgets/app_header_config.dart';
import 'package:fiamas_app/core/widgets/modal_bottom_sheet_layout.dart';

import '../../../auth/presentation/providers/tienda_provider.dart';
import '../../../customers/presentation/providers/cliente_provider.dart';
import '../../domain/debt.dart';
import 'collect_multiple_payment_screen.dart';

class DebtDetailMultipleScreen extends StatelessWidget {
  final Map<String, dynamic> customer;
  final List<Debt> debts;

  final bool isCollectFlow;

  const DebtDetailMultipleScreen({
    super.key,
    required this.customer,
    required this.debts,
    this.isCollectFlow = false,
  });

  String _getStatusText(DebtStatus status) {
    switch (status) {
      case DebtStatus.pendiente:
        return 'Pendiente';
      case DebtStatus.parcial:
        return 'Parcial';
      case DebtStatus.pagado:
        return 'Pagado';
    }
  }

  Color _getStatusColor(DebtStatus status) {
    switch (status) {
      case DebtStatus.pendiente:
        return AppColors.gold;
      case DebtStatus.parcial:
        return AppColors.parcial;
      case DebtStatus.pagado:
        return AppColors.success;
    }
  }

  Color _getStatusBgColor(DebtStatus status) {
    switch (status) {
      case DebtStatus.pendiente:
        return AppColors.gold.withValues(alpha: 0.15);
      case DebtStatus.parcial:
        return AppColors.parcialSoft;
      case DebtStatus.pagado:
        return AppColors.success.withValues(alpha: 0.15);
    }
  }

  /// Formatea cantidad + unidad: enteros sin decimales y peso/volumen con
  /// hasta 3 decimales sin ceros sobrantes.
  String _formatQuantityWithUnit(double quantity, String? unit) {
    final rounded = double.parse(quantity.toStringAsFixed(3));
    final quantityText = rounded == rounded.roundToDouble()
        ? rounded.toStringAsFixed(0)
        : rounded.toStringAsFixed(3).replaceFirst(RegExp(r'\.?0+$'), '');

    final rawUnit = (unit ?? '').trim();
    final unitKey = rawUnit.toLowerCase();
    final unitText =
        rawUnit.isEmpty ||
            unitKey == 'unidad' ||
            unitKey == 'unidades' ||
            unitKey == 'und' ||
            unitKey == 'u'
        ? 'und'
        : rawUnit;

    return '$quantityText $unitText';
  }

  String _resolverTelefono(BuildContext context) {
    final directo = customer['phone']?.toString().trim() ?? '';
    if (directo.isNotEmpty) return directo;

    final clienteId = customer['id']?.toString();
    if (clienteId != null && clienteId.isNotEmpty) {
      for (final cliente in context.read<ClienteProvider>().clientes) {
        if (cliente.id == clienteId && cliente.telefono.trim().isNotEmpty) {
          return cliente.telefono;
        }
      }
    }

    for (final debt in debts) {
      if (debt.phone.trim().isNotEmpty) return debt.phone;
    }

    return '';
  }

  List<String> _detalleFiados() {
    const maximoLineas = 8;
    final pendientes = debts
        .where((debt) => debt.status != DebtStatus.pagado)
        .toList();
    final visibles = pendientes.length > maximoLineas
        ? pendientes.take(maximoLineas - 1)
        : pendientes;

    final lineas = visibles.map((debt) {
      final productos = debt.items.isEmpty
          ? 'Sin detalle de productos'
          : debt.items.map((item) => item.productName).join(', ');
      final restante = debt.remainingAmount < 0 ? 0.0 : debt.remainingAmount;
      final monto = (debt.paidAmount > 0 && restante > 0)
          ? 'S/ ${restante.toStringAsFixed(2)} '
                '(resta S/ ${restante.toStringAsFixed(2)} de '
                'S/ ${debt.amount.toStringAsFixed(2)})'
          : 'S/ ${restante.toStringAsFixed(2)}';
      return '• ${debt.dateLabel} — $productos — $monto';
    }).toList();

    if (pendientes.length > maximoLineas) {
      lineas.add('y ${pendientes.length - (maximoLineas - 1)} fiados más');
    }

    return lineas;
  }

  void _mostrarSnackBar(
    BuildContext context,
    String mensaje, {
    bool error = false,
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          style: TextStyle(color: error ? AppColors.danger : AppColors.onBrand),
        ),
        backgroundColor: error ? AppColors.dangerSoft : AppColors.success,
      ),
    );
  }

  Future<void> _enviarRecordatorio(
    BuildContext context, {
    required String nombreCliente,
    required String nombreTienda,
    required double totalRestante,
  }) async {
    if (totalRestante <= 0) {
      _mostrarSnackBar(
        context,
        'Este cliente no tiene saldo pendiente',
        error: true,
      );
      return;
    }

    final telefono = _resolverTelefono(context);
    if (telefono.isEmpty) {
      _mostrarSnackBar(
        context,
        'Este cliente no tiene un teléfono registrado',
        error: true,
      );
      return;
    }

    final tono = await showModalBottomSheet<TonoRecordatorio>(
      context: context,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return ModalBottomSheetLayout(
          title: 'Enviar recordatorio',
          subtitle: 'Elige el tono del mensaje',
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final opcion in TonoRecordatorio.values)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Material(
                    color: AppColors.surfaceMuted,
                    borderRadius: BorderRadius.circular(12),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => Navigator.pop(sheetContext, opcion),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.chat_bubble_outline_rounded,
                              color: AppColors.teal,
                              size: 20,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                opcion.label,
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.ink,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: AppColors.inkMuted,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );

    if (tono == null || !context.mounted) return;

    final mensaje = tono.mensaje(
      nombreCliente: nombreCliente,
      deuda: totalRestante.toStringAsFixed(2),
      nombreTienda: nombreTienda,
      detalle: _detalleFiados(),
    );

    final abierto = await abrirWhatsapp(telefono: telefono, mensaje: mensaje);

    if (!context.mounted) return;

    if (!abierto) {
      _mostrarSnackBar(context, 'No se pudo abrir WhatsApp', error: true);
      return;
    }

    _mostrarSnackBar(context, 'Recordatorio preparado para $nombreCliente');
  }

  @override
  Widget build(BuildContext context) {
    final rawName = customer['name'] as String? ?? '';
    final name = rawName.trim().isEmpty ? 'Cliente' : rawName;

    final photoUrl = customer['imageUrl'] as String?;
    final tienda = context.watch<TiendaProvider>().tiendaSeleccionada;
    final nombreTienda = (tienda?.nombre.isNotEmpty ?? false)
        ? tienda!.nombre
        : 'Mi tienda';
    final allPaid =
        debts.isEmpty || debts.every((d) => d.status == DebtStatus.pagado);

    // Calculos reales sobre los fiados recibidos
    final totalOriginal = debts.fold(0.0, (sum, d) => sum + d.amount);
    final totalPagado = debts.fold(0.0, (sum, d) => sum + d.paidAmount);
    final totalRestante = totalOriginal - totalPagado;

    // Solo se puede cobrar si queda saldo y hay fiados seleccionables.
    final canCollect = totalRestante > 0 && debts.any((d) => d.isSelectable);

    final fiadosCount = debts.length;
    final fiadosLabel = '$fiadosCount fiado${fiadosCount == 1 ? '' : 's'}';
    final fiadosSubtitle = isCollectFlow
        ? '$fiadosLabel seleccionado${fiadosCount == 1 ? '' : 's'}'
        : fiadosLabel;

    final Map<String, List<DebtItem>> productsByDate = {};
    for (final debt in debts) {
      productsByDate.putIfAbsent(debt.dateLabel, () => []);
      productsByDate[debt.dateLabel]!.addAll(debt.items);
    }

    return AppHeaderConfig(
      title: 'Detalle de fiados',
      showBack: true,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Tarjeta del cliente
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mist),
                ),
                child: Row(
                  children: [
                    AppAvatar(
                      imageUrl: photoUrl,
                      name: name,
                      size: 44,
                      backgroundColor: AppColors.teal,
                      foregroundColor: Colors.white,
                      fontSize: 14,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            fiadosSubtitle,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Fiados incluidos
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mist),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Fiados incluidos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.teal,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ...debts.map(
                      (debt) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    debt.dateLabel,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.inkMuted,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _getStatusBgColor(debt.status),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      _getStatusText(debt.status),
                                      style: TextStyle(
                                        color: _getStatusColor(debt.status),
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'S/ ${debt.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Productos
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mist),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Productos',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.teal,
                      ),
                    ),
                    const SizedBox(height: 12),
                    ...productsByDate.entries.map((entry) {
                      final date = entry.key;
                      final items = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              date.toUpperCase(),
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.inkMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                            const _ProductReceiptHeaderRow(),
                            const SizedBox(height: 2),
                            for (var i = 0; i < items.length; i++) ...[
                              _ProductReceiptRow(
                                quantityLabel: _formatQuantityWithUnit(
                                  items[i].quantity,
                                  items[i].unit,
                                ),
                                productName: items[i].productName,
                                unitPrice:
                                    'S/ ${items[i].unitPrice.toStringAsFixed(2)}',
                                amount:
                                    'S/ ${items[i].subtotal.toStringAsFixed(2)}',
                              ),
                              if (i < items.length - 1)
                                const Divider(
                                  height: 1,
                                  thickness: 0.6,
                                  color: AppColors.mist,
                                ),
                            ],
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Resumen de cuenta
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.skyBlue.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.teal, width: 2),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Resumen de cuenta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.teal,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow(
                      'Total Deuda Original',
                      'S/ ${totalOriginal.toStringAsFixed(2)}',
                    ),
                    const SizedBox(height: 8),
                    _buildSummaryRow(
                      'Total Pagado',
                      'S/ ${totalPagado.toStringAsFixed(2)}',
                    ),
                    const Divider(height: 16, color: AppColors.mist),
                    _buildSummaryRow(
                      'Total Deuda Actual Restante',
                      'S/ ${totalRestante.toStringAsFixed(2)}',
                      isBold: true,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'TOTAL DEUDA',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                  Text(
                    'S/${totalRestante.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: allPaid ? AppColors.success : AppColors.gold,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (canCollect) ...[
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CollectMultiplePaymentScreen(
                            customer: customer,
                            selectedDebts: debts,
                          ),
                        ),
                      );

                      // Si el pago se registro con exito, cerramos esta pantalla
                      // para volver al historial ya actualizado.
                      if (result == true && context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Cobrar esta deuda',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () => _enviarRecordatorio(
                      context,
                      nombreCliente: name,
                      nombreTienda: nombreTienda,
                      totalRestante: totalRestante,
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.teal,
                      side: const BorderSide(color: AppColors.teal),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Enviar recordatorio',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.ink,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.ink,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

const double _receiptQuantityWidth = 54;
const double _receiptUnitPriceWidth = 76;
const double _receiptAmountWidth = 76;
const double _receiptColumnGap = 6;
const double _receiptProductUnitGap = 12;
const double _receiptUnitAmountGap = 12;

const List<FontFeature> _receiptTabularFigures = [FontFeature.tabularFigures()];

const TextStyle _receiptHeaderStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w600,
  color: AppColors.inkMuted,
);

const TextStyle _receiptNumericHeaderStyle = TextStyle(
  fontSize: 11,
  fontWeight: FontWeight.w600,
  color: AppColors.inkMuted,
  fontFeatures: _receiptTabularFigures,
);

const TextStyle _receiptUnitPriceStyle = TextStyle(
  fontSize: 14,
  color: AppColors.ink,
  fontFeatures: _receiptTabularFigures,
);

const TextStyle _receiptAmountStyle = TextStyle(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  color: AppColors.ink,
  fontFeatures: _receiptTabularFigures,
);

class _ProductReceiptHeaderRow extends StatelessWidget {
  const _ProductReceiptHeaderRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(
          width: _receiptQuantityWidth,
          child: Text('Cant.', style: _receiptHeaderStyle),
        ),
        SizedBox(width: _receiptColumnGap),
        Expanded(child: Text('Producto', style: _receiptHeaderStyle)),
        SizedBox(width: _receiptProductUnitGap),
        SizedBox(
          width: _receiptUnitPriceWidth,
          child: Text(
            'P. Unit.',
            textAlign: TextAlign.right,
            style: _receiptNumericHeaderStyle,
          ),
        ),
        SizedBox(width: _receiptUnitAmountGap),
        SizedBox(
          width: _receiptAmountWidth,
          child: Text(
            'Importe',
            textAlign: TextAlign.right,
            style: _receiptNumericHeaderStyle,
          ),
        ),
      ],
    );
  }
}

class _ProductReceiptRow extends StatelessWidget {
  const _ProductReceiptRow({
    required this.quantityLabel,
    required this.productName,
    required this.unitPrice,
    required this.amount,
  });

  final String quantityLabel;
  final String productName;
  final String unitPrice;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _receiptQuantityWidth,
            child: Text(
              quantityLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: AppColors.ink),
            ),
          ),
          const SizedBox(width: _receiptColumnGap),
          Expanded(
            child: Text(
              productName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 14, color: AppColors.ink),
            ),
          ),
          const SizedBox(width: _receiptProductUnitGap),
          SizedBox(
            width: _receiptUnitPriceWidth,
            child: Text(
              unitPrice,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: _receiptUnitPriceStyle,
            ),
          ),
          const SizedBox(width: _receiptUnitAmountGap),
          SizedBox(
            width: _receiptAmountWidth,
            child: Text(
              amount,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
              style: _receiptAmountStyle,
            ),
          ),
        ],
      ),
    );
  }
}
