import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../widgets/store_photo_picker.dart';

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
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _rucController.dispose();
    _phoneController.dispose();
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
      body: Column(
        children: [
          const SimpleAppBar(title: 'Nueva Tienda'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Selector de foto
                    Center(
                      child: StorePhotoPicker(
                        onTap: () {
                          // TODO: abrir selector de imagen / cámara
                        },
                      ),
                    ),
                    const SizedBox(height: 36),

                    // Campos del formulario
                    LabeledField(
                      label: 'Nombre de la tienda',
                      hint: '',
                      controller: _nameController,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Ingresa el nombre de tu tienda'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    LabeledField(
                      label: 'Dirección / Ubicación',
                      hint: '',
                      controller: _addressController,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Ingresa la dirección'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    LabeledField(
                      label: 'RUC (Opcional)',
                      hint: '',
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
                    const SizedBox(height: 20),

                    LabeledField(
                      label: 'Teléfono (Opcional)',
                      hint: '',
                      keyboardType: TextInputType.phone,
                      controller: _phoneController,
                    ),
                    const SizedBox(height: 32),

                    // Botón crear tienda
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.teal,
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(52),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                        elevation: 0,
                        textStyle: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      onPressed: _handleCreate,
                      child: const Text('Crear tienda'),
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