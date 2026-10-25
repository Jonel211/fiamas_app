import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header_config.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../providers/auth_provider.dart';

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
  bool _submitting = false;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  // función para manejar el guardado de la contraseña
  Future<void> _handleSave() async {
    if (_submitting) return;
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _submitting = true);
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    final success = await authProvider.cambiarPassword(
      passwordActual: _currentController.text.trim(),
      passwordNuevo: _newController.text.trim(),
    );

    if (!mounted) return;
    setState(() => _submitting = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Contraseña actualizada exitosamente.'),
          backgroundColor: AppColors.teal,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pop();
    } else {
      final errorMsg = authProvider.errorMessage ?? 'Error al actualizar la contraseña.';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMsg),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppHeaderConfig(
      title: 'Cambiar contraseña o PIN',
      showBack: true,
      child: Scaffold(
        backgroundColor: AppColors.ivory,
        body: SingleChildScrollView(
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
                  onPressed: _submitting ? null : _handleSave,
                  child: _submitting
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : const Text('Guardar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
