import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_strings.dart';
import '../models/branch.dart';
import '../models/menu_item.dart';
import '../providers/cart_provider.dart';
import '../services/menu_repository.dart';
import 'cart_screen.dart';

class BranchMenuScreen extends StatefulWidget {
  final Branch branch;
  const BranchMenuScreen({super.key, required this.branch});

  @override
  State<BranchMenuScreen> createState() => _BranchMenuScreenState();
}

class _BranchMenuScreenState extends State<BranchMenuScreen> {
  late Future<Map<String, List<MenuItem>>> _menuFuture;

  @override
  void initState() {
    super.initState();
    _menuFuture = MenuRepository.menuForBranch(widget.branch.id);
  }

  void _addToCart(MenuItem item, bool isArabic) {
    final hasSizes = item.hasMultipleSizes(widget.branch.id);
    if (!hasSizes) {
      context.read<CartProvider>().addItem(item);
      _showAddedSnack(isArabic);
      return;
    }
    _showSizePicker(item, isArabic);
  }

  void _showAddedSnack(bool isArabic) {
    final s = AppStrings.of(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(s.addedToCart), duration: const Duration(milliseconds: 900)),
    );
  }

  void _showSizePicker(MenuItem item, bool isArabic) {
    final s = AppStrings.of(context);
    final prices = item.sizePricesFor(widget.branch.id);
    final labels = item.sizeLabelsFor(widget.branch.id, isArabic);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(item.nameFor(isArabic), style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
                const SizedBox(height: 4),
                Text(s.chooseSize, style: TextStyle(color: Colors.grey[600])),
                const SizedBox(height: 12),
                for (int i = 0; i < prices.length; i++)
                  ListTile(
                    title: Text(i < labels.length ? labels[i] : ''),
                    trailing: Text(s.currencyAed(prices[i].toStringAsFixed(0))),
                    onTap: () {
                      context.read<CartProvider>().addItem(item, sizeIndex: i);
                      Navigator.of(context).pop();
                      _showAddedSnack(isArabic);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final isArabic = Localizations.localeOf(context).languageCode == 'ar';

    return Scaffold(
      appBar: AppBar(title: Text(widget.branch.nameEn)),
      body: SafeArea(
        child: FutureBuilder<Map<String, List<MenuItem>>>(
          future: _menuFuture,
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final grouped = snapshot.data!;
            if (grouped.isEmpty) {
              return Center(child: Text(s.emptyMenu));
            }
            final categories = grouped.keys.toList();

            return ListView.builder(
              padding: const EdgeInsets.only(bottom: 96),
              itemCount: categories.length,
              itemBuilder: (context, catIndex) {
                final category = categories[catIndex];
                final items = grouped[category]!;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 6),
                      child: Text(
                        category,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ),
                    ...items.map((item) => _MenuItemTile(
                          item: item,
                          branchId: widget.branch.id,
                          isArabic: isArabic,
                          onAdd: () => _addToCart(item, isArabic),
                        )),
                  ],
                );
              },
            );
          },
        ),
      ),
      bottomNavigationBar: Consumer<CartProvider>(
        builder: (context, cart, _) {
          if (cart.isEmpty) return const SizedBox.shrink();
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const CartScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14)),
                child: Text(
                  '${s.viewCart} (${cart.totalQuantity}) · ${s.currencyAed(cart.total.toStringAsFixed(0))}',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _MenuItemTile extends StatelessWidget {
  final MenuItem item;
  final String branchId;
  final bool isArabic;
  final VoidCallback onAdd;

  const _MenuItemTile({
    required this.item,
    required this.branchId,
    required this.isArabic,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    final s = AppStrings.of(context);
    final prices = item.sizePricesFor(branchId);
    final hasSizes = item.hasMultipleSizes(branchId);
    final priceLabel = hasSizes
        ? s.currencyAed('${prices.first.toStringAsFixed(0)}+')
        : s.currencyAed(prices.isNotEmpty ? prices.first.toStringAsFixed(0) : '-');

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      title: Text(item.nameFor(isArabic)),
      subtitle: Text(priceLabel, style: TextStyle(color: Colors.grey[600])),
      trailing: IconButton(
        icon: const Icon(Icons.add_circle, color: Colors.teal),
        onPressed: onAdd,
      ),
    );
  }
}
