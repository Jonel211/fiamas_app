import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/gradient_button.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../../main.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _dniController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _nameController.dispose();
    _dniController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _handleRegister() {
    if (_formKey.currentState?.validate() ?? false) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.stores,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  children: [
                  
                    Stack(
                      children: [
                        Container(
                          width: double.infinity,
                          height: 190,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Color(0xFFDCEDE8), Color(0xFFF4F9F7)],
                            ),
                          ),
                          child: Center(
                            child: Container(
                              width: 88,
                              height: 88,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.teal.withValues(alpha: 0.15),
                                    blurRadius: 20,
                                    offset: const Offset(0, 8),
                                  ),
                                ],
                              ),
                              child: const Icon(Icons.storefront,
                                  color: AppColors.teal, size: 38),
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 12,
                          child: SafeArea(
                            bottom: false,
                            child: IconButton(
                              onPressed: () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.arrow_back,
                                  color: AppColors.ink),
                              style: IconButton.styleFrom(
                                backgroundColor:
                                    Colors.white.withValues(alpha: 0.9),
                                padding: const EdgeInsets.all(10),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                    Transform.translate(
                      offset: const Offset(0, -28),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius:
                              const BorderRadius.vertical(top: Radius.circular(28)),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.ink.withValues(alpha: 0.08),
                              blurRadius: 24,
                              offset: const Offset(0, -4),
                            ),
                          ],
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const Text(
                                'Crea tu cuenta',
                                style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.ink),
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Empieza a digitalizar tu tienda hoy',
                                style:
                                    TextStyle(fontSize: 13, color: AppColors.inkMuted),
                              ),
                              const SizedBox(height: 20),
                              LabeledField(
                                label: 'Nombres completos',
                                hint: 'Ej: Juan Pérez',
                                icon: Icons.person_outline,
                                controller: _nameController,
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Ingresa tu nombre'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              LabeledField(
                                label: 'DNI',
                                hint: '8 dígitos',
                                icon: Icons.badge_outlined,
                                keyboardType: TextInputType.number,
                                controller: _dniController,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Ingresa tu DNI';
                                  if (v.length != 8) {
                                    return 'El DNI debe tener 8 dígitos';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              LabeledField(
                                label: 'Número de celular',
                                hint: 'Ej: 987 654 321',
                                icon: Icons.phone_outlined,
                                keyboardType: TextInputType.phone,
                                controller: _phoneController,
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Ingresa tu celular'
                                    : null,
                              ),
                              const SizedBox(height: 16),
                              LabeledField(
                                label: 'Crea una contraseña',
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
                                      () => _obscurePassword = !_obscurePassword),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Crea una contraseña';
                                  }
                                  if (v.length < 6) return 'Mínimo 6 caracteres';
                                  return null;
                                },
                              ),
                              const SizedBox(height: 16),
                              LabeledField(
                                label: 'Confirmar contraseña',
                                hint: '••••••••',
                                icon: Icons.lock_outline,
                                obscureText: _obscureConfirmPassword,
                                controller: _confirmPasswordController,
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureConfirmPassword
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 20,
                                    color: AppColors.inkMuted,
                                  ),
                                  onPressed: () => setState(() =>
                                      _obscureConfirmPassword =
                                          !_obscureConfirmPassword),
                                ),
                                validator: (v) {
                                  if (v == null || v.isEmpty) {
                                    return 'Confirma tu contraseña';
                                  }
                                  if (v != _passwordController.text) {
                                    return 'Las contraseñas no coinciden';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 20),
                              GradientButton(
                                label: 'Registrarme',
                                icon: Icons.check_circle_outline,
                                onPressed: _handleRegister,
                              ),
                              const SizedBox(height: 20),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text('¿Ya tienes una cuenta? ',
                                      style: TextStyle(
                                          fontSize: 13, color: AppColors.inkMuted)),
                                  GestureDetector(
                                    onTap: () => Navigator.of(context).pop(),
                                    child: const Text(
                                      'Inicia sesión',
                                      style: TextStyle(
                                        color: AppColors.teal,
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}