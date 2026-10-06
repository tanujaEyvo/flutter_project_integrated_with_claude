import 'package:eyvo_v3/api/api_service/api_service.dart';
import 'package:eyvo_v3/api/response_models/order_approval_approved_response.dart';
import 'package:eyvo_v3/api/response_models/order_approval_details_response.dart';
import 'package:eyvo_v3/api/response_models/order_approval_reject_response.dart';
import 'package:eyvo_v3/app/app_prefs.dart';
import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/routes_manager.dart';
import 'package:eyvo_v3/core/utils.dart';
import 'package:eyvo_v3/core/widgets/alert.dart';
import 'package:eyvo_v3/core/widgets/button.dart';
import 'package:eyvo_v3/core/widgets/common_app_bar.dart';
import 'package:eyvo_v3/core/widgets/progress_indicator.dart';
import 'package:eyvo_v3/features/auth/view/screens/approval/approval_12/common_form_page.dart';
import 'package:eyvo_v3/features/auth/view/screens/approval/approval_12/form_field_custom.dart';
import 'package:flutter/material.dart';

// class OrderDetailsView extends StatefulWidget {
//   final int orderId;
//   final String orderNumber;

//   const OrderDetailsView({
//     Key? key,
//     required this.orderId,
//     required this.orderNumber,
//   }) : super(key: key);

//   @override
//   State<OrderDetailsView> createState() => _OrderDetailsViewState();
// }

// class _OrderDetailsViewState extends State<OrderDetailsView> {
//   final ApiService apiService = ApiService();
//   bool isLoading = false, isError = false;
//   String errorText = "Something went wrong";
//   Data? orderDetails;

//   @override
//   void initState() {
//     super.initState();
//     fetchOrderApprovalDetails();
//   }

//   Future<void> fetchOrderApprovalDetails() async {
//     setState(() {
//       isLoading = true;
//       isError = false;
//     });

//     final jsonResponse = await apiService.postRequest(
//       context,
//       ApiService.orderApprovalDetails,
//       {'uid': SharedPrefs().uID, 'orderId': widget.orderId},
//     );

//     if (jsonResponse != null) {
//       final resp = OrderApprovalDetails.fromJson(jsonResponse);
//       if (resp.code == 200) {
//         setState(() {
//           orderDetails = resp.data;
//           isLoading = false;
//         });
//         return;
//       } else {
//         errorText = resp.message.join(', ');
//       }
//     }
//     setState(() {
//       isError = true;
//       isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: buildCommonAppBar(
//         context: context,
//         title: "#Order No ${widget.orderNumber.toString()}",
//       ),
//       backgroundColor: ColorManager.primary,
//       body: isLoading
//           ? const Center(child: CustomProgressIndicator())
//           : isError
//               ? Center(child: Text(errorText))
//               : orderDetails == null
//                   ? Center(child: Text("No data found"))
//                   : _buildOrderDetailsBody(),
//     );
//   }

//   Widget _buildOrderDetailsBody() {
//     final sections = _buildSectionsFromOrderData();

//     return CommonFormPage(
//       pageTitle: "Order #${widget.orderNumber}",
//       sections: sections,
//       isEditMode: false, // Always false for view only
//       onSubmit: (data) {}, // Not used in view mode
//       customBottomActions: _buildApprovalButtons(),
//     );
//   }

//   List<FormSection> _buildSectionsFromOrderData() {
//     return [
//       _buildHeaderSection(),
//       _buildLineItemsSection(),
//       _buildRulesSection(),
//       _buildRuleApproversSection(),
//       _buildCostCenterSection(),
//       _buildApproversSection(),
//       _buildGroupApproversSection(),
//       _buildAttachmentsSection(),
//       _buildEventLogSection(),
//     ];
//   }

