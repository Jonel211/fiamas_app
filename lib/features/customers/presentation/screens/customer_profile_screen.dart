import 'package:flutter/material.dart';
import 'package:fiamas_app/core/constants/app_colors.dart';

import '../widgets/edit_credit_limit_bottom_sheet.dart';

class CustomerProfileScreen extends StatefulWidget {
  final Map<String, dynamic> customer;

  const CustomerProfileScreen({super.key, required this.customer});

  @override
  State<CustomerProfileScreen> createState() => _CustomerProfileScreenState();
}

class _CustomerProfileScreenState extends State<CustomerProfileScreen> {
  /// Obtiene la inicial real del nombre (ignora títulos como Doña, Don, etc.)
  String _getInitial(String name) {
    final words = name.trim().split(' ');
    // Ignorar títulos comunes
    final skipTitles = {
      'doña',
      'don',
      'señor',
      'señora',
      'dr',
      'dra',
      'lic',
      'ing',
    };
    for (final word in words) {
      if (!skipTitles.contains(word.toLowerCase())) {
        return word[0].toUpperCase();
      }
    }
    return name[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final name = widget.customer['name'] as String? ?? 'Cliente';
    final phone = widget.customer['phone'] as String? ?? '';
    final debt = (widget.customer['debt'] as num?)?.toDouble() ?? 0.0;
    final creditLimit =
        (widget.customer['creditLimit'] as num?)?.toDouble() ?? 500.0;
    final used = debt;
    final available = creditLimit - used;
    final usagePercent = creditLimit > 0
        ? (used / creditLimit * 100).clamp(0.0, 100.0)
        : 0.0;
    final totalFiado = 1250.0;
    final totalPagado = 1004.50;
    final initial = _getInitial(name);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Perfil Del Cliente',
          style: TextStyle(color: AppColors.ink, fontWeight: FontWeight.w600),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ═══════════════════════════════════════════════════════════════
            // TARJETA SUPERIOR: Avatar + Nombre + Score + Badge "Bueno"
            // ═══════════════════════════════════════════════════════════════
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 24),
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
                    children: [
                      // Avatar grande centrado
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: AppColors.teal,
                        child: Text(
                          initial,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Nombre
                      Text(
                        name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      // Subtítulo
                      const Text(
                        'Cliente desde marzo 2024',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.inkMuted,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Badge Score dorado
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.emoji_events,
                              color: Colors.white,
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            const Text(
                              'Score 50',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                // Badge "Bueno" en la esquina superior derecha de la tarjeta
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.teal,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'Bueno',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ═══════════════════════════════════════════════════════════════
            // FILA DE 4 BOTONES CIRCULARES
            // ══════════════════════════════════════════════════════════════
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionCircleButton(
                  icon: Icons.phone,
                  label: 'Llamar',
                  onTap: () {
                    // TODO: Implementar llamada
                  },
                ),
                _ActionCircleButton(
                  icon: Icons.chat_bubble_outline,
                  label: 'WhatsApp',
                  onTap: () {
                    // TODO: Abrir WhatsApp
                  },
                ),

                _ActionCircleButton(
                  icon: Icons.location_on_outlined,
                  label: 'Dirección',
                  onTap: () {
                    // TODO: Ver dirección
                  },
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ═══════════════════════════════════════════════════════════════
            // TARJETA TEAL: SALDO ACTUAL PENDIENTE
            // ═══════════════════════════════════════════════════════════════
            Container(
              width: double.infinity,
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
                    'S/ ${debt.toStringAsFixed(2)}',
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

            // ═══════════════════════════════════════════════════════════════
            // TARJETA BLANCA: LÍMITE DE CRÉDITO
            // ═══════════════════════════════════════════════════════════════
            Container(
              width: double.infinity,
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
                  // Header con título y monto
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Límite de crédito',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.inkMuted,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'S/ ${creditLimit.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.ink,
                            ),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              // ✅ ABRIR BOTTOM SHEET EN LUGAR DE NAVEGAR
                              showModalBottomSheet(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                builder: (context) =>
                                    EditCreditLimitBottomSheet(
                                      customer: widget.customer,
                                    ),
                              ).then((newLimit) {
                                if (newLimit != null) {
                                  // TODO: Actualizar el límite en el backend y refrescar UI
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Límite actualizado a S/ ${newLimit.toStringAsFixed(2)}',
                                      ),
                                      backgroundColor: AppColors.success,
                                    ),
                                  );
                                }
                              });
                            },
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.teal.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.edit,
                                color: AppColors.teal,
                                size: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Barra de progreso
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: usagePercent / 100,
                      backgroundColor: AppColors.skyBlue.withOpacity(0.3),
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.gold),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Texto de usado y disponible
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Usado: S/ ${used.toStringAsFixed(2)} (${usagePercent.toInt()}%)',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.inkMuted,
                        ),
                      ),
                      Text(
                        'Disponible: S/ ${available.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.teal,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════════════
// WIDGET: Botón circular de acción (Llamar, WhatsApp, etc.)
// ══════════════════════════════════════════════════════════════════════════
class _ActionCircleButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionCircleButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppColors.skyBlue.withOpacity(0.4),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.teal, size: 24),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: AppColors.inkMuted,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
