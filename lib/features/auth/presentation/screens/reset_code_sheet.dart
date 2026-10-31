import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/modal_bottom_sheet_layout.dart';
import '../../../../core/widgets/step_indicator.dart';
import '../../../../core/services/firebase_otp_service.dart';
import 'new_password_sheet.dart';

class ResetCodeSheet extends StatefulWidget {
  final String phone;
  final String verificationId;

  const ResetCodeSheet({
    super.key,
    required this.phone,
    required this.verificationId,
  });

  @override
  State<ResetCodeSheet> createState() => _ResetCodeSheetState();
}

class _ResetCodeSheetState extends State<ResetCodeSheet> {
  final _otpService = FirebaseOtpService();
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  bool _showError = false;
  bool _isLoading = false;

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  Future<void> _verify() async {
    if (_code.length < 6) {
      setState(() => _showError = true);
      return;
    }
    setState(() => _isLoading = true);

    try {
      await _otpService.verifyOtp(
        verificationId: widget.verificationId,
        smsCode: _code,
      );
      if (mounted) {
        Navigator.of(context).pop();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => NewPasswordSheet(phone: widget.phone),
        );
      }
    } catch (e) {
      setState(() {
        _showError = true;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Código inválido o expirado'),
          backgroundColor: AppColors.danger,
        ),
      );
    }
  }

  void _onChanged(int index, String value) {
    setState(() => _showError = false);
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  KeyEventResult _onKey(int index, KeyEvent event) {
    if (event is KeyDownEvent &&
        event.logicalKey == LogicalKeyboardKey.backspace &&
        _controllers[index].text.isEmpty &&
        index > 0) {
      _controllers[index - 1].clear();
      _focusNodes[index - 1].requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return ModalBottomSheetLayout(
      title: 'Ingresa el código',
      subtitle:
          'Fiamas te ha enviado un código,\nrevisa tu bandeja de mensajes.',
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const StepIndicator(currentStep: 2),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              for (int i = 0; i < 6; i++) ...[
                if (i > 0) const SizedBox(width: 8),
                Flexible(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 48),
                    child: Focus(
                      onKeyEvent: (node, event) => _onKey(i, event),
                      child: TextField(
                        controller: _controllers[i],
                        focusNode: _focusNodes[i],
                        autofocus: i == 0,
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                        ],
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: Colors.white,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 14,
                          ),
                          // ✅ CORREGIDO: BorderRadius.all(Radius.circular(10))
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              color: _showError && _controllers[i].text.isEmpty
                                  ? AppColors.danger
                                  : AppColors.mist,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              color: _showError && _controllers[i].text.isEmpty
                                  ? AppColors.danger
                                  : AppColors.mist,
                            ),
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(Radius.circular(10)),
                            borderSide: BorderSide(
                              color: AppColors.teal,
                              width: 1.5,
                            ),
                          ),
                        ),
                        onChanged: (v) => _onChanged(i, v),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
          if (_showError) ...[
            const SizedBox(height: 12),
            const Text(
              'Ingresa los 6 dígitos del código',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.danger),
            ),
          ],
          const SizedBox(height: 8),
          const Text(
            'El código es de un solo uso',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.teal,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(
                  Radius.circular(12),
                ), // ✅ CORREGIDO
              ),
            ),
            onPressed: _isLoading ? null : _verify,
            child: _isLoading
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Verificar',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () {
              for (final c in _controllers) c.clear();
              _focusNodes.first.requestFocus();
              setState(() => _showError = false);
            },
            child: const Text(
              'Reenviar código',
              style: TextStyle(
                color: AppColors.teal,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
