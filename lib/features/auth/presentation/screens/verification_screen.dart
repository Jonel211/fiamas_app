import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../main.dart';

class VerificationScreen extends StatefulWidget {
  const VerificationScreen({super.key});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  static const int _codeLength = 6;

  final List<TextEditingController> _controllers =
      List.generate(_codeLength, (_) => TextEditingController());
  final List<FocusNode> _focusNodes =
      List.generate(_codeLength, (_) => FocusNode());

  bool _showError = false;

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  String get _code => _controllers.map((c) => c.text).join();

  /// Muestra el número parcialmente oculto: +51 9xx xxx 321
  String _maskedPhone(String? phone) {
    if (phone == null || phone.length != 9) return '+51 9xx xxx xxx';
    return '+51 ${phone[0]}xx xxx ${phone.substring(6)}';
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
    // Backspace en una casilla vacía: vuelve a la anterior y la borra.
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

  void _handleVerify() {
    if (_code.length < _codeLength) {
      setState(() => _showError = true);
      return;
    }
    // TODO: validar el código con la API cuando exista el backend.
    Navigator.of(context).pushNamedAndRemoveUntil(
      AppRoutes.stores,
      (route) => false,
    );
  }

  void _handleResend() {
    for (final c in _controllers) {
      c.clear();
    }
    _focusNodes.first.requestFocus();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Te reenviamos un nuevo código')),
    );
    // TODO: llamar a la API para reenviar el código.
  }

  @override
  Widget build(BuildContext context) {
    final phone = ModalRoute.of(context)?.settings.arguments as String?;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Flecha de regreso (fija arriba)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 4, 0, 0),
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back,
                      color: AppColors.ink, size: 28),
                ),
              ),
            ),

            // Contenido centrado en el espacio restante.
            // Si el teclado ocupa lugar, el contenido se puede desplazar.
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Verifica tu número',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: AppColors.ink,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Te enviamos un código al\n${_maskedPhone(phone)}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.ink,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 36),

                      // Casillas del código
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          for (int i = 0; i < _codeLength; i++) ...[
                            if (i > 0) const SizedBox(width: 10),
                            Flexible(
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxWidth: 48),
                                child: _CodeBox(
                                  controller: _controllers[i],
                                  focusNode: _focusNodes[i],
                                  autofocus: i == 0,
                                  hasError: _showError &&
                                      _controllers[i].text.isEmpty,
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
                        const Text(
                          'Ingresa los 6 dígitos del código',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontSize: 13, color: AppColors.danger),
                        ),
                      ],
                      const SizedBox(height: 48),

                      const Text(
                        '¿No recibiste el código?',
                        textAlign: TextAlign.center,
                        style:
                            TextStyle(fontSize: 14, color: AppColors.ink),
                      ),
                      const SizedBox(height: 8),
                      Center(
                        child: TextButton(
                          onPressed: _handleResend,
                          child: const Text(
                            'Reenviar Ahora',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.teal,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.teal,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          textStyle: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        onPressed: _handleVerify,
                        child: const Text('Verificar'),
                      ),

                      // Sube el bloque: más altura = más arriba.
                      // Prueba valores entre 100 y 200.
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
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: AppColors.ink,
        ),
        decoration: InputDecoration(
          counterText: '',
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 14),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: borderColor),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: borderColor),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
          ),
        ),
      ),
    );
  }
}