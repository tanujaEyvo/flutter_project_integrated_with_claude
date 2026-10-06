import 'dart:async';
import 'dart:convert';

import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:eyvo_v3/app/app_prefs.dart';
import 'package:eyvo_v3/app/sizes_helper.dart';
import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/routes_manager.dart';
import 'package:eyvo_v3/core/resources/strings_manager.dart';
import 'package:eyvo_v3/core/resources/styles_manager.dart';
import 'package:eyvo_v3/core/utils.dart';
import 'package:eyvo_v3/core/widgets/common_app_bar.dart';
import 'package:eyvo_v3/core/widgets/custom_field.dart';
import 'package:eyvo_v3/core/widgets/custom_list_tile.dart';
import 'package:eyvo_v3/core/widgets/progress_indicator.dart';
import 'package:eyvo_v3/local_db/dao/offline_db_dao.dart';
import 'package:eyvo_v3/local_db/model/offline_item_stock_model.dart';
import 'package:eyvo_v3/local_db/widgets/barcode_sanitizer_code.dart';

import 'package:eyvo_v3/log_data.dart/logger_data.dart';
import 'package:flutter/material.dart';

class OfflineBlindStockListView extends StatefulWidget {
  const OfflineBlindStockListView({super.key});

  @override
  State<OfflineBlindStockListView> createState() =>
      _OfflineBlindStockListViewState();
}

