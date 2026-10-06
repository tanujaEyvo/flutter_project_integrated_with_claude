import 'dart:convert';

import 'package:eyvo_v3/api/api_service/api_service.dart';
//import 'package:eyvo_v3vice/bloc.dart';
import 'package:eyvo_v3/api/response_models/default_api_response.dart';
import 'package:eyvo_v3/api/response_models/item_details_response.dart';
import 'package:eyvo_v3/api/response_models/item_scan_details_response.dart';
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
import 'package:eyvo_v3/log_data.dart/logger_data.dart';
import 'package:eyvo_v3/presentation/blind_stock_details/blindstock_details.dart';
import 'package:eyvo_v3/services/error_logging_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class ItemDetailsView extends StatefulWidget {
  final int? itemId;
  final String? resultString;
  final EntryType entryType;
  final String? scanFormat;

  const ItemDetailsView(
      {super.key,
      this.resultString,
      this.itemId,
      required this.entryType,
      this.scanFormat});

  @override
  State<ItemDetailsView> createState() => _ItemDetailsViewState();
}

// enum EntryType {
//   listing,
//   scan,
// }

class _ItemDetailsViewState extends State<ItemDetailsView> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _commmentsController = TextEditingController();
  final TextEditingController _actualWeightController = TextEditingController();
  late List<ItemDetails> items = [];
  bool isItemEditable = true;
  bool isLoading = false;
  bool isError = false;
  int? _currentItemId;
  String errorText = AppStrings.somethingWentWrong;
  final ApiService apiService = ApiService();
  DateTime selectedDate = DateTime.now();
  final FocusNode priceFocusNode = FocusNode();
  final FocusNode quantityFocusNode = FocusNode();
  final FocusNode actualWeightFocusNode = FocusNode();

  String? selectedUnit;
  int? selectedUnitId;

  List<Map<String, dynamic>> unitList = [];
  bool catchWeight = false;
  bool splittable = false;
  String actualWeightLabel = "";
  String? selectedUnitType;
  @override
  void initState() {
    super.initState();

    _quantityController.text = getFormattedString(1.0);
    _dateController.text = DateFormat('dd-MMM-yyyy').format(selectedDate);
    _priceController.text = getFormattedStringPrice(0.0);
    _actualWeightController.text = "1.00";
    // Decide which API to call
    if (widget.entryType == EntryType.scan) {
      scanItem();
    } else {
      fetchItemDetails();
    }

    priceFocusNode.addListener(() {
      if (!priceFocusNode.hasFocus) {
        _performPriceActionOnFocusChanged();
      }
    });

    quantityFocusNode.addListener(() {
      if (!quantityFocusNode.hasFocus) {
        _performQuantityActionOnFocusChanged();
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
    priceFocusNode.dispose();
    quantityFocusNode.dispose();
    actualWeightFocusNode.dispose();
    _quantityController.dispose();
    _dateController.dispose();
    _priceController.dispose();
    _commmentsController.dispose();
    _actualWeightController.dispose();
    SharedPrefs().isItemScanned = false;
    super.dispose();
  }

  void _performPriceActionOnFocusChanged() {
    if (_priceController.text.isNotEmpty) {
      _priceController.text = getDefaultString(_priceController.text);
      _priceController.text =
          getFormattedPriceStringPrice(double.parse(_priceController.text));
    } else {
      _priceController.text = getFormattedPriceStringPrice(0);
    }
  }

  // void _performQuantityActionOnFocusChanged() {
  //   if (_quantityController.text.isNotEmpty) {
  //     _quantityController.text = getDefaultString(_quantityController.text);
  //     _quantityController.text =
  //         getFormattedString(double.parse(_quantityController.text));
  //   } else {
  //     _quantityController.text = getFormattedString(1);
  //   }
  // }
  void _performQuantityActionOnFocusChanged() {
    if (_quantityController.text.trim().isNotEmpty) {
      final double quantity = parseQuantityString(_quantityController.text);
      _quantityController.text = formatQuantityString(quantity);
    } else {
      _quantityController.text = formatQuantityString(1.0);
    }
  }

  void _performActualWeightActionOnFocusChanged() {
    if (_actualWeightController.text.trim().isNotEmpty) {
      final double weight = parseQuantityString(_actualWeightController.text);
      _actualWeightController.text = formatQuantityString(weight);
    } else {
      _actualWeightController.text = formatQuantityString(1.0);
    }
  }

  String formatQuantityWithoutTrailingZeros(double value) {
    if (value == value.truncateToDouble()) {
      return value.toInt().toString();
    }

    return value
        .toStringAsFixed(SharedPrefs().decimalPlaces)
        .replaceFirst(RegExp(r'0+$'), '')
        .replaceFirst(RegExp(r'\.$'), '');
  }

  void scanItem() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      if (widget.resultString == null || widget.resultString!.isEmpty) {
        setState(() {
          isLoading = false;
          isError = true;
          errorText = 'No barcode/QR code scanned';
        });
        return;
      }

      Map<String, dynamic> data = {
        "locationid": SharedPrefs().selectedLocationID,
        "regionid": SharedPrefs().selectedRegionID,
        "scannedvalue": widget.resultString,
        "uid": SharedPrefs().uID,
        "scanformat": widget.scanFormat,
        "pagefrom": ""
      };

      final jsonResponse =
          await apiService.postRequest(context, ApiService.itemScan, data);

      if (jsonResponse != null) {
        final response = ItemDetailsResponse.fromJson(jsonResponse);

        setState(() {
          isLoading = false;

          if (response.code == '200') {
            items = response.data;
            _priceController.text =
                getFormattedPriceStringPrice(items[0].basePrice);
            isItemEditable = items[0].itemEdit;
            // SharedPrefs().selectedLocationID = items[0].locationid!;
            // SharedPrefs().selectedRegionID = items[0].regionid!;
            _currentItemId = items[0].itemId;
            catchWeight = items[0].catchWeight ?? false;
            splittable = items[0].splittable ?? false;
            actualWeightLabel = items[0].actualWeightLabel ?? "";
            //  _quantityController.text = formatQuantityString(1.0);
            _setUnitList(items[0]);
          } else {
            isError = true;
            errorText = response.message.join(', ');
          }
        });
      } else {
        setState(() {
          isLoading = false;
          isError = true;
          errorText = 'Failed to connect to server';
        });

        // Log null response error
        await ErrorLoggingService().logApiError(
          exceptionMessage: 'Failed to connect to server - Null response',
          stackTrace: StackTrace.current.toString(),
          apiUrl: ApiService.itemScan,
          requestBody: jsonEncode(data),
          screenName: 'item_details.dart',
          methodName: 'scanItem',
          context: context,
        );
      }
    } catch (e, stackTrace) {
      debugPrint('scanItem Exception: $e');
      debugPrintStack(stackTrace: stackTrace);

      setState(() {
        isLoading = false;
        isError = true;
        errorText = e.toString();
      });
      Map<String, dynamic> requestData = {
        "locationid": SharedPrefs().selectedLocationID,
        "regionid": SharedPrefs().selectedRegionID,
        "scannedvalue": widget.resultString,
        "uid": SharedPrefs().uID,
        "scanformat": widget.scanFormat,
        "pagefrom": ""
      };
      await ErrorLoggingService().logApiError(
        exceptionMessage: 'Failed to connect to server - Null response',
        stackTrace: StackTrace.current.toString(),
        apiUrl: ApiService.itemScan,
        requestBody: jsonEncode(requestData),
        screenName: 'item_details.dart',
        methodName: 'scanItem',
        context: context,
      );
      // showSnackBar(context, errorText);
    }
  }

  // ========== EXISTING FETCH METHOD ==========

  void fetchItemDetails() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> data = {
      "itemid": widget.itemId,
      "locationid": SharedPrefs().isItemScanned
          ? SharedPrefs().scannedLocationID
          : SharedPrefs().selectedLocationID,
      'regionid': SharedPrefs().isItemScanned
          ? SharedPrefs().scannedRegionID
          : SharedPrefs().selectedRegionID,
      "uid": SharedPrefs().uID,
    };

    final jsonResponse =
        await apiService.postRequest(context, ApiService.itemDetails, data);

    if (jsonResponse != null) {
      final response = ItemDetailsResponse.fromJson(jsonResponse);

      setState(() {
        if (response.code == '200') {
          items = response.data;

          if (items.isNotEmpty) {
            _priceController.text =
                getFormattedPriceStringPrice(items[0].basePrice);

            isItemEditable = items[0].itemEdit;
            _currentItemId = items[0].itemId;
            catchWeight = items[0].catchWeight ?? false;
            // catchWeight = true;
            splittable = items[0].splittable ?? false;
            // splittable = true;
            actualWeightLabel = items[0].actualWeightLabel ?? "";
            _quantityController.text = formatQuantityString(1.0);
            // actualWeightLabel = 'abc';
            _setUnitList(items[0]);
          }
        } else {
          isError = true;
          errorText = response.message.join(', ');
        }
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  void _setUnitList(ItemDetails item) {
    unitList.clear();

    final String? purchaseUnit = item.purchaseUnit?.trim();
    final String? inventoryUnit = item.inventoryUnit?.trim();

    final bool isSameUnit = purchaseUnit != null &&
        purchaseUnit.isNotEmpty &&
        inventoryUnit != null &&
        inventoryUnit.isNotEmpty &&
        purchaseUnit.toLowerCase() == inventoryUnit.toLowerCase();

    //if splittable is false → ONLY purchase unit
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
      LoggerData.dataLog('Unit List (non-splittable): $unitList');
    } else if (isSameUnit) {
      // Purchase Unit == Inventory Unit → keep ONLY Purchase Unit
      if (item.purchaseUnitID != null) {
        unitList.add({
          'id': item.purchaseUnitID,
          'name': purchaseUnit,
          'type': 'purchase',
        });
      }
    } else {
      // 1st -> Purchase Unit
      if (item.purchaseUnitID != null &&
          purchaseUnit != null &&
          purchaseUnit.isNotEmpty) {
        unitList.add({
          'id': item.purchaseUnitID,
          'name': purchaseUnit,
          'type': 'purchase',
        });
      }

      // 2nd -> Inventory Unit
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

    // Automatically select FIRST item
    if (unitList.isNotEmpty) {
      selectedUnit = unitList.first['name']?.toString();
      selectedUnitId = unitList.first['id'] as int?;
      selectedUnitType = unitList.first['type']?.toString(); // <-- add this
    } else {
      selectedUnit = null;
      selectedUnitId = null;
      selectedUnitType = null; // <-- add this
    }

    LoggerData.dataLog('Unit List: $unitList');
    LoggerData.dataLog('Selected Unit: $selectedUnit');
    LoggerData.dataLog('Selected Unit ID: $selectedUnitId');
    LoggerData.dataLog('Selected Unit Type: $selectedUnitType');
  }

  Future<void> _selectDate(BuildContext context) async {
    showDialog<DateTime>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          contentPadding: const EdgeInsets.all(0),
          content: SizedBox(
            width: displayWidth(context),
            child: CalendarDatePicker(
              initialDate: selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime.now(),
              onDateChanged: (DateTime date) {
                setState(() {
                  selectedDate = date;
                  _dateController.text =
                      DateFormat('dd-MMM-yyyy').format(selectedDate);
                });
                Navigator.of(context).pop();
              },
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close dialog without selection
              },
              child: const Text(AppStrings.cancel),
            ),
          ],
        );
      },
    );
  }

  void validateItemsIN() {
    var price = getDefaultString(_priceController.text);
    var quantity = getDefaultString(_quantityController.text);
    var actualWeight = getDefaultString(_actualWeightController.text);

    if (quantity.isEmpty) {
      showErrorDialog(context, AppStrings.quantityNotValid, false);
    } else if (double.parse(quantity) <= 0) {
      showErrorDialog(context, AppStrings.quantityNotValid, false);
    } else if (price.isEmpty) {
      showErrorDialog(context, AppStrings.priceNotValid, false);
    } else if (items[0].basePrice <= 0 && double.parse(price) <= 0) {
      showErrorDialog(context, AppStrings.priceNotValid, false);
    } else if (catchWeight &&
        (actualWeight.isEmpty || (double.tryParse(actualWeight) ?? 0) <= 0)) {
      showErrorDialog(
        context,
        "$actualWeightLabel should be greater than 0.",
        false,
      );
    } else if (_commmentsController.text.isEmpty) {
      showErrorDialog(context, AppStrings.commentsCannotBeBlank, false);
    } else {
      proceedWithItemsInOut('IN');
    }
  }

  void validateItemsOUT() {
    var quantity = getDefaultString(_quantityController.text);
    var actualWeight = getDefaultString(_actualWeightController.text);
    if (quantity.isEmpty) {
      showErrorDialog(context, AppStrings.quantityNotValid, false);
    } else if (double.parse(quantity) <= 0) {
      showErrorDialog(context, AppStrings.quantityNotValid, false);
    } else if (!catchWeight && double.parse(quantity) > items[0].stockCount) {
      showErrorDialog(
          context, AppStrings.quantityCannotBeGreaterThanStock, false);
    } else if (catchWeight &&
        (actualWeight.isEmpty || (double.tryParse(actualWeight) ?? 0) <= 0)) {
      showErrorDialog(
        context,
        "$actualWeightLabel should be greater than 0.",
        false,
      );
    } else if (_commmentsController.text.isEmpty) {
      showErrorDialog(context, AppStrings.commentsCannotBeBlank, false);
    } else {
      proceedWithItemsInOut('OUT');
    }
  }

  void proceedWithItemsInOut(String modeType) async {
    if (items.isEmpty) {
      setState(() {
        isLoading = false;
      });
      showErrorDialog(context, 'No item selected', false);
      return;
    }

    var price = getDefaultString(_priceController.text);
    final double quantity = parseQuantityString(_quantityController.text);

    setState(() {
      isLoading = true;
    });

    int itemId;
    if (widget.entryType == EntryType.scan) {
      // For scan, use the stored item ID from the scanned item
      itemId = _currentItemId ?? 0;
    } else {
      // For listing, use the widget.itemId
      itemId = widget.itemId ?? 0;
    }

    if (itemId == 0) {
      setState(() {
        isLoading = false;
      });
      showErrorDialog(context, 'Item ID is missing. Please try again.', false);
      return;
    }
    final String actualWeightText = _actualWeightController.text.trim();
    final double actualWeight = actualWeightText.isEmpty
        ? 0
        : (double.tryParse(actualWeightText.replaceAll(',', '')) ?? 0);
    Map<String, dynamic> data = {
      "itemid": itemId,
      "itemtype": items[0].itemType,
      "locationid": SharedPrefs().isItemScanned
          ? SharedPrefs().scannedLocationID
          : SharedPrefs().selectedLocationID,
      "isstock": items[0].isStock,
      "quantity": quantity,
      "price": double.parse(price),
      "adjustmentDate": _dateController.text,
      "comments": _commmentsController.text,
      "uid": SharedPrefs().uID,
      "pageMode": modeType,
      "actualweight": actualWeight,
      'regionid': SharedPrefs().selectedRegionID,
      "UOMID": selectedUnitId,
      "unitType": selectedUnitType,
    };
    final jsonResponse =
        await apiService.postRequest(context, ApiService.itemsInOut, data);
    if (jsonResponse != null) {
      final response = DefaultAPIResponse.fromJson(jsonResponse);
      setState(() {
        if (response.code == '200') {
          showSuccessDialog(context, ImageAssets.successfulIcon, '',
              response.message.join(', '), true);
        } else {
          showErrorDialog(context, response.message.join(', '), false);
        }
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  /// Applies a greyed-out look when the field is read-only.
  InputDecoration _applyReadOnlyStyle(InputDecoration decoration) {
    if (isItemEditable) return decoration;
    return decoration.copyWith(
      filled: true,
      fillColor: ColorManager.grey.withOpacity(0.1),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ColorManager.grey4),
        borderRadius: BorderRadius.circular(8),
      ),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ColorManager.grey4),
        borderRadius: BorderRadius.circular(8),
      ),
      disabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: ColorManager.grey4),
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }

  /// Reusable read-only display for a labeled value.
  Widget _readOnlyField({
    required String label,
    required String value,
    double? height,
  }) {
    return SizedBox(
      height: height,
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.always,
          floatingLabelStyle: getSemiBoldStyle(
            color: ColorManager.lightGrey1,
            fontSize: FontSize.s16,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: ColorManager.grey4),
              borderRadius: BorderRadius.circular(8.0)),
          filled: true,
          fillColor: ColorManager.grey.withOpacity(0.1),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          isDense: true,
        ),
        isEmpty: value.isEmpty,
        child: Text(
          value,
          style: getSemiBoldStyle(
            color: ColorManager.black,
            fontSize: FontSize.s16,
          ),
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = displayWidth(context);
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: ColorManager.primary,
        // appBar: buildCommonAppBar(
        //   context: context,
        //   title: AppStrings.itemDetails,
        // ),
        appBar: isItemEditable
            ? buildCommonAppBar(
                context: context,
                title: AppStrings.itemDetails,
              )
            : AppBar(
                backgroundColor: ColorManager.darkBlue,
                titleSpacing: -10,
                title: Text(
                  AppStrings.itemDetails,
                  style: getBoldStyle(
                    color: ColorManager.white,
                    fontSize: FontSize.s20,
                  ),
                ),
                leading: IconButton(
                  icon: SizedBox(
                    width: 18,
                    height: 18,
                    child: Image.asset(ImageAssets.backButton),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: ColorManager.readOnlyYellow,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: ColorManager.readOnlyYellow,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.lock_outline,
                          size: 16,
                          color: ColorManager.black,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Read only',
                          style: getSemiBoldStyle(
                            color: ColorManager.black,
                            fontSize: FontSize.s12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
        body: isLoading
            ? const Center(child: CustomProgressIndicator())
            : isError
                ? Column(
                    children: [
                      const SizedBox(height: 60),
                      Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: Container(
                          height: displayHeight(context) * 0.65,
                          width: displayWidth(context),
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: ColorManager.white),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                const Spacer(),
                                Image.asset(
                                    width: displayWidth(context) * 0.5,
                                    ImageAssets.errorMessageIcon),
                                Center(
                                  child: Text(errorText,
                                      style: getRegularStyle(
                                          color: ColorManager.lightGrey,
                                          fontSize: FontSize.s17)),
                                ),
                                const Spacer()
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(18.0),
                          child: Container(
                            decoration: BoxDecoration(
                                color: ColorManager.white,
                                border: Border.all(
                                    color: ColorManager.grey4, width: 1.0),
                                borderRadius: BorderRadius.circular(8)),
                            width: screenWidth,
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(0.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(height: 10),
                                      Row(
                                        children: [
                                          Column(
                                            children: [
                                              ConstrainedBox(
                                                constraints:
                                                    const BoxConstraints(
                                                  minWidth: 60,
                                                  maxWidth: 300,
                                                  minHeight: 30,
                                                ),
                                                child: IntrinsicWidth(
                                                  child: Center(
                                                    child: Padding(
                                                      padding:
                                                          const EdgeInsets.only(
                                                              left: 16.0),
                                                      child: Text(
                                                        items[0].locationCaption ??
                                                            '',
                                                        style: getBoldStyle(
                                                          color: ColorManager
                                                              .black,
                                                          fontSize:
                                                              FontSize.s14,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const Spacer(),
                                          Column(
                                            children: [
                                              ConstrainedBox(
                                                constraints:
                                                    const BoxConstraints(
                                                        minWidth: 60,
                                                        maxWidth: 300,
                                                        minHeight: 30),
                                                child: IntrinsicWidth(
                                                  child: Center(
                                                    child: Text(
                                                      formatQuantityString(items[
                                                              0]
                                                          .stockCount), // includes commas
                                                      style: getBoldStyle(
                                                        color: ColorManager
                                                            .darkBlue,
                                                        fontSize: FontSize.s18,
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              SizedBox(
                                                width: 50,
                                                height: 20,
                                                child: Center(
                                                  child: Text(
                                                    AppStrings.stock,
                                                    style: getBoldStyle(
                                                        color: ColorManager
                                                            .lightGrey2,
                                                        fontSize: FontSize.s12),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(width: 20),
                                        ],
                                      ),
                                      Center(
                                        child: SizedBox(
                                          height: 160,
                                          width: 160,
                                          // child: Image.network(
                                          //     items[0].itemImage))
                                          child: Image.network(
                                            items[0].itemImage,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Image.asset(
                                                ImageAssets.noImages,
                                                fit: BoxFit.cover,
                                              );
                                            },
                                            loadingBuilder: (context, child,
                                                loadingProgress) {
                                              if (loadingProgress == null)
                                                return child;
                                              return Center(
                                                child:
                                                    CircularProgressIndicator(
                                                  value: loadingProgress
                                                              .expectedTotalBytes !=
                                                          null
                                                      ? loadingProgress
                                                              .cumulativeBytesLoaded /
                                                          loadingProgress
                                                              .expectedTotalBytes!
                                                      : null,
                                                ),
                                              );
                                            },
                                          ),
                                        ),
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.all(18.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(items[0].outline,
                                                style: getBoldStyle(
                                                    color:
                                                        ColorManager.darkBlue,
                                                    fontSize: FontSize.s22_5)),
                                            const SizedBox(height: 5),
                                            RichText(
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              text: TextSpan(
                                                text:
                                                    AppStrings.itemCodeDetails,
                                                style: getSemiBoldStyle(
                                                    color: ColorManager.black,
                                                    fontSize: FontSize.s14),
                                                children: [
                                                  TextSpan(
                                                      text: items[0].itemCode,
                                                      style: getRegularStyle(
                                                          color: ColorManager
                                                              .black,
                                                          fontSize:
                                                              FontSize.s14))
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 5),
                                            RichText(
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              text: TextSpan(
                                                text: AppStrings
                                                    .categoryCodeDetails,
                                                style: getSemiBoldStyle(
                                                    color: ColorManager.black,
                                                    fontSize: FontSize.s14),
                                                children: [
                                                  TextSpan(
                                                    text: items[0].categoryCode,
                                                    style: getRegularStyle(
                                                        color:
                                                            ColorManager.black,
                                                        fontSize: FontSize.s14),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            const SizedBox(height: 6),
                                            Text(items[0].description,
                                                style: getRegularStyle(
                                                    color: ColorManager.black,
                                                    fontSize: FontSize.s14)),
                                            const SizedBox(height: 20),

                                            Row(
                                              children: [
                                                const Spacer(),

                                                // QUANTITY
                                                // If catchWeight == true  → full width (dropdown hidden)
                                                // If catchWeight == false → half width + dropdown shown
                                                SizedBox(
                                                  width: (screenWidth - 90) / 2,
                                                  height: 50,
                                                  child: isItemEditable
                                                      ? TextField(
                                                          controller:
                                                              _quantityController,
                                                          focusNode:
                                                              quantityFocusNode,
                                                          style:
                                                              getSemiBoldStyle(
                                                            color: ColorManager
                                                                .black,
                                                            fontSize:
                                                                FontSize.s16,
                                                          ),
                                                          readOnly:
                                                              !isItemEditable,

                                                          // splittable == true  → decimal allowed
                                                          // splittable == false → whole numbers only
                                                          keyboardType:
                                                              const TextInputType
                                                                  .numberWithOptions(
                                                            decimal: true,
                                                          ),
                                                          inputFormatters: [
                                                            DecimalTextInputFormatter(
                                                              decimalPlaces:
                                                                  SharedPrefs()
                                                                      .decimalplacesquantity,
                                                              minValue: 0.0,
                                                              maxValue: double
                                                                  .infinity,
                                                            ),
                                                            LengthLimitingTextInputFormatter(
                                                              AppConstants
                                                                  .maxCharactersForQuantity,
                                                            ),
                                                          ],

                                                          enableInteractiveSelection:
                                                              false,
                                                          maxLines: 1,
                                                          textAlignVertical:
                                                              TextAlignVertical
                                                                  .center,
                                                          decoration:
                                                              InputDecoration(
                                                            isDense: true,
                                                            contentPadding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                              horizontal: 12,
                                                              vertical: 10,
                                                            ),
                                                            labelText: catchWeight &&
                                                                    (items[0]
                                                                            .purchaseUnit
                                                                            ?.trim()
                                                                            .isNotEmpty ??
                                                                        false)
                                                                ? '${AppStrings.quantity} (${items[0].purchaseUnit})'
                                                                : AppStrings
                                                                    .quantity,
                                                            floatingLabelBehavior:
                                                                FloatingLabelBehavior
                                                                    .always,
                                                            floatingLabelStyle:
                                                                getSemiBoldStyle(
                                                              color: ColorManager
                                                                  .lightGrey1,
                                                              fontSize:
                                                                  FontSize.s16,
                                                            ),
                                                            border:
                                                                OutlineInputBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          8),
                                                            ),
                                                          ),
                                                        )
                                                      : _readOnlyField(
                                                          label: catchWeight &&
                                                                  (items[0]
                                                                          .purchaseUnit
                                                                          ?.trim()
                                                                          .isNotEmpty ??
                                                                      false)
                                                              ? '${AppStrings.quantity} (${items[0].purchaseUnit})'
                                                              : AppStrings
                                                                  .quantity,
                                                          value:
                                                              _quantityController
                                                                  .text,
                                                        ),
                                                ),
                                                if (catchWeight) ...[
                                                  const SizedBox(width: 10),
                                                  SizedBox(
                                                    width:
                                                        (screenWidth - 90) / 2,
                                                    height: 50,
                                                    child: isItemEditable
                                                        ? Stack(
                                                            children: [
                                                              TextField(
                                                                controller:
                                                                    _actualWeightController,
                                                                focusNode:
                                                                    actualWeightFocusNode,
                                                                style:
                                                                    getSemiBoldStyle(
                                                                  color:
                                                                      ColorManager
                                                                          .black,
                                                                  fontSize:
                                                                      FontSize
                                                                          .s16,
                                                                ),
                                                                readOnly:
                                                                    !isItemEditable,
                                                                keyboardType:
                                                                    const TextInputType
                                                                        .numberWithOptions(
                                                                        decimal:
                                                                            true),
                                                                inputFormatters: [
                                                                  DecimalTextInputFormatter(
                                                                    decimalPlaces:
                                                                        SharedPrefs()
                                                                            .decimalplacesquantity,
                                                                    minValue:
                                                                        0.0,
                                                                    maxValue: double
                                                                        .infinity,
                                                                  ),
                                                                ],
                                                                decoration:
                                                                    InputDecoration(
                                                                  isDense: true,
                                                                  contentPadding:
                                                                      const EdgeInsets
                                                                          .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical:
                                                                        10,
                                                                  ),
                                                                  labelText:
                                                                      actualWeightLabel,
                                                                  floatingLabelBehavior:
                                                                      FloatingLabelBehavior
                                                                          .always,
                                                                  floatingLabelStyle:
                                                                      getSemiBoldStyle(
                                                                    color: ColorManager
                                                                        .lightGrey1,
                                                                    fontSize:
                                                                        FontSize
                                                                            .s16,
                                                                  ),
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                ),
                                                              ),
                                                              Positioned(
                                                                right: 0,
                                                                top: 0,
                                                                child:
                                                                    CustomPaint(
                                                                  size:
                                                                      const Size(
                                                                          12,
                                                                          12),
                                                                  painter:
                                                                      _RedTrianglePainter(),
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        : _readOnlyField(
                                                            label:
                                                                actualWeightLabel,
                                                            value:
                                                                _actualWeightController
                                                                    .text,
                                                          ),
                                                  ),
                                                ],
// Show unit field ONLY when catchWeight == false
                                                if (!catchWeight) ...[
                                                  const SizedBox(width: 10),
                                                  SizedBox(
                                                    width:
                                                        (screenWidth - 90) / 2,
                                                    height: 50,
                                                    child: isItemEditable
                                                        ? (splittable
                                                            //  splittable == true → enabled dropdown (purchase + inventory)
                                                            ? DropdownButtonFormField<
                                                                int>(
                                                                value:
                                                                    selectedUnitId,
                                                                isExpanded:
                                                                    true,
                                                                decoration:
                                                                    InputDecoration(
                                                                  contentPadding:
                                                                      const EdgeInsets
                                                                          .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical:
                                                                        10,
                                                                  ),
                                                                  labelText:
                                                                      'Select Unit',
                                                                  floatingLabelBehavior:
                                                                      FloatingLabelBehavior
                                                                          .always,
                                                                  floatingLabelStyle:
                                                                      getSemiBoldStyle(
                                                                    color: ColorManager
                                                                        .lightGrey1,
                                                                    fontSize:
                                                                        FontSize
                                                                            .s16,
                                                                  ),
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                ),
                                                                icon: const Icon(
                                                                    Icons
                                                                        .arrow_drop_down),
                                                                items: unitList
                                                                    .map(
                                                                        (unit) {
                                                                  return DropdownMenuItem<
                                                                      int>(
                                                                    value: unit[
                                                                            'id']
                                                                        as int,
                                                                    child: Text(
                                                                      unit['name']
                                                                              ?.toString() ??
                                                                          '',
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style:
                                                                          getSemiBoldStyle(
                                                                        color: ColorManager
                                                                            .black,
                                                                        fontSize:
                                                                            FontSize.s16,
                                                                      ),
                                                                    ),
                                                                  );
                                                                }).toList(),
                                                                onChanged:
                                                                    isItemEditable
                                                                        ? (int?
                                                                            value) {
                                                                            if (value ==
                                                                                null)
                                                                              return;

                                                                            final selected =
                                                                                unitList.firstWhere(
                                                                              (unit) => unit['id'] == value,
                                                                            );

                                                                            setState(() {
                                                                              selectedUnitId = selected['id'] as int?;
                                                                              selectedUnit = selected['name']?.toString();
                                                                              selectedUnitType = selected['type']?.toString();
                                                                            });

                                                                            LoggerData.dataLog('Selected Unit: $selectedUnit');
                                                                            LoggerData.dataLog('Selected Unit ID: $selectedUnitId');
                                                                            LoggerData.dataLog('Selected Unit Type: $selectedUnitType');
                                                                          }
                                                                        : null,
                                                              )
                                                            //  splittable == false → disabled field showing only Purchase Unit
                                                            : DropdownButtonFormField<
                                                                int>(
                                                                value:
                                                                    selectedUnitId,
                                                                isExpanded:
                                                                    true,
                                                                // disabled dropdown (onChanged: null)
                                                                onChanged: null,
                                                                decoration:
                                                                    InputDecoration(
                                                                  contentPadding:
                                                                      const EdgeInsets
                                                                          .symmetric(
                                                                    horizontal:
                                                                        12,
                                                                    vertical:
                                                                        10,
                                                                  ),
                                                                  labelText:
                                                                      'Select Unit',
                                                                  floatingLabelBehavior:
                                                                      FloatingLabelBehavior
                                                                          .always,
                                                                  floatingLabelStyle:
                                                                      getSemiBoldStyle(
                                                                    color: ColorManager
                                                                        .lightGrey1,
                                                                    fontSize:
                                                                        FontSize
                                                                            .s16,
                                                                  ),
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(8),
                                                                  ),
                                                                  // grey out visually since it's disabled
                                                                  filled: true,
                                                                  fillColor: ColorManager
                                                                      .grey
                                                                      .withOpacity(
                                                                          0.1),
                                                                ),
                                                                icon: Icon(
                                                                  Icons
                                                                      .arrow_drop_down,
                                                                  color: ColorManager
                                                                      .lightGrey1,
                                                                ),
                                                                items: unitList
                                                                    .map(
                                                                        (unit) {
                                                                  return DropdownMenuItem<
                                                                      int>(
                                                                    value: unit[
                                                                            'id']
                                                                        as int,
                                                                    child: Text(
                                                                      unit['name']
                                                                              ?.toString() ??
                                                                          '',
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                      style:
                                                                          getSemiBoldStyle(
                                                                        color: ColorManager
                                                                            .black,
                                                                        fontSize:
                                                                            FontSize.s16,
                                                                      ),
                                                                    ),
                                                                  );
                                                                }).toList(),
                                                              ))
                                                        : _readOnlyField(
                                                            label:
                                                                'Select Unit',
                                                            value:
                                                                selectedUnit ??
                                                                    '',
                                                          ),
                                                  )
                                                ],
                                                const Spacer(),
                                              ],
                                            ), // const SizedBox(height: 20),
                                            if (catchWeight &&
                                                items.isNotEmpty &&
                                                items[0].purchaseUnitID != null)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 2, right: 4),
                                                child: Align(
                                                  alignment:
                                                      Alignment.centerRight,
                                                  child: Text(
                                                    "1 ${items[0].purchaseUnit} = ${formatQuantityString(items[0].purchaseUnitConversion)} ${items[0].standardUnit}",
                                                    style: getSemiBoldStyle(
                                                      color:
                                                          ColorManager.darkGrey,
                                                      fontSize: FontSize.s12,
                                                    ),
                                                    textAlign: TextAlign.right,
                                                  ),
                                                ),
                                              ),
                                            // // ACTUAL WEIGHT
                                            // catchWeight
                                            //     ? Column(
                                            //         children: [
                                            //           const SizedBox(
                                            //               height: 20),
                                            //           Center(
                                            //             child: SizedBox(
                                            //               width:
                                            //                   screenWidth - 80,
                                            //               height: 50,
                                            //               child: Stack(
                                            //                 children: [
                                            //                   // Actual Weight TextField
                                            //                   TextField(
                                            //                     controller:
                                            //                         _actualWeightController,
                                            //                     focusNode:
                                            //                         actualWeightFocusNode,
                                            //                     style:
                                            //                         getSemiBoldStyle(
                                            //                       color:
                                            //                           ColorManager
                                            //                               .black,
                                            //                       fontSize:
                                            //                           FontSize
                                            //                               .s17,
                                            //                     ),
                                            //                     readOnly:
                                            //                         !isItemEditable,
                                            //                     keyboardType:
                                            //                         const TextInputType
                                            //                             .numberWithOptions(
                                            //                       decimal: true,
                                            //                     ),
                                            //                     inputFormatters: [
                                            //                       DecimalTextInputFormatter(
                                            //                         decimalPlaces:
                                            //                             SharedPrefs()
                                            //                                 .decimalplacesquantity,
                                            //                         minValue:
                                            //                             0.0,
                                            //                         maxValue: double
                                            //                             .infinity,
                                            //                       ),
                                            //                     ],
                                            //                     decoration:
                                            //                         InputDecoration(
                                            //                       isDense: true,
                                            //                       contentPadding:
                                            //                           const EdgeInsets
                                            //                               .symmetric(
                                            //                         horizontal:
                                            //                             12,
                                            //                         vertical:
                                            //                             10,
                                            //                       ),
                                            //                       labelText:
                                            //                           actualWeightLabel,
                                            //                       floatingLabelBehavior:
                                            //                           FloatingLabelBehavior
                                            //                               .always,
                                            //                       floatingLabelStyle:
                                            //                           getSemiBoldStyle(
                                            //                         color: ColorManager
                                            //                             .lightGrey1,
                                            //                         fontSize:
                                            //                             FontSize
                                            //                                 .s17,
                                            //                       ),
                                            //                       border:
                                            //                           const OutlineInputBorder(),
                                            //                     ),
                                            //                   ),

                                            //                   // Red triangle indicator (top-right corner)
                                            //                   Positioned(
                                            //                     right: 0,
                                            //                     top: 0,
                                            //                     child:
                                            //                         CustomPaint(
                                            //                       size:
                                            //                           const Size(
                                            //                               12,
                                            //                               12),
                                            //                       painter:
                                            //                           _RedTrianglePainter(),
                                            //                     ),
                                            //                   ),
                                            //                 ],
                                            //               ),
                                            //             ),
                                            //           ),

                                            //           // Note below actual weight field
                                            //           if (items.isNotEmpty &&
                                            //               items[0].purchaseUnitID !=
                                            //                   null)
                                            //             SizedBox(
                                            //               width:
                                            //                   screenWidth - 80,
                                            //               child: Padding(
                                            //                 padding:
                                            //                     const EdgeInsets
                                            //                         .only(
                                            //                         top: 6),
                                            //                 child: Text(
                                            //                   "1 ${items[0].purchaseUnit} = ${formatQuantityString(items[0].purchaseUnitConversion)} ${items[0].standardUnit}",
                                            //                   style:
                                            //                       getSemiBoldStyle(
                                            //                     color: ColorManager
                                            //                         .lightGrey2,
                                            //                     fontSize:
                                            //                         FontSize
                                            //                             .s12,
                                            //                   ),
                                            //                   textAlign:
                                            //                       TextAlign
                                            //                           .right,
                                            //                 ),
                                            //               ),
                                            //             ),
                                            //         ],
                                            //       )
                                            //     : const SizedBox.shrink(),

                                            items[0].basePrice <= 0
                                                ? Column(
                                                    children: [
                                                      const SizedBox(
                                                          height: 10),
                                                      Row(
                                                        crossAxisAlignment:
                                                            CrossAxisAlignment
                                                                .start,
                                                        children: [
                                                          const Spacer(),

                                                          // PRICE - LEFT
                                                          SizedBox(
                                                            width:
                                                                (screenWidth -
                                                                        90) /
                                                                    2,
                                                            height: 50,
                                                            child: isItemEditable
                                                                ? TextField(
                                                                    focusNode:
                                                                        priceFocusNode,
                                                                    controller:
                                                                        _priceController,
                                                                    style:
                                                                        getSemiBoldStyle(
                                                                      color: ColorManager
                                                                          .black,
                                                                      fontSize:
                                                                          FontSize
                                                                              .s16,
                                                                    ),
                                                                    readOnly:
                                                                        !isItemEditable,
                                                                    keyboardType:
                                                                        const TextInputType
                                                                            .numberWithOptions(
                                                                      decimal:
                                                                          true,
                                                                    ),
                                                                    inputFormatters: [
                                                                      LengthLimitingTextInputFormatter(
                                                                        AppConstants
                                                                            .maxCharactersForPrice,
                                                                      ),
                                                                    ],
                                                                    decoration:
                                                                        InputDecoration(
                                                                      contentPadding:
                                                                          const EdgeInsets
                                                                              .symmetric(
                                                                        horizontal:
                                                                            12,
                                                                        vertical:
                                                                            10,
                                                                      ),
                                                                      labelText:
                                                                          AppStrings
                                                                              .price,
                                                                      floatingLabelBehavior:
                                                                          FloatingLabelBehavior
                                                                              .always,
                                                                      floatingLabelStyle:
                                                                          getSemiBoldStyle(
                                                                        color: ColorManager
                                                                            .lightGrey1,
                                                                        fontSize:
                                                                            FontSize.s16,
                                                                      ),
                                                                      border:
                                                                          OutlineInputBorder(
                                                                        borderRadius:
                                                                            BorderRadius.circular(8.0),
                                                                      ),
                                                                    ),
                                                                  )
                                                                : _readOnlyField(
                                                                    label: AppStrings
                                                                        .price,
                                                                    value:
                                                                        _priceController
                                                                            .text,
                                                                  ),
                                                          ),

                                                          const SizedBox(
                                                              width: 10),

                                                          // DATE - RIGHT
                                                          SizedBox(
                                                            width:
                                                                (screenWidth -
                                                                        90) /
                                                                    2,
                                                            height: 50,
                                                            child: TextField(
                                                              controller:
                                                                  _dateController,
                                                              style:
                                                                  getSemiBoldStyle(
                                                                color:
                                                                    ColorManager
                                                                        .black,
                                                                fontSize:
                                                                    FontSize
                                                                        .s16,
                                                              ),
                                                              readOnly: true,
                                                              // decoration:
                                                              //     InputDecoration(
                                                              //   isDense: true,
                                                              //   contentPadding:
                                                              //       const EdgeInsets
                                                              //           .symmetric(
                                                              //     horizontal: 12,
                                                              //     vertical: 10,
                                                              //   ),
                                                              //   suffixIcon:
                                                              //       isItemEditable
                                                              //           ? IconButton(
                                                              //               onPressed:
                                                              //                   () =>
                                                              //                       _selectDate(context),
                                                              //               icon:
                                                              //                   SizedBox(
                                                              //                 width:
                                                              //                     25,
                                                              //                 height:
                                                              //                     25,
                                                              //                 child:
                                                              //                     Image.asset(
                                                              //                   ImageAssets.calendarIcon,
                                                              //                   fit:
                                                              //                       BoxFit.contain,
                                                              //                 ),
                                                              //               ),
                                                              //             )
                                                              //           : null,
                                                              //   labelText:
                                                              //       AppStrings.date,
                                                              //   floatingLabelBehavior:
                                                              //       FloatingLabelBehavior
                                                              //           .always,
                                                              //   floatingLabelStyle:
                                                              //       getSemiBoldStyle(
                                                              //     color: ColorManager
                                                              //         .lightGrey1,
                                                              //     fontSize:
                                                              //         FontSize.s16,
                                                              //   ),
                                                              //   border:
                                                              //       const OutlineInputBorder(),
                                                              // ),
                                                              decoration:
                                                                  _applyReadOnlyStyle(
                                                                InputDecoration(
                                                                  isDense: true,
                                                                  contentPadding: const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          10),
                                                                  suffixIcon:
                                                                      isItemEditable
                                                                          ? IconButton(
                                                                              onPressed: () => _selectDate(context),
                                                                              icon: SizedBox(
                                                                                width: 25,
                                                                                height: 25,
                                                                                child: Image.asset(
                                                                                  ImageAssets.calendarIcon,
                                                                                  fit: BoxFit.contain,
                                                                                ),
                                                                              ),
                                                                            )
                                                                          : null,
                                                                  labelText:
                                                                      AppStrings
                                                                          .date,
                                                                  floatingLabelBehavior:
                                                                      FloatingLabelBehavior
                                                                          .always,
                                                                  floatingLabelStyle:
                                                                      getSemiBoldStyle(
                                                                    color: ColorManager
                                                                        .lightGrey1,
                                                                    fontSize:
                                                                        FontSize
                                                                            .s16,
                                                                  ),
                                                                  border:
                                                                      OutlineInputBorder(
                                                                    borderRadius:
                                                                        BorderRadius.circular(
                                                                            8.0),
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ),

                                                          const Spacer(),
                                                        ],
                                                      ),
                                                    ],
                                                  )
                                                : Column(
                                                    children: [
                                                      const SizedBox(height: 5),
                                                      SizedBox(
                                                        // PRICE EXISTS → ONLY DATE
                                                        width: screenWidth - 80,
                                                        height: 50,
                                                        child: TextField(
                                                          controller:
                                                              _dateController,
                                                          style:
                                                              getSemiBoldStyle(
                                                            color: ColorManager
                                                                .black,
                                                            fontSize:
                                                                FontSize.s17,
                                                          ),
                                                          readOnly: true,
                                                          // decoration:
                                                          //     InputDecoration(
                                                          //   isDense: true,
                                                          //   contentPadding:
                                                          //       const EdgeInsets
                                                          //           .symmetric(
                                                          //     horizontal: 12,
                                                          //     vertical: 10,
                                                          //   ),
                                                          //   suffixIcon:
                                                          //       isItemEditable
                                                          //           ? IconButton(
                                                          //               onPressed: () =>
                                                          //                   _selectDate(
                                                          //                       context),
                                                          //               icon:
                                                          //                   SizedBox(
                                                          //                 width: 25,
                                                          //                 height:
                                                          //                     25,
                                                          //                 child: Image
                                                          //                     .asset(
                                                          //                   ImageAssets
                                                          //                       .calendarIcon,
                                                          //                   fit: BoxFit
                                                          //                       .contain,
                                                          //                 ),
                                                          //               ),
                                                          //             )
                                                          //           : null,
                                                          //   labelText:
                                                          //       AppStrings.date,
                                                          //   floatingLabelBehavior:
                                                          //       FloatingLabelBehavior
                                                          //           .always,
                                                          //   floatingLabelStyle:
                                                          //       getSemiBoldStyle(
                                                          //     color: ColorManager
                                                          //         .lightGrey1,
                                                          //     fontSize:
                                                          //         FontSize.s16,
                                                          //   ),
                                                          //   border:
                                                          //       const OutlineInputBorder(),
                                                          // ),
                                                          decoration:
                                                              _applyReadOnlyStyle(
                                                            InputDecoration(
                                                              isDense: true,
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                      horizontal:
                                                                          12,
                                                                      vertical:
                                                                          10),
                                                              suffixIcon:
                                                                  isItemEditable
                                                                      ? IconButton(
                                                                          onPressed: () =>
                                                                              _selectDate(context),
                                                                          icon:
                                                                              SizedBox(
                                                                            width:
                                                                                25,
                                                                            height:
                                                                                25,
                                                                            child:
                                                                                Image.asset(
                                                                              ImageAssets.calendarIcon,
                                                                              fit: BoxFit.contain,
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : null,
                                                              labelText:
                                                                  AppStrings
                                                                      .date,
                                                              floatingLabelBehavior:
                                                                  FloatingLabelBehavior
                                                                      .always,
                                                              floatingLabelStyle:
                                                                  getSemiBoldStyle(
                                                                color: ColorManager
                                                                    .lightGrey1,
                                                                fontSize:
                                                                    FontSize
                                                                        .s16,
                                                              ),
                                                              border:
                                                                  OutlineInputBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                            const SizedBox(height: 15),
                                            // SizedBox(
                                            //   width: screenWidth - 80,
                                            //   height: 80,
                                            //   child: Stack(
                                            //     children: [
                                            //       TextField(
                                            //         controller:
                                            //             _commmentsController,
                                            //         style: getSemiBoldStyle(
                                            //           color: ColorManager.black,
                                            //           fontSize: FontSize.s16,
                                            //         ),
                                            //         readOnly: isItemEditable
                                            //             ? false
                                            //             : true,
                                            //         maxLines: null,
                                            //         expands: true,
                                            //         inputFormatters: [
                                            //           LengthLimitingTextInputFormatter(
                                            //             AppConstants
                                            //                 .maxCharactersForCommentItemDetails, // Make sure this is 250
                                            //           ),
                                            //         ],
                                            //         decoration: InputDecoration(
                                            //           contentPadding:
                                            //               const EdgeInsets.all(
                                            //                   20),
                                            //           labelText:
                                            //               AppStrings.comments,
                                            //           floatingLabelBehavior:
                                            //               FloatingLabelBehavior
                                            //                   .always,
                                            //           floatingLabelStyle:
                                            //               getSemiBoldStyle(
                                            //             color: ColorManager
                                            //                 .lightGrey1,
                                            //             fontSize: FontSize.s16,
                                            //           ),
                                            //         ),
                                            //         onChanged: (value) {
                                            //           // Trigger rebuild to update character count
                                            //           setState(() {});
                                            //         },
                                            //       ),
                                            //       // Required triangle indicator
                                            //       Positioned(
                                            //         right: 0,
                                            //         top: 0,
                                            //         child: CustomPaint(
                                            //           size: const Size(12, 12),
                                            //           painter:
                                            //               _RedTrianglePainter(),
                                            //         ),
                                            //       ),
                                            //     ],
                                            //   ),
                                            // ),
                                            SizedBox(
                                              width: screenWidth - 80,
                                              height: 80,
                                              child: Stack(
                                                children: [
                                                  TextField(
                                                    controller:
                                                        _commmentsController,
                                                    style: getSemiBoldStyle(
                                                      color: ColorManager.black,
                                                      fontSize: FontSize.s16,
                                                    ),
                                                    readOnly:
                                                        !isItemEditable, // still keep this so keyboard doesn't open
                                                    maxLines: null,
                                                    expands: true,
                                                    inputFormatters: [
                                                      LengthLimitingTextInputFormatter(
                                                        AppConstants
                                                            .maxCharactersForCommentItemDetails,
                                                      ),
                                                    ],
                                                    decoration:
                                                        _applyReadOnlyStyle(
                                                      InputDecoration(
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .all(20),
                                                        labelText:
                                                            AppStrings.comments,
                                                        floatingLabelBehavior:
                                                            FloatingLabelBehavior
                                                                .always,
                                                        floatingLabelStyle:
                                                            getSemiBoldStyle(
                                                          color: ColorManager
                                                              .lightGrey1,
                                                          fontSize:
                                                              FontSize.s16,
                                                        ),
                                                      ),
                                                    ),
                                                    onChanged: (value) {
                                                      setState(() {});
                                                    },
                                                  ),
                                                  // Only show the required-triangle when editable
                                                  if (isItemEditable)
                                                    Positioned(
                                                      right: 0,
                                                      top: 0,
                                                      child: CustomPaint(
                                                        size:
                                                            const Size(12, 12),
                                                        painter:
                                                            _RedTrianglePainter(),
                                                      ),
                                                    ),
                                                ],
                                              ),
                                            ),
// Character counter positioned below the comment box
                                            Padding(
                                              padding: const EdgeInsets.only(
                                                  top: 4, right: 4),
                                              child: Align(
                                                alignment:
                                                    Alignment.centerRight,
                                                child: Text(
                                                  "Characters remaining: ${AppConstants.maxCharactersForCommentItemDetails - _commmentsController.text.length}",
                                                  style: TextStyle(
                                                    fontSize: FontSize.s12,
                                                    color: _commmentsController
                                                                .text.length >=
                                                            AppConstants
                                                                .maxCharactersForCommentItemDetails
                                                        ? ColorManager.red
                                                        : (AppConstants.maxCharactersForCommentItemDetails -
                                                                    _commmentsController
                                                                        .text
                                                                        .length) <=
                                                                20
                                                            ? Colors.orange
                                                            : ColorManager
                                                                .darkGrey,
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

                                            const SizedBox(height: 10),
                                            items[0].note.isNotEmpty
                                                ? Text(items[0].note,
                                                    style: getRegularStyle(
                                                        color: ColorManager
                                                            .lightGrey2,
                                                        fontSize: FontSize.s12))
                                                : const SizedBox(),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                //const SizedBox(height: 10),
                                isItemEditable
                                    ? Padding(
                                        padding: const EdgeInsets.all(0.0),
                                        child: Container(
                                          color: ColorManager.white,
                                          width: screenWidth,
                                          //  height: 100,
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 2, 0, 20),
                                            child: Column(
                                              children: [
                                                const SizedBox(height: 2),
                                                Row(
                                                  children: [
                                                    const Spacer(),
                                                    CustomTextActionButton(
                                                        buttonText:
                                                            AppStrings.itemsIn,
                                                        backgroundColor:
                                                            ColorManager.green,
                                                        borderColor:
                                                            Colors.transparent,
                                                        fontColor:
                                                            ColorManager.white,
                                                        buttonWidth:
                                                            (screenWidth *
                                                                    0.5) -
                                                                35,
                                                        buttonHeight: 50,
                                                        isBoldFont: true,
                                                        fontSize: FontSize.s20,
                                                        onTap: () {
                                                          validateItemsIN();
                                                        }),
                                                    const SizedBox(width: 10),
                                                    CustomTextActionButton(
                                                        buttonText:
                                                            AppStrings.itemsOut,
                                                        backgroundColor:
                                                            ColorManager.red,
                                                        borderColor:
                                                            Colors.transparent,
                                                        fontColor:
                                                            ColorManager.white,
                                                        buttonWidth:
                                                            (screenWidth *
                                                                    0.5) -
                                                                35,
                                                        buttonHeight: 50,
                                                        isBoldFont: true,
                                                        fontSize: FontSize.s20,
                                                        onTap: () {
                                                          validateItemsOUT();
                                                        }),
                                                    const Spacer(),
                                                  ],
                                                ),
                                                const SizedBox(height: 5),
                                              ],
                                            ),
                                          ),
                                        ),
                                      )
                                    : const SizedBox(height: 10),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20)
                      ],
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
