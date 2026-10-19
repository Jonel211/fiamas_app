import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/category.dart';
import '../widgets/category_color_picker.dart';
import '../widgets/category_icon_picker.dart';
import '../widgets/category_style.dart';
import '../widgets/light_app_bar.dart';

/// Formulario para crear una categoría. Al guardar devuelve la [Category]
/// creada a la pantalla anterior.
class NewCategoryScreen extends StatefulWidget {
  const NewCategoryScreen({super.key});

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
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  void _save() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    // TODO: guardar la categoría en la API.
    Navigator.of(context).pop(Category(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _name.text.trim(),
      description: _description.text.trim(),
      color: _color,
      iconKey: _iconKey,
      active: _active,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        const LightAppBar(title: 'Nueva Categoría'),
        Expanded(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 32 + MediaQuery.of(context).padding.bottom),
            child: Form(
              key: _formKey,
              child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                _FilledField(
                  label: 'Nombre de la categoría',
                  controller: _name,
                  hint: 'Ej: Bebidas Energéticas',
                  icon: Icons.label_outline,
                  validator: (v) => (v == null || v.trim().isEmpty) ? 'Ingresa un nombre' : null,
                ),
                const SizedBox(height: 24),
                _FilledField(
                  label: 'Descripción',
                  controller: _description,
                  hint: 'Describe brevemente la categoría',
                  icon: Icons.edit_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                _StatusRow(active: _active, onChanged: (v) => setState(() => _active = v)),
                const SizedBox(height: 24),
                const _SectionLabel('Color de identificación'),
                const SizedBox(height: 12),
                CategoryColorPicker(selected: _color, onChanged: (c) => setState(() => _color = c)),
                const SizedBox(height: 24),
                const _SectionLabel('Ícono'),
                const SizedBox(height: 12),
                CategoryIconPicker(selectedKey: _iconKey, onChanged: (k) => setState(() => _iconKey = k)),
                const SizedBox(height: 32),
                ElevatedButton(
                  onPressed: _save,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    minimumSize: const Size.fromHeight(52),
                    textStyle: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('Guardar Categoría'),
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
  Widget build(BuildContext context) => Text(text,
      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink));
}

/// Campo con fondo gris azulado, sin borde y con ícono a la izquierda.
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
    OutlineInputBorder border([Color color = Colors.transparent]) => OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: color),
        );

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
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
          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          border: border(),
          enabledBorder: border(),
          focusedBorder: border(AppColors.teal),
          errorBorder: border(AppColors.danger),
          focusedErrorBorder: border(AppColors.danger),
        ),
      ),
    ]);
  }
}

/// "Estado" con su descripción y el interruptor Activa / Inactiva.
class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.active, required this.onChanged});

  final bool active;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      const Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _SectionLabel('Estado'),
          SizedBox(height: 2),
          Text('Habilitar disponibilidad', style: TextStyle(fontSize: 12, color: AppColors.inkMuted)),
        ]),
      ),
      Text(active ? 'Activa' : 'Inactiva',
          style: TextStyle(
              fontSize: 14, fontWeight: FontWeight.w700, color: active ? AppColors.teal : AppColors.inkMuted)),
      const SizedBox(width: 8),
      Switch(
        value: active,
        onChanged: onChanged,
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? AppColors.teal : AppColors.mist,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(Colors.transparent),
      ),
    ]);
  }
}