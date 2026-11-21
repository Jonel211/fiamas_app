import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/offline/database/database_helper.dart';
import '../../../../core/utils/whatsapp_reminder.dart';
import '../../../../core/widgets/app_header_config.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/tienda_provider.dart';
import '../../../customers/data/models/cliente_model.dart';
import '../../../customers/presentation/providers/cliente_provider.dart';
import '../../../debts/data/services/reminder_voucher_service.dart';
import '../../../debts/presentation/widgets/reminder_voucher_card.dart';

class WhatsappCollectionScreen extends StatefulWidget {
  const WhatsappCollectionScreen({super.key});

  @override
  State<WhatsappCollectionScreen> createState() =>
      _WhatsappCollectionScreenState();
}

class _WhatsappCollectionScreenState extends State<WhatsappCollectionScreen> {
  TonoRecordatorio _tono = TonoRecordatorio.respetuosa;
  final Set<String> _recordados = <String>{};
  String? _tiendaCargada;

  String? get _tiendaIdActual =>
      context.read<TiendaProvider>().tiendaSeleccionadaId ??
      context.read<AuthProvider>().user?.tiendaId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final tiendaId =
        context.watch<TiendaProvider>().tiendaSeleccionadaId ??
        context.watch<AuthProvider>().user?.tiendaId;

