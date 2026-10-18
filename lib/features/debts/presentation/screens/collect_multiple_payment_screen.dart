import 'package:flutter/material.dart';
import 'package:fiamas_app/core/constants/app_colors.dart';

import '../../domain/debt.dart';

class CollectMultiplePaymentScreen extends StatefulWidget {
  final Map<String, dynamic> customer;
  final List<Debt> selectedDebts;

  const CollectMultiplePaymentScreen({
    super.key,
    required this.customer,
    required this.selectedDebts,
  });

  @override
  State<CollectMultiplePaymentScreen> createState() =>
      _CollectMultiplePaymentScreenState();
}

class _CollectMultiplePaymentScreenState
    extends State<CollectMultiplePaymentScreen> {
  bool _paidAll = true;
  bool _paidPartial = false;
  String _selectedPaymentMethod = 'efectivo';
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _referenceController = TextEditingController();

  late double _totalDebt;

  @override
  void initState() {
    super.initState();
    _totalDebt = widget.selectedDebts.fold(
      0.0,
      (sum, debt) => sum + debt.amount,
    );
    _amountController.text = _totalDebt.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  double get _paidAmount {
    if (_paidAll) return _totalDebt;
    return double.tryParse(_amountController.text) ?? 0.0;
  }

  double get _remainingBalance {
    return _totalDebt - _paidAmount;
  }

  @override
  Widget build(BuildContext context) {
    final customerName = widget.customer['name'] as String? ?? 'Cliente';
    final firstName = customerName.split(' ').first;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(
          'Registrar Cobro',
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
            // MONTO QUE DEBE
            // ═════════════════════════════════════════════════════════════
            Center(
              child: Column(
                children: [
                  Text(
                    'Monto que debe $firstName',
                    style: TextStyle(fontSize: 14, color: AppColors.inkMuted),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'S/ ${_totalDebt.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${widget.selectedDebts.length} fiados seleccionados',
                    style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // ═══════════════════════════════════════════════════════════════
            // OPCIONES: Pagó todo / Pagó una parte
            // ═══════════════════════════════════════════════════════════════
            _buildPaymentOption(
              iconPath: 'assets/icons/bill_icon.png',
              title: 'Pagó todo',
              subtitle: 'Cerrar deuda',
              isSelected: _paidAll,
              onTap: () {
                setState(() {
                  _paidAll = true;
                  _paidPartial = false;
                });
              },
            ),

            const SizedBox(height: 12),

            _buildPaymentOption(
              iconPath: 'assets/icons/bill_icon.png',
              title: 'Pagó una parte',
              subtitle: 'Abonar al saldo',
              isSelected: _paidPartial,
              onTap: () {
                setState(() {
                  _paidAll = false;
                  _paidPartial = true;
                });
              },
            ),

            const SizedBox(height: 24),

            // ═══════════════════════════════════════════════════════════════
            // MONTO ABONADO (SOLO APARECE SI "Pagó una parte" ESTÁ SELECCIONADO)
            // ══════════════════════════════════════════════════════════════
            if (_paidPartial) ...[
              const Text(
                'Monto abonado',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.mist.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.mist),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.account_balance_wallet_outlined,
                      color: AppColors.success,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextField(
                        controller: _amountController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.ink,
                        ),
                        decoration: const InputDecoration(
                          prefixText: 'S/ ',
                          prefixStyle: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: AppColors.ink,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                        ),
                        onChanged: (value) {
                          setState(() {});
                        },
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // ══════════════════════════════════════════════════════════════
            // MEDIO DE PAGO
            // ══════════════════════════════════════════════════════════════
            const Text(
              'Medio de pago',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildPaymentMethodButton(
                  iconPath: 'assets/icons/billete.png',
                  label: 'Efectivo',
                  isSelected: _selectedPaymentMethod == 'efectivo',
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethod = 'efectivo';
                    });
                  },
                ),
                _buildPaymentMethodButton(
                  iconPath: 'assets/icons/yape.png',
                  label: 'Yape',
                  isSelected: _selectedPaymentMethod == 'yape',
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethod = 'yape';
                    });
                  },
                ),
                _buildPaymentMethodButton(
                  iconPath: 'assets/icons/plin.png',
                  label: 'Plin',
                  isSelected: _selectedPaymentMethod == 'plin',
                  onTap: () {
                    setState(() {
                      _selectedPaymentMethod = 'plin';
                    });
                  },
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ═══════════════════════════════════════════════════════════════
            // REFERENCIA (OPCIONAL)
            // ═══════════════════════════════════════════════════════════════
            const Text(
              'Referencia (Opcional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _referenceController,
              decoration: InputDecoration(
                hintText: 'Ej: Transferencia bancaria',
                hintStyle: TextStyle(color: AppColors.inkMuted),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.mist),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.mist),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: AppColors.teal, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // ═══════════════════════════════════════════════════════════════
            // RESUMEN DE DEUDA
            // ═══════════════════════════════════════════════════════════════
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.mist),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total deuda Original:',
                        style: TextStyle(fontSize: 14, color: AppColors.ink),
                      ),
                      Text(
                        'S/ ${_totalDebt.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Saldo Restante ',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                      ),
                      Text(
                        'S/ ${_remainingBalance.toStringAsFixed(2)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.gold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // ═══════════════════════════════════════════════════════════════
            // BOTÓN: Confirmar abono
            // ═══════════════════════════════════════════════════════════════
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  _confirmPayment();
                },
                icon: const Icon(Icons.check, size: 20),
                label: Text(
                  'Confirmar abono S/ ${_paidAmount.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════════
  // WIDGETS CON IMÁGENES
  // ══════════════════════════════════════════════════════════════════════════

  Widget _buildPaymentOption({
    required String iconPath,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.skyBlue.withOpacity(0.5) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.teal : AppColors.mist,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Image.asset(iconPath, width: 48, height: 48, fit: BoxFit.contain),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
                  ),
                ],
              ),
            ),
            Radio<bool>(
              value: true,
              groupValue: isSelected,
              onChanged: (value) {
                if (value != null) onTap();
              },
              activeColor: AppColors.teal,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethodButton({
    required String iconPath,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white,
              border: Border.all(
                color: isSelected ? AppColors.teal : AppColors.mist,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Image.asset(
              iconPath,
              width: 44,
              height: 44,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              color: isSelected ? AppColors.teal : AppColors.inkMuted,
            ),
          ),
        ],
      ),
    );
  }

  void _confirmPayment() {
    if (_paidAmount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El monto debe ser mayor a 0')),
      );
      return;
    }

    if (_paidAmount > _totalDebt) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El monto no puede ser mayor a la deuda total'),
        ),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Cobro registrado'),
        content: Text(
          'Se ha registrado un cobro de S/ ${_paidAmount.toStringAsFixed(2)} de ${widget.selectedDebts.length} fiados mediante $_selectedPaymentMethod.\n\n'
          'Referencia: ${_referenceController.text.isNotEmpty ? _referenceController.text : "Sin referencia"}',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context, true);
            },
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
  }
}
