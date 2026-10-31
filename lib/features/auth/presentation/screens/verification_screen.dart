import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/services/firebase_otp_service.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  static const int _codeLength = 6;
  final FirebaseOtpService _otpService = FirebaseOtpService(); 

  final List<TextEditingController> _controllers = List.generate(_codeLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(_codeLength, (_) => FocusNode());

  bool _showError = false;
  bool _isLoading = false; 
  String _verificationId = ''; 

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _sendOtp()); 
  }

  @override
  void dispose() {
    for (final c in _controllers) c.dispose();
    for (final f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  String _maskedPhone(String? phone) {
    if (phone == null || phone.length != 9) return '+51 9xx xxx xxx';
    return '+51 ${phone[0]}xx xxx ${phone.substring(6)}';
  }

  Future<void> _sendOtp() async {
    setState(() => _isLoading = true);
    final phone = ModalRoute.of(context)?.settings.arguments as String?;
    final formattedPhone = '+51${phone?.replaceAll(RegExp(r'\D'), '')}';

    await _otpService.sendOtp(
      phoneNumber: formattedPhone,
      onCodeSent: (verificationId) {
        if (mounted) {
          setState(() {
            _verificationId = verificationId;
            _isLoading = false;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error), backgroundColor: AppColors.danger),
          );
        }
      },
    );
  }

  void _onChanged(int index, String value) {
    if (_showError) setState(() => _showError = false);
    if (value.isNotEmpty && index < _codeLength - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isNotEmpty && index == _codeLength - 1) {
      _focusNodes[index].unfocus();
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

  Future<void> _handleVerify() async {
    if (_code.length < _codeLength) {
      setState(() => _showError = true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      //  Verificar con Firebase
      await _otpService.verifyOtp(
        verificationId: _verificationId,
        smsCode: _code,
      );
      
      if (mounted) {
        //  Devuelve true a la pantalla de registro para que continúe
        Navigator.of(context).pop(true); 
      }
    } catch (e) {
      setState(() {
        _showError = true;
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Código inválido o expirado'), backgroundColor: AppColors.danger),
      );
    }
  }

  void _handleResend() {
    for (final c in _controllers) c.clear();
    _focusNodes.first.requestFocus();
    _sendOtp(); // ✅ Reenvía el código
  }

  @override
  Widget build(BuildContext context) {
    final phone = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 0, 0),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back, color: AppColors.ink, size: 28),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text('Verifica tu número', textAlign: TextAlign.center, style: TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: AppColors.ink)),
                      const SizedBox(height: 12),
                      Text('Te enviamos un código al\n${_maskedPhone(phone)}', textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: AppColors.ink, height: 1.5)),
                      const SizedBox(height: 36),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < _codeLength; i++) ...[
                            if (i > 0) const SizedBox(width: 10),
                            Flexible(
                              child: ConstrainedBox(
                                constraints: const BoxConstraints(maxWidth: 48),
                                child: _CodeBox(
                                  controller: _controllers[i],
                                  focusNode: _focusNodes[i],
                                  autofocus: i == 0,
                                  hasError: _showError && _controllers[i].text.isEmpty,
                                  onChanged: (v) => _onChanged(i, v),
                                  onKeyEvent: (event) => _onKey(i, event),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (_showError) ...[
                        const SizedBox(height: 12),
                        const Text('Ingresa los 6 dígitos del código', textAlign: TextAlign.center, style: TextStyle(fontSize: 13, color: AppColors.danger)),
                      ],
                      const SizedBox(height: 48),
                      const Text('¿No recibiste el código?', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, color: AppColors.ink)),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: _isLoading ? null : _handleResend,
                          child: const Text('Reenviar Ahora', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.teal)),
                        ),
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          textStyle: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                        ),
                        onPressed: _isLoading ? null : _handleVerify,
                        child: _isLoading
                            ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white))
                            : const Text('Verificar'),
                      ),
                      const SizedBox(height: 220),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKeyEvent,
    this.autofocus = false,
    this.hasError = false,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onChanged;
  final KeyEventResult Function(KeyEvent event) onKeyEvent;
  final bool autofocus;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final borderColor = hasError ? AppColors.danger : AppColors.mist;

    return Focus(
      onKeyEvent: (_, event) => onKeyEvent(event),
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        autofocus: autofocus,
        onChanged: onChanged,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: AppColors.ink),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: borderColor)),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: const BorderSide(color: AppColors.teal, width: 1.5)),
        ),
      ),
    );
  }
}