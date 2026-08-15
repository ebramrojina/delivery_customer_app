import 'menu_item.dart';

/// One line in the cart: a menu item, an optional chosen size, and a
/// quantity. Kept separate from [MenuItem] so the same dish selected in
/// two different sizes shows up as two distinct cart lines.
class CartItem {
  final MenuItem menuItem;
  final String branchId;
  final int? sizeIndex; // null when the item has only one size
  int quantity;

  CartItem({
    required this.menuItem,
    required this.branchId,
    this.sizeIndex,
    this.quantity = 1,
  });

  double get unitPrice {
    final prices = menuItem.sizePricesFor(branchId);
    if (prices.isEmpty) return 0;
    if (sizeIndex != null && sizeIndex! < prices.length) return prices[sizeIndex!];
    return prices.first;
  }

  double get lineTotal => unitPrice * quantity;

  /// Display name including size, e.g. "Turkish Coffee (Large)".
  String displayName(bool isArabic) {
    final base = menuItem.nameFor(isArabic);
    if (sizeIndex == null) return base;
    final labels = menuItem.sizeLabelsFor(branchId, isArabic);
    if (sizeIndex! >= labels.length) return base;
    return '$base (${labels[sizeIndex!]})';
  }

  /// Two cart lines are "the same" if they're the same item + same size,
  /// so adding again just increments quantity instead of duplicating.
  bool matches(MenuItem item, int? size) =>
      menuItem.nameEn == item.nameEn && sizeIndex == size;

  /// What gets sent to the backend as one entry in the order's items array.
  Map<String, dynamic> toOrderJson(bool isArabic) => {
        'name': displayName(false), // always store English name server-side
        'price': unitPrice,
        'quantity': quantity,
      };
}
