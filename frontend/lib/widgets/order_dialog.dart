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

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
          ),
          Expanded(
            child: Text(value, style: const TextStyle(color: Colors.black54)),
          ),
        ],
      ),
    );
  }

  Widget _buildItemCard(dynamic item) {
    final name = item['name'] ?? 'Item';
    final quantity = item['quantity'] ?? 1;
    final price = item['price'] ?? 0.0;
    final totalPrice = item['total_price'] ?? (price * quantity);
    final observations = item['observations'];
    final discount = item['discount'] ?? 0;

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$quantity x $name',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                ),
                Text(
                  'R\$ ${totalPrice.toStringAsFixed(2)}',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
            if (discount > 0)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Desconto: R\$ ${discount.toStringAsFixed(2)}',
                  style: const TextStyle(fontSize: 12, color: Colors.orange),
                ),
              ),
            if (observations != null && observations.toString().isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Obs: $observations',
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentInfo(dynamic payment) {
    final value = payment['value'] ?? 0.0;
    final origin = payment['origin'] ?? 'N/A';
    final prepaid = payment['prepaid'] ?? false;

    return Card(
      color: Colors.green.shade50,
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(
              prepaid ? Icons.check_circle : Icons.access_time,
              color: prepaid ? Colors.green : Colors.orange,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatPaymentMethod(origin),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    prepaid ? 'Pago' : 'Pendente',
                    style: TextStyle(
                      fontSize: 12,
                      color: prepaid ? Colors.green : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              'R\$ ${value.toStringAsFixed(2)}',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressInfo(Map<String, dynamic> address) {
    final street = address['street_name'];
    final number = address['street_number'];
    final neighborhood = address['neighborhood'];
    final city = address['city'];
    final state = address['state'];
    final postalCode = address['postal_code'];
    final reference = address['reference'];

    final addressParts = <String>[];
    if (street != null) addressParts.add(street);
    if (number != null) addressParts.add(number.toString());
    if (neighborhood != null) addressParts.add(neighborhood);
    if (city != null && state != null) addressParts.add('$city - $state');
    if (postalCode != null) addressParts.add('CEP: $postalCode');

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (addressParts.isNotEmpty)
              Text(
                addressParts.join(', '),
                style: const TextStyle(fontSize: 13),
              ),
            if (reference != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  'Referência: $reference',
                  style: const TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.black54,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHistory(dynamic status) {
    final name = status['name'] ?? 'N/A';
    final createdAt = status['created_at'] as int?;
    final origin = status['origin'] ?? 'N/A';

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 8),
      child: Row(
        children: [
          const Icon(Icons.circle, size: 8, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatStatusName(name),
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
                Text(
                  createdAt != null
                      ? _formatDate(
                          DateTime.fromMillisecondsSinceEpoch(createdAt),
                        )
                      : 'Data não disponível',
                  style: const TextStyle(fontSize: 11, color: Colors.black54),
                ),
              ],
            ),
          ),
          Text(
            origin,
            style: const TextStyle(fontSize: 11, color: Colors.black45),
          ),
        ],
      ),
    );
  }

  String _formatPaymentMethod(String method) {
    switch (method.toUpperCase()) {
      case 'CREDIT_CARD':
        return 'Cartão de Crédito';
      case 'DEBIT_CARD':
        return 'Cartão de Débito';
      case 'PIX':
        return 'PIX';
      case 'CASH':
        return 'Dinheiro';
      default:
        return method;
    }
  }

  String _formatStatusName(String status) {
    switch (status.toUpperCase()) {
      case 'RECEIVED':
        return 'Recebido';
      case 'CONFIRMED':
        return 'Confirmado';
      case 'DISPATCHED':
        return 'Despachado';
      case 'DELIVERED':
        return 'Entregue';
      case 'CANCELED':
        return 'Cancelado';
      default:
        return status;
    }
  }
}
