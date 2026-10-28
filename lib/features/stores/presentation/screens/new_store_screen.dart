import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header_config.dart';
import '../../../auth/presentation/providers/tienda_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/store_form.dart';

class NewStoreScreen extends StatelessWidget {
  const NewStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AppHeaderConfig(
      title: 'Nueva Tienda',
      showBack: true,
      child: Scaffold(
        backgroundColor: AppColors.ivory,
        body: Consumer2<TiendaProvider, AuthProvider>(
          builder: (context, tiendaProvider, authProvider, _) {
            return Stack(
              children: [
                StoreForm(
                  submitLabel: 'Crear Tienda',
                  onSubmit: (formData) async {
                    final tenderoId = authProvider.user?.id;
                    if (tenderoId == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Error de sesión'),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                      return;
                    }

                    final success = await tiendaProvider.crearTienda(
                      nombre: formData.name,
                      direccion:
                          formData.address.isEmpty ? null : formData.address,
                      ruc: formData.ruc.isEmpty ? null : formData.ruc,
                      telefono: formData.phone.isEmpty ? null : formData.phone,
                      tenderoId: tenderoId,
                      logo: formData.logo,
                    );

                    if (!context.mounted) return;

                    if (success) {
                      final logoError = tiendaProvider.error;
                      if (logoError != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Tienda creada, pero no se pudo subir el logo',
                            ),
                            backgroundColor: AppColors.danger,
                          ),
                        );
                      }
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content:
                              Text(tiendaProvider.error ?? 'Error al crear'),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                    }
                  },
                ),
                if (tiendaProvider.isLoading)
                  Positioned.fill(
                    child: Container(
                      color: AppColors.ivory.withValues(alpha: 0.7),
                      child: const Center(
                        child: CircularProgressIndicator(color: AppColors.teal),
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}