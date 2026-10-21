import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../main.dart'; // <-- Aseguramos que esté importado para AppRoutes
import '../widgets/store_profile_header.dart';
import '../widgets/store_profile_tiles.dart';
import '../widgets/store_profile_stats.dart';

class StoreProfileScreen extends StatefulWidget {
  const StoreProfileScreen({super.key});

  @override
  State<StoreProfileScreen> createState() => _StoreProfileScreenState();
}

class _StoreProfileScreenState extends State<StoreProfileScreen> {
  bool _notifications = true;
  bool _reminders = true;
  bool _whatsapp = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(
        backgroundColor: AppColors.ivory,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.ink, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text('Mi Tienda', style: TextStyle(color: AppColors.ink, fontSize: 18, fontWeight: FontWeight.w700)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AppColors.ink, size: 20),
            // AQUÍ ESTÁ LA CONEXIÓN AL LÁPIZ
            onPressed: () => Navigator.of(context).pushNamed(AppRoutes.editStore),
          ),
        ],
      ),
      body: ListView(
        children: [
          const StoreProfileHeader(),
          
          // 1. INFORMACIÓN DEL NEGOCIO
          _buildSectionTitle('INFORMACIÓN DEL NEGOCIO'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: const [
                ProfileInfoTile(icon: Icons.storefront_outlined, label: 'Nombre', value: 'Bodega San Antonio'),
                ProfileInfoTile(icon: Icons.badge_outlined, label: 'RUC', value: '10456789123'),
                ProfileInfoTile(icon: Icons.phone_outlined, label: 'Teléfono', value: '+51 987 654 321'),
                ProfileInfoTile(icon: Icons.location_on_outlined, label: 'Dirección', value: 'Av. Los Álamos 456, Lima'),
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

          // 3. ESTADÍSTICAS
          _buildSectionTitle('ESTADÍSTICAS'),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.6,
              children: const [
                ProfileStatCard(icon: Icons.people_outline_rounded, value: '48', label: 'Clientes'),
                ProfileStatCard(icon: Icons.inventory_2_outlined, value: '156', label: 'Productos'),
                ProfileStatCard(icon: Icons.receipt_long_outlined, value: '412', label: 'Fiados totales'),
                ProfileStatCard(icon: Icons.attach_money_rounded, value: 'S/ 945.50', label: 'Por cobrar'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // 4. ZONA DE PELIGRO
          _buildSectionTitle('ZONA DE PELIGRO', color: Colors.red),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: DeleteStoreTile(
              onTap: () => Navigator.of(context).pushNamed(AppRoutes.deleteStore),
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
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.5, color: color),
      ),
    );
  }
} 