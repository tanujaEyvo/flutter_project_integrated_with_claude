import 'dart:developer';

import 'package:eyvo_v3/core/widgets/common_app_bar.dart';
import 'package:eyvo_v3/core/widgets/custom_card_item.dart';
import 'package:eyvo_v3/core/widgets/progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:eyvo_v3/api/api_service/api_service.dart';
import 'package:eyvo_v3/api/response_models/group_approval_list_response.dart';
import 'package:eyvo_v3/app/app_prefs.dart';
import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/strings_manager.dart';
import 'package:eyvo_v3/core/resources/styles_manager.dart';

class ShowGroupApprovalList extends StatefulWidget {
  final int id;
  final String from;

  const ShowGroupApprovalList({
    super.key,
    required this.id,
    required this.from,
  });

  @override
  State<ShowGroupApprovalList> createState() => _ShowGroupApprovalListState();
}

class _ShowGroupApprovalListState extends State<ShowGroupApprovalList> {
  final ApiService apiService = ApiService();

  List<GroupApproval> groupApprovalList = [];
  bool isLoading = false;
  bool isError = false;
  String errorText = '';

  @override
  void initState() {
    super.initState();
    fetchGroupApproverList();
  }

  void fetchGroupApproverList() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    final requestData = {
      'id': widget.id,
      'from': widget.from,
    };
    log('Sending request to API: $requestData');
    final jsonResponse = await apiService.postRequest(
      context,
      ApiService.groupApproverList,
      requestData,
    );

    if (jsonResponse != null) {
      final response = GroupApprovalListResponse.fromJson(jsonResponse);

      if (response.code == 200) {
        setState(() {
          groupApprovalList = response.data;
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

  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primary,
      appBar: buildCommonAppBar(
        context: context,
        title: "Group Approver List",
      ),
      body: isLoading
          ? const Center(child: CustomProgressIndicator())
          : isError
              ? Center(child: Text(errorText))
              : groupApprovalList.isEmpty
                  ? const Center(child: Text('No group approvers found.'))
                  : ListView.builder(
                      itemCount: groupApprovalList.length,
                      itemBuilder: (context, index) {
                        final item = groupApprovalList[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 2, vertical: 4),
                          child: CommonCardWidget(
                            subtitles: [
                              {'Name': item.userName},
                              {'Email': item.email},
                              {'Telephone': item.telephone},
                              {'Extension': item.extension},
                              {'Proxy For': item.proxyFor},
                            ],
                          ),
                        );
                      },
                    ),
    );
  }
}
