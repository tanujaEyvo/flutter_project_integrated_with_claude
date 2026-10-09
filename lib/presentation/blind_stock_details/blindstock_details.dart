import 'dart:developer';

import 'package:eyvo_v3/api/api_service/api_service.dart';
import 'package:eyvo_v3/api/response_models/item_details_response.dart';
import 'package:eyvo_v3/api/response_models/update_blind_stock.dart';
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
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class BlindStockDetailsView extends StatefulWidget {
  final int? itemId;
  final String? resultString;
  final EntryType entryType;
  final String? scanFormat;
  const BlindStockDetailsView(
      {super.key,
      this.resultString,
      this.itemId,
      required this.entryType,
      this.scanFormat});

  @override
  State<BlindStockDetailsView> createState() => _BlindStockDetailsViewState();
}

enum EntryType {
  listing,
  scan,
}

class _BlindStockDetailsViewState extends State<BlindStockDetailsView> {
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _commmentsController = TextEditingController();
  final TextEditingController _physicalQtyController = TextEditingController();
  final TextEditingController _actualWeightController = TextEditingController();

  final FocusNode physicalQtyFocusNode = FocusNode();

  late List<ItemDetails> items = [];
  bool isItemEditable = false;
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
  // Unit dropdown variables
  List<Map<String, dynamic>> unitList = [];
  bool catchWeight = false;
  bool splittable = false;
  String actualWeightLabel = "";
  String? selectedUnitType;

  int? itemType;

