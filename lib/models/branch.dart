class Branch {
  final String id;
  final String nameEn;
  final String locationEn;
  final String locationAr;

  Branch({
    required this.id,
    required this.nameEn,
    required this.locationEn,
    required this.locationAr,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] as String,
      nameEn: json['nameEn'] as String,
      locationEn: json['locationEn'] as String,
      locationAr: json['locationAr'] as String,
    );
  }

  /// Branch names are always shown in English regardless of app language;
  /// only the location line follows the current locale.
  String locationFor(bool isArabic) => isArabic ? locationAr : locationEn;
}
