import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

/// Campo de texto con la etiqueta arriba y borde redondeado.
/// Es el estilo de los formularios de autenticación y de perfil.
/// Admite un ícono opcional al inicio (`prefixIcon`).
/// Con `enabled: false` se muestra de solo lectura (fondo gris).
class AuthField extends StatelessWidget {
  const AuthField({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.maxLength,
    this.digitsOnly = false,
    this.enabled = true,
    this.textCapitalization = TextCapitalization.none,
    this.bottomSpacing = 16,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final int? maxLength;
  final bool digitsOnly;
  final bool enabled;
  final TextCapitalization textCapitalization;
  final double bottomSpacing;

  /// Método auxiliar para reutilizar la configuración del borde
  OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            validator: validator,
            enabled: enabled,
            keyboardType: keyboardType,
            obscureText: obscureText,
            maxLength: maxLength,
            textCapitalization: textCapitalization,
            inputFormatters:
                digitsOnly ? [FilteringTextInputFormatter.digitsOnly] : null,
            style: TextStyle(
              fontSize: 15,
              color: enabled ? AppColors.ink : AppColors.inkMuted,
            ),
            decoration: InputDecoration(
              counterText: '',
              isDense: true,
              filled: !enabled,
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: _border(AppColors.mist),
              enabledBorder: _border(AppColors.mist),
              disabledBorder: _border(AppColors.mist),
              focusedBorder: _border(AppColors.teal, 1.5),
            ),
          ),
        ],
      ),
    );
  }
}