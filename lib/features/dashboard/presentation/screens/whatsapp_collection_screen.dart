import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';

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
          const _TopBar(title: 'Bodega Gian Carlos'),
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

//// Cabecera teal: flecha con recuadro a la izquierda y tienda + título centrados.
class _TopBar extends StatelessWidget {
  const _TopBar({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    final topInset = MediaQuery.of(context).padding.top;

    return Container(
      color: AppColors.teal,
      padding: EdgeInsets.fromLTRB(16, topInset + 12, 16, 16),
      child: SizedBox(
        height: 44,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Flecha de regreso con recuadro sombreado (izquierda).
            Align(
              alignment: Alignment.centerLeft,
              child: Material(
                color: Colors.white.withValues(alpha: 0.18),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => Navigator.of(context).maybePop(),
                  borderRadius: BorderRadius.circular(12),
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ),
            // Icono de tienda + título (centro).
            const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.storefront_outlined,
                  color: Colors.white,
                  size: 22,
                ),
                SizedBox(width: 12),
                Text(
                  'Bodega Gian Carlos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ],
        ),
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
