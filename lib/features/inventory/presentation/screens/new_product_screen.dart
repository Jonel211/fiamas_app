import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../../domain/product.dart';
import '../../domain/sale_unit.dart';
import '../../domain/inventory_provider.dart';
import '../../domain/category.dart';
import '../widgets/active_switch_row.dart';
import '../widgets/barcode_field.dart';
import '../widgets/price_field.dart';
import '../widgets/product_input_style.dart';
import '../widgets/product_photo_picker.dart';
import '../widgets/sale_unit_selector.dart';

class NewProductScreen extends StatefulWidget {
  const NewProductScreen({super.key, this.product});

  final Product? product;
  bool get isEditing => product != null;

  @override
  State<NewProductScreen> createState() => _NewProductScreenState();
}

class _NewProductScreenState extends State<NewProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();
  final _barcode = TextEditingController();
  final _price = TextEditingController();

  String? _categoriaId;
  SaleUnit _unit = SaleUnit.unit;
  bool _active = true;

  bool get _byUnit => _unit == SaleUnit.unit;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().loadCategories();
    });

    if (widget.isEditing) {
      _name.text = widget.product!.nombre;
      _description.text = widget.product!.descripcion ?? '';
      _barcode.text = widget.product!.codigoBarras ?? '';
      _price.text = widget.product!.precioVenta.toStringAsFixed(2);
      _categoriaId = widget.product!.categoriaId;
      _unit = widget.product!.tipoVenta;
      _active = widget.product!.activo;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _barcode.dispose();
    _price.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final provider = context.read<InventoryProvider>();
    // TODO: Obtener el tienda_id real del usuario logueado (AuthProvider/TiendaProvider)
    const tiendaId = 'TIENDA_ID_TEMP';

    final newProduct = Product(
      id: widget.product?.id ?? '',
      tiendaId: tiendaId,
      categoriaId: _categoriaId ?? '',
      nombre: _name.text.trim(),
      descripcion: _description.text.trim().isEmpty
          ? null
          : _description.text.trim(),
      codigoBarras: _barcode.text.trim().isEmpty ? null : _barcode.text.trim(),
      tipoVenta: _unit,
      unidadMedida: _byUnit ? 'unidad' : 'kg',
      precioVenta: double.tryParse(_price.text.replaceAll(',', '.')) ?? 0.0,
      activo: _active,
      // TODO: Conectar con la lógica de subida de imagen real
      imagenUrl: widget.product?.imagenUrl,
    );

    if (widget.isEditing) {
      provider.updateProduct(widget.product!.id, newProduct);
    } else {
      provider.createProduct(newProduct);
    }

    if (mounted) Navigator.of(context).pop();
  }

  void _scanBarcode() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('El escáner estará disponible pronto')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        children: [
          SimpleAppBar(
            title: widget.isEditing ? 'Editar Producto' : 'Nuevo Producto',
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                24,
                20,
                24,
                32 + MediaQuery.of(context).padding.bottom,
              ),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      widget.isEditing
                          ? 'Modifica los datos del artículo'
                          : 'Agrega un artículo a tu lista',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ProductPhotoPicker(
                      onTap: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Selector de imagen próximamente'),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 24),

                    const ProductFieldLabel('Nombre del producto'),
                    TextFormField(
                      controller: _name,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: productInputDecoration(),
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Ingresa el nombre del producto'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    const ProductFieldLabel('Elegir categoría'),
                    Consumer<InventoryProvider>(
                      builder: (context, provider, child) {
                        final categories = provider.categories;
                        return DropdownButtonFormField<String>(
                          initialValue: _categoriaId,
                          icon: const Icon(
                            Icons.keyboard_arrow_down,
                            color: AppColors.inkMuted,
                          ),
                          decoration: productInputDecoration(
                            hint: 'Selecciona una categoría',
                          ),
                          items: categories.map((Category c) {
                            return DropdownMenuItem(
                              value: c.id,
                              child: Text(c.nombre),
                            );
                          }).toList(),
                          onChanged: (v) => setState(() => _categoriaId = v),
                          validator: (v) =>
                              v == null ? 'Selecciona una categoría' : null,
                        );
                      },
                    ),
                    const SizedBox(height: 20),

                    const ProductFieldLabel('Se vende por'),
                    SaleUnitSelector(
                      selected: _unit,
                      onChanged: (u) => setState(() => _unit = u),
                    ),
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

                    AnimatedSize(
                      duration: const Duration(milliseconds: 200),
                      alignment: Alignment.topCenter,
                      child: _byUnit
                          ? Column(
                              children: [
                                BarcodeField(
                                  controller: _barcode,
                                  onScan: _scanBarcode,
                                ),
                                const SizedBox(height: 20),
                              ],
                            )
                          : const SizedBox(width: double.infinity),
                    ),

                    PriceField(controller: _price, perKilo: !_byUnit),
                    const SizedBox(height: 24),

                    ActiveSwitchRow(
                      value: _active,
                      onChanged: (v) => setState(() => _active = v),
                    ),
                    const SizedBox(height: 16),

                    ElevatedButton(
                      onPressed: _save,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        minimumSize: const Size.fromHeight(52),
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: Text(
                        widget.isEditing
                            ? 'Guardar cambios'
                            : 'Guardar producto',
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
