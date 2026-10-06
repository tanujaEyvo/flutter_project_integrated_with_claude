import 'dart:developer';

import 'package:eyvo_v3/api/response_models/order_approval_approved_response.dart';
import 'package:eyvo_v3/api/response_models/order_approval_reject_response.dart';
import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:eyvo_v3/core/resources/routes_manager.dart';
import 'package:eyvo_v3/core/resources/styles_manager.dart';
import 'package:eyvo_v3/core/utils.dart';
import 'package:eyvo_v3/core/widgets/alert.dart';
import 'package:eyvo_v3/core/widgets/approval_details_helper.dart';
import 'package:eyvo_v3/core/widgets/approver_detailed_page.dart';
import 'package:eyvo_v3/core/widgets/progress_indicator.dart';
import 'package:eyvo_v3/core/widgets/thankYouPage.dart';
import 'package:eyvo_v3/features/auth/view/screens/approval/show_group_approver_list.dart';
import 'package:eyvo_v3/log_data.dart/logger_data.dart';
import 'package:flutter/material.dart';
import 'package:eyvo_v3/api/api_service/api_service.dart';
import 'package:eyvo_v3/api/response_models/order_approval_details_response.dart';
import 'package:eyvo_v3/app/app_prefs.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/strings_manager.dart';
import 'package:eyvo_v3/core/widgets/button.dart';
import 'package:eyvo_v3/core/widgets/common_app_bar.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class OrderDetailsView extends StatefulWidget {
  final int orderId;
  final String orderNumber;

  const OrderDetailsView(
      {Key? key, required this.orderId, required this.orderNumber})
      : super(key: key);

  @override
  State<OrderDetailsView> createState() => _OrderDetailsViewState();
}

class _OrderDetailsViewState extends State<OrderDetailsView> {
  final ApiService apiService = ApiService();
  bool isLoading = false, isError = false;
  String errorText = AppStrings.somethingWentWrong;
  Data? orderDetails;
  String? expandedSection;

  @override
  void initState() {
    super.initState();
    expandedSection = "Details"; // Default expanded
    fetchOrderApprovalDetails();
  }

  Future<void> fetchOrderApprovalDetails() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    final jsonResponse = await apiService.postRequest(
      context,
      ApiService.orderApprovalDetails,
      {'uid': SharedPrefs().uID, 'orderId': widget.orderId},
    );

