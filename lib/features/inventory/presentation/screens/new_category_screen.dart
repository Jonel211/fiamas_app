import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header_config.dart';
import '../../../../core/constants/category_icons.dart';
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
  String _iconKey = 'abarrotes';

  @override
  void initState() {
    super.initState();
    if (widget.isEditing) {
      _name.text = widget.category!.nombre;
      _description.text = widget.category!.descripcion ?? '';
      _active = widget.category!.activo;

      final savedIcon = widget.category!.icono;
      _iconKey = (savedIcon != null && CategoryIcons.all.containsKey(savedIcon))
          ? savedIcon
          : 'general';

      if (widget.category!.color != null &&
          widget.category!.color!.isNotEmpty) {
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

  /// Los 10 destacados. Si el ícono elegido no está entre ellos
  /// (porque se eligió en "Ver todos"), ocupa el último lugar.
  List<String> get _quickKeys {
    final keys = List<String>.from(CategoryIcons.featured);
    if (!keys.contains(_iconKey)) keys[keys.length - 1] = _iconKey;
    return keys;
  }

  Future<void> _pickIcon() async {
    final key = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        builder: (ctx, controller) => ListView(
          controller: controller,
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            24 + MediaQuery.of(ctx).padding.bottom,
          ),
          children: [
            CategoryIconPicker(
              selectedKey: _iconKey,
              color: _color,
              onChanged: (k) => Navigator.pop(ctx, k),
            ),
          ],
        ),
      ),
    );
    if (key != null) setState(() => _iconKey = key);
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

    final hexColor =
        '#${_color.toARGB32().toRadixString(16).substring(2).toUpperCase()}';

    final newCategory = Category(
      id: widget.category?.id ?? '',
      tiendaId: realTiendaId,
      nombre: _name.text.trim(),
      descripcion:
          _description.text.trim().isEmpty ? null : _description.text.trim(),
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
          const SnackBar(
            content: Text('Categoría guardada exitosamente'),
            backgroundColor: Colors.green,
          ),
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
    return AppHeaderConfig(
      title: widget.isEditing ? 'Editar Categoría' : 'Nueva Categoría',
      showBack: true,
      centerTitle: true,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            16,
            24,
            32 + MediaQuery.of(context).padding.bottom,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _FilledField(
                  label: 'Nombre de la categoría',
                  controller: _name,
                  hint: 'Ej: Bebidas Energéticas',
                  icon: Icons.label_outline,
                  validator: (v) => (v == null || v.trim().isEmpty)
                      ? 'Ingresa un nombre'
                      : null,
                ),
                const SizedBox(height: 24),
                _FilledField(
                  label: 'Descripción',
                  controller: _description,
                  hint: 'Describe la categoría',
                  icon: Icons.edit_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                _StatusRow(
                  active: _active,
                  onChanged: (v) => setState(() => _active = v),
                ),
                const SizedBox(height: 24),
                const _SectionLabel('Color'),
                const SizedBox(height: 12),
                CategoryColorPicker(
                  selected: _color,
                  onChanged: (c) => setState(() => _color = c),
                ),
                const SizedBox(height: 24),
                const _SectionLabel('Ícono'),
                const SizedBox(height: 12),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 5,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  children: [
                    for (final key in _quickKeys)
                      CategoryIconCell(
                        icon: CategoryIcons.resolve(key),
                        selected: key == _iconKey,
                        color: _color,
                        onTap: () => setState(() => _iconKey = key),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                TextButton.icon(
                  onPressed: _pickIcon,
                  style: TextButton.styleFrom(foregroundColor: AppColors.teal),
                  icon: const Icon(Icons.apps_rounded, size: 18),
                  label: const Text('Ver todos los íconos'),
                ),
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(52),
                    textStyle: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    widget.isEditing ? 'Guardar Cambios' : 'Guardar Categoría',
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);
  final String text;
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: AppColors.ink,
        ),
      );
}

class _FilledField extends StatelessWidget {
  const _FilledField({
    required this.label,
    required this.controller,
    required this.hint,
    required this.icon,
    this.validator,
    this.maxLines = 1,
  });

  final String label;
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final String? Function(String?)? validator;
  final int maxLines;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border([Color color = Colors.transparent]) =>
        OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color),
        );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _SectionLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          validator: validator,
          minLines: maxLines,
          maxLines: maxLines,
          textCapitalization: TextCapitalization.sentences,
          style: const TextStyle(fontSize: 14, color: AppColors.ink),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 14, color: AppColors.inkMuted),
            filled: true,
            fillColor: AppColors.surfaceMuted,
            prefixIcon: Align(
              alignment: Alignment.topCenter,
              widthFactor: 1,
              heightFactor: 1,
              child: Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Icon(icon, size: 20, color: AppColors.inkMuted),
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 14,
            ),
            border: border(),
            enabledBorder: border(),
            focusedBorder: border(AppColors.teal),
            errorBorder: border(AppColors.danger),
            focusedErrorBorder: border(AppColors.danger),
          ),
        ),
      ],
    );
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.active, required this.onChanged});

  final bool active;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SectionLabel('Estado'),
              SizedBox(height: 2),
              Text(
                'Habilitar disponibilidad',
                style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
              ),
            ],
          ),
        ),
        Text(
          active ? 'Activa' : 'Inactiva',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: active ? AppColors.teal : AppColors.inkMuted,
          ),
        ),
        const SizedBox(width: 8),
        Switch(
          value: active,
          onChanged: onChanged,
          thumbColor: const WidgetStatePropertyAll(Colors.white),
          trackColor: WidgetStateProperty.resolveWith(
            (states) => states.contains(WidgetState.selected)
                ? AppColors.teal
                : AppColors.mist,
          ),
          trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
        ),
      ],
    );
  }
}