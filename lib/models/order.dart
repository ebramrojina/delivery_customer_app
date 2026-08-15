/// Mirrors the status flow enforced server-side:
/// created -> assigned -> picked_up -> out_for_delivery -> delivered
enum OrderStatus { created, assigned, pickedUp, outForDelivery, delivered, unknown }

const List<OrderStatus> orderStatusSequence = [
  OrderStatus.created,
  OrderStatus.assigned,
  OrderStatus.pickedUp,
  OrderStatus.outForDelivery,
  OrderStatus.delivered,
];

OrderStatus orderStatusFromString(String? value) {
  switch (value) {
    case 'created':
      return OrderStatus.created;
    case 'assigned':
      return OrderStatus.assigned;
    case 'picked_up':
      return OrderStatus.pickedUp;
    case 'out_for_delivery':
      return OrderStatus.outForDelivery;
    case 'delivered':
      return OrderStatus.delivered;
    default:
      return OrderStatus.unknown;
  }
}

String orderStatusLabel(OrderStatus status) {
  switch (status) {
    case OrderStatus.created:
      return 'Order Placed';
    case OrderStatus.assigned:
      return 'Driver Assigned';
    case OrderStatus.pickedUp:
      return 'Picked Up';
    case OrderStatus.outForDelivery:
      return 'Out for Delivery';
    case OrderStatus.delivered:
      return 'Delivered';
    case OrderStatus.unknown:
      return 'Unknown';
  }
}

class DeliveryAddress {
  final String label;
  final double? lat;
  final double? lng;

  DeliveryAddress({required this.label, this.lat, this.lng});

  factory DeliveryAddress.fromJson(Map<String, dynamic> json) {
    return DeliveryAddress(
      label: json['label'] as String? ?? 'No address provided',
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'label': label,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
      };
}

class DeliveryOrder {
  final String id;
  final String customerId;
  final String? driverId;
  final String? driverName;
  final String? driverPhone;
  final OrderStatus status;
  final DeliveryAddress pickupAddress;
  final DeliveryAddress deliveryAddress;
  final DateTime? createdAt;
  final DateTime? assignedAt;
  final DateTime? pickedUpAt;
  final DateTime? outForDeliveryAt;
  final DateTime? deliveredAt;

  DeliveryOrder({
    required this.id,
    required this.customerId,
    this.driverId,
    this.driverName,
    this.driverPhone,
    required this.status,
    required this.pickupAddress,
    required this.deliveryAddress,
    this.createdAt,
    this.assignedAt,
    this.pickedUpAt,
    this.outForDeliveryAt,
    this.deliveredAt,
  });

  factory DeliveryOrder.fromJson(Map<String, dynamic> json) {
    // customerId/driverId may come back populated (as objects) or as raw id strings.
    String? extractId(dynamic field) {
      if (field == null) return null;
      if (field is String) return field;
      if (field is Map<String, dynamic>) return field['_id'] as String?;
      return null;
    }

    String? extractField(dynamic field, String key) {
      if (field is Map<String, dynamic>) return field[key] as String?;
      return null;
    }

    DateTime? parseDate(dynamic value) {
      if (value == null) return null;
      return DateTime.tryParse(value as String);
    }

    return DeliveryOrder(
      id: json['_id'] as String,
      customerId: extractId(json['customerId']) ?? '',
      driverId: extractId(json['driverId']),
      driverName: extractField(json['driverId'], 'name'),
      driverPhone: extractField(json['driverId'], 'phone'),
      status: orderStatusFromString(json['status'] as String?),
      pickupAddress: DeliveryAddress.fromJson(
          json['pickupAddress'] as Map<String, dynamic>? ?? {}),
      deliveryAddress: DeliveryAddress.fromJson(
          json['deliveryAddress'] as Map<String, dynamic>? ?? {}),
      createdAt: parseDate(json['createdAt']),
      assignedAt: parseDate(json['assignedAt']),
      pickedUpAt: parseDate(json['pickedUpAt']),
      outForDeliveryAt: parseDate(json['outForDeliveryAt']),
      deliveredAt: parseDate(json['deliveredAt']),
    );
  }

  /// Index of the current status within [orderStatusSequence] — drives the
  /// tracking screen's progress indicator (0 = just created, 4 = delivered).
  int get progressIndex {
    final index = orderStatusSequence.indexOf(status);
    return index == -1 ? 0 : index;
  }
}
