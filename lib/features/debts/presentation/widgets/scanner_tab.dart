// lib/features/debts/presentation/widgets/scanner_tab.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/tienda_provider.dart';
import '../../../customers/data/models/cliente_model.dart';
import '../../../inventory/domain/product.dart';
import 'scanner_bottom_sheet.dart';
import 'package:provider/provider.dart';

class ScannerTab extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(int, int) onUpdateQuantity;
  final Function(Product) onProductScanned;
  final ClienteModel cliente; 
  final Function(int)? onEditWeightItem; 
  final Function(int)? onRemoveItem; // NUEVO

  const ScannerTab({
    super.key, 
    required this.cartItems, 
    required this.onUpdateQuantity,
    required this.onProductScanned,
    required this.cliente, 
    this.onEditWeightItem, 
    this.onRemoveItem, // NUEVO
  });

  @override
  State<ScannerTab> createState() => _ScannerTabState();
}

class _ScannerTabState extends State<ScannerTab> {
  double _panelHeight = 320;
  bool _isProcessing = false;

  Future<void> _handleBarcode(String code) async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    final tiendaId = context.read<TiendaProvider>().tiendaSeleccionadaId ??
        context.read<AuthProvider>().user?.tiendaId;
    if (tiendaId == null) return;

    try {
      final dio = DioClient.create();
      final response = await dio.get('/productos/barcode/$code?tienda_id=$tiendaId');
      
      if (response.statusCode == 200) {
        final product = Product.fromJson(response.data);
        if (!product.activo) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Este producto está desactivado'),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          widget.onProductScanned(product);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${product.nombre} agregado'), backgroundColor: Colors.green, duration: const Duration(seconds: 1)),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Producto no encontrado en esta tienda'), backgroundColor: Colors.red),
        );
      }
    } finally {
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              MobileScanner(
                onDetect: (capture) {
                  for (final barcode in capture.barcodes) {
                    if (barcode.rawValue != null) {
                      _handleBarcode(barcode.rawValue!);
                      break; 
                    }
                  }
                },
              ),
              Container(
                width: 280, 
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.teal.withOpacity(0.7), width: 3),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    )
                  ]
                ),
              ),
              if (_isProcessing)
                Container(
                  color: Colors.black54,
                  child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                )
            ],
          ),
        ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 50),
          height: _panelHeight,
          child: ScannerBottomSheet(
            cartItems: widget.cartItems,
            onUpdateQuantity: widget.onUpdateQuantity,
            cliente: widget.cliente,
            onEditWeightItem: widget.onEditWeightItem,
            onRemoveItem: widget.onRemoveItem, // SE PASA LA FUNCION
            onDrag: (deltaY) {
              setState(() {
                _panelHeight -= deltaY;
                if (_panelHeight < 200) _panelHeight = 200;
                if (_panelHeight > 500) _panelHeight = 500;
              });
            },
          ),
        ),
      ],
    );
  }
}