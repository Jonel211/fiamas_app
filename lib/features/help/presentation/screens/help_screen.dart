import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../../../../main.dart';

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  // TODO: reemplazar por contenido real / CMS de preguntas frecuentes
  static const _faqs = [
    '¿Cómo registro un nuevo fiado?',
    '¿Cómo cobrar una deuda?',
    '¿El cliente puede ver su cuenta?',
    '¿Cómo agrego más tiendas?',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 100),
          children: [
            Text('Ayuda', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            Text('¿Cómo podemos ayudarte hoy?',
                style: Theme.of(context).textTheme.bodyMedium),
            const SizedBox(height: 20),

            // Tarjeta de contacto
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppColors.teal, Color(0xFF2E5851)],
                ),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('¿Tienes alguna duda?',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                          color: Colors.white)),
                  const SizedBox(height: 6),
                  Text('Estamos aquí para apoyarte con tu tienda.',
                      style: TextStyle(
                          fontSize: 13, color: Colors.white.withValues(alpha: 0.85))),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: () {
                      // TODO: abrir chat de soporte (WhatsApp / helpdesk)
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.ink,
                      minimumSize: const Size(0, 44),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline, size: 18),
                    label: const Text('Escríbenos'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text('Preguntas Frecuentes',
                style: TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.ink)),
            const SizedBox(height: 8),
            for (final question in _faqs)
              _FaqTile(
                question: question,
                onTap: () {
                  // TODO: mostrar la respuesta (expandir o navegar al detalle)
                },
              ),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) {
            AppRoutes.goHome(context);
          } else if (index == 1) {
            Navigator.of(context).pushNamed(AppRoutes.debts);
          } else if (index == 2) {
            Navigator.of(context).pushNamed(AppRoutes.products);
          }
        },
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  const _FaqTile({required this.question, this.onTap});

  final String question;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.mist),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(question,
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.ink)),
            ),
            const Icon(Icons.chevron_right, size: 18, color: AppColors.inkMuted),
          ],
        ),
      ),
    );
  }
}