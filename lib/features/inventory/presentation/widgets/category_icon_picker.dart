import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/category_icons.dart';

class CategoryIconPicker extends StatelessWidget {
  const CategoryIconPicker({
    super.key,
    required this.selectedKey,
    required this.onChanged,
    this.color = AppColors.teal,
  });

  final String? selectedKey;
  final ValueChanged<String> onChanged;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final group in CategoryIcons.groups.entries) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(4, 12, 4, 8),
            child: Text(
              group.key,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 13,
                color: AppColors.ink,
              ),
            ),
          ),
          GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 5,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            children: [
              for (final e in group.value.entries)
                _IconCell(
                  icon: e.value,
                  selected: e.key == selectedKey,
                  color: color,
                  onTap: () => onChanged(e.key),
                ),
            ],
          ),
        ],
      ],
    );
  }
}

class _IconCell extends StatelessWidget {
  const _IconCell({
    required this.icon,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: selected ? color : AppColors.surfaceMuted,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: selected ? color : Colors.grey.shade300),
        ),
        child: Icon(icon, color: selected ? Colors.white : Colors.black54),
      ),
    );
  }
}