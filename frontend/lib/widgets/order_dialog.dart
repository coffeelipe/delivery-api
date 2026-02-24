import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:frontend/models/order.dart';

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
    return AlertDialog(
      title: Row(
        children: [
          Text('Pedido #${order.id.substring(0, 6)}...'),
          IconButton(
            onPressed: () {
              Clipboard.setData(ClipboardData(text: order.id));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('ID copiado para a área de transferência!'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            icon: const Icon(Icons.copy_rounded),
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
}
