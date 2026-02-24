import 'package:flutter/material.dart';
import '../models/order.dart';
import 'order_card.dart';

class DashboardColumn extends StatelessWidget {
  final String title;
  final List<Order> orders;
  final Color color;
  final IconData icon;
  final Function(Order) onOrderTap;
  final Function(Order)? onMoveToNextStatus;

  const DashboardColumn({
    super.key,
    required this.title,
    required this.orders,
    required this.color,
    required this.icon,
    required this.onOrderTap,
    this.onMoveToNextStatus,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 300,
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          // Column Header
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${orders.length}',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Orders List
          Expanded(
            child: orders.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(icon, size: 48, color: Colors.grey[300]),
                        const SizedBox(height: 8),
                        Text(
                          'Sem pedidos',
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(12),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      final canMoveToNext = _canMoveToNextStatus(order.status);
                      return OrderCard(
                        order: order,
                        onTap: () => onOrderTap(order),
                        label: Text(
                          _getNextStatusLabel(order.status),
                        ),
                        icon: _getIconForStatus(order.status),
                        onPressed: canMoveToNext && onMoveToNextStatus != null
                            ? () => onMoveToNextStatus!(order)
                            : null,
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  bool _canMoveToNextStatus(OrderStatus status) {
    return status == OrderStatus.received ||
        status == OrderStatus.confirmed ||
        status == OrderStatus.dispatched;
  }

  String _getNextStatusLabel(OrderStatus status) {
    switch (status) {
      case OrderStatus.received:
        return 'Confirmar';
      case OrderStatus.confirmed:
        return 'Em Rota';
      case OrderStatus.dispatched:
        return 'Entregar';
      default:
        return '';
    }
  }

  IconData _getIconForStatus(OrderStatus status) {
    switch (status) {
      case OrderStatus.received:
        return Icons.check_circle;
      case OrderStatus.confirmed:
        return Icons.local_shipping;
      case OrderStatus.dispatched:
        return Icons.done_all;
      default:
        return Icons.help_outline;
    }
  }
}
