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

/// Registro y edición de un producto. Una sola pantalla: al cambiar "Se vende por"
/// entre Unidad y Kilo, cambian los campos (el código de barras solo aplica
/// a los productos por unidad).
class NewProductScreen extends StatefulWidget {
  const NewProductScreen({
    super.key,
    this.initialName,
    this.initialCategory,
    this.initialPrice,
    this.initialDescription,
    this.initialBarcode,
    this.initialUnit,
    this.isEditing = false,
  });

  final String? initialName;
  final String? initialCategory;
  final double? initialPrice;
  final String? initialDescription;
  final String? initialBarcode;
  final SaleUnit? initialUnit;
  final bool isEditing;

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
  void initState() {
    super.initState();
    if (widget.isEditing || widget.initialName != null) {
      _name.text = widget.initialName ?? '';
      _description.text = widget.initialDescription ?? '';
      _barcode.text = widget.initialBarcode ?? '';
      if (widget.initialPrice != null) {
        _price.text = widget.initialPrice!.toStringAsFixed(2);
      }
      _category = widget.initialCategory;
      if (widget.initialUnit != null) {
        _unit = widget.initialUnit!;
      }
    }
  }

  @override
  void dispose() {
    for (final c in [_name, _description, _barcode, _price]) {
      c.dispose();
    }
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // Retorna los datos guardados o editados a la pantalla anterior
    Navigator.of(context).pop({
      'name': _name.text.trim(),
      'category': _category,
      'price': double.tryParse(_price.text.replaceAll(',', '.')) ?? 0.0,
      'description': _description.text.trim(),
      'barcode': _barcode.text.trim(),
      'unit': _unit,
      'active': _active,
    });
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
        SimpleAppBar(title: widget.isEditing ? 'Editar Producto' : 'Nuevo Producto'),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 20, 24, 32 + MediaQuery.of(context).padding.bottom),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                Text(
                  widget.isEditing ? 'Modifica los datos del artículo' : 'Agrega un artículo a tu lista',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500, color: AppColors.ink),
                ),
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
                  child: Text(widget.isEditing ? 'Guardar cambios' : 'Guardar producto'),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}