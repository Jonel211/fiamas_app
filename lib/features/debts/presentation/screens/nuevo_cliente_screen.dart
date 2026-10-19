import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../../../../main.dart'; // <-- IMPORTANTE: Para usar AppRoutes
import '../widgets/register_method_card.dart';

class NuevoClienteScreen extends StatefulWidget {
  const NuevoClienteScreen({super.key});

  @override
  State<NuevoClienteScreen> createState() => _NuevoClienteScreenState();
}

class _NuevoClienteScreenState extends State<NuevoClienteScreen> {
  String _selectedMethod = 'manual'; // 'qr' o 'manual'

  final _nameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _limitController = TextEditingController(text: '500.00');

  @override
  void dispose() {
    _nameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        children: [
          const SimpleAppBar(title: 'Nuevo Cliente'),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Cabecera
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

                  // Opciones
                  RegisterMethodCard(
                    title: 'Generar código QR',
                    subtitle: 'El cliente escanea y se registra solo. Tú no escribes nada.',
                    icon: Icons.qr_code_rounded,
                    isSelected: _selectedMethod == 'qr',
                    isTealBackground: true,
                    // CORREGIDO: Navega a la pantalla de Registro QR
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

                  // Formulario Manual
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
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.skyBlue.withOpacity(0.3),
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
                      hint: 'Ej: +51 987 654 321',
                      prefixIcon: const Icon(Icons.phone_outlined, size: 20, color: AppColors.inkMuted),
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                    ),
                    _buildField(
                      label: 'Límite de crédito',
                      hint: '500.00',
                      // AQUÍ CAMBIAMOS EL ÍCONO DE DÓLAR POR EL TEXTO "S/"
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
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Botón Registrar
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            child: ElevatedButton(
              onPressed: () {
                // TODO: Guardar cliente
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.teal,
                foregroundColor: Colors.white,
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Registrar cliente',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
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

  // Helper actualizado para aceptar un Widget (así podemos usar íconos o texto)
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