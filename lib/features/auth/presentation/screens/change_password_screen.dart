import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../core/widgets/simple_app_bar.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: conectar con backend
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        children: [
          const SimpleAppBar(title: 'Cambiar contraseña o PIN'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Texto informativo
                    const Text(
                      'Para el cambio de su contraseña o PIN, ingrese los siguientes datos',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.teal,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 28),

                    LabeledField(
                      label: 'Contraseña / PIN',
                      hint: '',
                      obscureText: true,
                      controller: _currentController,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Ingresa tu contraseña actual'
                          : null,
                    ),
                    const SizedBox(height: 20),

                    LabeledField(
                      label: 'Nuevo PIN (De 6 dígitos)',
                      hint: '',
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      controller: _newController,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Ingresa el nuevo PIN';
                        if (v.length != 6) return 'El PIN debe tener 6 dígitos';
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    LabeledField(
                      label: 'Confirmar PIN',
                      hint: '',
                      obscureText: true,
                      keyboardType: TextInputType.number,
                      controller: _confirmController,
                      validator: (v) {
                        if (v == null || v.isEmpty) return 'Confirma el nuevo PIN';
                        if (v != _newController.text) {
                          return 'Los PIN no coinciden';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 48),

                    // Botón Guardar (dorado)
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gold,
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
                      onPressed: _handleSave,
                      child: const Text('Guardar'),
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