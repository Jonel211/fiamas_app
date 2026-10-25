import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header_config.dart';
import '../../../../main.dart';
import '../../../auth/data/models/tienda_model.dart';
import '../../../auth/presentation/providers/tienda_provider.dart';
import '../widgets/delete_store_list_item.dart';

class DeleteStoreScreen extends StatefulWidget {
  final TiendaModel? tienda;

  const DeleteStoreScreen({super.key, this.tienda});

  @override
  State<DeleteStoreScreen> createState() => _DeleteStoreScreenState();
}

class _DeleteStoreScreenState extends State<DeleteStoreScreen> {
  final _confirmController = TextEditingController();
  bool _isUnderstood = false;
  bool _isDeleting = false;
  String? _reason;

  bool get _canDelete =>
      _confirmController.text.trim().toUpperCase() == 'ELIMINAR' &&
      _isUnderstood;

  @override
  void dispose() {
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleDelete(String tiendaId) async {
    setState(() => _isDeleting = true);

    final success = await context.read<TiendaProvider>().eliminarTienda(tiendaId);

    if (!mounted) return;
    setState(() => _isDeleting = false);

    if (success) {
      await context.read<TiendaProvider>().cargarMisTiendas();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tienda eliminada exitosamente'),
          backgroundColor: AppColors.teal,
          behavior: SnackBarBehavior.floating,
        ),
      );
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.stores,
        (route) => false,
      );
    } else {
      final err =
          context.read<TiendaProvider>().error ?? 'Error al eliminar la tienda';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(err),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final routeArg = ModalRoute.of(context)?.settings.arguments;
    final tiendas = context.watch<TiendaProvider>().tiendas;
    final TiendaModel? tienda = widget.tienda ??
        (routeArg is TiendaModel ? routeArg : null) ??
        (tiendas.isNotEmpty ? tiendas.first : null);

    final nombreTienda = tienda?.nombre ?? 'tu tienda';

    return AppHeaderConfig(
      title: 'Eliminar tienda',
      showBack: true,
      centerTitle: true,
      child: Scaffold(
        backgroundColor: AppColors.ivory,
        body: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              color: Colors.red,
              size: 60,
            ),
            const SizedBox(height: 16),
            Text(
              '¿Eliminar $nombreTienda?',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Esta acción es permanente y no\nse puede deshacer',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
            ),
            const SizedBox(height: 24),

            // Información sobre impacto
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.red.withValues(alpha: 0.3),
                ),
              ),
              child: const Text(
                'Todos los clientes, deudas, inventario y registros asociados a esta tienda serán eliminados permanentemente.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.red,
                ),
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Se eliminará',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 12),
            const Column(
              children: [
                DeleteStoreListItem(text: 'Clientes y límites de crédito'),
                DeleteStoreListItem(text: 'Historial de fiados y pagos'),
                DeleteStoreListItem(text: 'Inventario y categorías'),
                DeleteStoreListItem(text: 'Reportes y estadísticas'),
              ],
            ),
            const SizedBox(height: 24),

            const Text(
              'Confirmación',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
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
                    initialValue: _reason,
                    hint: const Text(
                      'Motivo (opcional)',
                      style: TextStyle(fontSize: 13),
                    ),
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'Cerré el negocio',
                        child: Text(
                          'Cerré el negocio',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Problemas técnicos',
                        child: Text(
                          'Problemas técnicos',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'Otro',
                        child: Text(
                          'Otro',
                          style: TextStyle(fontSize: 13),
                        ),
                      ),
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
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 14,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: _isUnderstood,
                        activeColor: AppColors.teal,
                        onChanged: (val) =>
                            setState(() => _isUnderstood = val ?? false),
                      ),
                      const Expanded(
                        child: Text(
                          'Entiendo que no se puede deshacer',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.inkMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            OutlinedButton.icon(
              onPressed: (_canDelete && !_isDeleting && tienda != null)
                  ? () => _handleDelete(tienda.id)
                  : null,
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                disabledForegroundColor: AppColors.mist,
                side: BorderSide(
                  color: _canDelete ? Colors.red : AppColors.mist,
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              icon: _isDeleting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.red,
                      ),
                    )
                  : const Icon(Icons.delete_outline_rounded, size: 20),
              label: Text(
                _isDeleting
                    ? 'Eliminando tienda...'
                    : 'Eliminar tienda definitivamente',
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 12),

            OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.ink,
                side: const BorderSide(color: AppColors.mist),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Cancelar, conservar tienda',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
