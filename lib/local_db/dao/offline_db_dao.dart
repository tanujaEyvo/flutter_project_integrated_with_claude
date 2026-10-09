import 'dart:convert';

import 'package:eyvo_v3/app/app_prefs.dart';
import 'package:eyvo_v3/local_db/model/offline_item_stock_model.dart';
import 'package:eyvo_v3/local_db/database_helper.dart';

import 'package:eyvo_v3/log_data.dart/logger_data.dart';
import 'package:logger/logger.dart';
import 'package:sqflite/sqflite.dart';

class OfflineDBDao {
  final DBHelper _dbHelper = DBHelper();
  // Clear all offline tables
  Future<void> clearOfflineData() async {
    final Database db = await _dbHelper.db;

    await db.delete('item_stock');
    await db.delete('region_master');
    await db.delete('items_location');
    await db.delete('items_region');
    await db.delete('error_log');

    LoggerData.dataLog("Offline tables cleared");
  }

  // Insert Locations
  Future<void> insertLocations(List locations) async {
    final Database db = await _dbHelper.db;
    final batch = db
        .batch(); //Batch = bulk insert tool, Much faster than inserting one-by-one

    for (var loc in locations) {
      batch.insert(
        'items_location',
        {
          'Location_ID': loc['locationid'],
          'Location_Code': loc['locationcode'],
          'Region_Id': loc['region_id'],
          'Default_Location': loc['default_location']
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    LoggerData.dataLog("Locations saved: ${locations.length}");
  }

  // Insert Regions
  Future<void> insertRegions(List regions) async {
    final Database db = await _dbHelper.db;
    final batch = db.batch();

    for (var reg in regions) {
      batch.insert(
        'region_master',
        {
          'Region_ID': reg['regionid'],
          'Region_Code': reg['regioncode'],
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    LoggerData.dataLog("Regions saved: ${regions.length}");
  }

  // Insert Items
  Future<void> insertItems(List items) async {
    final Database db = await _dbHelper.db;
    final batch = db.batch();

    for (var item in items) {
      batch.insert(
        'item_stock',
        {
          'ItemID': item['itemId'],
          'ItemCode': item['itemCode'],
          'OutLine': item['outline'],
          'Description': item['description'],
          'CategoryID': item['categoryID'],
          'CategoryCode': item['categoryCode'],
          'Item_Type': item['itemType'],
          'IsStock': item['isstock'] == true ? 1 : 0,
          'Region_ID': item['region_ID'],
          'LocationID': item['location_ID'],
          'LocationCode': item['location_Code'],
          'TotalStockCount': item['totalStockCount'],
          'NewStockCount': 0,
          'Comments': '',
          'UpdatedBy': SharedPrefs().uID,
          'UpdatedOn': DateTime.now().toIso8601String(),
          'UPC': item['upc'],
          'CatchWeight': item['catchWeight'] == true ? 1 : 0,
          'Splitable': item['splittable'] == true ? 1 : 0,
          'UnitID': item['purchaseUnitID'],
          'Unit': item['purchaseUnit'],
          'InventoryUnitID': item['inventoryUnitID'],
          'InventoryUnit': item['inventoryUnit'],
          'StandardUnit': item['standardUnit'],
          'PurchaseUnit_Conversion': item['purchaseUnit_Conversion'],
          'InventoryUnit_Conversion': item['inventoryUnit_Conversion'],
          'RecipeUnitID': item['recipeUnitID'],
          'RecipeUnit': item['recipeUnit'],
          'RecipeUnit_Conversion': item['recipeUnit_Conversion'],
          'Synced': 1,
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
    LoggerData.dataLog("Items saved: ${items.length}");
  }

  // get regions
  Future<List<Map<String, dynamic>>> getAllRegions() async {
    final Database db = await _dbHelper.db;

    final List<Map<String, dynamic>> result =
        await db.query('region_master', orderBy: 'Region_Code ASC');

    LoggerData.dataLog("Fetched regions: ${result.length}");
    return result;
  }

// get locations
  Future<List<Map<String, dynamic>>> getAllLocations() async {
    final Database db = await _dbHelper.db;

    final List<Map<String, dynamic>> result =
        await db.query('items_location', orderBy: 'Location_ID ASC');

    LoggerData.dataLog("Fetched location: ${result.length}");
    return result;
  }

// Insert Items Region (split comma-separated region_id and save one-by-one)
  Future<void> insertItemsRegion(List itemsRegion) async {
    final Database db = await _dbHelper.db;
    final batch = db.batch();

    for (var item in itemsRegion) {
      final int itemId = item['itemid'];

      final rawRegion = item['region_id'];
      if (rawRegion == null) continue;

      final String regionStr = rawRegion.toString().trim();
      if (regionStr.isEmpty) continue;

      // Split by comma, trim, filter empty
      final List<String> regionIds = regionStr
          .split(',')
          .map((e) => e.trim())
          .where((e) => e.isNotEmpty)
          .toList();

      for (final regionIdStr in regionIds) {
        // Convert string to int (safely)
        final int? regionId = int.tryParse(regionIdStr);
        if (regionId == null) {
          LoggerData.dataLog(
              "Skipping invalid regionId '$regionIdStr' for itemId $itemId");
          continue;
        }

        batch.insert(
          'items_region',
          {
            'ItemID': itemId,
            'Region_ID': regionId,
          },
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
    }

    await batch.commit(noResult: true);
    LoggerData.dataLog("ItemsRegion saved: ${itemsRegion.length} items");
  }

// get item list by region & location
  Future<List<OfflineItemStock>> getItemStockList({
    required int regionId,
    required int locationId,
    required String searchText,
  }) async {
    final db = await _dbHelper.db;

    final result = await db.rawQuery(
      '''
SELECT
    is1.ItemID,
    is1.OutLine,
    is1.ItemCode,
    is1.CategoryCode,
    is1.TotalStockCount,
    is1.NewStockCount,
    is1.Synced
FROM item_stock is1
INNER JOIN items_region ir
    ON ir.ItemID = is1.ItemID
WHERE ir.Region_ID = ?
  AND (
        is1.LocationID = ?
        OR (
            is1.LocationID = -1
            AND NOT EXISTS (
                SELECT 1
                FROM item_stock x
                INNER JOIN items_region ir2
                    ON ir2.ItemID = x.ItemID
                WHERE ir2.Region_ID = ?
                  AND x.ItemID = is1.ItemID
                  AND x.LocationID = ?
            )
        )
      )
  AND (
        is1.ItemCode LIKE ?
        OR is1.OutLine LIKE ?
        OR is1.CategoryCode LIKE ?
        OR is1.UPC LIKE ?
      )
''',
      [
        regionId, // ir.Region_ID
        locationId, // is1.LocationID
        regionId, // ir2.Region_ID (subquery)
        locationId, // x.LocationID (subquery)
        '%$searchText%', // ItemCode LIKE
        '%$searchText%', // OutLine LIKE
        '%$searchText%', // CategoryCode LIKE
        '%$searchText%', // UPC LIKE
      ],
    );

    LoggerData.dataLog('Item stock fetched count: ${result.length}');
    LoggerData.dataLog(result.toString());
    return result.map((e) => OfflineItemStock.fromMap(e)).toList();
  }
//   // get item list by region & location
//   Future<List<OfflineItemStock>> getItemStockList({
//     required int regionId,
//     required int locationId,
//     required String searchText,
//   }) async {
//     final db = await _dbHelper.db;

//     final result = await db.rawQuery(
//       '''
// SELECT
//     ItemID,
//     OutLine,
//     ItemCode,
//     CategoryCode,
//     TotalStockCount,
//     NewStockCount,
//     Synced
// FROM item_stock
// WHERE Region_ID = ?
//   AND (
//         LocationID = ?
//         OR (
//             LocationID = -1
//             AND NOT EXISTS (
//                 SELECT 1
//                 FROM item_stock x
//                 WHERE x.Region_ID = item_stock.Region_ID
//                   AND x.ItemID = item_stock.ItemID
//                   AND x.LocationID = ?
//             )
//         )
//       )
//   AND (
//         ItemCode LIKE ?
//         OR OutLine LIKE ?
//         OR CategoryCode LIKE ?
//         OR UPC LIKE ?
//       )
// ''',
//       [
//         regionId,
//         locationId,
//         locationId, // <-- Add this
//         '%$searchText%',
//         '%$searchText%',
//         '%$searchText%',
//         '%$searchText%',
//       ],
//     );
//     LoggerData.dataLog('Item stock fetched count: ${result.length}');
//     LoggerData.dataLog(result.toString());
//     return result.map((e) => OfflineItemStock.fromMap(e)).toList();
//   }
//   Future<List<OfflineItemStock>> getItemStockList({
//     required int regionId,
//     required int locationId,
//     required String searchText,
//   }) async {
//     final db = await _dbHelper.db;

//     const query = '''
// SELECT
//     ItemID,
//     OutLine,
//     ItemCode,
//     CategoryCode,
//     TotalStockCount,
//     NewStockCount,
//     Synced
// FROM item_stock
// WHERE Region_ID = ?
//   AND (LocationID = ? OR LocationID = -1)
//   AND (
//       ItemCode LIKE ?
//       OR OutLine LIKE ?
//       OR CategoryCode LIKE ?
//       OR UPC LIKE ?
//   )
// ''';

//     final args = [
//       regionId,
//       locationId,
//       '%$searchText%',
//       '%$searchText%',
//       '%$searchText%',
//       '%$searchText%',
//     ];

//     LoggerData.dataLog('================ GET ITEM STOCK LIST ================');
//     LoggerData.dataLog('SQL Query:\n$query');
//     LoggerData.dataLog('Arguments: $args');

//     // Log equivalent SQL (for debugging only)
//     LoggerData.dataLog('''
// SELECT
//     ItemID,
//     OutLine,
//     ItemCode,
//     CategoryCode,
//     TotalStockCount,
//     NewStockCount,
//     Synced
// FROM item_stock
// WHERE Region_ID = $regionId
//   AND (LocationID = $locationId OR LocationID = -1)
//   AND (
//       ItemCode LIKE '%$searchText%'
//       OR OutLine LIKE '%$searchText%'
//       OR CategoryCode LIKE '%$searchText%'
//       OR UPC LIKE '%$searchText%'
//   );
// ''');

//     final result = await db.rawQuery(query, args);

//     LoggerData.dataLog('Item stock fetched count: ${result.length}');

//     for (final row in result) {
//       LoggerData.dataLog(row.toString());
//     }

//     return result.map((e) => OfflineItemStock.fromMap(e)).toList();
//   }

  // Get single item details by itemId, region & location
  // Future<OfflineItemStock?> getItemDetailsById({
  //   required int itemId,
  //   required int regionId,
  //   required int locationId,
  // }) async {
  //   final db = await _dbHelper.db;

  //   final result = await db.query(
  //     'item_stock',
  //     where:
  //         'ItemID = ? AND Region_ID = ? AND (LocationID = ? OR  LocationID =-1)',
  //     whereArgs: [itemId, regionId, locationId],
  //     limit: 1,
  //   );

  //   if (result.isNotEmpty) {
  //     LoggerData.dataLog('Item stock details : ${result.toString()}');
  //     return OfflineItemStock.fromMap(result.first);
  //   } else {
  //     return null;
  //   }
  // }

  Future<OfflineItemStock?> getItemDetailsById({
    required int itemId,
    required int regionId,
    required int locationId,
  }) async {
    final db = await _dbHelper.db;

    final result = await db.rawQuery(
      '''
SELECT is1.*
FROM item_stock is1
INNER JOIN items_region ir
    ON ir.ItemID = is1.ItemID
WHERE is1.ItemID = ?
  AND ir.Region_ID = ?
  AND (
        is1.LocationID = ?
        OR (
            is1.LocationID = -1
            AND NOT EXISTS (
                SELECT 1
                FROM item_stock x
                INNER JOIN items_region ir2
                    ON ir2.ItemID = x.ItemID
                WHERE ir2.Region_ID = ?
                  AND x.ItemID = is1.ItemID
                  AND x.LocationID = ?
            )
        )
      )
LIMIT 1;
''',
      [
        itemId, // is1.ItemID
        regionId, // ir.Region_ID
        locationId, // is1.LocationID
        regionId, // ir2.Region_ID (subquery)
        locationId, // x.LocationID (subquery)
      ],
    );

    LoggerData.dataLog('''
Executing SQL:
SELECT is1.*
FROM item_stock is1
INNER JOIN items_region ir
    ON ir.ItemID = is1.ItemID
WHERE is1.ItemID = $itemId
  AND ir.Region_ID = $regionId
  AND (
        is1.LocationID = $locationId
        OR (
            is1.LocationID = -1
            AND NOT EXISTS (
                SELECT 1
                FROM item_stock x
                INNER JOIN items_region ir2
                    ON ir2.ItemID = x.ItemID
                WHERE ir2.Region_ID = $regionId
                  AND x.ItemID = is1.ItemID
                  AND x.LocationID = $locationId
            )
        )
      )
LIMIT 1;
''');

    LoggerData.dataLog('Item stock details: $result');

    if (result.isNotEmpty) {
      return OfflineItemStock.fromMap(result.first);
    }

    return null;
  }

// Get concatenated "RegionPrefix - LocationCode" by itemId, regionId & locationId
  Future<String?> getLocationRegionConcatById({
    required int itemId,
    required int regionId,
    required int locationId,
  }) async {
    final db = await _dbHelper.db;

    final result = await db.rawQuery(
      '''
SELECT 
  TRIM(
    CASE 
      WHEN INSTR(rm.Region_Code, ' - ') > 0 
        THEN SUBSTR(rm.Region_Code, 1, INSTR(rm.Region_Code, ' - ') - 1)
      ELSE rm.Region_Code
    END
  ) || ' - ' || COALESCE(il.Location_Code, '') AS concata_location_region
FROM region_master rm
INNER JOIN items_region ir ON ir.Region_ID = rm.Region_ID
LEFT JOIN items_location il ON il.Location_ID = ?
WHERE ir.ItemID = ?
  AND ir.Region_ID = ?
LIMIT 1
''',
      [locationId, itemId, regionId],
    );

    LoggerData.dataLog(
      'getLocationRegionConcatById -> ItemID: $itemId, RegionID: $regionId, LocationID: $locationId',
    );
    LoggerData.dataLog('Query result: $result');

    if (result.isNotEmpty) {
      final value = result.first['concata_location_region'] as String?;
      LoggerData.dataLog('Concatenated value: $value');
      return value;
    }

    LoggerData.dataLog('No matching record found');
    return null;
  }

//   Future<OfflineItemStock?> getItemDetailsById({
//     required int itemId,
//     required int regionId,
//     required int locationId,
//   }) async {
//     final db = await _dbHelper.db;

//     final result = await db.rawQuery(
//       '''
// SELECT *
// FROM item_stock
// WHERE ItemID = ?
//   AND Region_ID = ?
//   AND (
//         LocationID = ?
//         OR (
//             LocationID = -1
//             AND NOT EXISTS (
//                 SELECT 1
//                 FROM item_stock x
//                 WHERE x.Region_ID = item_stock.Region_ID
//                   AND x.ItemID = item_stock.ItemID
//                   AND x.LocationID = ?
//             )
//         )
//       )
// LIMIT 1;
// ''',
//       [
//         itemId,
//         regionId,
//         locationId,
//         locationId,
//       ],
//     );

//     LoggerData.dataLog('''
// Executing SQL:
// SELECT *
// FROM item_stock
// WHERE ItemID = $itemId
//   AND Region_ID = $regionId
//   AND (
//         LocationID = $locationId
//         OR (
//             LocationID = -1
//             AND NOT EXISTS (
//                 SELECT 1
//                 FROM item_stock x
//                 WHERE x.Region_ID = item_stock.Region_ID
//                   AND x.ItemID = item_stock.ItemID
//                   AND x.LocationID = $locationId
//             )
//         )
//       )
// LIMIT 1;
// ''');

//     LoggerData.dataLog('Item stock details: $result');

//     if (result.isNotEmpty) {
//       return OfflineItemStock.fromMap(result.first);
//     }

//     return null;
//   }
//   Future<OfflineItemStock?> getItemDetailsById({
//     required int itemId,
//     required int regionId,
//     required int locationId,
//   }) async {
//     final db = await _dbHelper.db;

//     const whereClause =
//         'ItemID = ? AND Region_ID = ? AND (LocationID = ? OR LocationID = -1)';

//     final whereArgs = [
//       itemId,
//       regionId,
//       locationId,
//     ];

//     LoggerData.dataLog('================ GET ITEM DETAILS ================');
//     LoggerData.dataLog('Table: item_stock');
//     LoggerData.dataLog('Where: $whereClause');
//     LoggerData.dataLog('Args: $whereArgs');

//     // Equivalent SQL for debugging
//     LoggerData.dataLog('''
// SELECT *
// FROM item_stock
// WHERE ItemID = $itemId
//   AND Region_ID = $regionId
//   AND (LocationID = $locationId OR LocationID = -1)
// LIMIT 1;
// ''');

//     final result = await db.query(
//       'item_stock',
//       where: whereClause,
//       whereArgs: whereArgs,
//       limit: 1,
//     );

//     LoggerData.dataLog('Query Result: $result');

//     if (result.isNotEmpty) {
//       return OfflineItemStock.fromMap(result.first);
//     }

//     return null;
//   }

  // Future<void> updateItemStockQuantity({
  //   required int itemId,
  //   required int regionId,
  //   required int locationId,
  //   required double quantity,
  //   required String comments,
  // }) async {
  //   final db = await _dbHelper.db;

  //   LoggerData.dataLog('ItemID: $itemId');
  //   LoggerData.dataLog('RegionId: $regionId');
  //   LoggerData.dataLog('LocationID: $locationId');
  //   LoggerData.dataLog('Quantity: $quantity');
  //   LoggerData.dataLog('Comments: $comments');

  //   final rows = await db.update(
  //     'item_stock',
  //     {
  //       'NewStockCount': quantity,
  //       'Comments': comments,
  //       'Synced': 0,
  //       'UpdatedOn': DateTime.now().toIso8601String(),
  //       'UpdatedBy': SharedPrefs().uID,
  //       'LocationID':
  //           locationId == -1 ? SharedPrefs().selectedLocationID : locationId
  //     },
  //     where:
  //         'ItemID = ? AND Region_ID = ? AND (LocationID = ? OR LocationID = -1)',
  //     whereArgs: [itemId, regionId, locationId],
  //   );

  //   LoggerData.dataLog('Rows updated: $rows');

  //   if (rows > 0) {
  //     final updated = await db.query(
  //       'item_stock',
  //       where:
  //           'ItemID = ? AND Region_ID = ? AND (LocationID = ? OR LocationID = -1)',
  //       whereArgs: [itemId, regionId, locationId],
  //     );

  //     LoggerData.dataLog('Updated row data: $updated');
  //   } else {
  //     LoggerData.dataLog('No rows updated for ItemID: $itemId');
  //   }
  // }

  Future<void> updateItemStockQuantity({
    required int itemId,
    required int regionId,
    required int locationId,
    required double quantity,
    required String comments,
    required int? unitSelected,
    required String unitType,
    double? actualWeight,
  }) async {
    final db = await _dbHelper.db;

    LoggerData.dataLog('ItemID: $itemId');
    LoggerData.dataLog('RegionId: $regionId');
    LoggerData.dataLog('LocationID: $locationId');
    LoggerData.dataLog('Quantity: $quantity');
    LoggerData.dataLog('Comments: $comments');
    LoggerData.dataLog('Unit_Selected: $unitSelected');
    LoggerData.dataLog('Unit_Type: $unitType');
    LoggerData.dataLog('ActualWeight: ${actualWeight ?? 0}');

    final rows = await db.rawUpdate(
      '''
UPDATE item_stock
SET
  NewStockCount = ?,
  Comments = ?,
  Synced = 0,
  UpdatedOn = ?,
  UpdatedBy = ?,
  Unit_Selected = ?,
  Unit_Type = ?,
  ActualWeight = ?,
  LocationID = ?
WHERE ItemID = ?
  AND ItemID IN (
        SELECT ItemID FROM items_region WHERE Region_ID = ?
      )
  AND (
        LocationID = ?
        OR (
            LocationID = -1
            AND NOT EXISTS (
                SELECT 1
                FROM item_stock x
                WHERE x.ItemID = item_stock.ItemID
                  AND x.ItemID IN (
                        SELECT ItemID FROM items_region WHERE Region_ID = ?
                      )
                  AND x.LocationID = ?
            )
        )
      )
''',
      [
        quantity, // NewStockCount
        comments, // Comments
        DateTime.now().toIso8601String(), // UpdatedOn
        SharedPrefs().uID, // UpdatedBy
        unitSelected, // Unit_Selected
        unitType, // Unit_Type
        actualWeight ?? 0, // ActualWeight
        locationId == -1
            ? SharedPrefs().selectedLocationID
            : locationId, // LocationID
        itemId, // WHERE ItemID
        regionId, // IN (region)
        locationId, // LocationID = ?
        regionId, // IN (subquery region)
        locationId, // x.LocationID
      ],
    );

    LoggerData.dataLog('Rows updated: $rows');

    if (rows > 0) {
      final updated = await db.rawQuery(
        '''
SELECT *
FROM item_stock
WHERE ItemID = ?
  AND ItemID IN (
        SELECT ItemID FROM items_region WHERE Region_ID = ?
      )
  AND (
        LocationID = ?
        OR (
            LocationID = -1
            AND NOT EXISTS (
                SELECT 1
                FROM item_stock x
                WHERE x.ItemID = item_stock.ItemID
                  AND x.ItemID IN (
                        SELECT ItemID FROM items_region WHERE Region_ID = ?
                      )
                  AND x.LocationID = ?
            )
        )
      )
''',
        [
          itemId,
          regionId,
          locationId,
          regionId,
          locationId,
        ],
      );

      LoggerData.dataLog('Updated row data: $updated');
    } else {
      LoggerData.dataLog('No rows updated for ItemID: $itemId');
    }
  }
  // Future<void> updateItemStockQuantity({
  //   required int itemId,
  //   required int regionId,
  //   required int locationId,
  //   required double quantity,
  //   required String comments,
  //   required int? unitSelected,
  //   required String unitType,
  // }) async {
  //   final db = await _dbHelper.db;

  //   LoggerData.dataLog('ItemID: $itemId');
  //   LoggerData.dataLog('RegionId: $regionId');
  //   LoggerData.dataLog('LocationID: $locationId');
  //   LoggerData.dataLog('Quantity: $quantity');
  //   LoggerData.dataLog('Comments: $comments');
  //   LoggerData.dataLog('Unit_Selected: $unitSelected');
  //   LoggerData.dataLog('Unit_Type: $unitType');

  //   final rows = await db.update(
  //     'item_stock',
  //     {
  //       'NewStockCount': quantity,
  //       'Comments': comments,
  //       'Synced': 0,
  //       'UpdatedOn': DateTime.now().toIso8601String(),
  //       'UpdatedBy': SharedPrefs().uID,
  //       'Unit_Selected': unitSelected,
  //       'Unit_Type': unitType,
  //       'LocationID':
  //           locationId == -1 ? SharedPrefs().selectedLocationID : locationId,
  //     },
  //     where: '''
  //     ItemID = ?
  //     AND Region_ID = ?
  //     AND (
  //       LocationID = ?
  //       OR (
  //         LocationID = -1
  //         AND NOT EXISTS (
  //           SELECT 1
  //           FROM item_stock x
  //           WHERE x.Region_ID = item_stock.Region_ID
  //             AND x.ItemID = item_stock.ItemID
  //             AND x.LocationID = ?
  //         )
  //       )
  //     )
  //   ''',
  //     whereArgs: [
  //       itemId,
  //       regionId,
  //       locationId,
  //       locationId,
  //     ],
  //   );

  //   LoggerData.dataLog('Rows updated: $rows');

  //   if (rows > 0) {
  //     final updated = await db.query(
  //       'item_stock',
  //       where: '''
  //       ItemID = ?
  //       AND Region_ID = ?
  //       AND (
  //         LocationID = ?
  //         OR (
  //           LocationID = -1
  //           AND NOT EXISTS (
  //             SELECT 1
  //             FROM item_stock x
  //             WHERE x.Region_ID = item_stock.Region_ID
  //               AND x.ItemID = item_stock.ItemID
  //               AND x.LocationID = ?
  //           )
  //         )
  //       )
  //     ''',
  //       whereArgs: [
  //         itemId,
  //         regionId,
  //         locationId,
  //         locationId,
  //       ],
  //     );

  //     LoggerData.dataLog('Updated row data: $updated');
  //   } else {
  //     LoggerData.dataLog(
  //       'No rows updated for ItemID: $itemId',
  //     );
  //   }
  // }

  // Future<bool> isItemExists({
  //   required int itemId,
  //   required int regionId,
  //   required int locationId,
  // }) async {
  //   final db = await _dbHelper.db;

  //   final result = await db.query(
  //     'item_stock',
  //     where:
  //         'ItemID = ? AND Region_ID = ? AND (LocationID = ? OR LocationID = -1)',
  //     whereArgs: [itemId, regionId, locationId],
  //     limit: 1,
  //   );

  //   LoggerData.dataLog('isItemExists query result: $result');

  //   return result.isNotEmpty;
  // }
  Future<bool> isItemExists({
    required int itemId,
    required int regionId,
    required int locationId,
  }) async {
    final db = await _dbHelper.db;

    final result = await db.rawQuery(
      '''
SELECT 1
FROM item_stock is1
INNER JOIN items_region ir
    ON ir.ItemID = is1.ItemID
WHERE ir.Region_ID = ?
  AND is1.ItemID = ?
  AND (
        is1.LocationID = ?
        OR (
            is1.LocationID = -1
            AND NOT EXISTS (
                SELECT 1
                FROM item_stock x
                INNER JOIN items_region ir2
                    ON ir2.ItemID = x.ItemID
                WHERE ir2.Region_ID = ?
                  AND x.ItemID = is1.ItemID
                  AND x.LocationID = ?
            )
        )
      )
LIMIT 1
''',
      [regionId, itemId, locationId, regionId, locationId],
    );

    return result.isNotEmpty;
  }

  Future<List<OfflineItemStock>> getUnsyncedItems() async {
    final db = await _dbHelper.db;

    final result = await db.query(
      'item_stock',
      where: 'Synced = ?',
      whereArgs: [0],
    );

    LoggerData.dataLog('Unsynced items count: ${result.length}');
    LoggerData.dataLog(result.toString());

    return result.map((e) => OfflineItemStock.fromMap(e)).toList();
  }

  // Future<List<OfflineItemStock>> getUnsyncedItemsWithRegionAndLocation() async {
  //   final db = await _dbHelper.db;

  //   final result = await db.rawQuery('''
  //   SELECT
  //     item_stock.*,
  //     il.Location_Code as LocationName,
  //     rm.Region_Code as RegionName
  //   FROM item_stock
  //   LEFT JOIN items_location il ON item_stock.LocationID = il.Location_ID
  //   LEFT JOIN region_master rm ON item_stock.Region_ID = rm.Region_ID
  //   WHERE item_stock.Synced = ?
  // ''', [0]);

  //   LoggerData.dataLog('Unsynced items count: ${result.length}');
  //   LoggerData.dataLog(result.toString());

  //   return result.map((e) => OfflineItemStock.fromMap(e)).toList();
  // }
  Future<List<OfflineItemStock>> getUnsyncedItemsWithRegionAndLocation() async {
    final db = await _dbHelper.db;

    final result = await db.rawQuery('''
    SELECT 
      item_stock.*,
      il.Location_Code AS LocationName,
      rm.Region_Code AS RegionName,
      CASE 
        WHEN item_stock.CatchWeight = 1 THEN item_stock.StandardUnit
        ELSE 
          CASE 
          WHEN LOWER(item_stock.Unit_type) = 'inventory' THEN item_stock.InventoryUnit
            ELSE item_stock.Unit
          END
      END AS UnitName
    FROM item_stock
    LEFT JOIN items_location il ON item_stock.LocationID = il.Location_ID
    LEFT JOIN region_master rm ON item_stock.Region_ID = rm.Region_ID
    WHERE item_stock.Synced = ?
  ''', [0]);

    LoggerData.dataLog('Unsynced items count: ${result.length}');
    LoggerData.dataLog(result.toString());

    return result.map((e) => OfflineItemStock.fromMap(e)).toList();
  }
  // Future<void> markItemsAsSynced(List<int> itemIds) async {
  //   final db = await _dbHelper.db;

  //   final batch = db.batch();

  //   for (final id in itemIds) {
  //     batch.update(
  //       'item_stock',
  //       {'Synced': 1},
  //       where: 'ItemID = ?',
  //       whereArgs: [id],
  //     );
  //   }

  //   await batch.commit(noResult: true);

  //   LoggerData.dataLog('Items marked as synced: ${itemIds.length}');
  // }

  Future<void> markItemsAsSynced(List<OfflineItemStock> items) async {
    final db = await _dbHelper.db;
    final batch = db.batch();

    for (final item in items) {
      batch.update(
        'item_stock',
        {'Synced': 1},
        where: 'ItemID = ? AND Region_ID = ? AND LocationID = ?',
        whereArgs: [
          item.itemId,
          item.regionId,
          item.locationId,
        ],
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> deleteTransaction({
    required int itemId,
  }) async {
    final db = await _dbHelper.db;

    final rows = await db.update(
      'item_stock',
      {
        'NewStockCount': 0.0,
        'Synced': 1,
        'Comments': '',
        'UpdatedOn': DateTime.now().toIso8601String(),
        'UpdatedBy': SharedPrefs().uID,
      },
      where: 'ItemID = ?',
      whereArgs: [itemId],
    );

    LoggerData.dataLog(
        'Transaction cleared for ItemID: $itemId, Rows affected: $rows');
  }

  Future<void> insertErrorLog({
    String? exceptionMessage,
    String? stackTrace,
    String? apiUrl,
    String? requestBody,
    required String screenName,
    required String methodName,
  }) async {
    final Database db = await _dbHelper.db;

    await db.insert(
      'error_log',
      {
        'exception_message': exceptionMessage,
        'stack_trace': stackTrace,
        'api_url': apiUrl,
        'request_body': requestBody != null ? jsonEncode(requestBody) : null,
        'screen_name': screenName,
        'method_name': methodName,
        'timestamp': DateTime.now().toIso8601String(),
        'synced': 0,
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    LoggerData.dataLog('Offline error log saved successfully');
  }

// Get ItemID by UPC only
  Future<int?> getItemIdByBarCodeString(String upc) async {
    try {
      final db = await _dbHelper.db;

      // Fetch ALL rows matching the UPC (no limit — UPC may not be unique)
      final result = await db.query(
        'item_stock',
        columns: ['ItemID'],
        where: 'UPC = ?',
        whereArgs: [upc],
      );

      if (result.isEmpty) {
        LoggerData.dataLog('No item found for UPC: $upc');
        return null;
      }

      LoggerData.dataLog(
        'UPC $upc matched ${result.length} row(s): '
        '${result.map((r) => r['ItemID']).toList()}',
      );

      // Try each candidate — isItemExists applies region/location
      // + LocationID = -1 fallback logic
      for (final row in result) {
        final int itemId = row['ItemID'] as int;

        final bool itemExists = await isItemExists(
          itemId: itemId,
          regionId: SharedPrefs().selectedRegionID,
          locationId: SharedPrefs().selectedLocationID,
        );

        if (itemExists) {
          LoggerData.dataLog('Item found for UPC: $upc, ItemID: $itemId');
          return itemId;
        }
      }

      LoggerData.dataLog(
        'UPC $upc matched ${result.length} item(s) '
        'but none in current region/location',
      );
      return null;
    } catch (e, stackTrace) {
      LoggerData.dataLog('Error finding item by UPC: $e');
      LoggerData.dataLog(stackTrace.toString());
      return null;
    }
  }

  Future<int?> getItemIdByBarCodeWithoutRegionAndLocationString(
      String upc) async {
    try {
      final db = await _dbHelper.db;

      // Fetch ALL rows matching the UPC (no limit — UPC may not be unique)
      final result = await db.query(
        'item_stock',
        columns: ['ItemID'],
        where: 'UPC = ?',
        whereArgs: [upc],
      );

      if (result.isEmpty) {
        LoggerData.dataLog('No item found for UPC: $upc');
        return null;
      }

      LoggerData.dataLog(
        'UPC $upc matched ${result.length} row(s): '
        '${result.map((r) => r['ItemID']).toList()}',
      );

      // Just return the first matching ItemID — no region/location check here.
      // Region/location validation is handled separately by the caller
      // (e.g. via checkItemInRegion).
      final int itemId = result.first['ItemID'] as int;

      LoggerData.dataLog('Item found for UPC: $upc, ItemID: $itemId');
      return itemId;
    } catch (e, stackTrace) {
      LoggerData.dataLog('Error finding item by UPC: $e');
      LoggerData.dataLog(stackTrace.toString());
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getUnsyncedErrorLogs() async {
    final db = await _dbHelper.db;

    return await db.query(
      'error_log',
      where: 'synced = ?',
      whereArgs: [0],
    );
  }

  Future<void> markErrorLogSynced(int id) async {
    final db = await _dbHelper.db;

    await db.update(
      'error_log',
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> queryAndPrintItemData(int itemId, String newDescription) async {
    final db = await _dbHelper.db;

    // Update using raw query
    int result = await db.rawUpdate(
        'UPDATE item_stock SET Description = ? WHERE ItemID = ?',
        [newDescription, itemId]);

    // Print update status
    LoggerData.dataLog(' Update result: $result row(s) affected');

    // Query and LoggerData.dataLog the data
    List<Map<String, dynamic>> data = await db
        .rawQuery('SELECT * FROM item_stock WHERE ItemID = ?', [itemId]);

    if (data.isNotEmpty) {
      LoggerData.dataLog(' Updated Record:');
      LoggerData.dataLog('═══════════════════════════════════');
      data.first.forEach((key, value) {
        LoggerData.dataLog('$key: $value');
      });
      LoggerData.dataLog('═══════════════════════════════════');
    } else {
      LoggerData.dataLog('No record found for ItemID: $itemId');
    }
  }

  // // Get locations for dashboard by region
  // Future<List<Map<String, dynamic>>> getLocationsForDashboard() async {
  //   final Database db = await _dbHelper.db;

  //   final List<Map<String, dynamic>> result = await db.query(
  //     'items_location',
  //     where: 'Region_Id = ?',
  //     whereArgs: [SharedPrefs().selectedRegionID],
  //     orderBy: 'Default_Location DESC, Location_Code ASC',
  //   );

  //   LoggerData.dataLog("Fetched locations for dashboard: ${result.length}");
  //   return result;
  // }
  // Get locations for dashboard by region
  Future<List<Map<String, dynamic>>> getLocationsForDashboard() async {
    final Database db = await _dbHelper.db;

    final int regionId = SharedPrefs().selectedRegionID;

    // Build the raw SQL query
    final String query = '''
    SELECT * FROM items_location 
    WHERE Region_Id = $regionId 
    ORDER BY Default_Location DESC, Location_Code ASC
  ''';
    LoggerData.dataLog(
        "#################################################################################");
    // Print the full query
    LoggerData.dataLog("Executing SQL Query: $query");

    // Execute raw query
    final List<Map<String, dynamic>> result = await db.rawQuery(query);

    LoggerData.dataLog("Fetched locations for dashboard: ${result.length}");
    LoggerData.dataLog("Query result: $result");
    LoggerData.dataLog(
        "#################################################################################");
    return result;
  }

  Future<List<Map<String, dynamic>>> unitDropDown({
    required int itemId,
    required int locationId,
  }) async {
    final db = await _dbHelper.db;

    final result = await db.query(
      'item_stock',
      columns: [
        'UnitID',
        'Unit',
        'InventoryUnit',
        'InventoryUnitID',
      ],
      where: 'ItemID = ? AND LocationID = ?',
      whereArgs: [
        itemId,
        locationId,
      ],
    );

    LoggerData.dataLog(
      'Unit dropdown data: $result',
    );

    return result;
  }

  Future<Map<String, dynamic>?> getFirstRegion() async {
    final Database db = await _dbHelper.db;

    final result = await db.query(
      'region_master',
      orderBy: 'Region_ID ASC',
      limit: 1,
    );

    LoggerData.dataLog("First region from DB: $result");
    return result.isNotEmpty ? result.first : null;
  }

  Future<int> checkItemInRegion({required int itemId}) async {
    try {
      final db = await _dbHelper.db;

      final regionId = SharedPrefs().selectedRegionID;

      final count = Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM items_region WHERE ItemID = ? AND Region_ID = ?',
              [itemId, regionId],
            ),
          ) ??
          0;

      LoggerData.dataLog(
        'checkItemInRegion -> itemId=$itemId, regionId=$regionId, count=$count',
      );

      return count;
    } catch (e, stackTrace) {
      LoggerData.dataLog('checkItemInRegion error: $e');
      LoggerData.dataLog(stackTrace.toString());
      return 0;
    }
  }

  /// Get ItemCode for a given ItemID from item_stock.
  /// Ignores region/location — used for building region-mismatch messages.
  Future<String?> getItemCodeById(int itemId) async {
    try {
      final db = await _dbHelper.db;

      final result = await db.query(
        'item_stock',
        columns: ['ItemCode'],
        where: 'ItemID = ?',
        whereArgs: [itemId],
        limit: 1,
      );

      if (result.isEmpty) {
        LoggerData.dataLog('getItemCodeById -> no match for ItemID: $itemId');
        return null;
      }

      final code = result.first['ItemCode']?.toString();
      LoggerData.dataLog('getItemCodeById -> ItemID=$itemId, ItemCode=$code');
      return code;
    } catch (e, stackTrace) {
      LoggerData.dataLog('getItemCodeById error: $e');
      LoggerData.dataLog(stackTrace.toString());
      return null;
    }
  }
}
