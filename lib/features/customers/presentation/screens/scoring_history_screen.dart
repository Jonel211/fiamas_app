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

  final List<Map<String, dynamic>> _scoringEvents = [
    {
      'type': 'positive',
      'title': 'Pago a tiempo registrado',
      'points': 15,
      'time': '09:30 AM',
      'description': 'Pago de fiado pendiente registrado correctamente',
      'previousScore': 45,
      'newScore': 60,
    },
    {
      'type': 'negative',
      'title': 'Pago vencido registrado',
      'points': -10,
      'time': 'Ayer, 3:45 PM',
      'description': 'Se registró un fiado con fecha de pago vencida',
      'previousScore': 55,
      'newScore': 45,
    },
    {
      'type': 'positive',
      'title': 'Nuevo cliente registrado',
      'points': 5,
      'time': '15 ago 2024',
      'description': 'Registro inicial en el sistema',
      'previousScore': 50,
      'newScore': 55,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final customerName = widget.customer != null
        ? (widget.customer!['name'] as String? ?? 'Cliente')
        : 'Cliente General';

    const currentScore = 50;
    const scoreCategory = 'Cliente Regular';

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          // ═══════════════════════════════════════════════════════════════
          // HEADER CON SCORE
          // ═══════════════════════════════════════════════════════════════
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 40),
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
                    ),
                    const Expanded(child: SizedBox()),
                  ],
                ),
                const SizedBox(height: 20),
                const Text(
                  'Historial de Scoring',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  customerName,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 24),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '$currentScore',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 64,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'pts',
                          style: TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gold,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            scoreCategory,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.trending_up,
                        color: AppColors.success,
                        size: 16,
                      ),
                      SizedBox(width: 4),
                      Text(
                        '+15 pts este mes',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ═══════════════════════════════════════════════════════════════
          // FILTROS DE PERÍODO
          // ══════════════════════════════════════════════════════════════
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

          // ═══════════════════════════════════════════════════════════════
          // LISTA DE EVENTOS
          // ═════════════════════════════════════════════════════════════
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: _scoringEvents.length,
              itemBuilder: (context, index) {
                final event = _scoringEvents[index];
                return _buildScoringEvent(event);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodButton(String period) {
    final isSelected = _selectedPeriod == period;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPeriod = period;
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.teal : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.teal : AppColors.mist,
          ),
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

  Widget _buildScoringEvent(Map<String, dynamic> event) {
    final isPositive = event['type'] == 'positive';
    final points = event['points'] as int;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
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
            children: [
              Icon(
                isPositive ? Icons.arrow_upward : Icons.arrow_downward,
                color: isPositive ? AppColors.success : AppColors.danger,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  event['title'] as String,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
              ),
              Text(
                '${isPositive ? '+' : ''}$points puntos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: isPositive ? AppColors.success : AppColors.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            event['description'] as String,
            style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                event['time'] as String,
                style: TextStyle(fontSize: 11, color: AppColors.inkMuted),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            height: 4,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                colors: isPositive
                    ? [AppColors.success.withOpacity(0.3), AppColors.success]
                    : [AppColors.danger.withOpacity(0.3), AppColors.danger],
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Score anterior: ${event['previousScore']}',
                style: TextStyle(fontSize: 11, color: AppColors.inkMuted),
              ),
              Text(
                'Nuevo: ${event['newScore']}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
