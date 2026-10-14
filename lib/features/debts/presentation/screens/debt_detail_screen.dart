import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../domain/debt.dart';
import '../widgets/debt_avatar.dart';
import '../widgets/status_badge.dart';
import 'collect_payment_screen.dart';

class DebtDetailScreen extends StatelessWidget {
  const DebtDetailScreen({super.key, required this.debt});

  final Debt debt;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Detalle de Fiado',
          style: TextStyle(
            color: AppColors.ink,
            fontWeight: FontWeight.w600,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.white,
        foregroundColor: AppColors.ink,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ═══════════════════════════════════════════════════════════════
            // CARD: Cliente y estado
            // ═══════════════════════════════════════════════════════════════
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.mist),
              ),
              child: Row(
                children: [
                  DebtAvatar(initials: debt.initials, status: debt.status),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          debt.customerName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: AppColors.ink,
                          ),
                        ),
                        const SizedBox(height: 4),
                        StatusBadge(status: debt.status),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ═══════════════════════════════════════════════════════════════
            // CARD: Productos comprados
            // ══════════════════════════════════════════════════════════════
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.mist),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Productos comprados',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.teal,
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (debt.items.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Text(
                        'Sin detalle de productos para este fiado.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.inkMuted,
                        ),
                      ),
                    )
                  else
                    ...debt.items.map((item) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.productName,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.ink,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              'S/ ${item.subtotal.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ═══════════════════════════════════════════════════════════════
            // CARD AZUL: Resumen de cuenta
            // ═══════════════════════════════════════════════════════════════
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.skyBlue.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.teal, width: 2),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Resumen de cuenta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.teal,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildSummaryRow(
                    'Total Deuda Original',
                    'S/ ${debt.amount.toStringAsFixed(2)}',
                  ),
                  const SizedBox(height: 8),
                  _buildSummaryRow('Total Pagado', 'S/ 10.00'),
                  const Divider(height: 16, color: AppColors.mist),
                  _buildSummaryRow(
                    'Total Deuda Actual Restante',
                    'S/ ${debt.amount.toStringAsFixed(2)}',
                    isBold: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ═══════════════════════════════════════════════════════════════
            // BOTÓN: Historial de Pagos
            // ═══════════════════════════════════════════════════════════════
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Navegar al historial de pagos
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Historial de pagos próximamente'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Historial de Pagos de este fiado',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // ═══════════════════════════════════════════════════════════════
            // CARD: Mensaje de pagos
            // ═══════════════════════════════════════════════════════════════
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.mist),
              ),
              child: const Text(
                'No hay pagos registrados para este fiado',
                style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 24),

            // ═══════════════════════════════════════════════════════════════
            // TOTAL DEUDA
            // ═══════════════════════════════════════════════════════════════
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'TOTAL DEUDA',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  'S/${debt.amount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // ═══════════════════════════════════════════════════════════════
            // BOTÓN: Cobrar esta deuda
            // ═══════════════════════════════════════════════════════════════
            if (debt.status == DebtStatus.pendiente)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CollectPaymentScreen(debt: debt),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Cobrar esta deuda',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

            const SizedBox(height: 12),

            // ═══════════════════════════════════════════════════════════════
            // BOTÓN: Enviar recordatorio
            // ═══════════════════════════════════════════════════════════════
            if (debt.status == DebtStatus.pendiente)
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // TODO: Implementar envío de recordatorio (WhatsApp / SMS)
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Recordatorio enviado')),
                    );
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.teal,
                    side: const BorderSide(color: AppColors.teal),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Enviar recordatorio',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                ),
              ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.ink,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.ink,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
