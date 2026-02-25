import 'package:frontend/core/utils/utils.dart';

import 'orders_service.dart';

void main() async {
  final service = OrdersService();

  Utils.dPrint('Testing OrdersService...\n');

  try {
    // Test 1: Fetch all orders
    Utils.dPrint('Test 1: Fetching all orders...');
    final orders = await service.fetchOrders();
    Utils.dPrint('Success! Fetched ${orders.length} orders');

    if (orders.isNotEmpty) {
      Utils.dPrint('\nSample order:');
      final firstOrder = orders.first;
      Utils.dPrint('  ID: ${firstOrder.id}');
      Utils.dPrint('  Customer: ${firstOrder.customerName}');
      Utils.dPrint('  Details: ${firstOrder.details}');
      Utils.dPrint('  Status: ${firstOrder.statusLabel}');
      Utils.dPrint('  Total: \$${firstOrder.total.toStringAsFixed(2)}');
      Utils.dPrint('  Timestamp: ${firstOrder.timestamp}');

      // Test 2: Fetch single order
      Utils.dPrint('\nTest 2: Fetching single order (${firstOrder.id})...');
      final singleOrder = await service.fetchOrder(firstOrder.id);
      Utils.dPrint('Success! Fetched order: ${singleOrder.customerName}');

      // Test 3: Update order status (advance)
      Utils.dPrint('\nTest 3: Advancing order status...');
      Utils.dPrint('  Current status: ${singleOrder.statusLabel}');
      try {
        final updatedOrder = await service.advanceOrderStatus(singleOrder.id);
        Utils.dPrint('Success! New status: ${updatedOrder.statusLabel}');
      } catch (e) {
        Utils.dPrint('Could not advance (may be at terminal state): $e');
      }
    }

    // Test 4: Create a new order
    Utils.dPrint('\nTest 4: Creating a new order...');
    try {
      final newOrder = await service.createOrder(
        storeId: 'f052054c-e0a0-4768-ab55-7cb7ead57371',
        details: {
          'items': [
            {'name': 'Test Item', 'quantity': 1, 'price': 19.99},
          ],
        },
      );
      Utils.dPrint('Success! Created order: ${newOrder.id}');
      Utils.dPrint('  Customer: ${newOrder.customerName}');
      Utils.dPrint('  Status: ${newOrder.statusLabel}');

      // Test 5: Delete the test order
      Utils.dPrint('\nTest 5: Deleting test order...');
      await service.deleteOrder(newOrder.id);
      Utils.dPrint('Success! Order deleted');
    } catch (e) {
      Utils.dPrint('Failed to create/delete order: $e');
    }

    Utils.dPrint('\nAll tests completed!');
  } catch (e) {
    Utils.dPrint('Error: $e');
    Utils.dPrint(
      '\nMake sure your backend server is running on http://localhost:3000',
    );
  }
}
