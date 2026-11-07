import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../auth/presentation/providers/tienda_provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header_config.dart';
import '../../../../main.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../data/plan_repository.dart';
import '../../data/sync_preferences.dart';
import '../../data/sync_service.dart';
import '../widgets/user_card.dart';
import '../widgets/menu_section.dart';
import '../widgets/menu_item.dart';
import '../widgets/logout_button.dart';

const String _kSoporteWhatsApp = '910491787';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  final SyncPreferences _syncPreferences = SyncPreferences();
  final SyncService _syncService = SyncService();

  bool _syncActiva = false;
  bool _isSyncing = false;
  bool _cargandoSync = true;
  DateTime? _ultimaSincronizacion;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().cargarPerfil();
    });
    _cargarPreferenciasSync();
  }

  Future<void> _cargarPreferenciasSync() async {
    final activa = await _syncPreferences.isSyncActiva();
    final ultima = await _syncPreferences.getUltimaSincronizacion();
    if (!mounted) return;
    setState(() {
      _syncActiva = activa;
      _ultimaSincronizacion = ultima;
      _cargandoSync = false;
    });
  }

  Future<void> _cambiarSync(bool activa) async {
    setState(() => _syncActiva = activa);
    await _syncPreferences.setSyncActiva(activa);
  }

  Future<void> _sincronizarAhora() async {
    if (!_syncActiva || _isSyncing) return;

    final tiendaProvider = context.read<TiendaProvider>();
    final auth = context.read<AuthProvider>();
    final tiendaId = tiendaProvider.tiendaSeleccionadaId ?? auth.tiendaId;

    if (tiendaId == null) {
      _mostrarSnack('No hay una tienda seleccionada');
      return;
    }

    setState(() => _isSyncing = true);
    final exito = await _syncService.sincronizar(tiendaId);
    final ultima = await _syncPreferences.getUltimaSincronizacion();

    if (!mounted) return;

    setState(() {
      _isSyncing = false;
      _ultimaSincronizacion = ultima;
    });

    _mostrarSnack(
      exito ? 'Sincronización completada' : 'No se pudo sincronizar',
      error: !exito,
    );
  }

  void _mostrarSnack(String mensaje, {bool error = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          mensaje,
          style: TextStyle(color: error ? AppColors.danger : AppColors.onBrand),
        ),
        backgroundColor: error ? AppColors.dangerSoft : AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatearFecha(DateTime fecha) {
    final dia = fecha.day.toString().padLeft(2, '0');
    final mes = fecha.month.toString().padLeft(2, '0');
    final anio = fecha.year.toString();
    final hora = fecha.hour.toString().padLeft(2, '0');
    final minuto = fecha.minute.toString().padLeft(2, '0');
    return '$dia/$mes/$anio $hora:$minuto';
  }

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
                  'La sincronización de datos en la nube es una función '
                  'Premium. Escríbenos por WhatsApp y te daremos más '
                  'información.',
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
                      _contactarSoporte();
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

  Future<void> _contactarSoporte() async {
    final auth = context.read<AuthProvider>();
    final perfil = auth.perfil;
    final tienda = context.read<TiendaProvider>().tiendaSeleccionada;

    final nombre = (perfil?.fullName.isNotEmpty ?? false)
        ? perfil!.fullName
        : (auth.user?.nombre ?? 'Tendero');
    final telefono = perfil?.telefono ?? '';
    final nombreTienda = (tienda?.nombre.isNotEmpty ?? false)
        ? tienda!.nombre
        : 'Mi tienda';

    final mensaje =
        'Hola, quiero más información sobre la Sincronización de datos en '
        'la nube (Premium) de Fiamas. Tendero: $nombre, teléfono: $telefono. '
        'Tienda: $nombreTienda.';
    final uri = Uri.parse(
      'https://wa.me/$_kSoporteWhatsApp?text=${Uri.encodeComponent(mensaje)}',
    );

    var abierto = false;
    try {
      abierto = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {
      abierto = false;
    }

    if (!mounted) return;

    if (!abierto) {
      _mostrarSnack('No se pudo abrir WhatsApp', error: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppHeaderConfig(
      title: 'Menú',
      showBack: true,
      centerTitle: true,
      child: Scaffold(
        backgroundColor: AppColors.background,
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
              final isPremium = PlanRepository(perfil).isPremium;
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
                        icon: Icons.workspace_premium_rounded,
                        iconColor: AppColors.gold,
                        iconBackgroundColor: AppColors.warningSoft,
                        title: 'Sincronización de datos en la nube',
                        titleTrailing: const _PremiumBadge(),
                        showChevron: false,
                        onTap: isPremium
                            ? null
                            : () => _mostrarDialogoPremium(context),
                        trailing: isPremium
                            ? Switch(
                                value: _syncActiva,
                                activeThumbColor: AppColors.teal,
                                onChanged: _cambiarSync,
                              )
                            : GestureDetector(
                                onTap: () => _mostrarDialogoPremium(context),
                                child: const IgnorePointer(
                                  child: Switch(
                                    value: false,
                                    onChanged: null,
                                    thumbColor: WidgetStatePropertyAll(
                                      AppColors.surface,
                                    ),
                                    trackColor: WidgetStatePropertyAll(
                                      AppColors.surfaceMuted,
                                    ),
                                    trackOutlineColor: WidgetStatePropertyAll(
                                      AppColors.mist,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      if (isPremium)
                        Padding(
                          padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _cargandoSync
                                    ? 'Cargando estado de sincronización...'
                                    : _ultimaSincronizacion == null
                                    ? 'Aún no sincronizado'
                                    : 'Última sincronización: '
                                          '${_formatearFecha(_ultimaSincronizacion!)}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: AppColors.inkMuted,
                                ),
                              ),
                              const SizedBox(height: 10),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.teal,
                                    foregroundColor: AppColors.onBrand,
                                    elevation: 0,
                                    minimumSize: const Size.fromHeight(44),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: _syncActiva && !_isSyncing
                                      ? _sincronizarAhora
                                      : null,
                                  icon: _isSyncing
                                      ? const SizedBox(
                                          width: 18,
                                          height: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppColors.onBrand,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.cloud_sync_rounded,
                                          size: 20,
                                        ),
                                  label: Text(
                                    _isSyncing
                                        ? 'Sincronizando...'
                                        : 'Sincronizar ahora',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                        onTap: () =>
                            Navigator.of(context)
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
            color: AppColors.surface,
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
                    color: AppColors.mist,
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
                      color: AppColors.tealSoft,
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: AppColors.background,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: AppColors.mist),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.link_rounded,
                      color: AppColors.teal,
                      size: 22,
                    ),
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
                            content: Text(
                              '¡Enlace copiado al portapapeles!',
                              style: TextStyle(color: AppColors.onBrand),
                            ),
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
                        backgroundColor: AppColors.whatsapp,
                        foregroundColor: AppColors.onBrand,
                        minimumSize: const Size.fromHeight(48),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      icon: const Icon(
                        Icons.chat_bubble_outline_rounded,
                        size: 20,
                      ),
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
                          await launchUrl(
                            uri,
                            mode: LaunchMode.externalApplication,
                          );
                        } catch (_) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'No se pudo abrir WhatsApp',
                                  style: TextStyle(color: AppColors.danger),
                                ),
                                backgroundColor: AppColors.dangerSoft,
                              ),
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
                              const SnackBar(
                                content: Text(
                                  'No se pudo abrir la app de mensajes',
                                  style: TextStyle(color: AppColors.danger),
                                ),
                                backgroundColor: AppColors.dangerSoft,
                              ),
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

class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Text(
        'PREMIUM',
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.4,
          color: AppColors.gold,
        ),
      ),
    );
  }
}
