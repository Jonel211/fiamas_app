import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/labeled_field.dart';

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

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _rucController.dispose();
    super.dispose();
  }

  void _handleCreate() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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

      
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.mist),
                  ),
                  child: Form(
                    key: _formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
              
                          Center(
                            child: GestureDetector(
                              onTap: () {
                                
                              },
                              child: Stack(
                                clipBehavior: Clip.none,
                                children: [
                                  Container(
                                    width: 84,
                                    height: 84,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      color: AppColors.mist,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.storefront_outlined,
                                        color: AppColors.inkMuted, size: 50),
                                  ),
                                  Positioned(
                                    bottom: -2,
                                    right: -2,
                                    child: Container(
                                      width: 40,
                                      height: 40,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: AppColors.ink,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                            color: AppColors.surface, width: 2),
                                      ),
                                      child: const Icon(
                                          Icons.camera_alt_outlined,
                                          color: Colors.white,
                                          size: 14),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 40),
                          Text('Nueva Tienda',
                              style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 10),
                          Text(
                            'Cuéntanos un poco sobre tu negocio',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 20),
                          LabeledField(
                            label: 'Nombre de la tienda',
                            hint: 'Ej: Bodega Doña María',
                            icon: Icons.storefront_outlined,
                            controller: _nameController,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Ingresa el nombre de tu tienda'
                                : null,
                          ),
                          const SizedBox(height: 20),
                          LabeledField(
                            label: 'Dirección / Ubicación',
                            hint: 'Calle, Distrito, Ciudad',
                            icon: Icons.location_on_outlined,
                            controller: _addressController,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Ingresa la dirección'
                                : null,
                          ),
                          const SizedBox(height: 20),
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
                          const SizedBox(height: 40),
                          ElevatedButton.icon(
                            onPressed: _handleCreate,
                            icon: const Icon(Icons.check_circle_outline, size: 18),
                            label: const Text('Crear tienda'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}