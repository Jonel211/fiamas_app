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
    this.isCancelled = false,
  });

  final String id;
  final String customerName;
  final String phone;
  final double amount; // Monto total original
  final double paidAmount; // ✅ NUEVO: Monto pagado hasta ahora
  final DebtStatus status;

  /// Indica si el fiado fue cancelado (no se cuenta en los totales).
  final bool isCancelled;

  /// Fecha ya formateada para mostrar (ej: "Hoy, 10:30 AM").
  final String dateLabel;
  final List<DebtItem> items;

  // ✅ NUEVO: Calcula el saldo pendiente automáticamente
  double get remainingAmount => amount - paidAmount;

  /// Regla central para saber si un estado de fiado sigue activo.
  /// Vencido es pendiente con fecha vencida, así que también cuenta.
  static bool isActiveStatus(String estado) {
    final value = estado.trim().toLowerCase();
    return value != 'pagado' && value != 'cancelado';
  }

  /// Un fiado está activo mientras no esté pagado ni cancelado.
  bool get isActive => !isCancelled && isActiveStatus(status.name);

  /// Regla única de selección para cobros: un fiado pagado o cancelado
  /// no puede seleccionarse. Pendiente, parcial y vencido sí.
  bool get isSelectable => isActive;

  String get initials {
    final parts = customerName.trim().split(RegExp(r'\s+'));
    if (parts.length == 1) return parts.first.substring(0, 1).toUpperCase();
    return (parts.first.substring(0, 1) + parts.last.substring(0, 1))
        .toUpperCase();
  }
}

class DebtItem {
  const DebtItem({
    required this.productName,
    required this.quantity,
    required this.unitPrice,
    this.unit,
  });

  final String productName;
  final double quantity;
  final double unitPrice;
  final String? unit;

  double get subtotal => quantity * unitPrice;
}
