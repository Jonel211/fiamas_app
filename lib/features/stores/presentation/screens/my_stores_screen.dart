import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../main.dart';
import '../../domain/store.dart';
import '../widgets/store_card.dart';
import 'new_store_screen.dart';

class MyStoresScreen extends StatelessWidget {
  const MyStoresScreen({super.key});

  // TODO: reemplazar por datos reales desde StoresRepository
  static const _stores = [
    Store(id: '1', name: 'Bodega "El Sol"', city: 'Sullana'),
    Store(id: '2', name: 'Minimarket Pura Vida', city: 'Huancayo'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Mis Tiendas',
                      style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: 4),
                  Text(
                    'Elige la tienda que quieres gestionar',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
            Expanded(
              child: GridView.count(
                padding: const EdgeInsets.all(24),
                crossAxisCount: 3,
                mainAxisSpacing: 24,
                crossAxisSpacing: 12,
                childAspectRatio: 0.8,
                children: [
                  for (final store in _stores)
                    StoreCard(
                      store: store,
                      onTap: () {
                        // Solo navegación visual; el resumen real
                        // se conectará a esta tienda más adelante.
                        Navigator.of(context).pushNamed(AppRoutes.summary);
                      },
                    ),
                  AddStoreCard(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                          builder: (_) => const NewStoreScreen()),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}