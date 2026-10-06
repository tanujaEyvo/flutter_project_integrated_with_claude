import 'package:eyvo_v3/api/api_service/api_service.dart';
import 'package:eyvo_v3/api/response_models/request_approval_list_response.dart';
import 'package:eyvo_v3/app/app_prefs.dart';
import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/strings_manager.dart';
import 'package:eyvo_v3/core/resources/styles_manager.dart';
import 'package:eyvo_v3/core/utils.dart';
import 'package:eyvo_v3/core/widgets/custom_card_item.dart';
import 'package:eyvo_v3/core/widgets/custom_field.dart';
import 'package:eyvo_v3/core/widgets/progress_indicator.dart';
import 'package:eyvo_v3/features/auth/view/screens/approval/request_approval_details.dart';
import 'package:flutter/material.dart';

class RequestApprovalPage extends StatefulWidget {
  const RequestApprovalPage({super.key});

  @override
  State<RequestApprovalPage> createState() => _RequestApprovalPageState();
}

class _RequestApprovalPageState extends State<RequestApprovalPage> {
  final TextEditingController _searchController = TextEditingController();
  final ApiService apiService = ApiService();

  List<Datum> requestApprovalList = [];
  List<Datum> filteredRequests = [];

  bool isLoading = false;
  bool isError = false;
  String errorText = AppStrings.somethingWentWrong;

  @override
  void initState() {
    super.initState();
    fetchRequestApprovalList();
    _searchController.addListener(_filterRequests);
  }

  void fetchRequestApprovalList() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> requestData = {
      'uid': SharedPrefs().uID,
    };

    final jsonResponse = await apiService.postRequest(
      context,
      ApiService.requestApprovalList,
      requestData,
    );

    if (jsonResponse != null) {
      final response = RequestApprovalListResponse.fromJson(jsonResponse);

      if (response.code == 200) {
        setState(() {
          requestApprovalList = response.data;
          filteredRequests = response.data;
          isLoading = false;
          isError = false;
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
        errorText = 'Something went wrong. Please try again.';
        isLoading = false;
      });
    }
  }

  void _filterRequests() {
    final query = _searchController.text.toLowerCase();
    setState(() {
      filteredRequests = requestApprovalList.where((request) {
        return request.requestNumber.toLowerCase().contains(query) ||
            request.requestStatus.toLowerCase().contains(query);
      }).toList();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          AppStrings.requestApproval,
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
                fetchRequestApprovalList();
                filteredRequests = requestApprovalList;
              });
            },
            icon: const Icon(Icons.refresh, color: Colors.white),
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CustomProgressIndicator())
          : isError
              ? Center(child: Text(errorText))
              : Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      child: CustomSearchField(
                        controller: _searchController,
                        placeholderText: 'Search by request number or status',
                        inputType: TextInputType.text,
                      ),
                    ),
                    Expanded(
                      child: ScrollbarTheme(
                        data: ScrollbarThemeData(
                          thumbColor:
                              WidgetStateProperty.all(ColorManager.darkBlue),
                          trackColor: WidgetStateProperty.all(
                              ColorManager.primary.withOpacity(0.2)),
                          thickness: WidgetStateProperty.all(6),
                          radius: const Radius.circular(8),
                        ),
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: ListView.builder(
                            itemCount: filteredRequests.length,
                            itemBuilder: (context, index) {
                              final request = filteredRequests[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 2, vertical: 0),
                                child: CommonCardWidget(
                                  subtitles: [
                                    {'Request No': request.requestNumber},
                                    {'Request Status': request.requestStatus},
                                    {'Entry Date': request.entryDate},
                                    {
                                      'Request Net Total': request.requestValue
                                          .toStringAsFixed(2)
                                    },
                                  ],
                                  onTap: () {
                                    navigateToScreen(
                                      context,
                                      RequestDetailsView(
                                          requestId: request.requestId,
                                          requestNumber: request.requestNumber),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }
}
