import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../main.dart';
import '../../../auth/presentation/providers/tienda_provider.dart';
import '../widgets/store_form.dart';
import '../../../auth/data/models/tienda_model.dart'; 

class EditStoreScreen extends StatelessWidget {
  final TiendaModel tienda;

  const EditStoreScreen({super.key, required this.tienda});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(
        backgroundColor: AppColors.teal,
        foregroundColor: Colors.white,
        title: const Text(
          'Editar Tienda',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        elevation: 0,
      ),
      body: Consumer<TiendaProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: AppColors.teal),
            );
          }

          return StoreForm(
            submitLabel: 'Guardar Cambios',
            initialName: tienda.nombre,
            initialAddress: tienda.direccion ?? '',
            initialRuc: tienda.ruc ?? '',
            initialPhone: tienda.telefono ?? '',
            onSubmit: (formData) async {
              final success = await provider.updateTienda(
                tiendaId: tienda.id,
                nombre: formData.name,
                direccion: formData.address.isEmpty ? null : formData.address,
                ruc: formData.ruc.isEmpty ? null : formData.ruc,
                telefono: formData.phone.isEmpty ? null : formData.phone,
              );

              if (context.mounted) {
                if (success) {
                  Navigator.pop(context); // Volver a la lista
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(provider.error ?? 'Error al actualizar'),
                      backgroundColor: AppColors.danger,
                    ),
                  );
                }
              }
            },
          );
        },
      ),
    );
  }
}
