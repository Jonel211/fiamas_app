enum DebtStatus { pendiente, pagado }

class Debt {
  const Debt({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.amount,
    required this.status,
    required this.dateLabel,
    this.items = const [],
  });

  final String id;
  final String customerName;
  final String phone;
  final double amount;
  final DebtStatus status;

  /// Fecha ya formateada para mostrar (ej: "Hoy, 10:30 AM").
  final String dateLabel;
  final List<DebtItem> items;

  String get initials {
    final parts = customerName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1)).toUpperCase();
  }
}

class DebtItem {
  const DebtItem({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
  });

  final String productName;
  final int quantity;
  final double unitPrice;

  double get subtotal => quantity * unitPrice;
}