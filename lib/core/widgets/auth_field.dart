import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

/// Campo de texto con la etiqueta arriba y borde redondeado.
/// Con `onDark: true` se adapta a paneles de color (etiqueta blanca,
/// campo blanco).
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
    this.onDark = false,
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
  final bool onDark;
  final TextCapitalization textCapitalization;
  final double bottomSpacing;

  OutlineInputBorder _border(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) {
    final borderColor = onDark ? Colors.transparent : AppColors.mist;
    final focusColor = onDark ? AppColors.gold : AppColors.teal;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: onDark ? Colors.white : AppColors.ink,
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
              filled: !enabled || onDark,
              fillColor: onDark ? Colors.white : null,
              errorStyle: TextStyle(
                color: onDark ? AppColors.gold : AppColors.danger,
                fontWeight: FontWeight.w600,
              ),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              border: _border(borderColor),
              enabledBorder: _border(borderColor),
              disabledBorder: _border(borderColor),
              focusedBorder: _border(focusColor, 1.5),
              errorBorder: _border(onDark ? AppColors.gold : AppColors.danger),
              focusedErrorBorder:
                  _border(onDark ? AppColors.gold : AppColors.danger, 1.5),
            ),
          ),
        ],
      ),
    );
  }
}