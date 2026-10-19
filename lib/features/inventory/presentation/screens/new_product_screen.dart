import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../../domain/sale_unit.dart';
import '../widgets/active_switch_row.dart';
import '../widgets/barcode_field.dart';
import '../widgets/price_field.dart';
import '../widgets/product_input_style.dart';
import '../widgets/product_photo_picker.dart';
import '../widgets/sale_unit_selector.dart';

/// Registro de un producto. Una sola pantalla: al cambiar "Se vende por"
/// entre Unidad y Kilo, cambian los campos (el código de barras solo aplica
/// a los productos por unidad).
class NewProductScreen extends StatefulWidget {
  const NewProductScreen({super.key});

  @override
  State<NewProductScreen> createState() => _NewProductScreenState();
}

class _NewProductScreenState extends State<NewProductScreen> {
  // TODO: traer las categorías reales del módulo de categorías.
  static const _categories = ['Bebidas', 'Snacks', 'Panadería', 'Abarrotes', 'Limpieza', 'Otros'];

  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _barcode = TextEditingController();
  final _price = TextEditingController();

  String? _category;
  SaleUnit _unit = SaleUnit.unit;
  bool _active = true;

  bool get _byUnit => _unit == SaleUnit.unit;

  @override
  void dispose() {
    for (final c in [_name, _description, _barcode, _price]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // TODO: conectar con InventoryRepository.createProduct()
    // (el código de barras solo se envía si _byUnit).
    Navigator.of(context).pop();
  }

  void _scanBarcode() {
    // TODO: abrir el escáner de la cámara (lib/core/hardware) y llenar _barcode.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('El escáner estará disponible pronto')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(children: [
        const SimpleAppBar(title: 'Nuevo Producto'),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 32 + MediaQuery.of(context).padding.bottom),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                const Text('Agrega un artículo a tu lista',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.ink)),
                const SizedBox(height: 16),
                ProductPhotoPicker(onTap: () {
                  // TODO: abrir selector de imagen / cámara
                }),
                const SizedBox(height: 24),

                const ProductFieldLabel('Nombre del producto'),
                TextFormField(
                  controller: _name,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: productInputDecoration(),
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa el nombre del producto' : null,
                ),
                const SizedBox(height: 20),

                const ProductFieldLabel('Elegir categoría'),
                DropdownButtonFormField<String>(
                  initialValue: _category,
                  icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.inkMuted),
                  decoration: productInputDecoration(hint: 'Selecciona una categoría'),
                  items: [for (final c in _categories) DropdownMenuItem(value: c, child: Text(c))],
                  onChanged: (v) => setState(() => _category = v),
                  validator: (v) => v == null ? 'Selecciona una categoría' : null,
                ),
                const SizedBox(height: 20),

                const ProductFieldLabel('Se vende por'),
                SaleUnitSelector(selected: _unit, onChanged: (u) => setState(() => _unit = u)),
                const SizedBox(height: 20),

                const ProductFieldLabel('Descripción (Opcional)'),
                TextFormField(
                  controller: _description,
                  minLines: 3,
                  maxLines: 3,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: productInputDecoration(),
                ),
                const SizedBox(height: 20),

                // Solo para productos por unidad
                AnimatedSize(
                  duration: const Duration(milliseconds: 200),
                  alignment: Alignment.topCenter,
                  child: _byUnit
                      ? Column(children: [
                          BarcodeField(controller: _barcode, onScan: _scanBarcode),
                          const SizedBox(height: 20),
                        ])
                      : const SizedBox(width: double.infinity),
                ),

                PriceField(controller: _price, perKilo: !_byUnit),
                const SizedBox(height: 24),

                ActiveSwitchRow(value: _active, onChanged: (v) => setState(() => _active = v)),
                const SizedBox(height: 16),

                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(52),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Guardar producto'),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}