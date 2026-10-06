import 'dart:convert';

class ListItem {
  int itemId;
  String itemCode;
  String outline;
  String imageName;
  String itemImage;
  String? categoryCode;
  double stockCount;

  ListItem({
    required this.itemId,
    required this.itemCode,
    required this.outline,
    required this.imageName,
    required this.itemImage,
    this.categoryCode,
    required this.stockCount,
  });

  factory ListItem.fromJson(Map<String, dynamic> json) {
    return ListItem(
      itemId: json['itemid'] ?? 0,
      itemCode: json['itemcode']?.toString() ?? '',
      outline: json['outline']?.toString() ?? '',
      imageName: json['imagename']?.toString() ?? '',
      itemImage: json['itemimage']?.toString() ?? '',
      categoryCode: json['categorycode']?.toString(),
      stockCount: (json['stockcount'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class ItemListResponse {
  String code;
  List<String> message;
  List<ListItem> data; // <-- not nullable
  int totalRecords;

  ItemListResponse({
    required this.code,
    required this.message,
    required this.data,
    required this.totalRecords,
  });

  // factory ItemListResponse.fromJson(Map<String, dynamic> json) {
  //   List<ListItem> items = [];

  //   if (json['data'] != null && json['data'] is List) {
  //     items = (json['data'] as List)
  //         .map((e) => ListItem.fromJson(e as Map<String, dynamic>))
  //         .toList();
  //   }

  //   return ItemListResponse(
  //     code: json['code']?.toString() ?? '',
  //     message: (json['message'] as List?)
  //             ?.map((e) => e.toString())
  //             .toList() ??
  //         [],
  //     data: items, // always a List
  //     totalRecords: json['totalrecords'] ?? 0,
  //   );
  // }
  factory ItemListResponse.fromJson(Map<String, dynamic> json) {
    List<ListItem> items = [];

    // Check if data is a String (JSON string) or already a List
    if (json['data'] != null) {
      if (json['data'] is String) {
        // Parse the JSON string to a List
        try {
          final String dataString = json['data'] as String;
          final List<dynamic> dataList = jsonDecode(dataString);
          items = dataList
              .map((e) => ListItem.fromJson(e as Map<String, dynamic>))
              .toList();
        } catch (e) {
          print('Error parsing data string: $e');
          items = [];
        }
      } else if (json['data'] is List) {
        // Already a List
        items = (json['data'] as List)
            .map((e) => ListItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    }

    return ItemListResponse(
      code: json['code']?.toString() ?? '',
      message:
          (json['message'] as List?)?.map((e) => e.toString()).toList() ?? [],
      data: items,
      totalRecords: json['totalrecords'] ?? 0,
    );
  }
}
