import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../domain/debt.dart';
import 'debts_screen.dart';

class NewDebtReviewScreen extends StatelessWidget {
  const NewDebtReviewScreen({
    super.key,
    required this.items,
    this.customerName = 'Ricardo Mendoza',
    this.customerPhone = '987 123 456',
  });

  final List<DebtItem> items;
  final String customerName;
  final String customerPhone;

  double get _total => items.fold(0.0, (sum, item) => sum + item.subtotal);

  String get _initials {
    final parts = customerName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }

  void _handleConfirm(BuildContext context) {
    // TODO: conectar con DebtsRepository.createDebt()
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const DebtsScreen()),
      (route) => false,
    );
  }

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
                  Text('Revisar Fiado',
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
                            CircleAvatar(
                              radius: 20,
                              backgroundColor: AppColors.mist,
                              child: Text(_initials,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.ink)),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(customerName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 14,
                                        color: AppColors.ink)),
                                Text(customerPhone,
                                    style: const TextStyle(
                                        fontSize: 12, color: AppColors.inkMuted)),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      for (final item in items) ...[
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
                                    '${item.quantity} ${item.quantity == 1 ? 'unidad' : 'unidades'} x S/ ${item.unitPrice.toStringAsFixed(2)}',
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
                      const Divider(color: AppColors.mist),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('TOTAL',
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.4,
                                  color: AppColors.inkMuted)),
                          Text('S/ ${_total.toStringAsFixed(2)}',
                              style: const TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.ink)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.gold.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(12),
                          border:
                              Border.all(color: AppColors.gold.withValues(alpha: 0.3)),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline,
                                size: 16, color: AppColors.gold),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Asegúrate de que el cliente esté conforme antes de confirmar.',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.ink),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              GradientButton(
                label: 'Confirmar fiado',
                icon: Icons.check_circle_outline,
                onPressed: () => _handleConfirm(context),
              ),
              const SizedBox(height: 8),
              Center(
                child: TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancelar',
                      style: TextStyle(color: AppColors.inkMuted)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}