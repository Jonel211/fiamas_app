import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header_config.dart';
import '../../../../main.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/tienda_provider.dart';
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
      context.read<ClienteProvider>().cargarFiadosCliente(clienteId, tiendaId);
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

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClienteProvider>();
    
    final clienteId = widget.customer['id'] as String;
    final clienteCompleto = provider.clientes.firstWhere(
      (c) => c.id == clienteId, 
      orElse: () => provider.clientes.first,
    );

    final name = clienteCompleto.nombreCompleto;
    final phone = clienteCompleto.telefono;
    final debtAmount = clienteCompleto.vinculacion.saldoActual;
    final score = clienteCompleto.vinculacion.scorePagador;
    final categoria = clienteCompleto.vinculacion.categoriaPagador;
    
    final initial = name.isNotEmpty ? name.split(' ').last[0].toUpperCase() : 'C';
    final badgeText = _getBadgeText(score, categoria);
    final badgeColor = _getBadgeColor(score, categoria);
    final photoUrl = clienteCompleto.fotoPerfilUrl ?? (widget.customer['imageUrl'] as String?);

    final fiadosFiltrados = provider.fiadosCliente.where((d) {
      if (_selectedFilter == 'Todos') return true;
      if (_selectedFilter == 'Vigentes') return d.status == DebtStatus.pendiente;
      if (_selectedFilter == 'Pagados') return d.status == DebtStatus.pagado;
      if (_selectedFilter == 'Vencidos') return d.status == DebtStatus.pendiente && d.dateLabel.contains('Vencido');
      return true;
    }).toList();

    final totalFiado = provider.fiadosCliente.fold(0.0, (sum, item) => sum + item.amount);
    final totalPagado = provider.fiadosCliente
        .where((d) => d.status == DebtStatus.pagado)
        .fold(0.0, (sum, item) => sum + item.amount);

    final tieneDeudasPendientes = provider.fiadosCliente.any((d) => d.status == DebtStatus.pendiente);

    return AppHeaderConfig(
      title: 'Historial de Cliente',
      showBack: true,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.customerProfile, arguments: clienteCompleto);
              },
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.teal,
                      backgroundImage: (photoUrl != null && photoUrl.isNotEmpty) ? NetworkImage(photoUrl) : null,
                      onBackgroundImageError: (photoUrl != null && photoUrl.isNotEmpty) ? (_, __) {} : null,
                      child: (photoUrl != null && photoUrl.isNotEmpty)
                          ? null
                          : Text(initial, style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.ink)),
                          const SizedBox(height: 4),
                          Text(phone, style: TextStyle(fontSize: 13, color: AppColors.inkMuted)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                          child: Text('Score $score', style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w600)),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(color: badgeColor, borderRadius: BorderRadius.circular(8)),
                          child: Text(badgeText, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w600)),
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
              decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('SALDO ACTUAL PENDIENTE', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 1)),
                  const SizedBox(height: 8),
                  Text('S/ ${debtAmount.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  const Divider(color: Colors.white24, height: 1),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total fiado', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('S/ ${totalFiado.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Total pagado', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            const SizedBox(height: 4),
                            Text('S/ ${totalPagado.toStringAsFixed(2)}', style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
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
                  _buildFilterChip('Todos', provider.fiadosCliente.length, _selectedFilter == 'Todos'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Vigentes', provider.fiadosCliente.where((d) => d.status == DebtStatus.pendiente).length, _selectedFilter == 'Vigentes'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pagados', provider.fiadosCliente.where((d) => d.status == DebtStatus.pagado).length, _selectedFilter == 'Pagados'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Vencidos', provider.fiadosCliente.where((d) => d.status == DebtStatus.pendiente && d.dateLabel.contains('Vencido')).length, _selectedFilter == 'Vencidos'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: provider.isLoadingFiados
                  ? const Center(child: CircularProgressIndicator())
                  : fiadosFiltrados.isEmpty
                      ? const Center(
                          child: Text(
                            'Este cliente no tiene fiados registrados.',
                            style: TextStyle(color: AppColors.inkMuted, fontSize: 15),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          itemCount: fiadosFiltrados.length,
                          itemBuilder: (context, index) => _buildDebtCard(fiadosFiltrados[index]),
                        ),
            ),
          ],
        ),
        floatingActionButton: tieneDeudasPendientes
            ? FloatingActionButton.extended(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => SelectDebtsScreen(customer: widget.customer)),
                  );
                },
                backgroundColor: AppColors.teal,
                icon: const Icon(Icons.checklist, color: Colors.white),
                label: const Text('Seleccionar fiados', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
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
          style: TextStyle(color: isActive ? Colors.white : AppColors.ink, fontSize: 13, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildDebtCard(Debt debt) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DebtDetailMultipleScreen(
              customer: {'name': debt.customerName, 'phone': debt.phone},
              debts: [debt],
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('S/ ${debt.amount.toStringAsFixed(2)}', style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.ink)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: debt.status == DebtStatus.pagado ? AppColors.success.withOpacity(0.15) : AppColors.gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    debt.status == DebtStatus.pagado ? 'PAGADO' : 'PENDIENTE',
                    style: TextStyle(
                      color: debt.status == DebtStatus.pagado ? AppColors.success : AppColors.gold,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
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
                Text(debt.dateLabel, style: TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                Text(
                  debt.status == DebtStatus.pagado ? 'Cancelado' : 'Pendiente',
                  style: TextStyle(
                    fontSize: 12,
                    color: debt.status == DebtStatus.pagado ? AppColors.success : AppColors.gold,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}