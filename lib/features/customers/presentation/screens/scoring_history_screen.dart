import 'package:flutter/material.dart';
import 'package:fiamas_app/core/constants/app_colors.dart';

class ScoringHistoryScreen extends StatefulWidget {
  final Map<String, dynamic>? customer;

  const ScoringHistoryScreen({super.key, this.customer});

  @override
  State<ScoringHistoryScreen> createState() => _ScoringHistoryScreenState();
}

class _ScoringHistoryScreenState extends State<ScoringHistoryScreen> {
  String _selectedPeriod = 'Todo';

  @override
  Widget build(BuildContext context) {
    final customerName = widget.customer?['name'] as String? ?? 'Cliente';
    final currentScore = widget.customer?['score'] as int? ?? 0;
    final categoria = widget.customer?['categoria'] as String? ?? 'nuevo';

    // Determinamos la categoría basándonos en la lógica real
    String scoreCategory = 'Nuevo';
    if (categoria != 'nuevo') {
      if (currentScore >= 80) scoreCategory = 'Bueno';
      if (currentScore >= 50 && currentScore < 80) scoreCategory = 'Regular';
      if (currentScore < 50) scoreCategory = 'Malo';
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // HEADER
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 40, 20, 30),
            decoration: const BoxDecoration(
              color: AppColors.teal,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => Navigator.pop(context),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Historial de Scoring',
                  style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 4),
                Text(
                  customerName,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$currentScore',
                      style: const TextStyle(color: Colors.white, fontSize: 56, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('pts', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(color: AppColors.gold, borderRadius: BorderRadius.circular(12)),
                          child: Text(
                            scoreCategory,
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // FILTROS DE PERÍODO
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(child: _buildPeriodButton('Todo')),
                const SizedBox(width: 8),
                Expanded(child: _buildPeriodButton('30 días')),
                const SizedBox(width: 8),
                Expanded(child: _buildPeriodButton('Año')),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // LISTA DE EVENTOS
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_rounded, size: 60, color: AppColors.inkMuted.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  const Text(
                    'Aún no hay historial de scoring.',
                    style: TextStyle(color: AppColors.inkMuted, fontSize: 15),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () => setState(() => _selectedPeriod = period),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.teal : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: isSelected ? AppColors.teal : AppColors.mist),
        ),
        child: Text(
          period,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : AppColors.ink,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}