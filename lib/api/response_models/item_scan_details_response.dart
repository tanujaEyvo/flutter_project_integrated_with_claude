import 'dart:convert';

class ScanItemResponseModel {
  final int itemId;
  final String itemCode;
  final String outline;
  final String description;
  final String imageName;
  final String itemImage;
  final String categoryCode;
  final String note;
  final int regionId;
  final int locationId;

  ScanItemResponseModel({
    required this.itemId,
    required this.itemCode,
    required this.outline,
    required this.description,
    required this.imageName,
    required this.itemImage,
    required this.categoryCode,
    required this.note,
    required this.regionId,
    required this.locationId,
  });

  factory ScanItemResponseModel.fromJson(Map<String, dynamic> json) {
    return ScanItemResponseModel(
      itemId: json['itemid'] ?? 0,
      itemCode: json['itemcode'] ?? '',
      outline: json['outline'] ?? '',
      description: json['description'] ?? '',
      imageName: json['imagename'] ?? '',
      itemImage: json['itemimage'] ?? '',
      categoryCode: json['categorycode'] ?? '',
      note: json['note'] ?? '',
      regionId: json['regionid'] ?? 0,
      locationId: json['locationid'] ?? 0,
    );
  }
}

class ScanItemResponse {
  final String code;
  final List<String> message;
  final List<ScanItemResponseModel>? data;
  final int totalRecords;

  ScanItemResponse({
    required this.code,
    required this.message,
    this.data,
    required this.totalRecords,
  });

  factory ScanItemResponse.fromJson(Map<String, dynamic> json) {
    List<ScanItemResponseModel>? items;

    if (json['data'] != null) {
      final dataList = jsonDecode(json['data']) as List;
      items = dataList.map((e) => ScanItemResponseModel.fromJson(e)).toList();
    }

    return ScanItemResponse(
      code: json['code'] ?? '',
      message: List<String>.from(json['message'] ?? []),
      data: items,
      totalRecords: json['totalrecords'] ?? 0,
    );
  }
}