//   FormSection _buildHeaderSection() {
//     final header = orderDetails!.header;
//     return FormSection(
//       title: "Details",
//       icon: Icons.description_outlined,
//       fields: [
//         FormFieldConfig(
//           key: 'orderNumber',
//           label: 'Order Number',
//           type: FieldType.readonly,
//           value: header.orderNumber,
//         ),
//         FormFieldConfig(
//           key: 'orderDate',
//           label: 'Order Date',
//           type: FieldType.readonly,
//           value: header.orderDate,
//         ),
//         FormFieldConfig(
//           key: 'orderStatus',
//           label: 'Order Status',
//           type: FieldType.readonly,
//           value: header.orderStatus,
//         ),
//         FormFieldConfig(
//           key: 'supplierName',
//           label: 'Supplier Name',
//           type: FieldType.readonly,
//           value: header.supplierName,
//         ),
//         FormFieldConfig(
//           key: 'orderValue',
//           label:
//               'Order ${_capitalizeFirstLetter(header.orderValueLabel)} Total',
//           type: FieldType.readonly,
//           value:
//               '${_getFormattedPriceString(header.orderValue)} (${header.currencyCode})',
//         ),
//         FormFieldConfig(
//           key: 'ruleStatus',
//           label: 'Rule Approval',
//           type: FieldType.readonly,
//           value: header.ruleStatus,
//         ),
//         FormFieldConfig(
//           key: 'ccApproverStatus',
//           label: 'Cost Center Approver',
//           type: FieldType.readonly,
//           value: header.ccApproverStatus,
//         ),
//         FormFieldConfig(
//           key: 'groupApproverStatus',
//           label: 'Group Approver',
//           type: FieldType.readonly,
//           value: header.groupApproverStatus,
//         ),
//       ],
//       count: 8,
//     );
//   }

//   FormSection _buildLineItemsSection() {
//     return FormSection(
//       title: "Line Items",
//       icon: Icons.list_alt_outlined,
//       fields: orderDetails!.line.map((lineItem) {
//         return FormFieldConfig(
//           key: 'line_${lineItem.orderLineId}',
//           label: 'Item ${lineItem.itemOrder}',
//           type: FieldType.readonly,
//           value: '${lineItem.itemCode} - ${lineItem.description}',
//         );
//       }).toList(),
//       count: orderDetails!.line.length,
//     );
//   }

//   FormSection _buildRulesSection() {
//     return FormSection(
//       title: "Rules",
//       icon: Icons.rule,
//       fields: orderDetails!.rule.map((rule) {
//         return FormFieldConfig(
//           key: 'rule_${rule.ruleId}',
//           label: 'Rule',
//           type: FieldType.readonly,
//           value:
//               '${rule.ruleName}${rule.ruleDescription.isNotEmpty ? ' - ${rule.ruleDescription}' : ''}',
//         );
//       }).toList(),
//       count: orderDetails!.rule.length,
//     );
//   }

//   FormSection _buildRuleApproversSection() {
//     return FormSection(
//       title: "Rule Approvers",
//       icon: Icons.people,
//       fields: orderDetails!.ruleApprovers.map((approver) {
//         return FormFieldConfig(
//           key: 'rule_approver_${approver.ruleStatusId}',
//           label: 'Approver ${approver.approvalOrder}',
//           type: FieldType.readonly,
//           value: '${approver.userName} - ${approver.approvalStatus}',
//         );
//       }).toList(),
//       count: orderDetails!.ruleApprovers.length,
//     );
//   }

//   FormSection _buildCostCenterSection() {
//     return FormSection(
//       title: "Cost Center Split",
//       icon: Icons.share,
//       fields: orderDetails!.costcenter.map((costCenter) {
//         return FormFieldConfig(
//           key: 'costcenter_${costCenter.recNum}',
//           label: 'Cost Center',
//           type: FieldType.readonly,
//           value:
//               '${costCenter.costCode} - ${costCenter.costDescription} (${costCenter.splitPercentage}%)',
//         );
//       }).toList(),
//       count: orderDetails!.costcenter.length,
//     );
//   }

//   FormSection _buildApproversSection() {
//     return FormSection(
//       title: "Cost Center Approvers",
//       icon: Icons.people_outline,
//       fields: orderDetails!.approver.map((approver) {
//         return FormFieldConfig(
//           key: 'approver_${approver.recNum}',
//           label: 'Approver ${approver.rank}',
//           type: FieldType.readonly,
//           value: '${approver.userName} - ${approver.approval}',
//         );
//       }).toList(),
//       count: orderDetails!.approver.length,
//     );
//   }

//   FormSection _buildGroupApproversSection() {
//     return FormSection(
//       title: "Group Approvers",
//       icon: Icons.groups,
//       fields: orderDetails!.grpapprover.map((groupApprover) {
//         return FormFieldConfig(
//           key: 'group_approver_${groupApprover.userGroupId}',
//           label: 'Group',
//           type: FieldType.readonly,
//           value: '${groupApprover.groupCode} - ${groupApprover.approval}',
//         );
//       }).toList(),
//       count: orderDetails!.grpapprover.length,
//     );
//   }

