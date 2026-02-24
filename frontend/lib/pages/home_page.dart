import 'package:flutter/material.dart';
import 'package:frontend/widgets/stat_card.dart';
import '../models/order.dart';
import '../widgets/dashboard_column.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Order> orders = [];

  @override
  void initState() {
    super.initState();
    _initializeSampleData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        title: const Text(
          'CBLab Delivery',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Column(
        children: [
          // Stats Summary
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: StatCard(
                    label: 'Total de Pedidos',
                    value: orders.length.toString(),
                    icon: Icons.receipt_long,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Ativos',
                    value: orders
                        .where(
                          (o) =>
                              o.status != OrderStatus.delivered &&
                              o.status != OrderStatus.canceled,
                        )
                        .length
                        .toString(),
                    icon: Icons.pending_actions,
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: StatCard(
                    label: 'Entregues',
                    value: orders
                        .where((o) => o.status == OrderStatus.delivered)
                        .length
                        .toString(),
                    icon: Icons.check_circle,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // Dashboard
          Expanded(
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
              children: [
                DashboardColumn(
                  title: 'RECEBIDO',
                  orders: _getOrdersByStatus(OrderStatus.received),
                  color: Colors.orange,
                  icon: Icons.inbox,
                  onOrderTap: _showOrderDialog,
                  onMoveToNextStatus: _moveToNextStatus,
                ),
                DashboardColumn(
                  title: 'CONFIRMADO',
                  orders: _getOrdersByStatus(OrderStatus.confirmed),
                  color: Colors.blue,
                  icon: Icons.check_circle_outline,
                  onOrderTap: _showOrderDialog,
                  onMoveToNextStatus: _moveToNextStatus,
                ),
                DashboardColumn(
                  title: 'EM ROTA',
                  orders: _getOrdersByStatus(OrderStatus.dispatched),
                  color: Colors.purple,
                  icon: Icons.local_shipping_outlined,
                  onOrderTap: _showOrderDialog,
                  onMoveToNextStatus: _moveToNextStatus,
                ),
                DashboardColumn(
                  title: 'ENTREGUE',
                  orders: _getOrdersByStatus(OrderStatus.delivered),
                  color: Colors.green,
                  icon: Icons.done_all,
                  onOrderTap: _showOrderDialog,
                ),
                DashboardColumn(
                  title: 'CANCELADO',
                  orders: _getOrdersByStatus(OrderStatus.canceled),
                  color: Colors.red,
                  icon: Icons.cancel_outlined,
                  onOrderTap: _showOrderDialog,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _initializeSampleData() {
    orders = [
      Order(
        id: '001',
        customerName: 'John Smith',
        details: '2x Burger, 1x Fries, 1x Coke',
        timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
        status: OrderStatus.received,
        total: 24.99,
      ),
      Order(
        id: '002',
        customerName: 'Sarah Johnson',
        details: '1x Pizza Margherita, 1x Salad',
        timestamp: DateTime.now().subtract(const Duration(minutes: 12)),
        status: OrderStatus.received,
        total: 32.50,
      ),
      Order(
        id: '003',
        customerName: 'Mike Davis',
        details: '3x Tacos, 1x Burrito, 2x Nachos',
        timestamp: DateTime.now().subtract(const Duration(minutes: 18)),
        status: OrderStatus.confirmed,
        total: 45.75,
      ),
      Order(
        id: '004',
        customerName: 'Emily Brown',
        details: '1x Caesar Salad, 1x Soup',
        timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
        status: OrderStatus.confirmed,
        total: 18.99,
      ),
      Order(
        id: '005',
        customerName: 'David Wilson',
        details: '2x Pasta Carbonara, 1x Tiramisu',
        timestamp: DateTime.now().subtract(const Duration(minutes: 32)),
        status: OrderStatus.dispatched,
        total: 56.00,
      ),
      Order(
        id: '006',
        customerName: 'Lisa Anderson',
        details: '1x Sushi Combo, 1x Miso Soup',
        timestamp: DateTime.now().subtract(const Duration(minutes: 45)),
        status: OrderStatus.delivered,
        total: 38.50,
      ),
      Order(
        id: '007',
        customerName: 'Tom Martinez',
        details: '1x Steak, 1x Mashed Potatoes',
        timestamp: DateTime.now().subtract(const Duration(hours: 1)),
        status: OrderStatus.delivered,
        total: 62.99,
      ),
    ];
  }

  List<Order> _getOrdersByStatus(OrderStatus status) {
    return orders.where((order) => order.status == status).toList();
  }

  void _showOrderDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Pedido #${order.id}'),
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
            const SizedBox(height: 16),
            if (order.status != OrderStatus.delivered &&
                order.status != OrderStatus.canceled)
              const Text(
                'Mover para:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
          ],
        ),
        actions: [
          if (order.status == OrderStatus.received)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  order.status = OrderStatus.confirmed;
                });
                Navigator.pop(context);
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Confirmar'),
              style: TextButton.styleFrom(foregroundColor: Colors.blue),
            ),
          if (order.status == OrderStatus.confirmed)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  order.status = OrderStatus.dispatched;
                });
                Navigator.pop(context);
              },
              icon: const Icon(Icons.local_shipping),
              label: const Text('Em Rota'),
              style: TextButton.styleFrom(foregroundColor: Colors.purple),
            ),
          if (order.status == OrderStatus.dispatched)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  order.status = OrderStatus.delivered;
                });
                Navigator.pop(context);
              },
              icon: const Icon(Icons.done_all),
              label: const Text('Entregar'),
              style: TextButton.styleFrom(foregroundColor: Colors.green),
            ),
          if (order.status != OrderStatus.delivered &&
              order.status != OrderStatus.canceled)
            TextButton.icon(
              onPressed: () {
                setState(() {
                  order.status = OrderStatus.canceled;
                });
                Navigator.pop(context);
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
      ),
    );
  }

  void _moveToNextStatus(Order order) {
    setState(() {
      switch (order.status) {
        case OrderStatus.received:
          order.status = OrderStatus.confirmed;
          break;
        case OrderStatus.confirmed:
          order.status = OrderStatus.dispatched;
          break;
        case OrderStatus.dispatched:
          order.status = OrderStatus.delivered;
          break;
        default:
          break;
      }
    });
  }
}
