enum OrderStatus {
  received,
  confirmed,
  dispatched,
  delivered,
  canceled,
}

class Order {
  final String id;
  final String customerName;
  final String details;
  final DateTime timestamp;
  OrderStatus status;
  final double total;

  Order({
    required this.id,
    required this.customerName,
    required this.details,
    required this.timestamp,
    required this.status,
    required this.total,
  });

  String get statusLabel {
    switch (status) {
      case OrderStatus.received:
        return 'RECEIVED';
      case OrderStatus.confirmed:
        return 'CONFIRMED';
      case OrderStatus.dispatched:
        return 'DISPATCHED';
      case OrderStatus.delivered:
        return 'DELIVERED';
      case OrderStatus.canceled:
        return 'CANCELED';
    }
  }
}
