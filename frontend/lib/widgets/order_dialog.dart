import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/order.dart';
import 'package:intl/intl.dart';

class OrderDialog extends StatelessWidget {
  final Order order;
  final Future<void> Function(Order) onUpdateStatus;
  final Future<void> Function(Order) onCancel;
  const OrderDialog({
    super.key,
    required this.order,
    required this.onUpdateStatus,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final customer = order.rawDetails['customer'] as Map<String, dynamic>?;
    final items = order.rawDetails['items'] as List<dynamic>? ?? [];
    final payments = order.rawDetails['payments'] as List<dynamic>? ?? [];
    final store = order.rawDetails['store'] as Map<String, dynamic>?;
    final deliveryAddress =
        order.rawDetails['delivery_address'] as Map<String, dynamic>?;
    final statuses = order.rawDetails['statuses'] as List<dynamic>? ?? [];

    return AlertDialog(
      title: Row(
        children: [
          Expanded(
            child: Text(
              'Pedido #${order.id.substring(0, 8)}...',
              style: const TextStyle(fontSize: 18),
            ),
          ),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: order.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ID copiado para a área de transferência!'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded, size: 20),
            tooltip: 'Copiar ID completo',
          ),
        ],
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cliente: ${order.customerName}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text('Detalhes: ${order.details}'),
          const SizedBox(height: 8),
          Text('Total: \$${order.total.toStringAsFixed(2)}'),
          const SizedBox(height: 8),
          Text('Status: ${order.statusLabel}'),
        ],
      ),
      actions: [
        if (order.status == OrderStatus.received)
          TextButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await onUpdateStatus(order);
            },
            icon: const Icon(Icons.check_circle),
            label: const Text('Confirmar'),
            style: TextButton.styleFrom(foregroundColor: Colors.blue),
          ),
        if (order.status == OrderStatus.confirmed)
          TextButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await onUpdateStatus(order);
            },
            icon: const Icon(Icons.local_shipping),
            label: const Text('Despachar'),
            style: TextButton.styleFrom(foregroundColor: Colors.purple),
          ),
        if (order.status == OrderStatus.dispatched)
          TextButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await onUpdateStatus(order);
            },
            icon: const Icon(Icons.done_all),
            label: const Text('Entregar'),
            style: TextButton.styleFrom(foregroundColor: Colors.green),
          ),
        if (order.status != OrderStatus.delivered &&
            order.status != OrderStatus.canceled)
          TextButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              await onCancel(order);
            },
            icon: const Icon(Icons.cancel),
            label: const Text('Cancelar'),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
          ),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Fechar'),
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 16,
          color: Colors.blue,
        ),
      ),
    );
  }
}
