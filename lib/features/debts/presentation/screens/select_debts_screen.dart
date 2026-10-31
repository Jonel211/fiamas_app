import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fiamas_app/core/constants/app_colors.dart';
import 'package:fiamas_app/core/widgets/app_header_config.dart';
import '../../../customers/presentation/providers/cliente_provider.dart';
import '../../domain/debt.dart';
import 'debt_detail_multiple_screen.dart';

class SelectDebtsScreen extends StatefulWidget {
  final Map<String, dynamic> customer;

  const SelectDebtsScreen({super.key, required this.customer});

  @override
  State<SelectDebtsScreen> createState() => _SelectDebtsScreenState();
}

class _SelectDebtsScreenState extends State<SelectDebtsScreen> {
  String _selectedFilter = 'Todos';
  final Set<String> _selectedDebtIds = {};

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<ClienteProvider>();
    
    // Obtenemos las deudas reales del cliente
    final todasLasDeudas = provider.fiadosCliente;

    // Filtramos según el chip seleccionado
    final deudasFiltradas = todasLasDeudas.where((d) {
      if (_selectedFilter == 'Todos') return true;
      if (_selectedFilter == 'Vigentes') return d.status == DebtStatus.pendiente;
      if (_selectedFilter == 'Pagados') return d.status == DebtStatus.pagado;
      if (_selectedFilter == 'Vencidos') return d.status == DebtStatus.pendiente && d.dateLabel.contains('Vencido');
      return true;
    }).toList();

    // Calculamos el total seleccionado
    final selectedTotal = todasLasDeudas
        .where((d) => _selectedDebtIds.contains(d.id))
        .fold(0.0, (sum, debt) => sum + debt.amount);

    // Datos del cliente (desde el Map o el Provider)
    final clienteCompleto = provider.clientes.firstWhere(
      (c) => c.id == widget.customer['id'], 
      orElse: () => provider.clientes.first,
    );
    final name = clienteCompleto.nombreCompleto;
    final phone = clienteCompleto.telefono;
    final debtAmount = clienteCompleto.vinculacion.saldoActual;
    final score = clienteCompleto.vinculacion.scorePagador;
    
    // Totales reales
    final totalFiado = todasLasDeudas.fold(0.0, (sum, item) => sum + item.amount);
    final totalPagado = todasLasDeudas
        .where((d) => d.status == DebtStatus.pagado)
        .fold(0.0, (sum, item) => sum + item.amount);
        
    final initial = name.isNotEmpty ? name.split(' ').last[0].toUpperCase() : 'C';
    final photoUrl = clienteCompleto.fotoPerfilUrl ?? (widget.customer['imageUrl'] as String?);

    return AppHeaderConfig(
      title: '${_selectedDebtIds.length} seleccionados',
      centerTitle: true,
      leading: TextButton(
        onPressed: () => Navigator.pop(context),
        style: TextButton.styleFrom(padding: EdgeInsets.zero),
        child: const Text(
          'Cancelar',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.check_circle,
            color: _selectedDebtIds.isNotEmpty ? Colors.white : Colors.white54,
          ),
          onPressed: _selectedDebtIds.isNotEmpty ? () => _goToDetail(todasLasDeudas) : null,
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: Column(
          children: [
            // HEADER DEL CLIENTE
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
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
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(12)),
                    child: Text('Score $score', style: const TextStyle(color: AppColors.gold, fontSize: 11, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
            ),
            // SALDO ACTUAL PENDIENTE
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
            // FILTROS
            SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                children: [
                  _buildFilterChip('Todos', todasLasDeudas.length, _selectedFilter == 'Todos'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Vigentes', todasLasDeudas.where((d) => d.status == DebtStatus.pendiente).length, _selectedFilter == 'Vigentes'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Pagados', todasLasDeudas.where((d) => d.status == DebtStatus.pagado).length, _selectedFilter == 'Pagados'),
                  const SizedBox(width: 8),
                  _buildFilterChip('Vencidos', todasLasDeudas.where((d) => d.status == DebtStatus.pendiente && d.dateLabel.contains('Vencido')).length, _selectedFilter == 'Vencidos'),
                ],
              ),
            ),
            const SizedBox(height: 16),
            // LISTA CON CHECKBOXES
            Expanded(
              child: deudasFiltradas.isEmpty
                  ? const Center(
                      child: Text('No hay fiados en esta categoría.', style: TextStyle(color: AppColors.inkMuted)),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: deudasFiltradas.length,
                      itemBuilder: (context, index) {
                        final debt = deudasFiltradas[index];
                        final isSelected = _selectedDebtIds.contains(debt.id);
                        return _buildDebtCard(debt, isSelected);
                      },
                    ),
            ),
            // BOTÓN INFERIOR: COBRAR
            if (_selectedDebtIds.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 8, offset: const Offset(0, -2))],
                ),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _goToDetail(todasLasDeudas),
                    icon: const Icon(Icons.account_balance_wallet, size: 20),
                    label: Text(
                      'Cobrar S/ ${selectedTotal.toStringAsFixed(2)}',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                  ),
                ),
              ),
          ],
        ),
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

  Widget _buildDebtCard(Debt debt, bool isSelected) {
    final statusColor = debt.status == DebtStatus.pagado ? AppColors.success : AppColors.gold;
    final statusText = debt.status == DebtStatus.pagado ? 'PAGADO' : 'PENDIENTE';

    return GestureDetector(
      onTap: () {
        setState(() {
          if (_selectedDebtIds.contains(debt.id)) {
            _selectedDebtIds.remove(debt.id);
          } else {
            _selectedDebtIds.add(debt.id);
          }
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.teal : Colors.transparent,
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.only(top: 2, right: 12),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.teal : Colors.white,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: isSelected ? AppColors.teal : AppColors.mist,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(Icons.check, size: 16, color: Colors.white)
                  : null,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'S/ ${debt.amount.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
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
                          color: statusColor,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _goToDetail(List<Debt> todasLasDeudas) {
    final selectedDebts = todasLasDeudas
        .where((d) => _selectedDebtIds.contains(d.id))
        .toList();
        
    if (selectedDebts.isEmpty) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DebtDetailMultipleScreen(
          customer: widget.customer,
          debts: selectedDebts,
        ),
      ),
    );
  }
}
