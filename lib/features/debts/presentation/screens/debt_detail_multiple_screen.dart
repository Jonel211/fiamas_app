import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fiamas_app/core/constants/app_colors.dart';
import 'package:fiamas_app/core/offline/database/database_helper.dart';
import 'package:fiamas_app/core/utils/whatsapp_reminder.dart';
import 'package:fiamas_app/core/widgets/app_avatar.dart';
import 'package:fiamas_app/core/widgets/app_header_config.dart';
import 'package:fiamas_app/core/widgets/modal_bottom_sheet_layout.dart';
import 'package:fiamas_app/features/auth/presentation/providers/auth_provider.dart';

import '../../../auth/presentation/providers/tienda_provider.dart';
import '../../../customers/data/models/cliente_model.dart';
import '../../../customers/presentation/providers/cliente_provider.dart';
import '../../domain/debt.dart';
import 'collect_multiple_payment_screen.dart';
import '../../data/services/reminder_voucher_service.dart';
import '../widgets/reminder_voucher_card.dart';

/// FUNCIÓN GENÉRICA DE FORMATEO DE FECHAS (con fallback en español)
/// Usa 'intl' cuando el locale 'es' está disponible; si no, formatea
/// manualmente en español. Nunca devuelve la cadena ISO cruda.
String _formatearFecha(
  String? fechaIso, {
  String patron = 'd MMM yyyy',
  bool toLocal = false,
}) {
  if (fechaIso == null || fechaIso.isEmpty) return '';

  DateTime? date;
  try {
    date = DateTime.parse(fechaIso);
    if (toLocal) date = date.toLocal();
  } catch (_) {
    if (fechaIso.length >= 10) {
      final partes = fechaIso.substring(0, 10).split('-');
      if (partes.length == 3) {
        return '${partes[2]}/${partes[1]}/${partes[0]}';
      }
    }
    return fechaIso;
  }

  try {
    return DateFormat(patron, 'es').format(date!);
  } catch (_) {
    return _formatearManual(date!, conHora: patron.contains('HH:mm'));
  }
}

/// Formateo manual en español, idéntico al resultado de intl 'es'.
String _formatearManual(DateTime date, {bool conHora = false}) {
  const meses = [
    'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
    'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic',
  ];
  final base = '${date.day} ${meses[date.month - 1]} ${date.year}';
  if (!conHora) return base;
  final hora = date.hour.toString().padLeft(2, '0');
  final minuto = date.minute.toString().padLeft(2, '0');
  return '$base, $hora:$minuto';
}

// ✅ DEBE SER StatefulWidget para mantener la lógica de WhatsApp (setState)
class DebtDetailMultipleScreen extends StatefulWidget {
  final Map<String, dynamic> customer;
  final List<Debt> debts;
  final bool isCollectFlow;

  const DebtDetailMultipleScreen({
    super.key,
    required this.customer,
    required this.debts,
    this.isCollectFlow = false, 
  });

  @override
  State<DebtDetailMultipleScreen> createState() =>
      _DebtDetailMultipleScreenState();
}

