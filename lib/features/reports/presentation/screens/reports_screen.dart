import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../widgets/reports_filters.dart';
import '../widgets/reports_summary.dart';
import '../widgets/reports_chart.dart';
import '../widgets/report_item_tile.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        children: [
          const AppHeader(title: 'Reportes', showBack: true),
          Expanded(
            child: SafeArea(
              top: false,
              child: Column(
                children: [
                  const ReportsFilters(),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 32),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          const ReportsSummary(),
                          const SizedBox(height: 24),
                          const ReportsChart(),
                          const SizedBox(height: 24),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Reportes detallados',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.ink,
                                      ),
                                    ),
                                    Text(
                                      'Descarga cada categoría por separado',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: AppColors.inkMuted,
                                      ),
                                    ),
                                  ],
                                ),
                                const Text(
                                  '4 reportes',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.teal,
                                  ),
                                ),
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
                                  subtitle: '34 operaciones • S/ 1,450.00',
                                  status: '+15%',
                                  amount: '',
                                  icon: Icons.shopping_cart_outlined,
                                  iconColor: AppColors.teal,
                                  iconBg: AppColors.teal.withOpacity(0.1),
                                  statusColor: Colors.green,
                                ),
                                ReportItemTile(
                                  title: 'Fiados por cobrar',
                                  subtitle: '8 clientes • S/ 620.00',
                                  status: 'Pendiente',
                                  amount: '',
                                  icon: Icons.pan_tool_outlined,
                                  iconColor: Colors.orange,
                                  iconBg: Colors.orange.withOpacity(0.1),
                                  statusColor: Colors.orange,
                                ),
                                ReportItemTile(
                                  title: 'Cobros',
                                  subtitle: '12 cobros • S/ 830.00',
                                  status: 'Completado',
                                  amount: '',
                                  icon: Icons.mark_email_read_outlined,
                                  iconColor: Colors.green,
                                  iconBg: Colors.green.withOpacity(0.1),
                                  statusColor: Colors.green,
                                ),
                                ReportItemTile(
                                  title: 'Productos más vendidos',
                                  subtitle: 'Top 10 • 126 unidades',
                                  status: 'Ver ranking',
                                  amount: '',
                                  icon: Icons.inventory_2_outlined,
                                  iconColor: Colors.indigo,
                                  iconBg: Colors.indigo.withOpacity(0.1),
                                  statusColor: Colors.indigo,
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
        ],
      ),
    );
  }
}