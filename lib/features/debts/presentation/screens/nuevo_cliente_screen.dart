import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/phone_utils.dart';
import '../../../../core/widgets/app_header_config.dart';
import '../../../../main.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/tienda_provider.dart';
import '../../../customers/data/models/cliente_existente_model.dart';
import '../../../customers/data/models/cliente_model.dart';
import '../../../customers/presentation/providers/cliente_provider.dart';
import '../widgets/register_method_card.dart';
import '../widgets/vincular_cliente_sheet.dart';

class NuevoClienteScreen extends StatefulWidget {
  final String? initialPhone;

  const NuevoClienteScreen({super.key, this.initialPhone});

  @override
  State<NuevoClienteScreen> createState() => _NuevoClienteScreenState();
}

class _NuevoClienteScreenState extends State<NuevoClienteScreen> {
  String _selectedMethod = 'manual';

  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _limitController = TextEditingController(text: '500.00');
  Timer? _phoneDebounce;
  Completer<ClienteExistenteModel?>? _phoneCheckCompleter;
  Future<ClienteExistenteModel?>? _phoneCheckFuture;
  String? _currentNormalizedPhone;
  String? _lastCheckedPhone;
  String? _phoneWithOpenedSheet;
  bool _isCheckingPhone = false;
  bool _isSubmitting = false;
  bool _sheetAbierto = false;

  @override
  void initState() {
    super.initState();
    _phoneController.addListener(_onPhoneChanged);
    if (widget.initialPhone != null && widget.initialPhone!.isNotEmpty) {
      _phoneController.text = widget.initialPhone!;
      _onPhoneChanged();
    }
  }

