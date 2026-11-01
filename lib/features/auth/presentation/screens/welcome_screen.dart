import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../widgets/login_form.dart';
import '../widgets/register_client_content.dart';
import '../widgets/register_tendero_form.dart';

enum _PanelMode { welcome, login, registerTendero, registerCliente }

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  static const String _bgImage = 'assets/images/tendero.jpg';
  static const String _logo = 'assets/images/logoo.png';
  static const String _tenderoIcon = 'assets/icons/tendero.png';
  static const String _clienteIcon = 'assets/icons/cliente1.png';

  _PanelMode _mode = _PanelMode.welcome;
  bool _argsRead = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_argsRead) return;
    _argsRead = true;

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args == 'login') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _setMode(_PanelMode.login);
      });
    }
  }

  void _setMode(_PanelMode mode) {
    FocusScope.of(context).unfocus();
    setState(() => _mode = mode);
  }

  Widget _buildPanel(BoxConstraints c) {
    final loginHeight = c.maxHeight * 0.55;
    final clientHeight = c.maxHeight * 0.55;
    final tenderoHeight = c.maxHeight * 0.78;

    void toWelcome() => _setMode(_PanelMode.welcome);

    switch (_mode) {
      case _PanelMode.welcome:
        return _BottomPanel(
          key: const ValueKey('welcome'),
          onLogin: () => _setMode(_PanelMode.login),
          onRegisterTendero: () => _setMode(_PanelMode.registerTendero),
          onRegisterCliente: () => _setMode(_PanelMode.registerCliente),
          tenderoIcon: _tenderoIcon,
          clienteIcon: _clienteIcon,
        );

      case _PanelMode.login:
        return _SheetPanel(
          key: const ValueKey('login'),
          minHeight: loginHeight,
          color: AppColors.teal,
          onClose: toWelcome,
          child: LoginForm(onRegister: toWelcome, onDark: true),
        );

      case _PanelMode.registerTendero:
        return _SheetPanel(
          key: const ValueKey('tendero'),
          minHeight: tenderoHeight,
          onClose: toWelcome,
          child: RegisterTenderoForm(onLogin: () => _setMode(_PanelMode.login)),
        );

      case _PanelMode.registerCliente:
        return _SheetPanel(
          key: const ValueKey('cliente'),
          minHeight: clientHeight,
          onClose: toWelcome,
          child: const RegisterClientContent(),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final photoHeight = MediaQuery.of(context).size.height * 0.58;
    final isWelcome = _mode == _PanelMode.welcome;

    return PopScope(
      canPop: isWelcome,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _setMode(_PanelMode.welcome);
      },
      child: Scaffold(
        backgroundColor: AppColors.teal,
        body: LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              fit: StackFit.expand,
              children: [
                _Photo(path: _bgImage, height: photoHeight, zoomed: !isWelcome),
                _TopBar(logoPath: _logo, showWhatsapp: isWelcome),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: constraints.maxHeight * 0.92,
                    ),
                    child: AnimatedSize(
                      duration: const Duration(milliseconds: 400),
                      curve: Curves.easeInOutCubic,
                      alignment: Alignment.bottomCenter,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        layoutBuilder: (current, previous) => Stack(
                          alignment: Alignment.bottomCenter,
                          children: [...previous, if (current != null) current],
                        ),
                        transitionBuilder: (child, animation) {
                          final slide = Tween<Offset>(
                            begin: const Offset(0, 0.25),
                            end: Offset.zero,
                          ).animate(animation);
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: slide,
                              child: child,
                            ),
                          );
                        },
                        child: _buildPanel(constraints),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}


/// Foto de fondo con zoom animado y degradado superior.
class _Photo extends StatelessWidget {
  const _Photo({
    required this.path,
    required this.height,
    required this.zoomed,
  });

  final String path;
  final double height;
  final bool zoomed;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: height,
      child: ClipRect(
        child: AnimatedScale(
          scale: zoomed ? 1.12 : 1.0,
          alignment: Alignment.topCenter,
          duration: const Duration(milliseconds: 700),
          curve: Curves.easeOutCubic,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.asset(
                path,
                fit: BoxFit.cover,
                alignment: Alignment.centerRight,
                errorBuilder: (_, _, _) => Container(color: AppColors.skyBlue),
              ),
              const DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [Color(0x99000000), Color(0x00000000)],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Logo a la izquierda y botón de WhatsApp a la derecha.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.logoPath, required this.showWhatsapp});

  static const double _logoHeight = 64;
  static const double _whatsappSize = 48;

  static const String _whatsappPhone = '51910491787';
  static const String _whatsappMessage =
      'Hola, quiero información sobre Fiamas';
  static const String _whatsappIcon = 'assets/icons/whatsapp.png';

  final String logoPath;
  final bool showWhatsapp;

  Future<void> _openWhatsApp(BuildContext context) async {
    final uri = Uri.parse(
      'https://wa.me/$_whatsappPhone'
      '?text=${Uri.encodeComponent(_whatsappMessage)}',
    );
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir WhatsApp')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Image.asset(
                logoPath,
                height: _logoHeight,
                errorBuilder: (_, _, _) => const Text(
                  'FIAMAS',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
              AnimatedOpacity(
                opacity: showWhatsapp ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: IgnorePointer(
                  ignoring: !showWhatsapp,
                  child: GestureDetector(
                    onTap: () => _openWhatsApp(context),
                    child: Image.asset(
                      _whatsappIcon,
                      width: _whatsappSize,
                      height: _whatsappSize,
                      fit: BoxFit.contain,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.phone,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Panel teal, botón de inicio de sesión y registro.
class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    super.key,
    required this.onLogin,
    required this.onRegisterTendero,
    required this.onRegisterCliente,
    required this.tenderoIcon,
    required this.clienteIcon,
  });

  static const double _bottomSpace = 64;

  final VoidCallback onLogin;
  final VoidCallback onRegisterTendero;
  final VoidCallback onRegisterCliente;
  final String tenderoIcon;
  final String clienteIcon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(28, 36, 28, _bottomSpace),
      decoration: const BoxDecoration(
        color: AppColors.teal,
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'BIENVENIDO',
              style: textTheme.headlineLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '¡Nos alegra tenerte por aquí!',
              style: textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.gold,
                foregroundColor: AppColors.ink,
                minimumSize: const Size.fromHeight(48),
                textStyle: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              onPressed: onLogin,
              child: const Text('Inicia sesión'),
            ),
            const SizedBox(height: 28),
            Text(
              '¿No tienes cuenta?',
              style: textTheme.titleLarge?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Regístrate como:',
              style: textTheme.bodyMedium?.copyWith(color: Colors.white),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _RoleOption(
                  label: 'Tendero',
                  assetPath: tenderoIcon,
                  fallbackIcon: Icons.storefront,
                  onTap: onRegisterTendero,
                ),
                const SizedBox(width: 48),
                _RoleOption(
                  label: 'Cliente',
                  assetPath: clienteIcon,
                  fallbackIcon: Icons.person,
                  onTap: onRegisterCliente,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

/// Opción circular para elegir cómo registrarse.
class _RoleOption extends StatelessWidget {
  const _RoleOption({
    required this.label,
    required this.assetPath,
    required this.fallbackIcon,
    required this.onTap,
  });

  static const double _size = 64;

  final String label;
  final String assetPath;
  final IconData fallbackIcon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipOval(
              child: Image.asset(
                assetPath,
                width: _size,
                height: _size,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => Container(
                  width: _size,
                  height: _size,
                  color: AppColors.skyBlue,
                  child: Icon(fallbackIcon, color: AppColors.ink, size: 32),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.white),
            ),
          ],
        ),
      ),
    );
  }
}


class _SheetPanel extends StatefulWidget {
  const _SheetPanel({
    super.key,
    required this.onClose,
    required this.minHeight,
    required this.child,
    this.color = AppColors.surface,
  });

  final Color color;
  final VoidCallback onClose;
  final double minHeight;
  final Widget child;

  @override
  State<_SheetPanel> createState() => _SheetPanelState();
}

class _SheetPanelState extends State<_SheetPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  double _dragY = 0;
  double _from = 0;
  double _to = 0;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    )..addListener(() {
        final t = Curves.easeOutCubic.transform(_ctrl.value);
        setState(() => _dragY = _from + (_to - _from) * t);
      });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onDragUpdate(DragUpdateDetails d) {
    setState(() => _dragY = (_dragY + d.delta.dy).clamp(0, double.infinity));
  }

  Future<void> _onDragEnd(DragEndDetails d) async {
    final height = context.size?.height ?? widget.minHeight;
    final velocity = d.primaryVelocity ?? 0;
    final shouldClose = velocity > 700 || _dragY > height * 0.25;

    FocusScope.of(context).unfocus();
    _from = _dragY;
    _to = shouldClose ? height : 0;
    await _ctrl.forward(from: 0);

    if (shouldClose && mounted) widget.onClose();
  }

  @override
  Widget build(BuildContext context) {
    final isTeal = widget.color == AppColors.teal;

    return Transform.translate(
      offset: Offset(0, _dragY),
      child: Container(
        width: double.infinity,
        height: widget.minHeight,
        decoration: BoxDecoration(
          color: widget.color,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onVerticalDragUpdate: _onDragUpdate,
                onVerticalDragEnd: _onDragEnd,
                child: SizedBox(
                  width: double.infinity,
                  height: 44,
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 4,
                      decoration: BoxDecoration(
                        color: isTeal ? Colors.white54 : AppColors.mist,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                  child: widget.child,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}