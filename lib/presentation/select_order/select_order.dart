import 'dart:async';
import 'package:eyvo_v3/api/api_service/api_service.dart';
import 'package:eyvo_v3/api/response_models/order_response.dart';
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
import 'package:eyvo_v3/core/widgets/progress_indicator.dart';
import 'package:eyvo_v3/presentation/received_item_list/received_item_list.dart';
import 'package:flutter/material.dart';

class SelectOrderView extends StatefulWidget {
  const SelectOrderView({super.key});

  @override
  State<SelectOrderView> createState() => _SelectOrderViewState();
}

class _SelectOrderViewState extends State<SelectOrderView> with RouteAware {
  Timer? _debounce;
  late ScrollController _scrollController;
  final TextEditingController searchController = TextEditingController();
  bool isSearching = false;
  bool isLoading = false;
  bool isLoadMore = false;
  String searchText = '';
  final ApiService apiService = ApiService();
  late List<OrderData> orderItems = [];
  bool isError = false;
  String errorText = AppStrings.somethingWentWrong;
  int page = 1;
  int totalRecords = AppConstants.totalRecords;
  int pageSize = AppConstants.pageSize;
  int _lastLoadedPage = 0;
  // Add this flag to track if we're coming back from detail
  bool _isReturningFromDetail = false;
  bool _isFetching = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context) as PageRoute);
  }

  // @override
  // void didPopNext() {
  //   // When coming back from detail, refresh the list
  //   // but keep the current search text
  //   _isReturningFromDetail = true;
  //   setState(() {
  //     page = 1;
  //     orderItems.clear();
  //     totalRecords = 0;
  //   });
  //   fetchOrders(false);
  // }
  @override
  void didPopNext() {
    _debounce?.cancel(); // <-- add this
    _isReturningFromDetail = true;
    setState(() {
      page = 1;
      orderItems.clear();
      totalRecords = 0;
    });
    fetchOrders(false);
  }

  @override
  void initState() {
    super.initState();
    searchController.addListener(_onSearchChanged);
    _scrollController = ScrollController()..addListener(_scrollListener);
    fetchOrders(false);
  }

  void _scrollListener() {
    if (_scrollController.position.pixels ==
        _scrollController.position.maxScrollExtent) {
      fetchOrders(true);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _debounce?.cancel();
    searchController.removeListener(_onSearchChanged);
    searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  _onSearchChanged() {
    if (searchController.text.length >= 3 || searchController.text.isEmpty) {
      if (searchText != searchController.text) {
        setState(() {
          searchText = searchController.text;
          isSearching = true;
          page = 1;
          orderItems.clear();
          totalRecords = 0;
        });
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 550), () {
          fetchOrders(false);
        });
      }
    }
  }

  // void fetchOrders(bool isLoadingMoreItems) async {
  //   // Check if we're already loading or have loaded all records
  //   if (isLoading ||
  //       isLoadMore ||
  //       (totalRecords > 0 && orderItems.length >= totalRecords)) {
  //     // If we're returning from detail and there's no new data to load,
  //     // we should still allow a refresh
  //     if (!_isReturningFromDetail) {
  //       return;
  //     }
  //   }

  //   setState(() {
  //     if (!isLoadingMoreItems) {
  //       isError = false;
  //       // Don't clear items if we're returning from detail with search text
  //       if (!_isReturningFromDetail) {
  //         orderItems.clear();
  //         page = 1;
  //         totalRecords = 0;
  //       } else {
  //         // Reset the flag after handling
  //         _isReturningFromDetail = false;
  //       }
  //     }
  //     isLoading = !isLoadingMoreItems && !isSearching;
  //     isLoadMore = isLoadingMoreItems;
  //   });

  //   int requestPage = isLoadingMoreItems ? page + 1 : 1;

  //   Map<String, dynamic> data = {
  //     'uid': SharedPrefs().uID,
  //     'search': searchController.text,
  //     'regionid': SharedPrefs().selectedRegionID,
  //     'pageno': requestPage,
  //     'pagesize': AppConstants.pageSize
  //   };

  //   try {
  //     final jsonResponse = await apiService.postRequest(
  //         context, ApiService.goodReceiveOrderList, data);

  //     if (jsonResponse != null) {
  //       final response = OrderResponse.fromJson(jsonResponse);
  //       if (response.code == '200') {
  //         setState(() {
  //           orderItems.addAll(response.data ?? []);
  //           page = requestPage;
  //           totalRecords = response.totalRecords ?? orderItems.length;
  //           isError = false;
  //         });
  //       } else {
  //         setState(() {
  //           isError = true;
  //           errorText =
  //               response.message?.join(', ') ?? AppStrings.somethingWentWrong;
  //         });
  //       }
  //     } else {
  //       setState(() {
  //         isError = true;
  //         errorText = AppStrings.somethingWentWrong;
  //       });
  //     }
  //   } catch (e) {
  //     setState(() {
  //       isError = true;
  //       errorText = AppStrings.somethingWentWrong;
  //     });
  //   }

  //   setState(() {
  //     isLoading = false;
  //     isSearching = false;
  //     isLoadMore = false;
  //   });
  // }
  Future<void> fetchOrders(bool isLoadingMoreItems) async {
    if (_isFetching) return;
    if (isLoadingMoreItems &&
        totalRecords > 0 &&
        orderItems.length >= totalRecords) {
      return;
    }

    _isFetching = true;
    final int requestPage = isLoadingMoreItems ? page + 1 : 1;

    setState(() {
      if (!isLoadingMoreItems) {
        isError = false;
        orderItems.clear();
        page = 1;
        totalRecords = 0;
      }
      isLoading = !isLoadingMoreItems && !isSearching;
      isLoadMore = isLoadingMoreItems;
    });

    final Map<String, dynamic> data = {
      'uid': SharedPrefs().uID,
      'search': searchController.text,
      'regionid': SharedPrefs().selectedRegionID,
      'pageno': requestPage,
      'pagesize': AppConstants.pageSize,
    };

    try {
      final jsonResponse = await apiService.postRequest(
          context, ApiService.goodReceiveOrderList, data);

      if (jsonResponse != null) {
        final response = OrderResponse.fromJson(jsonResponse);
        if (response.code == '200') {
          setState(() {
            if (isLoadingMoreItems) {
              orderItems.addAll(response.data ?? []);
            } else {
              orderItems = List<OrderData>.from(response.data ?? []);
            }
            page = requestPage;
            totalRecords = response.totalRecords ?? orderItems.length;
            isError = false;
          });
        } else {
          setState(() {
            isError = true;
            errorText =
                response.message?.join(', ') ?? AppStrings.somethingWentWrong;
          });
        }
      } else {
        setState(() {
          isError = true;
          errorText = AppStrings.somethingWentWrong;
        });
      }
    } catch (e) {
      setState(() {
        isError = true;
        errorText = AppStrings.somethingWentWrong;
      });
    } finally {
      setState(() {
        isLoading = false;
        isSearching = false;
        isLoadMore = false;
      });
      _isFetching = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: ColorManager.primary,
        appBar: buildCommonAppBar(
          context: context,
          title: AppStrings.selectOrder,
        ),
        body: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              const SizedBox(height: 8),
              CustomSearchField(
                controller: searchController,
                placeholderText: AppStrings.searchOrderNumber,
              ),
              const SizedBox(height: 8),

              // LOADING STATE (initial load OR searching)
              if (isLoading || isSearching)
                const Expanded(
                  child: Center(child: CustomProgressIndicator()),
                )

              // ERROR STATE
              else if (isError)
                Expanded(
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
                  ),
                )

              // NO DATA STATE (only if search complete)
              else if (orderItems.isEmpty)
                Expanded(
                  child: Center(
                    child: Text(
                      "No Records Found",
                      style: getRegularStyle(
                        color: ColorManager.black,
                        fontSize: FontSize.s20,
                      ),
                    ),
                  ),
                )

              // DATA LIST STATE
              else
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (ScrollNotification notification) {
                      if (notification is ScrollStartNotification) {
                        FocusScope.of(context).unfocus();
                      }
                      return false;
                    },
                    child: ListView.separated(
                      controller: _scrollController,
                      itemCount: orderItems.length + 1,
                      separatorBuilder: (context, index) => Divider(
                        color: ColorManager.primary,
                        height: 2,
                        thickness: 2,
                      ),
                      itemBuilder: (context, index) {
                        if (index == orderItems.length) {
                          if (orderItems.length >= totalRecords) {
                            return const SizedBox();
                          }
                          return const Center(child: CustomProgressIndicator());
                        }

                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8.0,
                            vertical: 4.0,
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              color: ColorManager.white,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              title: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Expanded(
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            orderItems[index].orderNumber ?? '',
                                            style: getSemiBoldStyle(
                                              color: ColorManager.black,
                                              fontSize: FontSize.s16,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          const SizedBox(height: 2),
                                          Text(
                                            orderItems[index].supplierName ??
                                                '',
                                            style: getRegularStyle(
                                              color: ColorManager.lightGrey,
                                              fontSize: FontSize.s14,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      SizedBox(
                                        width: 90,
                                        child: Align(
                                          alignment: Alignment.centerRight,
                                          child: Text(
                                            orderItems[index].orderDate ?? '',
                                            style: getRegularStyle(
                                              color: ColorManager.lightGrey1,
                                              fontSize: FontSize.s12,
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      SizedBox(
                                        width: 75,
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6.0, vertical: 2.0),
                                          decoration: BoxDecoration(
                                            color: getStatusColor(
                                                    orderItems[index]
                                                        .orderStatus)
                                                .withOpacity(0.2),
                                            borderRadius:
                                                BorderRadius.circular(8),
                                          ),
                                          child: Center(
                                            child: Text(
                                              orderItems[index].orderStatus ??
                                                  'REJECTED',
                                              style: getSemiBoldStyle(
                                                color: getStatusColor(
                                                    orderItems[index]
                                                        .orderStatus),
                                                fontSize: FontSize.s12,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.receivedItemListRoute,
                                  arguments: {
                                    'orderNumber':
                                        orderItems[index].orderNumber ?? '',
                                    'orderId': orderItems[index].orderId ?? 0,
                                  },
                                );
                              },
                            ),
                          ),
                        );
                      },
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
