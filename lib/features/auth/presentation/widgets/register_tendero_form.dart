import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/auth_field.dart';
import '../../../../core/widgets/main_shell.dart';
import '../../../../main.dart'; // ✅ Para AppRoutes
import '../providers/auth_provider.dart';

class RegisterTenderoForm extends StatefulWidget {
  const RegisterTenderoForm({super.key, required this.onLogin});
  final VoidCallback onLogin;

  @override
  State<RegisterTenderoForm> createState() => _RegisterTenderoFormState();
}

class _RegisterTenderoFormState extends State<RegisterTenderoForm> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dniController = TextEditingController();
  final _phoneController = TextEditingController();
  final _storeNameController = TextEditingController();
  final _addressController = TextEditingController();
  final _rucController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _dniController.dispose();
    _phoneController.dispose();
    _storeNameController.dispose();
    _addressController.dispose();
    _rucController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final phone = _phoneController.text.trim();

    //  PASO 1: Navegar a la pantalla de verificación OTP
    final isVerified = await Navigator.of(context).pushNamed(
      AppRoutes.verification, // Asegúrate de que esta ruta apunte a VerificationScreen
      arguments: phone,
    );

    //  PASO 2: Si la verificación fue exitosa (devolvió true), proceder con el registro
    if (isVerified == true && mounted) {
      final auth = context.read<AuthProvider>();
      final success = await auth.registerTendero(
        dni: _dniController.text.trim(),
        nombres: _nameController.text.trim(),
        apellidos: ' ',
        telefono: phone,
        password: _passwordController.text,
        nombreTienda: _storeNameController.text.trim(),
      );

      if (!mounted) return;

      if (success) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainShellScreen()),
          (route) => false,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(auth.errorMessage ?? 'Error al registrar'),
            backgroundColor: AppColors.danger,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  Widget _icon(IconData data) => Icon(data, size: 20, color: AppColors.teal);

  Widget _toggle(bool obscured, VoidCallback onPressed) => IconButton(
        onPressed: onPressed,
        icon: Icon(
          obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
          size: 20,
          color: AppColors.inkMuted,
        ),
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
          const Text('Crear tu cuenta', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.ink)),
          const SizedBox(height: 6),
          const Text('Empieza a digitalizar tu tienda hoy', style: TextStyle(fontSize: 14, color: AppColors.inkMuted)),
          const SizedBox(height: 20),
          AuthField(
            label: 'Nombres completos',
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            prefixIcon: _icon(Icons.person_outline_rounded),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu nombre' : null,
          ),
          AuthField(
            label: 'DNI',
            controller: _dniController,
            keyboardType: TextInputType.number,
            maxLength: 8,
            digitsOnly: true,
            prefixIcon: _icon(Icons.badge_outlined),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Ingresa tu DNI';
              if (v.length != 8) return 'El DNI debe tener 8 dígitos';
              return null;
            },
          ),
          AuthField(
            label: 'Número de celular',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 9,
            digitsOnly: true,
            prefixIcon: _icon(Icons.phone_outlined),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Ingresa tu celular';
              if (v.length != 9) return 'El celular debe tener 9 dígitos';
              return null;
            },
          ),
          AuthField(
            label: 'Nombre de la tienda',
            controller: _storeNameController,
            textCapitalization: TextCapitalization.words,
            prefixIcon: _icon(Icons.storefront_outlined),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa el nombre de tu tienda' : null,
          ),
          AuthField(
            label: 'Dirección / Ubicación',
            controller: _addressController,
            textCapitalization: TextCapitalization.sentences,
            prefixIcon: _icon(Icons.location_on_outlined),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa la dirección' : null,
          ),
          AuthField(
            label: 'RUC (Opcional)',
            controller: _rucController,
            keyboardType: TextInputType.number,
            maxLength: 11,
            digitsOnly: true,
            prefixIcon: _icon(Icons.receipt_long_outlined),
            validator: (v) {
              if (v != null && v.isNotEmpty && v.length != 11) return 'El RUC debe tener 11 dígitos';
              return null;
            },
          ),
          AuthField(
            label: 'Crear una contraseña',
            controller: _passwordController,
            obscureText: _obscurePassword,
            prefixIcon: _icon(Icons.lock_outline_rounded),
            suffixIcon: _toggle(_obscurePassword, () => setState(() => _obscurePassword = !_obscurePassword)),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Crea una contraseña';
              if (v.length < 6) return 'Mínimo 6 caracteres';
              return null;
            },
          ),
          AuthField(
            label: 'Confirmar contraseña',
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            prefixIcon: _icon(Icons.lock_outline_rounded),
            suffixIcon: _toggle(_obscureConfirmPassword, () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword)),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Confirma tu contraseña';
              if (v != _passwordController.text) return 'Las contraseñas no coinciden';
              return null;
            },
          ),
          const SizedBox(height: 8),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.gold,
              foregroundColor: AppColors.ink,
              minimumSize: const Size.fromHeight(48),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            onPressed: isLoading ? null : _handleRegister,
            icon: isLoading ? const SizedBox.shrink() : const Icon(Icons.how_to_reg_rounded, size: 20),
            label: isLoading
                ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.ink))
                : const Text('Registrarme'),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('¿Ya tienes cuenta? ', style: TextStyle(fontSize: 13, color: AppColors.inkMuted)),
              GestureDetector(
                onTap: widget.onLogin,
                behavior: HitTestBehavior.opaque,
                child: const Text('Inicia sesión', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.teal)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}