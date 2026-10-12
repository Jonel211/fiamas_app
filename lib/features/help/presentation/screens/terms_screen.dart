import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/simple_app_bar.dart';
import '../../data/terms_text.dart';

/// Pantalla "Términos y Condiciones".
/// Muestra el texto legal dentro de una tarjeta scrollable con
/// dos botones al final: Rechazar (dorado) y Aceptar y Continúa (teal).
class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        children: [
          const SimpleAppBar(title: 'Términos y condiciones'),
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
                        child: _buildContent(context),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ── Botones ───────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: OutlinedButton.styleFrom(
                              backgroundColor: AppColors.gold,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(48),
                              side: BorderSide.none,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              textStyle: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            child: const Text('Rechazar'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () => Navigator.of(context).pop(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.teal,
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
                            child: const Text('Aceptar y Continúa'),
                          ),
                        ),
                      ],
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

  /// Construye el contenido del texto legal con estilo uniforme.
  Widget _buildContent(BuildContext context) {
    const baseStyle = TextStyle(
      fontSize: 13,
      color: AppColors.ink,
      height: 1.55,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(TermsText.intro, style: baseStyle),
        const SizedBox(height: 14),

        const Text(TermsText.description, style: baseStyle),
        const SizedBox(height: 8),

        // Lista de características
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final item in TermsText.features)
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('• ', style: baseStyle),
                      Expanded(child: Text(item, style: baseStyle)),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 14),

        const Text(TermsText.responsibility, style: baseStyle),
        const SizedBox(height: 14),
        const Text(TermsText.accuracy, style: baseStyle),
        const SizedBox(height: 14),

        const Text(TermsText.internalUse, style: baseStyle),
        const SizedBox(height: 14),
        const Text(TermsText.consent, style: baseStyle),
        const SizedBox(height: 14),

        const Text(TermsText.reports, style: baseStyle),
        const SizedBox(height: 14),
        const Text(TermsText.noInvoice, style: baseStyle),
        const SizedBox(height: 14),

        const Text(TermsText.property, style: baseStyle),
        const SizedBox(height: 14),

        const Text(TermsText.balance, style: baseStyle),
        const SizedBox(height: 14),
        const Text(TermsText.availability, style: baseStyle),
        const SizedBox(height: 14),

        const Text(TermsText.updates, style: baseStyle),
        const SizedBox(height: 14),

        const Text(TermsText.contact, style: baseStyle),
      ],
    );
  }
}