import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fiamas_app/core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../customers/presentation/providers/cliente_provider.dart';
import '../../../customers/data/models/cliente_model.dart';

class EditCreditLimitBottomSheet extends StatefulWidget {
  final ClienteModel customer;

  const EditCreditLimitBottomSheet({super.key, required this.customer});

  @override
  State<EditCreditLimitBottomSheet> createState() => _EditCreditLimitBottomSheetState();
}

class _EditCreditLimitBottomSheetState extends State<EditCreditLimitBottomSheet> {
  late TextEditingController _controller;
  late double _currentLimit;
  late double _currentDebt;
  bool _isSaving = false;
  final List<double> _suggestions = [200, 500, 800, 1000];

  @override
  void initState() {
    super.initState();
    _currentLimit = widget.customer.vinculacion.limiteCredito;
    _currentDebt = widget.customer.vinculacion.saldoActual;
    _controller = TextEditingController(text: _currentLimit.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _newLimit => double.tryParse(_controller.text.replaceAll('S/', '').trim()) ?? _currentLimit;
  bool get _isValid => _newLimit >= _currentDebt;

  Future<void> _saveChanges() async {
    if (!_isValid) return;
    
    setState(() => _isSaving = true);
    
    final tiendaId = context.read<AuthProvider>().user?.tiendaId;
    if (tiendaId == null) return;

    final success = await context.read<ClienteProvider>().actualizarLimiteCredito(
      widget.customer.id, 
      tiendaId, 
      _newLimit
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      Navigator.pop(context, _newLimit);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al actualizar el límite'), backgroundColor: Colors.red));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24))),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: AppColors.mist, borderRadius: BorderRadius.circular(2)))),
            const SizedBox(height: 20),
            const Text('Editar límite de crédito', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppColors.ink)),
            const SizedBox(height: 4),
            Text(widget.customer.nombreCompleto, style: TextStyle(fontSize: 14, color: AppColors.inkMuted)),
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
            const SizedBox(height: 20),
            
            // ✅ ADVERTENCIA PERMANENTE
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.gold.withOpacity(0.15), 
                borderRadius: BorderRadius.circular(12), 
                border: Border.all(color: AppColors.gold.withOpacity(0.3))
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber_rounded, color: AppColors.gold, size: 24),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'El nuevo límite debe ser mayor o igual al saldo actual pendiente del cliente (S/ ${_currentDebt.toStringAsFixed(2)})', 
                      style: const TextStyle(fontSize: 12, color: AppColors.ink, height: 1.3)
                    )
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: (_isValid && !_isSaving) ? _saveChanges : null,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  disabledBackgroundColor: AppColors.teal.withOpacity(0.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: _isSaving 
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                    : const Text('Guardar cambios', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: _isSaving ? null : () => Navigator.pop(context),
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