//   FormSection _buildAttachmentsSection() {
//     return FormSection(
//       title: "Attachments",
//       icon: Icons.attach_file,
//       fields: orderDetails!.attachdoc.map((attachment) {
//         return FormFieldConfig(
//           key: 'attachment_${attachment.documentImg}',
//           label: 'File',
//           type: FieldType.readonly,
//           value: attachment.documentFileName,
//         );
//       }).toList(),
//       count: orderDetails!.attachdoc.length,
//     );
//   }

//   FormSection _buildEventLogSection() {
//     return FormSection(
//       title: "Event Log",
//       icon: Icons.history,
//       fields: orderDetails!.log.map((log) {
//         return FormFieldConfig(
//           key: 'log_${log.recNum}',
//           label: _formatEventDate(log.eventDate),
//           type: FieldType.readonly,
//           value: '${log.eventUser}: ${log.event}',
//         );
//       }).toList(),
//       count: orderDetails!.log.length,
//     );
//   }

//   Widget _buildApprovalButtons() {
//     return Container(
//       color: ColorManager.white,
//       padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//       child: Row(
//         children: [
//           Expanded(
//             child: CustomTextActionButton(
//               buttonText: "Approve",
//               icon: Icons.thumb_up_outlined,
//               backgroundColor: ColorManager.green,
//               borderColor: ColorManager.white,
//               fontColor: ColorManager.white,
//               fontSize: FontSize.s18,
//               isBoldFont: true,
//               onTap: _approveOrder,
//             ),
//           ),
//           const SizedBox(width: 8),
//           Expanded(
//             child: CustomTextActionButton(
//               buttonText: "Reject",
//               icon: Icons.thumb_down_outlined,
//               backgroundColor: ColorManager.red,
//               borderColor: ColorManager.white,
//               fontColor: ColorManager.white,
//               fontSize: FontSize.s18,
//               isBoldFont: true,
//               onTap: _rejectOrder,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _approveOrder() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return CustomImageActionAlert(
//           iconString: '',
//           imageString: ImageAssets.common,
//           titleString: "Confirm Approval",
//           subTitleString: "Are you sure you want to approve this order?",
//           destructiveActionString: "Yes",
//           normalActionString: "No",
//           onDestructiveActionTap: () {
//             Navigator.of(context).pop();
//             orderApprovalApproved();
//           },
//           onNormalActionTap: () {
//             Navigator.of(context).pop();
//           },
//           isConfirmationAlert: true,
//           isNormalAlert: true,
//         );
//       },
//     );
//   }

//   void _rejectOrder() {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return CustomRejectReasonAlert(
//           iconString: '',
//           imageString: ImageAssets.rejection,
//           titleString: "Please Add Reject Reason",
//           rejectActionString: "Reject",
//           cancelActionString: "Cancel",
//           onCancelTap: () {
//             Navigator.of(context).pop();
//           },
//           onRejectTap: (reason) {
//             Navigator.of(context).pop();
//             orderApprovalReject(reason);
//           },
//         );
//       },
//     );
//   }

//   // Your existing API methods
//   Future<void> orderApprovalApproved() async {
//     setState(() {
//       isLoading = true;
//       isError = false;
//     });

//     final jsonResponse = await apiService.postRequest(
//       context,
//       ApiService.orderApprovalApproved,
//       {
//         'uid': SharedPrefs().uID,
//         'orderId': widget.orderId,
//       },
//     );

//     if (!mounted) return;

//     if (jsonResponse != null) {
//       final resp = OrderApprovalApprovedResponse.fromJson(jsonResponse);
//       if (resp.code == 200) {
//         final message = resp.message ?? "Approved successfully";

//         Navigator.pushReplacementNamed(
//           context,
//           Routes.thankYouRoute,
//           arguments: {
//             'message': message,
//             'approverName': 'orderApproval',
//             'status': 'Order Approved',
//             'requestName': 'Order Number',
//             'number': orderDetails!.header.orderNumber
//           },
//         );
//       } else {
//         errorText = resp.message ?? "Something went wrong";
//         showErrorDialog(context, errorText, false);
//       }
//     } else {
//       errorText = "No response from server";
//       showErrorDialog(context, errorText, false);
//     }

