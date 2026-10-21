import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../widgets/delete_store_list_item.dart';

class DeleteStoreScreen extends StatefulWidget {
  const DeleteStoreScreen({super.key});

  @override
  State<DeleteStoreScreen> createState() => _DeleteStoreScreenState();
}

class _DeleteStoreScreenState extends State<DeleteStoreScreen> {
  final _confirmController = TextEditingController();
  bool _isUnderstood = false;
  String? _reason;

  bool get _canDelete =>
      _confirmController.text.trim().toUpperCase() == 'ELIMINAR' &&
      _isUnderstood;

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(
        backgroundColor: AppColors.ivory,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.ink, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Eliminar tienda',
          style: TextStyle(color: AppColors.ink, fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          const Text(
            '¿Eliminar tu tienda?',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.ink),
          ),
          const SizedBox(height: 8),
          const Text(
            'Esta acción es permanente y no\nse puede deshacer',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
          ),
          const SizedBox(height: 24),

          // Alerta de saldo
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.red.withOpacity(0.05),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red.withOpacity(0.3)),
            ),
            child: const Text(
              'Tienes 8 clientes con saldo pendiente por S/ 23456',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.red),
            ),
          ),
          const SizedBox(height: 24),

          const Text('Se eliminará', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink)),
          const SizedBox(height: 12),
          const Column(
            children: [
              DeleteStoreListItem(text: 'Clientes y límites'),
              DeleteStoreListItem(text: 'Historial de fiados'),
              DeleteStoreListItem(text: 'Inventario y categorías'),
              DeleteStoreListItem(text: 'Reportes'),
            ],
          ),
          const SizedBox(height: 16),

          // BOTÓN EXPORTAR CORREGIDO
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.teal,
              side: const BorderSide(color: AppColors.teal),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), // Margen horizontal
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: Row(
              children: [
                const Icon(Icons.download_rounded, size: 20),
                const SizedBox(width: 12), // Separación entre ícono y texto
                const Expanded(
                  child: Text(
                    'Exportar mis datos', 
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, size: 20),
              ],
            ),
          ),
          const SizedBox(height: 24),

          const Text('Confirmación', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.mist),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: _reason,
                  hint: const Text('Motivo (opcional)', style: TextStyle(fontSize: 13)),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'Cerré el negocio', child: Text('Cerré el negocio', style: TextStyle(fontSize: 13))),
                    DropdownMenuItem(value: 'Problemas técnicos', child: Text('Problemas técnicos', style: TextStyle(fontSize: 13))),
                    DropdownMenuItem(value: 'Otro', child: Text('Otro', style: TextStyle(fontSize: 13))),
                  ],
                  onChanged: (val) => setState(() => _reason = val),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _confirmController,
                  onChanged: (_) => setState(() {}),
                  decoration: InputDecoration(
                    hintText: "Escribe 'ELIMINAR'",
                    hintStyle: const TextStyle(fontSize: 13),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Checkbox(
                      value: _isUnderstood,
                      activeColor: AppColors.teal,
                      onChanged: (val) => setState(() => _isUnderstood = val ?? false),
                    ),
                    const Expanded(
                      child: Text('Entiendo que no se puede deshacer', style: TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          OutlinedButton.icon(
            onPressed: _canDelete ? () {
              Navigator.of(context).pushNamedAndRemoveUntil('/stores', (route) => false);
            } : null,
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.teal,
              disabledForegroundColor: AppColors.mist,
              side: BorderSide(color: _canDelete ? AppColors.teal : AppColors.mist),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.delete_outline_rounded, size: 20),
            label: const Text('Eliminar tienda definitivamente', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          const SizedBox(height: 12),

          OutlinedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.ink,
              side: const BorderSide(color: AppColors.mist),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Cancelar, conservar tienda', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }
}