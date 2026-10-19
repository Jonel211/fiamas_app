import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../../../../main.dart';
import '../../domain/category.dart';
import 'new_category_screen.dart';
import '../widgets/category_tile.dart';

/// Lista de categorías de productos de la tienda.
class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({super.key});

  @override
  State<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen> {
  // TODO: reemplazar por las categorías reales (API).
  final List<Category> _categories = [
    const Category(
      id: '1',
      name: 'Bebidas',
      iconKey: 'coffee',
      color: Color(0xFF3B82F6),
    ),
    const Category(
      id: '2',
      name: 'Abarrotes',
      iconKey: 'bag',
      color: Color(0xFFF59E0B),
    ),
    const Category(
      id: '3',
      name: 'Comidas',
      iconKey: 'food',
      color: Color(0xFFEF4444),
    ),
    const Category(
      id: '4',
      name: 'Limpieza',
      iconKey: 'home',
      color: Color(0xFF10B981),
    ),
    const Category(
      id: '5',
      name: 'Ferretería',
      iconKey: 'tool',
      color: Color(0xFFA855F7),
    ),
    const Category(
      id: '6',
      name: 'Salud',
      iconKey: 'health',
      color: Color(0xFFEF4444),
    ),
    const Category(
      id: '7',
      name: 'Electro',
      iconKey: 'laptop',
      color: AppColors.ink,
    ),
  ];

  String? _selectedId;

  Future<void> _addCategory() async {
    final created = await Navigator.of(context).pushNamed(AppRoutes.newCategory);
    if (created is! Category || !mounted) return;
    setState(() => _categories.add(created));
  }

  Future<void> _editCategory(Category category) async {
    final updated = await Navigator.of(context).push<Category>(
      MaterialPageRoute(
        builder: (_) => NewCategoryScreen(category: category),
      ),
    );
    if (updated == null || !mounted) return;
    setState(() {
      final index = _categories.indexWhere((c) => c.id == updated.id);
      if (index != -1) {
        _categories[index] = updated;
      }
    });
  }

  Future<void> _deleteCategory(Category category) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Eliminar categoría'),
        content: Text('¿Eliminar "${category.name}"? Esta acción no se puede deshacer.'),
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
    if (confirmed != true || !mounted) return;
    setState(() {
      _categories.removeWhere((c) => c.id == category.id);
      if (_selectedId == category.id) _selectedId = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        children: [
          const SimpleAppBar(title: 'Categorías'),
          Expanded(
            child: SingleChildScrollView(
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
                      for (final c in _categories)
                        GestureDetector(
                          onLongPress: () => _deleteCategory(c),
                          child: CategoryTile(
                            category: c,
                            selected: c.id == _selectedId,
                            onTap: () {
                              setState(() => _selectedId = c.id);
                              _editCategory(c);
                            },
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}