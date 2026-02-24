import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/order.dart';

class OrdersService {
  static const String baseUrl = 'http://localhost:3000';

  // Fetch all orders
  Future<List<Order>> fetchOrders() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Order.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load orders: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching orders: $e');
    }
  }

  // Fetch a single order by ID
  Future<Order> fetchOrder(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/orders/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        return Order.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to load order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching order: $e');
    }
  }

  // Create a new order
  Future<Order> createOrder({
    required String storeId,
    required Map<String, dynamic> details,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/orders'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'store_id': storeId,
          'details': details,
        }),
      );

      if (response.statusCode == 201) {
        return Order.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to create order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error creating order: $e');
    }
  }

  // Delete an order
  Future<void> deleteOrder(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/orders/$id'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode != 204) {
        throw Exception('Failed to delete order: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error deleting order: $e');
    }
  }

  // Update order status (transition to next status)
  Future<Order> updateOrderStatus(String id, {bool cancel = false}) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/orders/$id/status'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'cancel': cancel,
        }),
      );

      if (response.statusCode == 200) {
        return Order.fromJson(json.decode(response.body));
      } else {
        throw Exception('Failed to update order status: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error updating order status: $e');
    }
  }

  // Advance order to next status
  Future<Order> advanceOrderStatus(String id) async {
    return updateOrderStatus(id, cancel: false);
  }

  // Cancel order
  Future<Order> cancelOrder(String id) async {
    return updateOrderStatus(id, cancel: true);
  }
}
