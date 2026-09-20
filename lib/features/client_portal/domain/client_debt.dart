enum TransactionStatus { pendiente, pagado }

class ClientStoreDebt {
  const ClientStoreDebt({
    required this.id,
    required this.storeName,
    required this.city,
    required this.amountOwed,
  });

  final String id;
  final String storeName;
  final String city;
  final double amountOwed;
}

class ClientTransaction {
  const ClientTransaction({
    required this.label,
    required this.dateLabel,
    required this.amount,
    required this.status,
  });

  final String label;
  final String dateLabel;

  /// Positivo = compra/fiado; negativo = pago realizado.
  final double amount;
  final TransactionStatus status;
}