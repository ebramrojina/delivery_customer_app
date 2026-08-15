import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/order.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../services/order_service.dart';
import '../services/api_exception.dart';
import '../l10n/app_strings.dart';
import '../widgets/status_badge.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderId;
  const OrderTrackingScreen({super.key, required this.orderId});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final OrderService _orderService = OrderService();
  DeliveryOrder? _order;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadOrder();
  }

  Future<void> _loadOrder() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final auth = context.read<AuthProvider>();
    try {
      final order = await _orderService.getOrderById(
        orderId: widget.orderId,
        token: auth.token!,
      );
      setState(() => _order = order);
      // Keep the orders list in sync too (real-time listener would call
      // this same method later, from the same OrderProvider).
      if (mounted) context.read<OrderProvider>().applyServerUpdate(order);
    } on ApiException catch (e) {
      setState(() => _errorMessage = e.message);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _callDriver(String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(s.trackOrder),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: s.refresh,
            onPressed: _isLoading ? null : _loadOrder,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadOrder,
        child: _buildBody(s),
      ),
    );
  }

  Widget _buildBody(AppStrings s) {
    if (_isLoading && _order == null) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage != null && _order == null) {
      return LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, color: Colors.red, size: 40),
                    const SizedBox(height: 12),
                    Text(_errorMessage!, textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    ElevatedButton(onPressed: _loadOrder, child: Text(s.retry)),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    }

    final order = _order!;

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                s.orderNumber(order.id.substring(order.id.length - 6)),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              StatusBadge(status: order.status),
            ],
          ),
          const SizedBox(height: 24),
          _ProgressStepper(order: order, s: s),
          const SizedBox(height: 24),
          if (order.driverName != null) _DriverCard(order: order, onCall: _callDriver, s: s),
          if (order.driverName != null) const SizedBox(height: 16),
          _AddressCard(icon: Icons.storefront, title: s.pickup, address: order.pickupAddress),
          const SizedBox(height: 12),
          _AddressCard(icon: Icons.location_on, title: s.delivery, address: order.deliveryAddress),
        ],
      ),
    );
  }
}

class _ProgressStepper extends StatelessWidget {
  final DeliveryOrder order;
  final AppStrings s;
  const _ProgressStepper({required this.order, required this.s});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('MMM d, h:mm a');
    final timestamps = <DateTime?>[
      order.createdAt,
      order.assignedAt,
      order.pickedUpAt,
      order.outForDeliveryAt,
      order.deliveredAt,
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(orderStatusSequence.length, (i) {
        final status = orderStatusSequence[i];
        final isDone = i <= order.progressIndex;
        final isCurrent = i == order.progressIndex;
        final isLast = i == orderStatusSequence.length - 1;
        final timestamp = timestamps[i];

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isDone ? Colors.teal : Colors.grey[300],
                    ),
                    child: isDone
                        ? const Icon(Icons.check, size: 14, color: Colors.white)
                        : null,
                  ),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 2,
                        color: isDone ? Colors.teal : Colors.grey[300],
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s.statusLabel(status),
                        style: TextStyle(
                          fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                          color: isDone ? Colors.black87 : Colors.grey,
                        ),
                      ),
                      if (timestamp != null)
                        Text(
                          dateFormat.format(timestamp.toLocal()),
                          style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

class _DriverCard extends StatelessWidget {
  final DeliveryOrder order;
  final void Function(String phone) onCall;
  final AppStrings s;

  const _DriverCard({required this.order, required this.onCall, required this.s});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.teal.withOpacity(0.06),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            const CircleAvatar(child: Icon(Icons.person)),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(s.yourDriver, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                  Text(
                    order.driverName ?? s.assigned,
                    style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
                  ),
                ],
              ),
            ),
            if (order.driverPhone != null)
              IconButton(
                icon: const Icon(Icons.call, color: Colors.teal),
                tooltip: s.callDriver,
                onPressed: () => onCall(order.driverPhone!),
              ),
          ],
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final DeliveryAddress address;

  const _AddressCard({required this.icon, required this.title, required this.address});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.blueGrey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text(address.label, style: TextStyle(color: Colors.grey[800])),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
