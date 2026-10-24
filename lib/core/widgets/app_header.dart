import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AppHeader extends StatelessWidget {
  const AppHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.showBack = false,
    this.onBack,
    this.leading,
    this.centerTitle = false,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;

  /// Si se pasa, reemplaza el icono izquierdo por defecto (tienda / volver).
  final Widget? leading;

  /// Centra el título en el header.
  final bool centerTitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final leftWidget = leading ??
        AppHeaderIconBox(
          icon: showBack
              ? Icons.arrow_back_ios_new_rounded
              : Icons.storefront_outlined,
          onTap: showBack
              ? (onBack ?? () => Navigator.of(context).maybePop())
              : null,
        );

    final titleColumn = Column(
      crossAxisAlignment:
          centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          title,
          maxLines: 1,
          textAlign: centerTitle ? TextAlign.center : TextAlign.start,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        if (subtitle != null)
          Text(
            subtitle!,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, color: Colors.white70),
          ),
      ],
    );

    return Container(
      color: AppColors.teal,
      padding: EdgeInsets.fromLTRB(
          16, MediaQuery.of(context).padding.top + 12, 16, 12),
      child: Row(
        children: [
          if (centerTitle)
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48),
              child: Align(alignment: Alignment.centerLeft, child: leftWidget),
            )
          else ...[
            leftWidget,
            const SizedBox(width: 12),
          ],
          Expanded(child: titleColumn),
          if (centerTitle)
            ConstrainedBox(
              constraints: const BoxConstraints(minWidth: 48),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.end,
                children: actions,
              ),
            )
          else
            ...actions,
        ],
      ),
    );
  }
}

class AppHeaderIconBox extends StatelessWidget {
  const AppHeaderIconBox({super.key, required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}

class AppHeaderIconAction extends StatelessWidget {
  const AppHeaderIconAction({super.key, required this.icon, this.onTap});
  final IconData icon;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => IconButton(
        onPressed: onTap,
        icon: Icon(icon, color: Colors.white),
      );
}

class AppHeaderPillAction extends StatelessWidget {
  const AppHeaderPillAction({super.key, required this.label, this.onTap});
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
}