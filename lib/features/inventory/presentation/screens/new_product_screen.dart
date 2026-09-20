import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/labeled_dropdown_field.dart';
import '../../../../core/widgets/labeled_field.dart';

class NewProductScreen extends StatefulWidget {
  const NewProductScreen({super.key});

  @override
  State<NewProductScreen> createState() => _NewProductScreenState();
}

class _NewProductScreenState extends State<NewProductScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _priceController = TextEditingController();
  String? _category;

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
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: conectar con InventoryRepository.createProduct()
      Navigator.of(context).pop();
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
              // 1. Botón para regresar (alineado a la izquierda)
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: AppColors.ink),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.mist,
                    shape: const CircleBorder(),
                    padding: const EdgeInsets.all(10),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 2. Encabezado centrado, AFUERA de la tarjeta blanca
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
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppColors.inkMuted,
                    ),
              ),
              const SizedBox(height: 24),

              // 3. Tarjeta blanca con el formulario
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
                      // Selector de foto + etiqueta con borde redondeado
                      Center(
                        child: GestureDetector(
                          onTap: () {
                            // TODO: abrir selector de imagen / cámara
                          },
                          child: Column(
                            children: [
                              Stack(
                                clipBehavior: Clip.none,
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
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 28,
                                      height: 28,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: AppColors.ink,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.surface,
                                          width: 2,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.camera_alt_outlined,
                                        color: Colors.white,
                                        size: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              // Etiqueta con borde redondeado tipo "pill"
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
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: AppColors.ink,
                                        fontWeight: FontWeight.w600,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 28),

                      // Campos de entrada
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
                        onChanged: (value) =>
                            setState(() => _category = value),
                        validator: (v) =>
                            v == null ? 'Selecciona una categoría' : null,
                      ),
                      const SizedBox(height: 16),
                      LabeledField(
                        label: 'Precio de venta',
                        hint: 'S/ 0.00',
                        icon: Icons.sell_outlined,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
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
                      const SizedBox(height: 28),

                      // Botón principal
                      GradientButton(
                        label: 'Guardar producto',
                        icon: Icons.check_circle_outline,
                        onPressed: _handleSave,
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