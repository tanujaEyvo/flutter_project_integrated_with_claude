import 'package:eyvo_v3/api/api_service/api_service.dart';
import 'package:eyvo_v3/api/api_service/bloc.dart';
import 'package:eyvo_v3/api/response_models/received_items_response.dart';
import 'package:eyvo_v3/api/response_models/update_good_receive_response.dart';
import 'package:eyvo_v3/app/app_prefs.dart';
import 'package:eyvo_v3/app/sizes_helper.dart';
import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/constants.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/routes_manager.dart';
import 'package:eyvo_v3/core/resources/strings_manager.dart';
import 'package:eyvo_v3/core/resources/styles_manager.dart';
import 'package:eyvo_v3/core/utils.dart';
import 'package:eyvo_v3/core/widgets/alert.dart';
import 'package:eyvo_v3/core/widgets/button.dart';
import 'package:eyvo_v3/core/widgets/common_app_bar.dart';
import 'package:eyvo_v3/core/widgets/custom_checkbox.dart';
import 'package:eyvo_v3/core/widgets/custom_list_tile.dart';
import 'package:eyvo_v3/core/widgets/progress_indicator.dart';
import 'package:eyvo_v3/log_data.dart/logger_data.dart';
import 'package:eyvo_v3/presentation/pdf_view/pdf_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class ReceivedItemListView extends StatefulWidget {
  final String orderNumber;
  final int orderId;
  const ReceivedItemListView(
      {super.key, required this.orderNumber, required this.orderId});

  @override
  State<ReceivedItemListView> createState() => _ReceivedItemListViewState();
}

