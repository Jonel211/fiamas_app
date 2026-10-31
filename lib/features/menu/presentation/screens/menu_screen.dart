import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../auth/presentation/providers/tienda_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header_config.dart';
import '../../../../main.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
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
    return AppHeaderConfig(
      title: 'Menú',
      showBack: true,
      centerTitle: true,
      child: Scaffold(
        backgroundColor: AppColors.ivory,
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
          child: Consumer<AuthProvider>(
            builder: (context, authProvider, _) {
              final perfil = authProvider.perfil;
              final userName = perfil?.fullName.isNotEmpty == true
                  ? perfil!.fullName
                  : (authProvider.user?.nombre ?? 'Usuario');
              final userPhone =
                  (perfil?.telefono != null && perfil!.telefono.isNotEmpty)
                  ? '+51 ${perfil.telefono}'
                  : 'Sin teléfono';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  UserCard(
                    name: userName,
                    phone: userPhone,
                    imageUrl: perfil?.fotoUrl,
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
                        showChevron: false,
                        trailing: Switch(
                          value: _autoBackup,
                          activeThumbColor: AppColors.teal,
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
                        icon: Icons.lock_outline_rounded,
                        title: 'Cambiar contraseña',
                        onTap: () => Navigator.of(context)
                            .pushNamed(AppRoutes.changePassword),
                      ),
                      MenuItem(
                        icon: Icons.share_outlined,
                        title: 'Compartir aplicación',
                        showChevron: true,
                        onTap: () => _mostrarModalCompartir(context),
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
                            Navigator.of(context).pushNamed(AppRoutes.terms),
                      ),
                      MenuItem(
                        icon: Icons.shield_outlined,
                        title: 'Política de privacidad',
                        onTap: () =>
                            Navigator.of(context).pushNamed(AppRoutes.privacy),
                      ),
                      MenuItem(
                        icon: Icons.info_outline_rounded,
                        title: 'Acerca de Fiamas',
                        subtitle: 'Versión 1.0.0',
                        onTap: () =>
                            Navigator.of(context).pushNamed(AppRoutes.about),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  LogoutButton(
                    onTap: () async {
                      final tiendaProvider = context.read<TiendaProvider>();
                      final auth = context.read<AuthProvider>();

                      await tiendaProvider.limpiarSesion();
                      await auth.logout();

                      if (context.mounted) AppRoutes.goToLogin(context);
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  // MODAL PARA COMPARTIR LA APP
  void _mostrarModalCompartir(BuildContext context) {
    const appLink = 'https://fiamas.app/descargar';
    const shareMessage =
        '¡Hola! Te invito a usar Fiamas para gestionar tus compras y fiados de forma rápida, segura y transparente. Descarga la aplicación aquí: $appLink';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            24 + MediaQuery.of(ctx).padding.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Indicador superior
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Encabezado
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.teal.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.share_rounded,
                      color: AppColors.teal,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Compartir Fiamas',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Invita a clientes u otros tenderos',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.inkMuted),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Caja con el enlace
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.mist),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.link_rounded, color: AppColors.teal, size: 22),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        appLink,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.ink,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton.icon(
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.teal,
                        visualDensity: VisualDensity.compact,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: const Text('Copiar'),
                      onPressed: () {
                        Clipboard.setData(const ClipboardData(text: appLink));
                        Navigator.pop(ctx);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('¡Enlace copiado al portapapeles!'),
                            backgroundColor: AppColors.teal,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Canales rápidos
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF25D366),
                        foregroundColor: Colors.white,
                        minimumSize: const Size.fromHeight(48),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                      label: const Text(
                        'WhatsApp',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final uri = Uri.parse(
                          'https://wa.me/?text=${Uri.encodeComponent(shareMessage)}',
                        );
                        try {
                          await launchUrl(uri, mode: LaunchMode.externalApplication);
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No se pudo abrir WhatsApp')),
                            );
                          }
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.ink,
                        side: const BorderSide(color: AppColors.mist),
                        minimumSize: const Size.fromHeight(48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(Icons.sms_outlined, size: 20),
                      label: const Text(
                        'SMS',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      onPressed: () async {
                        Navigator.pop(ctx);
                        final uri = Uri.parse(
                          'sms:?body=${Uri.encodeComponent(shareMessage)}',
                        );
                        try {
                          await launchUrl(uri);
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('No se pudo abrir la app de mensajes')),
                            );
                          }
                        }
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}
