import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/auth_field.dart';
import '../../../../core/widgets/main_shell.dart';
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
      Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (_) => const MainShellScreen()), (route) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.errorMessage ?? 'Error al iniciar sesión'), backgroundColor: AppColors.danger, behavior: SnackBarBehavior.floating));
    }
  }

  Widget _icon(IconData data) => Icon(data, size: 20, color: AppColors.ink);

  Widget _toggle(bool obscured, VoidCallback onPressed) => IconButton(
    onPressed: onPressed,
    icon: Icon(obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: AppColors.inkMuted),
  );

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Inicia sesión', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: widget.onDark ? Colors.white : AppColors.ink)),
          const SizedBox(height: 24),
          
          // ✅ TELÉFONO: Máximo 9 dígitos
          AuthField(
            label: 'Número de celular',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 9, 
            digitsOnly: true,
            onDark: widget.onDark,
            prefixIcon: _icon(Icons.phone_outlined),
            validator: (v) => (v == null || v.isEmpty) ? 'Ingresa tu celular' : (v.length != 9 ? 'Debe tener 9 dígitos' : null),
          ),
          
          // ✅ CONTRASEÑA: Máximo 6 dígitos
          AuthField(
            label: 'Contraseña',
            controller: _passwordController,
            obscureText: _obscurePassword,
            maxLength: 6,
            onDark: widget.onDark,
            prefixIcon: _icon(Icons.lock_outline_rounded),
            suffixIcon: _toggle(_obscurePassword, () => setState(() => _obscurePassword = !_obscurePassword)),
            validator: (v) => (v == null || v.isEmpty) ? 'Ingresa tu contraseña' : null,
          ),
          
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => showModalBottomSheet(context: context, isScrollControlled: true, backgroundColor: Colors.transparent, builder: (context) => const ForgotPasswordSheet()),
              child: Text('¿Olvidaste tu contraseña?', style: TextStyle(color: widget.onDark ? Colors.white70 : AppColors.inkMuted, fontSize: 13, fontWeight: FontWeight.w600)),
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.gold, foregroundColor: AppColors.ink, minimumSize: const Size.fromHeight(48), textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
            onPressed: isLoading ? null : _handleLogin,
            icon: isLoading ? const SizedBox.shrink() : const Icon(Icons.login_rounded, size: 20),
            label: isLoading ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.ink)) : const Text('Ingresar'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('¿No tienes cuenta? ', style: TextStyle(fontSize: 13, color: widget.onDark ? Colors.white70 : AppColors.inkMuted)),
              GestureDetector(
                onTap: widget.onRegister,
                behavior: HitTestBehavior.opaque,
                child: Text('Regístrate', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: widget.onDark ? Colors.white : AppColors.teal)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}