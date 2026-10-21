import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ReportsSummary extends StatelessWidget {
  const ReportsSummary({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Resumen semanal', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink)),
                  Text('21-27 de septiembre', style: TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.circle, size: 8, color: AppColors.teal),
                    SizedBox(width: 4),
                    Text('Actualizado hoy', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.teal)),
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.mist),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.show_chart_rounded, color: AppColors.teal, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Ventas Totales', style: TextStyle(fontSize: 13, color: AppColors.inkMuted)),
                    const Text('S/ 1,450.00', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppColors.ink)),
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.trending_up_rounded, size: 14, color: Colors.green),
                        SizedBox(width: 4),
                        Text('+15% vs semana anterior', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: Colors.green)),
                      ],
                    )
                  ],
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 12),

        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Expanded(
                child: _buildMiniCard(
                  title: 'Total Fiado / Por Cobrar',
                  amount: 'S/ 620.00',
                  subtitle: '8 clientes pendientes',
                  icon: Icons.payments_outlined,
                  iconColor: Colors.orange,
                  subtitleColor: Colors.orange,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMiniCard(
                  title: 'Cobros Realizados',
                  amount: 'S/ 830.00',
                  subtitle: '12 cobros registrados',
                  icon: Icons.check_circle_outline_rounded,
                  iconColor: AppColors.teal,
                  subtitleColor: AppColors.teal,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMiniCard({
    required String title,
    required String amount,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required Color subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mist),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(child: Text(title, style: const TextStyle(fontSize: 11, color: AppColors.inkMuted))),
              Icon(icon, color: iconColor, size: 18),
            ],
          ),
          const SizedBox(height: 8),
          Text(amount, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.ink)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: subtitleColor)),
        ],
      ),
    );
  }
}