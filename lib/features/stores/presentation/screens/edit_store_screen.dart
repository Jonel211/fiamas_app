import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../../../core/widgets/app_header_config.dart';
import '../../../../main.dart';
import '../../../auth/presentation/providers/tienda_provider.dart';
import '../../../auth/data/models/tienda_model.dart';
import '../widgets/store_form.dart';

class EditStoreScreen extends StatefulWidget {
  final TiendaModel tienda;

  const EditStoreScreen({super.key, required this.tienda});

  @override
  State<EditStoreScreen> createState() => _EditStoreScreenState();
}

class _EditStoreScreenState extends State<EditStoreScreen> {
  // Controladores para mantener el estado del formulario
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _rucController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    // Inicializamos los controladores con los datos actuales
    _nameController = TextEditingController(text: widget.tienda.nombre);
    _addressController = TextEditingController(text: widget.tienda.direccion ?? '');
    _rucController = TextEditingController(text: widget.tienda.ruc ?? '');
    _phoneController = TextEditingController(text: widget.tienda.telefono ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _rucController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppHeaderConfig(
      title: 'Editar Tienda',
      showBack: true,
      centerTitle: true,
      actions: [
        AppHeaderIconAction(
          icon: Icons.delete_outline_rounded,
          onTap: () {
            Navigator.pushNamed(
              context,
              AppRoutes.deleteStore,
              arguments: widget.tienda,
            );
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.ivory,
        body: Consumer<TiendaProvider>(
          builder: (context, provider, _) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.teal),
              );
            }

            return StoreForm(
              // Key única para evitar problemas de reconstrucción
              key: ValueKey('edit-${widget.tienda.id}'),
              submitLabel: 'Guardar Cambios',
              initialName: _nameController.text,
              initialAddress: _addressController.text,
              initialRuc: _rucController.text,
              initialPhone: _phoneController.text,
              onSubmit: (formData) async {
                // CORRECCIÓN CRÍTICA:
                // Si el campo está vacío, mantenemos el valor original
                // NO enviamos null para no sobrescribir datos existentes
                final success = await provider.updateTienda(
                  tiendaId: widget.tienda.id,
                  nombre: formData.name.trim().isEmpty
                      ? widget.tienda.nombre
                      : formData.name,
                  direccion: formData.address.trim().isEmpty
                      ? widget.tienda.direccion
                      : formData.address,
                  ruc: formData.ruc.trim().isEmpty
                      ? widget.tienda.ruc
                      : formData.ruc,
                  telefono: formData.phone.trim().isEmpty
                      ? widget.tienda.telefono
                      : formData.phone,
                );

                if (context.mounted) {
                  if (success) {
                    // Recargar la lista antes de cerrar
                    await context.read<TiendaProvider>().cargarMisTiendas();
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
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
      ),
    );
  }
}