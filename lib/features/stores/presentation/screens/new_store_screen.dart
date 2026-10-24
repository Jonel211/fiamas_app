import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../auth/presentation/providers/tienda_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../widgets/store_form.dart';

class NewStoreScreen extends StatelessWidget {
  const NewStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        children: [
          const AppHeader(title: 'Nueva Tienda', 
          showBack: true,
          centerTitle: true,),
          Expanded(
            child: Consumer2<TiendaProvider, AuthProvider>(
              builder: (context, tiendaProvider, authProvider, _) {
                if (tiendaProvider.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(color: AppColors.teal),
                  );
                }

                return StoreForm(
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
                    );

                    if (context.mounted) {
                      if (success) {
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                                tiendaProvider.error ?? 'Error al crear'),
                            backgroundColor: AppColors.danger,
                          ),
                        );
                      }
                    }
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
