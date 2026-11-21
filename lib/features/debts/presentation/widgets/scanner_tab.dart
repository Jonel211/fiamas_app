// lib/features/debts/presentation/widgets/scanner_tab.dart
import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/tienda_provider.dart';
import '../../../customers/data/models/cliente_model.dart';
import '../../../inventory/domain/inventory_provider.dart';
import '../../../inventory/domain/product.dart';
import 'scanner_bottom_sheet.dart';
import 'weight_product_bottom_sheet.dart';

class ScannerTab extends StatefulWidget {
  final List<Map<String, dynamic>> cartItems;
  final Function(int, int) onUpdateQuantity;
  final Function(Product) onProductScanned;
  final Function(Map<String, dynamic>)? onAddWithQuantity;
  final ClienteModel cliente;
  final Function(int)? onEditWeightItem;
  final Function(int)? onRemoveItem;

  const ScannerTab({
    super.key,
    required this.cartItems,
    required this.onUpdateQuantity,
    required this.onProductScanned,
    this.onAddWithQuantity,
    required this.cliente,
    this.onEditWeightItem,
    this.onRemoveItem,
  });

  @override
  State<ScannerTab> createState() => _ScannerTabState();
}

class _ScannerTabState extends State<ScannerTab> {
  double _panelHeight = 320;
  bool _isProcessing = false;
  bool _torchOn = false;
  DateTime? _lastScanAt;

  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    formats: [
      BarcodeFormat.ean13,
      BarcodeFormat.ean8,
      BarcodeFormat.code128,
      BarcodeFormat.code39,
      BarcodeFormat.upcA,
      BarcodeFormat.upcE,
      BarcodeFormat.qrCode,
    ],
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _snack(String msg, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), backgroundColor: color, duration: const Duration(seconds: 2)),
    );
  }

  //  FIX AQUÍ: .toString() para evitar el error de Object
  bool _esPorKilo(Product p) {
    final t = (p.tipoVenta?.toString() ?? '').toLowerCase();
    return t.contains('kilo') || t.contains('peso');
  }

  Product? _buscarLocal(String code) {
    final inventory = context.read<InventoryProvider>();
    for (final p in inventory.products) {
      final cb = p.codigoBarras?.trim();
      if (cb == null || cb.isEmpty) continue;
      if (cb == code || cb.contains(code) || code.contains(cb)) return p;
    }
    return null;
  }

  void _procesarProducto(Product product) {
    if (!product.activo) {
      _snack('Este producto está desactivado', Colors.red);
      return;
    }

    if (_esPorKilo(product) && widget.onAddWithQuantity != null) {
      showModalBottomSheet<Map<String, dynamic>>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) => WeightProductBottomSheet(product: product, initialQty: 1),
      ).then((result) {
        if (result != null && result['qty'] > 0) {
          widget.onAddWithQuantity!(result);
          _snack('${product.nombre} agregado', Colors.green);
        }
      });
    } else {
      widget.onProductScanned(product);
      _snack('${product.nombre} agregado', Colors.green);
    }
  }

  Future<void> _handleBarcode(String rawCode) async {
    final now = DateTime.now();
    if (_lastScanAt != null && now.difference(_lastScanAt!).inMilliseconds < 1500) return;
    _lastScanAt = now;

    final code = rawCode.trim();
    if (code.isEmpty) return;

    final local = _buscarLocal(code);
    if (local != null) {
      _procesarProducto(local);
      return;
    }

    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    try {
      final tiendaId = context.read<TiendaProvider>().tiendaSeleccionadaId ??
          context.read<AuthProvider>().user?.tiendaId;
      if (tiendaId == null) return;

      final dio = DioClient.create();
      final response = await dio.get(
        '/productos/barcode/$code',
        queryParameters: {'tienda_id': tiendaId},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final json = (data is Map && data['producto'] is Map) ? data['producto'] : data;

        if (json is Map<String, dynamic>) {
          final product = Product.fromJson(json);
          _procesarProducto(product);
        } else {
          _snack('Producto no encontrado en esta tienda', Colors.red);
        }
      }
    } catch (e) {
      _snack('Producto no encontrado en esta tienda', Colors.red);
    } finally {
      Future.delayed(const Duration(milliseconds: 400), () {
        if (mounted) setState(() => _isProcessing = false);
      });
    }
  }

  Future<void> _toggleTorch() async {
    try {
      await _controller.toggleTorch();
      setState(() => _torchOn = !_torchOn);
    } catch (_) {
      _snack('Este dispositivo no soporta linterna', Colors.orange);
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
                controller: _controller,
                errorBuilder: (context, error) => Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.no_photography_rounded, color: Colors.white54, size: 48),
                      const SizedBox(height: 8),
                      Text(
                        'Error de cámara: ${error.errorCode.name}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                onDetect: (capture) {
                  for (final barcode in capture.barcodes) {
                    final value = barcode.rawValue;
                    if (value != null && value.isNotEmpty) {
                      _handleBarcode(value);
                      break;
                    }
                  }
                },
              ),
              Container(
                width: 280,
                height: 180,
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.teal.withValues(alpha: 0.7), width: 3),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 10,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 12,
                right: 12,
                child: IconButton(
                  onPressed: _toggleTorch,
                  icon: Icon(
                    _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                    color: _torchOn ? AppColors.gold : Colors.white,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.45),
                    minimumSize: const Size(44, 44),
                  ),
                ),
              ),
              if (_isProcessing)
                Positioned(
                  top: 12,
                  left: 12,
                  child: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.45),
                      shape: BoxShape.circle,
                    ),
                    child: const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    ),
                  ),
                ),
              Positioned(
                bottom: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'Coloca el código dentro del marco',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ),
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
            onRemoveItem: widget.onRemoveItem,
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