import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/debt.dart';
import '../widgets/order_item_row.dart';
import 'new_debt_review_screen.dart';

class NewDebtScanScreen extends StatefulWidget {
  const NewDebtScanScreen({super.key});

  @override
  State<NewDebtScanScreen> createState() => _NewDebtScanScreenState();
}

class _NewDebtScanScreenState extends State<NewDebtScanScreen> {
  bool _scanMode = true;
  String? _lastAddedLabel = 'Agua San Mateo 1L';

  // TODO: reemplazar por datos reales del escaneo / búsqueda de productos
  final List<DebtItem> _items = [
    const DebtItem(productName: 'Agua San Mateo 1L', quantity: 1, unitPrice: 2.50),
    const DebtItem(productName: 'Pan Unión', quantity: 2, unitPrice: 6.50),
  ];

  double get _total => _items.fold(0.0, (sum, item) => sum + item.subtotal);

  void _updateQuantity(int index, int delta) {
    setState(() {
      final item = _items[index];
      final newQty = item.quantity + delta;
      if (newQty <= 0) {
        _items.removeAt(index);
      } else {
        _items[index] = DebtItem(
          productName: item.productName,
          quantity: newQty,
          unitPrice: item.unitPrice,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Barra superior: cerrar + flash
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _DarkIconButton(
                    icon: Icons.close,
                    onTap: () => Navigator.of(context).pop(),
                  ),
                  _DarkIconButton(
                    icon: Icons.flash_on_outlined,
                    onTap: () {
                      // TODO: alternar flash de la cámara
                    },
                  ),
                ],
              ),
            ),

            // Selector Escanear / Productos
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _ScanModeTab(
                        label: 'Escanear',
                        selected: _scanMode,
                        onTap: () => setState(() => _scanMode = true),
                      ),
                    ),
                    Expanded(
                      child: _ScanModeTab(
                        label: 'Productos',
                        selected: !_scanMode,
                        onTap: () => setState(() => _scanMode = false),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Visor de escaneo (placeholder, sin cámara real)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 240,
                      height: 200,
                      decoration: BoxDecoration(
                        border: Border.all(
                            color: AppColors.teal.withValues(alpha: 0.8), width: 2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Center(
                        child: Icon(Icons.qr_code_scanner,
                            color: Colors.white24, size: 48),
                      ),
                    ),
                    if (_lastAddedLabel != null) ...[
                      const SizedBox(height: 20),
                      Container(
                        padding:
                            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: AppColors.teal,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.check_circle,
                                color: Colors.white, size: 16),
                            const SizedBox(width: 8),
                            Text('Agregado: $_lastAddedLabel',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600)),
                            const SizedBox(width: 10),
                            GestureDetector(
                              onTap: () => setState(() => _lastAddedLabel = null),
                              child: const Icon(Icons.close,
                                  color: Colors.white70, size: 14),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Hoja inferior con la orden actual
            Container(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              decoration: const BoxDecoration(
                color: AppColors.surface,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text('Productos en la orden',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                          color: AppColors.ink)),
                  const SizedBox(height: 4),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 160),
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (int i = 0; i < _items.length; i++)
                          OrderItemRow(
                            item: _items[i],
                            onIncrement: () => _updateQuantity(i, 1),
                            onDecrement: () => _updateQuantity(i, -1),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${_items.length} productos',
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.inkMuted),
                        ),
                      ),
                      Text('S/ ${_total.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.ink)),
                      const SizedBox(width: 12),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          minimumSize: const Size(0, 40),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                        ),
                        onPressed: _items.isEmpty
                            ? null
                            : () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        NewDebtReviewScreen(items: _items),
                                  ),
                                ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: const [
                            Text('Revisar orden'),
                            SizedBox(width: 4),
                            Icon(Icons.arrow_forward, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DarkIconButton extends StatelessWidget {
  const _DarkIconButton({required this.icon, required this.onTap});

  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
    );
  }
}

class _ScanModeTab extends StatelessWidget {
  const _ScanModeTab({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? AppColors.ink : Colors.white70,
          ),
        ),
      ),
    );
  }
}