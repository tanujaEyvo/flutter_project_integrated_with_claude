import 'dart:convert';

GetOfflineDataResponse getOfflineDataResponseFromJson(String str) =>
    GetOfflineDataResponse.fromJson(json.decode(str));

String getOfflineDataResponseToJson(GetOfflineDataResponse data) =>
    json.encode(data.toJson());

class GetOfflineDataResponse {
  int code;
  List<String> message;
  OfflineDBDate data;
  int totalrecords;

  GetOfflineDataResponse({
    required this.code,
    required this.message,
    required this.data,
    required this.totalrecords,
  });

  factory GetOfflineDataResponse.fromJson(Map<String, dynamic> json) =>
      GetOfflineDataResponse(
        code: json["code"],
        message: List<String>.from(json["message"].map((x) => x)),
        data: json["data"] != null
            ? OfflineDBDate.fromJson(json["data"] as Map<String, dynamic>)
            : OfflineDBDate.empty(),
        totalrecords: json["totalrecords"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": List<dynamic>.from(message.map((x) => x)),
        "data": data.toJson(),
        "totalrecords": totalrecords,
      };
}

class OfflineDBDate {
  List<Location> locations;
  List<Region> regions;
  List<ItemRegion> itemsRegion;
  List<Item> items;
  String noLocationMessage;

  OfflineDBDate({
    required this.locations,
    required this.regions,
    required this.itemsRegion,
    required this.items,
    required this.noLocationMessage,
  });

  factory OfflineDBDate.fromJson(Map<String, dynamic> json) => OfflineDBDate(
        locations: List<Location>.from(
            json["locations"].map((x) => Location.fromJson(x))),
        regions:
            List<Region>.from(json["regions"].map((x) => Region.fromJson(x))),
        itemsRegion: List<ItemRegion>.from(
            json["items_region"].map((x) => ItemRegion.fromJson(x))),
        items: List<Item>.from(json["items"].map((x) => Item.fromJson(x))),
        noLocationMessage: json["no_location_message"],
      );

  Map<String, dynamic> toJson() => {
        "locations": List<dynamic>.from(locations.map((x) => x.toJson())),
        "regions": List<dynamic>.from(regions.map((x) => x.toJson())),
        "items_region": List<dynamic>.from(itemsRegion.map((x) => x.toJson())),
        "items": List<dynamic>.from(items.map((x) => x.toJson())),
        "no_location_message": noLocationMessage,
      };
  factory OfflineDBDate.empty() => OfflineDBDate(
        locations: [],
        regions: [],
        itemsRegion: [],
        items: [],
        noLocationMessage: '',
      );
}

class Item {
  int itemId;
  String itemCode;
  String outline;
  String description;
  int categoryId;
  String categoryCode;
  bool isstock;
  int itemTypeValue;
  String itemType;
  int locationId;
  String locationCode;
  double totalStockCount;
  String? upc;
  bool? catchWeight;
  bool? splittable;
  bool? taxExempt;
  int? standardUnitId;
  String? standardUnit;
  int? purchaseUnitId;
  String? purchaseUnit;
  double? purchaseUnitConversion;
  int? inventoryUnitId;
  String? inventoryUnit;
  double? inventoryUnitConversion;

  Item({
    required this.itemId,
    required this.itemCode,
    required this.outline,
    required this.description,
    required this.categoryId,
    required this.categoryCode,
    required this.isstock,
    required this.itemTypeValue,
    required this.itemType,
    required this.locationId,
    required this.locationCode,
    required this.totalStockCount,
    this.upc,
    this.catchWeight,
    this.splittable,
    this.taxExempt,
    this.standardUnitId,
    this.standardUnit,
    this.purchaseUnitId,
    this.purchaseUnit,
    this.purchaseUnitConversion,
    this.inventoryUnitId,
    this.inventoryUnit,
    this.inventoryUnitConversion,
  });

  factory Item.fromJson(Map<String, dynamic> json) => Item(
        itemId: json["itemId"],
        itemCode: json["itemCode"],
        outline: json["outline"],
        description: json["description"],
        categoryId: json["categoryID"],
        categoryCode: json["categoryCode"],
        isstock: json["isstock"],
        itemTypeValue: json["item_type"],
        itemType: json["itemType"],
        locationId: json["location_ID"],
        locationCode: json["location_Code"],
        totalStockCount: (json["totalStockCount"] ?? 0).toDouble(),
        upc: json["upc"],
        catchWeight: json["catchWeight"],
        splittable: json["splittable"],
        taxExempt: json["tax_Exempt"],
        standardUnitId: json["standardUnitID"],
        standardUnit: json["standardUnit"],
        purchaseUnitId: json["purchaseUnitID"],
        purchaseUnit: json["purchaseUnit"],
        purchaseUnitConversion:
            (json["purchaseUnit_Conversion"] as num?)?.toDouble(),
        inventoryUnitId: json["inventoryUnitID"],
        inventoryUnit: json["inventoryUnit"],
        inventoryUnitConversion:
            (json["inventoryUnit_Conversion"] as num?)?.toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "itemId": itemId,
        "itemCode": itemCode,
        "outline": outline,
        "description": description,
        "categoryID": categoryId,
        "categoryCode": categoryCode,
        "isstock": isstock,
        "item_type": itemTypeValue,
        "itemType": itemType,
        "location_ID": locationId,
        "location_Code": locationCode,
        "totalStockCount": totalStockCount,
        "upc": upc,
        "catchWeight": catchWeight,
        "splittable": splittable,
        "tax_Exempt": taxExempt,
        "standardUnitID": standardUnitId,
        "standardUnit": standardUnit,
        "purchaseUnitID": purchaseUnitId,
        "purchaseUnit": purchaseUnit,
        "purchaseUnit_Conversion": purchaseUnitConversion,
        "inventoryUnitID": inventoryUnitId,
        "inventoryUnit": inventoryUnit,
        "inventoryUnit_Conversion": inventoryUnitConversion,
      };
}

class ItemRegion {
  int itemid;
  String regionId;

  ItemRegion({
    required this.itemid,
    required this.regionId,
  });

  factory ItemRegion.fromJson(Map<String, dynamic> json) => ItemRegion(
        itemid: json["itemid"],
        regionId: json["region_id"],
      );

  Map<String, dynamic> toJson() => {
        "itemid": itemid,
        "region_id": regionId,
      };
}

class Location {
  int locationid;
  String locationcode;
  int regionId;
  int defaultLocation;

  Location({
    required this.locationid,
    required this.locationcode,
    required this.regionId,
    required this.defaultLocation,
  });

  factory Location.fromJson(Map<String, dynamic> json) => Location(
        locationid: json["locationid"],
        locationcode: json["locationcode"],
        regionId: json["region_id"],
        defaultLocation: json["default_location"],
      );

  Map<String, dynamic> toJson() => {
        "locationid": locationid,
        "locationcode": locationcode,
        "region_id": regionId,
        "default_location": defaultLocation,
      };
}

class Region {
  int regionid;
  String regioncode;

  Region({
    required this.regionid,
    required this.regioncode,
  });

  factory Region.fromJson(Map<String, dynamic> json) => Region(
        regionid: json["regionid"],
        regioncode: json["regioncode"],
      );

  Map<String, dynamic> toJson() => {
        "regionid": regionid,
        "regioncode": regioncode,
      };
}
