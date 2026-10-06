import 'dart:async';

import 'package:eyvo_v3/api/api_service/api_service.dart';
import 'package:eyvo_v3/api/response_models/order_approval_list_response.dart';
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
import 'package:eyvo_v3/core/widgets/custom_card_item.dart';
import 'package:eyvo_v3/core/widgets/custom_field.dart';
import 'package:eyvo_v3/core/widgets/progress_indicator.dart';
import 'package:eyvo_v3/features/auth/view/screens/approval/create_order_details.dart';
import 'package:eyvo_v3/features/auth/view/screens/approval/order_details_view.dart';
import 'package:flutter/material.dart';

class CreateOrderPage extends StatefulWidget {
  const CreateOrderPage({super.key});

  @override
  State<CreateOrderPage> createState() => _CreateOrderPageState();
}

class _CreateOrderPageState extends State<CreateOrderPage> with RouteAware {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final ApiService apiService = ApiService();

  List<OrderApprovalItem> orderApprovalList = [];
  bool isLoading = false;
  bool isError = false;
  String errorText = AppStrings.somethingWentWrong;
  String searchText = '';
  bool _showSearchBar = false;

  @override
  void initState() {
    super.initState();
    fetchOrderApprovalList();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    // Trigger search if ≥3 characters or cleared
    if (_searchController.text.length >= 3 || _searchController.text.isEmpty) {
      if (searchText != _searchController.text) {
        searchText = _searchController.text;
        _debounce?.cancel();
        _debounce = Timer(const Duration(milliseconds: 500), () {
          fetchOrderApprovalList();
        });
      }
    }
  }

  void fetchOrderApprovalList() async {
    setState(() {
      isLoading = true;
      isError = false;
      orderApprovalList.clear();
    });

    Map<String, dynamic> requestData = {
      'uid': SharedPrefs().uID,
      'search': _searchController.text,
    };

    final jsonResponse = await apiService.postRequest(
      context,
      ApiService.orderApprovalList,
      requestData,
    );

    if (jsonResponse != null) {
      final response = OrderApprovalListResponse.fromJson(jsonResponse);

      if (response.code == 200) {
        setState(() {
          orderApprovalList = response.data;
          isLoading = false;
        });
      } else {
        setState(() {
          isError = true;
          errorText = response.message.join(', ');
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isError = true;
        errorText = AppStrings.somethingWentWrong;
        isLoading = false;
      });
    }
  }

  Widget _buildSearchRow() {
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Row(
        children: [
          if (_showSearchBar) ...[
            // Expanded search bar
            Expanded(
              child: CustomSearchField(
                controller: _searchController,
                placeholderText: AppStrings.searchOrderNumber,
                inputType: TextInputType.text,
                autoFocus: true,
              ),
            ),
            const SizedBox(width: 8),
            // Close button
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
            // Compact search field
            Flexible(
              flex: 1, // leaves space for icons
              child: CustomSearchField(
                controller: _searchController,
                placeholderText: AppStrings.searchItems,
                inputType: TextInputType.text,
                autoFocus: false,
                readOnly: true,
                onTap: () {
                  setState(() => _showSearchBar = true);
                },
              ),
            ),
            const SizedBox(width: 10),

            GestureDetector(
              onTap: () {
                // Navigate to CreateOrderDetailsPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const CreateOrderDetailsPage(),
                  ),
                );
              },
              child: Container(
                height: 40,
                width: 40,
                decoration: BoxDecoration(
                  color: ColorManager.blue,
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(
                    Icons.add,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primary,
      appBar: AppBar(
        backgroundColor: ColorManager.darkBlue,
        titleSpacing: -10,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Create Order',
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
          // Refresh Button
          IconButton(
            onPressed: () {
              setState(() {
                _searchController.clear();
                fetchOrderApprovalList();
              });
            },
            icon: Icon(Icons.refresh, color: ColorManager.white),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: _buildSearchRow(),
          ),

          // Loading
          if (isLoading)
            const Expanded(child: Center(child: CustomProgressIndicator()))

          // Error
          else if (isError)
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      ImageAssets.noRecordFoundIcon,
                      width: displayWidth(context) * 0.5,
                    ),
                    const SizedBox(height: 10),
                    Text(errorText),
                  ],
                ),
              ),
            )

          // No Data
          else if (orderApprovalList.isEmpty)
            Expanded(
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
                      "No Records Found",
                      style: getRegularStyle(
                        color: ColorManager.black,
                        fontSize: FontSize.s17,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: ListView.builder(
                itemCount: orderApprovalList.length,
                itemBuilder: (context, index) {
                  final order = orderApprovalList[index];
                  return
                      // CommonCardWidget(
                      //   subtitles: [
                      //     {'Order No': order.orderNumber},
                      //     {'Status': order.orderStatus},
                      //     {'Supplier Name': order.supplierName},
                      //     {'Order Date': order.orderDate},
                      //     {
                      //       'Order Net Total':
                      //           '${getFormattedPriceString(order.orderValue)}'
                      //     },
                      //   ],
                      //   onTap: () {
                      //     navigateToScreen(
                      //       context,
                      //       OrderDetailsView(
                      //         orderId: order.orderId,
                      //         orderNumber: order.orderNumber,
                      //       ),
                      //     );
                      //   },
                      // );
                      GenericCardWidget(
                    titleKey: 'Order #${order.orderNumber}',
                    statusKey: order.orderStatus,
                    supplierKey: 'Tanuja Patil',
                    dateKey: order.orderDate,
                    valueKey: getFormattedPriceString(order.orderValue),
                    valueNameKey: 'Order Value',
                    itemCountKey: '5',
                    onTap: () {
                      navigateToScreen(
                        context,
                        const CreateOrderDetailsPage(),
                      );
                    },
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