//     setState(() {
//       isLoading = false;
//       isError = true;
//     });
//   }

//   Future<void> orderApprovalReject(String reason) async {
//     setState(() {
//       isLoading = true;
//       isError = false;
//     });

//     final jsonResponse = await apiService.postRequest(
//       context,
//       ApiService.orderApprovalReject,
//       {
//         'uid': SharedPrefs().uID,
//         'orderId': widget.orderId,
//         'reason': reason,
//       },
//     );

//     if (!mounted) return;

//     if (jsonResponse != null) {
//       final resp = OrderApprovalRejectResponse.fromJson(jsonResponse);
//       if (resp.code == 200) {
//         final message = resp.message.isNotEmpty
//             ? resp.message.first
//             : "Rejected successfully";

//         Navigator.pushReplacementNamed(
//           context,
//           Routes.thankYouRoute,
//           arguments: {
//             'message': message,
//             'approverName': 'orderApproval',
//             'status': 'Order Rejected',
//             'requestName': 'Order Number',
//             'number': orderDetails!.header.orderNumber,
//           },
//         );
//       } else {
//         errorText = resp.message.isNotEmpty
//             ? resp.message.first
//             : "Something went wrong";
//         showErrorDialog(context, errorText, false);
//       }
//     } else {
//       errorText = "No response from server";
//       showErrorDialog(context, errorText, false);
//     }

//     setState(() {
//       isLoading = false;
//       isError = true;
//     });
//   }

//   String _capitalizeFirstLetter(String text) {
//     if (text.isEmpty) return text;
//     return text[0].toUpperCase() + text.substring(1).toLowerCase();
//   }

//   String _getFormattedPriceString(double value) {
//     return value.toStringAsFixed(2);
//   }

//   String _formatEventDate(String eventDate) {
//     try {
//       final date = DateTime.parse(eventDate);
//       return "${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}";
//     } catch (e) {
//       return eventDate;
//     }
//   }
// }

