import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/code_input.dart';
import '../../../../main.dart';
import '../widgets/auth_flow_layout.dart';

/// Paso 2: el usuario escribe el código de 6 dígitos que recibió.
class ResetCodeScreen extends StatefulWidget {
  const ResetCodeScreen({super.key});

  @override
  State<ResetCodeScreen> createState() => _ResetCodeScreenState();
}

class _ResetCodeScreenState extends State<ResetCodeScreen> {
  static const int _codeLength = 6;

  String _code = '';
  bool _showError = false;

  void _verify() {
    if (_code.length < _codeLength) {
      setState(() => _showError = true);
      return;
    }
    // TODO: validar el código con la API.
    Navigator.of(context).pushNamed(AppRoutes.newPassword);
  }

  @override
  Widget build(BuildContext context) {
    return AuthFlowLayout(
      currentStep: 2,
      children: [
        const Text('Ingresa el código', style: AuthFlowText.title),
        const SizedBox(height: 12),
        const Text(
          'Fiamas te ha enviado un código, revisa tu bandeja de mensajes.',
          style: AuthFlowText.body,
        ),
        const SizedBox(height: 28),
        CodeInput(
          length: _codeLength,
          hasError: _showError,
          onChanged: (value) => setState(() {
            _code = value;
            _showError = false;
          }),
        ),
        if (_showError) ...[
          const SizedBox(height: 12),
          const Text(
            'Ingresa los 6 dígitos del código',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.danger),
          ),
        ],
        const SizedBox(height: 29),
        const Text(
          'El código es de un solo uso',
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
          onPressed: _verify,
          child: const Text('Verificar'),
        ),
      ],
    );
  }
}