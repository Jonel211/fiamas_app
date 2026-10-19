import 'package:flutter/material.dart';
import 'package:fiamas_app/core/constants/app_colors.dart';

class EditCreditLimitBottomSheet extends StatefulWidget {
  final Map<String, dynamic> customer;

  const EditCreditLimitBottomSheet({super.key, required this.customer});

  @override
  State<EditCreditLimitBottomSheet> createState() =>
      _EditCreditLimitBottomSheetState();
}

class _EditCreditLimitBottomSheetState extends State<EditCreditLimitBottomSheet> {
  late TextEditingController _controller;
  late double _currentLimit;
  late double _currentDebt;
  final List<double> _suggestions = [200, 500, 800, 1000];

  @override
  void initState() {
    super.initState();
    _currentLimit = (widget.customer['creditLimit'] as num?)?.toDouble() ?? 500.0;
    _currentDebt = (widget.customer['debt'] as num?)?.toDouble() ?? 0.0;
    _controller = TextEditingController(text: _currentLimit.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _newLimit => double.tryParse(_controller.text.replaceAll('S/', '').trim()) ?? _currentLimit;
  bool get _isValid => _newLimit >= _currentDebt;

  void _saveChanges() {
    if (!_isValid) return;
    Navigator.pop(context, _newLimit);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Límite actualizado a S/ ${_newLimit.toStringAsFixed(2)}'),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final customerName = widget.customer['name'] as String? ?? 'Cliente';

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40, height: 4,
                decoration: BoxDecoration(color: AppColors.mist, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 20),
            const Text('Editar límite de crédito', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.ink)),
            const SizedBox(height: 4),
            Text(customerName, style: TextStyle(fontSize: 14, color: AppColors.inkMuted)),
            const SizedBox(height: 24),
            const Text('Límite actual', style: TextStyle(fontSize: 12, color: AppColors.inkMuted)),
            const SizedBox(height: 4),
            Text('S/ ${_currentLimit.toStringAsFixed(2)}', style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppColors.ink)),
            const SizedBox(height: 20),
            const Text('Nuevo límite', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppColors.ink)),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(color: AppColors.background, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.mist)),
              child: Row(
                children: [
                  const Text('S/ ', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.teal)),
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.ink),
                      decoration: const InputDecoration(border: InputBorder.none, contentPadding: EdgeInsets.zero, isDense: true),
                      onChanged: (value) => setState(() {}),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            const Text('Toca el número para escribir un nuevo límite', style: TextStyle(fontSize: 12, color: AppColors.inkMuted)),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: _suggestions.map((amount) {
                  final isSelected = _newLimit == amount;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _controller.text = amount.toStringAsFixed(2)),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.teal.withOpacity(0.1) : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: isSelected ? AppColors.teal : AppColors.mist, width: isSelected ? 2 : 1),
                        ),
                        child: Text('S/${amount.toInt()}', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: isSelected ? AppColors.teal : AppColors.ink)),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 16),
            if (!_isValid)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.gold.withOpacity(0.15), borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.gold.withOpacity(0.3))),
                child: Row(
                  children: [
                    const Icon(Icons.warning_amber_rounded, color: AppColors.gold, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text('El nuevo límite debe ser mayor o igual al saldo actual (S/ ${_currentDebt.toStringAsFixed(2)})', style: const TextStyle(fontSize: 12, color: AppColors.ink)),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isValid ? _saveChanges : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.teal.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Guardar cambios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.inkMuted,
                  side: const BorderSide(color: AppColors.mist),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cancelar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}