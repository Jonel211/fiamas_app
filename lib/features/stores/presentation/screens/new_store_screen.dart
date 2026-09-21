import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../data/tienda_repository.dart'; // 👈 NUEVO

class NewStoreScreen extends StatefulWidget {
  const NewStoreScreen({super.key});

  @override
  State<NewStoreScreen> createState() => _NewStoreScreenState();
}

class _NewStoreScreenState extends State<NewStoreScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _rucController = TextEditingController();

  final _repository = TiendaRepository(); // 👈 NUEVO
  bool _isLoading = false; // 👈 NUEVO

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _rucController.dispose();
    super.dispose();
  }

  // 👇 CAMBIADO: ahora es async y conecta con el backend
  Future<void> _handleCreate() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    final result = await _repository.crearTienda(
      nombre: _nameController.text.trim(),
      direccion: _addressController.text.trim().isEmpty
          ? null
          : _addressController.text.trim(),
      ruc: _rucController.text.trim().isEmpty
          ? null
          : _rucController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      // ✅ Éxito
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Tienda creada exitosamente!'),
          backgroundColor: Color(0xFF0E7C7B),
          duration: Duration(seconds: 2),
        ),
      );

      // Devolver true para que MyStoresScreen recargue la lista
      Navigator.of(context).pop(true);
    } else {
      // ❌ Error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Error al crear la tienda'),
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
              // 1. Botón para regresar
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

              // 2. Encabezado
              Text(
                'Nueva Tienda',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Cuéntanos un poco sobre tu negocio',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: AppColors.inkMuted),
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
                      // Selector de foto
                      Center(
                        child: GestureDetector(
                          onTap: _isLoading
                              ? null
                              : () {
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
                                      Icons.storefront_outlined,
                                      color: AppColors.inkMuted,
                                      size: 36,
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
                                  'Añadir foto de tienda',
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
                      ),
                      const SizedBox(height: 28),

                      // Nombre
                      LabeledField(
                        label: 'Nombre de la tienda',
                        hint: 'Ej: Bodega Doña María',
                        icon: Icons.storefront_outlined,
                        controller: _nameController,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Ingresa el nombre de tu tienda'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Dirección
                      LabeledField(
                        label: 'Dirección / Ubicación',
                        hint: 'Calle, Distrito, Ciudad',
                        icon: Icons.location_on_outlined,
                        controller: _addressController,
                        validator: (v) => (v == null || v.isEmpty)
                            ? 'Ingresa la dirección'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // RUC
                      LabeledField(
                        label: 'RUC (Opcional)',
                        hint: '11 dígitos',
                        icon: Icons.badge_outlined,
                        keyboardType: TextInputType.number,
                        controller: _rucController,
                        validator: (v) {
                          if (v == null || v.isEmpty) return null;
                          if (v.length != 11) {
                            return 'El RUC debe tener 11 dígitos';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 28),

                      // 👇 Botón principal con estado de carga
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.ink,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _isLoading ? null : _handleCreate,
                        icon: _isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.check_circle_outline, size: 18),
                        label: Text(
                          _isLoading ? 'Creando tienda...' : 'Crear tienda',
                        ),
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