class _DebtDetailMultipleScreenState extends State<DebtDetailMultipleScreen> {
  bool _bienvenidaEnviada = true;
  bool _cargando = true;
  bool _enviandoBienvenida = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargarFlag());
  }

  Future<void> _cargarFlag() async {
    if (!mounted) return;
    final telefono = _resolverTelefono(context);
    final tiendaId = context.read<TiendaProvider>().tiendaSeleccionadaId ??
        context.read<AuthProvider>().user?.tiendaId;

    if (telefono.isEmpty || tiendaId == null) {
      if (mounted) setState(() => _cargando = false);
      return;
    }

    final enviada = await DatabaseHelper.instance.getWhatsappBienvenida(
      telefono,
      tiendaId,
    );
    if (!mounted) return;
    setState(() {
      _bienvenidaEnviada = enviada;
      _cargando = false;
    });
  }

  String _getInitials(String name) {
    final cleanName = name.trim();
    if (cleanName.isEmpty) return 'C';

    final parts = cleanName.split(RegExp(r'\s+'));

    if (parts.length == 1) {
      if (parts.first.isEmpty) return 'C';
      return parts.first.substring(0, 1).toUpperCase();
    }

    final first = parts.first.isNotEmpty ? parts.first.substring(0, 1) : '';
    final last = parts.last.isNotEmpty ? parts.last.substring(0, 1) : '';
    return (first + last).toUpperCase();
  }

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
    final directo = widget.customer['phone']?.toString().trim() ?? '';
    if (directo.isNotEmpty) return directo;

    final clienteId = widget.customer['id']?.toString();
    if (clienteId != null && clienteId.isNotEmpty) {
      for (final cliente in context.read<ClienteProvider>().clientes) {
        if (cliente.id == clienteId && cliente.telefono.trim().isNotEmpty) {
          return cliente.telefono;
        }
      }
    }

    for (final debt in widget.debts) {
      if (debt.phone.trim().isNotEmpty) return debt.phone;
    }
    return '';
  }

  String? _resolverFoto(List<ClienteModel> clientes) {
    final clienteId = widget.customer['id']?.toString();
    if (clienteId != null && clienteId.isNotEmpty) {
      for (final cliente in clientes) {
        if (cliente.id == clienteId) return cliente.fotoPerfilUrl;
      }
    }

    final nombre = (widget.customer['name'] as String? ?? '').trim().toLowerCase();
    if (nombre.isNotEmpty) {
      for (final cliente in clientes) {
        if (cliente.nombreCompleto.trim().toLowerCase() == nombre) {
          return cliente.fotoPerfilUrl;
        }
      }
    }

    return widget.customer['imageUrl'] as String?;
  }

  List<String> _detalleFiados() {
    const maximoLineas = 8;
    final pendientes = widget.debts
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
          ? 'S/ ${restante.toStringAsFixed(2)} (resta S/ ${restante.toStringAsFixed(2)} de S/ ${debt.amount.toStringAsFixed(2)})'
          : 'S/ ${restante.toStringAsFixed(2)}';
      return '• ${debt.dateLabel} — $productos — $monto';
    }).toList();
    if (pendientes.length > maximoLineas) {
      lineas.add('y ${pendientes.length - (maximoLineas - 1)} fiados más');
    }
    return lineas;
  }

  void _mostrarSnackBar(BuildContext context, String mensaje, {bool error = false}) {
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

  void _mostrarAyuda() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('¿Cómo funciona?'),
        content: const Text(
          'El primer envío abre WhatsApp con un mensaje de bienvenida. '
          'Después, los recordatorios con imagen se envían solos.\n\n'
          'Si borraste el chat, envía un mensaje desde el perfil del cliente.',
          style: TextStyle(fontSize: 14, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Entendido'),
          ),
        ],
      ),
    );
  }

  Future<void> _onEnviarBienvenida() async {
    if (_enviandoBienvenida) return;

    final telefono = _resolverTelefono(context);
    if (telefono.isEmpty) {
      _mostrarSnackBar(context, 'Este cliente no tiene un teléfono registrado', error: true);
      return;
    }

    final tiendaId = context.read<TiendaProvider>().tiendaSeleccionadaId ??
        context.read<AuthProvider>().user?.tiendaId;
    if (tiendaId == null) {
      _mostrarSnackBar(context, 'No se pudo identificar la tienda', error: true);
      return;
    }

    final tienda = context.read<TiendaProvider>().tiendaSeleccionada;
    final nombreTienda = (tienda?.nombre.isNotEmpty ?? false) ? tienda!.nombre : 'Mi tienda';
    final nombreCliente = (widget.customer['name'] as String?)?.trim() ?? 'Cliente';

    setState(() => _enviandoBienvenida = true);

    try {
      final mensaje = construirMensajeBienvenida(
        nombreCliente: nombreCliente,
        nombreTienda: nombreTienda,
      );

      final ok = await abrirWhatsapp(telefono: telefono, mensaje: mensaje);

      if (!ok) {
        if (mounted) {
          setState(() => _enviandoBienvenida = false);
          _mostrarSnackBar(context, 'No se pudo abrir WhatsApp', error: true);
        }
        return;
      }

      await DatabaseHelper.instance.setWhatsappBienvenida(telefono, tiendaId, enviada: true);

      if (!mounted) return;
      setState(() {
        _bienvenidaEnviada = true;
        _enviandoBienvenida = false;
      });

      _mostrarSnackBar(context, 'Toca "Enviar" en WhatsApp. Después podrás enviar recordatorios con imagen.');
    } catch (e) {
      if (!mounted) return;
      setState(() => _enviandoBienvenida = false);
      _mostrarSnackBar(context, 'Error al abrir WhatsApp', error: true);
    }
  }

  Future<void> _enviarRecordatorio(
    BuildContext context, {
    required String nombreCliente,
    required String nombreTienda,
    required double totalRestante,
  }) async {
    if (totalRestante <= 0) {
      _mostrarSnackBar(context, 'Este cliente no tiene saldo pendiente', error: true);
      return;
    }
    final telefono = _resolverTelefono(context);
    if (telefono.isEmpty) {
      _mostrarSnackBar(context, 'Este cliente no tiene un teléfono registrado', error: true);
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
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                        child: Row(
                          children: [
                            const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.teal, size: 20),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                opcion.label,
                                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
                              ),
                            ),
                            const Icon(Icons.chevron_right_rounded, color: AppColors.inkMuted, size: 20),
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

    final tienda = context.read<TiendaProvider>().tiendaSeleccionada;
    final pendientes = widget.debts.where((d) => d.status != DebtStatus.pagado).toList();
    final lineas = VoucherLinea.desdeDeudas(pendientes);

    try {
      final resultado = await ReminderVoucherService.enviarRecordatorio(
        context,
        tienda: tienda,
        nombreCliente: nombreCliente,
        telefono: telefono,
        lineas: lineas,
        total: totalRestante,
        tono: tono,
      );
      if (!context.mounted) return;

      if (resultado == ResultadoEnvio.error) {
        _mostrarSnackBar(context, 'No se pudo generar la imagen', error: true);
        return;
      }
      _mostrarSnackBar(
        context,
        resultado == ResultadoEnvio.directo
            ? 'Revisa la imagen en el chat de $nombreCliente y pulsa enviar'
            : 'Elige el chat de $nombreCliente en WhatsApp para enviarla',
      );
    } catch (e) {
      debugPrint('ERROR RECORDATORIO: $e');
      if (context.mounted) {
        _mostrarSnackBar(context, 'No se pudo preparar el recordatorio', error: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rawName = widget.customer['name'] as String? ?? '';
    final name = rawName.trim().isEmpty ? 'Cliente' : rawName;

    final clientes = context.watch<ClienteProvider>().clientes;
    final photoUrl = _resolverFoto(clientes);
    final initials = _getInitials(name);

    final tienda = context.watch<TiendaProvider>().tiendaSeleccionada;
    final nombreTienda = (tienda?.nombre.isNotEmpty ?? false) ? tienda!.nombre : 'Mi tienda';
    
    final allPaid = widget.debts.isEmpty || widget.debts.every((d) => d.status == DebtStatus.pagado);

    final totalOriginal = widget.debts.fold(0.0, (sum, d) => sum + d.amount);
    final totalPagado = widget.debts.fold(0.0, (sum, d) => sum + d.paidAmount);
    final totalRestante = totalOriginal - totalPagado;
    final canCollect = totalRestante > 0 && widget.debts.any((d) => d.isSelectable);

    final fiadosCount = widget.debts.length;
    final fiadosLabel = '$fiadosCount fiado${fiadosCount == 1 ? '' : 's'}';
    final fiadosSubtitle = widget.isCollectFlow
        ? '$fiadosLabel seleccionado${fiadosCount == 1 ? '' : 's'}'
        : fiadosLabel;

    final Map<String, List<DebtItem>> productsByDate = {};
    for (final debt in widget.debts) {
      productsByDate.putIfAbsent(debt.dateLabel, () => []);
      productsByDate[debt.dateLabel]!.addAll(debt.items);
    }

    final mostrarSubtitulo = !_cargando && !_bienvenidaEnviada;

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
                    AppAvatar.cliente(
                      imageUrl: photoUrl,
                      name: name,
                      size: 44,
                      fontSize: 14,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            name,
                            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            fiadosSubtitle,
                            style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.teal),
                    ),
                    const SizedBox(height: 16),
                    ...widget.debts.map(
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
                                    style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
                                  ),
                                  // Si está PAGADO: usa el formato con hora y zona horaria local
                                  if (debt.status == DebtStatus.pagado && debt.paidDate != null && debt.paidDate!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.check_circle_outline, size: 14, color: AppColors.success),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Pagado: ${_formatearFecha(debt.paidDate, patron: 'd MMM yyyy, HH:mm', toLocal: true)}',
                                          style: const TextStyle(fontSize: 12, color: AppColors.success, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ]
                                  // Si NO está pagado: usa el formato solo de fecha
                                  else if (debt.dueDate != null && debt.dueDate!.isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Row(
                                      children: [
                                        const Icon(Icons.event_outlined, size: 14, color: AppColors.gold),
                                        const SizedBox(width: 6),
                                        Text(
                                          'Vence: ${_formatearFecha(debt.dueDate)}',
                                          style: const TextStyle(fontSize: 12, color: AppColors.gold, fontWeight: FontWeight.w600),
                                        ),
                                      ],
                                    ),
                                  ],
                                  // El chip de estado SOLO se muestra si NO está pagado
                                  if (debt.status != DebtStatus.pagado) ...[
                                    const SizedBox(height: 6),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
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
                                ],
                              ),
                            ),
                            Text(
                              'S/ ${debt.amount.toStringAsFixed(2)}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink),
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.teal),
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
                              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.inkMuted, letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 6),
                            const _ProductReceiptHeaderRow(),
                            const SizedBox(height: 2),
                            for (var i = 0; i < items.length; i++) ...[
                              _ProductReceiptRow(
                                quantityLabel: _formatQuantityWithUnit(items[i].quantity, items[i].unit),
                                productName: items[i].productName,
                                unitPrice: 'S/ ${items[i].unitPrice.toStringAsFixed(2)}',
                                amount: 'S/ ${items[i].subtotal.toStringAsFixed(2)}',
                              ),
                              if (i < items.length - 1)
                                const Divider(height: 1, thickness: 0.6, color: AppColors.mist),
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
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.teal),
                    ),
                    const SizedBox(height: 12),
                    _buildSummaryRow('Total Deuda Original', 'S/ ${totalOriginal.toStringAsFixed(2)}'),
                    const SizedBox(height: 8),
                    _buildSummaryRow('Total Pagado', 'S/ ${totalPagado.toStringAsFixed(2)}'),
                    const Divider(height: 16, color: AppColors.mist),
                    _buildSummaryRow('Total Deuda Actual Restante', 'S/ ${totalRestante.toStringAsFixed(2)}', isBold: true),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('TOTAL DEUDA', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.ink)),
                  Text(
                    'S/${totalRestante.toStringAsFixed(2)}',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: allPaid ? AppColors.success : AppColors.gold),
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
                            customer: widget.customer,
                            selectedDebts: widget.debts,
                          ),
                        ),
                      );
                      if (result == true && context.mounted) {
                        Navigator.pop(context);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Cobrar esta deuda', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(height: 12),
                
                if (mostrarSubtitulo)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Text(
                      'Enviar recordatorio',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.inkMuted),
                    ),
                  ),
                  
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _enviandoBienvenida
                            ? null
                            : (_bienvenidaEnviada
                                ? () => _enviarRecordatorio(
                                      context,
                                      nombreCliente: name,
                                      nombreTienda: nombreTienda,
                                      totalRestante: totalRestante,
                                    )
                                : _onEnviarBienvenida),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.teal,
                          side: const BorderSide(color: AppColors.teal),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                        child: _enviandoBienvenida
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.teal),
                              )
                            : Text(
                                _bienvenidaEnviada ? 'Enviar recordatorio' : 'Enviar bienvenida',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.help_outline_rounded, color: AppColors.inkMuted),
                      tooltip: '¿Cómo funciona?',
                      onPressed: _mostrarAyuda,
                    ),
                  ],
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
        Text(label, style: TextStyle(fontSize: 14, color: AppColors.ink, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(value, style: TextStyle(fontSize: 14, color: AppColors.ink, fontWeight: isBold ? FontWeight.bold : FontWeight.w600)),
      ],
    );
  }
}

