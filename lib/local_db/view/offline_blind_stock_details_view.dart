import 'dart:convert';

import 'package:eyvo_v3/app/app_prefs.dart';
import 'package:eyvo_v3/app/sizes_helper.dart';
import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/constants.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/strings_manager.dart';
import 'package:eyvo_v3/core/resources/styles_manager.dart';
import 'package:eyvo_v3/core/utils.dart';
import 'package:eyvo_v3/core/widgets/button.dart';
import 'package:eyvo_v3/core/widgets/common_app_bar.dart';
import 'package:eyvo_v3/core/widgets/progress_indicator.dart';
import 'package:eyvo_v3/local_db/dao/offline_db_dao.dart';
import 'package:eyvo_v3/local_db/model/offline_item_stock_model.dart';

import 'package:eyvo_v3/log_data.dart/logger_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class OfflineBlindStockDetailsView extends StatefulWidget {
  final int itemId;
  const OfflineBlindStockDetailsView({super.key, required this.itemId});

  @override
  State<OfflineBlindStockDetailsView> createState() =>
      _OfflineBlindStockDetailsViewState();
}

class _OfflineBlindStockDetailsViewState
    extends State<OfflineBlindStockDetailsView> {
  final TextEditingController _physicalQtyController = TextEditingController();
  final TextEditingController _commmentsController = TextEditingController();
  final TextEditingController _actualWeightController = TextEditingController();
  final FocusNode physicalQtyFocusNode = FocusNode();

  final OfflineDBDao _offlineDBDao = OfflineDBDao();
  bool catchWeight = false;
  OfflineItemStock? item;
  bool isLoading = false;
  bool isError = false;
  String errorText = AppStrings.somethingWentWrong;
  String? itemType;
// Unit dropdown variables
  List<Map<String, dynamic>> unitList = [];
  String? selectedUnitType;
  bool splittable = false;
  String actualWeightLabel = "";
  String? selectedUnit;
  int? selectedUnitId;
  final FocusNode actualWeightFocusNode = FocusNode();
  String? concataLocationRegion;

  // String selectedUnitType = 'purchase';
  @override
  void initState() {
    super.initState();
    _physicalQtyController.text = formatQuantityString(1.0);
    _actualWeightController.text = formatQuantityString(1.0);
    fetchItemDetails();
    // physicalQtyFocusNode.addListener(() {
    //   if (!physicalQtyFocusNode.hasFocus) {
    //     _formatPhysicalQty();
    //   }
    // });
    // actualWeightFocusNode.addListener(() {
    //   if (!actualWeightFocusNode.hasFocus) {
    //     _performActualWeightActionOnFocusChanged();
    //   }
    // });
    physicalQtyFocusNode.addListener(() {
      if (!physicalQtyFocusNode.hasFocus) {
        _formatPhysicalQty();
      }
    });

    actualWeightFocusNode.addListener(() {
      if (!actualWeightFocusNode.hasFocus) {
        _performActualWeightActionOnFocusChanged();
      }
    });
  }

  @override
  void dispose() {
    _physicalQtyController.dispose();
    _commmentsController.dispose();
    physicalQtyFocusNode.dispose();
    _actualWeightController.dispose();
    actualWeightFocusNode.dispose();
    super.dispose();
  }

  void _performActualWeightActionOnFocusChanged() {
    if (_actualWeightController.text.trim().isNotEmpty) {
      final double weight = parseQuantityString(_actualWeightController.text);
      _actualWeightController.text = formatQuantityString(weight);
    } else {
      _actualWeightController.text = formatQuantityString(1.0);
    }
  }

  String getFormattedPriceStringPricetwo(double price) {
    var priceFormatter =
        NumberFormat.currency(locale: 'en_US', symbol: '', decimalDigits: 2);
    return priceFormatter.format(price);
  }

  void _setUnitList(OfflineItemStock item) {
    unitList.clear();

    final String? purchaseUnit = item.purchaseUnit?.trim();
    final String? inventoryUnit = item.inventoryUnit?.trim();

    final bool isSameUnit = purchaseUnit != null &&
        purchaseUnit.isNotEmpty &&
        inventoryUnit != null &&
        inventoryUnit.isNotEmpty &&
        purchaseUnit.toLowerCase() == inventoryUnit.toLowerCase();

    // splittable == false → ONLY purchase unit
    if (item.splittable != true) {
      if (item.purchaseUnitID != null &&
          purchaseUnit != null &&
          purchaseUnit.isNotEmpty) {
        unitList.add({
          'id': item.purchaseUnitID,
          'name': purchaseUnit,
          'type': 'purchase',
        });
      }
      LoggerData.dataLog('Offline Unit List (non-splittable): $unitList');
    } else if (isSameUnit) {
      // purchase == inventory → only purchase
      if (item.purchaseUnitID != null) {
        unitList.add({
          'id': item.purchaseUnitID,
          'name': purchaseUnit,
          'type': 'purchase',
        });
      }
    } else {
      // 1st purchase
      if (item.purchaseUnitID != null &&
          purchaseUnit != null &&
          purchaseUnit.isNotEmpty) {
        unitList.add({
          'id': item.purchaseUnitID,
          'name': purchaseUnit,
          'type': 'purchase',
        });
      }
      // 2nd inventory
      if (item.inventoryUnitID != null &&
          inventoryUnit != null &&
          inventoryUnit.isNotEmpty) {
        unitList.add({
          'id': item.inventoryUnitID,
          'name': inventoryUnit,
          'type': 'inventory',
        });
      }
    }

    if (unitList.isNotEmpty) {
      selectedUnit = unitList.first['name']?.toString();
      selectedUnitId = unitList.first['id'] as int?;
      selectedUnitType = unitList.first['type']?.toString() ?? 'purchase';
    } else {
      selectedUnit = null;
      selectedUnitId = null;
      selectedUnitType = 'purchase';
    }

    LoggerData.dataLog('Offline Unit List: $unitList');
    LoggerData.dataLog('Selected Unit: $selectedUnit');
    LoggerData.dataLog('Selected Unit ID: $selectedUnitId');
    LoggerData.dataLog('Selected Unit Type: $selectedUnitType');
  }

  // Future<void> fetchItemDetails() async {
  //   setState(() => isLoading = true);

  //   try {
  //     final regionId =
  //         // SharedPrefs().isItemScanned
  //         //     ? SharedPrefs().scannedRegionID
  //         //     :
  //         SharedPrefs().selectedRegionID;

  //     final locationId =
  //         // SharedPrefs().isItemScanned
  //         //     ? SharedPrefs().scannedLocationID
  //         //     :
  //         SharedPrefs().selectedLocationID;

  //     final result = await _offlineDBDao.getItemDetailsById(
  //       itemId: widget.itemId,
  //       regionId: regionId,
  //       locationId: locationId,
  //     );

  //     if (result != null) {
  //       setState(() {
  //         item = result;
  //         itemType = result.itemType;

  //         // Read flags from model
  //         catchWeight = result.catchWeight ?? false;
  //         splittable = result.splittable ?? false;
  //         actualWeightLabel = result.actualWeightLabel ?? '';

  //         // Build unit list based on splittable + purchase/inventory units
  //         _setUnitList(result);

  //         final double savedQty =
  //             (result.newStockCount == null || result.newStockCount == 0.0)
  //                 ? 1.0
  //                 : result.newStockCount!;

  //         // ✅ FIX: Handle catchWeight vs non-catchWeight properly
  //         if (catchWeight) {
  //           // For catch weight items, savedQty represents Actual Weight
  //           _actualWeightController.text = formatQuantityString(savedQty);
  //           _physicalQtyController.text = formatQuantityString(1.0);
  //         } else {
  //           // For normal items, savedQty represents Physical Quantity
  //           _physicalQtyController.text = formatQuantityString(savedQty);
  //           _actualWeightController.text = formatQuantityString(1.0);
  //         }
  //       });
  //     } else {
  //       await _offlineDBDao.insertErrorLog(
  //         exceptionMessage: 'OFFLINE - Item not found in offline database',
  //         stackTrace: '',
  //         apiUrl: 'SQLite - getItemDetailsById',
  //         requestBody: jsonEncode({
  //           'itemId': widget.itemId,
  //           'regionId': regionId,
  //           'locationId': locationId,
  //         }),
  //         screenName: 'OfflineBlindStockDetailsView',
  //         methodName: 'fetchItemDetails',
  //       );

  //       setState(() {
  //         isError = true;
  //         errorText = "Item not found in offline data";
  //       });
  //     }
  //   } catch (e, stackTrace) {
  //     await _offlineDBDao.insertErrorLog(
  //       exceptionMessage: e.toString(),
  //       stackTrace: stackTrace.toString(),
  //       apiUrl: 'OFFLINE - SQLite - getItemDetailsById',
  //       requestBody: jsonEncode({
  //         'itemId': widget.itemId,
  //         'regionId': SharedPrefs().isItemScanned
  //             ? SharedPrefs().scannedRegionID
  //             : SharedPrefs().selectedRegionID,
  //         'locationId': SharedPrefs().isItemScanned
  //             ? SharedPrefs().scannedLocationID
  //             : SharedPrefs().selectedLocationID,
  //       }),
  //       screenName: 'OfflineBlindStockDetailsView',
  //       methodName: 'fetchItemDetails',
  //     );

  //     LoggerData.dataLog('fetchItemDetails Exception: $e');
  //     LoggerData.dataLog(stackTrace.toString());

  //     setState(() {
  //       isError = true;
  //       errorText = AppStrings.somethingWentWrong;
  //     });
  //   } finally {
  //     setState(() => isLoading = false);
  //   }
  // }
  Future<void> fetchItemDetails() async {
    setState(() => isLoading = true);

    try {
      final regionId =
          // SharedPrefs().isItemScanned
          //     ? SharedPrefs().scannedRegionID
          //     :
          SharedPrefs().selectedRegionID;

      final locationId =
          // SharedPrefs().isItemScanned
          //     ? SharedPrefs().scannedLocationID
          //     :
          SharedPrefs().selectedLocationID;

      final result = await _offlineDBDao.getItemDetailsById(
        itemId: widget.itemId,
        regionId: regionId,
        locationId: locationId,
      );

      if (result != null) {
        // ✅ Fetch concatenated Region - Location string
        String? concatValue;
        try {
          concatValue = await _offlineDBDao.getLocationRegionConcatById(
            itemId: widget.itemId,
            regionId: regionId,
            locationId: locationId,
          );
        } catch (e, stackTrace) {
          LoggerData.dataLog('getLocationRegionConcatById Exception: $e');
          LoggerData.dataLog(stackTrace.toString());
        }

        setState(() {
          item = result;
          itemType = result.itemType;
          concataLocationRegion = concatValue;

          // Read flags from model
          catchWeight = result.catchWeight ?? false;
          splittable = result.splittable ?? false;
          actualWeightLabel = result.actualWeightLabel ?? '';

          // Build unit list based on splittable + purchase/inventory units
          _setUnitList(result);

          final double savedQty =
              (result.newStockCount == null || result.newStockCount == 0.0)
                  ? 1.0
                  : result.newStockCount!;

          if (catchWeight) {
            _actualWeightController.text = formatQuantityString(savedQty);
            _physicalQtyController.text = formatQuantityString(1.0);
          } else {
            _physicalQtyController.text = formatQuantityString(savedQty);
            _actualWeightController.text = formatQuantityString(1.0);
          }
        });
      } else {
        await _offlineDBDao.insertErrorLog(
          exceptionMessage: 'OFFLINE - Item not found in offline database',
          stackTrace: '',
          apiUrl: 'SQLite - getItemDetailsById',
          requestBody: jsonEncode({
            'itemId': widget.itemId,
            'regionId': regionId,
            'locationId': locationId,
          }),
          screenName: 'OfflineBlindStockDetailsView',
          methodName: 'fetchItemDetails',
        );

        setState(() {
          isError = true;
          errorText = "Item not found in offline data";
        });
      }
    } catch (e, stackTrace) {
      await _offlineDBDao.insertErrorLog(
        exceptionMessage: e.toString(),
        stackTrace: stackTrace.toString(),
        apiUrl: 'OFFLINE - SQLite - getItemDetailsById',
        requestBody: jsonEncode({
          'itemId': widget.itemId,
          'regionId': SharedPrefs().isItemScanned
              ? SharedPrefs().scannedRegionID
              : SharedPrefs().selectedRegionID,
          'locationId': SharedPrefs().isItemScanned
              ? SharedPrefs().scannedLocationID
              : SharedPrefs().selectedLocationID,
        }),
        screenName: 'OfflineBlindStockDetailsView',
        methodName: 'fetchItemDetails',
      );

      LoggerData.dataLog('fetchItemDetails Exception: $e');
      LoggerData.dataLog(stackTrace.toString());

      setState(() {
        isError = true;
        errorText = AppStrings.somethingWentWrong;
      });
    } finally {
      setState(() => isLoading = false);
    }
  }

  void _formatPhysicalQty() {
    if (_physicalQtyController.text.trim().isEmpty) {
      _physicalQtyController.text = formatQuantityString(1.0);
      return;
    }
    final double value = parseQuantityString(_physicalQtyController.text);
    _physicalQtyController.text = formatQuantityString(value);
  }

  Future<void> updateBlindStockOffline({
    required int itemId,
    required double adjustQuantity,
    required String comments,
    required int? selectedUnitId,
    required String? selectedUnitType,
    required double actualWeight,
  }) async {
    try {
      final int regionId = SharedPrefs().selectedRegionID;

      final int locationId = SharedPrefs().selectedLocationID;
      final int? unitIdToSave = catchWeight ? 0 : selectedUnitId;
      final String unitTypeToSave =
          catchWeight ? 'purchase' : (selectedUnitType ?? 'purchase');
      final double safeQty = catchWeight
          ? double.tryParse(
                  actualWeight.toString().replaceAll(',', '').trim()) ??
              0.0
          : double.tryParse(
                  adjustQuantity.toString().replaceAll(',', '').trim()) ??
              0.0;

      final double safeWeight =
          double.tryParse(actualWeight.toString().replaceAll(',', '').trim()) ??
              0.0;
      await _offlineDBDao.updateItemStockQuantity(
        itemId: itemId,
        regionId: regionId,
        locationId: locationId,
        // quantity: adjustQuantity,
        quantity: safeQty,
        comments: comments,
        unitSelected: unitIdToSave,
        unitType: unitTypeToSave,
        actualWeight: safeWeight,
      );

      LoggerData.dataLog(
        'OFFLINE BLIND STOCK UPDATE SUCCESS '
        '| Unit ID: $unitIdToSave '
        '| Unit Type: $unitTypeToSave} '
        '| Actual Weight: $actualWeight',
      );
    } catch (e, stackTrace) {
      await _offlineDBDao.insertErrorLog(
        exceptionMessage: e.toString(),
        stackTrace: stackTrace.toString(),
        apiUrl: 'OFFLINE - SQLite - updateItemStockQuantity',
        requestBody: jsonEncode({
          'itemId': itemId,
          'regionId': SharedPrefs().isItemScanned
              ? SharedPrefs().scannedRegionID
              : SharedPrefs().selectedRegionID,
          'locationId': SharedPrefs().isItemScanned
              ? SharedPrefs().scannedLocationID
              : SharedPrefs().selectedLocationID,
          'adjustQuantity': adjustQuantity,
          'comments': comments,
          'Unit_Selected': catchWeight ? 0 : selectedUnitId,
          'Unit_Type': catchWeight ? 'purchase' : selectedUnitType,
          'ActualWeight': actualWeight,
        }),
        screenName: 'OfflineBlindStockDetailsView',
        methodName: 'updateBlindStockOffline',
      );

      LoggerData.dataLog('Offline blind stock update failed: $e');
      LoggerData.dataLog(stackTrace.toString());

      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    LoggerData.dataLog(
      'UI → catchWeight=$catchWeight, splittable=$splittable, '
      'unitList=$unitList, selectedUnitId=$selectedUnitId',
    );
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.sizeOf(context).width;

    return Scaffold(
      backgroundColor: ColorManager.primary,
      appBar: AppBar(
        backgroundColor: ColorManager.grey,
        toolbarHeight: 56,
        leadingWidth: 40,
        titleSpacing: 0,
        leading: IconButton(
          icon: SizedBox(
            width: 18,
            height: 18,
            child: Image.asset(
              ImageAssets.backButton,
              color: ColorManager.white,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Blind Stock Details',
              style: getBoldStyle(
                color: ColorManager.white,
                fontSize: FontSize.s20,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ColorManager.white,
                    width: 1,
                  ),
                ),
                child: Text(
                  'OFFLINE MODE',
                  style: getSemiBoldStyle(
                    color: ColorManager.white,
                    fontSize: FontSize.s12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CustomProgressIndicator())
          : isError
              //    ? Center(child: Text(errorText))

              ? Padding(
                  padding: const EdgeInsets.all(18.0),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: ColorManager.white,
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Image.asset(
                            ImageAssets.noRecordFoundIcon,
                            width: displayWidth(context) * 0.5,
                          ),
                          Text(
                            errorText,
                            style: getRegularStyle(
                              color: ColorManager.lightGrey,
                              fontSize: FontSize.s17,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              : SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Container(
                      decoration: BoxDecoration(
                        color: ColorManager.white,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          // Blue container section - takes full width
                          Container(
                            width: double.infinity,
                            color: ColorManager.highlightColor,
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Region - Location concatenated value
                                if (concataLocationRegion != null &&
                                    concataLocationRegion!
                                        .trim()
                                        .isNotEmpty) ...[
                                  Text(
                                    concataLocationRegion!,
                                    style: getSemiBoldStyle(
                                      color: ColorManager.black,
                                      fontSize: FontSize.s14,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                ],
                                Text(
                                  item!.outLine!,
                                  style: getBoldStyle(
                                    color: ColorManager.darkBlue,
                                    fontSize: FontSize.s22_5,
                                  ),
                                ),
                                const SizedBox(height: 15),
                                RichText(
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  text: TextSpan(
                                    text: AppStrings.itemCodeDetails,
                                    style: getSemiBoldStyle(
                                      color: ColorManager.black,
                                      fontSize: FontSize.s14,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "${item!.itemCode}",
                                        style: getRegularStyle(
                                          color: ColorManager.black,
                                          fontSize: FontSize.s14,
                                        ),
                                      )
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 15),
                                RichText(
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  text: TextSpan(
                                    text: AppStrings.categoryCodeDetails,
                                    style: getSemiBoldStyle(
                                      color: ColorManager.black,
                                      fontSize: FontSize.s14,
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "${item!.categoryCode}",
                                        style: getRegularStyle(
                                          color: ColorManager.black,
                                          fontSize: FontSize.s14,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 15),
                                Divider(
                                  height: 0.2,
                                  thickness: 0.4,
                                  color: ColorManager.lightBlue2,
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  item!.description!,
                                  style: getRegularStyle(
                                    color: ColorManager.black,
                                    fontSize: FontSize.s14,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Divider(
                                  height: 0.2,
                                  thickness: 0.4,
                                  color: ColorManager.lightBlue2,
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 25),

                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: SizedBox(
                              width: screenWidth - 80,
                              child: Row(
                                children: [
                                  // Physical Quantity field
                                  Expanded(
                                    flex: 1,
                                    child: SizedBox(
                                      height: 50,
                                      child: TextField(
                                        focusNode: physicalQtyFocusNode,
                                        controller: _physicalQtyController,
                                        style: getSemiBoldStyle(
                                          color: ColorManager.black,
                                          fontSize: FontSize.s16,
                                        ),
                                        keyboardType: const TextInputType
                                            .numberWithOptions(decimal: true),
                                        inputFormatters: [
                                          DecimalTextInputFormatter(
                                            decimalPlaces: SharedPrefs()
                                                .decimalplacesquantity,
                                            minValue: 0.0,
                                            maxValue: double.infinity,
                                          ),
                                          LengthLimitingTextInputFormatter(
                                            AppConstants
                                                .maxCharactersForQuantity,
                                          ),
                                        ],
                                        onEditingComplete: _formatPhysicalQty,
                                        decoration: InputDecoration(
                                          contentPadding:
                                              const EdgeInsets.symmetric(
                                                  horizontal: 16, vertical: 12),
                                          labelText: catchWeight &&
                                                  (item?.purchaseUnit
                                                          ?.trim()
                                                          .isNotEmpty ??
                                                      false)
                                              ? "Physical Qty (${item!.purchaseUnit})"
                                              : "Physical Qty",
                                          floatingLabelBehavior:
                                              FloatingLabelBehavior.always,
                                          floatingLabelStyle: getSemiBoldStyle(
                                            color: ColorManager.lightGrey1,
                                            fontSize: FontSize.s16,
                                          ),
                                          border: OutlineInputBorder(
                                            borderRadius:
                                                BorderRadius.circular(4),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  if (catchWeight) ...[
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: SizedBox(
                                        height: 50,
                                        child: Stack(
                                          children: [
                                            TextField(
                                              controller:
                                                  _actualWeightController,
                                              focusNode: actualWeightFocusNode,
                                              style: getSemiBoldStyle(
                                                color: ColorManager.black,
                                                fontSize: FontSize.s17,
                                              ),
                                              keyboardType: const TextInputType
                                                  .numberWithOptions(
                                                  decimal: true),
                                              inputFormatters: [
                                                DecimalTextInputFormatter(
                                                  decimalPlaces: SharedPrefs()
                                                      .decimalplacesquantity,
                                                  minValue: 0.0,
                                                  maxValue: double.infinity,
                                                ),
                                              ],
                                              decoration: InputDecoration(
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                  horizontal: 12,
                                                  vertical: 10,
                                                ),
                                                labelText: (item?.standardUnit
                                                            ?.trim()
                                                            .isNotEmpty ??
                                                        false)
                                                    ? "Actual Weight (${item!.standardUnit})"
                                                    : "Actual Weight",
                                                floatingLabelBehavior:
                                                    FloatingLabelBehavior
                                                        .always,
                                                floatingLabelStyle:
                                                    getSemiBoldStyle(
                                                  color:
                                                      ColorManager.lightGrey1,
                                                  fontSize: FontSize.s18,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                    screenHeight * 0.01,
                                                  ),
                                                ),
                                                filled: true,
                                                fillColor: Colors.white,
                                              ),
                                            ),
                                            Positioned(
                                              right: 0,
                                              top: 0,
                                              child: CustomPaint(
                                                size: const Size(12, 12),
                                                painter: _RedTrianglePainter(),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                  // Show unit field ONLY when catchWeight == false
                                  if (!catchWeight) ...[
                                    const SizedBox(width: 10),
                                    Expanded(
                                      flex: 1,
                                      child: SizedBox(
                                        height: 50,
                                        child: splittable
                                            // splittable == true → enabled dropdown
                                            ? DropdownButtonFormField<int>(
                                                value: selectedUnitId,
                                                isExpanded: true,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 12,
                                                          vertical: 10),
                                                  labelText: 'Select Unit',
                                                  floatingLabelBehavior:
                                                      FloatingLabelBehavior
                                                          .always,
                                                  floatingLabelStyle:
                                                      getSemiBoldStyle(
                                                    color:
                                                        ColorManager.lightGrey1,
                                                    fontSize: FontSize.s16,
                                                  ),
                                                  border:
                                                      const OutlineInputBorder(),
                                                ),
                                                icon: const Icon(
                                                    Icons.arrow_drop_down),
                                                items: unitList.map((unit) {
                                                  return DropdownMenuItem<int>(
                                                    value: unit['id'] as int,
                                                    child: Text(
                                                      unit['name']
                                                              ?.toString() ??
                                                          '',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: getSemiBoldStyle(
                                                        color:
                                                            ColorManager.black,
                                                        fontSize: FontSize.s16,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                                onChanged: (int? value) {
                                                  if (value == null) return;
                                                  final selected = unitList
                                                      .firstWhere((unit) =>
                                                          unit['id'] == value);
                                                  setState(() {
                                                    selectedUnitId =
                                                        selected['id'] as int?;
                                                    selectedUnit =
                                                        selected['name']
                                                            ?.toString();
                                                    selectedUnitType =
                                                        selected['type']
                                                            ?.toString();
                                                  });
                                                },
                                              )
                                            //  splittable == false → disabled, only purchase unit
                                            : DropdownButtonFormField<int>(
                                                value: selectedUnitId,
                                                isExpanded: true,
                                                onChanged: null,
                                                decoration: InputDecoration(
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 12,
                                                          vertical: 10),
                                                  labelText: 'Select Unit',
                                                  floatingLabelBehavior:
                                                      FloatingLabelBehavior
                                                          .always,
                                                  floatingLabelStyle:
                                                      getSemiBoldStyle(
                                                    color:
                                                        ColorManager.lightGrey1,
                                                    fontSize: FontSize.s16,
                                                  ),
                                                  border:
                                                      const OutlineInputBorder(),
                                                  filled: true,
                                                  fillColor: ColorManager.grey
                                                      .withOpacity(0.1),
                                                ),
                                                icon: Icon(
                                                    Icons.arrow_drop_down,
                                                    color: ColorManager
                                                        .lightGrey1),
                                                items: unitList.map((unit) {
                                                  return DropdownMenuItem<int>(
                                                    value: unit['id'] as int,
                                                    child: Text(
                                                      unit['name']
                                                              ?.toString() ??
                                                          '',
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: getSemiBoldStyle(
                                                        color:
                                                            ColorManager.black,
                                                        fontSize: FontSize.s16,
                                                      ),
                                                    ),
                                                  );
                                                }).toList(),
                                              ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                          if (catchWeight &&
                              item != null &&
                              item!.purchaseUnitID != null)
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 18),
                              child: SizedBox(
                                width: screenWidth - 80,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Row(
                                    children: [
                                      const Expanded(child: SizedBox()),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          "1 ${item!.purchaseUnit} = ${formatQuantityString(item!.purchaseUnitConversion)} ${item!.standardUnit}",
                                          style: getSemiBoldStyle(
                                            color: ColorManager.lightGrey2,
                                            fontSize: FontSize.s12,
                                          ),
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          // const SizedBox(height: 20),
                          // if (catchWeight) ...[
                          //   const SizedBox(height: 20),
                          //   Center(
                          //     child: SizedBox(
                          //       width: screenWidth - 80,
                          //       height: 50,
                          //       child: Stack(
                          //         children: [
                          //           TextField(
                          //             controller: _actualWeightController,
                          //             focusNode: actualWeightFocusNode,
                          //             style: getSemiBoldStyle(
                          //               color: ColorManager.black,
                          //               fontSize: FontSize.s17,
                          //             ),
                          //             keyboardType:
                          //                 const TextInputType.numberWithOptions(
                          //                     decimal: true),
                          //             inputFormatters: [
                          //               DecimalTextInputFormatter(
                          //                 decimalPlaces: SharedPrefs()
                          //                     .decimalplacesquantity,
                          //                 minValue: 0.0,
                          //                 maxValue: double.infinity,
                          //               ),
                          //             ],
                          //             decoration: InputDecoration(
                          //               contentPadding: EdgeInsets.all(
                          //                   screenHeight * 0.015),
                          //               labelText: (item?.standardUnit
                          //                           ?.trim()
                          //                           .isNotEmpty ??
                          //                       false)
                          //                   ? "Actual Weight (${item!.standardUnit})"
                          //                   : "Actual Weight",
                          //               floatingLabelBehavior:
                          //                   FloatingLabelBehavior.always,
                          //               floatingLabelStyle: getSemiBoldStyle(
                          //                 color: ColorManager.lightGrey1,
                          //                 fontSize: FontSize.s18,
                          //               ),
                          //               border: OutlineInputBorder(
                          //                 borderRadius: BorderRadius.circular(
                          //                     screenHeight * 0.01),
                          //               ),
                          //               filled: true,
                          //               fillColor: Colors.white,
                          //             ),
                          //           ),
                          //           Positioned(
                          //             right: 0,
                          //             top: 0,
                          //             child: CustomPaint(
                          //               size: const Size(12, 12),
                          //               painter: _RedTrianglePainter(),
                          //             ),
                          //           ),
                          //         ],
                          //       ),
                          //     ),
                          //   ),

                          //   // Note: 1 PU = <conversion> SU
                          //   if (item != null && item!.purchaseUnitID != null)
                          //     SizedBox(
                          //       width: screenWidth - 80,
                          //       child: Padding(
                          //         padding: const EdgeInsets.only(top: 6),
                          //         child: Text(
                          //           "1 ${item!.purchaseUnit} = ${formatQuantityString(item!.purchaseUnitConversion)} ${item!.standardUnit}",
                          //           style: getSemiBoldStyle(
                          //             color: ColorManager.lightGrey2,
                          //             fontSize: FontSize.s12,
                          //           ),
                          //           textAlign: TextAlign.right,
                          //         ),
                          //       ),
                          //     ),
                          // ],

                          const SizedBox(height: 20),
                          // Comments TextField
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: SizedBox(
                              width: double.infinity,
                              height: 120,
                              child: TextField(
                                controller: _commmentsController,
                                style: getSemiBoldStyle(
                                  color: ColorManager.black,
                                  fontSize: FontSize.s16,
                                ),
                                maxLines: null,
                                minLines: 5,
                                expands: false,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(
                                    AppConstants
                                        .maxCharactersForCommentItemDetails,
                                  ),
                                ],
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.all(20),
                                  labelText: AppStrings.notes,
                                  alignLabelWithHint: true,
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  floatingLabelStyle: getSemiBoldStyle(
                                    color: ColorManager.lightGrey1,
                                    fontSize: FontSize.s16,
                                  ),
                                ),
                                onChanged: (value) {
                                  // Trigger rebuild to update character count
                                  setState(() {});
                                },
                              ),
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.only(top: 4, right: 4),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: Text(
                                "Characters remaining: ${AppConstants.maxCharactersForCommentItemDetails - _commmentsController.text.length}",
                                style: TextStyle(
                                  fontSize: FontSize.s14,
                                  color: _commmentsController.text.length >=
                                          AppConstants
                                              .maxCharactersForCommentItemDetails
                                      ? ColorManager.red
                                      : (AppConstants.maxCharactersForCommentItemDetails -
                                                  _commmentsController
                                                      .text.length) <=
                                              20
                                          ? Colors.orange
                                          : ColorManager.darkGrey,
                                  fontWeight: _commmentsController
                                              .text.length >=
                                          AppConstants
                                              .maxCharactersForCommentItemDetails
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 20),

                          // Button section - properly aligned
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 18),
                            child: Column(
                              children: [
                                SizedBox(height: displayHeight(context) * 0.05),
                                CustomTextActionButton(
                                  buttonText: "Adjust Stock",
                                  backgroundColor: ColorManager.appBarGrey,
                                  borderColor: Colors.transparent,
                                  fontColor: ColorManager.white,
                                  buttonWidth: double.infinity,
                                  buttonHeight: 50,
                                  isBoldFont: true,
                                  fontSize: FontSize.s20,
                                  onTap: () async {
                                    if (_physicalQtyController.text
                                        .trim()
                                        .isEmpty) {
                                      showErrorDialog(
                                          context,
                                          "Physical Quantity cannot be empty.",
                                          false);
                                      return;
                                    }

                                    final double actualWeight;
                                    if (catchWeight) {
                                      final text =
                                          _actualWeightController.text.trim();
                                      final double w = double.tryParse(
                                              text.replaceAll(',', '')) ??
                                          0;
                                      if (text.isEmpty || w <= 0) {
                                        showErrorDialog(
                                          context,
                                          "${actualWeightLabel.isNotEmpty ? actualWeightLabel : 'Actual Weight'} should be greater than 0.",
                                          false,
                                        );
                                        return;
                                      }
                                      actualWeight = w;
                                    } else {
                                      actualWeight = 0;
                                    }

                                    await updateBlindStockOffline(
                                      itemId: widget.itemId,
                                      adjustQuantity: double.tryParse(
                                            _physicalQtyController.text
                                                .replaceAll(',', ''),
                                          ) ??
                                          0.0,
                                      comments:
                                          _commmentsController.text.trim(),
                                      selectedUnitId: selectedUnitId,
                                      selectedUnitType:
                                          selectedUnitType, // String? is OK now
                                      actualWeight: actualWeight,
                                    );

                                    showSuccessDialog(
                                      context,
                                      ImageAssets.successfulIcon,
                                      '',
                                      'Stock updated successfully (Offline)',
                                      true,
                                    );
                                  },
                                ),
                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
    );
  }
}

class _RedTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = ColorManager.red2;
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
