import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../main.dart';
import '../widgets/menu_app_bar.dart';
import '../widgets/user_card.dart';
import '../widgets/menu_section.dart';
import '../widgets/menu_item.dart';
import '../widgets/logout_button.dart';

/// Pantalla "Menú" del tendero.
/// Se abre al tocar la hamburguesa en "Mis Tiendas".
class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool _autoBackup = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        children: [
          const MenuAppBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Tarjeta de usuario
                  const UserCard(
                    name: 'Jonel Villanueva',
                    phone: '999999999',
                  ),
                  const SizedBox(height: 24),

                  // Sección: DATOS Y RESPALDO
                  MenuSection(
                    title: 'Datos y respaldo',
                    children: [
                      MenuItem(
                        icon: Icons.sync_rounded,
                        title: 'Respaldo automático',
                        subtitle: 'Última vez: hoy a las 3 AM',
                        showChevron: false,
                        trailing: Switch(
                          value: _autoBackup,
                          activeColor: AppColors.teal,
                          onChanged: (v) => setState(() => _autoBackup = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Sección: SOPORTE
                  MenuSection(
                    title: 'Soporte',
                    children: [
                      MenuItem(
                        icon: Icons.help_outline_rounded,
                        title: 'Centro de ayuda',
                        subtitle: 'Guías y tutoriales',
                        onTap: () =>
                            Navigator.of(context).pushNamed(AppRoutes.help),
                      ),
                      MenuItem(
                        icon: Icons.report_gmailerrorred_rounded,
                        title: 'Atención de reclamos',
                        showChevron: false,
                        onTap: () {},
                      ),
                      MenuItem(
                        icon: Icons.lock_outline_rounded,
                        title: 'Cambiar contraseña',
                        onTap: () {},
                      ),
                      MenuItem(
                        icon: Icons.share_outlined,
                        title: 'Compartir aplicación',
                        showChevron: false,
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Sección: LEGAL
                  MenuSection(
                    title: 'Legal',
                    children: [
                      MenuItem(
                        icon: Icons.description_outlined,
                        title: 'Términos y condiciones',
                        onTap: () {},
                      ),
                      MenuItem(
                        icon: Icons.shield_outlined,
                        title: 'Política de privacidad',
                        onTap: () {},
                      ),
                      MenuItem(
                        icon: Icons.info_outline_rounded,
                        title: 'Acerca de Fiamas',
                        subtitle: 'Versión 1.0.0',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Botón cerrar sesión
                  LogoutButton(
                    onTap: () {
                      // Limpia la pila de navegación y va al login
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        AppRoutes.login,
                        (route) => false,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}