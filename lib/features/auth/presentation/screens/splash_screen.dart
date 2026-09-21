import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    // Animación de opacidad para todo el contenido
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.8, curve: Curves.easeOut),
      ),
    );

    // Animación de deslizamiento (entra desde abajo hacia arriba)
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
          ),
        );

    _mainController.forward();

    // Navegar al login después de 4 segundos
    Timer(const Duration(milliseconds: 4000), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, // Fondo blanco limpio como en tu diseño
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 👇 LOGO CIRCULAR CON LA BOLSA 👇
                Container(
                  width: 140,
                  height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(25),
                    child: Image.asset(
                      'assets/images/icono_fiamas.png', // 👈 Tu imagen de la bolsa
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // 👇 TEXTO "Fiamas." 👇
                Text(
                  'Fiamas.',
                  style: GoogleFonts.poppins(
                    fontSize: 36,
                    fontWeight: FontWeight.w700, // Negrita como en la imagen
                    color: const Color(
                      0xFF0F172A,
                    ), // Color negro/azulado oscuro
                    letterSpacing: 1,
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
