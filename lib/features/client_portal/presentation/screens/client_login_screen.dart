import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/labeled_field.dart';
import 'client_stores_screen.dart';

class ClientLoginScreen extends StatefulWidget {
  const ClientLoginScreen({super.key});

  @override
  State<ClientLoginScreen> createState() => _ClientLoginScreenState();
}

class _ClientLoginScreenState extends State<ClientLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() {
    // TODO: conectar con ClientAuthRepository.login()
    // Por ahora, solo navegación visual hacia Mis Tiendas (Fiador).
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ClientStoresScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight - 40),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            alignment: Alignment.center,
                            decoration: const BoxDecoration(
                              color: AppColors.mist,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.person_add_alt_1_outlined,
                                color: AppColors.ink, size: 28),
                          ),
                          const SizedBox(height: 16),
                          Text('Fiamas',
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineSmall
                                  ?.copyWith(fontSize: 28)),
                          const SizedBox(height: 2),
                          const Text('PORTAL DEL CLIENTE',
                              style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  letterSpacing: 0.6,
                                  color: AppColors.teal)),
                        ],
                      ),
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.mist),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text('Bienvenido',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(fontSize: 18)),
                            const SizedBox(height: 4),
                            Text('Revisa cuánto debes en tus tiendas',
                                style: Theme.of(context).textTheme.bodyMedium),
                            const SizedBox(height: 20),
                            LabeledField(
                              label: 'Tu número de celular',
                              hint: 'Ej: 987 654 321',
                              icon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              controller: _phoneController,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Ingresa tu número de celular'
                                  : null,
                            ),
                            const SizedBox(height: 16),
                            LabeledField(
                              label: 'Contraseña',
                              hint: '••••••••',
                              icon: Icons.lock_outline,
                              obscureText: true,
                              controller: _passwordController,
                              validator: (v) => (v == null || v.isEmpty)
                                  ? 'Ingresa tu contraseña'
                                  : null,
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton.icon(
                              onPressed: _handleLogin,
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.teal),
                              icon: const Icon(Icons.arrow_forward, size: 18),
                              label: const Text('Ver mi cuenta'),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('¿Aún no tienes cuenta? ',
                                  style: Theme.of(context).textTheme.bodyMedium),
                              GestureDetector(
                                onTap: () {
                                  // TODO: flujo de registro del cliente
                                },
                                child: const Text(
                                  'Crea una cuenta aquí',
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
                          const SizedBox(height: 16),
                          TextButton.icon(
                            onPressed: () => Navigator.of(context).pop(),
                            icon: const Icon(Icons.storefront_outlined,
                                size: 15, color: AppColors.inkMuted),
                            label: const Text('SOY TENDERO',
                                style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.4,
                                    color: AppColors.inkMuted)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}