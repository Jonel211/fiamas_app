import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/session_service.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/labeled_dropdown_field.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../data/producto_repository.dart';

class NewProductScreen extends StatefulWidget {
  const NewProductScreen({super.key});

  @override
  State<NewProductScreen> createState() => _NewProductScreenState();
}

class _NewProductScreenState extends State<NewProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  final _stockController = TextEditingController();

  final _repository = ProductoRepository();
  String? _category;
  bool _isLoading = false;

  static const _categories = [
    'Bebidas',
    'Snacks',
    'Panadería',
    'Abarrotes',
    'Limpieza',
    'Otros',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _priceController.dispose();
    _stockController.dispose();
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // Verificar que hay una tienda seleccionada
    final tienda = await SessionService.getTiendaActual();
    if (tienda == null) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay tienda seleccionada'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final result = await _repository.crearProducto(
      tiendaId: tienda['id']!,
      nombre: _nameController.text.trim(),
      precioVenta: double.parse(_priceController.text.trim()),
      stockActual: int.tryParse(_stockController.text.trim()) ?? 0,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Producto agregado exitosamente!'),
          backgroundColor: Color(0xFF0E7C7B),
        ),
      );
      Navigator.of(context).pop(true); // devolver true para recargar
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Error al guardar producto'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: _isLoading
                      ? null
                      : () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: AppColors.ink),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.mist,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Nuevo Producto',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Agrega un artículo a tu lista',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.inkMuted),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.mist),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.03),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ... (todo el bloque del selector de imagen queda igual) ...
                      Center(
                        child: Column(
                          children: [
                            Container(
                              width: 84,
                              height: 84,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: AppColors.mist,
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppColors.ink.withOpacity(0.08),
                                  width: 1.5,
                                ),
                              ),
                              child: const Icon(
                                Icons.inventory_2_outlined,
                                color: AppColors.inkMuted,
                                size: 34,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.ivory,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: AppColors.mist),
                              ),
                              child: Text(
                                'Añadir imagen de producto',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(
                                      color: AppColors.ink,
                                      fontWeight: FontWeight.w600,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      LabeledField(
                        label: 'Nombre del producto',
                        hint: 'Ej: Arroz Costeño 1kg',
                        icon: Icons.inventory_2_outlined,
                        controller: _nameController,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Ingresa el nombre del producto'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      LabeledDropdownField(
                        label: 'Categoría',
                        hint: 'Selecciona una categoría',
                        icon: Icons.category_outlined,
                        items: _categories,
                        value: _category,
                        onChanged: (value) => setState(() => _category = value),
                        validator: (v) =>
                            v == null ? 'Selecciona una categoría' : null,
                      ),
                      const SizedBox(height: 16),

                      LabeledField(
                        label: 'Precio de venta',
                        hint: 'S/ 0.00',
                        icon: Icons.sell_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        controller: _priceController,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Ingresa el precio de venta';
                          }
                          if (double.tryParse(v) == null) {
                            return 'Ingresa un precio válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      LabeledField(
                        label: 'Stock inicial',
                        hint: 'Ej: 10',
                        icon: Icons.numbers_outlined,
                        keyboardType: TextInputType.number,
                        controller: _stockController,
                        validator: (v) {
                          if (v == null || v.isEmpty) return null;
                          if (int.tryParse(v) == null) {
                            return 'Ingresa un número válido';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      GradientButton(
                        label: _isLoading ? 'Guardando...' : 'Guardar producto',
                        icon: Icons.check_circle_outline,
                        onPressed: _isLoading ? null : _handleSave,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}
