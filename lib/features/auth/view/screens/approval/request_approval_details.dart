import 'dart:developer';
import 'package:eyvo_v3/api/api_service/api_service.dart';
import 'package:eyvo_v3/api/response_models/request_approval_details_response.dart';
import 'package:eyvo_v3/app/app_prefs.dart';
import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/routes_manager.dart';
import 'package:eyvo_v3/core/resources/strings_manager.dart';
import 'package:eyvo_v3/core/utils.dart';
import 'package:eyvo_v3/core/widgets/alert.dart';
import 'package:eyvo_v3/core/widgets/approval_details_helper.dart';
import 'package:eyvo_v3/core/widgets/button.dart';
import 'package:eyvo_v3/core/widgets/common_app_bar.dart';
import 'package:eyvo_v3/core/widgets/progress_indicator.dart';
import 'package:flutter/material.dart';

class RequestDetailsView extends StatefulWidget {
  final int requestId;
  final String requestNumber;

  const RequestDetailsView(
      {Key? key, required this.requestId, required this.requestNumber})
      : super(key: key);

  @override
  State<RequestDetailsView> createState() => _RequestDetailsViewState();
}

class _RequestDetailsViewState extends State<RequestDetailsView> {
  final ApiService apiService = ApiService();
  bool isLoading = false;
  bool isError = false;
  String errorText = AppStrings.somethingWentWrong;

  Data? requestDetails;
  String? expandedSection;

  @override
  void initState() {
    super.initState();
    expandedSection = "Details"; // default expanded section
    fetchRequestApprovalDetails();
  }

  Future<void> fetchRequestApprovalDetails() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    final jsonResponse = await apiService.postRequest(
      context,
      ApiService.requestApprovalDetails,
      {'uid': SharedPrefs().uID, 'requestId': widget.requestId},
    );

    if (jsonResponse != null) {
      final resp = RequestApprovalDetailsResponse.fromJson(jsonResponse);
      if (resp.code == 200 && resp.data != null) {
        setState(() {
          requestDetails = resp.data;
          isLoading = false;
        });
        return;
      } else {
        errorText = resp.message?.join(', ') ?? "Failed to fetch data";
      }
    } else {
      errorText = "No response from server";
    }