// ✅ Se mantienen estos widgets al final del archivo
const double _receiptQuantityWidth = 54;
const double _receiptUnitPriceWidth = 76;
const double _receiptAmountWidth = 76;
const double _receiptColumnGap = 6;
const double _receiptProductUnitGap = 12;
const double _receiptUnitAmountGap = 12;

const List<FontFeature> _receiptTabularFigures = [FontFeature.tabularFigures()];

const TextStyle _receiptHeaderStyle = TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.inkMuted);

const TextStyle _receiptNumericHeaderStyle = TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.inkMuted, fontFeatures: _receiptTabularFigures);

const TextStyle _receiptUnitPriceStyle = TextStyle(fontSize: 14, color: AppColors.ink, fontFeatures: _receiptTabularFigures);

const TextStyle _receiptAmountStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink, fontFeatures: _receiptTabularFigures);

class _ProductReceiptHeaderRow extends StatelessWidget {
  const _ProductReceiptHeaderRow();

  @override
  Widget build(BuildContext context) {
    return const Row(
      children: [
        SizedBox(width: _receiptQuantityWidth, child: Text('Cant.', style: _receiptHeaderStyle)),
        SizedBox(width: _receiptColumnGap),
        Expanded(child: Text('Producto', style: _receiptHeaderStyle)),
        SizedBox(width: _receiptProductUnitGap),
        SizedBox(width: _receiptUnitPriceWidth, child: Text('P. Unit.', textAlign: TextAlign.right, style: _receiptNumericHeaderStyle)),
        SizedBox(width: _receiptUnitAmountGap),
        SizedBox(width: _receiptAmountWidth, child: Text('Importe', textAlign: TextAlign.right, style: _receiptNumericHeaderStyle)),
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
            child: Text(quantityLabel, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: AppColors.ink)),
          ),
          const SizedBox(width: _receiptColumnGap),
          Expanded(
            child: Text(productName, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 14, color: AppColors.ink)),
          ),
          const SizedBox(width: _receiptProductUnitGap),
          SizedBox(
            width: _receiptUnitPriceWidth,
            child: Text(unitPrice, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: _receiptUnitPriceStyle),
          ),
          const SizedBox(width: _receiptUnitAmountGap),
          SizedBox(
            width: _receiptAmountWidth,
            child: Text(amount, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.right, style: _receiptAmountStyle),
          ),
        ],
      ),
    );
  }
}