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
    this.centerTitle = true,
    this.actions = const [],
  });

  final String title;
  final String? subtitle;
  final bool showBack;
  final VoidCallback? onBack;
  final Widget? leading;
  final bool centerTitle;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) {
    final leftWidget = leading ??
        (showBack
            ? AppHeaderIconBox(
                icon: Icons.arrow_back_ios_new_rounded,
                onTap: onBack ?? () => Navigator.of(context).maybePop(),
              )
            : const AppHeaderIconBox(icon: Icons.storefront_outlined));

    final titleColumn = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment:
          centerTitle ? CrossAxisAlignment.center : CrossAxisAlignment.start,
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            title,
            maxLines: 1,
            textAlign: centerTitle ? TextAlign.center : TextAlign.start,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
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
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 40),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Row(
              children: [
                leftWidget,
                const Spacer(),
                ...actions,
              ],
            ),
            if (centerTitle)
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 88),
                  child: Center(child: titleColumn),
                ),
              )
            else
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.only(left: 52, right: 88),
                  child: Align(
                      alignment: Alignment.centerLeft, child: titleColumn),
                ),
              ),
          ],
        ),
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