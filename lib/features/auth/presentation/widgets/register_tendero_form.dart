import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/widgets/auth_field.dart';
import '../../../../core/widgets/main_shell.dart';
import '../../../../main.dart';
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

  Timer? _debounceDni;
  Timer? _debouncePhone;
  bool _isCheckingDni = false;
  bool _isCheckingPhone = false;
  String? _dniErrorMessage;
  String? _phoneErrorMessage;

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
    _debounceDni?.cancel();
    _debouncePhone?.cancel();
    super.dispose();
  }

  void _verificarDuplicado(String campo, String valor) {
    if (campo == 'dni') {
      _debounceDni?.cancel();
    } else if (campo == 'phone') {
      _debouncePhone?.cancel();
    }

    if ((campo == 'dni' && valor.length != 8) ||
        (campo == 'phone' && valor.length != 9)) {
      return;
    }

    final timer = Timer(const Duration(milliseconds: 800), () async {
      if (!mounted) return;

      setState(() {
        if (campo == 'dni') _isCheckingDni = true;
        if (campo == 'phone') _isCheckingPhone = true;
      });

      try {
        final dio = DioClient.create();
        final response = await dio.get(
          '/tenderos/verificar-duplicado',
          queryParameters: {
            if (campo == 'dni') 'dni': valor,
            if (campo == 'phone') 'telefono': valor,
          },
        );

        if (!mounted) return;

        setState(() {
          final existe = response.data['existe'] == true;
          if (existe) {
            final mensaje = response.data['mensaje'] ??
                (campo == 'dni'
                    ? 'Este DNI ya está registrado'
                    : 'Este teléfono ya está registrado');

            if (campo == 'dni') _dniErrorMessage = mensaje;
            if (campo == 'phone') _phoneErrorMessage = mensaje;
          } else {
            if (campo == 'dni') _dniErrorMessage = null;
            if (campo == 'phone') _phoneErrorMessage = null;
          }
        });
      } on DioException {
        if (!mounted) return;
        setState(() {
          if (campo == 'dni') _dniErrorMessage = 'Error de conexión';
          if (campo == 'phone') _phoneErrorMessage = 'Error de conexión';
        });
      } catch (_) {
        if (!mounted) return;
        setState(() {
          if (campo == 'dni') _dniErrorMessage = 'Error al verificar';
          if (campo == 'phone') _phoneErrorMessage = 'Error al verificar';
        });
      } finally {
        if (mounted) {
          setState(() {
            if (campo == 'dni') _isCheckingDni = false;
            if (campo == 'phone') _isCheckingPhone = false;
          });
        }
      }
    });

    if (campo == 'dni') _debounceDni = timer;
    if (campo == 'phone') _debouncePhone = timer;
  }

  Future<void> _handleRegister() async {
    if (_dniErrorMessage != null || _phoneErrorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Corrige los campos marcados en rojo antes de continuar.'),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    final phone = _phoneController.text.trim();

    final isVerified = await Navigator.of(context).pushNamed(
      AppRoutes.verification,
      arguments: phone,
    );

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

  Widget _buildErrorIconWithTooltip(String mensaje) {
    return Tooltip(
      message: mensaje,
      preferBelow: true,
      waitDuration: const Duration(milliseconds: 100),
      showDuration: const Duration(seconds: 3),
      decoration: BoxDecoration(
        color: Colors.red.shade700,
        borderRadius: BorderRadius.circular(8),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      textStyle: const TextStyle(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: const Icon(Icons.error, color: Colors.red, size: 20),
    );
  }

  Widget _buildIcon(IconData data) => Icon(data, size: 20, color: AppColors.teal);

  Widget _buildTogglePassword(bool obscured, VoidCallback onPressed) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        obscured ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        size: 20,
        color: AppColors.inkMuted,
      ),
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
          const Text(
            'Crear tu cuenta',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.ink),
          ),
          const SizedBox(height: 6),
          const Text(
            'Empieza a digitalizar tu tienda hoy',
            style: TextStyle(fontSize: 14, color: AppColors.inkMuted),
          ),
          const SizedBox(height: 20),
          AuthField(
            label: 'Nombres completos',
            controller: _nameController,
            textCapitalization: TextCapitalization.words,
            prefixIcon: _buildIcon(Icons.person_outline_rounded),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa tu nombre' : null,
          ),
          AuthField(
            label: 'DNI',
            controller: _dniController,
            keyboardType: TextInputType.number,
            maxLength: 8,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(8),
            ],
            prefixIcon: _buildIcon(Icons.badge_outlined),
            suffixIcon: _isCheckingDni
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : (_dniErrorMessage != null
                    ? _buildErrorIconWithTooltip(_dniErrorMessage!)
                    : (_dniController.text.length == 8
                        ? const Icon(Icons.check, color: Colors.green, size: 20)
                        : null)),
            onChanged: (val) {
              _verificarDuplicado('dni', val);
              if (_dniErrorMessage != null && mounted) {
                setState(() => _dniErrorMessage = null);
              }
            },
            validator: (v) {
              if (v == null || v.isEmpty) return 'Ingresa tu DNI';
              if (v.length != 8) return 'El DNI debe tener 8 dígitos';
              if (_dniErrorMessage != null) return _dniErrorMessage;
              return null;
            },
          ),
          AuthField(
            label: 'Número de celular',
            controller: _phoneController,
            keyboardType: TextInputType.phone,
            maxLength: 9,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(9),
            ],
            prefixIcon: _buildIcon(Icons.phone_outlined),
            suffixIcon: _isCheckingPhone
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : (_phoneErrorMessage != null
                    ? _buildErrorIconWithTooltip(_phoneErrorMessage!)
                    : (_phoneController.text.length == 9
                        ? const Icon(Icons.check, color: Colors.green, size: 20)
                        : null)),
            onChanged: (val) {
              _verificarDuplicado('phone', val);
              if (_phoneErrorMessage != null && mounted) {
                setState(() => _phoneErrorMessage = null);
              }
            },
            validator: (v) {
              if (v == null || v.isEmpty) return 'Ingresa tu celular';
              if (v.length != 9) return 'El celular debe tener 9 dígitos';
              if (_phoneErrorMessage != null) return _phoneErrorMessage;
              return null;
            },
          ),
          AuthField(
            label: 'Nombre de la tienda',
            controller: _storeNameController,
            textCapitalization: TextCapitalization.words,
            prefixIcon: _buildIcon(Icons.storefront_outlined),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa el nombre de tu tienda' : null,
          ),
          AuthField(
            label: 'Dirección / Ubicación',
            controller: _addressController,
            textCapitalization: TextCapitalization.sentences,
            prefixIcon: _buildIcon(Icons.location_on_outlined),
            validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa la dirección' : null,
          ),
          AuthField(
            label: 'RUC (Opcional)',
            controller: _rucController,
            keyboardType: TextInputType.number,
            maxLength: 11,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              LengthLimitingTextInputFormatter(11),
            ],
            prefixIcon: _buildIcon(Icons.receipt_long_outlined),
            validator: (v) {
              if (v != null && v.isNotEmpty && v.length != 11) return 'El RUC debe tener 11 dígitos';
              return null;
            },
          ),
          AuthField(
            label: 'Crear una contraseña (Máx. 6)',
            controller: _passwordController,
            obscureText: _obscurePassword,
            inputFormatters: [LengthLimitingTextInputFormatter(6)],
            prefixIcon: _buildIcon(Icons.lock_outline_rounded),
            suffixIcon: _buildTogglePassword(
              _obscurePassword,
              () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) {
              if (v == null || v.isEmpty) return 'Crea una contraseña';
              if (v.length > 6) return 'Máximo 6 caracteres';
              return null;
            },
          ),
          AuthField(
            label: 'Confirmar contraseña',
            controller: _confirmPasswordController,
            obscureText: _obscureConfirmPassword,
            inputFormatters: [LengthLimitingTextInputFormatter(6)],
            prefixIcon: _buildIcon(Icons.lock_outline_rounded),
            suffixIcon: _buildTogglePassword(
              _obscureConfirmPassword,
              () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
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
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: AppColors.ink),
                  )
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