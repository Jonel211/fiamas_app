import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ReportsHeader extends StatelessWidget {
  const ReportsHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: Row(
        children: [
          // Botón Atrás
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.mist),
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: AppColors.ink),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          const SizedBox(width: 12),
          
          // Título
          const Expanded(
            child: Text(
              'Reportes',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.ink),
            ),
          ),
          
          // BOTÓN EXPORTAR PDF (Hecho a medida para evitar el error de infinito)
          GestureDetector(
            onTap: () {
              // TODO: Lógica para exportar PDF
            },
            child: Container(
              // padding vertical 10 lo hace un poquito más alto como pediste
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.teal,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min, // Crucial para que no intente ser infinito
                children: const [
                  Icon(Icons.picture_as_pdf_rounded, size: 16, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Exportar PDF',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}