import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/tienda_provider.dart';

/// Tarjeta de acción para agregar una tienda nueva.
/// Calcula internamente si es la primera tienda para mostrar o no el candado.
class AddStoreItem extends StatelessWidget {
  const AddStoreItem({super.key, this.onTap});

  final VoidCallback? onTap;
  static const double _circleSize = 120;

  @override
  Widget build(BuildContext context) {
    //  El widget consulta directamente el estado real, sin depender de parámetros externos
    final authProvider = context.watch<AuthProvider>();
    final tiendaProvider = context.watch<TiendaProvider>();

    final esPremium = authProvider.user?.esPremium ?? false;
    
    // Contamos cuántas tiendas están REALMENTE activas en este momento
    final tiendasActivas = tiendaProvider.tiendas.where((t) => t.activo == true).length;
    
    // Es primera tienda si NO hay ninguna activa
    final esPrimeraTienda = tiendasActivas == 0;
    
    //  El candado solo se muestra si NO es premium Y ya tiene al menos 1 tienda activa
    final mostrarCandado = !esPremium && !esPrimeraTienda;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              Container(
                width: _circleSize,
                height: _circleSize,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: mostrarCandado ? AppColors.skyBlue.withOpacity(0.6) : AppColors.skyBlue,
                  shape: BoxShape.circle,
                  border: mostrarCandado ? Border.all(color: AppColors.gold, width: 2.5) : null,
                ),
                child: const Icon(
                  Icons.add_rounded,
                  color: AppColors.ink,
                  size: 48,
                ),
              ),
              if (mostrarCandado)
                Positioned(
                  right: 4,
                  bottom: 4,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: const BoxDecoration(
                      color: AppColors.gold,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
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
          const Flexible(
            child: Text(
              'Nueva Tienda',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink, height: 1.2),
            ),
          ),
          if (mostrarCandado) ...[
            const SizedBox(height: 2),
            const Text(
              'Desbloquear',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.gold),
            ),
          ],
        ],
      ),
    );
  }
}