    if (tiendaId != null && tiendaId != _tiendaCargada) {
      _tiendaCargada = tiendaId;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _cargarClientes(tiendaId);
      });
    }
  }

  Future<void> _cargarClientes(String tiendaId) async {
    final provider = context.read<ClienteProvider>();
    if (provider.tiendaConDeudaId == tiendaId) return;
    await provider.cargarClientesConDeuda(tiendaId);
  }

  Future<void> _onRefresh() async {
    final tiendaId = _tiendaIdActual;
    if (tiendaId == null) return;
    await context.read<ClienteProvider>().cargarClientesConDeuda(tiendaId);
  }

  Future<void> _recordar(ClienteModel cliente, String nombreTienda) async {
    void aviso(String texto, {bool error = false}) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            texto,
            style: TextStyle(color: error ? AppColors.danger : AppColors.onBrand),
          ),
          backgroundColor: error ? AppColors.dangerSoft : AppColors.success,
        ),
      );
    }

    if (normalizarTelefonoWhatsapp(cliente.telefono).isEmpty) {
      aviso('Este cliente no tiene un teléfono registrado', error: true);
      return;
    }

    final tiendaId = _tiendaIdActual;
    if (tiendaId == null) {
      aviso('No se pudo identificar la tienda', error: true);
      return;
    }

    final provider = context.read<ClienteProvider>();
    final tienda = context.read<TiendaProvider>().tiendaSeleccionada;
    aviso('Preparando recordatorio para ${cliente.nombreCompleto}…');

    try {
      final deudas = await provider.obtenerFiadosPendientes(
        cliente.id,
        tiendaId,
        nombre: cliente.nombreCompleto,
        telefono: cliente.telefono,
      );
      if (!mounted) return;

      var lineas = VoucherLinea.desdeDeudas(deudas);
      var total = lineas.fold<double>(0, (s, l) => s + l.monto);

      if (lineas.isEmpty) {
        total = cliente.vinculacion.saldoActual;
        lineas = [
          VoucherLinea(
            fecha: '-',
            detalle: 'Saldo pendiente',
            monto: total,
          ),
        ];
      }

      final resultado = await ReminderVoucherService.enviarRecordatorio(
        context,
        tienda: tienda,
        nombreCliente: cliente.nombreCompleto,
        telefono: cliente.telefono,
        lineas: lineas,
        total: total,
        tono: _tono,
      );
      if (!mounted) return;

      if (resultado == ResultadoEnvio.error) {
        aviso('No se pudo generar la imagen', error: true);
        return;
      }

      setState(() => _recordados.add(cliente.id));
      aviso(
        resultado == ResultadoEnvio.directo
            ? 'Revisa la imagen en el chat de ${cliente.nombreCompleto} y pulsa enviar'
            : 'Elige el chat de ${cliente.nombreCompleto} en WhatsApp para enviarla',
      );
    } catch (e) {
      debugPrint('ERROR RECORDATORIO: $e');
      aviso('No se pudo preparar el recordatorio', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tienda = context.watch<TiendaProvider>().tiendaSeleccionada;
    final nombreTienda = (tienda?.nombre.isNotEmpty ?? false)
        ? tienda!.nombre
        : 'Mi tienda';
    final provider = context.watch<ClienteProvider>();
    final tiendaId = _tiendaIdActual;
    final esperandoCarga =
        tiendaId != null &&
        provider.tiendaConDeudaId != tiendaId &&
        provider.errorConDeuda == null;

    final deudores =
        provider.clientesConDeuda
            .where((cliente) => cliente.vinculacion.saldoActual > 0)
            .toList()
          ..sort(
            (a, b) =>
                b.vinculacion.saldoActual.compareTo(a.vinculacion.saldoActual),
          );

    return AppHeaderConfig(
      title: 'Cobros',
      showBack: true,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: RefreshIndicator(
          onRefresh: _onRefresh,
          color: AppColors.teal,
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Cobranza WhatsApp',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                    _TonoChip(
                      tono: _tono,
                      onSelected: (tono) => setState(() => _tono = tono),
                    ),
                  ],
                ),
              ),
              if (provider.errorConDeuda != null)
                _ErrorState(
                  message: provider.errorConDeuda!,
                  onRetry: _onRefresh,
                )
              else if ((provider.isLoadingConDeuda || esperandoCarga) &&
                  provider.clientesConDeuda.isEmpty)
                const _LoadingState()
              else if (deudores.isEmpty)
                const _EmptyState()
              else
                for (final cliente in deudores)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _DeudorCard(
                      key: ValueKey('${cliente.id}_${tiendaId ?? ''}'),
                      cliente: cliente,
                      tiendaId: tiendaId ?? '',
                      nombreTienda: nombreTienda,
                      recordadoHoy: _recordados.contains(cliente.id),
                      onRecordar: () => _recordar(cliente, nombreTienda),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TonoChip extends StatelessWidget {
  const _TonoChip({required this.tono, required this.onSelected});

  final TonoRecordatorio tono;
  final ValueChanged<TonoRecordatorio> onSelected;

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<TonoRecordatorio>(
      onSelected: onSelected,
      position: PopupMenuPosition.under,
      color: AppColors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      itemBuilder: (context) {
        return TonoRecordatorio.values.map((opcion) {
          final seleccionado = opcion == tono;
          return PopupMenuItem<TonoRecordatorio>(
            value: opcion,
            child: Row(
              children: [
                Icon(
                  seleccionado
                      ? Icons.radio_button_checked_rounded
                      : Icons.radio_button_off_rounded,
                  color: seleccionado ? AppColors.teal : AppColors.inkMuted,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Text(
                  opcion.label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: seleccionado
                        ? FontWeight.w700
                        : FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          );
        }).toList();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: AppColors.tealSoft,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              tono.label,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.teal,
              ),
            ),
            const SizedBox(width: 4),
            const Icon(
              Icons.expand_more_rounded,
              color: AppColors.teal,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

class _DeudorCard extends StatefulWidget {
  const _DeudorCard({
    super.key,
    required this.cliente,
    required this.tiendaId,
    required this.nombreTienda,
    required this.recordadoHoy,
    required this.onRecordar,
  });

  final ClienteModel cliente;
  final String tiendaId;
  final String nombreTienda;
  final bool recordadoHoy;
  final VoidCallback onRecordar;

  @override
  State<_DeudorCard> createState() => _DeudorCardState();
}

class _DeudorCardState extends State<_DeudorCard> {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  bool _bienvenidaEnviada = true;
  bool _cargando = true;
  bool _enviando = false;

  @override
  void initState() {
    super.initState();
    _cargarFlag();
  }

  Future<void> _cargarFlag() async {
    final enviada = await _dbHelper.getWhatsappBienvenida(
      widget.cliente.telefono,
      widget.tiendaId,
    );
    if (!mounted) return;
    setState(() {
      _bienvenidaEnviada = enviada;
      _cargando = false;
    });
  }

  Future<void> _onPressed() async {
    if (_enviando || _cargando) return;

    if (_bienvenidaEnviada) {
      widget.onRecordar();
      return;
    }

    if (normalizarTelefonoWhatsapp(widget.cliente.telefono).isEmpty) {
      _snack('Este cliente no tiene un teléfono registrado', error: true);
      return;
    }

    setState(() => _enviando = true);

    try {
      final mensaje = construirMensajeBienvenida(
        nombreCliente: widget.cliente.nombreCompleto,
        nombreTienda: widget.nombreTienda,
      );

      final ok = await abrirWhatsapp(
        telefono: widget.cliente.telefono,
        mensaje: mensaje,
      );

      if (!ok) {
        if (mounted) {
          setState(() => _enviando = false);
          _snack('No se pudo abrir WhatsApp', error: true);
        }
        return;
      }

      await _dbHelper.setWhatsappBienvenida(
        widget.cliente.telefono,
        widget.tiendaId,
        enviada: true,
      );

      if (!mounted) return;
      setState(() {
        _bienvenidaEnviada = true;
        _enviando = false;
      });

      _snack(
        'Toca "Enviar" en WhatsApp. Después podrás enviar recordatorios con imagen.',
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _enviando = false);
      _snack('Error al abrir WhatsApp', error: true);
    }
  }

  void _snack(String texto, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          texto,
          style: TextStyle(color: error ? AppColors.danger : AppColors.onBrand),
        ),
        backgroundColor: error ? AppColors.dangerSoft : AppColors.success,
        duration: const Duration(seconds: 5),
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

  @override
  Widget build(BuildContext context) {
    final mostrarSubtitulo = !_cargando && !_bienvenidaEnviada;

    return Container(
      // Redujimos el padding derecho de 20 a 8 para que el (?) respire mejor
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.ink.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.cliente.nombreCompleto,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Deuda actual: S/ ${widget.cliente.vinculacion.saldoActual.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.teal,
                  ),
                ),
                if (widget.recordadoHoy) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.success.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle_rounded,
                          size: 14,
                          color: AppColors.success,
                        ),
                        SizedBox(width: 4),
                        Text(
                          'Recordado hoy',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 4), // Reducido de 8 a 4 para dar más espacio
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (mostrarSubtitulo)
                const Padding(
                  padding: EdgeInsets.only(bottom: 4, right: 18), // Alineado ópticamente sobre el botón
                  child: Text(
                    'Enviar recordatorio',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Material(
                    color: AppColors.teal,
                    borderRadius: BorderRadius.circular(10),
                    child: InkWell(
                      onTap: _onPressed,
                      borderRadius: BorderRadius.circular(10),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12, // Reducido de 14 a 12 para compactar el botón
                          vertical: 10,
                        ),
                        child: _enviando
                            ? const SizedBox(
                                width: 14,
                                height: 14,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.onBrand,
                                ),
                              )
                            : Text(
                                _bienvenidaEnviada
                                    ? 'Enviar recordatorio'
                                    : 'Enviar bienvenida',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.onBrand,
                                ),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 2), // Pequeño espacio entre botón y (?)
                  IconButton(
                    padding: EdgeInsets.zero, // Elimina el padding interno por defecto
                    constraints: const BoxConstraints(), // Elimina el tamaño mínimo de 48x48
                    icon: const Icon(
                      Icons.help_outline_rounded,
                      size: 18,
                      color: AppColors.inkMuted,
                    ),
                    tooltip: '¿Cómo funciona?',
                    onPressed: _mostrarAyuda,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LoadingState extends StatelessWidget {
  const _LoadingState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 80),
      child: Center(child: CircularProgressIndicator(color: AppColors.teal)),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 20),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.tealSoft,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.task_alt_rounded,
              color: AppColors.teal,
              size: 30,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No hay clientes con deuda pendiente',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: AppColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.mist),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.error_outline_rounded,
            color: AppColors.danger,
            size: 32,
          ),
          const SizedBox(height: 10),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13, color: AppColors.inkMuted),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}