class _ReceivedItemListViewState extends State<ReceivedItemListView>
    with RouteAware {
  final TextEditingController editQuantityController = TextEditingController();
  bool isPrintEnabled = false;
  String searchText = '';
  late List<OrderData> orderItems = [];
  late List selectedOrderItems = [];
  bool isGoodsReceived = false;
  bool isGenerateLabelEnabled = false;
  String receivedGoodsSuccessMessage = '';
  String receivedGoodsNumber = '';
  bool isAllSelected = false;
  bool isReceiveGoodsEnabled = false;
  bool isLoading = false;
  bool isError = false;
  String errorText = AppStrings.somethingWentWrong;
  final ApiService apiService = ApiService();
  bool isEditingQuantity = false;
  final Duration duration = const Duration(milliseconds: 300);
  final double editBoxHeight = 350;
  late double maxQuantity;
  int selectedIndex = 0;
  bool isReject = false;
  final TextEditingController _commentsController = TextEditingController();
  int maxChars = AppConstants.maxCharactersForComment;
  String? selectedRejectReason = 'Broken'; // Default value
  String? selectedAction = 'Replace Item'; // Default value
  String? errorMessage;
  Map<int, Map<String, String>> uploadedImages = {};
  Map<int, Map<String, dynamic>> rejectDataMap = {};
  final TextEditingController _actualWeightController = TextEditingController();
  bool splittable = false;
  bool catchWeight = false;
  String actualWeightLabel = "";
  List<Map<String, dynamic>> unitList = [];

  // Per-item data storage (keyed by orderLineId)
  Map<int, List<Map<String, dynamic>>> itemUnitLists = {};
  Map<int, bool> itemSplittable = {};
  Map<int, bool> itemCatchWeight = {};
  Map<int, String> itemActualWeightLabel = {};
  String? selectedUnit;
  int? selectedUnitId;
  String? selectedUnitType;
  // Per-item selected values (keyed by orderLineId)
  Map<int, int?> itemSelectedUnitId = {};
  Map<int, String?> itemSelectedUnitType = {};
  Map<int, double> itemActualWeight = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPopNext() {
    fetchOrderItems();
  }

  @override
  void initState() {
    super.initState();
    fetchOrderItems();
    _actualWeightController.text = formatQuantityString(1.0);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    editQuantityController.dispose();
    _actualWeightController.dispose();
    _commentsController.dispose();
    super.dispose();
  }

  bool hasRejectData(int orderLineId) {
    return rejectDataMap.containsKey(orderLineId);
  }

  double _computeActualWeightForItem(OrderData item) {
    // Only for catch weight items
    if (item.catchWeight != true) return 1.0;

    final double conversion = item.purchaseUnitConversion ?? 0.0;
    final double qty =
        item.isEdited ? item.updatedQuantity : item.receivedQuantity;

    // Avoid 0 * qty = 0 → fall back to 1.0 or qty
    if (conversion <= 0) return qty > 0 ? qty : 1.0;

    return conversion * qty;
  }

  List<Map<String, dynamic>> _buildUnitList(OrderData item) {
    final List<Map<String, dynamic>> unitList = [];

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
          'id': _parseUnitId(item.purchaseUnitID),
          'name': purchaseUnit,
          'type': 'purchase',
        });
      }
      LoggerData.dataLog(
          'Unit List (non-splittable) for item ${item.orderLineId}: $unitList');
      return unitList;
    }

    if (isSameUnit) {
      // Purchase Unit == Inventory Unit → keep ONLY Purchase Unit
      if (item.purchaseUnitID != null) {
        unitList.add({
          'id': _parseUnitId(item.purchaseUnitID),
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
          'id': _parseUnitId(item.purchaseUnitID),
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

    LoggerData.dataLog('Unit List for item ${item.orderLineId}: $unitList');
    return unitList;
  }

  int? _parseUnitId(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  void fetchOrderItems() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> data = {
      'orderid': widget.orderId.toString(),
    };
    final jsonResponse = await apiService.postRequest(
        context, ApiService.goodReceiveItemList, data);
    if (jsonResponse != null) {
      final response = ReceivedItemsResponse.fromJson(jsonResponse);
      if (response.code == '200') {
        setState(() {
          orderItems = response.data;
          isPrintEnabled = response.print;
          isAllSelected = false;
          isReceiveGoodsEnabled = false;
          // (optional but recommended, since the old indices/maps may be stale)
          selectedOrderItems = [];
          // Clear previous per-item data
          itemUnitLists.clear();
          itemSplittable.clear();
          itemCatchWeight.clear();
          itemActualWeightLabel.clear();

          // Populate per-item data for EVERY item
          for (final item in orderItems) {
            final orderLineId = item.orderLineId;

            // Build unit list for this item
            itemUnitLists[orderLineId] = _buildUnitList(item);

            // Store splittable, catchWeight, actualWeightLabel per item
            itemSplittable[orderLineId] = item.splittable ?? false;
            itemCatchWeight[orderLineId] = item.catchWeight ?? false;
            itemActualWeightLabel[orderLineId] = item.actualWeightLabel ?? '';
          }
          LoggerData.dataLog('itemSplittable: $itemSplittable');
          LoggerData.dataLog('itemUnitLists: $itemUnitLists');
          LoggerData.dataLog('itemCatchWeight: $itemCatchWeight');
          LoggerData.dataLog('itemActualWeightLabel: $itemActualWeightLabel');
        });
      } else {
        isError = true;
        errorText = response.message.join(', ');
        isPrintEnabled = response.print;
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  // void didTappedOnSelectAll() {
  //   setState(() {
  //     isAllSelected = !isAllSelected;
  //     for (var item in orderItems) {
  //       item.isSelected = isAllSelected;
  //     }
  //     checkIsAnyItemSelected();
  //   });
  // }
  void didTappedOnSelectAll() {
    setState(() {
      isAllSelected = !isAllSelected;
      for (var item in orderItems) {
        item.isSelected = isAllSelected;

        if (isAllSelected && (item.catchWeight ?? false)) {
          itemActualWeight[item.orderLineId] =
              _computeActualWeightForItem(item);
        }
        // When deselecting, leave itemActualWeight untouched
      }
      checkIsAnyItemSelected();
    });
  }

  void editReceivedQuantity(BuildContext context, double bookInQuantity,
      double totalQuantity, int editingIndex, bool isRejectMode) {
    setState(() {
      isEditingQuantity = true;
      maxQuantity = bookInQuantity;
      //   editQuantityController.text = getFormattedString(bookInQuantity);

      selectedIndex = editingIndex;
      isReject = isRejectMode;

      final item = orderItems[editingIndex];
      final orderLineId = item.orderLineId;
      // Quantity
      // editQuantityController.text = (itemSplittable[orderLineId] ?? false)
      //     ? formatQuantityString(bookInQuantity) // was getFormattedString
      //     : formatQuantityInt(
      //         bookInQuantity); // was bookInQuantity.toInt().toString()
      editQuantityController.text = formatQuantityString(bookInQuantity);
      // Unit list for this item
      unitList = itemUnitLists[orderLineId] ?? [];

      // if the user already picked a unit for this item, use it;
      // otherwise fall back to the first unit in the list.
      if (itemSelectedUnitId.containsKey(orderLineId)) {
        selectedUnitId = itemSelectedUnitId[orderLineId];
        selectedUnitType = itemSelectedUnitType[orderLineId];
        selectedUnit = unitList
            .firstWhere(
              (u) => u['id'] == selectedUnitId,
              orElse: () =>
                  unitList.isNotEmpty ? unitList.first : <String, dynamic>{},
            )['name']
            ?.toString();
      } else {
        if (unitList.isNotEmpty) {
          selectedUnit = unitList.first['name']?.toString();
          selectedUnitId = _parseUnitId(unitList.first['id']);
          selectedUnitType = unitList.first['type']?.toString();
        } else {
          selectedUnit = null;
          selectedUnitId = null;
          selectedUnitType = null;
        }
      }

      splittable = itemSplittable[orderLineId] ?? false;
      catchWeight = itemCatchWeight[orderLineId] ?? false;
      actualWeightLabel = itemActualWeightLabel[orderLineId] ?? '';
      final bool isSelected = item.isSelected;
//  NEW — restore previously entered actual weight (if any)
      // _actualWeightController.text = (itemActualWeight[orderLineId] ?? 0.0) > 0
      //     ? formatQuantityString(itemActualWeight[orderLineId]!)
      //     : formatQuantityString(1.0);
      _actualWeightController.text = (itemActualWeight[orderLineId] ?? 0.0) > 0
          ? formatQuantityString(itemActualWeight[orderLineId]!)
          : (item.catchWeight == true && isSelected)
              ? formatQuantityString(_computeActualWeightForItem(item))
              : formatQuantityString(1.0);
      if (isRejectMode) {
        if (!rejectDataMap.containsKey(orderLineId)) {
          rejectDataMap[orderLineId] = {
            'rejectQuantity': bookInQuantity,
            'rejectReason': 'Broken',
            'creditReplace': 'Replace Item',
            'notes': '',
          };
        } else {
          rejectDataMap[orderLineId]!['rejectQuantity'] = bookInQuantity;
        }
      }
    });
  }

  void updateReceivedQuantity() {
    var updatedQuantityString = '';
    var updatedQuantity = 0.0;

    if (editQuantityController.text.isNotEmpty) {
      updatedQuantityString =
          formatQuantityString(double.parse(editQuantityController.text));
      updatedQuantity = double.parse(updatedQuantityString);
    }

    if (updatedQuantity <= 0) {
      showErrorDialog(context, AppStrings.quantityNotValid, false);
    } else {
      setState(() {
        isEditingQuantity = false;
        final orderLineId = orderItems[selectedIndex].orderLineId;
        itemSelectedUnitId[orderLineId] = selectedUnitId;
        itemSelectedUnitType[orderLineId] = selectedUnitType;
        itemActualWeight[orderLineId] =
            double.tryParse(_actualWeightController.text) ?? 1.0;
        if (isReject) {
          // Store reject data in the map - updatedQuantity goes to rejectquantity
          rejectDataMap[orderLineId] = {
            'rejectQuantity':
                updatedQuantity, // Use the updatedQuantity for reject
            'rejectReason': selectedRejectReason,
            'creditReplace': selectedAction,
            'notes': _commentsController.text,
          };

          // For reject items: received quantity = 0, reject quantity = updatedQuantity
          orderItems[selectedIndex].updatedQuantity =
              0.0; // This goes to receivedquantity in API
        } else {
          // For accept mode: received quantity = updatedQuantity, no reject data
          orderItems[selectedIndex].updatedQuantity =
              updatedQuantity; // This goes to receivedquantity in API
          rejectDataMap.remove(orderLineId); // Remove reject data if accepting
        }

        // Mark as edited if quantity changed from original received quantity
        if (orderItems[selectedIndex].receivedQuantity !=
            orderItems[selectedIndex].updatedQuantity) {
          orderItems[selectedIndex].isEdited = true;
        } else {
          orderItems[selectedIndex].isEdited = false;
        }

        orderItems[selectedIndex].isSelected = true;
        checkIsAnyItemSelected();

        // RESET DROPDOWN VALUES
        selectedRejectReason = 'Broken';
        selectedAction = 'Replace Item';
        // Clear controllers
        _commentsController.clear();
        errorMessage = null;
      });
    }
  }

  void updateQuantity(double updatedQuantity) {
    editQuantityController.text = formatQuantityString(updatedQuantity);
  }

  // void increaseReceivedQuantity() {
  //   final currentQuantity = double.tryParse(editQuantityController.text) ?? 0;

  //   double updatedQuantity;

  //   if (!splittable) {
  //     // splittable == false → whole numbers only
  //     updatedQuantity = currentQuantity.floorToDouble() + 1;
  //   } else {
  //     // splittable == true → decimals allowed
  //     updatedQuantity = currentQuantity + 1.0;
  //   }

  //   if (updatedQuantity <= orderItems[selectedIndex].bookInQuantity) {
  //     editQuantityController.text = !splittable
  //         ? updatedQuantity.toInt().toString()
  //         : getFormattedString(updatedQuantity);
  //   }
  // }

  // void decreaseReceivedQuantity() {
  //   final currentQuantity = double.tryParse(editQuantityController.text) ?? 0;

  //   double updatedQuantity;

  //   if (!splittable) {
  //     // splittable == false → whole numbers only
  //     updatedQuantity = currentQuantity.ceilToDouble() - 1;
  //   } else {
  //     // splittable == true → decimals allowed
  //     updatedQuantity = currentQuantity - 1.0;
  //   }

  //   if (updatedQuantity > 0) {
  //     editQuantityController.text = !splittable
  //         ? updatedQuantity.toInt().toString()
  //         : getFormattedString(updatedQuantity);
  //   }
  // }
  void increaseReceivedQuantity() {
    final currentQuantity = double.tryParse(editQuantityController.text) ?? 0;
    final double updatedQuantity = currentQuantity + 1.0;

    if (updatedQuantity <= orderItems[selectedIndex].bookInQuantity) {
      editQuantityController.text = formatQuantityString(updatedQuantity);
    }
  }

  void decreaseReceivedQuantity() {
    final currentQuantity = double.tryParse(editQuantityController.text) ?? 0;
    final double updatedQuantity = currentQuantity - 1.0;

    if (updatedQuantity > 0) {
      editQuantityController.text = formatQuantityString(updatedQuantity);
    }
  }

  void receiveGoods() {
    if (isReceiveGoodsEnabled) {
      selectedOrderItems = [];
      for (var item in orderItems) {
        if (item.isSelected) {
          final orderLineId = item.orderLineId;

          // Look up per-item saved values
          final int? uomId = itemSelectedUnitId[orderLineId] ?? 0;
          final String? unitType = itemSelectedUnitType[orderLineId];
          final double actualWeight = itemActualWeight[orderLineId] ?? 1.0;

          Map<String, dynamic> data = {
            "orderlineid": item.orderLineId,
            "itemorder": item.itemOrder,
            "receivedquantity": item.updatedQuantity,
            "itemtype": item.itemType,
            "isstock": item.isStock,
            "isupdated": true,
            "Document_FileName": "",
            "Document_FileNameAzure": "",

            "UOMID": uomId,
            // if itemId == 0 → unitType must be ""
            "unitType":
                item.itemId == 0 ? "Purchase" : (unitType ?? "Purchases"),
            "actualweight": actualWeight,
          };

          // Reject data (unchanged)
          final rejectData = rejectDataMap[orderLineId];
          if (rejectData != null) {
            data["rejectquantity"] = rejectData['rejectQuantity'];
            data["rejectreason"] = rejectData['rejectReason'];
            data["creditReplace"] = rejectData['creditReplace'];
            data["notes"] = rejectData['notes'];
          }

          // Uploaded image (unchanged)
          final imageData = uploadedImages[orderLineId];
          if (imageData != null) {
            data["Document_FileName"] = imageData["fileName"];
            data["Document_FileNameAzure"] = imageData["azureImageName"];
          }

          selectedOrderItems.add(data);
        }
      }

      showReceiveGoodsDialog(context);
    }
  }

  void onConfirmReceiveGoods() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> data = {
      "orderid": widget.orderId,
      "ordernumber": widget.orderNumber,
      "uid": SharedPrefs().uID,
      "locationid": SharedPrefs().selectedLocationID,
      "regionid": SharedPrefs().selectedRegionID,
      "usersession": SharedPrefs().userSession,
      "items": selectedOrderItems,
    };
    final jsonResponse = await apiService.postRequest(
        context, ApiService.goodReceiveUpdate, data);
    if (jsonResponse != null) {
      final response = UpdateGoodReceiveResponse.fromJson(jsonResponse);
      setState(() {
        if (response.code == '200') {
          isGoodsReceived = true;
          receivedGoodsNumber = response.data.grNumber;
          isGenerateLabelEnabled = response.data.print;
          receivedGoodsSuccessMessage = response.message.join(', ');
        } else {
          showErrorDialog(context, response.message.join(', '), false);
        }
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  void showReceiveGoodsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomImageActionAlert(
            iconString: "",
            imageString: ImageAssets.receiveGoodsImage,
            titleString: AppStrings.receiveGoodsTitle,
            subTitleString: AppStrings.receiveGoodsSubTitle
                .replaceAll("{count}", selectedOrderItems.length.toString()),
            destructiveActionString: AppStrings.yes,
            normalActionString: AppStrings.no,
            onDestructiveActionTap: () {
              Navigator.pop(context);
              onConfirmReceiveGoods();
            },
            onNormalActionTap: () {
              Navigator.pop(context);
            },
            isNormalAlert: true,
            isConfirmationAlert: true);
      },
    );
  }

  void checkIsAnyItemSelected() {
    isReceiveGoodsEnabled = false;
    for (var item in orderItems) {
      if (item.isSelected) {
        isReceiveGoodsEnabled = true;
      } else {
        isAllSelected = false;
      }
    }
  }

  void printReceiveGoods(int orderId, int itemId, String grNo) {
    isGoodsReceived = false;
    isReceiveGoodsEnabled = false;
    navigateToScreen(
        context,
        PDFViewScreen(
          orderNumber: widget.orderNumber,
          orderId: orderId,
          itemId: itemId,
          grNo: grNo,
        ));
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
        appBar: buildCommonAppBar(
          context: context,
          title: AppStrings.itemDetails,
        ),
        body: isLoading
            ? const Center(child: CustomProgressIndicator())
            : Stack(
                children: [
                  isError
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
                                        ImageAssets.noRecordFoundIcon),
                                    Text(errorText,
                                        style: getRegularStyle(
                                            color: ColorManager.lightGrey,
                                            fontSize: FontSize.s17)),
                                    const Spacer()
                                  ],
                                )),
                              ),
                            ),
                          ],
                        )
                      : isGoodsReceived
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        // const Spacer(),
                                        Image.asset(
                                            width: displayWidth(context) * 0.6,
                                            ImageAssets
                                                .successfulReceivedImage),
                                        Text(receivedGoodsSuccessMessage,
                                            textAlign: TextAlign.center,
                                            style: getRegularStyle(
                                                color: ColorManager.lightGrey,
                                                fontSize: FontSize.s17)),
                                        // const Spacer()
                                      ],
                                    )),
                                  ),
                                ),
                              ],
                            )
                          : Column(
                              children: [
                                Expanded(
                                  child: SingleChildScrollView(
                                    child: Column(
                                      children: [
                                        const SizedBox(height: 60),
                                        SizedBox(
                                          width: displayWidth(context),
                                          child: Padding(
                                            padding:
                                                const EdgeInsets.only(left: 18),
                                            child: CustomCheckBox(
                                                imageString: isAllSelected
                                                    ? ImageAssets
                                                        .selectedCheckBoxIcon
                                                    : ImageAssets.checkBoxIcon,
                                                titleString:
                                                    AppStrings.selectAll,
                                                isSelected: isAllSelected,
                                                onTap: () {
                                                  didTappedOnSelectAll();
                                                }),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: 0,
                                              bottom: 8,
                                              left: 18,
                                              right: 18),
                                          child: ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                const NeverScrollableScrollPhysics(),
                                            itemCount: orderItems.length,
                                            itemBuilder: (context, index) {
                                              return OrderItemListTile(
                                                itemID:
                                                    orderItems[index].itemOrder,
                                                title: orderItems[index]
                                                        .itemCode ??
                                                    '',
                                                subtitle: orderItems[index]
                                                    .description,
                                                imageString:
                                                    orderItems[index].itemImage,
                                                totalQuantity:
                                                    orderItems[index].quantity,
                                                receivedQuantity:
                                                    orderItems[index].isEdited
                                                        ? orderItems[index]
                                                            .updatedQuantity
                                                        : orderItems[index]
                                                            .receivedQuantity,
                                                isSelected: orderItems[index]
                                                    .isSelected,
                                                isReject: hasRejectData(
                                                    orderItems[index]
                                                        .orderLineId),
                                                rejectQuantity: hasRejectData(
                                                        orderItems[index]
                                                            .orderLineId)
                                                    ? rejectDataMap[
                                                            orderItems[index]
                                                                .orderLineId]![
                                                        'rejectQuantity'] // Pass reject quantity
                                                    : null,
                                                // onTap: () {
                                                //   setState(() {
                                                //     orderItems[index]
                                                //             .isSelected =
                                                //         !orderItems[index]
                                                //             .isSelected;
                                                //     checkIsAnyItemSelected();
                                                //   });
                                                // },
                                                onTap: () {
                                                  setState(() {
                                                    final item =
                                                        orderItems[index];
                                                    item.isSelected =
                                                        !item.isSelected;

                                                    if (item.isSelected &&
                                                        (item.catchWeight ??
                                                            false)) {
                                                      // Newly selected + catch weight → set actual weight
                                                      final orderLineId =
                                                          item.orderLineId;
                                                      itemActualWeight[
                                                              orderLineId] =
                                                          _computeActualWeightForItem(
                                                              item);
                                                    }
                                                    // If unselected → do NOT modify itemActualWeight (per requirement)

                                                    checkIsAnyItemSelected();
                                                  });
                                                },
                                                onEdit: () {
                                                  bool hasRejectData =
                                                      rejectDataMap.containsKey(
                                                          orderItems[index]
                                                              .orderLineId);

                                                  editReceivedQuantity(
                                                    context,
                                                    hasRejectData
                                                        ? rejectDataMap[orderItems[
                                                                    index]
                                                                .orderLineId]![
                                                            'rejectQuantity'] // Use reject quantity for editing
                                                        : (orderItems[index]
                                                                .isEdited
                                                            ? orderItems[index]
                                                                .updatedQuantity
                                                            : orderItems[index]
                                                                .receivedQuantity),
                                                    orderItems[index].quantity,
                                                    index,
                                                    hasRejectData,
                                                  );
                                                },
                                                isImageUploaded:
                                                    uploadedImages.containsKey(
                                                        orderItems[index]
                                                            .orderLineId),
                                                uploadedImageBase64:
                                                    uploadedImages[
                                                            orderItems[index]
                                                                .orderLineId]
                                                        ?["base64"],
                                                onImageUploaded: (fileName,
                                                    azureImageName,
                                                    base64Image) {
                                                  setState(() {
                                                    if (fileName.isEmpty &&
                                                        base64Image.isEmpty &&
                                                        azureImageName
                                                            .isEmpty) {
                                                      uploadedImages.remove(
                                                          orderItems[index]
                                                              .orderLineId);
                                                    } else {
                                                      uploadedImages[
                                                          orderItems[index]
                                                              .orderLineId] = {
                                                        "fileName": fileName,
                                                        "azureImageName":
                                                            azureImageName,
                                                        "base64": base64Image,
                                                      };
                                                      orderItems[index]
                                                          .isSelected = true;
                                                    }
                                                    checkIsAnyItemSelected();
                                                  });
                                                },
                                              );
                                            },
                                          ),
                                        ),
                                        const SizedBox(height: 50),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 80),
                              ],
                            ),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      color: ColorManager.white,
                      alignment: Alignment.topLeft,
                      height: 60,
                      width: displayWidth(context),
                      child: Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 8, left: 18, right: 18, bottom: 8),
                            child: Text(
                              AppStrings.orderNumberDetail + widget.orderNumber,
                              style: getBoldStyle(
                                  color: ColorManager.darkBlue,
                                  fontSize: FontSize.s20),
                            ),
                          ),
                          // const Spacer(),
                          const SizedBox(height: 5),
                          isGoodsReceived
                              ? const SizedBox()
                              : isPrintEnabled
                                  ? Padding(
                                      padding: const EdgeInsets.only(right: 18),
                                      child: IconButton(
                                          onPressed: () {
                                            printReceiveGoods(
                                                widget.orderId, 0, "");
                                          },
                                          icon: Image.asset(
                                              ImageAssets.printIcon)),
                                    )
                                  : const SizedBox()
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      width: displayWidth(context),
                      height: 90,
                      color: isGoodsReceived
                          ? isGenerateLabelEnabled
                              ? ColorManager.white
                              : Colors.transparent
                          : Colors.transparent,
                      child: Padding(
                        padding: const EdgeInsets.all(18.0),
                        child: isGoodsReceived
                            ? isGenerateLabelEnabled
                                ? CustomButton(
                                    buttonText: AppStrings.generateLabels,
                                    onTap: () {
                                      printReceiveGoods(widget.orderId, 0,
                                          receivedGoodsNumber);
                                    },
                                    isEnabled: isReceiveGoodsEnabled)
                                : const SizedBox()
                            : CustomButton(
                                buttonText: AppStrings.receiveGoods,
                                onTap: () {
                                  isReceiveGoodsEnabled ? receiveGoods() : null;
                                },
                                isEnabled: isReceiveGoodsEnabled),
                      ),
                    ),
                  ),
                  // FIXED POPUP WITH OPTION 1
                  isEditingQuantity
                      ? AnimatedPositioned(
                          duration: duration,
                          curve: Curves.easeInOut,
                          bottom: isEditingQuantity ? 0 : -editBoxHeight,
                          left: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () =>
                                setState(() => isEditingQuantity = false),
                            child: AnimatedContainer(
                              color: ColorManager.blackOpacity50,
                              duration: duration,
                              height: isEditingQuantity
                                  ? displayHeight(context)
                                  : 0,
                              child: Column(
                                children: [
                                  const Spacer(),
                                  // Wrap QuantityEditPopup with GestureDetector to absorb taps
                                  GestureDetector(
                                    onTap:
                                        () {}, // Empty onTap to absorb the event
                                    behavior: HitTestBehavior
                                        .opaque, // This ensures the tap is captured here
                                    child: QuantityEditPopup(
                                      quantityController:
                                          editQuantityController,
                                      actualWeightController:
                                          _actualWeightController,
                                      commentsController: _commentsController,
                                      splittable: splittable,
                                      catchWeight: catchWeight,
                                      actualWeightLabel: actualWeightLabel,
                                      isReject: isReject,
                                      isReceiveGoodsEnabled:
                                          isReceiveGoodsEnabled,
                                      onIncrease: increaseReceivedQuantity,
                                      onDecrease: decreaseReceivedQuantity,
                                      onToggleAcceptReject: (value) {
                                        setState(() {
                                          isReject = !value;
                                          isReceiveGoodsEnabled = value;
                                        });
                                      },
                                      selectedRejectReason:
                                          selectedRejectReason,
                                      selectedAction: selectedAction,
                                      onRejectReasonChanged: (value) {
                                        setState(() {
                                          selectedRejectReason = value;
                                        });
                                      },
                                      onActionChanged: (value) {
                                        setState(() {
                                          selectedAction = value;
                                        });
                                      },
                                      unitList: unitList,
                                      selectedUnitId: selectedUnitId,
                                      selectedUnit: selectedUnit,
                                      selectedUnitType: selectedUnitType,
                                      onUnitChanged: (selected) {
                                        setState(() {
                                          selectedUnitId =
                                              selected['id'] as int?;
                                          selectedUnit =
                                              selected['name']?.toString();
                                          selectedUnitType =
                                              selected['type']?.toString();
                                        });
                                      },
                                      itemId: orderItems[selectedIndex].itemId,
                                      // Replacement for PopupTickButton
                                      noteText: orderItems[selectedIndex]
                                                  .purchaseUnitID !=
                                              null
                                          ? "1 ${orderItems[selectedIndex].purchaseUnit} = "
                                              "${orderItems[selectedIndex].purchaseUnitConversion?.toStringAsFixed(2)} "
                                              "${orderItems[selectedIndex].standardUnit}"
                                          : null,
                                      onConfirm: () {
                                        if (editQuantityController.text
                                            .trim()
                                            .isEmpty) {
                                          showErrorDialog(
                                            context,
                                            AppStrings.quantityNotValid,
                                            false,
                                          );
                                          return;
                                        }
                                        if (catchWeight) {
                                          final String actualWeightText =
                                              _actualWeightController.text
                                                  .trim();
                                          final double actualWeight =
                                              double.tryParse(actualWeightText
                                                      .replaceAll(',', '')) ??
                                                  0;

                                          if (actualWeightText.isEmpty ||
                                              actualWeight <= 0) {
                                            showErrorDialog(
                                              context,
                                              actualWeightLabel.isNotEmpty
                                                  ? "$actualWeightLabel should be greater than 0."
                                                  : "Actual Weight should be greater than 0.",
                                              false,
                                            );
                                            return;
                                          }
                                        }
                                        // if (catchWeight &&
                                        //     _actualWeightController.text
                                        //         .trim()
                                        //         .isEmpty) {
                                        //   showErrorDialog(
                                        //     context,
                                        //     'Actual weight cannot be empty.',
                                        //     false,
                                        //   );
                                        //   return;
                                        // }

                                        updateReceivedQuantity();
                                      },
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : const SizedBox(),
                ],
              ),
      ),
    );
  }
}

