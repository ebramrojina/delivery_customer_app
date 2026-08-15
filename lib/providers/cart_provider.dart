import 'package:flutter/foundation.dart';
import '../models/branch.dart';
import '../models/cart_item.dart';
import '../models/menu_item.dart';

/// Holds the customer's current branch selection and cart contents while
/// they browse the menu and check out. Cleared after a successful order.
class CartProvider extends ChangeNotifier {
  Branch? selectedBranch;
  final List<CartItem> _lines = [];

  List<CartItem> get lines => List.unmodifiable(_lines);

  bool get isEmpty => _lines.isEmpty;

  int get totalQuantity => _lines.fold(0, (sum, l) => sum + l.quantity);

  double get total => _lines.fold(0, (sum, l) => sum + l.lineTotal);

  void selectBranch(Branch branch) {
    if (selectedBranch?.id != branch.id) {
      // Switching branches invalidates prices/availability from the old one.
      _lines.clear();
    }
    selectedBranch = branch;
    notifyListeners();
  }

  void addItem(MenuItem item, {int? sizeIndex, int quantity = 1}) {
    if (selectedBranch == null) return;
    final branchId = selectedBranch!.id;
    final existingIndex = _lines.indexWhere((l) => l.matches(item, sizeIndex));
    if (existingIndex != -1) {
      _lines[existingIndex].quantity += quantity;
    } else {
      _lines.add(CartItem(
        menuItem: item,
        branchId: branchId,
        sizeIndex: sizeIndex,
        quantity: quantity,
      ));
    }
    notifyListeners();
  }

  void incrementLine(CartItem line) {
    line.quantity++;
    notifyListeners();
  }

  void decrementLine(CartItem line) {
    line.quantity--;
    if (line.quantity <= 0) {
      _lines.remove(line);
    }
    notifyListeners();
  }

  void removeLine(CartItem line) {
    _lines.remove(line);
    notifyListeners();
  }

  void clear() {
    _lines.clear();
    selectedBranch = null;
    notifyListeners();
  }
}
