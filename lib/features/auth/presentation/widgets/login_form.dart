import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/auth_field.dart';
import '../../../../main.dart';
import '../providers/auth_provider.dart';

/// Aparece con fade + deslizamiento. `index` define el retraso (cascada).
class FadeSlideIn extends StatelessWidget {
  const FadeSlideIn({super.key, required this.index, required this.child});

  final int index; // 0, 1, 2...
  final Widget child;

  @override
  Widget build(BuildContext context) {
    const total = 900; // ms
    final start = (index * 90) / total;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: total),
      curve: Interval(start, 1, curve: Curves.easeOutCubic),
      builder: (_, v, c) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 18 * (1 - v)),
          child: c,
        ),
      ),
      child: child,
    );
  }
}

/// Formulario de login reutilizable (panel y pantalla).
class LoginForm extends StatefulWidget {
  const LoginForm({super.key, required this.onRegister});

  /// Acción al tocar "Regístrate".
  final VoidCallback onRegister;

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
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

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      identificador: _identifierController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;

    if (success) {
      final user = auth.user;
      if (user == null) return;

      if (user.isTendero) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRoutes.stores, (route) => false);
      } else if (user.isCliente) {
        Navigator.of(context)
            .pushNamedAndRemoveUntil(AppRoutes.menu, (route) => false);
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Error al iniciar sesión'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Título con ícono
          const FadeSlideIn(
            index: 0,
            child: Row(
              children: [
                Text(
                  '¡Ingresa ya!',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Teléfono
          FadeSlideIn(
            index: 1,
            child: AuthField(
              label: 'Teléfono',
              controller: _identifierController,
              keyboardType: TextInputType.phone,
              digitsOnly: true,
              prefixIcon: const Icon(
                Icons.phone_outlined,
                size: 20,
                color: AppColors.teal,
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Ingresa tu teléfono' : null,
            ),
          ),

          // Contraseña
          FadeSlideIn(
            index: 2,
            child: AuthField(
              label: 'Contraseña',
              controller: _passwordController,
              obscureText: _obscurePassword,
              bottomSpacing: 4,
              prefixIcon: const Icon(
                Icons.lock_outline_rounded,
                size: 20,
                color: AppColors.teal,
              ),
              suffixIcon: IconButton(
                onPressed: () =>
                    setState(() => _obscurePassword = !_obscurePassword),
                icon: Icon(
                  _obscurePassword
                      ? Icons.visibility_off_outlined
                      : Icons.visibility_outlined,
                  size: 20,
                  color: AppColors.inkMuted,
                ),
              ),
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'Ingresa tu contraseña' : null,
            ),
          ),

          // ¿Olvidaste tu contraseña?
          FadeSlideIn(
            index: 3,
            child: Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () =>
                    Navigator.of(context).pushNamed(AppRoutes.forgotPassword),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.ink,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                ),
                icon: const Icon(Icons.help_outline_rounded, size: 16),
                label: const Text(
                  '¿Olvidaste tu contraseña?',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Botón Ingresar
          FadeSlideIn(
            index: 4,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(48),
                textStyle:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              onPressed: auth.isLoading ? null : _handleLogin,
              icon: auth.isLoading
                  ? const SizedBox.shrink()
                  : const Icon(Icons.login_rounded, size: 20),
              label: auth.isLoading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Ingresar'),
            ),
          ),
          const SizedBox(height: 24),

          // ¿No tienes cuenta?
          FadeSlideIn(
            index: 5,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  '¿No tienes cuenta? ',
                  style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
                ),
                GestureDetector(
                  onTap: widget.onRegister,
                  behavior: HitTestBehavior.opaque,
                  child: const Text(
                    'Regístrate',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.teal,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}