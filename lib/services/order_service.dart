import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/order.dart';
import 'api_exception.dart';

class OrderService {
  Map<String, String> _headers(String token) => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };

  Future<DeliveryOrder> createOrder({
    required DeliveryAddress pickupAddress,
    required DeliveryAddress deliveryAddress,
    required String branchId,
    required String branchName,
    required List<Map<String, dynamic>> items,
    required double orderTotal,
    required String token,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse(ApiConfig.createOrder),
            headers: _headers(token),
            body: jsonEncode({
              'pickupAddress': pickupAddress.toJson(),
              'deliveryAddress': deliveryAddress.toJson(),
              'branchId': branchId,
              'branchName': branchName,
              'items': items,
              'orderTotal': orderTotal,
            }),
          )
          .timeout(ApiConfig.requestTimeout);

      if (response.statusCode != 201) {
        _throwFromBody(response);
      }
      return DeliveryOrder.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
    } on SocketException {
      throw ApiException('Could not reach the server. Check your connection.');
    }
  }

  Future<List<DeliveryOrder>> getCustomerOrders({
    required String customerId,
    required String token,
  }) async {
    final response = await _get(Uri.parse(ApiConfig.customerOrders(customerId)), token);
    final list = jsonDecode(response.body) as List<dynamic>;
    return list
        .map((e) => DeliveryOrder.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<DeliveryOrder> getOrderById({
    required String orderId,
    required String token,
  }) async {
    final response = await _get(Uri.parse(ApiConfig.orderById(orderId)), token);
    return DeliveryOrder.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }

  // --- shared HTTP helpers -------------------------------------------------

  Future<http.Response> _get(Uri uri, String token) async {
    try {
      final response = await http
          .get(uri, headers: _headers(token))
          .timeout(ApiConfig.requestTimeout);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        _throwFromBody(response);
      }
      return response;
    } on SocketException {
      throw ApiException('Could not reach the server. Check your connection.');
    }
  }

  Never _throwFromBody(http.Response response) {
    String message = 'Something went wrong (${response.statusCode})';
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      message = body['message'] as String? ?? message;
    } catch (_) {
      // response wasn't JSON; keep default message
    }

    if (response.statusCode == 401) {
      throw ApiException('Session expired. Please log in again.', statusCode: 401);
    }
    throw ApiException(message, statusCode: response.statusCode);
  }
}
