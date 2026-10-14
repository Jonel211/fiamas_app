import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/debt.dart';
import 'debt_detail_screen.dart';
import 'select_debts_screen.dart'; // ✅ NUEVO IMPORT para la selección múltiple

class DebtHistoryScreen extends StatefulWidget {
  final Map<String, dynamic> customer;

  const DebtHistoryScreen({super.key, required this.customer});

  @override
  State<DebtHistoryScreen> createState() => _DebtHistoryScreenState();
}

class _DebtHistoryScreenState extends State<DebtHistoryScreen> {
  String _selectedFilter = 'Todos';

  final List<Debt> _debts = [
    Debt(
      id: '1',
      customerName: 'Doña Martha Gómez',
      phone: '+51 987 654 321',
      amount: 62.00,
      status: DebtStatus.pagado,
      dateLabel: 'Cancelado el 10 sep 2024',
      items: [
        DebtItem(productName: 'Azúcar', quantity: 1, unitPrice: 20.00),
        DebtItem(productName: 'Detergente', quantity: 1, unitPrice: 25.00),
        DebtItem(
          productName: 'Jabón Bolívar x3',
          quantity: 1,
          unitPrice: 17.00,
        ),
      ],
    ),
    Debt(
      id: '2',
      customerName: 'Doña Martha Gómez',
      phone: '+51 912 345 678',
      amount: 38.00,
      status: DebtStatus.pendiente,
      dateLabel: 'Vencido hace 3 días',
      items: [
        DebtItem(productName: 'Manteca', quantity: 1, unitPrice: 10.00),
        DebtItem(productName: 'Fideos', quantity: 2, unitPrice: 4.00),
        DebtItem(productName: 'Galletas Soda', quantity: 1, unitPrice: 12.00),
        DebtItem(productName: 'Jabón de barra', quantity: 1, unitPrice: 8.00),
      ],
    ),
    Debt(
      id: '3',
      customerName: 'Doña Martha Gómez',
      phone: '+51 998 776 554',
      amount: 140.00,
      status: DebtStatus.pendiente,
      dateLabel: '19 ago 2024',
      items: [
        DebtItem(
          productName: 'Generales X, Y, Z',
          quantity: 1,
          unitPrice: 80.00,
        ),
        DebtItem(
          productName: 'Canastos sin stock',
          quantity: 1,
          unitPrice: 40.00,
        ),
        DebtItem(productName: 'Preparación', quantity: 1, unitPrice: 20.00),
      ],
    ),
  ];

  List<Debt> get _filteredDebts {
    if (_selectedFilter == 'Todos') return _debts;
    if (_selectedFilter == 'Vigentes') {
      return _debts.where((d) => d.status == DebtStatus.pendiente).toList();
    }
    if (_selectedFilter == 'Pagados') {
      return _debts.where((d) => d.status == DebtStatus.pagado).toList();
    }
    if (_selectedFilter == 'Vencidos') {
      return _debts
          .where(
            (d) =>
                d.status == DebtStatus.pendiente &&
                d.dateLabel.contains('Vencido'),
          )
          .toList();
    }
    return _debts;
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.customer['name'] as String? ?? 'Cliente';
    final phone = widget.customer['phone'] as String? ?? '';
    final debtAmount = (widget.customer['debt'] as num?)?.toDouble() ?? 245.50;
    final totalFiado = 1290.0;
    final totalPagado = 1044.50;
    final initial = name.isNotEmpty
        ? name.split(' ').last[0].toUpperCase()
        : 'C';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Historial de Cliente',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
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
                  child: Text(
                    initial,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
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
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        phone,
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.gold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Score 92',
                        style: TextStyle(
                          color: AppColors.gold,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Excelente',
                      style: TextStyle(
                        color: AppColors.teal,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // TARJETA TEAL
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 20),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppColors.teal,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'SALDO ACTUAL PENDIENTE',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'S/ ${debtAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: Colors.white24, height: 1),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total fiado',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'S/ ${totalFiado.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Total pagado',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'S/ ${totalPagado.toStringAsFixed(2)}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
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
                _buildFilterChip('Todos', _debts.length, true),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Vigentes',
                  _debts.where((d) => d.status == DebtStatus.pendiente).length,
                  false,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Pagados',
                  _debts.where((d) => d.status == DebtStatus.pagado).length,
                  false,
                ),
                const SizedBox(width: 8),
                _buildFilterChip(
                  'Vencidos',
                  _debts
                      .where(
                        (d) =>
                            d.status == DebtStatus.pendiente &&
                            d.dateLabel.contains('Vencido'),
                      )
                      .length,
                  false,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // LISTA
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _filteredDebts.length,
              itemBuilder: (context, index) =>
                  _buildDebtCard(_filteredDebts[index]),
            ),
          ),
        ],
      ),

      // ✅ NUEVO BOTÓN FLOTANTE PARA SELECCIÓN MÚLTIPLE
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => SelectDebtsScreen(customer: widget.customer),
            ),
          );
        },
        backgroundColor: AppColors.teal,
        icon: const Icon(Icons.checklist, color: Colors.white),
        label: const Text(
          'Seleccionar fiados',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, int count, bool isActive) {
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedFilter = label;
        });
      },
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
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildDebtCard(Debt debt) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => DebtDetailScreen(debt: debt)),
        );
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
              offset: const Offset(0, 2),
            ),
          ],
        ),
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: debt.status == DebtStatus.pagado
                        ? AppColors.success.withOpacity(0.15)
                        : AppColors.gold.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    debt.status == DebtStatus.pagado ? 'PAGADO' : 'PENDIENTE',
                    style: TextStyle(
                      color: debt.status == DebtStatus.pagado
                          ? AppColors.success
                          : AppColors.gold,
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
                Text(
                  debt.dateLabel,
                  style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
                ),
                Text(
                  debt.status == DebtStatus.pagado ? 'Cancelado' : 'Pendiente',
                  style: TextStyle(
                    fontSize: 12,
                    color: debt.status == DebtStatus.pagado
                        ? AppColors.success
                        : AppColors.gold,
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
