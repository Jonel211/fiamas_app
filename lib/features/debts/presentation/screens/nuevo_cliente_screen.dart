import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../main.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../customers/presentation/providers/cliente_provider.dart';
import '../widgets/register_method_card.dart';

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

  @override
  void initState() {
    super.initState();
    if (widget.initialPhone != null && widget.initialPhone!.isNotEmpty) {
      _phoneController.text = widget.initialPhone!;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _addressController.dispose(); 
    _limitController.dispose();
    super.dispose();
  }

  Future<void> _registrarCliente() async {
    // 1. Validar campos de texto
    if (_nameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, llena todos los campos obligatorios')),
      );
      return;
    }

    final telefono = _phoneController.text.trim();
    if (telefono.length != 9) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El teléfono debe tener exactamente 9 dígitos')),
      );
      return;
    }

    // 2. VALIDAR LÍMITE DE CRÉDITO
    if (_limitController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, ingresa un límite de crédito')),
      );
      return;
    }

    final limiteStr = _limitController.text.replaceAll(',', '.').trim();
    final limite = double.tryParse(limiteStr);
    
    if (limite == null || limite <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('El límite de crédito debe ser un número mayor a 0')),
      );
      return;
    }

    // 3. Continuar con el registro
    final authProvider = context.read<AuthProvider>();
    final clienteProvider = context.read<ClienteProvider>();
    final tiendaId = authProvider.user?.tiendaId;

    if (tiendaId == null || tiendaId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error: No se encontró la tienda del tendero')),
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
        const SnackBar(content: Text('Cliente registrado exitosamente'), backgroundColor: Colors.green),
      );
      Navigator.of(context).pop(true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(clienteProvider.error ?? 'Error al registrar'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCreating = context.watch<ClienteProvider>().isCreating;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        children: [
          const AppHeader(title: 'Nuevo Cliente', showBack: true),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    '¿Cómo quieres registrarlo?',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppColors.ink),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Elige una opción para agregar al cliente',
                    style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
                  ),
                  const SizedBox(height: 20),

                  RegisterMethodCard(
                    title: 'Generar código QR',
                    subtitle: 'El cliente escanea y se registra solo. Tú no escribes nada.',
                    icon: Icons.qr_code_rounded,
                    isSelected: _selectedMethod == 'qr',
                    isTealBackground: true,
                    onTap: () => Navigator.of(context).pushNamed(AppRoutes.newClientQr),
                  ),
                  RegisterMethodCard(
                    title: 'Registrar manualmente',
                    subtitle: 'Tú escribes los datos del cliente desde tu app',
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
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.ink),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.skyBlue.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'Registro directo',
                            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.ink),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    
                    _buildField(
                      label: 'Nombres',
                      hint: 'Ej: Martha',
                      prefixIcon: const Icon(Icons.person_outline_rounded, size: 20, color: AppColors.inkMuted),
                      controller: _nameController,
                    ),
                    _buildField(
                      label: 'Apellidos',
                      hint: 'Ej: Gómez',
                      prefixIcon: const Icon(Icons.person_outline_rounded, size: 20, color: AppColors.inkMuted),
                      controller: _lastNameController,
                    ),
                    _buildField(
                      label: 'Teléfono',
                      hint: 'Ej: 987654321',
                      prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: AppColors.inkMuted),
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildField(
                      label: 'Dirección (Opcional)',
                      hint: 'Ej: Av. Larco 123',
                      prefixIcon: const Icon(Icons.location_on_outlined, size: 20, color: AppColors.inkMuted),
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
                            style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.inkMuted, fontSize: 14),
                          ),
                        ),
                      ),
                      controller: _limitController,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    ),
                  ],
                ],
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: ElevatedButton(
              onPressed: isCreating ? null : _registrarCliente,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 0,
              ),
              child: isCreating
                  ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('Registrar cliente', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward_rounded, size: 20),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildField({
    required String label,
    required String hint,
    required Widget prefixIcon,
    required TextEditingController controller,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink)),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: const TextStyle(fontSize: 13, color: AppColors.inkMuted),
              prefixIcon: prefixIcon,
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