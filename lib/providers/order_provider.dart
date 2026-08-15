import 'package:flutter/foundation.dart';
import '../models/order.dart';
import '../services/order_service.dart';
import '../services/api_exception.dart';

/// Holds the customer's order list and handles creating new orders.
///
/// Real-time hook point: when Socket.IO is added, listen for an
/// `order:statusUpdated` event elsewhere in the app and call
/// [applyServerUpdate] with the incoming order — the UI refreshes
/// automatically since this is a ChangeNotifier. No screen code needs
/// to change.
class OrderProvider extends ChangeNotifier {
  final OrderService _orderService = OrderService();

  List<DeliveryOrder> orders = [];
  bool isLoading = false;
  bool isCreating = false;
  String? errorMessage;

  Future<void> fetchCustomerOrders({
    required String customerId,
    required String token,
  }) async {
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      orders = await _orderService.getCustomerOrders(customerId: customerId, token: token);
      // Most recent first.
      orders.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });
    } on ApiException catch (e) {
      errorMessage = e.message;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  /// Creates a new order and inserts it at the top of the local list.
  /// Returns an error message on failure, or null on success.
  Future<String?> createOrder({
    required DeliveryAddress pickupAddress,
    required DeliveryAddress deliveryAddress,
    required String branchId,
    required String branchName,
    required List<Map<String, dynamic>> items,
    required double orderTotal,
    required String token,
  }) async {
    isCreating = true;
    notifyListeners();

    try {
      final order = await _orderService.createOrder(
        pickupAddress: pickupAddress,
        deliveryAddress: deliveryAddress,
        branchId: branchId,
        branchName: branchName,
        items: items,
        orderTotal: orderTotal,
        token: token,
      );
      orders.insert(0, order);
      return null;
    } on ApiException catch (e) {
      return e.message;
    } finally {
      isCreating = false;
      notifyListeners();
    }
  }

  /// Replaces an order in the local list with a fresher copy from the
  /// server (used by the tracking screen's refresh now, and by a socket
  /// listener later).
  void applyServerUpdate(DeliveryOrder updated) {
    final index = orders.indexWhere((o) => o.id == updated.id);
    if (index == -1) {
      orders.insert(0, updated);
    } else {
      orders[index] = updated;
    }
    notifyListeners();
  }

  void clear() {
    orders = [];
    errorMessage = null;
    notifyListeners();
  }
}
