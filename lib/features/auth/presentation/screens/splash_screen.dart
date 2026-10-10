import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import 'welcome_screen.dart';


class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  
  static const String _logo = 'assets/images/logo-oscuro.png';
  static const String _spinner = 'assets/images/spinner.png';


  static const _beforeLogo = Duration(milliseconds: 300);
  static const _logoOnly = Duration(milliseconds: 1400);
  static const _withSpinner = Duration(milliseconds: 2300);

  static const double _logoSize = 130;
  static const double _spinnerSize = 180;
  static const double _logoScaleWithSpinner = 0.55;

  late final AnimationController _rotation;

  bool _logoVisible = false;
  bool _showSpinner = false;

  @override
  void initState() {
    super.initState();

    // Giro continuo del spinner: una vuelta cada 2 segundos.
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
    await Future.wait([_precache(_logo), _precache(_spinner)]);

    await Future.delayed(_beforeLogo);
    if (!mounted) return;
    setState(() => _logoVisible = true);

    await Future.delayed(_logoOnly);
    if (!mounted) return;
    setState(() => _showSpinner = true);

    await Future.delayed(_withSpinner);
    if (!mounted) return;
    _goToWelcome();
  }

  void _goToWelcome() {
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        settings: const RouteSettings(name: '/welcome'),
        transitionDuration: const Duration(milliseconds: 600),
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
              // Spinner: puntos que giran alrededor del logo
              AnimatedOpacity(
                opacity: _showSpinner ? 1 : 0,
                duration: const Duration(milliseconds: 500),
                child: RotationTransition(
                  turns: _rotation,
                  child: Image.asset(
                    _spinner,
                    width: _spinnerSize,
                    height: _spinnerSize,
                  ),
                ),
              ),

              AnimatedOpacity(
                opacity: _logoVisible ? 1 : 0,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                child: AnimatedScale(
                  scale: _showSpinner ? _logoScaleWithSpinner : 1,
                  duration: const Duration(milliseconds: 600),
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