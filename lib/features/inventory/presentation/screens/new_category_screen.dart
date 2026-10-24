import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../domain/category.dart';
import '../../domain/inventory_provider.dart';
import '../widgets/category_color_picker.dart';
import '../widgets/category_icon_picker.dart';
import '../widgets/category_style.dart';

class NewCategoryScreen extends StatefulWidget {
  const NewCategoryScreen({super.key, this.category});

  final Category? category;
  bool get isEditing => category != null;

  @override
  State<NewCategoryScreen> createState() => _NewCategoryScreenState();
}

class _NewCategoryScreenState extends State<NewCategoryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _description = TextEditingController();

  bool _active = true;
  Color _color = CategoryStyle.colors.first;
  String _iconKey = CategoryStyle.icons.keys.first;

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _name.text = widget.category!.nombre;
      _description.text = widget.category!.descripcion ?? '';
      _active = widget.category!.activo;
      _iconKey = widget.category!.icono ?? CategoryStyle.icons.keys.first;
      if (widget.category!.color != null && widget.category!.color!.isNotEmpty) {
        final hex = widget.category!.color!.replaceAll('#', '');
        final fullHex = hex.length == 6 ? 'FF$hex' : hex;
        _color = Color(int.parse(fullHex, radix: 16));
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final provider = context.read<InventoryProvider>();

    provider.clearError();
    
    provider.ensureInitialized(context);
    final realTiendaId = provider.tiendaId;

    if (realTiendaId == null || realTiendaId.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error: No se encontró el ID de la tienda.'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final hexColor = '#${_color.value.toRadixString(16).substring(2).toUpperCase()}';
    
    final newCategory = Category(
      id: widget.category?.id ?? '',
      tiendaId: realTiendaId,
      nombre: _name.text.trim(),
      descripcion: _description.text.trim().isEmpty ? null : _description.text.trim(),
      color: hexColor,
      icono: _iconKey,
      activo: _active,
    );

    try {
      if (widget.isEditing) {
        await provider.updateCategory(widget.category!.id, newCategory);
      } else {
        await provider.createCategory(newCategory);
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Categoría guardada exitosamente'), backgroundColor: Colors.green),
        );
        Navigator.of(context).pop(newCategory);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        AppHeader(
          title: widget.isEditing ? 'Editar Categoría' : 'Nueva Categoría',
          showBack: true,
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 32 + MediaQuery.of(context).padding.bottom),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _FilledField(label: 'Nombre', controller: _name, hint: 'Ej: Bebidas', icon: Icons.label_outline, validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa un nombre' : null),
                const SizedBox(height: 24),
                _FilledField(label: 'Descripción', controller: _description, hint: 'Describe la categoría', icon: Icons.edit_outlined, maxLines: 3),
                const SizedBox(height: 24),
                _StatusRow(active: _active, onChanged: (v) => setState(() => _active = v)),
                const SizedBox(height: 24),
                const _SectionLabel('Color'),
                const SizedBox(height: 12),
                CategoryColorPicker(selected: _color, onChanged: (c) => setState(() => _color = c)),
                const SizedBox(height: 24),
                const _SectionLabel('Ícono'),
                const SizedBox(height: 12),
                CategoryIconPicker(selectedKey: _iconKey, onChanged: (k) => setState(() => _iconKey = k)),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.teal, foregroundColor: Colors.white, minimumSize: const Size.fromHeight(52), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                  child: Text(widget.isEditing ? 'Guardar Cambios' : 'Guardar Categoría'),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.black));
}

class _FilledField extends StatelessWidget {
  const _FilledField({required this.label, required this.controller, required this.hint, required this.icon, this.validator, this.maxLines = 1});
  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final int maxLines;
  @override
  Widget build(BuildContext context) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _SectionLabel(label),
      const SizedBox(height: 8),
      TextFormField(controller: controller, validator: validator, minLines: maxLines, maxLines: maxLines, decoration: InputDecoration(hintText: hint, filled: true, fillColor: Colors.grey.shade200, prefixIcon: Icon(icon, color: Colors.grey), border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none))),
    ]);
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.active, required this.onChanged});
  final bool active;
  final ValueChanged<bool> onChanged;
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Expanded(child: Text('Activa', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700))),
      Switch(value: active, onChanged: onChanged),
    ]);
  }
}