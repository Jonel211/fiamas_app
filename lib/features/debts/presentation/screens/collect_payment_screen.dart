import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../domain/debt.dart';

class CollectPaymentScreen extends StatefulWidget {
  const CollectPaymentScreen({super.key, required this.debt});

  final Debt debt;

  @override
  State<CollectPaymentScreen> createState() => _CollectPaymentScreenState();
}

enum _PaymentType { total, parcial }

class _CollectPaymentScreenState extends State<CollectPaymentScreen> {
  _PaymentType _paymentType = _PaymentType.total;
  final _partialController = TextEditingController();

  @override
  void dispose() {
    _partialController.dispose();
    super.dispose();
  }

  String get _firstName => widget.debt.customerName.split(' ').first;

  void _handleConfirm() {
    // TODO: conectar con DebtsRepository.registerPayment()
    Navigator.of(context).pop();
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
                  Text('Registrar Cobro',
                      style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
              const SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    Text('Monto que debe $_firstName',
                        style: const TextStyle(
                            fontSize: 13, color: AppColors.inkMuted)),
                    const SizedBox(height: 6),
                    Text(
                      'S/ ${widget.debt.amount.toStringAsFixed(2)}',
                      style: const TextStyle(
                          fontSize: 34,
                          fontWeight: FontWeight.w800,
                          color: AppColors.ink),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              _PaymentOptionCard(
                icon: Icons.check_circle_outline,
                title: 'Pagó todo',
                subtitle: 'CERRAR DEUDA',
                selected: _paymentType == _PaymentType.total,
                onTap: () => setState(() => _paymentType = _PaymentType.total),
              ),
              const SizedBox(height: 12),
              _PaymentOptionCard(
                icon: Icons.calculate_outlined,
                title: 'Pagó una parte',
                subtitle: 'ABONAR AL SALDO',
                selected: _paymentType == _PaymentType.parcial,
                onTap: () => setState(() => _paymentType = _PaymentType.parcial),
              ),
              if (_paymentType == _PaymentType.parcial) ...[
                const SizedBox(height: 16),
                LabeledField(
                  label: 'Monto abonado',
                  hint: 'S/ 0.00',
                  icon: Icons.payments_outlined,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  controller: _partialController,
                ),
              ],
              const Spacer(),
              GradientButton(
                label: 'Confirmar cobro',
                icon: Icons.check,
                onPressed: _handleConfirm,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PaymentOptionCard extends StatelessWidget {
  const _PaymentOptionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        decoration: BoxDecoration(
          color: selected ? AppColors.teal.withValues(alpha: 0.08) : AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? AppColors.teal : AppColors.mist,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: selected ? AppColors.teal : AppColors.mist,
                shape: BoxShape.circle,
              ),
              child: Icon(icon,
                  size: 18, color: selected ? Colors.white : AppColors.inkMuted),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.ink)),
                  Text(subtitle,
                      style: const TextStyle(
                          fontSize: 10,
                          letterSpacing: 0.4,
                          color: AppColors.inkMuted)),
                ],
              ),
            ),
            if (selected)
              const Icon(Icons.check_circle, size: 20, color: AppColors.teal),
          ],
        ),
      ),
    );
  }
}