class _OfflineBlindStockListViewState extends State<OfflineBlindStockListView>
    with RouteAware {
  final OfflineDBDao _offlineDBDao = OfflineDBDao();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final int regionId = SharedPrefs().selectedRegionID;
  final int locationId = SharedPrefs().selectedLocationID;
  Timer? _debounce;
  bool hasUnsyncedItems = false;
  int unsyncedCount = 0;
  bool isLoading = false;
  bool isError = false;
  bool _showSearchBar = false;

  String errorText = AppStrings.somethingWentWrong;

  List<OfflineItemStock> listItems = [];
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    routeObserver.subscribe(
      this,
      ModalRoute.of(context)! as PageRoute,
    );
  }

  @override
  void didPopNext() {
    fetchListItems();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    fetchListItems();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  //---------------- SEARCH ----------------

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      fetchListItems();
    });
  }

  //---------------- FETCH OFFLINE DATA ----------------

  // Future<void> fetchListItems() async {
  //   setState(() {
  //     isLoading = true;
  //     isError = false;
  //   });

  //   try {
  //     final offlineItems = await _offlineDBDao.getItemStockList(
  //       regionId: SharedPrefs().selectedRegionID,
  //       locationId: SharedPrefs().selectedLocationID,
  //       searchText: _searchController.text,
  //     );

  //     setState(() {
  //       listItems = offlineItems;
  //     });
  //     await checkUnsyncedItems();
  //   }
  //   catch (e) {
  //     setState(() {
  //       isError = true;
  //       errorText = AppStrings.somethingWentWrong;
  //       listItems = [];
  //     });
  //   }

  //   setState(() {
  //     isLoading = false;
  //   });
  // }

  Future<void> fetchListItems() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      final offlineItems = await _offlineDBDao.getItemStockList(
        regionId: SharedPrefs().selectedRegionID,
        locationId: SharedPrefs().selectedLocationID,
        searchText: _searchController.text,
      );

      setState(() {
        listItems = offlineItems;
      });

      await checkUnsyncedItems();
    } catch (e, stackTrace) {
      await _offlineDBDao.insertErrorLog(
        exceptionMessage: e.toString(),
        stackTrace: stackTrace.toString(),
        apiUrl: 'OFFLINE - SQLite - getItemStockList',
        requestBody: jsonEncode({
          "regionId": SharedPrefs().selectedRegionID,
          "locationId": SharedPrefs().selectedLocationID,
          "searchText": _searchController.text,
        }),
        screenName: 'OfflineBlindStockListView',
        methodName: 'fetchListItems',
      );

      LoggerData.dataLog('fetchListItems Exception: $e');
      LoggerData.dataLog(stackTrace.toString());

      setState(() {
        isError = true;
        errorText = AppStrings.somethingWentWrong;
        listItems = [];
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }
  //---------------- NAVIGATION ----------------

  void navigateToItemDetails(int itemId) {
    Navigator.pushNamed(
      context,
      Routes.offlineBlindStockDetailsRoute,
      arguments: {'itemId': itemId},
    );
  }

//--------------------------------------- SCANNER LOGIC ----------------------------
  // Future<void> scanBarcode() async {
  //   try {
  //     final ScanResult result = await BarcodeScanner.scan();

  //     //  Cancel or empty scan
  //     if (result.rawContent.isEmpty || result.rawContent == "-1") return;

  //     final json = jsonDecode(result.rawContent);
  //     final int itemId = json['itemid'];

  //     if (SharedPrefs().isOfflineMode) {
  //       final bool itemExists = await _offlineDBDao.isItemExists(
  //         itemId: itemId,
  //         regionId: SharedPrefs().selectedRegionID,
  //         locationId: SharedPrefs().selectedLocationID,
  //       );

  //       if (!itemExists) {
  //         showSnackBar(context, 'Item not found in offline data');
  //         return;
  //       }

  //       navigateToItemDetails(itemId);
  //     } else {
  //       showSnackBar(context, 'Offline mode required to scan item');
  //     }
  //   } catch (e) {
  //     LoggerData.dataLog('Scan error: $e');
  //     showSnackBar(context, 'Failed to scan barcode');
  //   }
  // }
  // Future<void> scanBarcode() async {
  //   String? resultString;

  //   try {
  //     final ScanResult result = await BarcodeScanner.scan();

  //     resultString = result.rawContent.trim();

  //     LoggerData.dataLog("=== BARCODE SCAN ===");
  //     LoggerData.dataLog("Format: ${result.format}");
  //     LoggerData.dataLog("Raw Content: $resultString");

  //     if (resultString.isEmpty || resultString == "-1") {
  //       await _offlineDBDao.insertErrorLog(
  //         exceptionMessage: "Empty or cancelled scan",
  //         stackTrace: "",
  //         apiUrl: "OFFLINE - Barcode Scanner",
  //         requestBody: resultString,
  //         screenName: "OfflineBlindStockListView",
  //         methodName: "scanBarcode",
  //       );
  //       return;
  //     }

  //     // iPhone sometimes returns quoted JSON
  //     if (resultString.startsWith('"') && resultString.endsWith('"')) {
  //       resultString = jsonDecode(resultString);
  //       LoggerData.dataLog("Decoded iOS QR: $resultString");
  //     }

  //     LoggerData.dataLog("isQRCode = ${_isQRCode(resultString!)}");

  //     if (_isQRCode(resultString)) {
  //       await _handleQRCodeScan(resultString);
  //     } else {
  //       await _handleBarcodeScan(resultString, result.format.toString());
  //     }
  //   } catch (e, stackTrace) {
  //     await _offlineDBDao.insertErrorLog(
  //       exceptionMessage: e.toString(),
  //       stackTrace: stackTrace.toString(),
  //       apiUrl: "OFFLINE - Barcode Scanner",
  //       requestBody: resultString ?? "",
  //       screenName: "OfflineBlindStockListView",
  //       methodName: "scanBarcode",
  //     );

  //     LoggerData.dataLog(e.toString());
  //     LoggerData.dataLog(stackTrace.toString());

  //     showSnackBar(context, "Failed to scan barcode");
  //   }
  // }
  Future scanBarcode() async {
    String? resultString;

    try {
      final ScanResult result = await BarcodeScanner.scan();

      resultString = result.rawContent.trim();

      LoggerData.dataLog("=== SCAN RESULT ===");
      LoggerData.dataLog("Format      : ${result.format}");
      LoggerData.dataLog("Raw Content : $resultString");

      if (resultString.isEmpty || resultString == "-1") {
        await _offlineDBDao.insertErrorLog(
          exceptionMessage: "Empty or cancelled scan",
          stackTrace: "",
          apiUrl: "OFFLINE - Barcode Scanner",
          requestBody: resultString,
          screenName: "OfflineBlindStockListView",
          methodName: "scanBarcode",
        );
        return;
      }

      // iOS sometimes returns quoted JSON
      if (resultString.startsWith('"') && resultString.endsWith('"')) {
        resultString = jsonDecode(resultString);
      }

      // QR Code
      if (_isQRCode(resultString!)) {
        await _handleQRCodeScan(resultString);
        return;
      }

      // ---------- BARCODE ----------
      List<String> candidates = [];

      String barcode = resultString.trim();

      candidates.add(barcode);

      // EAN13 -> UPCA
      if (barcode.length == 13 && barcode.startsWith("0")) {
        candidates.add(barcode.substring(1));
      }

      // UPCA -> EAN13
      if (barcode.length == 12) {
        candidates.add("0$barcode");
      }

      candidates = candidates.toSet().toList();

      LoggerData.dataLog("Barcode Candidates : $candidates");

      bool found = false;

      for (final code in candidates) {
        final int? itemId = await _offlineDBDao.getItemIdByBarCodeString(code);

        LoggerData.dataLog("Trying barcode : $code -> ItemId : $itemId");

        if (itemId != null) {
          found = true;
          navigateToItemDetails(itemId);
          break;
        }
      }

      if (!found) {
        showSnackBar(
          context,
          "Item Details Not Found",
        );
        LoggerData.dataLog(resultString);
      }
    } catch (e, stackTrace) {
      await _offlineDBDao.insertErrorLog(
        exceptionMessage: e.toString(),
        stackTrace: stackTrace.toString(),
        apiUrl: "OFFLINE - Barcode Scanner",
        requestBody: resultString ?? "",
        screenName: "OfflineBlindStockListView",
        methodName: "scanBarcode",
      );

      LoggerData.dataLog(e.toString());
      LoggerData.dataLog(stackTrace.toString());

      showSnackBar(context, "Failed to scan barcode");
    }
  }

// Helper method to detect if it's a QR code (contains JSON)
  bool _isQRCode(String content) {
    // Check if content looks like JSON
    content = content.trim();
    return (content.startsWith('{') && content.endsWith('}')) ||
        (content.startsWith('[') && content.endsWith(']'));
  }

// Handle QR Code scan (JSON format)
  // Future<void> _handleQRCodeScan(String resultString) async {
  //   try {
  //     LoggerData.dataLog("=== QR CODE SCAN ===");
  //     LoggerData.dataLog("Raw QR = $resultString");

  //     final dynamic decoded = jsonDecode(resultString);

  //     late Map<String, dynamic> jsonData;

  //     if (decoded is Map<String, dynamic>) {
  //       jsonData = decoded;
  //     } else if (decoded is List && decoded.isNotEmpty) {
  //       jsonData = Map<String, dynamic>.from(decoded.first);
  //     } else {
  //       throw Exception("Invalid QR format");
  //     }

  //     LoggerData.dataLog("Decoded QR = $jsonData");

  //     final int? itemId = jsonData["itemid"];
  //     final int? locationId = jsonData["location_id"];
  //     final int? regionId = jsonData["region_id"];

  //     if (itemId == null || locationId == null || regionId == null) {
  //       throw Exception(
  //         "QR missing required fields. JSON: ${jsonEncode(jsonData)}",
  //       );
  //     }

  //     // SharedPrefs().selectedLocationID = locationId;
  //     // SharedPrefs().selectedRegionID = regionId;

  //     LoggerData.dataLog("ItemId = ${itemId}");
  //     LoggerData.dataLog("LocationId = ${SharedPrefs().selectedLocationID}");
  //     LoggerData.dataLog("RegionId = ${SharedPrefs().selectedRegionID}");

  //     if (!SharedPrefs().isOfflineMode) {
  //       showSnackBar(context, "Offline mode required to scan QR code");
  //       return;
  //     }

  //     final bool itemExists = await _offlineDBDao.isItemExists(
  //       itemId: itemId,
  //       regionId: SharedPrefs().selectedRegionID,
  //       locationId: SharedPrefs().selectedLocationID,
  //     );

  //     if (!itemExists) {
  //       showSnackBar(context, "Item not found in offline database");
  //       await _offlineDBDao.insertErrorLog(
  //         exceptionMessage:
  //             "Item not found in offline database for QR: ItemId=$itemId, LocationId=$locationId, RegionId=$regionId",
  //         stackTrace: "",
  //         apiUrl: "OFFLINE - QR Code Processing",
  //         requestBody: resultString,
  //         screenName: "OfflineBlindStockListView",
  //         methodName: "_handleQRCodeScan",
  //       );

  //       return;
  //     }
  //     SharedPrefs().selectedLocationID = locationId;
  //     SharedPrefs().selectedRegionID = regionId;
  //     navigateToItemDetails(itemId);
  //   } catch (e, stackTrace) {
  //     await _offlineDBDao.insertErrorLog(
  //       exceptionMessage: e.toString(),
  //       stackTrace: stackTrace.toString(),
  //       apiUrl: "OFFLINE - QR Code Processing",
  //       requestBody: resultString,
  //       screenName: "OfflineBlindStockListView",
  //       methodName: "_handleQRCodeScan",
  //     );

  //     LoggerData.dataLog("QR Exception = $e");
  //     LoggerData.dataLog(stackTrace.toString());

  //     showSnackBar(context, "Failed to process QR code");
  //   }
  // }
  Future<void> _handleQRCodeScan(String resultString) async {
    try {
      LoggerData.dataLog("=== QR CODE SCAN ===");
      LoggerData.dataLog("Raw QR = $resultString");

      final dynamic decoded = jsonDecode(resultString);

      late Map<String, dynamic> jsonData;

      if (decoded is Map<String, dynamic>) {
        jsonData = decoded;
      } else if (decoded is List && decoded.isNotEmpty) {
        jsonData = Map<String, dynamic>.from(decoded.first);
      } else {
        throw Exception("Invalid QR format");
      }

      LoggerData.dataLog("Decoded QR = $jsonData");

      final int? itemId = jsonData["itemid"];
      if (itemId == null) {
        throw Exception("QR missing itemid. JSON: ${jsonEncode(jsonData)}");
      }

      // ✅ Always use the user's current session region/location.
      // The QR's region_id/location_id are placeholders (0/1) and
      // must NOT override the session.
      final int sessionRegionId = SharedPrefs().selectedRegionID;
      final int sessionLocationId = SharedPrefs().selectedLocationID;

      LoggerData.dataLog("ItemId = $itemId");
      LoggerData.dataLog("Session RegionId = $sessionRegionId");
      LoggerData.dataLog("Session LocationId = $sessionLocationId");
      LoggerData.dataLog(
        "QR claimed regionId=${jsonData['region_id']}, "
        "locationId=${jsonData['location_id']} (ignored)",
      );

      if (!SharedPrefs().isOfflineMode) {
        showSnackBar(context, "Offline mode required to scan QR code");
        return;
      }

      final bool itemExists = await _offlineDBDao.isItemExists(
        itemId: itemId,
        regionId: sessionRegionId,
        locationId: sessionLocationId,
      );

      if (!itemExists) {
        showSnackBar(context, "Item not found in offline database");
        await _offlineDBDao.insertErrorLog(
          exceptionMessage: "Item not found for QR: itemId=$itemId, "
              "regionId=$sessionRegionId, locationId=$sessionLocationId",
          stackTrace: "",
          apiUrl: "OFFLINE - QR Code Processing",
          requestBody: resultString,
          screenName: "OfflineBlindStockListView",
          methodName: "_handleQRCodeScan",
        );
        return;
      }

      // ❌ DO NOT call:
      // SharedPrefs().selectedLocationID = locationId;
      // SharedPrefs().selectedRegionID = regionId;

      if (!mounted) return;
      navigateToItemDetails(itemId);
    } catch (e, stackTrace) {
      await _offlineDBDao.insertErrorLog(
        exceptionMessage: e.toString(),
        stackTrace: stackTrace.toString(),
        apiUrl: "OFFLINE - QR Code Processing",
        requestBody: resultString,
        screenName: "OfflineBlindStockListView",
        methodName: "_handleQRCodeScan",
      );

      LoggerData.dataLog("QR Exception = $e");
      LoggerData.dataLog(stackTrace.toString());

      if (!mounted) return;
      showSnackBar(context, "Failed to process QR code");
    }
  }

// Handle Barcode scan (regular code)
  Future<void> _handleBarcodeScan(String resultString, String format) async {
    try {
      // Sanitize the barcode
      String sanitizedCode =
          BarcodeSanitizer.sanitizeBarcode(resultString, format.toUpperCase());

      LoggerData.dataLog('=== BARCODE SCAN ===');
      LoggerData.dataLog('Original Barcode: $resultString');
      LoggerData.dataLog('Sanitized Barcode: $sanitizedCode');

      if (SharedPrefs().isOfflineMode) {
        // Get ItemID by UPC - this already checks if item exists
        final int? itemId =
            await _offlineDBDao.getItemIdByBarCodeString(sanitizedCode);

        if (itemId == null) {
          await _offlineDBDao.insertErrorLog(
            exceptionMessage: 'Item not found for barcode',
            stackTrace: '',
            apiUrl: 'OFFLINE - SQLite - getItemIdByBarCodeString',
            requestBody: jsonEncode({
              'barcode': sanitizedCode,
              'format': format,
            }),
            screenName: 'OfflineBlindStockListView',
            methodName: '_handleBarcodeScan',
          );

          showSnackBar(context, 'Item not found for barcode: $sanitizedCode');
          return;
        }

        navigateToItemDetails(itemId);
      } else {
        await _offlineDBDao.insertErrorLog(
          exceptionMessage: 'Offline mode required to scan barcode',
          stackTrace: '',
          apiUrl: 'OFFLINE - Barcode Scan',
          requestBody: jsonEncode({
            'barcode': sanitizedCode,
            'format': format,
          }),
          screenName: 'OfflineBlindStockListView',
          methodName: '_handleBarcodeScan',
        );

        showSnackBar(context, 'Offline mode required to scan barcode');
      }
    } catch (e, stackTrace) {
      await _offlineDBDao.insertErrorLog(
        exceptionMessage: e.toString(),
        stackTrace: stackTrace.toString(),
        apiUrl: 'OFFLINE - Barcode Processing',
        requestBody: jsonEncode({
          'barcode': resultString,
          'format': format,
        }),
        screenName: 'OfflineBlindStockListView',
        methodName: '_handleBarcodeScan',
      );

      LoggerData.dataLog('Barcode processing error: $e');
      LoggerData.dataLog(stackTrace.toString());

      showSnackBar(context, 'Failed to process barcode');
    }
  }
  // ---------------- SEARCH BAR UI ----------------

  Widget _buildSearchToggleRow() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          if (_showSearchBar) ...[
            Expanded(
              child: CustomSearchField(
                controller: _searchController,
                placeholderText: AppStrings.searchItems,
                inputType: TextInputType.text,
                autoFocus: true,
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () {
                setState(() {
                  _showSearchBar = false;
                  _searchController.clear();
                });
              },
            ),
          ] else ...[
            Expanded(
              child: CustomSearchField(
                controller: _searchController,
                placeholderText: AppStrings.searchItems,
                inputType: TextInputType.text,
                readOnly: true,
                onTap: () => setState(() => _showSearchBar = true),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.qr_code_scanner_outlined),
              onPressed: scanBarcode,
            ),
          ],
        ],
      ),
    );
  }

  Future<void> checkUnsyncedItems() async {
    try {
      final unsyncedItems = await _offlineDBDao.getUnsyncedItems();

      setState(() {
        hasUnsyncedItems = unsyncedItems.isNotEmpty;
        unsyncedCount = unsyncedItems.length;
      });
    } catch (e) {
      setState(() {
        hasUnsyncedItems = false;
        unsyncedCount = 0;
      });
    }
  }

  void navigateToTransactions() {
    Navigator.pushNamed(
      context,
      Routes.transactionsRoute,
    );
  }

  Widget _buildTransactionsLink() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 6),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: navigateToTransactions,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            color: ColorManager.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: ColorManager.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ColorManager.blue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.receipt_long,
                  color: ColorManager.blue,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Transactions",
                  style: getMediumStyle(
                    color: ColorManager.black,
                    fontSize: FontSize.s16,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: ColorManager.grey,
              )
            ],
          ),
        ),
      ),
    );
  }
  // ---------------- UI ----------------

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
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
                'Blind Stock Listing',
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
        bottomNavigationBar: hasUnsyncedItems
            ? SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 16,
                    right: 16,
                    top: 16,
                    bottom: displayHeight(context) * 0.05,
                  ),
                  child: SizedBox(
                    height: 55,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: navigateToTransactions,
                      child: Container(
                        decoration: BoxDecoration(
                          color: ColorManager.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: ColorManager.blue,
                            width: 1.5,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: ColorManager.black.withOpacity(0.1),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ],
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.receipt_long,
                              color: ColorManager.blue,
                              size: 22,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              "View Adjusted Inventory",
                              style: getBoldStyle(
                                color: ColorManager.blue,
                                fontSize: FontSize.s16,
                              ),
                            ),
                            if (unsyncedCount > 0) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: ColorManager.yellow,
                                  shape: BoxShape.circle,
                                ),
                                constraints: const BoxConstraints(
                                  minWidth: 22,
                                  minHeight: 22,
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  unsyncedCount.toString(),
                                  style: TextStyle(
                                    color: ColorManager.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: FontSize.s12,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              )
            : null,
        body: SafeArea(
          child: Column(
            children: [
              _buildSearchToggleRow(),
              const SizedBox(height: 5),
              Expanded(
                child: isLoading
                    ? const Center(child: CustomProgressIndicator())
                    : isError
                        ? _buildErrorView(context)
                        : _buildListView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorView(BuildContext context) {
    return Center(
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
              fontSize: FontSize.s16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView() {
    if (listItems.isEmpty) {
      return Center(
        child: Padding(
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
                  const SizedBox(height: 10),
                  Text(
                    "No data found", // or "No data found"
                    style: getRegularStyle(
                      color: ColorManager.lightGrey,
                      fontSize: FontSize.s17,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      itemCount: listItems.length,
      itemBuilder: (context, index) {
        final item = listItems[index];
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: GestureDetector(
            onTap: () => navigateToItemDetails(item.itemId!),
            child: ItemListTile(
              title: item.outLine ?? '',
              subtitle1: item.itemCode ?? '',
              subtitle2: item.categoryCode ?? '',
              subtitle3: item.synced == 0
                  ? formatQuantityString(item.newStockCount ?? 0)
                  : null,
              imageString: '',
              isOffline: true,
            ),
          ),
        );
      },
    );
  }
}
