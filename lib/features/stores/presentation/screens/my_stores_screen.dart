import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../main.dart';
import '../../domain/store.dart';
import '../widgets/stores_app_bar.dart';
import '../widgets/store_list_item.dart';
import '../widgets/add_store_item.dart';

/// Pantalla "Mis Tiendas": el tendero elige qué tienda gestionar
/// o agrega una nueva.
///
/// El layout es responsive:
/// - 1–2 tiendas → 1 columna (card grande).
/// - 3 o más tiendas → 2 columnas.
class MyStoresScreen extends StatelessWidget {
  const MyStoresScreen({super.key});

  // TODO: reemplazar por datos reales desde StoresRepository
  static const _stores = [
    Store(id: '1', name: 'Bodega "Gian Carlos"', city: 'Chiclín'),
    Store(id: '2', name: 'Bodega "El Sol"', city: 'Sullana'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        children: [
          // ↓ AQUÍ va el botón de hamburguesa conectado al menú
          StoresAppBar(
            onMenuTap: () => Navigator.of(context).pushNamed(AppRoutes.menu),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                children: [
                  // Subtítulo
                  const Text(
                    'Elige la tienda que quieres gestionar',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.inkMuted,
                    ),
                  ),
                  const SizedBox(height: 28),

                  // Grid dinámico
                  _StoresGrid(stores: _stores),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Grid responsive que decide cuántas columnas usar según la cantidad
/// de tiendas y el ancho de la pantalla.
class _StoresGrid extends StatelessWidget {
  const _StoresGrid({required this.stores});
  final List<Store> stores;

  @override
  Widget build(BuildContext context) {
    // Regla: 3+ tiendas → 2 columnas, si no → 1 columna.
    final crossAxisCount = stores.length >= 3 ? 2 : 1;

    // Aspect ratio diferente según las columnas para que las cards se vean bien.
    final aspectRatio = crossAxisCount == 1 ? 1.35 : 0.85;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: crossAxisCount,
      mainAxisSpacing: 28,
      crossAxisSpacing: 16,
      childAspectRatio: aspectRatio,
      children: [
        for (final store in stores)
          StoreListItem(
            store: store,
            onTap: () {
              // Navegación al resumen de esa tienda
              Navigator.of(context).pushNamed(AppRoutes.summary);
            },
            onEdit: () {
              // TODO: navegar a edición de tienda
              debugPrint('Editar tienda: ${store.id}');
            },
          ),
        AddStoreItem(
          onTap: () => Navigator.of(context).pushNamed(AppRoutes.newStore),
        ),
      ],
    );
  }
}