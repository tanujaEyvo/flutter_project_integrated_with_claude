import 'package:eyvo_v3/app/sizes_helper.dart';
import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:eyvo_v3/core/utils.dart';
import 'package:eyvo_v3/core/widgets/alert.dart';
import 'package:eyvo_v3/core/widgets/common_app_bar.dart';
import 'package:eyvo_v3/local_db/dao/offline_db_dao.dart';
import 'package:eyvo_v3/local_db/model/offline_item_stock_model.dart';
import 'package:eyvo_v3/log_data.dart/logger_data.dart';
import 'package:flutter/material.dart';

import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/styles_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class TransactionsRoute extends StatefulWidget {
  const TransactionsRoute({super.key});

  @override
  State<TransactionsRoute> createState() => _TransactionsRouteState();
}

class _TransactionsRouteState extends State<TransactionsRoute> {
  final OfflineDBDao _dao = OfflineDBDao();
  List<OfflineItemStock> transactions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadTransactions();
  }

  Future<void> loadTransactions() async {
    try {
      final data = await _dao.getUnsyncedItemsWithRegionAndLocation();

      setState(() {
        transactions = data;
      });
    } catch (e, stackTrace) {
      await _dao.insertErrorLog(
        exceptionMessage: e.toString(),
        stackTrace: stackTrace.toString(),
        apiUrl: 'OFFLINE - SQLite - getUnsyncedItems',
        requestBody: null,
        screenName: 'TransactionsView',
        methodName: 'loadTransactions',
      );

      LoggerData.dataLog('loadTransactions Exception: $e');
      LoggerData.dataLog(stackTrace.toString());

      setState(() {
        transactions = [];
      });

      showSnackBar(context, 'Failed to load transactions');
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) return "";

    try {
      final dateTime = DateTime.parse(dateString);
      return DateFormat('dd-MMM-yyyy').format(dateTime);
    } catch (e) {
      return dateString;
    }
  }

  void showDeleteConfirmation(OfflineItemStock item) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomImageActionAlert(
          iconString: '',
          imageString: ImageAssets.deleteTransactions,
          titleString: "Delete Transaction",
          subTitleString:
              "Are you sure you want to delete this transaction?\nThis action cannot be reversed.",
          destructiveActionString: "Delete",
          destructiveButtonColor: ColorManager.red,
          normalActionString: "Cancel",
          onDestructiveActionTap: () async {
            await _dao.deleteTransaction(itemId: item.itemId!);

            Navigator.of(context).pop();
            await loadTransactions();
          },
          onNormalActionTap: () {
            Navigator.of(context).pop();
          },
          isConfirmationAlert: true,
          isNormalAlert: true,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
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
              'Adjusted Inventory',
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
          ? const Center(child: CircularProgressIndicator())
          : transactions.isEmpty
              ? Container(
                  width: double.infinity,
                  color: ColorManager.white,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Image.asset(
                        ImageAssets.noRecordFoundIcon,
                        width: displayWidth(context) * 0.5,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'No Pending Transactions',
                        style: getSemiBoldStyle(
                          color: ColorManager.black,
                          fontSize: FontSize.s17,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: transactions.length,
                  itemBuilder: (context, index) {
                    final item = transactions[index];
                    return buildTransactionCard(item);
                  },
                ),
    );
  }

  Widget buildTransactionCard(OfflineItemStock item) {
    // Build location and region display string
    String locationDisplay = '';
    if (item.regionName != null &&
        item.regionName!.isNotEmpty &&
        item.locationName != null &&
        item.locationName!.isNotEmpty) {
      locationDisplay = '${item.regionName}-${item.locationName}';
    } else if (item.locationName != null && item.locationName!.isNotEmpty) {
      locationDisplay = item.locationName!;
    } else if (item.regionName != null && item.regionName!.isNotEmpty) {
      locationDisplay = item.regionName!;
    }

    return InkWell(
      borderRadius: BorderRadius.circular(8),
      child: Card(
        color: ColorManager.white,
        margin: const EdgeInsets.symmetric(vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location and Region Display
              if (locationDisplay.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    locationDisplay,
                    style: getSemiBoldStyle(
                      color: ColorManager.blue, // Use your blue color
                      fontSize: FontSize.s12,
                    ),
                  ),
                ),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Item Code",
                          style: getSemiBoldStyle(
                            color: ColorManager.lightGrey1,
                            fontSize: FontSize.s14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          item.itemCode ?? "",
                          style: getBoldStyle(
                            color: ColorManager.black,
                            fontSize: FontSize.s14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        IconButton(
                          icon: Icon(
                            FontAwesomeIcons.trashCan,
                            color: ColorManager.red,
                          ),
                          onPressed: () {
                            showDeleteConfirmation(item);
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(thickness: 0.8),
              Text(
                "Description",
                style: getSemiBoldStyle(
                  color: ColorManager.lightGrey1,
                  fontSize: FontSize.s14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                item.description != null && item.description!.length > 50
                    ? '${item.description!.substring(0, 50)}...'
                    : (item.description ?? ""),
                style: getRegularStyle(
                  color: ColorManager.black,
                  fontSize: FontSize.s14,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Adjusted on",
                        style: getSemiBoldStyle(
                          color: ColorManager.lightGrey1,
                          fontSize: FontSize.s14,
                        ),
                      ),
                      Text(
                        formatDate(item.updatedOn),
                        style: getSemiBoldStyle(
                          color: ColorManager.black,
                          fontSize: FontSize.s16,
                        ),
                      ),
                    ],
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          "Adjusted Stock${(item.unitName != null && item.unitName!.isNotEmpty) ? " (${item.unitName})" : ""}",
                          style: getSemiBoldStyle(
                            color: ColorManager.lightGrey1,
                            fontSize: FontSize.s14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatQuantityString(double.parse(
                              item.newStockCount?.toString() ?? "0")),
                          style: getBoldStyle(
                            color: ColorManager.black,
                            fontSize: FontSize.s18,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
  // Widget buildTransactionCard(OfflineItemStock item) {
  //   return InkWell(
  //     borderRadius: BorderRadius.circular(8),
  //     child: Card(
  //       color: ColorManager.white,
  //       margin: const EdgeInsets.symmetric(vertical: 6),
  //       shape: RoundedRectangleBorder(
  //         borderRadius: BorderRadius.circular(8),
  //       ),
  //       child: Padding(
  //         padding: const EdgeInsets.all(12),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               children: [
  //                 Expanded(
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Text(
  //                         "Item Code",
  //                         style: getSemiBoldStyle(
  //                           color: ColorManager.lightGrey1,
  //                           fontSize: FontSize.s14,
  //                         ),
  //                       ),
  //                       const SizedBox(height: 4),
  //                       Text(
  //                         item.itemCode ?? "",
  //                         style: getBoldStyle(
  //                           color: ColorManager.black,
  //                           fontSize: FontSize.s18,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 Expanded(
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.end,
  //                     children: [
  //                       IconButton(
  //                         icon: Icon(
  //                           FontAwesomeIcons.trashCan,
  //                           color: ColorManager.red,
  //                         ),
  //                         onPressed: () {
  //                           showDeleteConfirmation(item);
  //                         },
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             const Divider(thickness: 0.8),
  //             Text(
  //               "Description",
  //               style: getSemiBoldStyle(
  //                 color: ColorManager.lightGrey1,
  //                 fontSize: FontSize.s14,
  //               ),
  //             ),
  //             const SizedBox(height: 4),
  //             Text(
  //               item.description != null && item.description!.length > 50
  //                   ? '${item.description!.substring(0, 50)}...'
  //                   : (item.description ?? ""),
  //               style: getRegularStyle(
  //                 color: ColorManager.black,
  //                 fontSize: FontSize.s14,
  //               ),
  //             ),
  //             const SizedBox(height: 10),
  //             Row(
  //               crossAxisAlignment: CrossAxisAlignment.start,
  //               children: [
  //                 Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     Text(
  //                       "Adjusted on",
  //                       style: getSemiBoldStyle(
  //                         color: ColorManager.lightGrey1,
  //                         fontSize: FontSize.s14,
  //                       ),
  //                     ),
  //                     Text(
  //                       formatDate(item.updatedOn),
  //                       style: getSemiBoldStyle(
  //                         color: ColorManager.black,
  //                         fontSize: FontSize.s16,
  //                       ),
  //                     ),
  //                   ],
  //                 ),
  //                 Expanded(
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.end,
  //                     children: [
  //                       Text(
  //                         "Adjusted Stock",
  //                         style: getSemiBoldStyle(
  //                           color: ColorManager.lightGrey1,
  //                           fontSize: FontSize.s14,
  //                         ),
  //                       ),
  //                       const SizedBox(height: 4),
  //                       Text(
  //                         getFormattedPriceString(double.parse(
  //                             item.newStockCount?.toString() ?? "0")),
  //                         style: getBoldStyle(
  //                           color: ColorManager.black,
  //                           fontSize: FontSize.s18,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //               ],
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
}
