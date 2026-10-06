import 'dart:convert';

OrderApprovalListResponse orderApprovalListResponseFromJson(String str) =>
    OrderApprovalListResponse.fromJson(json.decode(str));

String orderApprovalListResponseToJson(OrderApprovalListResponse data) =>
    json.encode(data.toJson());

class OrderApprovalListResponse {
  final int code;
  final List<String> message;
  final List<OrderApprovalItem> data;
  final int totalrecords;

  OrderApprovalListResponse({
    required this.code,
    required this.message,
    required this.data,
    required this.totalrecords,
  });

  factory OrderApprovalListResponse.fromJson(Map<String, dynamic> json) =>
      OrderApprovalListResponse(
        code: json["code"] ?? 0,
        message: List<String>.from(json["message"]?.map((x) => x) ?? []),
        data: List<OrderApprovalItem>.from(
            json["data"]?.map((x) => OrderApprovalItem.fromJson(x)) ?? []),
        totalrecords: json["totalrecords"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": List<dynamic>.from(message.map((x) => x)),
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "totalrecords": totalrecords,
      };
}

class OrderApprovalItem {
  final int orderId;
  final String orderNumber;
  final String orderStatus;
  final String orderDate;
  final double orderValue;
  final dynamic referenceNo;
  final int supplierId;
  final dynamic supplierName;
  final dynamic fao;
  final dynamic deliveryId;
  final dynamic invoicePtId;
  final dynamic categoryId;
  final dynamic orderTypeId;
  final dynamic expCode1Id;
  final dynamic expCode2Id;
  final dynamic expCode3Id;
  final dynamic contractId;
  final dynamic fob;
  final dynamic orderBudgetHeader;
  final String approvalType;

  OrderApprovalItem({
    required this.orderId,
    required this.orderNumber,
    required this.orderStatus,
    required this.orderDate,
    required this.orderValue,
    this.referenceNo,
    required this.supplierId,
    this.supplierName,
    this.fao,
    this.deliveryId,
    this.invoicePtId,
    this.categoryId,
    this.orderTypeId,
    this.expCode1Id,
    this.expCode2Id,
    this.expCode3Id,
    this.contractId,
    this.fob,
    this.orderBudgetHeader,
    required this.approvalType,
  });

  factory OrderApprovalItem.fromJson(Map<String, dynamic> json) =>
      OrderApprovalItem(
        orderId: json["Order_ID"] ?? 0,
        orderNumber: json["OrderNumber"] ?? "",
        orderStatus: json["Order_Status"] ?? "",
        orderDate: json["Order_Date"] ?? "",
        orderValue: json["Order_Value"] ?? 0,
        referenceNo: json["ReferenceNo"],
        supplierId: json["SupplierID"] ?? 0,
        supplierName: json["Supplier_Name"],
        fao: json["FAO"],
        deliveryId: json["DeliveryID"],
        invoicePtId: json["InvoicePtID"],
        categoryId: json["CategoryID"],
        orderTypeId: json["OrderTypeID"],
        expCode1Id: json["ExpCode1_ID"],
        expCode2Id: json["ExpCode2_ID"],
        expCode3Id: json["ExpCode3_ID"],
        contractId: json["ContractID"],
        fob: json["FOB"],
        orderBudgetHeader: json["Order_Budget_Header"],
        approvalType: json["ApprovalType"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "Order_ID": orderId,
        "OrderNumber": orderNumber,
        "Order_Status": orderStatus,
        "Order_Date": orderDate,
        "Order_Value": orderValue,
        "ReferenceNo": referenceNo,
        "SupplierID": supplierId,
        "Supplier_Name": supplierName,
        "FAO": fao,
        "DeliveryID": deliveryId,
        "InvoicePtID": invoicePtId,
        "CategoryID": categoryId,
        "OrderTypeID": orderTypeId,
        "ExpCode1_ID": expCode1Id,
        "ExpCode2_ID": expCode2Id,
        "ExpCode3_ID": expCode3Id,
        "ContractID": contractId,
        "FOB": fob,
        "Order_Budget_Header": orderBudgetHeader,
        "ApprovalType": approvalType,
      };
}
