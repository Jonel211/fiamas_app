import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../inventory/domain/product.dart';

class WeightProductBottomSheet extends StatefulWidget {
  final Product product;

  const WeightProductBottomSheet({super.key, required this.product});

  @override
  State<WeightProductBottomSheet> createState() => _WeightProductBottomSheetState();
}

class _WeightProductBottomSheetState extends State<WeightProductBottomSheet> {
  final TextEditingController _qtyController = TextEditingController(text: '1.00');

  @override
  void initState() {
    super.initState();
    _qtyController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  double get _subtotal {
    double qty = double.tryParse(_qtyController.text) ?? 0;
    return qty * widget.product.precioVenta;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 40, height: 4,
              decoration: BoxDecoration(color: AppColors.mist, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.product.nombre,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'S/ ${widget.product.precioVenta.toStringAsFixed(2)} por kg',
                    style: const TextStyle(fontSize: 13, color: AppColors.inkMuted),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded, color: AppColors.inkMuted),
                style: IconButton.styleFrom(backgroundColor: AppColors.mist.withValues(alpha: 0.4), padding: const EdgeInsets.all(6)),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildQtyButton(
                icon: Icons.remove,
                onTap: () {
                  double val = double.tryParse(_qtyController.text) ?? 0;
                  if (val > 0.25) _qtyController.text = (val - 0.25).toStringAsFixed(2);
                },
              ),
              const SizedBox(width: 12),
              Container(
                width: 140,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(color: AppColors.ivory, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.mist)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 70,
                      child: TextField(
                        controller: _qtyController,
                        textAlign: TextAlign.center,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.ink),
                        decoration: const InputDecoration(isDense: true, border: InputBorder.none, contentPadding: EdgeInsets.zero),
                      ),
                    ),
                    const Text('kg', style: TextStyle(fontSize: 14, color: AppColors.inkMuted)),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildQtyButton(
                icon: Icons.add,
                onTap: () {
                  double val = double.tryParse(_qtyController.text) ?? 0;
                  _qtyController.text = (val + 0.25).toStringAsFixed(2);
                },
                isSolid: true,
              ),
            ],
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 8,
            children: [
              _buildWeightChip('0.25 kg'),
              _buildWeightChip('0.5 kg'),
              _buildWeightChip('1 kg'),
              _buildWeightChip('2 kg'),
            ],
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              const Text('Subtotal', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppColors.ink)),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text('S/ ${_subtotal.toStringAsFixed(2)}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink)),
                  Text('${_qtyController.text} kg x S/ ${widget.product.precioVenta.toStringAsFixed(2)}', style: const TextStyle(fontSize: 11, color: AppColors.inkMuted)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context, {
                'producto_id': widget.product.id,
                'name': widget.product.nombre,
                'price': widget.product.precioVenta,
                'qty': double.tryParse(_qtyController.text) ?? 1.0,
                'imagenUrl': widget.product.imagenUrl, // <-- UNICA LINEA AGREGADA
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal, foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 0,
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Agregar a la orden', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward_rounded, size: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQtyButton({required IconData icon, required VoidCallback onTap, bool isSolid = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSolid ? AppColors.teal : AppColors.ivory,
          shape: BoxShape.circle,
          border: isSolid ? null : Border.all(color: AppColors.mist),
        ),
        child: Icon(icon, color: isSolid ? Colors.white : AppColors.ink, size: 20),
      ),
    );
  }

  Widget _buildWeightChip(String label) {
    return ActionChip(
      label: Text(label),
      labelStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.ink),
      backgroundColor: AppColors.ivory,
      side: const BorderSide(color: AppColors.mist),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      onPressed: () => _qtyController.text = label.replaceAll(' kg', ''),
    );
  }
}