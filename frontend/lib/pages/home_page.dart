import 'package:flutter/material.dart';
import 'package:frontend/widgets/order_dialog.dart';
import 'package:frontend/widgets/stat_card.dart';
import '../models/order.dart';
import '../widgets/dashboard_column.dart';
import '../services/orders_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final OrdersService _ordersService = OrdersService();
  List<Order> orders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrders();
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
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.black87),
            onPressed: _loadOrders,
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Erro ao carregar pedidos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _loadOrders,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Tentar Novamente'),
                  ),
                ],
              ),
            )
          : Column(
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
                        title: 'DESPACHADO',
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

  Future<void> _loadOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final fetchedOrders = await _ordersService.fetchOrders();
      setState(() {
        orders = fetchedOrders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  List<Order> _getOrdersByStatus(OrderStatus status) {
    return orders.where((order) => order.status == status).toList();
  }

  void _showOrderDialog(Order order) {
    showDialog(
      context: context,
      builder: (context) => OrderDialog(
        order: order,
        onUpdateStatus: _updateOrderStatus,
        onCancel: _cancelOrder,
      ),
    );
  }

  Future<void> _updateOrderStatus(Order order) async {
    try {
      await _ordersService.advanceOrderStatus(order.id);
      await _loadOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Status atualizado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _cancelOrder(Order order) async {
    try {
      await _ordersService.cancelOrder(order.id);
      await _loadOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido cancelado com sucesso!'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao cancelar pedido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _moveToNextStatus(Order order) async {
    await _updateOrderStatus(order);
  }
}
