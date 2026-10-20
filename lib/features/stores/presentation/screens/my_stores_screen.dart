import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../main.dart';
import '../../../auth/presentation/providers/tienda_provider.dart';
import '../../../auth/data/models/tienda_model.dart';
import '../widgets/stores_app_bar.dart';
import '../widgets/add_store_item.dart';
import '../widgets/store_list_item.dart';
import 'new_store_screen.dart';
import 'edit_store_screen.dart';

class MyStoresScreen extends StatefulWidget {
  const MyStoresScreen({super.key});

  @override
  State<MyStoresScreen> createState() => _MyStoresScreenState();
}

class _MyStoresScreenState extends State<MyStoresScreen> {
  @override
  void initState() {
    super.initState();
    // Carga inicial
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TiendaProvider>().cargarMisTiendas();
    });
  }

  void _openMenu() {
    Navigator.pushNamed(context, AppRoutes.menu);
  }

  void _openNotifications() {
    Navigator.pushNamed(context, AppRoutes.notifications);
  }

  // ✅ FUNCIÓN PARA RECARGAR AL DESLIZAR
  Future<void> _onRefresh() async {
    await context.read<TiendaProvider>().cargarMisTiendas();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 40),
        child: StoresAppBar(
          onMenuTap: _openMenu,
          onBellTap: _openNotifications,
        ),
      ),
      body: Consumer<TiendaProvider>(
        builder: (context, provider, _) {
          // Estado de carga inicial
          if (provider.isLoading && provider.tiendas.isEmpty) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.teal),
            );
          }

          // Estado de error inicial
          if (provider.error != null && provider.tiendas.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    provider.error!,
                    style: const TextStyle(color: AppColors.inkMuted),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => provider.cargarMisTiendas(),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          // Estado vacío (sin tiendas)
          if (provider.tiendas.isEmpty) {
            return Center(
              child: AddStoreItem(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => NewStoreScreen()),
                ),
              ),
            );
          }

          // ✅ WRAPPER DE REFRESH INDICATOR (Deslizar para recargar)
          return RefreshIndicator(
            onRefresh: _onRefresh,
            color: AppColors.teal, // Color de la "pelotita" de carga
            backgroundColor: Colors.white,
            child: GridView.builder(
              padding: const EdgeInsets.all(24),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 20,
                mainAxisSpacing: 20,
                childAspectRatio: 0.85,
              ),
              itemCount: provider.tiendas.length + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return AddStoreItem(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => NewStoreScreen()),
                    ),
                  );
                }

                final tienda = provider.tiendas[index - 1];
                return StoreListItem(
                  store: tienda,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.summary,
                      arguments: {'tienda': tienda},
                    );
                  },
                  onEdit: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.editStore,
                      arguments: tienda,
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
