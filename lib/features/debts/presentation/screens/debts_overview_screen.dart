import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav.dart';

class DebtsOverviewScreen extends StatelessWidget {
  const DebtsOverviewScreen({super.key});

  // TODO: reemplazar por datos reales desde DebtsRepository
  static const _totalPendiente = 1245.50;
  static const _weeklyBars = [0.3, 0.45, 0.25, 0.6, 1.0, 0.4, 0.5];
  static const _topDebtors = [
    ('Carlos Prado', 420.00),
    ('Ana Sofía', 285.50),
    ('Marcos Ramos', 150.00),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.ink),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const Expanded(
                    child: Text(
                      '¿Cuánto me deben?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink),
                    ),
                  ),
                  const SizedBox(width: 24), // balancea la flecha para centrar el título
                ],
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      Center(
                        child: Column(
                          children: [
                            const Text('Resumen General',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.teal)),
                            const SizedBox(height: 4),
                            Text('S/ ${_totalPendiente.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.ink)),
                            const SizedBox(height: 2),
                            const Text('MONTO PENDIENTE TOTAL',
                                style: TextStyle(
                                    fontSize: 10,
                                    letterSpacing: 0.4,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.gold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        height: 120,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            for (int i = 0; i < _weeklyBars.length; i++)
                              _Bar(
                                heightFactor: _weeklyBars[i],
                                highlighted: _weeklyBars[i] ==
                                    _weeklyBars.reduce((a, b) => a > b ? a : b),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Por persona',
                              style: TextStyle(
                                  fontWeight: FontWeight.w700,
                                  fontSize: 15,
                                  color: AppColors.ink)),
                          TextButton.icon(
                            onPressed: () {
                              // TODO: exportar/descargar reporte
                            },
                            icon: const Icon(Icons.download_outlined,
                                size: 15, color: AppColors.inkMuted),
                            label: const Text('Descargar',
                                style: TextStyle(
                                    fontSize: 12, color: AppColors.inkMuted)),
                          ),
                        ],
                      ),
                      for (int i = 0; i < _topDebtors.length; i++)
                        _DebtorRankTile(
                          rank: i + 1,
                          name: _topDebtors[i].$1,
                          amount: _topDebtors[i].$2,
                        ),
                      const SizedBox(height: 90),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 1),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.heightFactor, required this.highlighted});

  final double heightFactor;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 100 * heightFactor,
      decoration: BoxDecoration(
        color: highlighted ? AppColors.gold : AppColors.mist,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
      ),
    );
  }
}

class _DebtorRankTile extends StatelessWidget {
  const _DebtorRankTile({required this.rank, required this.name, required this.amount});

  final int rank;
  final String name;
  final double amount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.mist,
              shape: BoxShape.circle,
            ),
            child: Text('$rank',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 12, color: AppColors.ink)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(name,
                style: const TextStyle(
                    fontWeight: FontWeight.w600, fontSize: 14, color: AppColors.ink)),
          ),
          Text('S/ ${amount.toStringAsFixed(2)}',
              style: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
        ],
      ),
    );
  }
}