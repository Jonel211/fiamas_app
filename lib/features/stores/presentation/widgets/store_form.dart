import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/labeled_field.dart';
import 'store_photo_picker.dart';

/// Datos que captura el formulario de tienda.
class StoreFormData {
  const StoreFormData({
    required this.name,
    required this.address,
    this.ruc = '',
    this.phone = '',
  });

  final String name;
  final String address;
  final String ruc;
  final String phone;
}

/// Formulario compartido por "Nueva Tienda" y "Editar Tienda".
/// Con los valores iniciales llega prellenado (modo edición).
class StoreForm extends StatefulWidget {
  const StoreForm({
    super.key,
    required this.submitLabel,
    required this.onSubmit,
    this.initialName = '',
    this.initialAddress = '',
    this.initialRuc = '',
    this.initialPhone = '',
  });

  final String submitLabel;
  final ValueChanged<StoreFormData> onSubmit;
  final String initialName;
  final String initialAddress;
  final String initialRuc;
  final String initialPhone;

  @override
  State<StoreForm> createState() => _StoreFormState();
}

class _StoreFormState extends State<StoreForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.initialName);
  late final _addressController = TextEditingController(text: widget.initialAddress);
  late final _rucController = TextEditingController(text: widget.initialRuc);
  late final _phoneController = TextEditingController(text: widget.initialPhone);

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _rucController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    widget.onSubmit(StoreFormData(
      name: _nameController.text.trim(),
      address: _addressController.text.trim(),
      ruc: _rucController.text.trim(),
      phone: _phoneController.text.trim(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: StorePhotoPicker(
                onTap: () {
                  // TODO: abrir selector de imagen / cámara
                },
              ),
            ),
            const SizedBox(height: 36),
            LabeledField(
              label: 'Nombre de la tienda',
              hint: '',
              controller: _nameController,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Ingresa el nombre de tu tienda' : null,
            ),
            const SizedBox(height: 20),
            LabeledField(
              label: 'Dirección / Ubicación',
              hint: '',
              controller: _addressController,
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Ingresa la dirección' : null,
            ),
            const SizedBox(height: 20),
            LabeledField(
              label: 'RUC (Opcional)',
              hint: '',
              keyboardType: TextInputType.number,
              controller: _rucController,
              validator: (v) {
                if (v == null || v.isEmpty) return null;
                return v.length == 11 ? null : 'El RUC debe tener 11 dígitos';
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 0,
                textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
              onPressed: _submit,
              child: Text(widget.submitLabel),
            ),
          ],
        ),
      ),
    );
  }
}