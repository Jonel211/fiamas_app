import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/tienda_provider.dart';
import '../../data/models/cliente_model.dart'; // ← aquí está nivelScore
import '../../data/models/scoring_historial_model.dart';
import '../providers/cliente_provider.dart';

class ScoringHistoryScreen extends StatefulWidget {
  final Map<String, dynamic>? customer;

  const ScoringHistoryScreen({super.key, this.customer});

  @override
  State<ScoringHistoryScreen> createState() => _ScoringHistoryScreenState();
}

class _ScoringHistoryScreenState extends State<ScoringHistoryScreen> {
  String _selectedPeriod = 'Todo';
  bool _isInit = false;

  // Filtro personalizado
  DateTime? _fechaDesde;
  DateTime? _fechaHasta;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _isInit = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _cargarHistorial();
      });
    }
  }

  void _cargarHistorial() {
    final clienteId = widget.customer?['id'] as String?;
    final tiendaId = context.read<TiendaProvider>().tiendaSeleccionadaId ??
        context.read<AuthProvider>().user?.tiendaId;

    if (clienteId != null && tiendaId != null) {
      context.read<ClienteProvider>().cargarScoringHistorial(clienteId, tiendaId);
    }
  }

  /// Normaliza el motivo que viene del backend a los textos correctos
  String _textoMotivo(ScoringHistorialModel item) {
    final motivo = (item.motivo).toLowerCase().trim();
    final cambio = item.cambioScore ?? 0;

    // Pago a tiempo
    if (motivo.contains('a tiempo') ||
        motivo.contains('pago a tiempo') ||
        motivo.contains('recuperación progresiva')) {
      return 'Pagó un fiado a tiempo';
    }

    // Pago después del vencimiento
    if (motivo.contains('después') ||
        motivo.contains('tarde') ||
        motivo.contains('vencimiento')) {
      return 'Pagó un fiado después del vencimiento';
    }

    // Mora / penalización
    if (motivo.contains('mora') ||
        motivo.contains('vencido') ||
        motivo.contains('penalización') ||
        cambio < 0) {
      return 'Fiado vencido sin pagar';
    }

    // Primer fiado o evaluación inicial
    if (motivo.contains('primer') || motivo.contains('evaluaci')) {
      return 'Primer fiado registrado';
    }

    // Fallback
    return item.motivo;
  }

  List<ScoringHistorialModel> _filtrarHistorial(List<ScoringHistorialModel> historial) {
    if (_selectedPeriod == 'Todo') return historial;

    if (_selectedPeriod == 'Personalizado') {
      if (_fechaDesde == null || _fechaHasta == null) return historial;

      final desde = DateTime(_fechaDesde!.year, _fechaDesde!.month, _fechaDesde!.day);
      final hasta = DateTime(_fechaHasta!.year, _fechaHasta!.month, _fechaHasta!.day, 23, 59, 59);

      return historial.where((item) {
        return item.fechaCalculo.isAfter(desde.subtract(const Duration(seconds: 1))) &&
            item.fechaCalculo.isBefore(hasta.add(const Duration(seconds: 1)));
      }).toList();
    }

    final now = DateTime.now();
    final limitDate = _selectedPeriod == '30 días'
        ? now.subtract(const Duration(days: 30))
        : now.subtract(const Duration(days: 365));

    return historial.where((item) => item.fechaCalculo.isAfter(limitDate)).toList();
  }

  Future<void> _seleccionarRangoPersonalizado() async {
    final DateTime? desde = await showDatePicker(
      context: context,
      initialDate: _fechaDesde ?? DateTime.now().subtract(const Duration(days: 30)),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      helpText: 'Fecha desde',
      cancelText: 'Cancelar',
      confirmText: 'Siguiente',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.teal,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (desde == null || !mounted) return;

    final DateTime? hasta = await showDatePicker(
      context: context,
      initialDate: _fechaHasta ?? DateTime.now(),
      firstDate: desde,
      lastDate: DateTime.now(),
      helpText: 'Fecha hasta',
      cancelText: 'Cancelar',
      confirmText: 'Aplicar',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.teal,
              onPrimary: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (hasta == null || !mounted) return;

    setState(() {
      _fechaDesde = desde;
      _fechaHasta = hasta;
      _selectedPeriod = 'Personalizado';
    });
  }

  String get _textoFiltroPersonalizado {
    if (_fechaDesde == null || _fechaHasta == null) return 'Personalizado';
    final formato = DateFormat('dd/MM/yy');
    return '${formato.format(_fechaDesde!)} - ${formato.format(_fechaHasta!)}';
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClienteProvider>();
    final customerName = widget.customer?['name'] as String? ?? 'Cliente';

    final currentScore = provider.scoreActual;
    final categoria = provider.categoriaActual;

    // Usa la función que ya tienes en cliente_model.dart
    final nivel = nivelScore(currentScore, categoria);

    final historialFiltrado = _filtrarHistorial(provider.scoringHistorial);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ===================== HEADER =====================
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
            decoration: const BoxDecoration(
              color: AppColors.teal,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Historial de Scoring',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  customerName,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$currentScore',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 56,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'pts',
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: nivel.color,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            nivel.etiqueta,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ===================== FILTROS =====================
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildPeriodButton('Todo'),
                  const SizedBox(width: 8),
                  _buildPeriodButton('30 días'),
                  const SizedBox(width: 8),
                  _buildPeriodButton('Año'),
                  const SizedBox(width: 8),
                  _buildPeriodButton(
                    'Personalizado',
                    isCustom: true,
                    customLabel: _selectedPeriod == 'Personalizado'
                        ? _textoFiltroPersonalizado
                        : 'Personalizado',
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // ===================== LISTA =====================
          Expanded(
            child: provider.isLoadingScoring
                ? const Center(
                    child: CircularProgressIndicator(color: AppColors.teal),
                  )
                : provider.errorScoring != null
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Text(
                            provider.errorScoring!,
                            style: const TextStyle(color: AppColors.danger),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                    : historialFiltrado.isEmpty
                        ? _buildEmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            itemCount: historialFiltrado.length,
                            itemBuilder: (context, index) {
                              return _buildHistoryCard(historialFiltrado[index]);
                            },
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(
    String period, {
    bool isCustom = false,
    String? customLabel,
  }) {
    final isSelected = _selectedPeriod == period;
    final label = customLabel ?? period;

    return GestureDetector(
      onTap: () {
        if (isCustom) {
          _seleccionarRangoPersonalizado();
        } else {
          setState(() {
            _selectedPeriod = period;
            if (period != 'Personalizado') {
              _fechaDesde = null;
              _fechaHasta = null;
            }
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.teal : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.teal : AppColors.mist,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.ink,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.history_rounded,
            size: 60,
            color: AppColors.inkMuted.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aún no hay historial de scoring\nen este período.',
            textAlign: TextAlign.center,
            style: TextStyle(color: AppColors.inkMuted, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryCard(ScoringHistorialModel item) {
    final isPositive = (item.cambioScore ?? 0) > 0;
    final isNegative = (item.cambioScore ?? 0) < 0;

    final color = isPositive
        ? AppColors.success
        : (isNegative ? AppColors.danger : AppColors.inkMuted);

    final icon = isPositive
        ? Icons.arrow_upward_rounded
        : (isNegative ? Icons.arrow_downward_rounded : Icons.remove_rounded);

    final changeText = item.cambioScore != null && item.cambioScore != 0
        ? '${isPositive ? '+' : ''}${item.cambioScore} pts'
        : 'Sin cambios';

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          )
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _textoMotivo(item),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  DateFormat('dd/MM/yyyy, hh:mm a').format(item.fechaCalculo),
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                changeText,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Total: ${item.scoreNuevo}',
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}