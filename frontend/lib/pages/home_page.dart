import 'package:flutter/material.dart';
import 'package:frontend/widgets/new_order_dialog.dart';
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
  bool _debugMode = false;

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
            icon: Icon(
              Icons.bug_report,
              color: _debugMode ? Colors.red : Colors.black87,
            ),
            onPressed: () {
              setState(() {
                _debugMode = !_debugMode;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    _debugMode ? 'Modo Debug Ativado' : 'Modo Debug Desativado',
                  ),
                  backgroundColor: _debugMode ? Colors.orange : Colors.grey,
                  duration: const Duration(seconds: 1),
                ),
              );
            },
            tooltip: 'Modo Debug',
          ),
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
                // Debug Mode Banner
                if (_debugMode)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    color: Colors.orange.shade100,
                    child: Row(
                      children: [
                        Icon(Icons.bug_report, color: Colors.orange.shade700, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            '🔧 Modo Debug Ativo: Clique em qualquer pedido para ver a opção "Excluir do DB"',
                            style: TextStyle(
                              color: Colors.orange.shade900,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          icon: Icon(Icons.close, size: 18, color: Colors.orange.shade700),
                          onPressed: () {
                            setState(() {
                              _debugMode = false;
                            });
                          },
                          tooltip: 'Desativar Modo Debug',
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(),
                        ),
                      ],
                    ),
                  ),
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
                        onCreateOrder: _showNewOrderDialog,
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
        debugMode: _debugMode,
        onDelete: _debugMode ? () => _deleteOrder(order) : null,
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

  Future<void> _deleteOrder(Order order) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmar Exclusão'),
        content: Text(
          'Tem certeza que deseja excluir o pedido #${order.id.substring(0, 8)}?\n\nEsta ação não pode ser desfeita.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await _ordersService.deleteOrder(order.id);
        await _loadOrders();
        if (mounted) {
          Navigator.pop(context); // Close the order dialog
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Pedido excluído com sucesso!'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erro ao excluir pedido: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _showNewOrderDialog() {
    showDialog(
      context: context,
      builder: (context) => NewOrderDialog(
        onCreateOrder: _createOrder,
      ),
    );
  }

  Future<void> _createOrder({
    required String storeId,
    required Map<String, dynamic> details,
  }) async {
    try {
      await _ordersService.createOrder(
        storeId: storeId,
        details: details,
      );
      await _loadOrders();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pedido criado com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao criar pedido: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
      rethrow;
    }
  }
}
