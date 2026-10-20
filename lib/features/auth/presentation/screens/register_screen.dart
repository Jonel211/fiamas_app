import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../../../../core/widgets/main_shell.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../main.dart';
import '../providers/auth_provider.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  static const String _logo = 'assets/images/logo-os.png';
  static const double _headerHeight = 130;
  static const double _logoHeight = 240;

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

    final role = ModalRoute.of(context)?.settings.arguments as String?;
    final isTendero = role != 'cliente';

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

  final success = await authProvider.registerTendero(
        dni: _dniController.text.trim(),
        nombres: _nameController.text.trim(),
        apellidos: ' ',
        telefono: _phoneController.text.trim(),
        password: _passwordController.text,
        nombreTienda: isTendero ? _storeNameController.text.trim() : '',
      );

    if (!mounted) return;

    if (success) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => MainShellScreen()),
        (route) => false,
      );
    } else {
      final error = authProvider.errorMessage;
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Error al registrar'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final role = ModalRoute.of(context)?.settings.arguments as String?;
    final isTendero = role != 'cliente';

    return Scaffold(
      backgroundColor: AppColors.skyBlue,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
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
            Expanded(
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
                ),
                child: Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    if (auth.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    return SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(
                        24,
                        28,
                        24,
                        24 + MediaQuery.of(context).padding.bottom,
                      ),
                      child: Form(
                        key: _formKey,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const Text(
                              'Crear tu cuenta',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.ink,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              isTendero
                                  ? 'Empieza a digitalizar tu tienda hoy'
                                  : 'Empieza a llevar tus fiados al día',
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.ink,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 20),
                            _Field(
                              label: 'Nombres completos',
                              controller: _nameController,
                              textCapitalization: TextCapitalization.words,
                              validator: (v) => (v == null || v.trim().isEmpty)
                                  ? 'Ingresa tu nombre'
                                  : null,
                            ),
                            _Field(
                              label: 'DNI',
                              controller: _dniController,
                              keyboardType: TextInputType.number,
                              maxLength: 8,
                              digitsOnly: true,
                              validator: (v) {
                                if (v == null || v.isEmpty)
                                  return 'Ingresa tu DNI';
                                if (v.length != 8) {
                                  return 'El DNI debe tener 8 dígitos';
                                }
                                return null;
                              },
                            ),
                            _Field(
                              label: 'Número de celular',
                              controller: _phoneController,
                              keyboardType: TextInputType.phone,
                              maxLength: 9,
                              digitsOnly: true,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Ingresa tu celular';
                                }
                                if (v.length != 9) {
                                  return 'El celular debe tener 9 dígitos';
                                }
                                return null;
                              },
                            ),
                            if (isTendero) ...[
                              _Field(
                                label: 'Nombre de la tienda',
                                controller: _storeNameController,
                                textCapitalization: TextCapitalization.words,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Ingresa el nombre de tu tienda'
                                    : null,
                              ),
                              _Field(
                                label: 'Dirección / Ubicación',
                                controller: _addressController,
                                textCapitalization:
                                    TextCapitalization.sentences,
                                validator: (v) =>
                                    (v == null || v.trim().isEmpty)
                                    ? 'Ingresa la dirección'
                                    : null,
                              ),
                              _Field(
                                label: 'RUC (Opcional)',
                                controller: _rucController,
                                keyboardType: TextInputType.number,
                                maxLength: 11,
                                digitsOnly: true,
                                validator: (v) {
                                  if (v != null &&
                                      v.isNotEmpty &&
                                      v.length != 11) {
                                    return 'El RUC debe tener 11 dígitos';
                                  }
                                  return null;
                                },
                              ),
                            ],
                            _Field(
                              label: 'Crear una contraseña',
                              controller: _passwordController,
                              obscureText: _obscurePassword,
                              suffixIcon: _VisibilityToggle(
                                obscured: _obscurePassword,
                                onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword,
                                ),
                              ),
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Crea una contraseña';
                                }
                                if (v.length < 6) return 'Mínimo 6 caracteres';
                                return null;
                              },
                            ),
                            _Field(
                              label: 'Confirmar contraseña',
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              suffixIcon: _VisibilityToggle(
                                obscured: _obscureConfirmPassword,
                                onPressed: () => setState(
                                  () => _obscureConfirmPassword =
                                      !_obscureConfirmPassword,
                                ),
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
                            const SizedBox(height: 24),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.gold,
                                foregroundColor: AppColors.ink,
                                minimumSize: const Size.fromHeight(48),
                                textStyle: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              onPressed: _handleRegister,
                              child: const Text('Registrarme'),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  '¿Ya tienes cuenta? ',
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: AppColors.ink,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.of(context)
                                      .pushReplacementNamed(AppRoutes.login),
                                  child: const Text(
                                    'Inicia sesión',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.teal,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  const _Field({
    required this.label,
    required this.controller,
    this.validator,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.maxLength,
    this.digitsOnly = false,
    this.textCapitalization = TextCapitalization.none,
  });

  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final int? maxLength;
  final bool digitsOnly;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            validator: validator,
            keyboardType: keyboardType,
            obscureText: obscureText,
            maxLength: maxLength,
            textCapitalization: textCapitalization,
            inputFormatters: digitsOnly
                ? [FilteringTextInputFormatter.digitsOnly]
                : null,
            style: const TextStyle(fontSize: 15, color: AppColors.ink),
            decoration: InputDecoration(
              counterText: '',
              isDense: true,
              suffixIcon: suffixIcon,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 14,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.mist),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.mist),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VisibilityToggle extends StatelessWidget {
  const _VisibilityToggle({required this.obscured, required this.onPressed});

  final bool obscured;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 20,
        color: AppColors.inkMuted,
      ),
    );
  }
}
