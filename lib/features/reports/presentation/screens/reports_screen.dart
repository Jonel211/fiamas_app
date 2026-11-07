import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header_config.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/tienda_provider.dart';
import '../../../customers/presentation/providers/cliente_provider.dart';
import '../../data/models/reporte_resumen_model.dart';
import '../../data/services/reporte_service.dart';
import '../../data/services/pdf_service.dart';
import '../widgets/reports_filters.dart';
import '../widgets/reports_summary.dart';
import '../widgets/reports_chart.dart';
import '../widgets/report_item_tile.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  final _service = ReporteService();
  ReporteResumenModel? _resumen;
  bool _isLoading = true;
  String _currentPeriodo = 'semana';
  int _reqId = 0; // evita que una respuesta lenta pise a una más nueva

  String _selectedClienteId = 'all';
  String? _selectedClienteName;

  String? _tiendaActual() {
    return context.read<TiendaProvider>().tiendaSeleccionadaId ??
        context.read<AuthProvider>().user?.tiendaId;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final tiendaId = _tiendaActual();
      if (tiendaId != null) {
        context.read<ClienteProvider>().cargarClientes(tiendaId);
        _cargarDatos();
      } else {
        setState(() => _isLoading = false);
      }
    });
  }

  Future<void> _cargarDatos() async {
    final miReq = ++_reqId;
    setState(() => _isLoading = true);

    final tiendaId = _tiendaActual();
    if (tiendaId == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    try {
      final data = await _service.getResumenReportes(
        tiendaId,
        _currentPeriodo,
        clienteId: _selectedClienteId == 'all' ? null : _selectedClienteId,
      );

      if (!mounted || miReq != _reqId) return;
      setState(() {
        _resumen = ReporteResumenModel.fromJson(data);
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted || miReq != _reqId) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _onFilterChanged(String newPeriodo) {
    if (_currentPeriodo == newPeriodo) return;
    setState(() => _currentPeriodo = newPeriodo);
    _cargarDatos();
  }

  Future<void> _exportarPdf(TipoReporte tipo) async {
    if (_resumen == null) return;

    final tiendaNombre =
        context.read<TiendaProvider>().tiendaSeleccionada?.nombre ?? 'Mi Tienda';

    try {
      await PdfService.generarReporte(
        resumen: _resumen!,
        nombreTienda: tiendaNombre,
        periodo: _currentPeriodo,
        tipo: tipo,
        clienteNombre: _selectedClienteName,
      );
    } catch (e) {
      debugPrint('ERROR PDF: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al generar el PDF: $e')),
        );
      }
    }
  }

  String _unidadesTop() {
    final top = _resumen?.topProductos ?? [];
    final num unidades =
        top.fold<num>(0, (s, i) => s + ((i['cantidad'] as num?) ?? 0));
    final txt = unidades % 1 == 0
        ? unidades.toInt().toString()
        : unidades.toStringAsFixed(2);
    return 'Top ${top.length} • $txt unidades';
  }

  String _etiquetaPeriodo() {
    switch (_currentPeriodo) {
      case 'hoy':
        return 'Hoy';
      case 'semana':
        return 'Esta semana';
      case 'mes':
        return 'Este mes';
      default:
        return 'Histórico';
    }
  }

  @override
  Widget build(BuildContext context) {
    final clientes = context.watch<ClienteProvider>().clientes;
    final valorDropdown =
        (_selectedClienteId == 'all' || clientes.any((c) => c.id == _selectedClienteId))
            ? _selectedClienteId
            : 'all';

    final servidorViejo = _resumen != null && _resumen!.version == null;

    return AppHeaderConfig(
      title: 'Reportes',
      showBack: true,
      child: Scaffold(
        backgroundColor: AppColors.ivory,
        body: SafeArea(
          top: false,
          child: Column(
            children: [
              ReportsFilters(
                selectedFilter: _currentPeriodo,
                onFilterSelected: _onFilterChanged,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.mist),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: valorDropdown,
                      items: [
                        const DropdownMenuItem<String>(
                          value: 'all',
                          child: Text('Todos los clientes',
                              style: TextStyle(fontSize: 13)),
                        ),
                        ...clientes.map((c) {
                          return DropdownMenuItem<String>(
                            value: c.id,
                            child: Text(c.nombreCompleto,
                                style: const TextStyle(fontSize: 13),
                                overflow: TextOverflow.ellipsis),
                          );
                        }),
                      ],
                      onChanged: (val) {
                        if (val == null) return;
                        setState(() {
                          _selectedClienteId = val;
                          _selectedClienteName = val == 'all'
                              ? null
                              : clientes.firstWhere((c) => c.id == val).nombreCompleto;
                        });
                        _cargarDatos();
                      },
                    ),
                  ),
                ),
              ),
              if (servidorViejo)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.orange.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'El servidor tiene una versión vieja de reportes: el filtro por cliente y los PDF no funcionarán hasta que se despliegue el backend actualizado.',
                    style: TextStyle(fontSize: 11, color: Colors.deepOrange),
                  ),
                ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 32),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            ReportsSummary(resumen: _resumen),
                            const SizedBox(height: 24),
                            ReportsChart(chartData: _resumen?.chartData ?? []),
                            const SizedBox(height: 24),
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 16),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Reportes detallados',
                                          style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w700,
                                              color: AppColors.ink)),
                                      Text('Descarga cada categoría por separado',
                                          style: TextStyle(
                                              fontSize: 11,
                                              color: AppColors.inkMuted)),
                                    ],
                                  ),
                                  Text('4 reportes',
                                      style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.teal)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 12),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ReportItemTile(
                                    title: 'Fiados',
                                    subtitle:
                                        '${_resumen?.totalFiados ?? 0} operaciones • S/ ${(_resumen?.montoTotalFiado ?? 0).toStringAsFixed(2)}',
                                    status: _etiquetaPeriodo(),
                                    amount: '',
                                    icon: Icons.shopping_cart_outlined,
                                    iconColor: AppColors.teal,
                                    iconBg: AppColors.teal.withValues(alpha: 0.1),
                                    statusColor: Colors.green,
                                    onExportPdf: () => _exportarPdf(TipoReporte.fiados),
                                  ),
                                  ReportItemTile(
                                    title: 'Fiados por cobrar',
                                    subtitle:
                                        '${_resumen?.clientesPendientes ?? 0} clientes • S/ ${(_resumen?.porCobrar ?? 0).toStringAsFixed(2)}',
                                    status: 'Saldo actual pendiente',
                                    amount: '',
                                    icon: Icons.pan_tool_outlined,
                                    iconColor: Colors.orange,
                                    iconBg: Colors.orange.withValues(alpha: 0.1),
                                    statusColor: Colors.orange,
                                    onExportPdf: () =>
                                        _exportarPdf(TipoReporte.fiadosPorCobrar),
                                  ),
                                  ReportItemTile(
                                    title: 'Cobros',
                                    subtitle:
                                        '${_resumen?.totalCobros ?? 0} cobros • S/ ${(_resumen?.montoTotalCobrado ?? 0).toStringAsFixed(2)}',
                                    status: _etiquetaPeriodo(),
                                    amount: '',
                                    icon: Icons.mark_email_read_outlined,
                                    iconColor: Colors.green,
                                    iconBg: Colors.green.withValues(alpha: 0.1),
                                    statusColor: Colors.green,
                                    onExportPdf: () => _exportarPdf(TipoReporte.cobros),
                                  ),
                                  ReportItemTile(
                                    title: 'Productos más vendidos',
                                    subtitle: _unidadesTop(),
                                    status: 'Solo filtra por fecha',
                                    amount: '',
                                    icon: Icons.inventory_2_outlined,
                                    iconColor: Colors.indigo,
                                    iconBg: Colors.indigo.withValues(alpha: 0.1),
                                    statusColor: Colors.indigo,
                                    onExportPdf: () =>
                                        _exportarPdf(TipoReporte.productos),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}