class PopupTickButton extends StatelessWidget {
  final VoidCallback onTap;
  final bool isReject;

  const PopupTickButton({
    super.key,
    required this.onTap,
    required this.isReject,
  });

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double screenWidth = MediaQuery.sizeOf(context).width;
    double calculatedBottomOffset =
        isReject ? screenHeight * 0.50 : screenHeight * 0.30;

    return Positioned(
      bottom: calculatedBottomOffset,
      right: screenHeight * 0.02,
      child: Container(
        width: screenWidth,
        height: 80,
        alignment: Alignment.topRight,
        child: Padding(
          padding: const EdgeInsets.only(right: 10),
          child: IconButton(
            onPressed: onTap,
            icon: Image.asset(
              isReject ? ImageAssets.tickIconRed : ImageAssets.tickIcon,
            ),
          ),
        ),
      ),
    );
  }
}

Widget _buildDropdownWithInputDecoration({
  required String label,
  required String? value,
  required List<String> items,
  required Function(String?) onChanged,
  required double screenWidth,
  required double screenHeight,
  double? fixedWidth,
}) {
  return ConstrainedBox(
    constraints: BoxConstraints(
      minWidth: screenWidth * 0.3,
      maxWidth: fixedWidth ?? screenWidth * 0.5,
    ),
    child: InputDecorator(
      decoration: InputDecoration(
        labelText: label,
        alignLabelWithHint: true,
        floatingLabelBehavior: FloatingLabelBehavior.always,
        floatingLabelStyle: getSemiBoldStyle(
          color: ColorManager.lightGrey1,
          fontSize: FontSize.s18,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(screenHeight * 0.01),
          borderSide: BorderSide(
            color: ColorManager.grey.withOpacity(0.5),
            width: 1,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(screenHeight * 0.008),
          borderSide: BorderSide(
            color: ColorManager.grey.withOpacity(0.5),
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(screenHeight * 0.008),
          borderSide: BorderSide(
            color: ColorManager.darkBlue,
            width: 1.5,
          ),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.02,
          vertical: screenHeight * 0.008,
        ),
        isCollapsed: true,
        constraints: BoxConstraints(
          maxHeight: screenHeight * 0.05,
        ),
      ),
      isEmpty: value == null,
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: Icon(
            Icons.arrow_drop_down_rounded,
            color: ColorManager.darkBlue,
            size: screenHeight * 0.028,
          ),
          style: getSemiBoldStyle(
            color: ColorManager.black,
            fontSize: FontSize.s18,
          ),
          dropdownColor: Colors.white,
          elevation: 4,
          borderRadius: BorderRadius.circular(screenHeight * 0.008),
          menuMaxHeight: screenHeight * 0.35,
          underline: const SizedBox(),
          selectedItemBuilder: (BuildContext context) {
            return items.map<Widget>((String item) {
              return Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  item,
                  textAlign: TextAlign.left,
                  style: getSemiBoldStyle(
                    color: ColorManager.darkBlue,
                    fontSize: FontSize.s16,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              );
            }).toList();
          },
          items: items.map((String item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                style: getSemiBoldStyle(
                  color: value == item
                      ? ColorManager.darkBlue
                      : ColorManager.black,
                  fontSize: FontSize.s16,
                ),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    ),
  );
}

Widget _quantityButton({
  required String icon,
  required VoidCallback onPressed,
  required double size,
}) {
  return Container(
    width: size * 0.06,
    height: size * 0.04,
    decoration: BoxDecoration(
      color: ColorManager.darkBlue,
      borderRadius: BorderRadius.circular(size * 0.008),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: IconButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed,
      icon: Image.asset(
        icon,
        width: size * 0.02,
        height: size * 0.02,
        color: Colors.white,
      ),
    ),
  );
}

class QuantityEditPopup extends StatefulWidget {
  final TextEditingController quantityController;
  final TextEditingController actualWeightController;
  final TextEditingController commentsController;
  final bool catchWeight;
  final bool splittable;
  final bool isReject;
  final bool isReceiveGoodsEnabled;
  final VoidCallback onIncrease;
  final VoidCallback onDecrease;
  final ValueChanged<bool> onToggleAcceptReject;
  final double boxHeight;
  final String? selectedRejectReason;
  final String? selectedAction;
  final ValueChanged<String?> onRejectReasonChanged;
  final ValueChanged<String?> onActionChanged;
  final VoidCallback onConfirm;
  final String actualWeightLabel;
  final List<Map<String, dynamic>> unitList;
  final int? selectedUnitId;
  final String? selectedUnit;
  final String? selectedUnitType;
  final ValueChanged<Map<String, dynamic>> onUnitChanged;
  final int itemId;
  final String? noteText;
  const QuantityEditPopup({
    super.key,
    required this.quantityController,
    required this.actualWeightController,
    required this.actualWeightLabel,
    required this.splittable,
    required this.catchWeight,
    required this.commentsController,
    required this.isReject,
    required this.isReceiveGoodsEnabled,
    required this.onIncrease,
    required this.onDecrease,
    required this.onToggleAcceptReject,
    required this.selectedRejectReason,
    required this.selectedAction,
    required this.onRejectReasonChanged,
    required this.onActionChanged,
    required this.onConfirm,
    required this.unitList,
    required this.selectedUnitId,
    required this.selectedUnit,
    required this.selectedUnitType,
    required this.onUnitChanged,
    required this.itemId,
    this.noteText,
    this.boxHeight = 350,
  });

  @override
  State<QuantityEditPopup> createState() => _QuantityEditPopupState();
}

class _QuantityEditPopupState extends State<QuantityEditPopup> {
  int maxChars = AppConstants.maxCharactersForComment;
  String? errorMessage;
  final FocusNode actualWeightFocusNode = FocusNode();
  final FocusNode quantityFocusNode = FocusNode();
  bool get _isNewUi => widget.itemId > 0;

  @override
  void initState() {
    super.initState();

    actualWeightFocusNode.addListener(() {
      if (!actualWeightFocusNode.hasFocus) {
        _performActualWeightActionOnFocusChanged();
      }
    });

    quantityFocusNode.addListener(() {
      if (!quantityFocusNode.hasFocus) {
        _formatQuantity();
      }
    });
  }

  @override
  void dispose() {
    actualWeightFocusNode.dispose();
    super.dispose();
  }

  void _performActualWeightActionOnFocusChanged() {
    if (widget.actualWeightController.text.trim().isNotEmpty) {
      final double weight =
          parseQuantityString(widget.actualWeightController.text);
      widget.actualWeightController.text = formatQuantityString(weight);
    } else {
      widget.actualWeightController.text = formatQuantityString(1.0);
    }
  }

  void _formatQuantity() {
    final text = widget.quantityController.text.trim();
    if (text.isEmpty) {
      widget.quantityController.text = formatQuantityString(0.0);
      return;
    }
    final double value = parseQuantityString(text);
    widget.quantityController.text = formatQuantityString(value);

    // keep cursor at end
    widget.quantityController.selection = TextSelection.collapsed(
      offset: widget.quantityController.text.length,
    );
  }

  double get _calculatedHeight {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;

    double baseHeight;
    if (widget.isReject) {
      baseHeight = screenHeight * 0.68;
    } else if (!_isNewUi) {
      baseHeight = screenHeight * 0.40;
    } else if (widget.catchWeight) {
      baseHeight = screenHeight * 0.48;
    } else {
      baseHeight = screenHeight * 0.40;
    }

    // If keyboard is open, cap the height so the popup fits above it
    if (keyboardHeight > 0) {
      final availableHeight = screenHeight - keyboardHeight;
      return baseHeight.clamp(0, availableHeight * 0.95);
    }
    return baseHeight;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final keyboardHeight = MediaQuery.viewInsetsOf(context).bottom;
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      behavior: HitTestBehavior.opaque,
      child: Padding(
        //  padding: EdgeInsets.only(bottom: keyboardHeight),
        padding: EdgeInsets.only(bottom: keyboardHeight > 0 ? 8 : 0),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.all(screenHeight * 0.02),
          height: _calculatedHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(screenHeight * 0.02),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // ---------- Toggle Accept / Reject (unchanged) ----------
              Row(
                children: [
                  SizedBox(width: screenWidth * 0.01),
                  Container(
                    height: screenHeight * 0.05,
                    decoration: BoxDecoration(
                      color: ColorManager.white,
                      borderRadius: BorderRadius.circular(screenHeight * 0.01),
                      border: Border.all(
                        color: ColorManager.grey.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: ToggleButtons(
                      isSelected: [!widget.isReject, widget.isReject],
                      onPressed: (index) {
                        widget.onToggleAcceptReject(index == 0);
                      },
                      borderRadius: BorderRadius.circular(screenHeight * 0.01),
                      constraints: BoxConstraints(
                        minWidth: screenWidth * 0.20,
                        minHeight: screenHeight * 0.10,
                      ),
                      color: Colors.black,
                      selectedColor: Colors.white,
                      fillColor: MaterialStateColor.resolveWith((states) {
                        if (states.contains(MaterialState.selected)) {
                          final selectedIndex = [
                            !widget.isReject,
                            widget.isReject
                          ].indexWhere((selected) => selected);
                          return selectedIndex == 0
                              ? ColorManager.green
                              : ColorManager.red2;
                        }
                        return Colors.transparent;
                      }),
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.check_circle_outline,
                                size: screenHeight * 0.03,
                                color: !widget.isReject
                                    ? Colors.white
                                    : ColorManager.green,
                              ),
                              SizedBox(width: screenWidth * 0.01),
                              Text(
                                "Accept",
                                style: getBoldStyle(
                                  fontSize: screenHeight * 0.018,
                                  color: !widget.isReject
                                      ? Colors.white
                                      : ColorManager.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: screenWidth * 0.02),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                ImageAssets.closeIcon,
                                width: screenHeight * 0.025,
                                height: screenHeight * 0.025,
                                color: widget.isReject
                                    ? Colors.white
                                    : ColorManager.red2,
                              ),
                              SizedBox(width: screenWidth * 0.01),
                              Text(
                                "Reject",
                                style: getBoldStyle(
                                  fontSize: screenHeight * 0.018,
                                  color: widget.isReject
                                      ? Colors.white
                                      : ColorManager.red2,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: screenWidth * 0.01),
                ],
              ),
              SizedBox(height: screenHeight * 0.01),
              const Divider(thickness: 1),
              SizedBox(height: screenHeight * 0.01),
              Expanded(
                child: SingleChildScrollView(
                  physics: const ClampingScrollPhysics(),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        widget.isReject
                            ? (widget.catchWeight &&
                                    (widget.unitList.isNotEmpty &&
                                        (widget.unitList.first['name']
                                                ?.toString()
                                                .trim()
                                                .isNotEmpty ??
                                            false)))
                                ? "Edit Reject Quantity (${widget.unitList.first['name']})"
                                : "Edit Reject Quantity"
                            : (widget.catchWeight &&
                                    (widget.unitList.isNotEmpty &&
                                        (widget.unitList.first['name']
                                                ?.toString()
                                                .trim()
                                                .isNotEmpty ??
                                            false)))
                                ? "${AppStrings.editReceiveQuantity} (${widget.unitList.first['name']})"
                                : AppStrings.editReceiveQuantity,
                        style: getBoldStyle(
                          color: ColorManager.lightGrey2,
                          fontSize: screenHeight * 0.025,
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // ---------- Quantity Row ----------
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Minus
                          _quantityButton(
                            icon: ImageAssets.minusIcon,
                            onPressed: widget.onDecrease,
                            size: screenHeight,
                          ),

                          // Quantity TextField
                          SizedBox(
                            width: !_isNewUi
                                //OLD UI → same width as before (no dropdown, no weight)
                                ? screenWidth * 0.35
                                : widget.catchWeight
                                    // NEW UI + catchWeight → wide (no dropdown)
                                    ? screenWidth * 0.62
                                    //  NEW UI + no catchWeight → narrower (dropdown visible)
                                    : screenWidth * 0.30,
                            height: screenHeight * 0.05,
                            child: TextField(
                              focusNode: quantityFocusNode,
                              controller: (widget.quantityController),
                              style: getBoldStyle(
                                color: ColorManager.lightGrey2,
                                fontSize: screenHeight * 0.022,
                              ),
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) =>
                                  FocusScope.of(context).unfocus(),
                              onEditingComplete: _formatQuantity,
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                      decimal: true),
                              inputFormatters: [
                                DecimalTextInputFormatter(
                                  decimalPlaces:
                                      SharedPrefs().decimalplacesquantity,
                                  minValue: 0.0,
                                  maxValue: double.infinity,
                                ),
                                LengthLimitingTextInputFormatter(
                                  AppConstants.maxCharactersForQuantity,
                                ),
                              ],
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                contentPadding: EdgeInsets.zero,
                                border: InputBorder.none,
                                filled: true,
                                fillColor: ColorManager.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      screenHeight * 0.008),
                                  borderSide: BorderSide(
                                    color: ColorManager.grey.withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(
                                      screenHeight * 0.008),
                                  borderSide: BorderSide(
                                    color: ColorManager.darkBlue,
                                    width: 1.5,
                                  ),
                                ),
                              ),
                            ),
                          ),

                          // Plus
                          _quantityButton(
                            icon: ImageAssets.plusIcon,
                            onPressed: widget.onIncrease,
                            size: screenHeight,
                          ),
                          // Unit Dropdown — ONLY in NEW UI AND when catchWeight is FALSE
                          if (_isNewUi && !widget.catchWeight)
                            SizedBox(
                              width: screenWidth * 0.28,
                              height: screenHeight * 0.05,
                              child: DropdownButtonFormField<int>(
                                value: widget.selectedUnitId,
                                isExpanded: true,
                                // Disable dropdown when splittable is false
                                onChanged: widget.splittable
                                    ? (int? value) {
                                        if (value == null) return;

                                        final selected =
                                            widget.unitList.firstWhere(
                                          (unit) => unit['id'] == value,
                                          orElse: () => <String, dynamic>{},
                                        );

                                        if (selected.isEmpty) return;

                                        widget.onUnitChanged(selected);

                                        LoggerData.dataLog(
                                            'Selected Unit: ${selected['name']}');
                                        LoggerData.dataLog(
                                            'Selected Unit ID: ${selected['id']}');
                                        LoggerData.dataLog(
                                            'Selected Unit Type: ${selected['type']}');
                                      }
                                    : null, //  null disables the dropdown
                                decoration: InputDecoration(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 10,
                                  ),
                                  labelText: 'Select Unit :',
                                  floatingLabelBehavior:
                                      FloatingLabelBehavior.always,
                                  floatingLabelStyle: getSemiBoldStyle(
                                    color: ColorManager.lightGrey1,
                                    fontSize: FontSize.s16,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        screenHeight * 0.008),
                                    borderSide: BorderSide(
                                      color: ColorManager.grey.withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        screenHeight * 0.008),
                                    borderSide: BorderSide(
                                      color: ColorManager.grey.withOpacity(0.5),
                                      width: 1,
                                    ),
                                  ),
                                  // Grey out border when disabled
                                  disabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        screenHeight * 0.008),
                                    borderSide: BorderSide(
                                      color: ColorManager.grey.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(
                                        screenHeight * 0.008),
                                    borderSide: BorderSide(
                                      color: ColorManager.darkBlue,
                                      width: 1.5,
                                    ),
                                  ),
                                  filled: true,
                                  //  Grey background when disabled
                                  fillColor: widget.splittable
                                      ? Colors.white
                                      : ColorManager.grey.withOpacity(0.08),
                                ),
                                // Grey out the arrow icon when disabled
                                icon: Icon(
                                  Icons.arrow_drop_down,
                                  color: widget.splittable
                                      ? ColorManager.darkBlue
                                      : ColorManager.grey,
                                  size: screenHeight * 0.028,
                                ),
                                style: getSemiBoldStyle(
                                  //  Grey out text when disabled
                                  color: widget.splittable
                                      ? ColorManager.black
                                      : ColorManager.grey,
                                  fontSize: FontSize.s16,
                                ),
                                dropdownColor: Colors.white,
                                elevation: 4,
                                borderRadius:
                                    BorderRadius.circular(screenHeight * 0.008),
                                menuMaxHeight: screenHeight * 0.2,
                                items: widget.unitList.map((unit) {
                                  final id = unit['id'] as int?;
                                  final name = unit['name']?.toString() ?? '';
                                  return DropdownMenuItem<int>(
                                    value: id,
                                    child: Text(
                                      name,
                                      overflow: TextOverflow.ellipsis,
                                      style: getSemiBoldStyle(
                                        color: ColorManager.darkBlue,
                                        fontSize: FontSize.s16,
                                      ),
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                        ],
                      ),
                      // Actual Weight field — ONLY in NEW UI AND when catchWeight is TRUE
                      if (_isNewUi && widget.catchWeight)
                        Column(
                          children: [
                            const SizedBox(height: 20),
                            Center(
                              child: SizedBox(
                                width: screenWidth,
                                height: 50,
                                child: Stack(
                                  children: [
                                    // Actual Weight TextField
                                    TextField(
                                      controller: widget.actualWeightController,
                                      focusNode: actualWeightFocusNode,
                                      style: getSemiBoldStyle(
                                        color: ColorManager.black,
                                        fontSize: FontSize.s17,
                                      ),
                                      textInputAction: TextInputAction.done,
                                      onSubmitted: (_) =>
                                          FocusScope.of(context).unfocus(),
                                      keyboardType:
                                          const TextInputType.numberWithOptions(
                                        decimal: true,
                                      ),
                                      inputFormatters: [
                                        DecimalTextInputFormatter(
                                          decimalPlaces: SharedPrefs()
                                              .decimalplacesquantity,
                                          minValue: 0.0,
                                          maxValue: double.infinity,
                                        ),
                                      ],
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.all(
                                            screenHeight * 0.015),
                                        labelText:
                                            widget.actualWeightLabel.isNotEmpty
                                                ? widget.actualWeightLabel
                                                : 'Actual Weight',
                                        floatingLabelBehavior:
                                            FloatingLabelBehavior.always,
                                        floatingLabelStyle: getSemiBoldStyle(
                                          color: ColorManager.lightGrey1,
                                          fontSize: FontSize.s18,
                                        ),
                                        border: OutlineInputBorder(
                                          borderRadius: BorderRadius.circular(
                                              screenHeight * 0.01),
                                        ),
                                        filled: true,
                                        fillColor: Colors.white,
                                      ),
                                    ),

                                    // Red triangle indicator (top-right)
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

                            // NOTE below Actual Weight — uses the noteText passed from parent
                            if (widget.noteText != null &&
                                widget.noteText!.isNotEmpty)
                              SizedBox(
                                width: screenWidth - 80,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 6),
                                  child: Text(
                                    widget.noteText!,
                                    style: getSemiBoldStyle(
                                      color: ColorManager.lightGrey2,
                                      fontSize: FontSize.s12,
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      SizedBox(height: screenHeight * 0.015),

                      // ---------- Reject section (unchanged) ----------
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: widget.isReject ? 1.0 : 0.0,
                        child: Visibility(
                          visible: widget.isReject,
                          child: Column(
                            children: [
                              SizedBox(height: screenHeight * 0.02),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          right: screenWidth * 0.01),
                                      child: _buildDropdownWithInputDecoration(
                                        label: 'Reject Reason :',
                                        value: widget.selectedRejectReason,
                                        items: [
                                          'Broken',
                                          'Not Required',
                                          'Shortage',
                                          'Unavailable',
                                          'Wrong Specification'
                                        ],
                                        onChanged: widget.onRejectReasonChanged,
                                        screenWidth: screenWidth,
                                        screenHeight: screenHeight,
                                        fixedWidth: screenWidth * 0.38,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: screenWidth * 0.02),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.only(
                                          left: screenWidth * 0.01),
                                      child: _buildDropdownWithInputDecoration(
                                        label: 'Action :',
                                        value: widget.selectedAction,
                                        items: ['Replace Item', 'Credit Note'],
                                        onChanged: widget.onActionChanged,
                                        screenWidth: screenWidth,
                                        screenHeight: screenHeight,
                                        fixedWidth: screenWidth * 0.38,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      // ---------- Comments (unchanged) ----------
                      AnimatedOpacity(
                        duration: const Duration(milliseconds: 300),
                        opacity: widget.isReject ? 1.0 : 0.0,
                        child: Visibility(
                          visible: widget.isReject,
                          child: SizedBox(
                            width: screenWidth * 0.95,
                            height: screenHeight * 0.12,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: widget.commentsController,
                                    style: getSemiBoldStyle(
                                      color: ColorManager.black,
                                      fontSize: FontSize.s18,
                                    ),
                                    expands: true,
                                    maxLines: null,
                                    minLines: null,
                                    textAlignVertical: TextAlignVertical.top,
                                    keyboardType: TextInputType.multiline,
                                    textInputAction: TextInputAction.done,
                                    onSubmitted: (_) =>
                                        FocusScope.of(context).unfocus(),
                                    inputFormatters: [
                                      LengthLimitingTextInputFormatter(
                                          maxChars),
                                    ],
                                    onChanged: (_) {
                                      setState(() {});
                                    },
                                    decoration: InputDecoration(
                                      contentPadding:
                                          EdgeInsets.all(screenHeight * 0.015),
                                      labelText: 'Notes :',
                                      alignLabelWithHint: true,
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                      floatingLabelStyle: getSemiBoldStyle(
                                        color: ColorManager.lightGrey1,
                                        fontSize: FontSize.s18,
                                      ),
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            screenHeight * 0.01),
                                        borderSide: BorderSide(
                                          color: ColorManager.grey
                                              .withOpacity(0.5),
                                          width: 1,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            screenHeight * 0.01),
                                        borderSide: BorderSide(
                                          color: ColorManager.grey
                                              .withOpacity(0.5),
                                          width: 1,
                                        ),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(
                                            screenHeight * 0.01),
                                        borderSide: BorderSide(
                                          color: ColorManager.darkBlue,
                                          width: 1.5,
                                        ),
                                      ),
                                      filled: true,
                                      fillColor: Colors.white,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 4, right: 4),
                                  child: Align(
                                    alignment: Alignment.centerRight,
                                    child: Text(
                                      "Characters remaining ${maxChars - widget.commentsController.text.length}",
                                      style: TextStyle(
                                        fontSize: FontSize.s14,
                                        color: ColorManager.darkGrey,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: screenHeight * 0.02),

                      SizedBox(
                        width: double.infinity,
                        child: CustomTextActionButton(
                          buttonText: widget.isReject
                              ? 'Confirm Reject'
                              : 'Confirm Receive',
                          backgroundColor: widget.isReject
                              ? ColorManager.red2
                              : ColorManager.green,
                          borderColor: Colors.transparent,
                          fontColor: ColorManager.white,
                          buttonWidth: double.infinity,
                          buttonHeight: 50,
                          isBoldFont: true,
                          fontSize: FontSize.s18,
                          onTap: widget.onConfirm,
                        ),
                      ),

                      SizedBox(height: screenHeight * 0.01),
                    ],
                  ),
                ),
              ),
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
