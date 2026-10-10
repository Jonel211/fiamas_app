import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  // ── Rutas (coinciden con AppRoutes en main.dart) ───────────
  static const String _routeLogin = '/login';
  static const String _routeRegister = '/register';
  static const String _routeRegisterClient = '/register-client';

  // ── Assets ─────────────────────────────────────────────────
  static const String _bgImage = 'assets/images/tendero.jpg';
  static const String _logo = 'assets/images/logo.png';
  static const String _tenderoIcon = 'assets/icons/tendero.png';
  static const String _clienteIcon = 'assets/icons/cliente1.png';

  @override
  Widget build(BuildContext context) {
    final photoHeight = MediaQuery.of(context).size.height * 0.58;

    return Scaffold(
      backgroundColor: AppColors.teal,
      body: Stack(
        fit: StackFit.expand,
        children: [
          _Photo(path: _bgImage, height: photoHeight),
          const _TopBar(logoPath: _logo),
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomPanel(
              onLogin: () => Navigator.pushNamed(context, _routeLogin),
              onRegisterTendero: () => Navigator.pushNamed(
                context,
                _routeRegister,
                arguments: 'tendero',
              ),
              onRegisterCliente: () =>
                  Navigator.pushNamed(context, _routeRegisterClient),
              tenderoIcon: _tenderoIcon,
              clienteIcon: _clienteIcon,
            ),
          ),
        ],
      ),
    );
  }
}

/// Foto de fondo. Es más alta que el panel para que las esquinas
/// redondeadas del panel se vean sobre la foto.
class _Photo extends StatelessWidget {
  const _Photo({required this.path, required this.height});

  final String path;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: height,
      child: Image.asset(
        path,
        fit: BoxFit.cover,
        // La foto es horizontal: se alinea a la derecha para que se vean
        // el tendero y la clienta. (-1 = izquierda, 0 = centro, 1 = derecha)
        alignment: Alignment.centerRight,
        errorBuilder: (_, _, _) => Container(color: AppColors.skyBlue),
      ),
    );
  }
}

/// Logo a la izquierda e ícono decorativo de contacto a la derecha.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.logoPath});

  static const double _logoHeight = 64;

  final String logoPath;

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
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: AppColors.whatsapp,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.phone, color: Colors.white, size: 26),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Panel teal inferior: saludo, botón de inicio de sesión y registro.
class _BottomPanel extends StatelessWidget {
  const _BottomPanel({
    required this.onLogin,
    required this.onRegisterTendero,
    required this.onRegisterCliente,
    required this.tenderoIcon,
    required this.clienteIcon,
  });

  // Espacio bajo los íconos. Más alto = todo el bloque sube.
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