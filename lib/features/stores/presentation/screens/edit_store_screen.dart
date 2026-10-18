import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../../domain/store.dart';
import '../widgets/store_form.dart';

/// Edita una tienda existente. Recibe la [Store] como argumento de la ruta:
/// Navigator.pushNamed(context, AppRoutes.editStore, arguments: store);
class EditStoreScreen extends StatelessWidget {
  const EditStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final store = ModalRoute.of(context)?.settings.arguments as Store?;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        children: [
          const SimpleAppBar(title: 'Editar Tienda'),
          Expanded(
            child: StoreForm(
              submitLabel: 'Guardar cambios',
              initialName: store?.name ?? '',
              // TODO: usar la dirección real cuando Store la incluya.
              initialAddress: store?.city ?? '',
              // TODO: guardar los cambios en la API.
              onSubmit: (_) => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}