import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/constants/app_colors.dart';
import 'scanner_bottom_sheet.dart';

class ScannerTab extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(int, int) onUpdateQuantity;

  const ScannerTab({super.key, required this.cartItems, required this.onUpdateQuantity});

  @override
  State<ScannerTab> createState() => _ScannerTabState();
}

class _ScannerTabState extends State<ScannerTab> {
  double _panelHeight = 320;
  final double _minHeight = 200;
  final double _maxHeight = 500;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // CÁMARA (Se adapta al espacio restante)
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              MobileScanner(
                onDetect: (capture) {
                  for (final barcode in capture.barcodes) {
                    if (barcode.rawValue != null) debugPrint('Escaneado: ${barcode.rawValue}');
                  }
                },
              ),
              Container(
                width: 260,
                height: 260,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.teal.withOpacity(0.6), width: 2),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [Container(height: 2, color: AppColors.teal)],
                ),
              ),
            ],
          ),
        ),
        // PANEL DESLIZABLE
        AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          height: _panelHeight,
          child: ScannerBottomSheet(
            cartItems: widget.cartItems,
            onUpdateQuantity: widget.onUpdateQuantity,
            onDrag: (deltaY) {
              setState(() {
                _panelHeight -= deltaY;
                if (_panelHeight < _minHeight) _panelHeight = _minHeight;
                if (_panelHeight > _maxHeight) _panelHeight = _maxHeight;
              });
            },
          ),
        ),
      ],
    );
  }
}