import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';

class AuthField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final int? maxLength;
  final TextCapitalization textCapitalization;
  
  // ✅ NUEVOS PARÁMETROS AGREGADOS (Fase 1)
  final List<TextInputFormatter>? inputFormatters;
  final ValueChanged<String>? onChanged;
  
  // ✅ PARÁMETROS RESTAURADOS PARA COMPATIBILIDAD
  final bool enabled;
  final bool digitsOnly;
  final double? bottomSpacing;
  final bool? onDark;

  const AuthField({
    Key? key,
    required this.label,
    required this.controller,
    this.obscureText = false,
    this.prefixIcon,
    this.suffixIcon,
    this.validator,
    this.keyboardType,
    this.maxLength,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.onChanged,
    this.enabled = true,
    this.digitsOnly = false,
    this.bottomSpacing = 16.0,
    this.onDark,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Combinamos los formatters
    List<TextInputFormatter> formatters = [];
    if (digitsOnly) {
      formatters.add(FilteringTextInputFormatter.digitsOnly);
    }
    if (inputFormatters != null) {
      formatters.addAll(inputFormatters!);
    }

    final isDark = onDark == true;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomSpacing ?? 16.0),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        maxLength: maxLength,
        textCapitalization: textCapitalization,
        inputFormatters: formatters.isEmpty ? null : formatters,
        onChanged: onChanged,
        validator: validator,
        enabled: enabled,
        style: isDark ? const TextStyle(color: Colors.black) : const TextStyle(color: Colors.black),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: isDark ? Colors.white70 : AppColors.inkMuted, 
            fontSize: 14
          ),
          prefixIcon: prefixIcon != null 
              ? IconTheme.merge(
                  data: IconThemeData(color: AppColors.teal),
                  child: prefixIcon!,
                ) 
              : null,
          suffixIcon: suffixIcon,
          filled: true,
          fillColor: Colors.white, // ✅ FONDO BLANCO SÓLIDO
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: isDark ? Colors.white24 : AppColors.mist),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: isDark ? Colors.white24 : AppColors.mist),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.teal, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.danger),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.danger, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        ),
      ),
    );
  }
}