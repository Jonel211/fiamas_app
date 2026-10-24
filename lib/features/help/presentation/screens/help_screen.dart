import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header.dart';
import '../../data/help_repository.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  static const _faqs = [
    (
      q: '¿Cómo registro un nuevo fiado?',
      a:
          'Entra a la tienda, abre Fiados y toca "Nuevo fiado". Elige al '
          'cliente, agrega los productos y guarda.',
    ),
    (
      q: '¿Cómo cobrar una deuda?',
      a:
          'En Fiados abre la deuda del cliente y toca "Registrar abono". '
          'Escribe el monto recibido y confirma.',
    ),
    (
      q: '¿El cliente puede ver su cuenta?',
      a:
          'Sí. El cliente crea su cuenta desde la app y ve sus deudas y '
          'pagos de cada tienda.',
    ),
    (
      q: '¿Cómo agrego más tiendas?',
      a:
          'En "Mis tiendas" toca "Nueva tienda" y completa los datos del '
          'negocio.',
    ),
  ];

  // abrir formulario
  void _openHelpForm(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _HelpFormBottomSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const AppHeader(
            title: 'Ayuda',
            showBack: true,
            centerTitle: true,
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                const SizedBox(height: 4),
                const Text(
                  '¿Cómo podemos ayudarte hoy?',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 15, color: AppColors.ink),
                ),
                const SizedBox(height: 24),

                // Tarjeta de contacto
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.teal,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '¿Tienes alguna duda o inconveniente?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        'Envía un mensaje directo al administrador de Fiamas',
                        style: TextStyle(fontSize: 13, color: Colors.white),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: () => _openHelpForm(context),
                        icon: const Icon(Icons.chat_bubble_outline, size: 18),
                        label: const Text('Escríbenos'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.ink,
                          elevation: 0,
                          minimumSize: const Size(0, 38),
                          textStyle: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 28),

                const Text(
                  'Preguntas Frecuentes',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: 14),
                for (final faq in _faqs) ...[
                  _FaqTile(question: faq.q, answer: faq.a),
                  const SizedBox(height: 14),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Modal bottom sheet con formulario para enviar solicitud de ayuda al Administrador
class _HelpFormBottomSheet extends StatefulWidget {
  const _HelpFormBottomSheet();

  @override
  State<_HelpFormBottomSheet> createState() => _HelpFormBottomSheetState();
}

class _HelpFormBottomSheetState extends State<_HelpFormBottomSheet> {
  final _formKey = GlobalKey<FormState>();
  final _asuntoController = TextEditingController();
  final _mensajeController = TextEditingController();
  final _repository = HelpRepository();

  String _prioridad = 'media';
  bool _isLoading = false;

  @override
  void dispose() {
    _asuntoController.dispose();
    _mensajeController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await _repository.enviarMensajeAyuda(
        asunto: _asuntoController.text,
        mensaje: _mensajeController.text,
        prioridad: _prioridad,
      );

      if (!mounted) return;
      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            '¡Mensaje de ayuda enviado! El administrador lo revisará a la brevedad.',
          ),
          backgroundColor: AppColors.teal,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: AppColors.danger,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Barra indicadora superior
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Formulario de Ayuda',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppColors.ink,
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: AppColors.inkMuted),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Envía tu duda o reporte. Llegará directamente a la sección de avisos del administrador.',
                style: TextStyle(fontSize: 13, color: AppColors.inkMuted),
              ),
              const SizedBox(height: 20),

              // Campo Asunto
              const Text(
                'Asunto',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _asuntoController,
                decoration: InputDecoration(
                  hintText: 'Ej: Consulta sobre cobranzas, duda con inventario...',
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.mist),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Ingresa el asunto del mensaje' : null,
              ),
              const SizedBox(height: 16),

              // Prioridad
              const Text(
                'Prioridad',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _PriorityChip(
                    label: 'Baja',
                    selected: _prioridad == 'baja',
                    color: Colors.blue,
                    onTap: () => setState(() => _prioridad = 'baja'),
                  ),
                  const SizedBox(width: 8),
                  _PriorityChip(
                    label: 'Media',
                    selected: _prioridad == 'media',
                    color: Colors.amber[800]!,
                    onTap: () => setState(() => _prioridad = 'media'),
                  ),
                  const SizedBox(width: 8),
                  _PriorityChip(
                    label: 'Alta',
                    selected: _prioridad == 'alta',
                    color: Colors.red,
                    onTap: () => setState(() => _prioridad = 'alta'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Campo Mensaje
              const Text(
                'Mensaje detallado',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.ink),
              ),
              const SizedBox(height: 6),
              TextFormField(
                controller: _mensajeController,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Describe claramente en qué necesitas asistencia o qué ocurrió...',
                  hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.mist),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(color: AppColors.teal, width: 1.5),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return 'Ingresa el mensaje de tu consulta';
                  }
                  if (v.trim().length < 5) {
                    return 'El mensaje debe contener al menos 5 caracteres';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Botón Enviar
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text(
                        'Enviar mensaje al Administrador',
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({
    required this.label,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? color.withValues(alpha: 0.15) : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? color : AppColors.inkMuted,
          ),
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
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _open = !_open),
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      widget.question,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _open ? 0.25 : 0, // la flecha gira hacia abajo
                    duration: const Duration(milliseconds: 200),
                    child: const Icon(
                      Icons.chevron_right,
                      size: 20,
                      color: AppColors.ink,
                    ),
                  ),
                ],
              ),
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
                      child: Text(
                        widget.answer,
                        style: const TextStyle(
                          fontSize: 14,
                          height: 1.4,
                          color: AppColors.ink,
                        ),
                      ),
                    ),
                  )
                : const SizedBox(width: double.infinity),
          ),
        ],
      ),
    );
  }
}
