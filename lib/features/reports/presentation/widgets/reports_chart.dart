import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';

class ReportsChart extends StatelessWidget {
  const ReportsChart({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(20),
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
              const Text('Fiados semanales', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(color: AppColors.teal.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.arrow_upward_rounded, size: 12, color: AppColors.teal),
                    SizedBox(width: 2),
                    Text('15.2%', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.teal)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          SizedBox(
            height: 150,
            child: LineChart(
              LineChartData(
                gridData: const FlGridData(show: false),
                titlesData: FlTitlesData(
                  show: true,
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 22,
                      interval: 1,
                      getTitlesWidget: (value, meta) {
                        const days = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];
                        if (value >= 0 && value < days.length) {
                          return Text(days[value.toInt()], style: const TextStyle(fontSize: 10, color: AppColors.inkMuted));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineTouchData: LineTouchData(
                  touchTooltipData: LineTouchTooltipData(
                    getTooltipColor: (touchedSpot) => AppColors.ink,
                    getTooltipItems: (List<LineBarSpot> touchedSpots) {
                      return touchedSpots.map((spot) {
                        return LineTooltipItem(
                          'S/ ${spot.y.toStringAsFixed(0)}',
                          const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                        );
                      }).toList();
                    },
                  ),
                ),
                minY: 0,
                maxY: 250,
                lineBarsData: [
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 80),
                      FlSpot(1, 120),
                      FlSpot(2, 90),
                      FlSpot(3, 150),
                      FlSpot(4, 180),
                      FlSpot(5, 140),
                      FlSpot(6, 220),
                    ],
                    isCurved: true,
                    color: AppColors.teal,
                    barWidth: 3,
                    isStrokeCapRound: true,
                    dotData: const FlDotData(show: false),
                    belowBarData: BarAreaData(
                      show: true,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.teal.withOpacity(0.3),
                          AppColors.teal.withOpacity(0.0),
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                      ),
                    ),
                  ),
                  LineChartBarData(
                    spots: const [
                      FlSpot(0, 60),
                      FlSpot(1, 100),
                      FlSpot(2, 130),
                      FlSpot(3, 110),
                      FlSpot(4, 140),
                      FlSpot(5, 160),
                      FlSpot(6, 190),
                    ],
                    isCurved: true,
                    color: Colors.orangeAccent,
                    barWidth: 2,
                    dashArray: [5, 5],
                    dotData: const FlDotData(show: false),
                  ),
                ],
              ),
            ),
          ),
          
          const Divider(color: AppColors.mist, height: 24),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Anterior: S/ 1,258.00', style: TextStyle(fontSize: 11, color: AppColors.inkMuted)),
              Text('+S/ 192.00', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.teal)),
            ],
          )
        ],
      ),
    );
  }
}