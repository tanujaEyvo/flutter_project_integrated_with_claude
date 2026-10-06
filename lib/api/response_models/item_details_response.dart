import 'dart:convert';

class ItemDetails {
  final int itemId;
  final int itemType;
  final double stockCount;
  final double basePrice;
  final bool itemEdit;
  final bool isStock;
  final String itemCode;
  final String outline;
  final String description;
  final String imageName;
  final String itemImage;
  final String categoryCode;
  final String note;

  final int? regionid;
  final int? locationid;
  final String? locationCaption;

  final bool? catchWeight;
  final bool? splittable;
  final int? standardUnitID;
  final String? standardUnit;
  final int? purchaseUnitID;
  final String? purchaseUnit;
  final double? purchaseUnitConversion;
  final int? inventoryUnitID;
  final String? inventoryUnit;
  final double? inventoryUnitConversion;
  final bool? taxExempt;
  final String? actualWeightLabel;

  ItemDetails({
    required this.itemId,
    required this.itemType,
    required this.stockCount,
    required this.basePrice,
    required this.itemEdit,
    required this.isStock,
    required this.itemCode,
    required this.outline,
    required this.description,
    required this.imageName,
    required this.itemImage,
    required this.categoryCode,
    required this.note,
    this.regionid,
    this.locationid,
    this.locationCaption,
    this.catchWeight,
    this.splittable,
    this.standardUnitID,
    this.standardUnit,
    this.purchaseUnitID,
    this.purchaseUnit,
    this.purchaseUnitConversion,
    this.inventoryUnitID,
    this.inventoryUnit,
    this.inventoryUnitConversion,
    this.taxExempt,
    this.actualWeightLabel,
  });

  factory ItemDetails.fromJson(Map<String, dynamic> json) {
    return ItemDetails(
      itemId: _toInt(json['itemid']) ?? 0,
      itemType: _toInt(json['item_type']) ?? 0,
      stockCount: _toDouble(json['stockcount']) ?? 0.0,
      basePrice: _toDouble(json['baseprice']) ?? 0.0,
      itemEdit: json['itemedit'] ?? false,
      isStock: json['isstock'] ?? false,
      itemCode: json['itemcode']?.toString() ?? '',
      outline: json['outline']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
      imageName: json['imagename']?.toString() ?? '',
      itemImage: json['itemimage']?.toString() ?? '',
      categoryCode: json['categorycode']?.toString() ?? '',
      note: json['note']?.toString() ?? '',
      regionid: _toInt(json['regionid']),
      locationid: _toInt(json['locationid']),
      locationCaption: json['location_caption']?.toString(),
      catchWeight: json['CatchWeight'],
      splittable: json['Splittable'],
      standardUnitID: _toInt(json['standardUnitID']),
      standardUnit: json['standardUnit']?.toString(),
      purchaseUnitID: _toInt(json['purchaseUnitID']),
      purchaseUnit: json['purchaseUnit']?.toString(),
      purchaseUnitConversion: _toDouble(json['PurchaseUnit_Conversion']),
      inventoryUnitID: _toInt(json['InventoryUnitID']),
      inventoryUnit: json['InventoryUnit']?.toString(),
      inventoryUnitConversion: _toDouble(json['InventoryUnit_Conversion']),
      taxExempt: json['Tax_Exempt'] as bool?,
      actualWeightLabel: json['actualWeightLabel']?.toString() ?? '',
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;

    if (value is int) return value;

    if (value is double) return value.toInt();

    return int.tryParse(value.toString()) ??
        double.tryParse(value.toString())?.toInt();
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toDouble();
    }

    return double.tryParse(value.toString());
  }
}

class ItemDetailsResponse {
  final String code;
  final List<String> message;
  final dynamic data;
  final int totalRecords;

  ItemDetailsResponse({
    required this.code,
    required this.message,
    this.data,
    required this.totalRecords,
  });

  factory ItemDetailsResponse.fromJson(Map<String, dynamic> json) {
    List<ItemDetails> items = [];

    if (json['data'] != null) {
      final decodedData = jsonDecode(json['data']);

      if (decodedData is List) {
        items = decodedData
            .map(
              (item) => ItemDetails.fromJson(
                Map<String, dynamic>.from(item),
              ),
            )
            .toList();
      }
    }

    return ItemDetailsResponse(
      code: json['code']?.toString() ?? '',
      message:
          json['message'] != null ? List<String>.from(json['message']) : [],
      data: json['data'] == null ? null : items,
      totalRecords: ItemDetails._toInt(json['totalrecords']) ?? 0,
    );
  }
}