import 'package:flutter/material.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/widgets/common_app_bar.dart';
import 'package:eyvo_v3/features/auth/view/screens/approval/approval_12/common_form_page.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({Key? key}) : super(key: key);

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final ApiService apiService = ApiService();
  bool isLoading = false;
  String errorText = "";

  @override
  Widget build(BuildContext context) {
    final sections = _buildOrderCreationSections();

    return CommonFormPage(
      pageTitle: "Create New Order",
      sections: sections,
      isEditMode: true,
      // onSubmit: _submitOrder,
      customBottomActions: _buildActionButtons(),
    );
  }

  List<FormSection> _buildOrderCreationSections() {
    return [
      _buildOrderInfoSection(),
      _buildSupplierSection(),
      _buildDeliverySection(),
      _buildLineItemsSection(),
      _buildCostCenterSection(),
      _buildAdditionalInfoSection(),
    ];
  }

  FormSection _buildOrderInfoSection() {
    return FormSection(
      title: "Order Information",
      icon: Icons.description,
      fields: [
        FormFieldConfig(
          key: 'orderDate',
          label: 'Order Date',
          type: FieldType.date,
          isRequired: true,
          value: _getCurrentDate(),
        ),
        FormFieldConfig(
          key: 'referenceNo',
          label: 'Reference Number',
          type: FieldType.text,
          isRequired: false,
        ),
        FormFieldConfig(
          key: 'orderType',
          label: 'Order Type',
          type: FieldType.dropdown,
          isRequired: true,
          options: [
            {'label': 'Purchase Order', 'value': 'PO'},
            {'label': 'Work Order', 'value': 'WO'},
            {'label': 'Service Order', 'value': 'SO'},
            {'label': 'Maintenance Order', 'value': 'MO'},
          ],
        ),
        FormFieldConfig(
          key: 'category',
          label: 'Category',
          type: FieldType.dropdown,
          isRequired: true,
          options: [
            {'label': 'IT Equipment', 'value': 'IT'},
            {'label': 'Office Supplies', 'value': 'OFFICE'},
            {'label': 'Furniture', 'value': 'FURNITURE'},
            {'label': 'Services', 'value': 'SERVICES'},
          ],
        ),
      ],
    );
  }

  FormSection _buildSupplierSection() {
    return FormSection(
      title: "Supplier Details",
      icon: Icons.business,
      fields: [
        FormFieldConfig(
          key: 'supplier',
          label: 'Supplier',
          type: FieldType.dropdown,
          isRequired: true,
          options: [
            {'label': 'GBP Supplier', 'value': '1'},
            {'label': 'ABC Corporation', 'value': '2'},
            {'label': 'XYZ Ltd', 'value': '3'},
          ],
        ),
        FormFieldConfig(
          key: 'supplierContact',
          label: 'Contact Person',
          type: FieldType.text,
          isRequired: false,
        ),
        FormFieldConfig(
          key: 'supplierEmail',
          label: 'Supplier Email',
          type: FieldType.text,
          isRequired: false,
          validationMessage: 'Please enter a valid email',
        ),
        FormFieldConfig(
          key: 'supplierPhone',
          label: 'Supplier Phone',
          type: FieldType.text,
          isRequired: false,
        ),
      ],
    );
  }

  FormSection _buildDeliverySection() {
    return FormSection(
      title: "Delivery Information",
      icon: Icons.local_shipping,
      fields: [
        FormFieldConfig(
          key: 'deliveryTo',
          label: 'Delivery To (FAO)',
          type: FieldType.text,
          isRequired: true,
          value: 'Mike Smith', // Default value or from user profile
        ),
        FormFieldConfig(
          key: 'deliveryAddress',
          label: 'Delivery Address',
          type: FieldType.multiline,
          isRequired: true,
        ),
        FormFieldConfig(
          key: 'deliveryDate',
          label: 'Expected Delivery Date',
          type: FieldType.date,
          isRequired: false,
        ),
        FormFieldConfig(
          key: 'incoterms',
          label: 'Incoterms',
          type: FieldType.dropdown,
          isRequired: false,
          options: [
            {'label': 'EXW - Ex Works', 'value': 'EXW'},
            {'label': 'FOB - Free On Board', 'value': 'FOB'},
            {'label': 'CIF - Cost Insurance Freight', 'value': 'CIF'},
            {'label': 'DDP - Delivered Duty Paid', 'value': 'DDP'},
          ],
        ),
      ],
    );
  }

  FormSection _buildLineItemsSection() {
    return FormSection(
      title: "Order Items",
      icon: Icons.list_alt,
      fields: [
        FormFieldConfig(
          key: 'item1_code',
          label: 'Item Code',
          type: FieldType.text,
          isRequired: true,
        ),
        FormFieldConfig(
          key: 'item1_description',
          label: 'Description',
          type: FieldType.multiline,
          isRequired: true,
        ),
        FormFieldConfig(
          key: 'item1_quantity',
          label: 'Quantity',
          type: FieldType.number,
          isRequired: true,
        ),
        FormFieldConfig(
          key: 'item1_unit',
          label: 'Unit',
          type: FieldType.dropdown,
          isRequired: true,
          options: [
            {'label': 'Piece', 'value': 'PC'},
            {'label': 'Box', 'value': 'BOX'},
            {'label': 'Set', 'value': 'SET'},
            {'label': 'Kg', 'value': 'KG'},
            {'label': 'Meter', 'value': 'M'},
          ],
        ),
        FormFieldConfig(
          key: 'item1_price',
          label: 'Unit Price',
          type: FieldType.number,
          isRequired: true,
        ),
        FormFieldConfig(
          key: 'item1_tax',
          label: 'Tax (%)',
          type: FieldType.number,
          isRequired: false,
          value: '0.0',
        ),
      ],
    );
  }

  FormSection _buildCostCenterSection() {
    return FormSection(
      title: "Cost Center Allocation",
      icon: Icons.account_balance_wallet,
      fields: [
        FormFieldConfig(
          key: 'costCenter',
          label: 'Cost Center',
          type: FieldType.dropdown,
          isRequired: true,
          options: [
            {'label': '0230 - IT Projects', 'value': '0230'},
            {'label': '0450 - Marketing', 'value': '0450'},
            {'label': '0670 - Operations', 'value': '0670'},
            {'label': '0890 - Administration', 'value': '0890'},
          ],
        ),
        FormFieldConfig(
          key: 'splitPercentage',
          label: 'Split Percentage (%)',
          type: FieldType.number,
          isRequired: true,
          value: '100',
        ),
        FormFieldConfig(
          key: 'glAccount',
          label: 'GL Account',
          type: FieldType.dropdown,
          isRequired: true,
          options: [
            {'label': 'Consulting Income', 'value': '74'},
            {'label': 'Hardware Expenses', 'value': '66'},
            {'label': 'Software Expenses', 'value': '67'},
          ],
        ),
      ],
    );
  }

  FormSection _buildAdditionalInfoSection() {
    return FormSection(
      title: "Additional Information",
      icon: Icons.note_add,
      fields: [
        FormFieldConfig(
          key: 'specialInstructions',
          label: 'Special Instructions',
          type: FieldType.multiline,
          isRequired: false,
        ),
        FormFieldConfig(
          key: 'budgetCode',
          label: 'Budget Code',
          type: FieldType.text,
          isRequired: false,
        ),
        FormFieldConfig(
          key: 'projectCode',
          label: 'Project Code',
          type: FieldType.text,
          isRequired: false,
        ),
        FormFieldConfig(
          key: 'jobNumber',
          label: 'Job Number',
          type: FieldType.text,
          isRequired: false,
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Container(
      color: ColorManager.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: isLoading ? null : _saveAsDraft,
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                side: BorderSide(color: ColorManager.blue),
              ),
              child: isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      'Save as Draft',
                      style: TextStyle(color: ColorManager.blue),
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed:
                  isLoading ? null : () {}, // Handled by CommonFormPage submit
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.green,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: isLoading
                  ? SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Text(
                      'Submit Order',
                      style: TextStyle(color: Colors.white),
                    ),
            ),
          ),
        ],
      ),
    );
  }

  // Future<void> _submitOrder(Map<String, dynamic> formData) async {
  //   setState(() {
  //     isLoading = true;
  //   });

  //   try {
  //     // Prepare the order data for API
  //     final orderData = _prepareOrderData(formData);

  //     // Call your order creation API
  //     final jsonResponse = await apiService.postRequest(
  //       context,
  //       ApiService.createOrder, // You'll need to add this to your ApiService
  //       {
  //         'uid': SharedPrefs().uID,
  //         ...orderData,
  //       },
  //     );

  //     if (!mounted) return;

  //     if (jsonResponse != null) {
  //       // Handle API response based on your API structure
  //       if (jsonResponse['code'] == 200) {
  //         _showSuccessDialog();
  //       } else {
  //         errorText = jsonResponse['message']?.join(', ') ?? "Failed to create order";
  //         _showErrorDialog(errorText);
  //       }
  //     } else {
  //       errorText = "No response from server";
  //       _showErrorDialog(errorText);
  //     }
  //   } catch (e) {
  //     errorText = "Error creating order: $e";
  //     _showErrorDialog(errorText);
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         isLoading = false;
  //       });
  //     }
  //   }
  // }

  Future<void> _saveAsDraft() async {
    setState(() {
      isLoading = true;
    });

    try {
      // You might want to get the current form data from CommonFormPage
      // For now, we'll just show a message
      await Future.delayed(Duration(seconds: 1)); // Simulate API call

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Order saved as draft successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving draft: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Map<String, dynamic> _prepareOrderData(Map<String, dynamic> formData) {
    // Transform form data to match your API requirements
    return {
      'orderDate': formData['orderDate'],
      'referenceNo': formData['referenceNo'] ?? '',
      'orderType': formData['orderType'],
      'category': formData['category'],
      'supplierId': formData['supplier'],
      'supplierContact': formData['supplierContact'] ?? '',
      'deliveryTo': formData['deliveryTo'],
      'deliveryAddress': formData['deliveryAddress'],
      'deliveryDate': formData['deliveryDate'] ?? '',
      'incoterms': formData['incoterms'] ?? '',
      'lineItems': [
        {
          'itemCode': formData['item1_code'],
          'description': formData['item1_description'],
          'quantity': formData['item1_quantity'],
          'unit': formData['item1_unit'],
          'price': formData['item1_price'],
          'tax': formData['item1_tax'] ?? '0.0',
        }
      ],
      'costCenter': formData['costCenter'],
      'splitPercentage': formData['splitPercentage'],
      'glAccount': formData['glAccount'],
      'specialInstructions': formData['specialInstructions'] ?? '',
      'budgetCode': formData['budgetCode'] ?? '',
      'projectCode': formData['projectCode'] ?? '',
      'jobNumber': formData['jobNumber'] ?? '',
    };
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Order Created Successfully"),
          content:
              Text("Your order has been created and submitted for approval."),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to previous screen
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Error"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return "${now.day}/${now.month}/${now.year}";
  }
}
