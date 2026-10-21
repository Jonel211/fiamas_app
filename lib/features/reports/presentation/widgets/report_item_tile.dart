import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class ReportItemTile extends StatelessWidget {
  const ReportItemTile({
    super.key,
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.status,
    required this.icon,
    required this.iconColor,
    required this.iconBg,
    required this.statusColor,
  });

  final String title;
  final String subtitle;
  final String amount;
  final String status;
  final IconData icon;
  final Color iconColor;
  final Color iconBg;
  final Color statusColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.mist),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              mainAxisSize: MainAxisSize.min, // <--- ESTA ES LA SOLUCIÓN
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.ink)),
                const SizedBox(height: 2),
                Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.inkMuted)),
                const SizedBox(height: 4),
                Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: statusColor)),
              ],
            ),
          ),
          SizedBox(
            width: 60,
            height: 44,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange.withOpacity(0.1),
                foregroundColor: Colors.orange,
                elevation: 0,
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.picture_as_pdf_rounded, size: 16),
                  Text('PDF', style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}