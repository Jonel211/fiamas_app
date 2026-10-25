import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_header_config.dart';
import '../widgets/about_section_title.dart';
import '../widgets/feature_card.dart';
import '../widgets/contact_link.dart';

/// Pantalla "Acerca de Fiamas".
/// Se abre desde el Menú > Legal.
class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  static const String _logo = 'assets/images/fiamas-vertical.png';

  @override
  Widget build(BuildContext context) {
    return AppHeaderConfig(
      title: 'Acerca de Fiamas',
      showBack: true,
      child: Scaffold(
        backgroundColor: AppColors.ivory,
        body: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // ── Logo ──────────────────────────────
                    Center(
                      child: Image.asset(
                        _logo,
                        height: 90,
                        errorBuilder: (_, __, ___) => const Text(
                          'FIAMAS',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),

                    // ── Tagline ───────────────────────────
                    const Text(
                      '"Digitalizando la confianza"',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.w600,
                        color: AppColors.inkMuted,
                      ),
                    ),
                    const SizedBox(height: 6),

                    // ── Versión ───────────────────────────
                    const Text(
                      'versión 1.0.0 build 1',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
                    ),
                    const SizedBox(height: 32),

                    // ── Quiénes Somos ─────────────────────
                    const AboutSectionTitle(title: 'Quiénes Somos'),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.teal.withOpacity(0.45),
                        ),
                      ),
                      child: const Text(
                        'App móvil para tenderos que reemplaza el cuaderno de fiados por un registro ágil y transparente.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.ink,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // ── Qué puedes hacer ──────────────────
                    const AboutSectionTitle(title: 'Qué puedes hacer'),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 12,
                      crossAxisSpacing: 12,
                      childAspectRatio: 1.25,
                      children: const [
                        FeatureCard(label: 'Fiados y\nabonos'),
                        FeatureCard(label: 'Límites de\ncrédito'),
                        FeatureCard(label: 'Escaner de\nproductos'),
                        FeatureCard(label: 'Historial'),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Contacto ──────────────────────────
                    const AboutSectionTitle(title: 'Contacto'),
                    ContactLink(
                      icon: Icons.public_rounded,
                      label: 'Sitio web',
                      onTap: () {
                        // TODO: abrir URL del sitio
                      },
                    ),
                    const SizedBox(height: 10),
                    ContactLink(
                      icon: Icons.star_outline_rounded,
                      label: 'Calificar la app',
                      onTap: () {
                        // TODO: abrir Play Store
                      },
                    ),
                    const SizedBox(height: 32),

                    // ── Copyright ─────────────────────────
                    // ── Copyright ─────────────────────────
                    const Text(
                      '© 2026 Fiamas',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 12, color: AppColors.inkMuted),
                    ),
                  ], // children de la Column interna
                ), // Column interna
              ), // SingleChildScrollView
            ), // Expanded
          ],
        ), // Column
      ), // Scaffold
    ); // AppHeaderConfig
  }
}
