import 'dart:async';
import 'dart:convert';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:eyvo_v3/api/api_service/api_service.dart';
import 'package:eyvo_v3/api/response_models/item_list_response.dart';
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
import 'package:eyvo_v3/core/widgets/common_app_bar.dart';
import 'package:eyvo_v3/core/widgets/custom_field.dart';
import 'package:eyvo_v3/core/widgets/custom_list_tile.dart';
import 'package:eyvo_v3/core/widgets/progress_indicator.dart';
import 'package:eyvo_v3/log_data.dart/logger_data.dart';
import 'package:eyvo_v3/presentation/blind_stock_details/blindstock_details.dart';
import 'package:eyvo_v3/services/error_logging_service.dart';
import 'package:flutter/material.dart';

class BlindStockListView extends StatefulWidget {
  const BlindStockListView({super.key});

  @override
  State<BlindStockListView> createState() => _BlindStockListViewState();
}

class _BlindStockListViewState extends State<BlindStockListView>
    with RouteAware {
  late ScrollController _scrollController;
  Timer? _debounce;
  final TextEditingController _searchController = TextEditingController();
  String searchText = '';
  late List<ListItem> listItems = [];
  bool isListViewSelected = true;
  bool isSearching = false;
  bool isLoading = false;
  bool isLoadMore = false;
  bool isError = false;
  String errorText = AppStrings.somethingWentWrong;
  final ApiService apiService = ApiService();
  int page = 1;
  int totalRecords = AppConstants.totalRecords;
  int pageSize = AppConstants.pageSize;
  bool _showSearchBar = false; // toggle state

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _scrollController = ScrollController()..addListener(_scrollListener);
    fetchListItems(false);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  @override
  void didPopNext() {
    page = 1;
    listItems = [];
    fetchListItems(false);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      fetchListItems(true);
    }
  }

  void _onSearchChanged() {
    if (_searchController.text.length >= 2 || _searchController.text.isEmpty) {
      if (searchText != _searchController.text) {
        setState(() {
          searchText = _searchController.text;
          isSearching = true;
          page = 1;
          listItems.clear();
          totalRecords = 0;
        });

        // Cancel previous debounce timer
        _debounce?.cancel();

        // Delay API call for smoother search
        _debounce = Timer(const Duration(milliseconds: 550), () {
          fetchListItems(false);
        });
      }
    }
  }

  void fetchListItems(bool isLoadingMoreItems) async {
    if (isLoading ||
        isLoadMore ||
        (totalRecords > 0 && listItems.length >= totalRecords)) return;

    setState(() {
      if (!isLoadingMoreItems) {
        isError = false; // reset before fetch
      }
      isLoading = !isLoadingMoreItems && !isSearching;
      isLoadMore = isLoadingMoreItems;
    });

    int requestPage = isLoadingMoreItems ? page + 1 : page;

    Map<String, dynamic> data = {
      "regionid": SharedPrefs().selectedRegionID,
      "locationid": SharedPrefs().selectedLocationID,
      "search": _searchController.text,
      "pageno": requestPage,
      "pagesize": AppConstants.pageSize
    };

    try {
      final jsonResponse = await apiService.postRequest(
          context, ApiService.blindStockListing, data);
//  throw Exception("Testing ErrorLoggingService");
      if (jsonResponse != null) {
        final response = ItemListResponse.fromJson(jsonResponse);
        if (response.code == '200') {
          setState(() {
            if (isLoadingMoreItems) {
              listItems.addAll(response.data ?? []);
              page = requestPage;
            } else {
              listItems = response.data ?? [];
              page = requestPage;
            }
            totalRecords = response.totalRecords ?? listItems.length;
            isError = false;
          });
        } else {
          setState(() {
            isError = true;
            errorText = response.message.join(', ');
            if (!isLoadingMoreItems) listItems = [];
          });
        }
      } else {
        setState(() {
          isError = true;
          errorText = AppStrings.somethingWentWrong;
          if (!isLoadingMoreItems) listItems = [];
        });
      }
    } catch (e, stackTrace) {
      await ErrorLoggingService().logApiError(
        exceptionMessage: e.toString(),
        stackTrace: stackTrace.toString(),
        apiUrl: ApiService.blindStockListing,
        requestBody: jsonEncode(data),
        screenName: 'blindstock_list.dart',
        methodName: 'fetchListItems',
        context: context,
      );

      setState(() {
        isError = true;
        errorText = AppStrings.somethingWentWrong;
        if (!isLoadingMoreItems) listItems = [];
      });
    }

    setState(() {
      isLoading = false;
      isSearching = false;
      isLoadMore = false;
    });
  }

  void navigateToItemDetails(ListItem selectedItem) {
    Navigator.pushNamed(
      context,
      Routes.blindStockDetailsRoute,
      arguments: {
        'itemId': selectedItem.itemId,
        'entryType': EntryType.listing.name
      },
    );
  }

  void navigateToItemDetailsScan(String resultString, String scanFormat) {
    Navigator.pushNamed(context, Routes.blindStockDetailsRoute, arguments: {
      'resultString': resultString,
      'entryType': EntryType.scan.name,
      'scanFormat': scanFormat
    });
  }

  // Future<void> scanBarcode() async {
  //   try {
  //     ScanResult barcodeScanResult = await BarcodeScanner.scan();
  //     String resultString = barcodeScanResult.rawContent;
  //     if (resultString.isNotEmpty && resultString != "-1") {
  //       Map<String, dynamic> jsonDict = jsonDecode(resultString);
  //       // SharedPrefs().scannedLocationID = jsonDict['location_id'];
  //       // SharedPrefs().scannedRegionID = jsonDict['region_id'];
  //       // SharedPrefs().isItemScanned = true;
  //       navigateToItemDetailsScan(jsonDict['itemid']);
  //     }
  //   } catch (e) {
  //     setState(() {
  //       errorText = "Failed to scan";
  //     });
  //   }
  // }
  Future<void> scanBarcode() async {
    try {
      ScanResult barcodeScanResult = await BarcodeScanner.scan();
      String resultString = barcodeScanResult.rawContent;
      String format = barcodeScanResult.format.toString();

      // Log the format for debugging
      LoggerData.dataLog('=== BARCODE SCAN ===');
      LoggerData.dataLog('Format: $format');
      LoggerData.dataLog('Raw Content: $resultString');

      if (resultString.isEmpty || resultString == "-1") {
        return;
      }
      navigateToItemDetailsScan(resultString, format);
      //     }
    } catch (e) {
      setState(() {
        errorText = "Failed to scan: $e";
      });
    }
  }

  void navigateToScanItems() {
    scanBarcode();
  }

  Widget _buildSearchToggleRow() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          if (_showSearchBar) ...[
            // Expanded search bar (takes max space)
            Expanded(
              child: CustomSearchField(
                controller: _searchController,
                placeholderText: AppStrings.searchItems,
                inputType: TextInputType.text,
                autoFocus: true, // focus immediately
              ),
            ),
            const SizedBox(width: 8),
            // Cross button to close
            IconButton(
              icon: Icon(Icons.close, color: ColorManager.black),
              onPressed: () {
                setState(() {
                  _showSearchBar = false;
                  _searchController.clear();
                });
              },
            ),
          ] else ...[
            // Responsive compact search field
            Flexible(
              flex: 3, // leaves space for icons
              child: CustomSearchField(
                controller: _searchController,
                placeholderText: AppStrings.searchItems,
                inputType: TextInputType.text,
                autoFocus: false,
                readOnly: true,
                onTap: () {
                  // when tapped, expand to full search mode
                  setState(() => _showSearchBar = true);
                },
              ),
            ),

            const SizedBox(width: 8),

            // Right-side icons (grouped with padding)
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // List toggle
                IconButton(
                  icon: SizedBox(
                    height: 20,
                    width: 20,
                    child: Image.asset(
                      isListViewSelected
                          ? ImageAssets.boxSelectedIcon
                          : ImageAssets.boxIcon,
                    ),
                  ),
                  onPressed: () => setState(() => isListViewSelected = true),
                ),

                // Divider
                Container(
                  color: ColorManager.lightBlue2,
                  height: 35,
                  width: 2,
                ),

                // Grid toggle
                IconButton(
                  icon: SizedBox(
                    height: 20,
                    width: 20,
                    child: Image.asset(
                      isListViewSelected
                          ? ImageAssets.gridIcon
                          : ImageAssets.gridSelectedIcon,
                    ),
                  ),
                  onPressed: () => setState(() => isListViewSelected = false),
                ),

                // Scanner button with safe right padding
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: IconButton(
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                    icon: Icon(
                      Icons.qr_code_scanner_outlined,
                      color: ColorManager.blue,
                    ),
                    onPressed: () => navigateToScanItems(),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const double sidePadding = 18;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenWidth >= 600;
    final isLandscape = screenWidth > screenHeight;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: ColorManager.primary,
        appBar: buildCommonAppBar(
          context: context,
          title: 'Blind Stock Listing',
        ),
        body: SafeArea(
          child: Column(
            children: [
              //  Always show search bar at top
              _buildSearchToggleRow(),

              //  Loader / Error / List / Grid below
              Expanded(
                child: isLoading && listItems.isEmpty
                    ? const Center(child: CustomProgressIndicator())
                    : isError
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
                        : Padding(
                            padding: const EdgeInsets.symmetric(
                                horizontal: sidePadding, vertical: 8),
                            child: listItems.isEmpty
                                ? const Center(
                                    child: CustomProgressIndicator(),
                                  )
                                : NotificationListener<ScrollNotification>(
                                    onNotification:
                                        (ScrollNotification notification) {
                                      if (notification
                                          is ScrollStartNotification) {
                                        FocusScope.of(context).unfocus();
                                      }
                                      return false;
                                    },
                                    child: isListViewSelected
                                        ? ListView.builder(
                                            controller: _scrollController,
                                            itemCount: listItems.length +
                                                (isLoading ||
                                                        listItems.length >=
                                                            totalRecords
                                                    ? 0
                                                    : 1),
                                            itemBuilder: (context, index) {
                                              if (index == listItems.length) {
                                                return const Center(
                                                  child:
                                                      CustomProgressIndicator(),
                                                );
                                              }
                                              return Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 6.0),
                                                child: GestureDetector(
                                                  onTap: () {
                                                    navigateToItemDetails(
                                                        listItems[index]);
                                                  },
                                                  child: ItemListTile(
                                                    title: listItems[index]
                                                        .outline,
                                                    subtitle1: listItems[index]
                                                        .itemCode,
                                                    subtitle2: listItems[index]
                                                            .categoryCode ??
                                                        "",
                                                    // subtitle3:
                                                    //     getFormattedPriceString(
                                                    //         listItems[index]
                                                    //             .stockCount),
                                                    imageString:
                                                        listItems[index]
                                                            .itemImage,
                                                  ),
                                                ),
                                              );
                                            },
                                          )
                                        : GridView.builder(
                                            controller: _scrollController,
                                            itemCount: listItems.length +
                                                (isLoading ||
                                                        listItems.length >=
                                                            totalRecords
                                                    ? 0
                                                    : 1),
                                            gridDelegate:
                                                SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: isTablet
                                                  ? (isLandscape ? 3 : 2)
                                                  : (isLandscape ? 2 : 2),
                                              crossAxisSpacing: 8.0,
                                              mainAxisSpacing: 8.0,
                                              childAspectRatio: isTablet
                                                  ? (isLandscape ? 0.85 : 0.95)
                                                  : (isLandscape ? 1.1 : 0.75),
                                            ),
                                            padding: const EdgeInsets.all(8.0),
                                            itemBuilder: (context, index) {
                                              if (index == listItems.length) {
                                                return const Center(
                                                  child:
                                                      CustomProgressIndicator(),
                                                );
                                              }

                                              return GestureDetector(
                                                onTap: () {
                                                  navigateToItemDetails(
                                                      listItems[index]);
                                                },
                                                child: ItemGridTile(
                                                  title:
                                                      listItems[index].outline,
                                                  subtitle1:
                                                      listItems[index].itemCode,
                                                  subtitle2: listItems[index]
                                                          .categoryCode ??
                                                      "",
                                                  imageString: listItems[index]
                                                      .itemImage,
                                                ),
                                              );
                                            },
                                          ),
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
