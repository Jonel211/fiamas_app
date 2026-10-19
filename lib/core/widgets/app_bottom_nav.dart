import 'package:flutter/material.dart';

import '../constants/app_colors.dart';

class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.currentIndex,
    this.onTap,
    this.onFiadoTap,
  });

  final int currentIndex;
  final ValueChanged<int>? onTap;
  final VoidCallback? onFiadoTap;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Stack(
        alignment: Alignment.bottomCenter,
        clipBehavior: Clip.none,
        children: [
          // 1. LA BARRA BLANCA (FONDO)
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            height: 68,
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(35),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // 0: Inicio
                _NavItem(
                  icon: Icons.home_outlined,
                  activeIcon: Icons.home_rounded,
                  label: 'Inicio',
                  isSelected: currentIndex == 0,
                  onTap: () => onTap?.call(0),
                ),
                // 1: Productos
                _NavItem(
                  icon: Icons.inventory_2_outlined,
                  activeIcon: Icons.inventory_2_rounded,
                  label: 'Productos',
                  isSelected: currentIndex == 1,
                  onTap: () => onTap?.call(1),
                ),

                // HUECO EN EL CENTRO para el botón de Fiado
                const SizedBox(width: 60),

                // 3: Clientes (índice 3 en main_shell)
                _NavItem(
                  icon: Icons.people_outline_rounded,
                  activeIcon: Icons.people_rounded,
                  label: 'Clientes',
                  isSelected: currentIndex == 3,
                  onTap: () => onTap?.call(3),
                ),
                // 4: Más
                _NavItem(
                  icon: Icons.grid_view_outlined,
                  activeIcon: Icons.grid_view_rounded,
                  label: 'Más',
                  isSelected: currentIndex == 4,
                  onTap: () => onTap?.call(4),
                ),
              ],
            ),
          ),

          // 2. EL BOTÓN FLOTANTE DE FIADO (+)
          Positioned(
            top: -15,
            child: GestureDetector(
              onTap: onFiadoTap,
              behavior: HitTestBehavior.opaque,
              child: Container(
                // Área de toque más ancha para evitar toques accidentales
                width: 80,
                color: Colors.transparent,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 54,
                      height: 54,
                      decoration: BoxDecoration(
                        color: AppColors.teal,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.teal.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Icon(Icons.add, color: Colors.white, size: 32),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Fiado',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
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
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final textColor = isSelected ? AppColors.teal : AppColors.inkMuted;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(35),
          onTap: onTap,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.teal : Colors.transparent,
                ),
                child: Icon(
                  isSelected ? activeIcon : icon,
                  size: 22,
                  color: isSelected ? Colors.white : AppColors.inkMuted,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: textColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}