  @override
  void initState() {
    super.initState();
    _physicalQtyController.text = formatQuantityString(1.00);
    _dateController.text = DateFormat('dd-MMM-yyyy').format(selectedDate);
    _priceController.text = getFormattedStringPrice(0.0);
    _actualWeightController.text = formatQuantityString(1.00);
    if (widget.entryType == EntryType.scan) {
      scanItem();
    } else {
      fetchItemDetails();
    }
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
    priceFocusNode.dispose();
    quantityFocusNode.dispose();
    _quantityController.dispose();
    actualWeightFocusNode.dispose();
    _dateController.dispose();
    _priceController.dispose();
    _commmentsController.dispose();
    _physicalQtyController.dispose();
    physicalQtyFocusNode.dispose();
    SharedPrefs().isItemScanned = false;
    _actualWeightController.dispose();
    super.dispose();
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

    // if splittable is false → ONLY purchase unit
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

  void _performQuantityActionOnFocusChanged() {
    if (_quantityController.text.isNotEmpty) {
      _quantityController.text = getDefaultString(_quantityController.text);
      _quantityController.text =
          getFormattedString(double.parse(_quantityController.text));
    } else {
      _quantityController.text = getFormattedString(1);
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
  /// Loads item data by scanning a barcode/QR value.
  void scanItem() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

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
      "pagefrom": 'blindstock',
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
          itemType = items[0].itemType;

          catchWeight = items[0].catchWeight ?? false;
          splittable = items[0].splittable ?? false;
          actualWeightLabel = items[0].actualWeightLabel ?? "";
          _physicalQtyController.text = formatQuantityString(1);
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
    }
  }

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

    final jsonResponse = await apiService.postRequest(
        context, ApiService.blindStockDetails, data);
    if (jsonResponse != null) {
      final response = ItemDetailsResponse.fromJson(jsonResponse);
      setState(() {
        if (response.code == '200') {
          items = response.data;
          _priceController.text =
              getFormattedPriceStringPrice(items[0].basePrice);
          isItemEditable = items[0].itemEdit;
          _currentItemId = items[0].itemId;
          // Save item_type for later use
          itemType = items[0].itemType;
          catchWeight = items[0].catchWeight ?? false;
          // catchWeight = true;
          splittable = items[0].splittable ?? false;
          // splittable = true;
          actualWeightLabel = items[0].actualWeightLabel ?? "";
          // actualWeightLabel = 'abc';
          _setUnitList(items[0]);
          _physicalQtyController.text = formatQuantityString(1);
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

  String getFormattedPriceStringPricetwo(double price) {
    var priceFormatter =
        NumberFormat.currency(locale: 'en_US', symbol: '', decimalDigits: 2);
    return priceFormatter.format(price);
  }

  void _formatPhysicalQty() {
    if (_physicalQtyController.text.trim().isEmpty) {
      _physicalQtyController.text = formatQuantityString(1.0);
      return;
    }
    final double value = parseQuantityString(_physicalQtyController.text);
    _physicalQtyController.text = formatQuantityString(value);
  }

  void updateBlindStack() async {
    if (widget.itemId == null && _currentItemId == null) {
      showErrorDialog(context, "Item ID is missing", false);
      return;
    }

    double adjustQuantity = double.tryParse(
          _physicalQtyController.text.trim().replaceAll(',', ''),
        ) ??
        0.00;

    String notes = _commmentsController.text.trim();

    if (_physicalQtyController.text.trim().isEmpty) {
      showErrorDialog(context, "Physical Quantity cannot be empty.", false);
      return;
    }
    if (catchWeight) {
      final String actualWeightText = _actualWeightController.text.trim();
      final double actualWeight =
          double.tryParse(actualWeightText.replaceAll(',', '')) ?? 0;

      if (actualWeightText.isEmpty || actualWeight <= 0) {
        showErrorDialog(
          context,
          "$actualWeightLabel should be greater than 0.",
          false,
        );
        return;
      }
    }
    setState(() {
      isLoading = true;
    });

    int itemIdToUse;
    if (widget.entryType == EntryType.scan) {
      // For scan, use the stored item ID from the scanned item
      itemIdToUse = _currentItemId ?? 0;
    } else {
      // For listing, use the widget.itemId
      itemIdToUse = widget.itemId ?? 0;
    }

    if (itemIdToUse == 0) {
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
      "itemid": itemIdToUse,
      "adjustquantity": adjustQuantity,
      "locationid": SharedPrefs().isItemScanned
          ? SharedPrefs().scannedLocationID
          : SharedPrefs().selectedLocationID,
      "notes": notes,
      "uid": SharedPrefs().uID,
      "itemtype": itemType,
      "actualweight": actualWeight,
      "regionid": SharedPrefs().selectedRegionID,
      "unitType": selectedUnitType,
    };

    final jsonResponse = await apiService.postRequest(
      context,
      ApiService.updateBlindStock,
      data,
    );

    if (jsonResponse != null) {
      final response = UpdateBlindStockResponse.fromJson(jsonResponse);
      setState(() {
        isLoading = false;
        if (response.code == '200') {
          showSuccessDialog(
            context,
            ImageAssets.successfulIcon,
            '',
            response.message.join(', '),
            true,
          );
        } else {
          showErrorDialog(context, response.message.join(', '), false);
        }
      });
    } else {
      setState(() {
        isLoading = false;
      });
      showErrorDialog(context, 'Failed to connect to server', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.sizeOf(context).width;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: ColorManager.primary,
        appBar: buildCommonAppBar(
          context: context,
          title: "Blind Stock Details",
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
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 16),
                                  child: Text(
                                    errorText,
                                    textAlign: TextAlign.center,
                                    style: getRegularStyle(
                                      color: ColorManager.lightGrey,
                                      fontSize: FontSize.s17,
                                    ),
                                  ),
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
                                      const SizedBox(height: 20),
                                      Column(
                                        children: [
                                          ConstrainedBox(
                                            constraints: const BoxConstraints(
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
                                                      color: ColorManager.black,
                                                      fontSize: FontSize.s14,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Center(
                                        child: SizedBox(
                                          height: 160,
                                          width: 160,
                                          child: (items[0].itemImage.isNotEmpty)
                                              ? Image.network(
                                                  items[0].itemImage,
                                                  errorBuilder: (context, error,
                                                      stackTrace) {
                                                    // If URL is invalid or fails to load
                                                    return Image.asset(
                                                        ImageAssets.noImages);
                                                  },
                                                )
                                              : Image.asset(
                                                  ImageAssets.noImages),
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
                                            const SizedBox(height: 5),
                                            Divider(
                                              height: 0.2,
                                              thickness: 0.4,
                                              color: ColorManager.lightBlue2,
                                            ),
                                            const SizedBox(height: 5),
                                            Text(items[0].description,
                                                style: getRegularStyle(
                                                    color: ColorManager.black,
                                                    fontSize: FontSize.s14)),
                                            const SizedBox(height: 5),
                                            Divider(
                                              height: 0.2,
                                              thickness: 0.4,
                                              color: ColorManager.lightBlue2,
                                            ),

                                            const SizedBox(height: 20),

                                            //   Physical Quantity Block with Unit Dropdown on the right side
                                            Row(
                                              children: [
                                                // Physical Quantity TextField (Left side)
                                                // If catchWeight == true → take full width (no dropdown shown)
                                                // If catchWeight == false → take half width, dropdown shown on right
                                                Expanded(
                                                  flex: catchWeight ? 1 : 1,
                                                  child: SizedBox(
                                                    height: 50,
                                                    child: TextField(
                                                      focusNode:
                                                          physicalQtyFocusNode,
                                                      controller:
                                                          _physicalQtyController,
                                                      style: getSemiBoldStyle(
                                                        color:
                                                            ColorManager.black,
                                                        fontSize: FontSize.s16,
                                                      ),
                                                      readOnly: isItemEditable
                                                          ? false
                                                          : true,
                                                      keyboardType:
                                                          const TextInputType
                                                              .numberWithOptions(
                                                              decimal: true),
                                                      inputFormatters: [
                                                        DecimalTextInputFormatter(
                                                          decimalPlaces:
                                                              SharedPrefs()
                                                                  .decimalplacesquantity,
                                                          minValue: 0.0,
                                                          maxValue:
                                                              double.infinity,
                                                        ),
                                                        LengthLimitingTextInputFormatter(
                                                          AppConstants
                                                              .maxCharactersForQuantity,
                                                        ),
                                                      ],
                                                     
                                                      onEditingComplete: () {
                                                        _formatPhysicalQty();
                                                      },
                                                      decoration:
                                                          InputDecoration(
                                                        contentPadding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                          horizontal: 16,
                                                          vertical: 12,
                                                        ),
                                                        // labelText:
                                                        //     "Physical Quantity",
                                                        labelText: catchWeight &&
                                                                (items[0]
                                                                        .purchaseUnit
                                                                        ?.trim()
                                                                        .isNotEmpty ??
                                                                    false)
                                                            ? "Physical Qty (${items[0].purchaseUnit})"
                                                            : "Physical Qty",
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
                                                                  .circular(4),
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
                                                            focusNode:
                                                                actualWeightFocusNode,
                                                            style:
                                                                getSemiBoldStyle(
                                                              color:
                                                                  ColorManager
                                                                      .black,
                                                              fontSize:
                                                                  FontSize.s16,
                                                            ),
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
                                                                minValue: 0.0,
                                                                maxValue: double
                                                                    .infinity,
                                                              ),
                                                            ],
                                                            decoration:
                                                                InputDecoration(
                                                              contentPadding:
                                                                  const EdgeInsets
                                                                      .symmetric(
                                                                horizontal: 12,
                                                                vertical: 10,
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
                                                                        .circular(
                                                                  screenHeight *
                                                                      0.01,
                                                                ),
                                                              ),
                                                              filled: true,
                                                              fillColor:
                                                                  Colors.white,
                                                            ),
                                                          ),
                                                          Positioned(
                                                            right: 0,
                                                            top: 0,
                                                            child: CustomPaint(
                                                              size: const Size(
                                                                  12, 12),
                                                              painter:
                                                                  _RedTrianglePainter(),
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
                                                      width:
                                                          (screenWidth * 0.6) -
                                                              45,
                                                      height: 50,
                                                      child: splittable
                                                          //  splittable == true → enabled dropdown (purchase + inventory)
                                                          ? DropdownButtonFormField<
                                                              int>(
                                                              value:
                                                                  selectedUnitId,
                                                              isExpanded: true,
                                                              decoration:
                                                                  InputDecoration(
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 10,
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
                                                                    const OutlineInputBorder(),
                                                              ),
                                                              icon: const Icon(Icons
                                                                  .arrow_drop_down),
                                                              items: unitList
                                                                  .map((unit) {
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
                                                                          FontSize
                                                                              .s16,
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
                                                                            (unit) =>
                                                                                unit['id'] ==
                                                                                value,
                                                                          );

                                                                          setState(
                                                                              () {
                                                                            selectedUnitId =
                                                                                selected['id'] as int?;
                                                                            selectedUnit =
                                                                                selected['name']?.toString();
                                                                            selectedUnitType =
                                                                                selected['type']?.toString();
                                                                          });

                                                                          LoggerData.dataLog(
                                                                              'Selected Unit: $selectedUnit');
                                                                          LoggerData.dataLog(
                                                                              'Selected Unit ID: $selectedUnitId');
                                                                          LoggerData.dataLog(
                                                                              'Selected Unit Type: $selectedUnitType');
                                                                        }
                                                                      : null,
                                                            )
                                                          //  splittable == false → disabled field showing only Purchase Unit
                                                          : DropdownButtonFormField<
                                                              int>(
                                                              value:
                                                                  selectedUnitId,
                                                              isExpanded: true,
                                                              // disabled dropdown (onChanged: null)
                                                              onChanged: null,
                                                              decoration:
                                                                  InputDecoration(
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .symmetric(
                                                                  horizontal:
                                                                      12,
                                                                  vertical: 10,
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
                                                                    const OutlineInputBorder(),
                                                                filled: true,
                                                                fillColor:
                                                                    ColorManager
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
                                                                  .map((unit) {
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
                                                                          FontSize
                                                                              .s16,
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
                                            if (catchWeight &&
                                                items.isNotEmpty &&
                                                items[0].purchaseUnitID != null)
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 6),
                                                child: Row(
                                                  children: [
                                                    const Expanded(
                                                        child: SizedBox()),
                                                    const SizedBox(width: 10),
                                                    Expanded(
                                                      child: Text(
                                                        "1 ${items[0].purchaseUnit} = ${formatQuantityString(items[0].purchaseUnitConversion)} ${items[0].standardUnit}",
                                                        style: getSemiBoldStyle(
                                                          color: ColorManager
                                                              .lightGrey2,
                                                          fontSize:
                                                              FontSize.s12,
                                                        ),
                                                        textAlign:
                                                            TextAlign.right,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                           
                                            const SizedBox(height: 20),
                                            SizedBox(
                                              width: (screenWidth) - 45,
                                              height: 120,
                                              child: TextField(
                                                controller:
                                                    _commmentsController,
                                                style: getSemiBoldStyle(
                                                  color: ColorManager.black,
                                                  fontSize: FontSize.s16,
                                                ),
                                                readOnly: isItemEditable
                                                    ? false
                                                    : true,
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
                                                  contentPadding:
                                                      const EdgeInsets.all(20),
                                                  labelText: AppStrings.notes,
                                                  alignLabelWithHint: true,
                                                  floatingLabelBehavior:
                                                      FloatingLabelBehavior
                                                          .always,
                                                  floatingLabelStyle:
                                                      getSemiBoldStyle(
                                                    color:
                                                        ColorManager.lightGrey1,
                                                    fontSize: FontSize.s16,
                                                  ),
                                                ),
                                                onChanged: (value) {
                                                  // Trigger rebuild to update character count
                                                  setState(() {});
                                                },
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
                                                    fontSize: FontSize.s14,
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
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                //   const SizedBox(height: 20),
                                isItemEditable
                                    ? Padding(
                                        padding: const EdgeInsets.all(0.0),
                                        child: Container(
                                          color: ColorManager.white,
                                          width: (screenWidth) - 65,
                                          //  height: 100,
                                          child: Padding(
                                            padding: const EdgeInsets.fromLTRB(
                                                0, 20, 0, 20),
                                            child: Column(
                                              children: [
                                                const SizedBox(height: 2),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child:
                                                          CustomTextActionButton(
                                                        buttonText:
                                                            "Adjust Stock",
                                                        backgroundColor:
                                                            ColorManager.green,
                                                        borderColor:
                                                            Colors.transparent,
                                                        fontColor:
                                                            ColorManager.white,
                                                        buttonWidth:
                                                            double.infinity,
                                                        buttonHeight: 50,
                                                        isBoldFont: true,
                                                        fontSize: FontSize.s20,
                                                        onTap: () {
                                                          updateBlindStack();
                                                          log("adjust stock");
                                                        },
                                                      ),
                                                    ),
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
