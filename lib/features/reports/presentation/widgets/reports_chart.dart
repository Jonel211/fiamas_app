import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/constants/app_colors.dart';
import '../../data/models/reporte_resumen_model.dart';

class ReportsChart extends StatelessWidget {
  final List<ChartDataModel> chartData;

  const ReportsChart({super.key, required this.chartData});

  @override
  Widget build(BuildContext context) {
    final spots = chartData.asMap().entries.map((e) {
      return FlSpot(e.key.toDouble(), e.value.monto);
    }).toList();

    final spotsParaGrafico = spots.isEmpty ? [const FlSpot(0, 0)] : spots;

    double maxY = 100;
    if (spots.isNotEmpty) {
      final maxVal = spots.map((s) => s.y).reduce((a, b) => a > b ? a : b);
      maxY = maxVal > 0 ? maxVal * 1.2 : 100;
    }

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
          const Text('Fiados últimos 7 días',
              style: TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink)),
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
                        final i = value.toInt();
                        if (value == i.toDouble() && i >= 0 && i < chartData.length) {
                          return Text(chartData[i].dia,
                              style: const TextStyle(
                                  fontSize: 10, color: AppColors.inkMuted));
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
                          'S/ ${spot.y.toStringAsFixed(2)}',
                          const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12),
                        );
                      }).toList();
                    },
                  ),
                ),
                minY: 0,
                maxY: maxY,
                lineBarsData: [
                  LineChartBarData(
                    spots: spotsParaGrafico,
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
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}