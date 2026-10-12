import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

/// Fila de casillas para escribir un código numérico (por defecto 6 dígitos).
/// Avanza solas al escribir y retroceden con Backspace.
class CodeInput extends StatefulWidget {
  const CodeInput({
    super.key,
    this.length = 6,
    required this.onChanged,
    this.hasError = false,
  });

  final int length;

  /// Se llama con el código completo cada vez que cambia una casilla.
  final ValueChanged<String> onChanged;

  /// Marca en rojo las casillas vacías.
  final bool hasError;

  @override
  State<CodeInput> createState() => _CodeInputState();
}

class _CodeInputState extends State<CodeInput> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(widget.length, (_) => TextEditingController());
    _focusNodes = List.generate(widget.length, (_) => FocusNode());
  }

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

  void _onChanged(int index, String value) {
    widget.onChanged(_controllers.map((c) => c.text).join());

    if (value.isNotEmpty && index < widget.length - 1) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isNotEmpty) {
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
      widget.onChanged(_controllers.map((c) => c.text).join());
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (int i = 0; i < widget.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Flexible(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 48),
              child: _CodeBox(
                controller: _controllers[i],
                focusNode: _focusNodes[i],
                autofocus: i == 0,
                hasError: widget.hasError && _controllers[i].text.isEmpty,
                onChanged: (v) => _onChanged(i, v),
                onKeyEvent: (event) => _onKey(i, event),
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _CodeBox extends StatelessWidget {
  const _CodeBox({
    required this.controller,
    required this.focusNode,
    required this.onChanged,
    required this.onKeyEvent,
    required this.autofocus,
    required this.hasError,
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

    OutlineInputBorder border(Color color, [double width = 1]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: color, width: width),
        );

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
          border: border(borderColor),
          enabledBorder: border(borderColor),
          focusedBorder: border(AppColors.teal, 1.5),
        ),
      ),
    );
  }
}