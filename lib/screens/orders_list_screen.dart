import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/order_provider.dart';
import '../providers/locale_provider.dart';
import '../l10n/app_strings.dart';
import '../widgets/order_card.dart';
import 'branch_selection_screen.dart';
import 'order_tracking_screen.dart';
import 'login_screen.dart';

class OrdersListScreen extends StatefulWidget {
  const OrdersListScreen({super.key});

  @override
  State<OrdersListScreen> createState() => _OrdersListScreenState();
}

class _OrdersListScreenState extends State<OrdersListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadOrders());
  }

  Future<void> _loadOrders() async {
    final auth = context.read<AuthProvider>();
    if (auth.currentUser == null || auth.token == null) return;

    await context.read<OrderProvider>().fetchCustomerOrders(
          customerId: auth.currentUser!.id,
          token: auth.token!,
        );
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    context.read<OrderProvider>().clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  Future<void> _goToCreateOrder() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const BranchSelectionScreen()),
    );
    // Refresh in case the user came back without navigating through
    // the tracking screen (e.g. pressed back after placing an order).
    _loadOrders();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final orderProvider = context.watch<OrderProvider>();
    final s = AppStrings.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.hiName(auth.currentUser?.name.split(' ').first ?? '')),
        actions: [
          TextButton(
            onPressed: () => context.read<LocaleProvider>().toggleLocale(),
            child: Text(s.switchLanguage, style: const TextStyle(color: Colors.white)),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: s.logOut,
            onPressed: _logout,
          ),
        ],
      ),
      floatingActionButton: orderProvider.orders.isEmpty
          ? null // empty state already shows its own big CTA button
          : FloatingActionButton.extended(
              onPressed: _goToCreateOrder,
              icon: const Icon(Icons.add),
              label: Text(s.newOrder),
            ),
      body: RefreshIndicator(
        onRefresh: _loadOrders,
        child: _buildBody(orderProvider, s),
      ),
    );
  }

  Widget _buildBody(OrderProvider orderProvider, AppStrings s) {
    if (orderProvider.isLoading && orderProvider.orders.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (orderProvider.errorMessage != null && orderProvider.orders.isEmpty) {
      return _ErrorState(message: orderProvider.errorMessage!, onRetry: _loadOrders, retryLabel: s.retry);
    }

    if (orderProvider.orders.isEmpty) {
      return _EmptyState(onCreateOrder: _goToCreateOrder, s: s);
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(top: 8, bottom: 88), // room for the FAB
      itemCount: orderProvider.orders.length,
      itemBuilder: (context, index) {
        final order = orderProvider.orders[index];
        return OrderCard(
          order: order,
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => OrderTrackingScreen(orderId: order.id)),
            );
          },
        );
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onCreateOrder;
  final AppStrings s;
  const _EmptyState({required this.onCreateOrder, required this.s});

  @override
  Widget build(BuildContext context) {
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
                  Icon(Icons.inventory_2_outlined, size: 56, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    s.noOrdersTitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    s.noOrdersSubtitle,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: onCreateOrder,
                    icon: const Icon(Icons.add),
                    label: Text(s.createFirstOrder),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;
  final String retryLabel;

  const _ErrorState({required this.message, required this.onRetry, required this.retryLabel});

  @override
  Widget build(BuildContext context) {
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
                  Text(message, textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  ElevatedButton(onPressed: onRetry, child: Text(retryLabel)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
