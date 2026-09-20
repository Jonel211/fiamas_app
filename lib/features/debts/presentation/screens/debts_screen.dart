import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../main.dart';
import '../../domain/debt.dart';
import '../widgets/debt_tile.dart';
import 'new_debt_customer_screen.dart';
import 'debt_detail_screen.dart';
import 'debts_overview_screen.dart';

class DebtsScreen extends StatefulWidget {
  const DebtsScreen({super.key});

  @override
  State<DebtsScreen> createState() => _DebtsScreenState();
}

enum _DebtFilter { todos, pendientes, pagados }

class _DebtsScreenState extends State<DebtsScreen> {
  // TODO: reemplazar por datos reales desde DebtsRepository
  static const _debts = [
    Debt(
      id: '1',
      customerName: 'Ricardo Mendoza',
      phone: '987 123 456',
      amount: 45.00,
      status: DebtStatus.pendiente,
      dateLabel: 'Hoy, 10:30 AM',
      items: [
        DebtItem(productName: 'Agua San Mateo 1L', quantity: 1, unitPrice: 2.50),
        DebtItem(productName: 'Pan Unión', quantity: 2, unitPrice: 6.50),
      ],
    ),
    Debt(
      id: '2',
      customerName: 'Lucía García',
      phone: '955 666 777',
      amount: 12.80,
      status: DebtStatus.pagado,
      dateLabel: 'Ayer',
    ),
    Debt(
      id: '3',
      customerName: 'Carlos Prado',
      phone: '944 222 111',
      amount: 120.00,
      status: DebtStatus.pendiente,
      dateLabel: '20 Oct',
    ),
  ];

  _DebtFilter _filter = _DebtFilter.todos;

  List<Debt> get _filteredDebts {
    switch (_filter) {
      case _DebtFilter.todos:
        return _debts;
      case _DebtFilter.pendientes:
        return _debts.where((d) => d.status == DebtStatus.pendiente).toList();
      case _DebtFilter.pagados:
        return _debts.where((d) => d.status == DebtStatus.pagado).toList();
    }
  }

  double get _totalPorCobrar => _debts
      .where((d) => d.status == DebtStatus.pendiente)
      .fold(0.0, (sum, d) => sum + d.amount);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Fiados',
                                style: Theme.of(context).textTheme.headlineSmall),
                            const SizedBox(height: 2),
                            Text('Gestión de deudores',
                                style: Theme.of(context).textTheme.bodyMedium),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => const DebtsOverviewScreen()),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            const Text('POR COBRAR',
                                style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.4,
                                    color: AppColors.inkMuted)),
                            Text('S/ ${_totalPorCobrar.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink)),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      _FilterTab(
                        label: 'Todos',
                        selected: _filter == _DebtFilter.todos,
                        onTap: () => setState(() => _filter = _DebtFilter.todos),
                      ),
                      const SizedBox(width: 8),
                      _FilterTab(
                        label: 'Pendientes',
                        selected: _filter == _DebtFilter.pendientes,
                        onTap: () =>
                            setState(() => _filter = _DebtFilter.pendientes),
                      ),
                      const SizedBox(width: 8),
                      _FilterTab(
                        label: 'Pagados',
                        selected: _filter == _DebtFilter.pagados,
                        onTap: () => setState(() => _filter = _DebtFilter.pagados),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _filteredDebts.isEmpty
                  ? Center(
                      child: Text('No hay fiados en esta categoría',
                          style: Theme.of(context).textTheme.bodyMedium),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.fromLTRB(24, 4, 24, 100),
                      itemCount: _filteredDebts.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: AppColors.mist),
                      itemBuilder: (context, index) {
                        final debt = _filteredDebts[index];
                        return DebtTile(
                          debt: debt,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                                builder: (_) => DebtDetailScreen(debt: debt)),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.of(context).push(
          MaterialPageRoute(builder: (_) => const NewDebtCustomerScreen()),
        ),
        backgroundColor: AppColors.teal,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nuevo fiado',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            AppRoutes.goHome(context);
          } else if (index == 2) {
            Navigator.of(context).pushNamed(AppRoutes.products);
          } else if (index == 3) {
            Navigator.of(context).pushNamed(AppRoutes.help);
          }
        },
      ),
    );
  }
}

class _FilterTab extends StatelessWidget {
  const _FilterTab({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? AppColors.ink : AppColors.mist.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? Colors.white : AppColors.inkMuted,
          ),
        ),
      ),
    );
  }
}