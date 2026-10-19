import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Decoración común de los campos del producto: fondo gris suave y borde fino.
/// Con `pill: true` los bordes son totalmente redondeados (campo de precio).
InputDecoration productInputDecoration({String? hint, Widget? prefixIcon, bool pill = false}) {
  final radius = BorderRadius.circular(pill ? 24 : 10);
  OutlineInputBorder border(Color color, [double width = 1]) =>
      OutlineInputBorder(borderRadius: radius, borderSide: BorderSide(color: color, width: width));

  return InputDecoration(
    hintText: hint,
    hintStyle: const TextStyle(fontSize: 14, color: AppColors.inkMuted),
    filled: true,
    fillColor: AppColors.surfaceMuted,
    prefixIcon: prefixIcon,
    isDense: true,
    contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: pill ? 12 : 14),
    border: border(AppColors.mist),
    enabledBorder: border(AppColors.mist),
    focusedBorder: border(AppColors.teal, 1.5),
    errorBorder: border(AppColors.danger),
    focusedErrorBorder: border(AppColors.danger, 1.5),
  );
}

/// Etiqueta teal en negrita que va sobre cada campo.
class ProductFieldLabel extends StatelessWidget {
  const ProductFieldLabel(this.text, {super.key, this.small = false});

  final String text;
  final bool small;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(
          text,
          style: TextStyle(
            fontSize: small ? 14 : 16,
            fontWeight: FontWeight.w700,
            color: AppColors.teal,
          ),
        ),
      );
}