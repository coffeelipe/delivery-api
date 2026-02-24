enum OrderStatus { received, confirmed, dispatched, delivered, canceled }

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
        return 'RECEBIDO';
      case OrderStatus.confirmed:
        return 'CONFIRMADO';
      case OrderStatus.dispatched:
        return 'DESPACHADO';
      case OrderStatus.delivered:
        return 'ENTREGUE';
      case OrderStatus.canceled:
        return 'CANCELADO';
    }
  }

  // Parse status from string
  static OrderStatus _parseStatus(String statusName) {
    switch (statusName.toUpperCase()) {
      case 'RECEIVED':
        return OrderStatus.received;
      case 'CONFIRMED':
        return OrderStatus.confirmed;
      case 'DISPATCHED':
        return OrderStatus.dispatched;
      case 'DELIVERED':
        return OrderStatus.delivered;
      case 'CANCELED':
        return OrderStatus.canceled;
      default:
        return OrderStatus.received;
    }
  }

  // Create Order from JSON
  factory Order.fromJson(Map<String, dynamic> json) {
    final details = json['details'] as Map<String, dynamic>? ?? {};
    final customer = details['customer'] as Map<String, dynamic>? ?? {};
    final lastStatusName = details['last_status_name'] as String? ?? 'RECEIVED';
    final totalPrice = details['total_price'] as num? ?? 0.0;
    final createdAt = details['created_at'] as int?;

    // Combine items into a details string
    final items = details['items'] as List<dynamic>? ?? [];
    final itemsString = items
        .map((item) {
          final name = item['name'] ?? '';
          final quantity = item['quantity'] ?? 1;
          return '$quantity x $name';
        })
        .join(', ');

    return Order(
      id: json['id'] as String,
      customerName: customer['name'] as String? ?? 'Unknown',
      details: itemsString,
      timestamp: createdAt != null
          ? DateTime.fromMillisecondsSinceEpoch(createdAt)
          : DateTime.now(),
      status: _parseStatus(lastStatusName),
      total: totalPrice.toDouble(),
    );
  }

  // Convert Order to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'details': {
        'customer': {'name': customerName},
        'last_status_name': statusLabel,
        'total_price': total,
        'created_at': timestamp.millisecondsSinceEpoch,
      },
    };
  }
}
