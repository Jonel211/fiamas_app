import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/hardware/photo_picker.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/widgets/labeled_field.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import 'store_photo_picker.dart';

/// Datos que captura el formulario de tienda.
class StoreFormData {
  const StoreFormData({
    required this.name,
    required this.address,
    this.ruc = '',
    this.phone = '',
    this.logo,
  });

  final String name;
  final String address;
  final String ruc;
  final String phone;
  final File? logo;
}

/// Formulario compartido por "Nueva Tienda" y "Editar Tienda".
class StoreForm extends StatefulWidget {
  const StoreForm({
    super.key,
    required this.submitLabel,
    required this.onSubmit,
    this.initialName = '',
    this.initialAddress = '',
    this.initialRuc = '',
    this.initialPhone = '',
    this.initialLogoUrl,
  });

  final String submitLabel;
  final ValueChanged<StoreFormData> onSubmit;
  final String initialName;
  final String initialAddress;
  final String initialRuc;
  final String initialPhone;
  final String? initialLogoUrl;

  @override
  State<StoreForm> createState() => _StoreFormState();
}

class _StoreFormState extends State<StoreForm> {
  final _formKey = GlobalKey<FormState>();
  late final _nameController = TextEditingController(text: widget.initialName);
  late final _addressController = TextEditingController(
    text: widget.initialAddress,
  );
  late final _rucController = TextEditingController(text: widget.initialRuc);
  late final _phoneController = TextEditingController(
    text: widget.initialPhone,
  );
  File? _logo;

  //  Estado de validación de teléfono (en tiempo real, vía API)
  Timer? _debouncePhone;
  bool _isCheckingPhone = false;
  String? _phoneErrorMessage;

  //  Estado de validación de RUC (en tiempo real, local)
  String? _rucErrorMessage;

  @override
  void dispose() {
    _debouncePhone?.cancel();
    _nameController.dispose();
    _addressController.dispose();
    _rucController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  /// Valida el RUC en vivo: 11 dígitos numéricos y prefijo válido (10 o 20).
  void _validarRuc(String valor) {
    _debouncePhone?.cancel(); // no aplica, pero mantiene consistencia

    if (valor.isEmpty) {
      if (_rucErrorMessage != null) setState(() => _rucErrorMessage = null);
      return;
    }

    if (valor.length != 11) {
      setState(() => _rucErrorMessage = 'El RUC debe tener 11 dígitos');
      return;
    }

    // RUC peruano válido: empieza con 10 (persona natural) o 20 (empresa)
    final prefijo = valor.substring(0, 2);
    if (prefijo != '10' && prefijo != '20') {
      setState(() => _rucErrorMessage = 'El RUC debe empezar con 10 o 20');
      return;
    }

    setState(() => _rucErrorMessage = null);
  }

  /// Verifica en tiempo real si el teléfono de la tienda ya está registrado.
  void _verificarTelefonoTienda(String valor) {
    _debouncePhone?.cancel();

    if (valor.isEmpty || valor.length != 9) {
      if (_phoneErrorMessage != null) {
        setState(() => _phoneErrorMessage = null);
      }
      return;
    }

    _debouncePhone = Timer(const Duration(milliseconds: 800), () async {
      if (!mounted) return;
      setState(() => _isCheckingPhone = true);

      try {
        final dio = DioClient.create();
        final tenderoId = context.read<AuthProvider>().user?.id;

        final response = await dio.get(
          '/tenderos/verificar-duplicado',
          queryParameters: {
            'telefono': valor,
            'tendero_id': ?tenderoId,
          },
        );

        if (!mounted) return;
        setState(() {
          final existe = response.data['existe'] == true;
          _phoneErrorMessage = existe
              ? (response.data['mensaje'] ?? 'Este teléfono ya está registrado')
              : null;
        });
      } catch (_) {
        if (!mounted) return;
        setState(() => _phoneErrorMessage = 'Error al verificar');
      } finally {
        if (mounted) setState(() => _isCheckingPhone = false);
      }
    });
  }

  Future<void> _pickLogo() async {
    final file = await PhotoPicker.pick(context);
    if (file == null || !mounted) return;
    setState(() => _logo = file);
  }

  void _submit() {
    if (_phoneErrorMessage != null || _rucErrorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Corrige los campos marcados en rojo antes de continuar.',
          ),
          backgroundColor: AppColors.danger,
        ),
      );
      return;
    }

    if (!(_formKey.currentState?.validate() ?? false)) return;

    widget.onSubmit(
      StoreFormData(
        name: _nameController.text.trim(),
        address: _addressController.text.trim(),
        ruc: _rucController.text.trim(),
        phone: _phoneController.text.trim(),
        logo: _logo,
      ),
    );
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
          BoxShadow(color: Colors.black26, blurRadius: 6, offset: Offset(0, 2)),
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

  Widget _buildPhoneSuffix() {
    if (_isCheckingPhone) {
      return const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    if (_phoneErrorMessage != null) {
      return _buildErrorIconWithTooltip(_phoneErrorMessage!);
    }
    if (_phoneController.text.length == 9) {
      return const Icon(Icons.check, color: Colors.green, size: 20);
    }
    return const SizedBox.shrink();
  }

  Widget _buildRucSuffix() {
    if (_rucErrorMessage != null) {
      return _buildErrorIconWithTooltip(_rucErrorMessage!);
    }
    if (_rucController.text.length == 11) {
      return const Icon(Icons.check, color: Colors.green, size: 20);
    }
    return const SizedBox.shrink();
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: StorePhotoPicker(
                imageUrl: widget.initialLogoUrl,
                localFile: _logo,
                onTap: _pickLogo,
              ),
            ),
            const SizedBox(height: 36),
            LabeledField(
              label: 'Nombre de la tienda',
              hint: '',
              controller: _nameController,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Ingresa el nombre de tu tienda'
                  : null,
            ),
            const SizedBox(height: 20),
            LabeledField(
              label: 'Dirección / Ubicación',
              hint: '',
              controller: _addressController,
              validator: (v) => (v == null || v.trim().isEmpty)
                  ? 'Ingresa la dirección'
                  : null,
            ),
            const SizedBox(height: 20),
            //  RUC con validación EN VIVO + restricción a 11 dígitos numéricos
            LabeledField(
              label: 'RUC (Opcional)',
              hint: '',
              keyboardType: TextInputType.number,
              maxLength: 11,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(11),
              ],
              controller: _rucController,
              onChanged: _validarRuc,
              suffixIcon: _buildRucSuffix(),
              validator: (v) {
                if (v == null || v.isEmpty) return null; // opcional
                if (_rucErrorMessage != null) return _rucErrorMessage;
                return null;
              },
            ),
            const SizedBox(height: 20),
            //  Teléfono con validación EN VIVO vía API
            LabeledField(
              label: 'Teléfono (Opcional)',
              hint: '',
              keyboardType: TextInputType.phone,
              maxLength: 9,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(9),
              ],
              controller: _phoneController,
              onChanged: _verificarTelefonoTienda,
              suffixIcon: _buildPhoneSuffix(),
              validator: (v) {
                if (v == null || v.isEmpty) return null; // opcional
                if (v.length != 9) return 'El celular debe tener 9 dígitos';
                if (_phoneErrorMessage != null) return _phoneErrorMessage;
                return null;
              },
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
                textStyle: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
              onPressed: _submit,
              child: Text(widget.submitLabel),
            ),
          ],
        ),
      ),
    );
  }
}
