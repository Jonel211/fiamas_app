import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../main.dart';
import '../../../auth/data/models/tienda_model.dart';
import '../../../auth/presentation/providers/tienda_provider.dart';
import '../widgets/store_profile_header.dart';
import '../widgets/store_profile_tiles.dart';
import '../widgets/store_profile_stats.dart';

class StoreProfileScreen extends StatefulWidget {
  final TiendaModel? tienda;

  const StoreProfileScreen({super.key, this.tienda});

  @override
  State<StoreProfileScreen> createState() => _StoreProfileScreenState();
}

class _StoreProfileScreenState extends State<StoreProfileScreen> {
  bool _notifications = true;
  bool _reminders = true;
  bool _whatsapp = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<TiendaProvider>().cargarMisTiendas();
    });
  }

  @override
  Widget build(BuildContext context) {
    final routeArg = ModalRoute.of(context)?.settings.arguments;
    final tiendas = context.watch<TiendaProvider>().tiendas;
    final TiendaModel? tienda = widget.tienda ??
        (routeArg is TiendaModel ? routeArg : null) ??
        (tiendas.isNotEmpty ? tiendas.first : null);

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        children: [
          AppHeader(
            title: tienda?.nombre ?? 'Mi Tienda',
            showBack: true,
            centerTitle: true,
            actions: [
              if (tienda != null)
                AppHeaderIconAction(
                  icon: Icons.edit_outlined,
                  onTap: () async {
                    await Navigator.of(context).pushNamed(
                      AppRoutes.editStore,
                      arguments: tienda,
                    );
                    if (context.mounted) {
                      context.read<TiendaProvider>().cargarMisTiendas();
                    }
                  },
                ),
            ],
          ),
          Expanded(
            child: ListView(
              children: [
                StoreProfileHeader(
                  storeName: tienda?.nombre ?? 'Mi Tienda',
                  status: 'Activa',
                  subtitle: (tienda?.direccion != null && tienda!.direccion!.isNotEmpty)
                      ? tienda.direccion!
                      : 'Tienda registrada en Fiamas',
                ),

                // 1. INFORMACIÓN DEL NEGOCIO
                _buildSectionTitle('INFORMACIÓN DEL NEGOCIO'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      ProfileInfoTile(
                        icon: Icons.storefront_outlined,
                        label: 'Nombre',
                        value: tienda?.nombre ?? 'Sin nombre',
                      ),
                      ProfileInfoTile(
                        icon: Icons.badge_outlined,
                        label: 'RUC',
                        value: (tienda?.ruc != null && tienda!.ruc!.isNotEmpty)
                            ? tienda.ruc!
                            : 'No registrado',
                      ),
                      ProfileInfoTile(
                        icon: Icons.phone_outlined,
                        label: 'Teléfono',
                        value: (tienda?.telefono != null && tienda!.telefono!.isNotEmpty)
                            ? tienda.telefono!
                            : 'No registrado',
                      ),
                      ProfileInfoTile(
                        icon: Icons.location_on_outlined,
                        label: 'Dirección',
                        value: (tienda?.direccion != null && tienda!.direccion!.isNotEmpty)
                            ? tienda.direccion!
                            : 'Sin dirección',
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 2. PREFERENCIAS
                _buildSectionTitle('PREFERENCIAS'),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      ProfileSwitchTile(
                        icon: Icons.notifications_none_rounded,
                        label: 'Notificaciones de la tienda',
                        value: _notifications,
                        onChanged: (v) => setState(() => _notifications = v),
                      ),
                      ProfileSwitchTile(
                        icon: Icons.history_rounded,
                        label: 'Recordatorios automáticos',
                        value: _reminders,
                        onChanged: (v) => setState(() => _reminders = v),
                      ),
                      ProfileSwitchTile(
                        icon: Icons.chat_bubble_outline_rounded,
                        label: 'Enviar cobros por WhatsApp',
                        value: _whatsapp,
                        onChanged: (v) => setState(() => _whatsapp = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // 3. ZONA DE PELIGRO
                _buildSectionTitle('ZONA DE PELIGRO', color: Colors.red),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: DeleteStoreTile(
                    onTap: () => Navigator.of(context).pushNamed(
                      AppRoutes.deleteStore,
                      arguments: tienda,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {Color color = AppColors.inkMuted}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
          color: color,
        ),
      ),
    );
  }
}