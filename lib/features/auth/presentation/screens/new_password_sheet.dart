import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/auth_field.dart';
import '../../../../core/widgets/modal_bottom_sheet_layout.dart';
import '../../../../core/widgets/step_indicator.dart';
import '../providers/auth_provider.dart';
import '../../../../main.dart';

class NewPasswordSheet extends StatefulWidget {
  final String phone;
  const NewPasswordSheet({super.key, required this.phone});

  @override
  State<NewPasswordSheet> createState() => _NewPasswordSheetState();
}

class _NewPasswordSheetState extends State<NewPasswordSheet> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _update() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    final auth = context.read<AuthProvider>();

    final success = await auth.resetPassword(
      identificador: widget.phone,
      nuevaPassword: _passwordController.text,
    );

    if (!mounted) return;
    if (success) {
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Contraseña actualizada correctamente. Ya puedes iniciar sesión.'), backgroundColor: AppColors.success));
      AppRoutes.goToLogin(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(auth.errorMessage ?? 'Error al actualizar la contraseña'), backgroundColor: AppColors.danger));
    }
  }

  Widget _toggle(bool obscured, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined, size: 20, color: AppColors.inkMuted),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return ModalBottomSheetLayout(
      title: '¡Actualiza tu contraseña!',
      subtitle: null,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const StepIndicator(currentStep: 3),
          const SizedBox(height: 24),
          Form(
            key: _formKey,
            child: Column(
              children: [
                // ✅ NUEVA CONTRASEÑA: Máximo 6 dígitos
                AuthField(
                  label: 'Nueva contraseña',
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  maxLength: 6,
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.teal),
                  suffixIcon: _toggle(_obscurePassword, () => setState(() => _obscurePassword = !_obscurePassword)),
                  validator: (v) => (v == null || v.isEmpty || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                ),
                // ✅ CONFIRMAR CONTRASEÑA: Máximo 6 dígitos
                AuthField(
                  label: 'Confirmar nueva contraseña',
                  controller: _confirmController,
                  obscureText: _obscureConfirm,
                  maxLength: 6,
                  prefixIcon: const Icon(Icons.lock_outline, color: AppColors.teal),
                  suffixIcon: _toggle(_obscureConfirm, () => setState(() => _obscureConfirm = !_obscureConfirm)),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Confirma tu contraseña';
                    if (v != _passwordController.text) return 'Las contraseñas no coinciden';
                    return null;
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(48), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: isLoading ? null : _update,
            child: isLoading ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white)) : const Text('Actualizar contraseña', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 12),
          TextButton(onPressed: isLoading ? null : () => Navigator.of(context).pop(), child: const Text('Cancelar', style: TextStyle(color: AppColors.inkMuted, fontWeight: FontWeight.w600))),
        ],
      ),
    );
  }
}