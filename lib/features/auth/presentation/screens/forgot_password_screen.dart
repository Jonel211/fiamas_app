import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/auth_field.dart';
import '../../../../main.dart';
import '../widgets/auth_flow_layout.dart';

/// Paso 1: el usuario escribe su teléfono para recibir un código.
class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _send() {
    if (_formKey.currentState?.validate() ?? false) {
      // TODO: pedir a la API que envíe el código de validación.
      Navigator.of(context).pushNamed(
        AppRoutes.resetCode,
        arguments: _phoneController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthFlowLayout(
      currentStep: 1,
      children: [
        const Text('¡No te preocupes!', style: AuthFlowText.title),
        const SizedBox(height: 12),
        const Text('En Fiamas no pierdes nada.', style: AuthFlowText.body),
        const SizedBox(height: 20),
        Form(
          key: _formKey,
          child: AuthField(
            label: 'Ingresa tu número de teléfono',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 9,
            digitsOnly: true,
            validator: (v) {
              if (v == null || v.isEmpty) return 'Ingresa tu teléfono';
              if (v.length != 9) return 'El celular debe tener 9 dígitos';
              return null;
            },
          ),
        ),
        const Text(
          'Te enviaremos un código de validación.',
          textAlign: TextAlign.center,
          style: AuthFlowText.hint,
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.teal,
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48),
            textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          onPressed: _send,
          child: const Text('Enviar'),
        ),
      ],
    );
  }
}