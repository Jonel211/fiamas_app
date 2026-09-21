import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../main.dart';
import '../../../client_portal/presentation/screens/client_login_screen.dart';
import '../../data/auth_repository.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController(); // 👈 DNI o teléfono
  final _passwordController = TextEditingController();

  final _authRepository = AuthRepository();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    final result = await _authRepository.loginTendero(
      identifier: _identifierController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('¡Bienvenido de nuevo!'),
          backgroundColor: Color(0xFF0E7C7B),
          duration: Duration(seconds: 2),
        ),
      );
      Navigator.of(context).pushNamed(AppRoutes.stores);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['error'] ?? 'Error al iniciar sesión'),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusBarHeight = MediaQuery.of(context).padding.top;
    const double headerHeight = 350;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Stack(
        children: [
          // Header con imagen difuminada
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: headerHeight + statusBarHeight,
            child: Stack(
              fit: StackFit.expand,
              children: [
                Container(color: AppColors.ink),
                Opacity(
                  opacity: 0.30,
                  child: Image.asset(
                    'assets/images/tienda.jpg',
                    fit: BoxFit.cover,
                  ),
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 2.0, sigmaY: 2.0),
                  child: Container(color: Colors.black.withValues(alpha: 0.2)),
                ),
              ],
            ),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: constraints.maxHeight,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Positioned(
                              top: 0,
                              left: 0,
                              right: 0,
                              height: headerHeight,
                              child: Padding(
                                padding: const EdgeInsets.only(top: 82),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 52,
                                      height: 52,
                                      alignment: Alignment.center,
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(14),
                                        boxShadow: [
                                          BoxShadow(
                                            color: AppColors.ink.withValues(
                                              alpha: 0.12,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 4),
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.storefront_outlined,
                                        color: AppColors.ink,
                                        size: 24,
                                      ),
                                    ),
                                    const SizedBox(height: 10),
                                    const Text(
                                      'Fiamas',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 20,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      'Para el tendero peruano',
                                      style: TextStyle(
                                        color: Colors.white.withValues(
                                          alpha: 0.85,
                                        ),
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 250),
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.fromLTRB(
                                  24,
                                  24,
                                  24,
                                  20,
                                ),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(32),
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.18,
                                      ),
                                      blurRadius: 30,
                                      offset: const Offset(0, -8),
                                    ),
                                  ],
                                ),
                                child: Form(
                                  key: _formKey,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      const Text(
                                        'Ingresar a mi tienda',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.ink,
                                        ),
                                      ),
                                      const SizedBox(height: 16),

                                      // 🔥 CAMBIO: ahora es DNI o teléfono
                                      LabeledField(
                                        label: 'DNI o número de celular',
                                        hint: 'Ej: 72839485',
                                        icon: Icons.badge_outlined,
                                        keyboardType: TextInputType.number,
                                        controller: _identifierController,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Ingresa tu DNI o celular';
                                          }
                                          if (value.length < 8) {
                                            return 'Debe tener al menos 8 dígitos';
                                          }
                                          return null;
                                        },
                                      ),
                                      const SizedBox(height: 16),

                                      LabeledField(
                                        label: 'Contraseña',
                                        hint: '••••••••',
                                        icon: Icons.lock_outline,
                                        obscureText: _obscurePassword,
                                        controller: _passwordController,
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _obscurePassword
                                                ? Icons.visibility_off_outlined
                                                : Icons.visibility_outlined,
                                            size: 20,
                                            color: AppColors.inkMuted,
                                          ),
                                          onPressed: () => setState(
                                            () => _obscurePassword =
                                                !_obscurePassword,
                                          ),
                                        ),
                                        validator: (value) =>
                                            (value == null || value.isEmpty)
                                            ? 'Ingresa tu contraseña'
                                            : null,
                                      ),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: TextButton(
                                          onPressed: () {
                                            // TODO: flujo de recuperación
                                          },
                                          style: TextButton.styleFrom(
                                            foregroundColor: AppColors.ink,
                                          ),
                                          child: const Text(
                                            '¿Olvidaste tu clave?',
                                            style: TextStyle(
                                              fontSize: 13,
                                              decoration:
                                                  TextDecoration.underline,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),

                                      // Botón con estado de carga
                                      GradientButton(
                                        label: _isLoading
                                            ? 'Ingresando...'
                                            : 'Entrar',
                                        icon: Icons.arrow_forward,
                                        onPressed: _isLoading
                                            ? null
                                            : _handleLogin,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
                          child: Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text(
                                    '¿No tienes cuenta? ',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: AppColors.inkMuted,
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const RegisterScreen(),
                                      ),
                                    ),
                                    child: const Text(
                                      'Regístrate aquí',
                                      style: TextStyle(
                                        color: AppColors.ink,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              OutlinedButton.icon(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (_) => const ClientLoginScreen(),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.person_outline,
                                  size: 18,
                                ),
                                label: const Text(
                                  '¿Eres cliente? Mira tu cuenta',
                                ),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: AppColors.ink,
                                  side: const BorderSide(color: AppColors.mist),
                                  minimumSize: const Size.fromHeight(48),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
