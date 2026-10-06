class OfflineRegion {
  final int id;
  final String code;

  OfflineRegion({
    required this.id,
    required this.code,
  });

  factory OfflineRegion.fromMap(Map<String, dynamic> map) {
    return OfflineRegion(
      id: map['Region_ID'],
      code: map['Region_Code'],
    );
  }
}
