import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header_config.dart';
import '../../../../main.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/providers/tienda_provider.dart';
import '../../domain/category.dart';
import '../../domain/inventory_provider.dart';
import 'new_category_screen.dart';
import '../widgets/category_tile.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});
  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  void _loadDataForCurrentStore() {
    final authProvider = context.read<AuthProvider>();
    final tiendaProvider = context.read<TiendaProvider>();
    final inventoryProvider = context.read<InventoryProvider>();

    final currentTiendaId =
        tiendaProvider.tiendaSeleccionadaId ?? authProvider.tiendaId;
    final token = authProvider.token;

    if (currentTiendaId != null && token != null) {
      inventoryProvider.updateTiendaContext(token, currentTiendaId);
      inventoryProvider.loadCategories();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _loadDataForCurrentStore(),
    );
  }

  Future<void> _addCategory() async {
    final created = await Navigator.of(context)
        .pushNamed(AppRoutes.newCategory);
    if (created is Category && mounted) _loadDataForCurrentStore();
  }

  Future<void> _editCategory(Category category) async {
    final updated = await Navigator.of(context).push<Category>(
      MaterialPageRoute(builder: (_) => NewCategoryScreen(category: category)),
    );
    if (updated != null && mounted) _loadDataForCurrentStore();
  }

  Future<void> _deleteCategory(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: Text(
          '¿Eliminar "${category.nombre}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: TextButton.styleFrom(foregroundColor: AppColors.danger),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await context.read<InventoryProvider>().deleteCategory(category.id);
      _loadDataForCurrentStore();
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppHeaderConfig(
      title: 'Categorías',
      showBack: true,
      centerTitle: true,
      child: Scaffold(
        backgroundColor: AppColors.ivory,
        body: Consumer<InventoryProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Error: ${provider.error}'),
                    ElevatedButton(
                      onPressed: () {
                        provider.clearError();
                        _loadDataForCurrentStore();
                      },
                      child: const Text('Reintentar'),
                    ),
                  ],
                ),
              );
            }
            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: _addCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gold,
                      foregroundColor: AppColors.ink,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(44),
                      textStyle: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Nueva categoría'),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Lista de categorías',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 0.9,
                    children: [
                      for (final c in provider.categories)
                        GestureDetector(
                          onLongPress: () => _deleteCategory(c),
                          child: CategoryTile(
                            category: c,
                            onTap: () => _editCategory(c),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
