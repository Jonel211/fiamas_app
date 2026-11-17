import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fiamas_app/core/constants/app_colors.dart';
import 'package:fiamas_app/core/offline/database/database_helper.dart';
import 'package:fiamas_app/core/utils/whatsapp_reminder.dart';
import 'package:fiamas_app/core/widgets/app_header_config.dart';
import 'package:fiamas_app/core/widgets/modal_bottom_sheet_layout.dart';
import 'package:fiamas_app/features/auth/presentation/providers/auth_provider.dart';

import '../../../auth/presentation/providers/tienda_provider.dart';
import '../../../customers/presentation/providers/cliente_provider.dart';
import '../../domain/debt.dart';
import 'collect_multiple_payment_screen.dart';
import '../../data/services/reminder_voucher_service.dart';
import '../widgets/reminder_voucher_card.dart';

class DebtDetailMultipleScreen extends StatefulWidget {
  final Map<String, dynamic> customer;
  final List<Debt> debts;

  const DebtDetailMultipleScreen({
    super.key,
    required this.customer,
    required this.debts,
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
        return AppColors.skyBlue;
      case DebtStatus.pagado:
        return AppColors.success;
    }
  }

  Color _getStatusBgColor(DebtStatus status) {
    switch (status) {
      case DebtStatus.pendiente:
        return AppColors.gold.withValues(alpha: 0.15);
      case DebtStatus.parcial:
        return AppColors.skyBlue.withValues(alpha: 0.15);
      case DebtStatus.pagado:
        return AppColors.success.withValues(alpha: 0.15);
    }
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
      _mostrarSnackBar(
        context,
        'Este cliente no tiene un teléfono registrado',
        error: true,
      );
      return;
    }

    final tiendaId = context.read<TiendaProvider>().tiendaSeleccionadaId ??
        context.read<AuthProvider>().user?.tiendaId;
    if (tiendaId == null) {
      _mostrarSnackBar(
        context,
        'No se pudo identificar la tienda',
        error: true,
      );
      return;
    }

    final tienda = context.read<TiendaProvider>().tiendaSeleccionada;
    final nombreTienda = (tienda?.nombre.isNotEmpty ?? false)
        ? tienda!.nombre
        : 'Mi tienda';
    final nombreCliente =
        (widget.customer['name'] as String?)?.trim() ?? 'Cliente';

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

      await DatabaseHelper.instance.setWhatsappBienvenida(
        telefono,
        tiendaId,
        enviada: true,
      );

      if (!mounted) return;
      setState(() {
        _bienvenidaEnviada = true;
        _enviandoBienvenida = false;
      });

      _mostrarSnackBar(
        context,
        'Toca "Enviar" en WhatsApp. Después podrás enviar recordatorios con imagen.',
      );
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

    final tienda = context.read<TiendaProvider>().tiendaSeleccionada;
    final pendientes = widget.debts
        .where((d) => d.status != DebtStatus.pagado)
        .toList();
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
        _mostrarSnackBar(
          context,
          'No se pudo preparar el recordatorio',
          error: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final rawName = widget.customer['name'] as String? ?? '';
    final name = rawName.trim().isEmpty ? 'Cliente' : rawName;

    final initials = _getInitials(name);
    final photoUrl = widget.customer['imageUrl'] as String?;
    final tienda = context.watch<TiendaProvider>().tiendaSeleccionada;
    final nombreTienda = (tienda?.nombre.isNotEmpty ?? false)
        ? tienda!.nombre
        : 'Mi tienda';
    final allPaid =
        widget.debts.every((d) => d.status == DebtStatus.pagado);

    final totalOriginal =
        widget.debts.fold(0.0, (sum, d) => sum + d.amount);
    final totalPagado =
        widget.debts.fold(0.0, (sum, d) => sum + d.paidAmount);
    final totalRestante =
        widget.debts.fold(0.0, (sum, d) => sum + d.remainingAmount);

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
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: AppColors.teal,
                      backgroundImage: (photoUrl != null && photoUrl.isNotEmpty)
                          ? NetworkImage(photoUrl)
                          : null,
                      onBackgroundImageError:
                          (photoUrl != null && photoUrl.isNotEmpty)
                          ? (_, _) {}
                          : null,
                      child: (photoUrl != null && photoUrl.isNotEmpty)
                          ? null
                          : Text(
                              initials,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                            '${widget.debts.length} fiado${widget.debts.length == 1 ? '' : 's'} '
                            'seleccionado${widget.debts.length == 1 ? '' : 's'}',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.inkMuted,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: (allPaid ? AppColors.success : AppColors.gold)
                            .withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        allPaid ? 'Pagado' : 'Pendiente',
                        style: TextStyle(
                          color: allPaid ? AppColors.success : AppColors.gold,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
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
                    const SizedBox(height: 16),
                    ...productsByDate.entries.map((entry) {
                      final date = entry.key;
                      final items = entry.value;
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16),
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
                            const SizedBox(height: 8),
                            ...items.map(
                              (item) => Padding(
                                padding: const EdgeInsets.only(bottom: 6),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item.productName,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                    ),
                                    Text(
                                      'S/ ${item.subtotal.toStringAsFixed(2)}',
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

              if (!allPaid) ...[
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

                if (mostrarSubtitulo)
                  const Padding(
                    padding: EdgeInsets.only(bottom: 6),
                    child: Text(
                      'Enviar recordatorio',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkMuted,
                      ),
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
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: _enviandoBienvenida
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.teal,
                                ),
                              )
                            : Text(
                                _bienvenidaEnviada
                                    ? 'Enviar recordatorio'
                                    : 'Enviar bienvenida',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(
                        Icons.help_outline_rounded,
                        color: AppColors.inkMuted,
                      ),
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