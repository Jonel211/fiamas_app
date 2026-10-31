enum DebtStatus { pendiente, pagado, parcial }

class Debt {
  const Debt({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.amount,
    required this.paidAmount, // ✅ NUEVO: Monto pagado
    required this.status,
    required this.dateLabel,
    this.items = const [],
  });

  final String id;
  final String customerName;
  final String phone;
  final double amount; // Monto total original
  final double paidAmount; // ✅ NUEVO: Monto pagado hasta ahora
  final DebtStatus status;

  /// Fecha ya formateada para mostrar (ej: "Hoy, 10:30 AM").
  final String dateLabel;
  final List<DebtItem> items;

  // ✅ NUEVO: Calcula el saldo pendiente automáticamente
  double get remainingAmount => amount - paidAmount;

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
  final double quantity; // ✅ CAMBIADO A DOUBLE
  final double unitPrice;

  double get subtotal => quantity * unitPrice;
}