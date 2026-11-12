import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Tarjeta de acción para agregar una tienda nueva.
/// Siempre muestra "+" y "Nueva Tienda", pero con un candado si no es Premium.
class AddStoreItem extends StatelessWidget {
  const AddStoreItem({super.key, this.onTap});

  final VoidCallback? onTap;

  static const double _circleSize = 120;

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, _) {
        final esPremium = authProvider.user?.esPremium ?? false;

        return InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  // CÍRCULO PRINCIPAL
                  Container(
                    width: _circleSize,
                    height: _circleSize,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: esPremium 
                          ? AppColors.skyBlue 
                          : AppColors.skyBlue.withOpacity(0.6), // Un poco más apagado si no es premium
                      shape: BoxShape.circle,
                      border: !esPremium 
                          ? Border.all(color: AppColors.gold, width: 2.5) // Borde dorado si no es premium
                          : null,
                    ),
                    child: const Icon(
                      Icons.add_rounded, //  SIEMPRE EL SIGNO DE MÁS
                      color: AppColors.ink,
                      size: 48,
                    ),
                  ),
                  
                  //  CANDADO (solo si NO es Premium)
                  if (!esPremium)
                    Positioned(
                      right: 4,
                      bottom: 4,
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(
                          color: AppColors.gold,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.lock_outline_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              
              //  TEXTO PRINCIPAL: SIEMPRE "Nueva Tienda"
              const Flexible(
                child: Text(
                  'Nueva Tienda',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                    height: 1.2,
                  ),
                ),
              ),
              
              //  SUBTÍTULO (solo si NO es Premium)
              if (!esPremium) ...[
                const SizedBox(height: 2),
                const Text(
                  'Desbloquear',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.gold,
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}