import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import '../models/branch.dart';
import '../models/menu_item.dart';

/// Loads the branch list and shared menu from bundled JSON assets.
/// Both are static data (seeded from the master price-list spreadsheet),
/// so this simply reads and caches them once per app run.
class MenuRepository {
  static List<Branch>? _branches;
  static List<MenuItem>? _menuItems;

  static Future<List<Branch>> loadBranches() async {
    if (_branches != null) return _branches!;
    final raw = await rootBundle.loadString('assets/data/branches.json');
    final list = jsonDecode(raw) as List<dynamic>;
    _branches = list.map((e) => Branch.fromJson(e as Map<String, dynamic>)).toList();
    return _branches!;
  }

  static Future<List<MenuItem>> loadMenuItems() async {
    if (_menuItems != null) return _menuItems!;
    final raw = await rootBundle.loadString('assets/data/menu.json');
    final list = jsonDecode(raw) as List<dynamic>;
    _menuItems = list.map((e) => MenuItem.fromJson(e as Map<String, dynamic>)).toList();
    return _menuItems!;
  }

  /// Menu items available at [branchId], grouped by category in the
  /// original spreadsheet order.
  static Future<Map<String, List<MenuItem>>> menuForBranch(String branchId) async {
    final items = await loadMenuItems();
    final available = items.where((i) => i.availableAt(branchId)).toList();
    final grouped = <String, List<MenuItem>>{};
    for (final item in available) {
      grouped.putIfAbsent(item.category, () => []).add(item);
    }
    return grouped;
  }
}
