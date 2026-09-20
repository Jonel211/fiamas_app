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
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
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
                  const SizedBox(width: 8),
                  Text('Detalle de Fiado',
                      style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(14),
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
                                  Text(debt.customerName,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700,
                                          fontSize: 15,
                                          color: AppColors.ink)),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      StatusBadge(status: debt.status),
                                      const SizedBox(width: 6),
                                      Text(debt.dateLabel,
                                          style: const TextStyle(
                                              fontSize: 11, color: AppColors.inkMuted)),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      const Text('PRODUCTOS COMPRADOS',
                          style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.4,
                              color: AppColors.inkMuted)),
                      const SizedBox(height: 10),
                      if (debt.items.isEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 8),
                          child: Text('Sin detalle de productos para este fiado.',
                              style: TextStyle(fontSize: 13, color: AppColors.inkMuted)),
                        )
                      else
                        for (final item in debt.items) ...[
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item.productName,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.w600,
                                            fontSize: 14,
                                            color: AppColors.ink)),
                                    Text(
                                      '${item.quantity} ${item.quantity == 1 ? 'unidad' : 'unidades'}',
                                      style: const TextStyle(
                                          fontSize: 12, color: AppColors.inkMuted),
                                    ),
                                  ],
                                ),
                              ),
                              Text('S/ ${item.subtotal.toStringAsFixed(2)}',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: AppColors.ink)),
                            ],
                          ),
                          const SizedBox(height: 14),
                        ],
                      const SizedBox(height: 6),
                      const Divider(color: AppColors.mist),
                      const SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('TOTAL DEUDA',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                  color: AppColors.inkMuted)),
                          Text('S/ ${debt.amount.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              if (debt.status == DebtStatus.pendiente) ...[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal),
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(
                        builder: (_) => CollectPaymentScreen(debt: debt)),
                  ),
                  icon: const Icon(Icons.account_balance_wallet_outlined, size: 18),
                  label: const Text('Cobrar esta deuda'),
                ),
                const SizedBox(height: 8),
                OutlinedButton.icon(
                  onPressed: () {
                    // TODO: enviar recordatorio (WhatsApp / SMS)
                  },
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Enviar recordatorio'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.ink,
                    side: const BorderSide(color: AppColors.mist),
                    minimumSize: const Size.fromHeight(52),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}