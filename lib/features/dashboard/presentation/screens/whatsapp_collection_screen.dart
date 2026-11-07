import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/whatsapp_reminder.dart';
import '../../../../core/widgets/app_header_config.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/tienda_provider.dart';
import '../../../customers/data/models/cliente_model.dart';
import '../../../customers/presentation/providers/cliente_provider.dart';

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
    final telefono = normalizarTelefonoWhatsapp(cliente.telefono);
    if (telefono.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Este cliente no tiene un teléfono registrado',
            style: TextStyle(color: AppColors.danger),
          ),
          backgroundColor: AppColors.dangerSoft,
        ),
      );
      return;
    }

    final deudaActual = cliente.vinculacion.saldoActual.toStringAsFixed(2);
    final mensaje = _tono.mensaje(
      nombreCliente: cliente.nombreCompleto,
      deuda: deudaActual,
      nombreTienda: nombreTienda,
    );
    final abierto = await abrirWhatsapp(
      telefono: cliente.telefono,
      mensaje: mensaje,
    );

    if (!mounted) return;

    if (!abierto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se pudo abrir WhatsApp',
            style: TextStyle(color: AppColors.danger),
          ),
          backgroundColor: AppColors.dangerSoft,
        ),
      );
      return;
    }

    setState(() => _recordados.add(cliente.id));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Recordatorio preparado para ${cliente.nombreCompleto}',
          style: const TextStyle(color: AppColors.onBrand),
        ),
        backgroundColor: AppColors.success,
      ),
    );
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
      title: nombreTienda,
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
                      cliente: cliente,
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

class _DeudorCard extends StatelessWidget {
  const _DeudorCard({
    required this.cliente,
    required this.recordadoHoy,
    required this.onRecordar,
  });

  final ClienteModel cliente;
  final bool recordadoHoy;
  final VoidCallback onRecordar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
                  cliente.nombreCompleto,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Deuda actual: S/ ${cliente.vinculacion.saldoActual.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.teal,
                  ),
                ),
                if (recordadoHoy) ...[
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
          const SizedBox(width: 12),
          Material(
            color: AppColors.teal,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: onRecordar,
              borderRadius: BorderRadius.circular(10),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Text(
                  'Recordar',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.onBrand,
                  ),
                ),
              ),
            ),
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
