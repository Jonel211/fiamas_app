import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/auth_repository.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombresCtrl = TextEditingController();
  final _apellidosCtrl = TextEditingController();
  final _dniCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  final _authRepository = AuthRepository();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  // Color principal del diseño
  final Color _primaryColor = const Color(0xFF0F172A);

  @override
  void dispose() {
    _nombresCtrl.dispose();
    _apellidosCtrl.dispose();
    _dniCtrl.dispose();
    _emailCtrl.dispose();
    _telefonoCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  Future<void> _registrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final result = await _authRepository.registerTendero(
      dni: _dniCtrl.text.trim(),
      nombres: _nombresCtrl.text.trim(),
      apellidos: _apellidosCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim(),
      password: _passwordCtrl.text,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result['success'] == true) {
      // Éxito
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            '¡Cuenta creada con éxito! Bienvenido a Fiamas.',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: const Color(0xFF0E7C7B),
        ),
      );
      // Navegar al login después de un momento
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) Navigator.of(context).pushReplacementNamed('/login');
      });
    } else {
      // Error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            result['error'] ?? 'Error al registrar',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 10),
                Text(
                  'Crea tu cuenta',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                    color: _primaryColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Empieza a digitalizar tu tienda hoy',
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 28),

                // Nombres
                _buildLabel('Nombres'),
                _buildTextField(
                  controller: _nombresCtrl,
                  hint: 'Ej: Juan',
                  icon: Icons.person_outline,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Ingresa tus nombres' : null,
                ),

                // Apellidos (NUEVO, requerido por backend)
                _buildLabel('Apellidos'),
                _buildTextField(
                  controller: _apellidosCtrl,
                  hint: 'Ej: Pérez Gómez',
                  icon: Icons.person_outline,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Ingresa tus apellidos' : null,
                ),

                // DNI
                _buildLabel('DNI'),
                _buildTextField(
                  controller: _dniCtrl,
                  hint: '8 dígitos',
                  icon: Icons.badge_outlined,
                  keyboardType: TextInputType.number,
                  maxLength: 8,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa tu DNI';
                    if (v.length != 8) return 'El DNI debe tener 8 dígitos';
                    return null;
                  },
                ),

                // Email (NUEVO, requerido por backend)
                _buildLabel('Correo electrónico'),
                _buildTextField(
                  controller: _emailCtrl,
                  hint: 'Ej: juan@correo.com',
                  icon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa tu correo';
                    if (!v.contains('@')) return 'Correo inválido';
                    return null;
                  },
                ),

                // Teléfono
                _buildLabel('Número de celular'),
                _buildTextField(
                  controller: _telefonoCtrl,
                  hint: 'Ej: 987 654 321',
                  icon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (v) =>
                      v == null || v.isEmpty ? 'Ingresa tu celular' : null,
                ),

                // Contraseña
                _buildLabel('Crea una contraseña'),
                _buildTextField(
                  controller: _passwordCtrl,
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  obscureText: _obscurePassword,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF94A3B8),
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Ingresa una contraseña';
                    if (v.length < 6) return 'Mínimo 6 caracteres';
                    return null;
                  },
                ),

                // Confirmar contraseña
                _buildLabel('Confirmar contraseña'),
                _buildTextField(
                  controller: _confirmPasswordCtrl,
                  hint: '••••••••',
                  icon: Icons.lock_outline,
                  obscureText: _obscureConfirm,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: const Color(0xFF94A3B8),
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Confirma tu contraseña';
                    if (v != _passwordCtrl.text)
                      return 'Las contraseñas no coinciden';
                    return null;
                  },
                ),

                const SizedBox(height: 28),

                // Botón Registrarme
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _registrar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 2,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                color: Colors.white,
                                size: 20,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Registrarme',
                                style: GoogleFonts.poppins(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 20),

                // Link a Login
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '¿Ya tienes una cuenta? ',
                        style: GoogleFonts.poppins(
                          fontSize: 13,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                      GestureDetector(
                        onTap: () =>
                            Navigator.of(context)
                                .pushReplacementNamed('/login'),
                        child: Text(
                          'Inicia sesión',
                          style: GoogleFonts.poppins(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF0E7C7B),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 14),
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: const Color(0xFF0F172A),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    bool obscureText = false,
    Widget? suffixIcon,
    int? maxLength,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      maxLength: maxLength,
      validator: validator,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        counterText: '',
        hintText: hint,
        hintStyle: GoogleFonts.poppins(
          fontSize: 13,
          color: const Color(0xFF94A3B8),
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFF0E7C7B), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent),
        ),
      ),
    );
  }
}
