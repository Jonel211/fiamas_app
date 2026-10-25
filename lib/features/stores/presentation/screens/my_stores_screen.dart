import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_header_config.dart';
import '../../../../main.dart';
import '../../../auth/data/models/tienda_model.dart';
import '../../../auth/presentation/providers/tienda_provider.dart';
import '../widgets/add_store_item.dart';
import '../widgets/store_list_item.dart';
import 'new_store_screen.dart';

class MyStoresScreen extends StatefulWidget {
  const MyStoresScreen({super.key});

  @override
  State<MyStoresScreen> createState() => _MyStoresScreenState();
}

class _MyStoresScreenState extends State<MyStoresScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TiendaProvider>().cargarMisTiendas();
    });
  }

  void _openMenu() {
    Navigator.pushNamed(context, AppRoutes.menu);
  }

  Future<void> _onRefresh() async {
    await context.read<TiendaProvider>().cargarMisTiendas();
  }

  @override
  Widget build(BuildContext context) {
    return AppHeaderConfig(
      title: 'Mis Tiendas',
      showBack: false,
      leading: AppHeaderIconBox(icon: Icons.menu_rounded, onTap: _openMenu),
      child: Scaffold(
        backgroundColor: AppColors.ivory,
        body: Column(
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 20, 24, 0),
              child: Text(
                'Elige la tienda que quieres gestionar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.ink,
                ),
              ),
            ),
            Expanded(
              child: Consumer<TiendaProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading && provider.tiendas.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.teal),
                    );
                  }

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

                  if (provider.tiendas.isEmpty) {
                    return Center(
                      child: AddStoreItem(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const NewStoreScreen(),
                          ),
                        ),
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: _onRefresh,
                    color: AppColors.teal,
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
                              MaterialPageRoute(
                                builder: (_) => const NewStoreScreen(),
                              ),
                            ),
                          );
                        }

                        final tienda = provider.tiendas[index - 1];
                        return StoreListItem(
                          store: tienda,
                          onTap: () async {
                            // 1. Guardar la tienda seleccionada en el Provider y en SharedPreferences
                            await context.read<TiendaProvider>().seleccionarTienda(tienda.id);

                            // 2. Navegar a la pantalla principal solo si el widget sigue montado
                            if (mounted) {
                              Navigator.pushNamed(
                                context,
                                AppRoutes.summary,
                                arguments: {'tienda': tienda},
                              );
                            }
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
            ),
          ],
        ),
      ),
    );
  }
}