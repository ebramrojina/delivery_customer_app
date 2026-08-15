/// Generic size labels used when an item has more than one price tier.
/// Two prices -> Small/Large, three prices -> Small/Medium/Large.
const List<String> _sizeLabelsEn = ['Small', 'Medium', 'Large'];
const List<String> _sizeLabelsAr = ['صغير', 'وسط', 'كبير'];

class MenuItem {
  final String category;
  final String nameEn;
  final String nameAr;

  /// branchId -> list of size prices. A single-entry list means the item
  /// has one price at that branch; multiple entries mean it comes in
  /// multiple sizes (parsed from "12/17" style cells).
  final Map<String, List<double>> pricesByBranch;

  MenuItem({
    required this.category,
    required this.nameEn,
    required this.nameAr,
    required this.pricesByBranch,
  });

  factory MenuItem.fromJson(Map<String, dynamic> json) {
    final rawPrices = (json['prices'] as Map<String, dynamic>? ?? {});
    final parsed = <String, List<double>>{};
    rawPrices.forEach((branchId, value) {
      final parts = (value as String).split('/');
      parsed[branchId] = parts
          .map((p) => double.tryParse(p.trim()) ?? 0)
          .toList();
    });

    return MenuItem(
      category: json['category'] as String,
      nameEn: json['nameEn'] as String,
      nameAr: json['nameAr'] as String? ?? json['nameEn'] as String,
      pricesByBranch: parsed,
    );
  }

  String nameFor(bool isArabic) => isArabic ? nameAr : nameEn;

  bool availableAt(String branchId) =>
      pricesByBranch.containsKey(branchId) &&
      pricesByBranch[branchId]!.isNotEmpty;

  List<double> sizePricesFor(String branchId) => pricesByBranch[branchId] ?? const [];

  bool hasMultipleSizes(String branchId) => sizePricesFor(branchId).length > 1;

  List<String> sizeLabelsFor(String branchId, bool isArabic) {
    final count = sizePricesFor(branchId).length;
    final labels = isArabic ? _sizeLabelsAr : _sizeLabelsEn;
    if (count <= 1) return const [];
    if (count == 2) return [labels[0], labels[2]]; // Small / Large
    return labels.sublist(0, count);
  }
}
