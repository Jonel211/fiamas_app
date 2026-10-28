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
  late final TextEditingController _nameController;
  late final TextEditingController _addressController;
  late final TextEditingController _rucController;
  late final TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
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
            return Stack(
              children: [
                StoreForm(
                  key: ValueKey('edit-${widget.tienda.id}'),
                  submitLabel: 'Guardar Cambios',
                  initialName: _nameController.text,
                  initialAddress: _addressController.text,
                  initialRuc: _rucController.text,
                  initialPhone: _phoneController.text,
                  initialLogoUrl: widget.tienda.logoUrl,
                  onSubmit: (formData) async {
                    // Si el campo está vacío, se mantiene el valor original
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
                      logo: formData.logo,
                    );

                    if (!context.mounted) return;

                    if (success) {
                      final logoError = provider.error;
                      await context.read<TiendaProvider>().cargarMisTiendas();
                      if (!context.mounted) return;
                      if (logoError != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              'Cambios guardados, pero no se pudo subir el logo',
                            ),
                            backgroundColor: AppColors.danger,
                          ),
                        );
                      }
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(provider.error ?? 'Error al actualizar'),
                          backgroundColor: AppColors.danger,
                        ),
                      );
                    }
                  },
                ),
                if (provider.isLoading)
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