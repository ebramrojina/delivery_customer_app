import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/cart_item.dart';
import '../models/order.dart';
import '../providers/auth_provider.dart';
import '../providers/cart_provider.dart';
import '../providers/order_provider.dart';
import 'order_tracking_screen.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _formKey = GlobalKey<FormState>();
  final _deliveryController = TextEditingController();

  @override
  void dispose() {
    _deliveryController.dispose();
    super.dispose();
  }

  Future<void> _confirmOrder() async {
    if (!_formKey.currentState!.validate()) return;

    final cart = context.read<CartProvider>();
    final branch = cart.selectedBranch;
    if (branch == null || cart.isEmpty) return;

    final auth = context.read<AuthProvider>();
    final orderProvider = context.read<OrderProvider>();
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    final errorMessage = await orderProvider.createOrder(
      pickupAddress: DeliveryAddress(label: '${branch.nameEn} - ${branch.locationEn}'),
      deliveryAddress: DeliveryAddress(label: _deliveryController.text.trim()),
      branchId: branch.id,
      branchName: branch.nameEn,
      items: cart.lines.map((l) => l.toOrderJson(isArabic)).toList(),
      orderTotal: cart.total,
      token: auth.token!,
    );

    if (!mounted) return;

    if (errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errorMessage)));
      return;
    }

    final newOrder = orderProvider.orders.first;
    cart.clear();

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => OrderTrackingScreen(orderId: newOrder.id)),
      (route) => route.isFirst, // keep the orders list at the base of the stack
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';
    final cart = context.watch<CartProvider>();
    final isCreating = context.watch<OrderProvider>().isCreating;

    return Scaffold(
      appBar: AppBar(title: Text(s.yourCart)),
      body: SafeArea(
        child: cart.isEmpty ? _EmptyCart(s: s) : _buildCartBody(context, s, isArabic, cart, isCreating),
      ),
    );
  }

  Widget _buildCartBody(
    BuildContext context,
    AppStrings s,
    bool isArabic,
    CartProvider cart,
    bool isCreating,
  ) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (cart.selectedBranch != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    const Icon(Icons.storefront, size: 18, color: Colors.teal),
                    const SizedBox(width: 8),
                    Text('${s.pickupFrom}: ${cart.selectedBranch!.nameEn}',
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            Text(s.orderSummary, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...cart.lines.map((line) => _CartLineTile(line: line, isArabic: isArabic)),
            const Divider(height: 28),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(s.total, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text(
                  s.currencyAed(cart.total.toStringAsFixed(0)),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(s.deliveryDetails, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            TextFormField(
              controller: _deliveryController,
              maxLines: 2,
              decoration: InputDecoration(
                labelText: s.deliveryAddress,
                prefixIcon: const Icon(Icons.location_on),
                border: const OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return s.pleaseEnterDelivery;
                }
                return null;
              },
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: isCreating ? null : _confirmOrder,
              style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
              child: isCreating
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(s.confirmOrder, style: const TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartLineTile extends StatelessWidget {
  final CartItem line;
  final bool isArabic;
  const _CartLineTile({required this.line, required this.isArabic});

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final cart = context.read<CartProvider>();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(line.displayName(isArabic), style: const TextStyle(fontSize: 14)),
          ),
          Text(s.currencyAed(line.lineTotal.toStringAsFixed(0)), style: const TextStyle(fontSize: 13, color: Colors.grey)),
          const SizedBox(width: 8),
          IconButton(
            icon: const Icon(Icons.remove_circle_outline, size: 20),
            onPressed: () => cart.decrementLine(line),
            visualDensity: VisualDensity.compact,
          ),
          Text('${line.quantity}'),
          IconButton(
            icon: const Icon(Icons.add_circle_outline, size: 20),
            onPressed: () => cart.incrementLine(line),
            visualDensity: VisualDensity.compact,
          ),
        ],
      ),
    );
  }
}

class _EmptyCart extends StatelessWidget {
  final AppStrings s;
  const _EmptyCart({required this.s});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shopping_cart_outlined, size: 56, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text(s.emptyCartTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
            const SizedBox(height: 8),
            Text(s.emptyCartSubtitle, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ),
    );
  }
}