    if (jsonResponse != null) {
      final resp = OrderApprovalDetails.fromJson(jsonResponse);
      if (resp.code == 200) {
        setState(() {
          orderDetails = resp.data;
          isLoading = false;
        });
        return;
      } else {
        errorText = resp.message.join(', ');
      }
    }
    setState(() {
      isError = true;
      isLoading = false;
    });
  }

  Future<void> orderApprovalApproved() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    final jsonResponse = await apiService.postRequest(
      context,
      ApiService.orderApprovalApproved,
      {
        'uid': SharedPrefs().uID,
        'orderId': widget.orderId,
      },
    );

    if (!mounted) return;

    if (jsonResponse != null) {
      final resp = OrderApprovalApprovedResponse.fromJson(jsonResponse);
      if (resp.code == 200) {
        final message = resp.message ?? "Approved successfully";

        Navigator.pushReplacementNamed(
          context,
          Routes.thankYouRoute,
          arguments: {
            'message': message,
            'approverName': 'orderApproval',
            'status': 'Order Approved',
            'requestName': 'Order Number',
            'number': orderDetails!.header.orderNumber
          },
        );
      } else {
        errorText = resp.message ?? "Something went wrong";
        showErrorDialog(context, errorText, false);
      }
    } else {
      errorText = "No response from server";
      showErrorDialog(context, errorText, false);
    }

    setState(() {
      isLoading = false;
      isError = true;
    });
  }

  Future<void> orderApprovalReject(String reason) async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    final jsonResponse = await apiService.postRequest(
      context,
      ApiService.orderApprovalReject,
      {
        'uid': SharedPrefs().uID,
        'orderId': widget.orderId,
        'reason': reason,
      },
    );

    if (!mounted) return;

    if (jsonResponse != null) {
      final resp = OrderApprovalRejectResponse.fromJson(jsonResponse);
      if (resp.code == 200) {
        final message = resp.message.isNotEmpty
            ? resp.message.first
            : "Rejected successfully";

        Navigator.pushReplacementNamed(
          context,
          Routes.thankYouRoute,
          arguments: {
            'message': message,
            'approverName': 'orderApproval',
            'status': 'Order Rejected',
            'requestName': 'Order Number',
            'number': orderDetails!.header.orderNumber,
          },
        );
      } else {
        errorText = resp.message.isNotEmpty
            ? resp.message.first
            : "Something went wrong";
        showErrorDialog(context, errorText, false);
      }
    } else {
      errorText = "No response from server";
      showErrorDialog(context, errorText, false);
    }

    setState(() {
      isLoading = false;
      isError = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCommonAppBar(
        context: context,
        title: "Order #${widget.orderNumber.toString()}",
      ),
      backgroundColor: ColorManager.primary,
      body: isLoading
          ? const Center(child: CustomProgressIndicator())
          : isError
              ? Center(child: Text(errorText))
              : Column(
                  children: [
                    Expanded(
                      child: ScrollbarTheme(
                        data: ScrollbarThemeData(
                          thumbColor:
                              MaterialStateProperty.all(ColorManager.blue),
                          radius: const Radius.circular(8),
                          thickness: MaterialStateProperty.all(6),
                        ),
                        child: Scrollbar(
                          thumbVisibility: true,
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              children: [
//------------------------------------ order header--------------------------
                                ApprovalDetailsHelper.buildSectionForDetails(
                                  "Details",
                                  Icons.description_outlined,
                                  {
                                    'Order Number':
                                        orderDetails!.header.orderNumber,
                                    'Order Date':
                                        orderDetails!.header.orderDate,
                                    'Order Status':
                                        orderDetails!.header.orderStatus,
                                    'Supplier Name':
                                        orderDetails!.header.supplierName,
                                    'Order ${capitalizeFirstLetter(orderDetails!.header.orderValueLabel)} Total':
                                        '${getFormattedPriceString(orderDetails!.header.orderValue)} (${orderDetails!.header.currencyCode})',
                                    'Rule Approval':
                                        orderDetails!.header.ruleStatus,
                                    'Cost Center Approver':
                                        orderDetails!.header.ccApproverStatus,
                                    'Group Approver': orderDetails!
                                        .header.groupApproverStatus,
                                  },
                                  onTap: () {
                                    Navigator.pushNamed(
                                      context,
                                      Routes.genericDetailRoute,
                                      arguments: {
                                        'title': 'Order Header',
                                        'data': {
                                          'Order Number':
                                              orderDetails!.header.orderNumber,
                                          'Order Date':
                                              orderDetails!.header.orderDate,
                                          'Order Status':
                                              orderDetails!.header.orderStatus,
                                          'Order Net Total':
                                              '${getFormattedPriceString(orderDetails!.header.orderValue)} (${orderDetails!.header.currencyCode})',
                                          'Reference No':
                                              orderDetails!.header.referenceNo,
                                          'Supplier Name':
                                              orderDetails!.header.supplierName,
                                          'Delivery To':
                                              orderDetails!.header.fao,
                                          'Delivery Code':
                                              orderDetails!.header.deliveryCode,
                                          'Invoice Code': orderDetails!
                                              .header.invoicePtCode,
                                          'Category Code':
                                              orderDetails!.header.categoryCode,
                                          orderDetails!.header.expName1:
                                              orderDetails!.header.expCode1,
                                          orderDetails!.header.expName2:
                                              orderDetails!.header.expCode2,
                                          orderDetails!.header.expName3:
                                              orderDetails!.header.expCode3,
                                          'Incoterms': orderDetails!.header.fob,
                                          'Budget': orderDetails!
                                              .header.orderBudgetHeader,
                                          // 'Approval Type': orderDetails!
                                          //         .header.approvalType ??
                                          //     '',
                                          'Rule Approver Status':
                                              orderDetails!.header.ruleStatus,
                                          'CC Approver Status': orderDetails!
                                              .header.ccApproverStatus,
                                          'Group Approver Status': orderDetails!
                                              .header.groupApproverStatus,
                                        },
                                      },
                                    );
                                  },
                                  isExpanded: expandedSection == "Details",
                                  toggleSection: () {
                                    setState(() {
                                      expandedSection =
                                          expandedSection == "Details"
                                              ? null
                                              : "Details";
                                    });
                                  },
                                ),
//------------------------------------------ Line Item ----------------------------------
                                ApprovalDetailsHelper.buildSection(
                                  "Line Items",
                                  Icons.list_alt_outlined,
                                  orderDetails!.line.isEmpty
                                      ? [
                                          ApprovalDetailsHelper.buildEmptyView(
                                              "No line items found"),
                                        ]
                                      : [
                                          ...orderDetails!.line.map((lineItem) {
                                            return ApprovalDetailsHelper
                                                .buildMiniCardWithEditIcon({
                                              'Item No': lineItem.itemOrder,
                                              'Description': lineItem
                                                          .description.length >
                                                      50
                                                  ? '${lineItem.description.substring(0, 50)}...'
                                                  : lineItem.description,
                                              'Quantity':
                                                  '${getFormattedPriceString(lineItem.quantity)}',
                                              'Unit Price':
                                                  '${getFormattedPriceString(lineItem.price)} (${lineItem.supplierCcyCode})',
                                              'Net Price':
                                                  '${getFormattedPriceString(lineItem.netPrice)} (${lineItem.supplierCcyCode})',
                                            }, () {
                                              Navigator.pushNamed(
                                                context,
                                                Routes.genericDetailRoute,
                                                arguments: {
                                                  'title': 'Order Line',
                                                  'data': {
                                                    'Item No.':
                                                        lineItem.itemOrder,
                                                    'Item Code':
                                                        lineItem.itemCode,
                                                    'Description':
                                                        lineItem.description,
                                                    'Suppliers Part No':
                                                        lineItem
                                                            .suppliersPartNo,
                                                    'Due Date':
                                                        lineItem.dueDate,
                                                    'Quantity':
                                                        '${getFormattedPriceString(lineItem.quantity)}',
                                                    'Unit': lineItem.unit,
                                                    'Pack Size': lineItem
                                                        .packSize
                                                        .toInt()
                                                        .toString(),
                                                    'Unit Price':
                                                        '${getFormattedPriceString(lineItem.price)} (${lineItem.supplierCcyCode})',
                                                    'Discount': lineItem
                                                                .discountType ==
                                                            1
                                                        ? '${lineItem.discount}(value)'
                                                        : '${lineItem.discount}(%)',
                                                    'Tax':
                                                        '${lineItem.tax.toStringAsFixed(3)}%',
                                                    'Tax Value': lineItem
                                                        .taxValue
                                                        .toStringAsFixed(3),
                                                    'Net Price':
                                                        '${getFormattedPriceString(lineItem.netPrice)} (${lineItem.supplierCcyCode})',
                                                    'Gross Price':
                                                        '${getFormattedPriceString(lineItem.grossPrice)} (${lineItem.supplierCcyCode})',
                                                    lineItem.expName4:
                                                        lineItem.expCode4,
                                                    lineItem.expName5:
                                                        lineItem.expCode5,
                                                    lineItem.expName6:
                                                        lineItem.expCode6,
                                                  },
                                                },
                                              );
                                            });
                                          }).toList(),

                                          // Add the total net price at the bottom
                                          ApprovalDetailsHelper
                                              .buildNetGrossTotalWidget(
                                                  context, orderDetails!.line,
                                                  dialogTitle:
                                                      'Order Total Summary',
                                                  netTotalLabel:
                                                      'Order Net Total',
                                                  shippingChargesLabel:
                                                      'Shipping Charges',
                                                  salesTaxLabel: 'Sales Tax',
                                                  grossTotalLabel:
                                                      'Order Gross Total',
                                                  currencyLabel:
                                                      'Order Currency'),
                                        ],
                                  count: orderDetails!.line.length,
                                  isExpanded: expandedSection == "Line Items",
                                  toggleSection: () {
                                    setState(() {
                                      expandedSection =
                                          expandedSection == "Line Items"
                                              ? null
                                              : "Line Items";
                                    });
                                  },
                                ),

//--------------------------- Rule------------------------------------------------
                                ApprovalDetailsHelper.buildSection(
                                  "Rules",
                                  Icons.rule,
                                  orderDetails!.rule.isEmpty
                                      ? [
                                          ApprovalDetailsHelper.buildEmptyView(
                                              "No Rule found"),
                                        ]
                                      : orderDetails!.rule.map((r) {
                                          return ApprovalDetailsHelper
                                              .buildMiniCard({
                                            'Rule Name': r.ruleName,
                                            'Rule Description':
                                                r.ruleDescription,
                                            'Rule Selected': r.ruleSelected
                                                ? 'true'
                                                : 'false',
                                          });
                                        }).toList(),
                                  count: orderDetails!.rule.length,
                                  isExpanded: expandedSection == "Rules",
                                  toggleSection: () {
                                    setState(() {
                                      expandedSection =
                                          expandedSection == "Rules"
                                              ? null
                                              : "Rules";
                                    });
                                  },
                                ),
//--------------------------------- Rule Approvers---------------------------------------
                                ApprovalDetailsHelper.buildSection(
                                  "Rule Approvers",
                                  FontAwesomeIcons.userCheck,
                                  orderDetails!.ruleApprovers.isEmpty
                                      ? [
                                          ApprovalDetailsHelper.buildEmptyView(
                                              "No rule approvers found"),
                                        ]
                                      : orderDetails!.ruleApprovers.map((ra) {
                                          return ApprovalDetailsHelper
                                              .buildMiniCardForApproval(
                                            {
                                              'Approval Order':
                                                  ra.approvalOrder.toString(),
                                              'Approval Status':
                                                  ra.approvalStatus,
                                              'User Name': ra.userName,
                                              'Group Name': ra.userGroupName,
                                              'Proxy User': ra.proxyUserName,
                                              'UID Group':
                                                  ra.uidGroup.toString(),
                                              'Email': ra.email,
                                            },
                                            () {
                                              Navigator.pushNamed(
                                                context,
                                                Routes
                                                    .showGroupApprovalListRoute,
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
                                  count: orderDetails!.ruleApprovers.length,
                                  iconSize: 20,
                                  isExpanded:
                                      expandedSection == "Rule Approvers",
                                  toggleSection: () {
                                    setState(() {
                                      expandedSection =
                                          expandedSection == "Rule Approvers"
                                              ? null
                                              : "Rule Approvers";
                                    });
                                  },
                                ),
//------------------------ Cost Center Split -----------------------------------------
                                ApprovalDetailsHelper.buildSection(
                                  "Cost Center Split",
                                  Icons.share,
                                  orderDetails!.costcenter.isEmpty
                                      ? [
                                          ApprovalDetailsHelper.buildEmptyView(
                                              "No cost center data"),
                                        ]
                                      : orderDetails!.costcenter.map((c) {
                                          return ApprovalDetailsHelper
                                              .buildMiniCard({
                                            'Code': c.costCode,
                                            'Description': c.costDescription,
                                            'Split Percent':
                                                "${getFormattedString(c.splitPercentage)}%",
                                            'Split Value':
                                                '${getFormattedPriceString(c.splitValue)}',
                                          });
                                        }).toList(),
                                  count: orderDetails!.costcenter.length,
                                  isExpanded: expandedSection == "Cost Center",
                                  toggleSection: () {
                                    setState(() {
                                      expandedSection =
                                          expandedSection == "Cost Center"
                                              ? null
                                              : "Cost Center";
                                    });
                                  },
                                ),
                                //-----------------------------------------------------Cost Center Approvers----------------------------------------------------------------
                                ApprovalDetailsHelper.buildSection(
                                  "Cost Center Approvers",
                                  FontAwesomeIcons.userCheck,
                                  orderDetails!.approver.isEmpty
                                      ? [
                                          ApprovalDetailsHelper.buildEmptyView(
                                              "No approvers found"),
                                        ]
                                      : orderDetails!.approver.map((a) {
                                          return ApprovalDetailsHelper
                                              .buildMiniCard(
                                            {
                                              'Rank': a.rank,
                                              'Approval': a.approval,
                                              'Name': a.userName,
                                              'Telephone': a.telephone,
                                              'Extensions': a.extension,
                                              'Email': a.email,
                                              'Proxy For': a.uidProxy,
                                            },
                                            // onTap: () {
                                            //   Navigator.push(
                                            //     context,
                                            //     MaterialPageRoute(
                                            //       builder: (_) =>
                                            //           GenericDetailPage(
                                            //         title: a.userName,
                                            //         data: {
                                            //           'Rec Num':
                                            //               a.recNum.toString(),
                                            //           'Rank': a.rank.toString(),
                                            //           'Approval': a.approval,
                                            //           'User Name': a.userName,
                                            //           'Telephone': a.telephone,
                                            //           'Extension': a.extension,
                                            //           'Email': a.email,
                                            //           'Approval Date':
                                            //               a.approvalDate,
                                            //           'UID Proxy': a.uidProxy,
                                            //         },
                                            //       ),
                                            //     ),
                                            //   );
                                            // },
                                          );
                                        }).toList(),
                                  count: orderDetails!.approver.length,
                                  iconSize: 20,
                                  isExpanded: expandedSection ==
                                      "Cost center Approvers",
                                  toggleSection: () {
                                    setState(() {
                                      expandedSection = expandedSection ==
                                              "Cost center Approvers"
                                          ? null
                                          : "Cost center Approvers";
                                    });
                                  },
                                ),
//-----------------------------------------------Group Approvers----------------------------------------------
                                ApprovalDetailsHelper.buildSection(
                                  "Group Approvers",
                                  Icons.groups,
                                  orderDetails!.grpapprover.isEmpty
                                      ? [
                                          ApprovalDetailsHelper.buildEmptyView(
                                              "No Group Approvers found"),
                                        ]
                                      : orderDetails!.grpapprover.map((g) {
                                          return ApprovalDetailsHelper
                                              .buildMiniCardForApproval(
                                            {
                                              'UserGroup': g.groupCode,
                                              'Approval': g.approval,
                                              'Mandatory': g.mandatory,
                                            },
                                            () {
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (_) =>
                                                      ShowGroupApprovalList(
                                                    id: g.userGroupId,
                                                    from: 'group',
                                                  ),
                                                ),
                                              );
                                            },
                                          );
                                        }).toList(),
                                  count: orderDetails!.grpapprover.length,
                                  isExpanded:
                                      expandedSection == "Group Approvers",
                                  toggleSection: () {
                                    setState(() {
                                      expandedSection =
                                          expandedSection == "Group Approvers"
                                              ? null
                                              : "Group Approvers";
                                    });
                                  },
                                ),
//----------------------------------Attachments------------------------------------------------------
                                ApprovalDetailsHelper.buildSection(
                                  "Attachments",
                                  Icons.attach_file,
                                  orderDetails!.attachdoc.isEmpty
                                      ? [
                                          ApprovalDetailsHelper.buildEmptyView(
                                              "No attachments found"),
                                        ]
                                      : orderDetails!.attachdoc.map((d) {
                                          return ApprovalDetailsHelper
                                              .buildMiniCard({
                                            'File Name': d.documentFileName,
                                            'File Privacy': d.docPrivacyText,
                                            'Deascription':
                                                d.documentDescription,
                                            'Entry Date': d.docStamp,
                                            'Entered By': d.enteredBy,
                                          }, onTap: () {
                                            //   print("Tapped File: ${d.fileName}");
                                          });
                                        }).toList(),
                                  count: orderDetails!.attachdoc.length,
                                  isExpanded: expandedSection == "Attachments",
                                  toggleSection: () {
                                    setState(() {
                                      expandedSection =
                                          expandedSection == "Attachments"
                                              ? null
                                              : "Attachments";
                                    });
                                  },
                                ),
//---------------------------------------------Event Log-------------------------------------------------------------------------------
                                ApprovalDetailsHelper.buildSection(
                                  "Event Log",
                                  Icons.history,
                                  orderDetails!.log.isEmpty
                                      ? [
                                          ApprovalDetailsHelper.buildEmptyView(
                                              "No events found"),
                                        ]
                                      : orderDetails!.log.map((e) {
                                          return ApprovalDetailsHelper
                                              .buildMiniCard({
                                            'Event Date': e.eventDate,
                                            'User': e.eventUser,
                                            'Event': e.event,
                                          });
                                        }).toList(),
                                  count: orderDetails!.log.length,
                                  isExpanded: expandedSection == "Event Log",
                                  toggleSection: () {
                                    setState(() {
                                      expandedSection =
                                          expandedSection == "Event Log"
                                              ? null
                                              : "Event Log";
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
//---------------------------------Approve/Reject-----------------------------------------------------
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
                                        orderApprovalApproved();
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
                                        orderApprovalReject(reason);
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
