class OfflineItemStock {
  int? itemId;
  int? locationId;
  final String? unitName;

  String? itemCode;
  String? outLine;
  String? description;

  int? categoryId;
  String? categoryCode;
  String? itemType;

  int? isStock;

  int? regionId;
  String? locationCode;

  double? totalStockCount;
  double? newStockCount;
  double? unitSelected;
  String? comments;
  String? updatedBy;
  String? updatedOn;
  String? unitType;

  int? synced;
  String? locationName;
  String? regionName;
  final bool? catchWeight;
  final bool? splittable;
  final String? actualWeightLabel;
  final int? purchaseUnitID;
  final String? purchaseUnit;
  final int? inventoryUnitID;
  final String? inventoryUnit;
  final String? standardUnit;
  final double? purchaseUnitConversion;
  final double? inventoryUnitConversion;
  final int? recipeUnitID;
  final String? recipeUnit;
  final double? recipeUnitConversion;
  OfflineItemStock(
      {this.itemId,
      this.locationId,
      this.itemCode,
      this.outLine,
      this.description,
      this.categoryId,
      this.categoryCode,
      this.itemType,
      this.isStock,
      this.regionId,
      this.locationCode,
      this.totalStockCount,
      this.newStockCount,
      this.comments,
      this.updatedBy,
      this.updatedOn,
      this.synced,
      this.locationName,
      this.regionName,
      this.catchWeight,
      this.splittable,
      this.actualWeightLabel,
      this.purchaseUnitID,
      this.purchaseUnit,
      this.inventoryUnitID,
      this.inventoryUnit,
      this.standardUnit,
      this.purchaseUnitConversion,
      this.unitType,
      this.inventoryUnitConversion,
      this.recipeUnitID,
      this.recipeUnit,
      this.recipeUnitConversion,
      this.unitName,
      this.unitSelected});
  bool get isStockBool => (isStock ?? 0) == 1;

  bool get isSyncedBool => (synced ?? 0) == 1;

  factory OfflineItemStock.fromMap(Map<String, dynamic> map) {
    return OfflineItemStock(
        itemId: map['ItemID'] as int?,
        locationId: map['LocationID'] as int?,
        itemCode: map['ItemCode'] as String?,
        outLine: map['OutLine'] as String?,
        description: map['Description'] as String?,
        categoryId: map['CategoryID'] as int?,
        categoryCode: map['CategoryCode'] as String?,
        itemType: map['Item_Type'] as String?,
        isStock: map['IsStock'] as int?,
        regionId: map['Region_ID'] as int?,
        locationCode: map['LocationCode'] as String?,
        totalStockCount: (map['TotalStockCount'] as num?)?.toDouble(),
        newStockCount: (map['NewStockCount'] as num?)?.toDouble(),
        unitSelected: (map['Unit_Selected'] as num?)?.toDouble(),
        comments: map['Comments'] as String?,
        catchWeight: (map['CatchWeight'] as num?)?.toInt() == 1,
        splittable: (map['Splitable'] as num?)?.toInt() == 1,
        updatedBy: map['UpdatedBy'] as String?,
        updatedOn: map['UpdatedOn'] as String?,
        synced: map['Synced'] as int?,
        locationName: map['LocationName'] as String?,
        unitType: map['Unit_Type'] as String?,
        // ── units (THIS WAS MISSING) ──────────────────────────
        purchaseUnitID: (map['UnitID'] as num?)?.toInt(),
        inventoryUnitConversion:
            (map['InventoryUnit_Conversion'] as num?)?.toDouble(),
        recipeUnitID: (map['RecipeUnitID'] as num?)?.toInt(),
        recipeUnit: map['RecipeUnit'] as String?,
        recipeUnitConversion:
            (map['RecipeUnit_Conversion'] as num?)?.toDouble(),
        purchaseUnit: map['Unit'] as String?,
        inventoryUnitID: (map['InventoryUnitID'] as num?)?.toInt(),
        inventoryUnit: map['InventoryUnit'] as String?,
        standardUnit: map['StandardUnit'] as String?,
        purchaseUnitConversion:
            (map['PurchaseUnit_Conversion'] as num?)?.toDouble(),
        unitName: map['UnitName'] as String?,

        // if you have a column for this, map it; else leave null
        actualWeightLabel: null,
        regionName: map['RegionName'] as String?);
  }

  Map<String, dynamic> toMap() {
    return {
      'ItemID': itemId,
      'LocationID': locationId,
      'ItemCode': itemCode,
      'OutLine': outLine,
      'Description': description,
      'CategoryID': categoryId,
      'CategoryCode': categoryCode,
      'Item_Type': itemType,
      'IsStock': isStock,
      'Region_ID': regionId,
      'LocationCode': locationCode,
      'TotalStockCount': totalStockCount,
      'NewStockCount': newStockCount,
      'Comments': comments,
      'UpdatedBy': updatedBy,
      'UpdatedOn': updatedOn,
      'Synced': synced,
      'locationName': locationName,
      'regionName': regionName,
      'Unit_Type': unitType,
      'Unit_Selected': unitSelected,
      'CatchWeight': (catchWeight ?? false) ? 1 : 0,
      'Splitable': (splittable ?? false) ? 1 : 0,
      'UnitID': purchaseUnitID,
      'Unit': purchaseUnit,
      'InventoryUnitID': inventoryUnitID,
      'InventoryUnit': inventoryUnit,
      'StandardUnit': standardUnit,
      'PurchaseUnit_Conversion': purchaseUnitConversion,
      'InventoryUnit_Conversion': inventoryUnitConversion,
      'RecipeUnitID': recipeUnitID,
      'RecipeUnit': recipeUnit,
      'RecipeUnit_Conversion': recipeUnitConversion,
      'UnitName': unitName,
    };
  }
}
