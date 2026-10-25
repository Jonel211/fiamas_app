import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header_config.dart';
import '../../../../main.dart'; // <-- Para usar AppRoutes.summary
import '../widgets/fiado_product_item.dart';

class FinalizarFiadoScreen extends StatefulWidget {
  const FinalizarFiadoScreen({super.key});

  @override
  State<FinalizarFiadoScreen> createState() => _FinalizarFiadoScreenState();
}

class _FinalizarFiadoScreenState extends State<FinalizarFiadoScreen> {
  final _dateController = TextEditingController();

  final List<Map<String, dynamic>> _productos = [
    {'name': 'Aceite 1L', 'price': 4.50},
    {'name': 'Arroz 2kg', 'price': 8.00},
    {'name': 'Leche 400g', 'price': 4.50},
    {'name': 'Gaseosas 3L', 'price': 12.00},
    {'name': 'Paquete botanas', 'price': 6.50},
    {'name': 'Detergente 1kg', 'price': 8.00},
    {'name': 'Jabón Bolívar x3', 'price': 7.00},
  ];

  @override
  void dispose() {
    _dateController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _dateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  // Función reutilizable para mostrar el diálogo de confirmación
  Future<bool> _showConfirmDialog({
    required String title,
    required String message,
    required String confirmText,
    required Color confirmColor,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppColors.ink,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(color: AppColors.inkMuted),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text(
              'Volver',
              style: TextStyle(
                color: AppColors.inkMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: confirmColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  // Función para regresar al dashboard limpiando el historial
  void _goToDashboard() {
    Navigator.of(context)
        .pushNamedAndRemoveUntil(AppRoutes.summary, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    double total = _productos.fold(
      0,
      (sum, item) => sum + (item['price'] as double),
    );

    return AppHeaderConfig(
      title: 'Finalizar fiado',
      showBack: true,
      centerTitle: true,
      child: Scaffold(
        backgroundColor: AppColors.ivory,
        body: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. FECHA LÍMITE
              const Text(
                'Fecha límite de pago',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _dateController,
                readOnly: true,
                onTap: _selectDate,
                decoration: InputDecoration(
                  hintText: 'Selecciona una fecha',
                  hintStyle: const TextStyle(
                    color: AppColors.inkMuted,
                    fontSize: 14,
                  ),
                  suffixIcon: const Icon(
                    Icons.calendar_today_outlined,
                    color: AppColors.ink,
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.mist),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: AppColors.mist),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // 2. TARJETA DE PRODUCTOS
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.mist),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Productos',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.teal,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      '24 SEP 2026',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 12),

                    ..._productos.map(
                      (p) =>
                          FiadoProductItem(name: p['name'], price: p['price']),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // 3. TOTAL
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: AppColors.teal.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total :',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                    Text(
                      total.toStringAsFixed(2),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.ink,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // 4. BOTONES DE ACCIÓN
              // Volver a elegir (solo cierra esta pantalla y vuelve atrás)
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Volver a elegir',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 12),

              // Cancelar (Pide confirmación y va al dashboard)
              ElevatedButton(
                onPressed: () async {
                  final confirmed = await _showConfirmDialog(
                    title: 'Cancelar fiado',
                    message: '¿Estás seguro de que deseas cancelar este fiado? Los datos ingresados se perderán.',
                    confirmText: 'Sí, cancelar',
                    confirmColor: AppColors.danger,
                  );
                  if (confirmed && mounted) {
                    _goToDashboard();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.gold,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 12),

              // Finalizar (Pide confirmación y va al dashboard)
              ElevatedButton(
                onPressed: () async {
                  final confirmed = await _showConfirmDialog(
                    title: 'Finalizar fiado',
                    message:
                        '¿Estás seguro de que deseas registrar este fiado?',
                    confirmText: 'Sí, finalizar',
                    confirmColor: AppColors.teal,
                  );
                  if (confirmed && mounted) {
                    // TODO: Aquí iría la llamada al backend para guardar
                    _goToDashboard();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Finalizar',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
