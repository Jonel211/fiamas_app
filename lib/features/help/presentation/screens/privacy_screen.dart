import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../../data/privacy_text.dart';

/// Pantalla "Política de Privacidad".
/// Muestra el texto legal dentro de una tarjeta scrollable con un
/// único botón "Entendido" al final (dorado).
class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        children: [
          const SimpleAppBar(title: 'Política de Privacidad'),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: AppColors.teal.withOpacity(0.45),
                  ),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    // ── Texto scrollable ───────────────────
                    Expanded(
                      child: SingleChildScrollView(
                        child: _buildContent(),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Botón único ───────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(context).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.gold,
                          foregroundColor: Colors.white,
                          minimumSize: const Size.fromHeight(48),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          textStyle: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        child: const Text('Entendido'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construye el texto completo con párrafos y listas.
  Widget _buildContent() {
    const baseStyle = TextStyle(
      fontSize: 13,
      color: AppColors.ink,
      height: 1.55,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(PrivacyText.intro, style: baseStyle),
        const SizedBox(height: 14),

        // ── Datos recopilados ──────────────────────────
        const Text(PrivacyText.collectIntro, style: baseStyle),
        const SizedBox(height: 8),
        _buildBulletList(PrivacyText.collectedData, baseStyle),
        const SizedBox(height: 14),

        // ── Fines de uso ───────────────────────────────
        const Text(PrivacyText.purposesIntro, style: baseStyle),
        const SizedBox(height: 8),
        _buildBulletList(PrivacyText.purposes, baseStyle),
        const SizedBox(height: 14),

        // ── Avisos ─────────────────────────────────────
        const Text(PrivacyText.balance, style: baseStyle),
        const SizedBox(height: 14),
        const Text(PrivacyText.availability, style: baseStyle),
        const SizedBox(height: 14),

        // ── Terceros ───────────────────────────────────
        const Text(PrivacyText.thirdPartiesIntro, style: baseStyle),
        const SizedBox(height: 8),
        _buildBulletList(PrivacyText.thirdParties, baseStyle),
        const SizedBox(height: 14),

        // ── Derechos ───────────────────────────────────
        const Text(PrivacyText.rights, style: baseStyle),
        const SizedBox(height: 14),

        // ── Actualizaciones ────────────────────────────
        const Text(PrivacyText.updates, style: baseStyle),
        const SizedBox(height: 14),

        // ── Contacto ───────────────────────────────────
        const Text(PrivacyText.contactIntro, style: baseStyle),
        const SizedBox(height: 8),
        _buildBulletList(PrivacyText.contactChannels, baseStyle),
      ],
    );
  }

  /// Lista con viñetas para reutilizar con cualquier lista de strings.
  Widget _buildBulletList(List<String> items, TextStyle style) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final item in items)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('• ', style: style),
                  Expanded(child: Text(item, style: style)),
                ],
              ),
            ),
        ],
      ),
    );
  }
}