enum DebtStatus { pendiente, pagado, parcial }

class Debt {
  const Debt({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.amount,
    required this.paidAmount,
    required this.status,
    required this.dateLabel,
    this.dueDate,
    this.paidDate,
    this.items = const [],
    this.isCancelled = false,
    
  });

  final String id;
  final String customerName;
  final String phone;
  final double amount;
  final double paidAmount;
  final DebtStatus status;
  final String dateLabel;
  final String? dueDate; 
  final List<DebtItem> items;
  final bool isCancelled;
  final String? paidDate;

  double get remainingAmount => amount - paidAmount;

  static bool isActiveStatus(String estado) {
    final value = estado.trim().toLowerCase();
    return value != 'pagado' && value != 'cancelado';
  }

  bool get isActive => !isCancelled && isActiveStatus(status.name);
  bool get isSelectable => isActive;

  bool get isOverdue {
    if (!isActive || remainingAmount <= 0) return false;
    final raw = dueDate?.trim();
    if (raw != null && raw.isNotEmpty) {
      final ymd = raw.length >= 10 ? raw.substring(0, 10) : raw;
      final parsed = DateTime.tryParse(ymd);
      if (parsed != null) {
        final now = DateTime.now();
        final today = DateTime(now.year, now.month, now.day);
        final dueDay = DateTime(parsed.year, parsed.month, parsed.day);
        return dueDay.isBefore(today);
      }
    }
    return dateLabel.toLowerCase().contains('vencid');
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
