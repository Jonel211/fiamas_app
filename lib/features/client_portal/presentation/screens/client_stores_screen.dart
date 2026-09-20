import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../domain/client_debt.dart';
import 'client_login_screen.dart';
import 'client_store_detail_screen.dart';

class ClientStoresScreen extends StatelessWidget {
  const ClientStoresScreen({super.key, this.customerFirstName = 'Ricardo'});

  final String customerFirstName;

  // TODO: reemplazar por datos reales desde ClientDebtsRepository
  static const _storeDebts = [
    ClientStoreDebt(
        id: '1', storeName: 'Bodega "El Sol"', city: 'Sullana', amountOwed: 45.00),
    ClientStoreDebt(
        id: '2', storeName: 'Minimarket Don Pepe', city: 'Sullana', amountOwed: 12.50),
  ];

  double get _total =>
      _storeDebts.fold(0.0, (sum, d) => sum + d.amountOwed);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Hola, $customerFirstName',
                            style: Theme.of(context).textTheme.headlineSmall),
                        const SizedBox(height: 2),
                        Text('Estas son tus deudas actuales',
                            style: Theme.of(context).textTheme.bodyMedium),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pushReplacement(
                      MaterialPageRoute(builder: (_) => const ClientLoginScreen()),
                    ),
                    icon: const Icon(Icons.logout, color: AppColors.ink, size: 18),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.mist,
                      padding: const EdgeInsets.all(8),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView(
                  children: [
                    for (final store in _storeDebts)
                      _StoreDebtCard(
                        store: store,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => ClientStoreDetailScreen(store: store)),
                        ),
                      ),
                  ],
                ),
              ),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.mist),
                ),
                child: Column(
                  children: [
                    const Text('Total por pagar en todas las tiendas',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 12, color: AppColors.inkMuted)),
                    const SizedBox(height: 4),
                    Text('S/ ${_total.toStringAsFixed(2)}',
                        style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.ink)),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.ink,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Recuerda pagar a tiempo para mantener tu buen crédito con los tenderos.',
                        style: TextStyle(
                            fontSize: 11.5, color: Colors.white.withValues(alpha: 0.9)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StoreDebtCard extends StatelessWidget {
  const _StoreDebtCard({required this.store, this.onTap});

  final ClientStoreDebt store;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.mist),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: AppColors.mist,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.storefront_outlined,
                  color: AppColors.ink, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(store.storeName,
                      style: const TextStyle(
                          fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.ink)),
                  Text(store.city.toUpperCase(),
                      style: const TextStyle(
                          fontSize: 10, letterSpacing: 0.3, color: AppColors.inkMuted)),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                const Text('DEBES',
                    style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.4,
                        color: AppColors.inkMuted)),
                Text('S/ ${store.amountOwed.toStringAsFixed(2)}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.gold)),
              ],
            ),
          ],
        ),
      ),
    );
  }
}