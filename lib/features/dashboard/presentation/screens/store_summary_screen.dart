import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/app_bottom_nav.dart';
import '../widgets/dashboard_action_card.dart';
import '../widgets/recent_debt_tile.dart';

class StoreSummaryScreen extends StatelessWidget {
  const StoreSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Encabezado
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.ink),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.mist,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('MI TIENDA',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppColors.inkMuted,
                                letterSpacing: 0.5)),
                        Text('Bodega "El Sol"',
                            style: Theme.of(context)
                                .textTheme
                                .headlineSmall
                                ?.copyWith(fontSize: 20)),
                      ],
                    ),
                  ),
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.mist,
                    child: const Icon(Icons.person_outline,
                        color: AppColors.ink, size: 18),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Tarjeta de saldo
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF0F2A52),
                      Color(0xFF2B5A96),
                      Color(0xFF6FA3D8),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF0F2A52).withValues(alpha: 0.35),
                      blurRadius: 28,
                      offset: const Offset(0, 14),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: Stack(
                    children: [
                      Positioned(
                        top: -60,
                        right: -40,
                        child: Transform.rotate(
                          angle: 0.5,
                          child: Container(
                            width: 220,
                            height: 260,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.white.withValues(alpha: 0.18),
                                  Colors.white.withValues(alpha: 0.0),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        right: -18,
                        bottom: -18,
                        child: Icon(
                          Icons.storefront_rounded,
                          size: 130,
                          color: Colors.white.withValues(alpha: 0.08),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.account_balance_wallet,
                                    size: 26,
                                    color: Colors.white.withValues(alpha: 0.95)),
                                const Spacer(),
                                Text(
                                  'TOTAL POR COBRAR',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.6,
                                    color: Colors.white.withValues(alpha: 0.85),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 28),
                            const Center(
                              child: Text(
                                'S/ 1,245.50',
                                style: TextStyle(
                                  fontSize: 34,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 22),
                            Center(
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 7),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.16),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.25),
                                    width: 0.8,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.schedule,
                                        size: 15,
                                        color: Colors.white.withValues(alpha: 0.9)),
                                    const SizedBox(width: 6),
                                    Text('12 fiados pendientes',
                                        style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w600,
                                            color: Colors.white
                                                .withValues(alpha: 0.95))),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),

              // Acciones rápidas
              Row(
                children: [
                  DashboardActionCard(
                    icon: Icons.add,
                    label: 'Anotar\nfiado',
                    accent: AppColors.teal,
                    onTap: () {
                      // TODO: ir a features/debts -> registrar nuevo fiado
                    },
                  ),
                  const SizedBox(width: 12),
                  DashboardActionCard(
                    icon: Icons.attach_money,
                    label: 'Cobrar',
                    accent: AppColors.ink,
                    onTap: () {
                      // TODO: ir a features/debts -> registrar abono/pago
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Últimos fiados
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Últimos fiados',
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 15,
                          color: AppColors.ink)),
                  TextButton(
                    onPressed: () {
                      // TODO: ir a features/debts -> listado completo
                    },
                    style: TextButton.styleFrom(foregroundColor: AppColors.ink),
                    child: const Text('Ver todos',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                  ),
                ],
              ),
              // TODO: reemplazar por datos reales desde DebtsRepository
              const RecentDebtTile(
                customerName: 'Ricardo Mendoza',
                timeAgo: 'Hace 1 hora',
                amount: 'S/ 45.00',
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: const AppBottomNav(currentIndex: 0),
    );
  }
}