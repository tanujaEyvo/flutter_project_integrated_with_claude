class OfflineLocation {
  final int id;
  final String code;
  final String name;

  OfflineLocation({
    required this.id,
    required this.code,
    required this.name,
  });

  factory OfflineLocation.fromMap(Map<String, dynamic> map) {
    return OfflineLocation(
      id: map['Location_ID'],
      code: map['Location_Code'],
      name: map['Location_Name'] ?? '',
    );
  }
}