import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../main.dart';
import '../../../notifications/data/notification_repository.dart';
import '../widgets/movement_tile.dart';

class StoreSummaryScreen extends StatefulWidget {
  const StoreSummaryScreen({super.key});

  @override
  State<StoreSummaryScreen> createState() => _StoreSummaryScreenState();
}

class _StoreSummaryScreenState extends State<StoreSummaryScreen> {
  final _notifRepo = NotificationRepository();
  int _unread = 0;

  @override
  void initState() {
    super.initState();
    _loadUnread();
  }

  Future<void> _loadUnread() async {
    try {
      final count = await _notifRepo.unreadCount();
      if (mounted) setState(() => _unread = count);
    } catch (_) {
      // Sin conexión: el badge queda como está
    }
  }

  Future<void> _openNotifications() async {
    await Navigator.of(context).pushNamed(AppRoutes.notifications);
    _loadUnread(); // refresca el contador al volver de la lista
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 1. TARJETA ENCABEZADO DE SALDO
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF148F8B),
                borderRadius: BorderRadius.circular(24),
              ),
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.storefront_rounded,
                          color: Colors.white,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Bodega Gian Carlos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        onPressed: _openNotifications,
                        icon: Badge(
                          isLabelVisible: _unread > 0,
                          label: Text(_unread > 9 ? '9+' : '$_unread'),
                          backgroundColor: const Color(0xFFE5A93C),
                          textColor: const Color(0xFF2C2208),
                          child: const Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'SALDO TOTAL POR COBRAR',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: Colors.white.withOpacity(0.8),
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'S/ 945.50',
                    style: TextStyle(
                      fontSize: 38,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      const Icon(
                        Icons.trending_up_rounded,
                        color: Colors.white,
                        size: 18,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Cobrado este mes: S/ 7,420',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // 2. BOTONES DE ACCIÓN RÁPIDA
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Navigator.of(context).pushNamed(AppRoutes.registroFiado);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE5A93C),
                      foregroundColor: const Color(0xFF2C2208),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(Icons.add, size: 20),
                    label: const Text(
                      'Anotar Fiado',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    style: OutlinedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.ink,
                      side: const BorderSide(color: Color(0xFFD0D7DE)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    icon: const Icon(
                      Icons.chat_bubble_outline_rounded,
                      size: 18,
                      color: AppColors.ink,
                    ),
                    label: const Text(
                      'Cobro WhatsApp',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.ink,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 3. TARJETA DE ALERTA DE LÍMITE DE CRÉDITO
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF7EA),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFF3D299), width: 1),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.only(top: 2),
                    child: Icon(
                      Icons.warning_amber_rounded,
                      color: Color(0xFFD98A1B),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: RichText(
                      text: const TextSpan(
                        style: TextStyle(
                          fontSize: 13,
                          color: Color(0xFF4A3E2C),
                          height: 1.35,
                        ),
                        children: [
                          TextSpan(
                            text: 'Límite cerca: ',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          TextSpan(
                            text:
                                'Don Roberto Ruiz está al 95% de su crédito autorizado.',
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 4. ENCABEZADO "MOVIMIENTOS DE HOY"
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Movimientos de hoy',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.ink,
                  ),
                ),
                GestureDetector(
                  onTap: () =>
                      Navigator.of(context).pushNamed(AppRoutes.customers),
                  child: Row(
                    children: const [
                      Text(
                        'Ver clientes',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF148F8B),
                        ),
                      ),
                      SizedBox(width: 2),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 18,
                        color: Color(0xFF148F8B),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // 5. LISTA DE MOVIMIENTOS
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: const [
                  MovementTile(
                    initial: 'M',
                    avatarBg: Color(0xFFBBDEFB),
                    avatarFg: Color(0xFF1565C0),
                    name: 'Doña Martha Gómez',
                    subtitle: 'Aceite 1L, Arroz 2kg, Leche',
                    amount: '+ S/ 45.50',
                    isPositive: true,
                    time: '10:15 AM',
                    showBorder: true,
                  ),
                  MovementTile(
                    initial: 'R',
                    avatarBg: Color(0xFFFFECB3),
                    avatarFg: Color(0xFFB78103),
                    name: 'Don Roberto Ruiz',
                    subtitle: 'Gaseosas 3L, Paquete bot...',
                    amount: '+ S/ 95.00',
                    isPositive: true,
                    time: '6:40 PM',
                    showBorder: true,
                  ),
                  MovementTile(
                    initial: 'C',
                    avatarBg: Color(0xFFE8F5E9),
                    avatarFg: Color(0xFF2E7D32),
                    name: 'Carlos Mendoza',
                    subtitle: 'Liquidación total cuenta ...',
                    amount: '- S/ 150.00',
                    isPositive: false,
                    time: '3:10 PM',
                    showBorder: false,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}