    setState(() {
      isError = true;
      isLoading = false;
    });
  }

  Future<void> requestApprovalApprove() async {
    setState(() => isLoading = true);

    final jsonResponse = await apiService.postRequest(
      context,
      ApiService.requestApprovalApproved,
      {'uid': SharedPrefs().uID, 'requestId': widget.requestId},
    );

    if (jsonResponse != null) {
      if (jsonResponse['code'] == 200) {
        Navigator.pushReplacementNamed(
          context,
          Routes.thankYouRoute,
          arguments: {
            'message': "Request approved successfully",
            'status': "Request Approved",
            'number': requestDetails?.header.requestNumber ?? "",
          },
        );
      } else {
        showErrorDialog(context, jsonResponse['message'].toString(), false);
      }
    } else {
      showErrorDialog(context, "No response from server", false);
    }

    setState(() => isLoading = false);
  }

  Future<void> requestApprovalReject(String reason) async {
    setState(() => isLoading = true);

    final jsonResponse = await apiService.postRequest(
      context,
      ApiService.requestApprovalReject,
      {
        'uid': SharedPrefs().uID,
        'requestId': widget.requestId,
        'reason': reason
      },
    );

    if (jsonResponse != null) {
      if (jsonResponse['code'] == 200) {
        Navigator.pushReplacementNamed(
          context,
          Routes.thankYouRoute,
          arguments: {
            'message': "Request rejected successfully",
            'status': "Request Rejected",
            'number': requestDetails?.header.requestNumber ?? "",
          },
        );
      } else {
        showErrorDialog(context, jsonResponse['message'].toString(), false);
      }
    } else {
      showErrorDialog(context, "No response from server", false);
    }

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCommonAppBar(
        context: context,
        title: "Request #${widget.requestNumber}",
      ),
      body: isLoading
          ? const Center(child: CustomProgressIndicator())
          : isError
              ? Center(child: Text(errorText))
              : Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          children: [
// --------------------------------------------------------------- DETAILS ---------------------------------------------------------------
                            ApprovalDetailsHelper.buildSectionForDetails(
                              "Details",
                              Icons.description_outlined,
                              {
                                'Request No':
                                    requestDetails!.header.requestNumber,
                                'Entry Date': requestDetails!.header.entryDate,
                                'Request Status':
                                    requestDetails!.header.requestStatus,
                                'Request Net Total':
                                    '${requestDetails!.header.grossTotal} (${requestDetails!.header.headerCcyCode})',
                                'Approver Name':
                                    requestDetails!.header.originatorName,
                              },
                              onTap: () {
                                Navigator.pushNamed(
                                  context,
                                  Routes.genericDetailRoute,
                                  arguments: {
                                    'title': 'Request Header',
                                    'data': {
                                      'Request No': requestDetails!
                                              .header.requestNumber ??
                                          '',
                                      'Entry Date':
                                          requestDetails!.header.entryDate ??
                                              '',
                                      'Request Status': requestDetails!
                                              .header.requestStatus ??
                                          '',
                                      'Ref Num':
                                          requestDetails!.header.referenceNo ??
                                              '',
                                      'Instructions':
                                          requestDetails!.header.instructions ??
                                              '',
                                      'Delivery To':
                                          requestDetails!.header.fao ?? '',
                                      'Document Type':
                                          requestDetails!.header.orderTypeId ??
                                              '',
                                      'Delivery Code':
                                          requestDetails!.header.deliveryCode ??
                                              '',
                                      requestDetails!.header.expName1:
                                          requestDetails!.header.expCode1 ?? '',
                                      'Incoterms':
                                          requestDetails!.header.fob ?? '',
                                    },
                                  },
                                );
                              },
                              isExpanded: expandedSection == "Details",
                              toggleSection: () => setState(() {
                                expandedSection = expandedSection == "Details"
                                    ? null
                                    : "Details";
                              }),
                            ),

// ---------------------------------------------------------------------------- LINE ITEMS ------------------------------------------------------------------------------------

                            ApprovalDetailsHelper.buildSection(
                              "Line Items",
                              Icons.list_alt_outlined,
                              (requestDetails?.line?.isEmpty ?? true)
                                  ? [
                                      ApprovalDetailsHelper.buildEmptyView(
                                          "No line items")
                                    ]
                                  : [
                                      ...requestDetails!.line!.map((lineItem) {
                                        return ApprovalDetailsHelper
                                            .buildMiniCardWithEditIcon({
                                          'Item': lineItem.itemCode,
                                          'Description': lineItem.description,
                                          'Quantity': lineItem.quantity,
                                          'Unit Price':
                                              '${getFormattedPriceString(lineItem.price)} (${lineItem.supplierCcyCode})',
                                          'Net Price':
                                              '${getFormattedPriceString(lineItem.netPrice)} (${lineItem.supplierCcyCode})',
                                        }, () {
                                          Navigator.pushNamed(
                                            context,
                                            Routes.genericDetailRoute,
                                            arguments: {
                                              'title': 'Request Line',
                                              'data': {
                                                //  'Item Order': lineItem.itemOrder,
                                                'Item Code': lineItem.itemCode,
                                                'Item Description': lineItem
                                                            .description
                                                            .length >
                                                        100
                                                    ? '${lineItem.description.substring(0, 100)}...'
                                                    : lineItem.description,
                                                'Item Due Date':
                                                    lineItem.dueDate,
                                                'Quantity': lineItem.quantity,
                                                'Unit': lineItem.unit,
                                                'Pack Size': lineItem.packSize,
                                                'Unit Price':
                                                    '${getFormattedPriceString(lineItem.price)} (${lineItem.supplierCcyCode})',
                                                'Discount': lineItem
                                                            .discountType ==
                                                        1
                                                    ? '${lineItem.discount}(value)'
                                                    : '${lineItem.discount}(%)',
                                                'Tax':
                                                    '${lineItem.tax.toStringAsFixed(3)}%',
                                                'Tax Value': lineItem.taxValue
                                                    .toStringAsFixed(3),
                                              },
                                            },
                                          );
                                        });
                                      }).toList(),
                                      ApprovalDetailsHelper
                                          .buildNetGrossTotalWidget(
                                              context, requestDetails!.line,
                                              dialogTitle:
                                                  'Request Total Summary',
                                              netTotalLabel: 'Total Net Amount',
                                              salesTaxLabel: 'Total Tax',
                                              grossTotalLabel:
                                                  'Request Gross Amount',
                                              currencyLabel:
                                                  'Request Currency'),
                                    ],
                              count: requestDetails?.line?.length ?? 0,
                              isExpanded: expandedSection == "Line Items",
                              toggleSection: () => setState(() {
                                expandedSection =
                                    expandedSection == "Line Items"
                                        ? null
                                        : "Line Items";
                              }),
                            ),

// ---------------------------------------------------------------------- RULES -------------------------------------------------------------------
                            ApprovalDetailsHelper.buildSection(
                              "Rules",
                              Icons.rule,
                              (requestDetails?.rule?.isEmpty ?? true)
                                  ? [
                                      ApprovalDetailsHelper.buildEmptyView(
                                          "No rules")
                                    ]
                                  : requestDetails!.rule!.map((r) {
                                      return ApprovalDetailsHelper
                                          .buildMiniCard({
                                        'Rule Name': r.ruleName,
                                        'Rule Description': r.ruleDescription,
                                        'Rule Selected':
                                            r.ruleSelected ? 'Yes' : 'No',
                                      });
                                    }).toList(),
                              count: requestDetails?.rule?.length ?? 0,
                              isExpanded: expandedSection == "Rules",
                              toggleSection: () => setState(() {
                                expandedSection =
                                    expandedSection == "Rules" ? null : "Rules";
                              }),
                            ),

// ---------------------------------------------- RULE APPROVERS ----------------------------------------------------------
                            ApprovalDetailsHelper.buildSection(
                              "Rule Approvers",
                              Icons.person_outline,
                              (requestDetails?.ruleApprovers?.isEmpty ?? true)
                                  ? [
                                      ApprovalDetailsHelper.buildEmptyView(
                                          "No rule approvers")
                                    ]
                                  : requestDetails!.ruleApprovers!.map((ra) {
                                      return ApprovalDetailsHelper
                                          .buildMiniCardForApproval(
                                        {
                                          'Approval Order': ra.approvalOrder,
                                          'User Name': ra.userName,
                                          'Group': ra.userGroupName,
                                          'Status': ra.approvalStatus,
                                          'Proxy User': ra.proxyUserName,
                                          'UID Group': ra.uidGroup.toString(),
                                        },
                                        () {
                                          Navigator.pushNamed(
                                            context,
                                            Routes.showGroupApprovalListRoute,
                                            arguments: {
                                              'id': ra.uidGroup,
                                              'from': 'rulegroup',
                                            },
                                          );
                                        },
                                        showIconCondition: (data) =>
                                            data['UID Group']?.toString() !=
                                            "0",
                                      );
                                    }).toList(),
                              count: requestDetails?.ruleApprovers?.length ?? 0,
                              isExpanded: expandedSection == "Rule Approvers",
                              toggleSection: () => setState(() {
                                expandedSection =
                                    expandedSection == "Rule Approvers"
                                        ? null
                                        : "Rule Approvers";
                              }),
                            ),

//-------------------------------------------------------------------- COST CENTERS ------------------------------------------------------------------------------------------------------------------------
//----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
                            ApprovalDetailsHelper.buildSection(
                              "Cost Center Split",
                              Icons.account_balance_wallet_outlined,
                              (requestDetails?.costCenter?.isEmpty ?? true)
                                  ? [
                                      ApprovalDetailsHelper.buildEmptyView(
                                          "No cost center data"),
                                    ]
                                  : requestDetails!.costCenter!.map((cc) {
                                      return ApprovalDetailsHelper
                                          .buildMiniCard({
                                        'Cost Center Code': cc.costCode,
                                        'Description': cc.costDescription,
                                        'Split Percentage':
                                            '${cc.splitPercentage}%',
                                        'Split Value': getFormattedPriceString(
                                            cc.splitValue),
                                      });
                                    }).toList(),
                              count: requestDetails?.costCenter?.length ?? 0,
                              isExpanded: expandedSection == "Cost Centers",
                              toggleSection: () => setState(() {
                                expandedSection =
                                    expandedSection == "Cost Centers"
                                        ? null
                                        : "Cost Centers";
                              }),
                            ),

// -------------------- ATTACHMENTS --------------------
                            ApprovalDetailsHelper.buildSection(
                              "Attachments",
                              Icons.attach_file,
                              (requestDetails?.attachedDocument?.isEmpty ??
                                      true)
                                  ? [
                                      ApprovalDetailsHelper.buildEmptyView(
                                          "No attachments")
                                    ]
                                  : requestDetails!.attachedDocument!
                                      .map((doc) {
                                      return ApprovalDetailsHelper
                                          .buildMiniCard(doc);
                                    }).toList(),
                              count:
                                  requestDetails?.attachedDocument?.length ?? 0,
                              isExpanded: expandedSection == "Attachments",
                              toggleSection: () => setState(() {
                                expandedSection =
                                    expandedSection == "Attachments"
                                        ? null
                                        : "Attachments";
                              }),
                            ),
// -------------------- EVENT LOG --------------------
                            ApprovalDetailsHelper.buildSection(
                              "Event Log",
                              Icons.event_note,
                              (requestDetails?.log?.isEmpty ?? true)
                                  ? [
                                      ApprovalDetailsHelper.buildEmptyView(
                                          "No logs")
                                    ]
                                  : requestDetails!.log!.map((log) {
                                      return ApprovalDetailsHelper
                                          .buildMiniCard({
                                        'Event Date': log.eventDate,
                                        'User': log.eventUser,
                                        'Event': log.event,
                                      });
                                    }).toList(),
                              count: requestDetails?.log?.length ?? 0,
                              isExpanded: expandedSection == "Event Log",
                              toggleSection: () => setState(() {
                                expandedSection = expandedSection == "Event Log"
                                    ? null
                                    : "Event Log";
                              }),
                            ),
                          ],
                        ),
                      ),
                    ),

                    // -------------------- APPROVE / REJECT BUTTONS --------------------
                    Container(
                      color: ColorManager.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Expanded(
                            child: CustomTextActionButton(
                              buttonText: "Approve",
                              icon: Icons.thumb_up_outlined,
                              backgroundColor: ColorManager.green,
                              borderColor: ColorManager.white,
                              fontColor: ColorManager.white,
                              fontSize: FontSize.s18,
                              isBoldFont: true,
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CustomImageActionAlert(
                                      iconString: '',
                                      imageString: ImageAssets.common,
                                      titleString: "Confirm Approval",
                                      subTitleString:
                                          "Are you sure you want to approve this order?",
                                      destructiveActionString: "Yes",
                                      normalActionString: "No",
                                      onDestructiveActionTap: () {
                                        Navigator.of(context).pop();
                                        requestApprovalApprove();
                                      },
                                      onNormalActionTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      isConfirmationAlert: true,
                                      isNormalAlert: true,
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: CustomTextActionButton(
                              buttonText: "Reject",
                              icon: Icons.thumb_down_outlined,
                              backgroundColor: ColorManager.red,
                              borderColor: ColorManager.white,
                              fontColor: ColorManager.white,
                              fontSize: FontSize.s18,
                              isBoldFont: true,
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return CustomRejectReasonAlert(
                                      iconString: '',
                                      imageString: ImageAssets.rejection,
                                      titleString: "Please Add Reject Reason",
                                      rejectActionString: "Reject",
                                      cancelActionString: "Cancel",
                                      onCancelTap: () {
                                        Navigator.of(context).pop();
                                      },
                                      onRejectTap: (reason) {
                                        Navigator.of(context).pop();
                                        requestApprovalReject(reason);
                                      },
                                    );
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
