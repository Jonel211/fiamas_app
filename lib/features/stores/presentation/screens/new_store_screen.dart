import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../widgets/store_form.dart';

class NewStoreScreen extends StatelessWidget {
  const NewStoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        children: [
          const SimpleAppBar(title: 'Nueva Tienda'),
          Expanded(
            child: StoreForm(
              submitLabel: 'Crear tienda',
              // TODO: crear la tienda en la API.
              onSubmit: (_) => Navigator.of(context).pop(),
            ),
          ),
        ],
      ),
    );
  }
}