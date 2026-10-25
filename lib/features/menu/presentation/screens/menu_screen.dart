import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../main.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/menu_app_bar.dart';
import '../widgets/user_card.dart';
import '../widgets/menu_section.dart';
import '../widgets/menu_item.dart';
import '../widgets/logout_button.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  bool _autoBackup = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().cargarPerfil();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        children: [
          // ✅ AppBar teal con flecha atrás y "Menu" centrado
          const MenuAppBar(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              child: Consumer<AuthProvider>(
                builder: (context, authProvider, _) {
                  final perfil = authProvider.perfil;
                  final userName = perfil?.fullName.isNotEmpty == true
                      ? perfil!.fullName
                      : (authProvider.user?.nombre ?? 'Usuario');
                  final userPhone = (perfil?.telefono != null && perfil!.telefono.isNotEmpty)
                      ? '+51 ${perfil.telefono}'
                      : 'Sin teléfono';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [

                      UserCard(
                        name: userName,
                        phone: userPhone,
                        onTap: () =>
                            Navigator.of(context).pushNamed(AppRoutes.profile),
                      ),
                      const SizedBox(height: 24),
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
                            onTap: () =>
                                Navigator.of(context)
                                    .pushNamed(AppRoutes.changePassword),
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


                      MenuSection(
                        title: 'Legal',
                        children: [
                          MenuItem(
                            icon: Icons.description_outlined,
                            title: 'Términos y condiciones',
                            onTap: () =>
                                Navigator.of(context)
                                    .pushNamed(AppRoutes.terms),
                          ),
                          MenuItem(
                            icon: Icons.shield_outlined,
                            title: 'Política de privacidad',
                            onTap: () =>
                                Navigator.of(context)
                                    .pushNamed(AppRoutes.privacy),
                          ),
                          MenuItem(
                            icon: Icons.info_outline_rounded,
                            title: 'Acerca de Fiamas',
                            subtitle: 'Versión 1.0.0',
                            onTap: () =>
                                Navigator.of(context)
                                    .pushNamed(AppRoutes.about),
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),


                      LogoutButton(
                        onTap: () async {
                          await authProvider.logout();
                          if (context.mounted) {
                            Navigator.of(context).pushNamedAndRemoveUntil(
                              AppRoutes.login,
                              (route) => false,
                            );
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
