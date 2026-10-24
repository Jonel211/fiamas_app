import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header.dart';

/// Cliente con saldo pendiente para la cobranza por WhatsApp.
class _Deudor {
  const _Deudor(this.nombre, this.telefono, this.saldo);

  final String nombre;

  /// Teléfono con código de país, sin +, espacios ni guiones.
  final String telefono;
  final double saldo;
}

/// Pantalla de cobranza por WhatsApp.
class WhatsappCollectionScreen extends StatelessWidget {
  const WhatsappCollectionScreen({super.key});

  static const String _tono = 'Respetuosa';

  static const List<_Deudor> _deudores = [
    _Deudor('Doña Martha Gómez', '51987654321', 145.50),
    _Deudor('Don Roberto Ruiz', '51912345678', 285.00),
    _Deudor('Lucía Benítez', '51998776554', 195.00),
    _Deudor('Andrés Morales', '51911223344', 320.00),
  ];

  String _mensaje(_Deudor d) =>
      'Hola ${d.nombre} ¿cómo estás? Te recordamos con cariño '
      'que tienes un saldo pendiente de S/ ${d.saldo.toStringAsFixed(2)} '
      'en la bodega. ¡Gracias!';

  Future<void> _recordar(BuildContext context, _Deudor d) async {
    final uri = Uri.parse(
      'https://wa.me/${d.telefono}?text=${Uri.encodeComponent(_mensaje(d))}',
    );
    var abierto = false;
    try {
      abierto = await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (_) {}
    if (!abierto && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir WhatsApp')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AppHeader(
            title: 'Bodega Gian Carlos',
            showBack: true,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 24),
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(4, 0, 4, 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Cobranza WhatsApp',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                      _TonoChip(tono: _tono),
                    ],
                  ),
                ),
                for (final d in _deudores)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: _DeudorCard(
                      deudor: d,
                      onRecordar: () => _recordar(context, d),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}



/// Chip informativo con el tono del mensaje de recordatorio.
class _TonoChip extends StatelessWidget {
  const _TonoChip({required this.tono});

  final String tono;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: AppColors.tealSoft,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        tono,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
          color: AppColors.teal,
        ),
      ),
    );
  }
}

/// Tarjeta de un cliente: nombre, saldo pendiente y botón de recordatorio.
class _DeudorCard extends StatelessWidget {
  const _DeudorCard({required this.deudor, required this.onRecordar});

  final _Deudor deudor;
  final VoidCallback onRecordar;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  deudor.nombre,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Saldo: S/ ${deudor.saldo.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.teal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Material(
            color: AppColors.teal,
            borderRadius: BorderRadius.circular(10),
            child: InkWell(
              onTap: onRecordar,
              borderRadius: BorderRadius.circular(10),
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                child: Text(
                  'Recordar',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
