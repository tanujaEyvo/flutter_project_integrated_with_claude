import 'dart:convert';

class ReceivedItemsResponse {
  final String code;
  final List<String> message;
  final dynamic data;
  final int totalRecords;
  final bool print;

  ReceivedItemsResponse(
      {required this.code,
      required this.message,
      this.data,
      required this.totalRecords,
      required this.print});

  factory ReceivedItemsResponse.fromJson(Map<String, dynamic> json) {
    return ReceivedItemsResponse(
      code: json['code'],
      message: List<String>.from(json['message']),
      data: json['data'] == null
          ? json['data']
          : List<OrderData>.from(
              jsonDecode(json['data']).map((item) => OrderData.fromJson(item))),
      totalRecords: json['totalrecords'],
      print: json['print'],
    );
  }
}

class OrderData {
  final int orderId;
  final int orderLineId;
  final int itemId;
  final String? itemCode;
  final String description;
  final String imageName;
  final String itemImage;
  final double quantity;
  late double receivedQuantity;
  final double bookInQuantity;
  late double rejectquantity;
  final String rejectReason;
  final String action;
  final String notes;
  final int regionId;
  final int itemType;
  final bool isStock;
  final int itemOrder;
  late double updatedQuantity;
  late bool isSelected;
  late bool isEdited;
  final bool? catchWeight;
  final bool? splittable;
  final bool? taxExempt;
  final int? standardUnitID;
  final String? standardUnit;
  final String? purchaseUnitID;
  final String? purchaseUnit;
  final double? purchaseUnitConversion;
  final int? inventoryUnitID;
  final String? inventoryUnit;
  final double? inventoryUnitConversion;
  final String? actualWeightLabel;
  OrderData({
    required this.orderId,
    required this.orderLineId,
    required this.itemId,
    this.itemCode,
    required this.description,
    required this.imageName,
    required this.itemImage,
    required this.quantity,
    required this.receivedQuantity,
    required this.bookInQuantity,
    required this.notes,
    required this.rejectquantity,
    required this.rejectReason,
    required this.action,
    required this.regionId,
    required this.itemType,
    required this.isStock,
    required this.itemOrder,
    this.updatedQuantity = 0.0,
    this.isSelected = false,
    this.isEdited = false,
    this.catchWeight,
    this.splittable,
    this.taxExempt,
    this.standardUnitID,
    this.standardUnit,
    this.purchaseUnitID,
    this.purchaseUnit,
    this.purchaseUnitConversion,
    this.inventoryUnitID,
    this.inventoryUnit,
    this.inventoryUnitConversion,
    this.actualWeightLabel,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      return double.tryParse(value.toString()) ?? 0.0;
    }

    double? parseNullableDouble(dynamic value) {
      if (value == null) return null;
      if (value is int) return value.toDouble();
      if (value is double) return value;
      return double.tryParse(value.toString());
    }

    int? parseNullableInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      return int.tryParse(value.toString());
    }

    return OrderData(
      orderId: json['orderid'] ?? 0,
      orderLineId: json['orderlineid'] ?? 0,
      itemId: json['itemid'] ?? 0,
      itemCode: json['itemcode'],
      description: json['description'] ?? '',
      imageName: json['imagename'] ?? '',
      itemImage: json['itemimage'] ?? '',
      quantity: parseDouble(json['quantity']),
      receivedQuantity: parseDouble(json['receivedquantity']),
      bookInQuantity: parseDouble(json['bookinquantity']),
      rejectquantity: parseDouble(json['rejectquantity']),
      rejectReason: json['rejectReason'] ?? '',
      action: json['action'] ?? '',
      notes: json['notes'] ?? '',
      regionId: json['regionid'] ?? 0,
      itemType: json['itemtype'] ?? 0,
      isStock: json['isstock'] ?? false,
      itemOrder: json['itemorder'] ?? 0,
      updatedQuantity: parseDouble(json['receivedquantity']),
      isEdited: false,
      isSelected: false,
      catchWeight: json['CatchWeight'] as bool?,
      splittable: json['Splittable'] as bool?,
      taxExempt: json['Tax_Exempt'] as bool?,
      standardUnitID: parseNullableInt(json['standardUnitID']),
      standardUnit: json['standardUnit'] as String?,
      purchaseUnitID: json['purchaseUnitID']?.toString(),
      purchaseUnit: json['purchaseUnit'] as String?,
      purchaseUnitConversion:
          parseNullableDouble(json['PurchaseUnit_Conversion']),
      inventoryUnitID: parseNullableInt(json['InventoryUnitID']),
      inventoryUnit: json['InventoryUnit'] as String?,
      inventoryUnitConversion:
          parseNullableDouble(json['InventoryUnit_Conversion']),
      actualWeightLabel: json['actualWeightLabel'] as String?,
    );
  }
}
