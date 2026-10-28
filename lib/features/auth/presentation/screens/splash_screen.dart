import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/main_shell.dart';
import '../providers/auth_provider.dart';
import 'welcome_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  
  static const String _logo = 'assets/images/logo-oscuro.png';

  static const _beforeLogo = Duration(milliseconds: 300);
  static const _logoOnly = Duration(milliseconds: 1200);
  static const _withSpinner = Duration(milliseconds: 2500);

  static const double _logoSize = 120;
  static const double _spinnerSize = 180;
  static const double _logoScaleWithSpinner = 0.6;

  late final AnimationController _rotation;

  bool _logoVisible = false;
  bool _showSpinner = false;

  @override
  void initState() {
    super.initState();

    // Giro continuo del spinner de puntos: una vuelta cada 2 segundos.
    _rotation = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    WidgetsBinding.instance.addPostFrameCallback((_) => _runSequence());
  }

  @override
  void dispose() {
    _rotation.dispose();
    super.dispose();
  }

  Future<void> _precache(String path) {
    return precacheImage(AssetImage(path), context, onError: (_, __) {});
  }

  Future<void> _runSequence() async {
    // 1. Verificamos sesión y precargamos el logo en paralelo
    final authFuture = context.read<AuthProvider>().checkAuthStatus();
    await _precache(_logo);

    await Future.delayed(_beforeLogo);
    if (!mounted) return;
    setState(() => _logoVisible = true);

    await Future.delayed(_logoOnly);
    if (!mounted) return;
    setState(() => _showSpinner = true);

    await Future.delayed(_withSpinner);
    if (!mounted) return;

    // 2. Evaluamos resultado de sesión y redirigimos
    final isLoggedIn = await authFuture;
    if (!mounted) return;

    if (isLoggedIn) {
      _goToHome();
    } else {
      _goToWelcome();
    }
  }

  void _goToHome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        settings: const RouteSettings(name: '/summary'),
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const MainShellScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  void _goToWelcome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        settings: const RouteSettings(name: '/welcome'),
        transitionDuration: const Duration(milliseconds: 500),
        pageBuilder: (_, __, ___) => const WelcomeScreen(),
        transitionsBuilder: (_, animation, __, child) =>
            FadeTransition(opacity: animation, child: child),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.skyBlue,
      body: Center(
        child: SizedBox(
          width: _spinnerSize,
          height: _spinnerSize,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Spinner de puntos giratorio basado en tu referencia
              AnimatedOpacity(
                opacity: _showSpinner ? 1 : 0,
                duration: const Duration(milliseconds: 400),
                child: RotationTransition(
                  turns: _rotation,
                  child: CustomPaint(
                    size: const Size(_spinnerSize, _spinnerSize),
                    painter: _DottedSpinnerPainter(color: AppColors.teal),
                  ),
                ),
              ),

              // Logo central con animación de aparición y escala
              AnimatedOpacity(
                opacity: _logoVisible ? 1 : 0,
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOut,
                child: AnimatedScale(
                  scale: _showSpinner ? _logoScaleWithSpinner : 1,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  child: Image.asset(
                    _logo,
                    width: _logoSize,
                    height: _logoSize,
                    fit: BoxFit.contain,
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

// ─── Pintor personalizado para los puntos circulares ─────────
class _DottedSpinnerPainter extends CustomPainter {
  final Color color;
  _DottedSpinnerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 14;
    const int count = 10; // Cantidad de puntos en el círculo
    final dotRadius = size.width * 0.05; // Radio de cada punto

    for (int i = 0; i < count; i++) {
      final double angle = (i * 2 * pi) / count;
      final Offset dotCenter = Offset(
        center.dx + radius * cos(angle),
        center.dy + radius * sin(angle),
      );

      // Opacidad progresiva para dar el efecto de estela de carga
      final double opacity = (i + 1) / count;
      final paint = Paint()
        ..color = color.withOpacity(opacity)
        ..style = PaintingStyle.fill;

      canvas.drawCircle(dotCenter, dotRadius, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}