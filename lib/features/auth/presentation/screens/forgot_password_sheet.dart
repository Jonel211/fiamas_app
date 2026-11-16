import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/auth_field.dart';
import '../../../../core/widgets/modal_bottom_sheet_layout.dart';
import '../../../../core/widgets/step_indicator.dart';
import '../../../../core/services/firebase_otp_service.dart';
import '../../../../core/network/dio_client.dart';
import 'reset_code_sheet.dart';

class ForgotPasswordSheet extends StatefulWidget {
  const ForgotPasswordSheet({super.key});

  @override
  State<ForgotPasswordSheet> createState() => _ForgotPasswordSheetState();
}

class _ForgotPasswordSheetState extends State<ForgotPasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpService = FirebaseOtpService();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);
      final phone = _phoneController.text.trim();

      try {
        //  PASO 1: Verificar en el backend ANTES de enviar el SMS
        final dio = DioClient.create();
        final response = await dio.post(
          '/auth/verificar-telefono-recuperacion', // Asegúrate que la ruta coincida con tu backend
          data: {'telefono': phone},
        );

        //  PASO 2: Si el backend dice que NO existe, mostramos error y DETENEMOS el proceso
        if (response.data['existe'] == false) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.data['mensaje'] ?? 'Número no registrado'),
              backgroundColor: AppColors.danger,
              behavior: SnackBarBehavior.floating,
            ),
          );
          return; //  AQUÍ SE DETIENE. NO SE LLAMA A FIREBASE NI SE GASTA SMS.
        }

        //  PASO 3: Si existe, recién ahora enviamos el SMS con Firebase
        final formattedPhone = '+51$phone';
        await _otpService.sendOtp(
          phoneNumber: formattedPhone,
          onCodeSent: (verificationId) {
            if (mounted) {
              setState(() => _isLoading = false);
              Navigator.of(context).pop();
              showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => ResetCodeSheet(
                  phone: phone, 
                  verificationId: verificationId,
                ),
              );
            }
          },
          onError: (error) {
            if (mounted) {
              setState(() => _isLoading = false);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(error), 
                  backgroundColor: AppColors.danger,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          },
        );
      } catch (e) {
        // Manejo de errores de red o del backend
        setState(() => _isLoading = false);
        String errorMsg = 'Error de conexión. Intenta de nuevo.';
        if (e.toString().contains('404')) {
          errorMsg = 'Este número no está registrado en el sistema.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMsg),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ModalBottomSheetLayout(
      title: '¡No te preocupes!',
      subtitle: 'En Fiamas no pierdes nada.\nIngresa tu número de teléfono',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const StepIndicator(currentStep: 1),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: AuthField(
              label: 'Número de teléfono',
              controller: _phoneController,
              keyboardType: TextInputType.phone,
              maxLength: 9,
              digitsOnly: true,
              prefixIcon: const Icon(Icons.phone_outlined, color: AppColors.teal),
              validator: (v) => (v == null || v.isEmpty || v.length != 9) 
                  ? 'Debe tener 9 dígitos' 
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Te enviaremos un código de validación', 
            textAlign: TextAlign.center, 
            style: TextStyle(fontSize: 13, color: AppColors.inkMuted)
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal, 
              foregroundColor: Colors.white, 
              minimumSize: const Size.fromHeight(48), 
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
            ),
            onPressed: _isLoading ? null : _sendCode,
            child: _isLoading 
                ? const SizedBox(
                    height: 22, 
                    width: 22, 
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)
                  ) 
                : const Text('Enviar', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.of(context).pop(), 
            child: const Text('Cancelar', style: TextStyle(color: AppColors.inkMuted, fontWeight: FontWeight.w600))
          ),
        ],
      ),
    );
  }
}