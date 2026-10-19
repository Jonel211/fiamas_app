import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Tarjeta que aparece debajo del buscador cuando el usuario escribe un
/// teléfono que no está registrado, ofreciendo crearlo.
class RegisterClientSuggestion extends StatelessWidget {
  const RegisterClientSuggestion({
    super.key,
    required this.phone,
    this.onTap,
  });

  final String phone;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.mist),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          child: Row(
            children: [
              const Icon(
                Icons.person_outline_rounded,
                color: AppColors.ink,
                size: 20,
              ),
              const SizedBox(width: 8),
              const Text(
                'Registrar cliente',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  phone,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.inkMuted,
                  ),
                  textAlign: TextAlign.right,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}