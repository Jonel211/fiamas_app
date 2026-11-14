import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../main.dart';
import '../providers/auth_provider.dart';
import '../screens/forgot_password_sheet.dart';

class LoginForm extends StatefulWidget {
  final VoidCallback onRegister;
  final bool onDark;

  const LoginForm({super.key, required this.onRegister, this.onDark = false});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  int _phoneLength = 0;
  int _passwordLength = 0;

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthProvider>();

    final success = await auth.login(
      identificador: _phoneController.text.trim(),
      password: _passwordController.text,
    );

    if (!mounted) return;
    if (success) {
      Navigator.pushNamedAndRemoveUntil(context, AppRoutes.stores, (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Error al iniciar sesión'),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  // ✅ ICONO OSCURO Y SIEMPRE VISIBLE (ya no se pierde sobre blanco)
  Widget _icon(IconData data) => Icon(
    data,
    size: 22,
    color: AppColors.ink, // Negro sólido para máximo contraste
  );

  Widget _toggle(bool obscured, VoidCallback onPressed) => IconButton(
    onPressed: onPressed,
    icon: Icon(
      obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
      size: 20,
      color: AppColors.inkMuted,
    ),
  );

  InputDecoration _buildDecoration({
    required Widget prefix,
    Widget? suffix,
    required bool isDark,
  }) {
    return InputDecoration(
      counterText: '',
      prefixIcon: prefix,
      suffixIcon: suffix,
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.teal, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.danger, width: 2),
      ),
      // ✅ PADDING REDUCIDO para que el input sea más compacto
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ✅ TÍTULO MÁS PEQUEÑO
          Text(
            'Inicia sesión',
            style: TextStyle(
              fontSize: 22, // Reducido de 24 → 22
              fontWeight: FontWeight.w800,
              color: widget.onDark ? Colors.white : AppColors.ink,
            ),
          ),
          const SizedBox(height: 20), // Reducido de 32 → 20

          // ✅ LABEL TELÉFONO
          Text(
            'Número de celular',
            style: TextStyle(
              fontSize: 13, // Reducido de 14 → 13
              fontWeight: FontWeight.w600,
              color: widget.onDark ? Colors.white : AppColors.ink,
            ),
          ),
          const SizedBox(height: 6), // Reducido de 8 → 6

          // ✅ CAMPO TELÉFONO
          TextFormField(
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
            ],
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: _buildDecoration(
              prefix: _icon(Icons.phone_outlined),
              isDark: widget.onDark,
            ),
            onChanged: (value) {
              setState(() => _phoneLength = value.length);
            },
            validator: (v) {
              if (v == null || v.isEmpty) return 'Ingresa tu celular';
              if (v.length != 9) return 'Debe tener 9 dígitos';
              return null;
            },
          ),

          // ✅ CONTADOR 0/9 (pegado al input, sin espacio extra)
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$_phoneLength/9',
                style: TextStyle(
                  fontSize: 11, // Reducido de 12 → 11
                  color: widget.onDark ? Colors.white70 : AppColors.inkMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12), // Reducido de 16 → 12

          // ✅ LABEL CONTRASEÑA
          Text(
            'Contraseña',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: widget.onDark ? Colors.white : AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),

          // ✅ CAMPO CONTRASEÑA
          TextFormField(
            controller: _passwordController,
            obscureText: _obscurePassword,
            inputFormatters: [
              LengthLimitingTextInputFormatter(6),
            ],
            style: const TextStyle(
              color: Colors.black,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: _buildDecoration(
              prefix: _icon(Icons.lock_outline_rounded),
              suffix: _toggle(_obscurePassword, () => setState(() => _obscurePassword = !_obscurePassword)),
              isDark: widget.onDark,
            ),
            onChanged: (value) {
              setState(() => _passwordLength = value.length);
            },
            validator: (v) {
              if (v == null || v.isEmpty) return 'Ingresa tu contraseña';
              return null;
            },
          ),

          // ✅ CONTADOR 0/6
          Padding(
            padding: const EdgeInsets.only(top: 2, right: 4),
            child: Align(
              alignment: Alignment.centerRight,
              child: Text(
                '$_passwordLength/6',
                style: TextStyle(
                  fontSize: 11,
                  color: widget.onDark ? Colors.white70 : AppColors.inkMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),

          const SizedBox(height: 8), // Reducido de 16 → 8

          // ✅ LINK OLVIDASTE CONTRASEÑA
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (context) => const ForgotPasswordSheet(),
              ),
              child: Text(
                '¿Olvidaste tu contraseña?',
                style: TextStyle(
                  color: widget.onDark ? Colors.white70 : AppColors.inkMuted,
                  fontSize: 12, // Reducido de 13 → 12
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(height: 12), // Reducido de 8 → 12 (para dar aire al botón)

          // ✅ BOTÓN INGRESAR (altura reducida)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.ink,
              minimumSize: const Size.fromHeight(46), // Reducido de 52 → 46
              textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: isLoading ? null : _handleLogin,
            icon: isLoading
                ? const SizedBox.shrink()
                : const Icon(Icons.login_rounded, size: 20),
            label: isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: AppColors.ink,
                    ),
                  )
                : const Text('Ingresar'),
          ),

          const SizedBox(height: 14), // Reducido de 20 → 14

          // ✅ LINK REGISTRARSE (siempre visible ahora)
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '¿No tienes cuenta? ',
                style: TextStyle(
                  fontSize: 13, // Reducido de 14 → 13
                  color: widget.onDark ? Colors.white70 : AppColors.inkMuted,
                  fontWeight: FontWeight.w500,
                ),
              ),
              GestureDetector(
                onTap: widget.onRegister,
                behavior: HitTestBehavior.opaque,
                child: const Text(
                  'Regístrate',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}