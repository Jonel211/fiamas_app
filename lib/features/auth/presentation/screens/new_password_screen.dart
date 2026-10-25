import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/auth_field.dart';
import '../../../../main.dart';
import '../widgets/auth_flow_layout.dart';

/// Paso 3: el usuario define su nueva contraseña.
class NewPasswordScreen extends StatefulWidget {
  const NewPasswordScreen({super.key});

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _update() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // TODO: enviar la nueva contraseña a la API.
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contraseña actualizada')),
    );
    // Vuelve al login dejando solo la pantalla de bienvenida debajo.
    AppRoutes.goToLogin(context);
    
  }

  Widget _toggle(bool obscured, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 20,
        color: AppColors.inkMuted,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthFlowLayout(
      currentStep: 3,
      children: [
        const Text('¡Actualiza tu contraseña!', 
        textAlign: TextAlign.center,
        style: AuthFlowText.title),
        const SizedBox(height: 30),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AuthField(
                label: 'Nueva contraseña',
                controller: _passwordController,
                obscureText: _obscurePassword,
                suffixIcon: _toggle(
                  _obscurePassword,
                  () => setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Crea una contraseña';
                  if (v.length < 6) return 'Mínimo 6 caracteres';
                  return null;
                },
              ),
              AuthField(
                label: 'Confirmar nueva contraseña',
                controller: _confirmController,
                obscureText: _obscureConfirm,
                suffixIcon: _toggle(
                  _obscureConfirm,
                  () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Confirma tu contraseña';
                  if (v != _passwordController.text) {
                    return 'Las contraseñas no coinciden';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.teal,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          onPressed: _update,
          child: const Text('Actualizar contraseña'),
        ),
      ],
    );
  }
}