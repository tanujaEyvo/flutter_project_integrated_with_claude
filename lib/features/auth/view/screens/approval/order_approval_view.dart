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
import 'package:eyvo_v3/features/auth/view/screens/approval/order_details_view.dart';
import 'package:flutter/material.dart';

class OrderApproverPage extends StatefulWidget {
  const OrderApproverPage({super.key});

  @override
  State<OrderApproverPage> createState() => _OrderApproverPageState();
}

class _OrderApproverPageState extends State<OrderApproverPage> with RouteAware {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  final ApiService apiService = ApiService();

  List<OrderApprovalItem> orderApprovalList = [];
  bool isLoading = false;
  bool isError = false;
  String errorText = AppStrings.somethingWentWrong;
  String searchText = '';

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
          fetchOrderApprovalList(); // re-fetch API with search
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
      'search': _searchController.text, // pass search query to API
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
          AppStrings.orderApproval,
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
            child: CustomSearchField(
              controller: _searchController,
              placeholderText: 'Search by order number or net total',
            ),
          ),

          // Loading
          if (isLoading)
            const Expanded(child: Center(child: CustomProgressIndicator()))

          // Error
          else if (isError)
            Expanded(
              child: Container(
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
                      errorText,
                      style: getRegularStyle(
                        color: ColorManager.black,
                        fontSize: FontSize.s17,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )

          // No Data
          else if (orderApprovalList.isEmpty)
            Expanded(
              child: Container(
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
                      "No Records Found",
                      style: getRegularStyle(
                        color: ColorManager.black,
                        fontSize: FontSize.s17,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )

          // Data List
          else
            Expanded(
              child: ListView.builder(
                itemCount: orderApprovalList.length,
                itemBuilder: (context, index) {
                  final order = orderApprovalList[index];
                  return CommonCardWidget(
                    subtitles: [
                      {'Order No': order.orderNumber},
                      {'Status': order.orderStatus},
                      {'Order Date': order.orderDate},
                      {
                        'Order Net Total':
                            '${getFormattedPriceString(order.orderValue)}'
                      },
                    ],
                    onTap: () {
                      navigateToScreen(
                        context,
                        OrderDetailsView(
                          orderId: order.orderId,
                          orderNumber: order.orderNumber,
                        ),
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
