import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_header_config.dart';
import '../../../../main.dart';
import '../../../auth/presentation/providers/tienda_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/add_store_item.dart';
import '../widgets/store_list_item.dart';
import 'new_store_screen.dart';

const String _kSoporteWhatsApp = '910491787';

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

  // FUNCIÓN PARA MOSTRAR EL MODAL DE PREMIUM
  void _mostrarDialogoPremium(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (ctx) {
        return Dialog(
          backgroundColor: AppColors.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 28, 24, 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    color: AppColors.warningSoft,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.workspace_premium_rounded,
                    color: AppColors.gold,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Función Premium',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Crear múltiples tiendas es una función Premium. '
                  'Escríbenos por WhatsApp y te daremos más información.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: AppColors.inkMuted,
                  ),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.teal,
                      foregroundColor: AppColors.onBrand,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(ctx);
                      _contactarSoporte(context);
                    },
                    child: const Text(
                      'Contactar a soporte',
                      style: TextStyle(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text(
                    'Ahora no',
                    style: TextStyle(
                      color: AppColors.inkMuted,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _contactarSoporte(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    final tiendaProvider = context.read<TiendaProvider>();
    final perfil = auth.perfil;
    final tienda = tiendaProvider.tiendaSeleccionada;

    final nombre = (perfil?.fullName.isNotEmpty ?? false)
        ? perfil!.fullName
        : (auth.user?.nombres ?? 'Tendero');
    final telefono = perfil?.telefono ?? '';
    final nombreTienda = (tienda?.nombre.isNotEmpty ?? false)
        ? tienda!.nombre
        : 'Mi tienda';

    final mensaje =
        'Hola, quiero más información sobre crear múltiples tiendas (Premium) '
        'de Fiamas. Tendero: $nombre, teléfono: $telefono. '
        'Tienda actual: $nombreTienda.';
    final uri = Uri.parse(
      'https://wa.me/$_kSoporteWhatsApp?text=${Uri.encodeComponent(mensaje)}',
    );

    var abierto = false;
    try {
      abierto = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      abierto = false;
    }

    if (!context.mounted) return;

    if (!abierto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se pudo abrir WhatsApp', style: TextStyle(color: AppColors.danger)),
          backgroundColor: AppColors.dangerSoft,
        ),
      );
    }
  }

  // FUNCIÓN QUE DECIDE SI MOSTRAR MODAL O NAVEGAR
  void _irANuevaTienda(BuildContext context) {
    final authProvider = context.read<AuthProvider>();
    final esPremium = authProvider.user?.esPremium ?? false;

    if (!esPremium) {
      _mostrarDialogoPremium(context);
    } else {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const NewStoreScreen()),
      );
    }
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
              child: RefreshIndicator(
                onRefresh: _onRefresh,
                color: AppColors.teal,
                backgroundColor: Colors.white,
                child: Consumer<TiendaProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading && provider.tiendas.isEmpty) {
                      return const Center(
                        child: CircularProgressIndicator(color: AppColors.teal),
                      );
                    }

                    if (provider.error != null && provider.tiendas.isEmpty) {
                      return LayoutBuilder(
                        builder: (context, constraints) => SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Center(
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
                            ),
                          ),
                        ),
                      );
                    }

                    if (provider.tiendas.isEmpty) {
                      return LayoutBuilder(
                        builder: (context, constraints) => SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Center(
                              child: AddStoreItem(
                                // USAR LA NUEVA FUNCIÓN
                                onTap: () => _irANuevaTienda(context),
                              ),
                            ),
                          ),
                        ),
                      );
                    }

                    return GridView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(24),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 20,
                        mainAxisSpacing: 20,
                        childAspectRatio: 0.74,
                      ),
                      itemCount: provider.tiendas.length + 1,
                      itemBuilder: (context, index) {
                        if (index == 0) {
                          return AddStoreItem(
                            // USAR LA NUEVA FUNCIÓN
                            onTap: () => _irANuevaTienda(context),
                          );
                        }

                        final tienda = provider.tiendas[index - 1];
                        return StoreListItem(
                          store: tienda,
                          onTap: () async {
                            await context.read<TiendaProvider>().seleccionarTienda(tienda.id);
                            if (context.mounted) {
                              Navigator.pushNamedAndRemoveUntil(
                                context,
                                AppRoutes.summary,
                                (route) => false,
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
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}