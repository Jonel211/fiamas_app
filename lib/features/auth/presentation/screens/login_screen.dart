import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/auth_field.dart';
import '../../../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Logo vertical (bolsa arriba, "FIAMAS" abajo), versión oscura.
  static const String _logo = 'assets/images/fiamas-vertical.png';

  // Altura de la franja azul y tamaño con el que se dibuja el logo.
  static const double _headerHeight = 240;
  static const double _logoHeight = 200;

  final _formKey = GlobalKey<FormState>();
  final _identifierController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pushNamed(AppRoutes.stores);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.skyBlue,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            // Rellena la pantalla y, si el teclado ocupa espacio, se desplaza.
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  // ── Cabecera azul claro con logo ───────────
                  SizedBox(
                    height: _headerHeight,
                    child: Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.center,
                      children: [
                        OverflowBox(
                          maxWidth: double.infinity,
                          maxHeight: double.infinity,
                          child: Image.asset(
                            _logo,
                            height: _logoHeight,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Text(
                              'FIAMAS',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w800,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // ── Panel blanco con el formulario ─────────
                  Expanded(
                    child: Container(
                      width: double.infinity,
                      padding: EdgeInsets.fromLTRB(
                        24,
                        28,
                        24,
                        24 + MediaQuery.of(context).padding.bottom,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.surface,
                        borderRadius:
                            BorderRadius.vertical(top: Radius.circular(32)),
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              '¡Ingresa ya!',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 20),

                            AuthField(
                              label: 'Teléfono',
                              controller: _identifierController,
                              keyboardType: TextInputType.phone,
                              digitsOnly: true,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Ingresa tu teléfono'
                                  : null,
                            ),
                            AuthField(
                              label: 'Contraseña',
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              bottomSpacing: 4,
                              suffixIcon: IconButton(
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  size: 20,
                                  color: AppColors.inkMuted,
                                ),
                              ),
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Ingresa tu contraseña'
                                  : null,
                            ),

                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  // TODO: flujo de recuperación de contraseña
                                },
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.ink,
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 4, vertical: 8),
                                ),
                                child: const Text(
                                  '¿Olvidaste tu contraseña?',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),

                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.teal,
                                foregroundColor: Colors.white,
                                minimumSize: const Size.fromHeight(48),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: _handleLogin,
                              child: const Text('Ver mi cuenta'),
                            ),
                          ],
                        ),
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
  }
}