  @override
  void dispose() {
    _phoneDebounce?.cancel();
    final pendingCheck = _phoneCheckCompleter;
    if (pendingCheck != null && !pendingCheck.isCompleted) {
      pendingCheck.complete(null);
    }
    _phoneController.removeListener(_onPhoneChanged);
    _nameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  void _onPhoneChanged() {
    final telefono = normalizarTelefonoPE(_phoneController.text);
    if (telefono != _currentNormalizedPhone) {
      _phoneDebounce?.cancel();
      final pendingCheck = _phoneCheckCompleter;
      if (pendingCheck != null && !pendingCheck.isCompleted) {
        pendingCheck.complete(null);
      }

      _currentNormalizedPhone = telefono;
      _lastCheckedPhone = null;
      _phoneCheckCompleter = null;
      _phoneCheckFuture = null;
      _phoneWithOpenedSheet = null;
      _isCheckingPhone = false;
    }

    if (!esTelefonoValido(telefono) ||
        _lastCheckedPhone == telefono ||
        _phoneCheckFuture != null) {
      return;
    }

    final completer = Completer<ClienteExistenteModel?>();
    _phoneCheckCompleter = completer;
    _phoneCheckFuture = completer.future;
    _phoneDebounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted || _currentNormalizedPhone != telefono) {
        if (!completer.isCompleted) completer.complete(null);
        return;
      }

      _lastCheckedPhone = telefono;
      setState(() => _isCheckingPhone = true);
      unawaited(_consultarTelefono(telefono, completer));
    });
  }

  Future<void> _consultarTelefono(
    String telefono,
    Completer<ClienteExistenteModel?> completer,
  ) async {
    final authProvider = context.read<AuthProvider>();
    final tiendaProvider = context.read<TiendaProvider>();
    final tiendaId =
        tiendaProvider.tiendaSeleccionadaId ?? authProvider.user?.tiendaId;

    if (tiendaId == null || tiendaId.isEmpty) {
      debugPrint(
        'No se pudo verificar el teléfono: no hay tienda seleccionada.',
      );
      if (!completer.isCompleted) completer.complete(null);
      if (mounted && _currentNormalizedPhone == telefono) {
        setState(() => _isCheckingPhone = false);
      }
      return;
    }

    final clienteProvider = context.read<ClienteProvider>();
    ClienteExistenteModel? existente;
    try {
      existente = await clienteProvider.verificarTelefono(telefono, tiendaId);
    } catch (error) {
      debugPrint('Error al verificar el teléfono $telefono: $error');
    }

    if (!mounted) {
      if (!completer.isCompleted) completer.complete(existente);
      return;
    }

    if (existente == null) {
      debugPrint(
        'No se pudo verificar el teléfono $telefono: '
        '${clienteProvider.errorVerificacion ?? 'error desconocido'}',
      );
    }

    if (_currentNormalizedPhone != telefono) {
      if (!completer.isCompleted) completer.complete(existente);
      return;
    }

    setState(() => _isCheckingPhone = false);
    if (!completer.isCompleted) completer.complete(existente);

    if (existente != null &&
        existente.existe &&
        existente.activo &&
        !existente.yaVinculado &&
        existente.clienteId != null &&
        existente.clienteId!.isNotEmpty) {
      await _mostrarVincularSheetParaTelefono(
        existente,
        tiendaId,
        telefono,
        automatico: true,
      );
      if (!mounted) return;
    }
  }

  Future<void> _registrarCliente() async {
    final clienteProvider = context.read<ClienteProvider>();

    if (_isSubmitting ||
        clienteProvider.isLinking ||
        clienteProvider.isCreating) {
      return;
    }

    final telefono = normalizarTelefonoPE(_phoneController.text);
    if (!esTelefonoValido(telefono)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ingresa un teléfono válido de 9 dígitos'),
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final authProvider = context.read<AuthProvider>();
      final tiendaProvider = context.read<TiendaProvider>();
      final tiendaId =
          tiendaProvider.tiendaSeleccionadaId ?? authProvider.user?.tiendaId;

      if (tiendaId == null || tiendaId.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se encontró la tienda del tendero'),
          ),
        );
        return;
      }

      final consulta = _phoneCheckFuture;
      final existente = consulta == null ? null : await consulta;

      if (!mounted) return;
      if (_currentNormalizedPhone != telefono) return;

      if (existente != null && existente.existe) {
        if (!existente.activo) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Este cliente no está disponible'),
              backgroundColor: AppColors.danger,
            ),
          );
          return;
        }

        if (existente.yaVinculado) {
          await _mostrarYaVinculado(existente, telefono);
          if (!mounted) return;
          return;
        }

        if (existente.clienteId == null || existente.clienteId!.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No se pudo obtener el cliente. Reintenta.'),
              backgroundColor: AppColors.danger,
            ),
          );
          return;
        }

        await _mostrarVincularSheetParaTelefono(existente, tiendaId, telefono);
        if (!mounted) return;
        return;
      }

      await _crearClienteManual(telefono, tiendaId, clienteProvider);
      if (!mounted) return;
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Future<void> _crearClienteManual(
    String telefono,
    String tiendaId,
    ClienteProvider clienteProvider,
  ) async {
    if (_nameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, llena todos los campos obligatorios'),
        ),
      );
      return;
    }

    if (_limitController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, ingresa un límite de crédito'),
        ),
      );
      return;
    }

    final limiteStr = _limitController.text.replaceAll(',', '.').trim();
    final limite = double.tryParse(limiteStr);

    if (limite == null || limite <= 0 || limite > 10000) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'El límite de crédito debe ser mayor a 0 y hasta S/ 10,000',
          ),
        ),
      );
      return;
    }

    final success = await clienteProvider.crearCliente(
      nombres: _nameController.text.trim(),
      apellidos: _lastNameController.text.trim(),
      telefono: telefono,
      limiteCredito: limite,
      tiendaId: tiendaId,
      direccion: _addressController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Cliente registrado exitosamente'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(clienteProvider.error ?? 'Error al registrar'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _mostrarVincularSheet(
    ClienteExistenteModel existente,
    String tiendaId,
  ) async {
    if (_sheetAbierto) return;
    _sheetAbierto = true;

    bool? vinculado;
    try {
      vinculado = await showModalBottomSheet<bool>(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (_) =>
            VincularClienteSheet(cliente: existente, tiendaId: tiendaId),
      );
    } finally {
      _sheetAbierto = false;
    }

    if (!mounted || vinculado != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Cliente vinculado exitosamente'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.of(context).pop(true);
  }

  Future<void> _mostrarVincularSheetParaTelefono(
    ClienteExistenteModel existente,
    String tiendaId,
    String telefono, {
    bool automatico = false,
  }) async {
    if (automatico && _phoneWithOpenedSheet == telefono) return;
    _phoneWithOpenedSheet = telefono;
    await _mostrarVincularSheet(existente, tiendaId);
    if (!mounted) return;
  }

  Future<void> _mostrarYaVinculado(
    ClienteExistenteModel existente,
    String telefono,
  ) async {
    final verPerfil = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ya es cliente de tu tienda'),
        content: Text(
          existente.nombreCompleto.isEmpty
              ? 'Este cliente ya está vinculado a tu tienda.'
              : '${existente.nombreCompleto} ya está vinculado a tu tienda.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cerrar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Ver perfil'),
          ),
        ],
      ),
    );

    if (!mounted || verPerfil != true) return;

    Navigator.of(context).pushNamed(
      AppRoutes.customerProfile,
      arguments: _clienteMinimo(existente, telefono),
    );
  }

  ClienteModel _clienteMinimo(
    ClienteExistenteModel existente,
    String telefono,
  ) {
    final id = existente.clienteId ?? '';

    return ClienteModel(
      id: id,
      telefono: telefono,
      nombres: existente.nombres,
      apellidos: existente.apellidos,
      fotoPerfilUrl: existente.fotoPerfilUrl,
      vinculacion: VinculacionModel(
        id: id,
        limiteCredito: 500,
        saldoActual: 0,
        scorePagador: 100,
        categoriaPagador: 'nuevo',
        totalFiados: 0,
        totalPagos: 0,
        cantidadFiadosMora: 0,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final clienteProvider = context.watch<ClienteProvider>();
    final isBusy =
        clienteProvider.isCreating ||
        clienteProvider.isLinking ||
        _isSubmitting;

    return AppHeaderConfig(
      title: 'Nuevo Cliente',
      showBack: true,
      child: Scaffold(
        backgroundColor: AppColors.ivory,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      '¿Cómo quieres registrarlo?',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Elige una opción para agregar al cliente',
                      style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
                    ),
                    const SizedBox(height: 20),

                    RegisterMethodCard(
                      title: 'Mostrar código QR',
                      subtitle: 'El cliente escanea y se registra solo. Tú no escribes nada.',
                      icon: Icons.qr_code_rounded,
                      isSelected: _selectedMethod == 'qr',
                      isTealBackground: true,
                      onTap: () =>
                          Navigator.of(context)
                              .pushNamed(AppRoutes.newClientQr),
                    ),
                    RegisterMethodCard(
                      title: 'Registrar manualmente',
                      subtitle:
                          'Tú escribes los datos del cliente desde tu app',
                      icon: Icons.edit_rounded,
                      isSelected: _selectedMethod == 'manual',
                      isTealBackground: false,
                      onTap: () => setState(() => _selectedMethod = 'manual'),
                    ),

                    const SizedBox(height: 28),

                    if (_selectedMethod == 'manual') ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Datos del fiador',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.ink,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.skyBlue.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Registro directo',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.ink,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      _buildField(
                        label: 'Nombres',
                        hint: 'Ej: Martha',
                        prefixIcon: const Icon(
                          Icons.person_outline_rounded,
                          size: 20,
                          color: AppColors.inkMuted,
                        ),
                        controller: _nameController,
                      ),
                      _buildField(
                        label: 'Apellidos',
                        hint: 'Ej: Gómez',
                        prefixIcon: const Icon(
                          Icons.person_outline_rounded,
                          size: 20,
                          color: AppColors.inkMuted,
                        ),
                        controller: _lastNameController,
                      ),
                      _buildField(
                        label: 'Teléfono',
                        hint: 'Ej: 987654321',
                        prefixIcon: const Icon(
                          Icons.phone_outlined,
                          size: 20,
                          color: AppColors.inkMuted,
                        ),
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        suffixIcon: _isCheckingPhone
                            ? const Padding(
                                padding: EdgeInsets.all(14),
                                child: SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                ),
                              )
                            : null,
                      ),
                      _buildField(
                        label: 'Dirección (Opcional)',
                        hint: 'Ej: Av. Larco 123',
                        prefixIcon: const Icon(
                          Icons.location_on_outlined,
                          size: 20,
                          color: AppColors.inkMuted,
                        ),
                        controller: _addressController,
                      ),
                      _buildField(
                        label: 'Límite de crédito',
                        hint: 'Ej: 500.00',
                        prefixIcon: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Center(
                            widthFactor: 1.0,
                            child: Text(
                              'S/',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: AppColors.inkMuted,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                        controller: _limitController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
              child: ElevatedButton(
                onPressed: isBusy ? null : _registrarCliente,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(52),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: isBusy
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Registrar cliente',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(Icons.arrow_forward_rounded, size: 20),
                        ],
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required Widget prefixIcon,
    required TextEditingController controller,
    TextInputType? keyboardType,
    Widget? suffixIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.ink,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(
                fontSize: 13,
                color: AppColors.inkMuted,
              ),
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              filled: true,
              fillColor: AppColors.surface,
              contentPadding: const EdgeInsets.symmetric(vertical: 14),
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
                borderSide: const BorderSide(color: AppColors.teal),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
