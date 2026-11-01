import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header_config.dart';
import '../../../../main.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/tienda_provider.dart';
import '../../../customers/data/models/cliente_model.dart';
import '../../../customers/presentation/providers/cliente_provider.dart';
import '../../domain/debt.dart';
import 'debt_detail_multiple_screen.dart';
import 'select_debts_screen.dart';

class DebtHistoryScreen extends StatefulWidget {
  final Map<String, dynamic> customer;

  const DebtHistoryScreen({super.key, required this.customer});

  @override
  State<DebtHistoryScreen> createState() => _DebtHistoryScreenState();
}

class _DebtHistoryScreenState extends State<DebtHistoryScreen> {
  String _selectedFilter = 'Todos';
  bool _isInit = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInit) {
      _isInit = true;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _cargarFiados();
      });
    }
  }

  void _cargarFiados() {
    final tiendaId = context.read<TiendaProvider>().tiendaSeleccionadaId ??
        context.read<AuthProvider>().user?.tiendaId;
    final clienteId = widget.customer['id'];
    if (tiendaId != null && clienteId != null) {
      context.read<ClienteProvider>().cargarFiadosCliente(
            clienteId,
            tiendaId,
            nombre: widget.customer['name']?.toString(),
            telefono: widget.customer['phone']?.toString(),
          );
    }
  }

  String _getBadgeText(int score, String categoria) {
    if (categoria.toLowerCase() == 'nuevo') return 'Nuevo';
    if (score >= 80) return 'Bueno';
    if (score >= 50) return 'Regular';
    return 'Malo';
  }

  Color _getBadgeColor(int score, String categoria) {
    if (categoria.toLowerCase() == 'nuevo') return AppColors.skyBlue;
    if (score >= 80) return AppColors.teal;
    if (score >= 50) return AppColors.gold;
    return AppColors.danger;
  }

  bool _esVigente(Debt d) => d.status != DebtStatus.pagado;

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClienteProvider>();
    final clienteId = widget.customer['id'] as String;

    // Busca el cliente sin romper si la lista aún no cargó
    ClienteModel? clienteCompleto;
    for (final c in provider.clientes) {
      if (c.id == clienteId) {
        clienteCompleto = c;
        break;
      }
    }

    final name = clienteCompleto?.nombreCompleto ??
        (widget.customer['name']?.toString() ?? 'Cliente');
    final phone = clienteCompleto?.telefono ??
        (widget.customer['phone']?.toString() ?? '');
    final debtAmount = clienteCompleto?.vinculacion.saldoActual ??
        ((widget.customer['debt'] as num?)?.toDouble() ?? 0.0);
    final score = clienteCompleto?.vinculacion.scorePagador ?? 100;
    final categoria = clienteCompleto?.vinculacion.categoriaPagador ?? 'nuevo';

    final initial =
        name.trim().isNotEmpty ? name.trim().split(' ').last[0].toUpperCase() : 'C';
    final badgeText = _getBadgeText(score, categoria);
    final badgeColor = _getBadgeColor(score, categoria);
    final photoUrl = clienteCompleto?.fotoPerfilUrl ?? (widget.customer['imageUrl'] as String?);
    final hasPhoto = photoUrl != null && photoUrl.isNotEmpty;

    final fiados = provider.fiadosCliente;

    final fiadosFiltrados = fiados.where((d) {
      if (_selectedFilter == 'Todos') return true;
      if (_selectedFilter == 'Vigentes') return _esVigente(d);
      if (_selectedFilter == 'Pagados') return d.status == DebtStatus.pagado;
      if (_selectedFilter == 'Vencidos') {
        return _esVigente(d) && d.dateLabel.contains('Vencido');
      }
      return true;
    }).toList();

    final totalFiado = fiados.fold(0.0, (sum, item) => sum + item.amount);
    // Incluye abonos parciales, no solo fiados pagados al 100%
    final totalPagado = fiados.fold(0.0, (sum, item) => sum + item.paidAmount);

    final tieneDeudasPendientes = fiados.any(_esVigente);

    return AppHeaderConfig(
      title: 'Historial de Cliente',
      showBack: true,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            GestureDetector(
              onTap: () {
                if (clienteCompleto != null) {
                  Navigator.pushNamed(context, AppRoutes.customerProfile,
                      arguments: clienteCompleto);
                }
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2))
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.teal,
                      backgroundImage: hasPhoto ? NetworkImage(photoUrl) : null,
                      onBackgroundImageError: hasPhoto ? (_, __) {} : null,
                      child: hasPhoto
                          ? null
                          : Text(initial, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name,
                              style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.ink)),
                          const SizedBox(height: 4),
                          Text(phone,
                              style: TextStyle(
                                  fontSize: 13, color: AppColors.inkMuted)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                              color: AppColors.gold.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(12)),
                          child: Text('Score $score',
                              style: const TextStyle(
                                  color: AppColors.gold,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                              color: badgeColor,
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(badgeText,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                  color: AppColors.teal, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SALDO ACTUAL PENDIENTE',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Text('S/ ${debtAmount.toStringAsFixed(2)}',
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total fiado',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('S/ ${totalFiado.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total pagado',
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('S/ ${totalPagado.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildFilterChip('Todos', fiados.length,
                      _selectedFilter == 'Todos'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Vigentes', fiados.where(_esVigente).length,
                      _selectedFilter == 'Vigentes'),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                      'Pagados',
                      fiados.where((d) => d.status == DebtStatus.pagado).length,
                      _selectedFilter == 'Pagados'),
                  const SizedBox(width: 8),
                  _buildFilterChip(
                      'Vencidos',
                      fiados
                          .where((d) =>
                              _esVigente(d) && d.dateLabel.contains('Vencido'))
                          .length,
                      _selectedFilter == 'Vencidos'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: provider.isLoadingFiados
                  ? const Center(child: CircularProgressIndicator())
                  : provider.errorFiados != null
                      ? Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              provider.errorFiados!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.red),
                            ),
                          ),
                        )
                      : fiadosFiltrados.isEmpty
                          ? const Center(
                              child: Text(
                                'Este cliente no tiene fiados registrados.',
                                style: TextStyle(
                                    color: AppColors.inkMuted, fontSize: 15),
                              ),
                            )
                          : ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              itemCount: fiadosFiltrados.length,
                              itemBuilder: (context, index) =>
                                  _buildDebtCard(fiadosFiltrados[index]),
                            ),
            ),
          ],
        ),
        floatingActionButton: tieneDeudasPendientes
            ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) =>
                            SelectDebtsScreen(customer: widget.customer)),
                  );
                },
                backgroundColor: AppColors.teal,
                icon: const Icon(Icons.checklist, color: Colors.white),
                label: const Text('Seleccionar fiados',
                    style: TextStyle(
                        color: Colors.white, fontWeight: FontWeight.w600)),
              )
            : null,
      ),
    );
  }

  Widget _buildFilterChip(String label, int count, bool isActive) {
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isActive ? AppColors.teal : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: isActive ? AppColors.teal : AppColors.mist),
        ),
        child: Text(
          '$label ($count)',
          style: TextStyle(
              color: isActive ? Colors.white : AppColors.ink,
              fontSize: 13,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildDebtCard(Debt debt) {
    final pagado = debt.status == DebtStatus.pagado;
    final parcial = debt.status == DebtStatus.parcial;

    final etiqueta = pagado ? 'PAGADO' : (parcial ? 'PARCIAL' : 'PENDIENTE');
    final color = pagado
        ? AppColors.success
        : (parcial ? AppColors.skyBlue : AppColors.gold);

    return GestureDetector(
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DebtDetailMultipleScreen(
              customer: {
                'id': widget.customer['id'],
                'name': debt.customerName,
                'phone': debt.phone,
              },
              debts: [debt],
            ),
          ),
        );
        // Al volver (por ejemplo tras cobrar) se refresca la lista
        if (!mounted) return;
        _cargarFiados();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('S/ ${debt.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.ink)),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    etiqueta,
                    style: TextStyle(
                        color: color,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              debt.items.map((item) => item.productName).join(', '),
              style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(debt.dateLabel,
                    style: TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                Text(
                  pagado
                      ? 'Cancelado'
                      : 'Resta S/ ${debt.remainingAmount.toStringAsFixed(2)}',
                  style: TextStyle(
                      fontSize: 12,
                      color: pagado ? AppColors.success : AppColors.gold,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}