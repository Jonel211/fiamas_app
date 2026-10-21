import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../main.dart';

class MenuDrawer extends StatelessWidget {
  const MenuDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final userName = authProvider.user?.nombre ?? 'Usuario';
    final userPhone = ''; 

    return Drawer(
      backgroundColor: AppColors.ivory,
      child: Column(
        children: [
          // Header del drawer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(20, 60, 20, 24),
            color: AppColors.teal,
            child: Column(
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: AppColors.teal),
                ),
                const SizedBox(height: 12),
                Text(
                  userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  userPhone,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),

          // Items del menú
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                ListTile(
                  leading: Icon(Icons.home_outlined, color: AppColors.ink),
                  title: const Text('Mis Tiendas'),
                  onTap: () {
                    Navigator.pop(context); // Cerrar drawer
                    Navigator.pushNamed(context, AppRoutes.stores);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.person_outline, color: AppColors.ink),
                  title: const Text('Mi Perfil'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.profile);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.notifications_outlined,
                    color: AppColors.ink,
                  ),
                  title: const Text('Notificaciones'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.notifications);
                  },
                ),
                const Divider(height: 24),
                ListTile(
                  leading: Icon(Icons.help_outline, color: AppColors.ink),
                  title: const Text('Centro de ayuda'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.help);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.lock_outline, color: AppColors.ink),
                  title: const Text('Cambiar contraseña'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.changePassword);
                  },
                ),
                ListTile(
                  leading: Icon(
                    Icons.description_outlined,
                    color: AppColors.ink,
                  ),
                  title: const Text('Términos y condiciones'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.terms);
                  },
                ),
                ListTile(
                  leading: Icon(Icons.shield_outlined, color: AppColors.ink),
                  title: const Text('Política de privacidad'),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, AppRoutes.privacy);
                  },
                ),
              ],
            ),
          ),

          // Botón cerrar sesión
          Container(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: () async {
                await authProvider.logout();
                if (context.mounted) {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.login,
                    (route) => false,
                  );
                }
              },
              icon: const Icon(Icons.logout, color: Colors.white),
              label: const Text(
                'Cerrar sesión',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.danger,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }
}
