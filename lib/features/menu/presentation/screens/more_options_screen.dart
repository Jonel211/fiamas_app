import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../main.dart';
import '../widgets/more_option_card.dart';

class MoreOptionsScreen extends StatelessWidget {
  const MoreOptionsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 1. BARRA SUPERIOR (HEADER)
        Container(
          width: double.infinity,
          color: AppColors.teal,
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            bottom: 16,
            left: 20,
            right: 20,
          ),
          child: const Text(
            'Más opciones',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),

        // 2. CONTENIDO (Grilla y botón)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                // Grilla de opciones
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 3,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1.0,
                  children: [
                    MoreOptionCard(
                      icon: Icons.analytics_rounded,
                      label: 'Reportes',
                      color: Colors.blueAccent,
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.reports),
                    ),
                    MoreOptionCard(
                      icon: Icons.local_offer_rounded,
                      label: 'Categoría',
                      color: Colors.orangeAccent,
                      // AQUÍ ESTÁ LA CONEXIÓN: Va a la pantalla de Categorías
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.categories),
                    ),
                    MoreOptionCard(
                      icon: Icons.storefront_rounded,
                      label: 'Tienda',
                      color: Colors.pinkAccent,
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.storeProfile),
                    ),
                    MoreOptionCard(
                      icon: Icons.support_agent_rounded,
                      label: 'Ayuda',
                      color: Colors.purpleAccent,
                      onTap: () => Navigator.of(context).pushNamed(AppRoutes.help),
                    ),
                  ],
                ),
                
                const Spacer(),

                // Botón Salir
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.stores,
                        (route) => false,
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                      textStyle: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('Salir de la tienda'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}