import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  // TODO: revisar las respuestas y reemplazarlas por el texto final.
  static const _faqs = [
    (
      q: '¿Cómo registro un nuevo fiado?',
      a: 'Entra a la tienda, abre Fiados y toca "Nuevo fiado". Elige al '
          'cliente, agrega los productos y guarda.',
    ),
    (
      q: '¿Cómo cobrar una deuda?',
      a: 'En Fiados abre la deuda del cliente y toca "Registrar abono". '
          'Escribe el monto recibido y confirma.',
    ),
    (
      q: '¿El cliente puede ver su cuenta?',
      a: 'Sí. El cliente crea su cuenta desde la app y ve sus deudas y '
          'pagos de cada tienda.',
    ),
    (
      q: '¿Cómo agrego más tiendas?',
      a: 'En "Mis tiendas" toca "Nueva tienda" y completa los datos del '
          'negocio.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            // Barra: flecha + título centrado
            Row(children: [
              IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(Icons.arrow_back, color: AppColors.ink),
              ),
              const Expanded(
                child: Text('Ayuda', textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.ink)),
              ),
              const SizedBox(width: 48), // equilibra la flecha
            ]),
            const SizedBox(height: 4),
            const Text('¿Cómo podemos ayudarte hoy?', textAlign: TextAlign.center,
                style: TextStyle(fontSize: 15, color: AppColors.ink)),
            const SizedBox(height: 24),

            // Tarjeta de contacto
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppColors.teal, borderRadius: BorderRadius.circular(14)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('¿Tienes alguna duda?',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 4),
                const Text('Estamos aquí para apoyarte con tu tienda',
                    style: TextStyle(fontSize: 13, color: Colors.white)),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  // TODO: abrir WhatsApp o el chat de soporte.
                  onPressed: () {},
                  icon: const Icon(Icons.chat_bubble_outline, size: 18),
                  label: const Text('Escríbenos'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.ink,
                    elevation: 0,
                    minimumSize: const Size(0, 38),
                    textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ]),
            ),
            const SizedBox(height: 28),

            const Text('Preguntas Frecuentes',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppColors.ink)),
            const SizedBox(height: 14),
            for (final faq in _faqs) ...[
              _FaqTile(question: faq.q, answer: faq.a),
              const SizedBox(height: 14),
            ],
          ],
        ),
      ),
    );
  }
}

/// Pregunta que al tocarla se expande hacia abajo y muestra la respuesta.
class _FaqTile extends StatefulWidget {
  const _FaqTile({required this.question, required this.answer});

  final String question;
  final String answer;

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.teal),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(children: [
        InkWell(
          onTap: () => setState(() => _open = !_open),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
            child: Row(children: [
              Expanded(
                child: Text(widget.question,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink)),
              ),
              AnimatedRotation(
                turns: _open ? 0.25 : 0, // la flecha gira hacia abajo
                duration: const Duration(milliseconds: 200),
                child: const Icon(Icons.chevron_right, size: 20, color: AppColors.ink),
              ),
            ]),
          ),
        ),
        // La respuesta aparece con una animación de altura.
        AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: _open
              ? Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: Text(widget.answer,
                        style: const TextStyle(fontSize: 14, height: 1.4, color: AppColors.ink)),
                  ),
                )
              : const SizedBox(width: double.infinity),
        ),
      ]),
    );
  }
}