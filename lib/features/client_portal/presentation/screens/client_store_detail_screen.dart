import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/client_debt.dart';

class ClientStoreDetailScreen extends StatelessWidget {
  const ClientStoreDetailScreen({super.key, required this.store});

  final ClientStoreDebt store;

  // TODO: reemplazar por datos reales desde ClientDebtsRepository
  static const _transactions = [
    ClientTransaction(
        label: 'Compra del día',
        dateLabel: 'Hoy, 10:30 AM · 3 productos',
        amount: 15.50,
        status: TransactionStatus.pendiente),
    ClientTransaction(
        label: 'Saldo anterior',
        dateLabel: 'Ayer, 08:15 PM · 1 producto',
        amount: 29.50,
        status: TransactionStatus.pendiente),
    ClientTransaction(
        label: 'Pago realizado',
        dateLabel: '15 Oct · Efectivo',
        amount: -50.00,
        status: TransactionStatus.pagado),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.arrow_back, color: AppColors.ink),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 8),
                  Text(store.storeName,
                      style: Theme.of(context).textTheme.headlineSmall),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 22),
                        decoration: BoxDecoration(
                          color: AppColors.surface,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: AppColors.mist),
                        ),
                        child: Column(
                          children: [
                            const Text('Tu deuda actual aquí',
                                style:
                                    TextStyle(fontSize: 13, color: AppColors.inkMuted)),
                            const SizedBox(height: 6),
                            Text('S/ ${store.amountOwed.toStringAsFixed(2)}',
                                style: const TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.w800,
                                    color: AppColors.gold)),
                            const SizedBox(height: 4),
                            const Text('ACTUALIZADA HACE 15 MIN',
                                style: TextStyle(
                                    fontSize: 10,
                                    letterSpacing: 0.4,
                                    color: AppColors.inkMuted)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text('Tus últimas compras',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              color: AppColors.ink)),
                      const SizedBox(height: 10),
                      for (final tx in _transactions) _TransactionTile(tx: tx),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () {
                  // TODO: notificar al tendero (WhatsApp / notificación in-app)
                },
                icon: const Icon(Icons.chat_bubble_outline, size: 18),
                label: const Text('Avisar que voy a pagar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TransactionTile extends StatelessWidget {
  const _TransactionTile({required this.tx});

  final ClientTransaction tx;

  bool get _isPaid => tx.status == TransactionStatus.pagado;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tx.label,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.ink)),
                Text(tx.dateLabel,
                    style: const TextStyle(fontSize: 11, color: AppColors.inkMuted)),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${tx.amount < 0 ? '-' : ''}S/ ${tx.amount.abs().toStringAsFixed(2)}',
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: _isPaid ? AppColors.teal : AppColors.ink),
              ),
              const SizedBox(height: 2),
              Text(
                _isPaid ? 'PAGADO' : 'PENDIENTE',
                style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: _isPaid ? AppColors.teal : AppColors.gold),
              ),
            ],
          ),
        ],
      ),
    );
  }
}