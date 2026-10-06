import 'dart:convert';

RequestApprovalListResponse requestApprovalListResponseFromJson(String str) =>
    RequestApprovalListResponse.fromJson(json.decode(str));

String requestApprovalListResponseToJson(RequestApprovalListResponse data) =>
    json.encode(data.toJson());

class RequestApprovalListResponse {
  final int code;
  final List<String> message;
  final List<Datum> data;
  final int totalrecords;

  RequestApprovalListResponse({
    required this.code,
    required this.message,
    required this.data,
    required this.totalrecords,
  });

  factory RequestApprovalListResponse.fromJson(Map<String, dynamic> json) =>
      RequestApprovalListResponse(
        code: json["code"] ?? 0,
        message: List<String>.from(json["message"]?.map((x) => x) ?? []),
        data:
            List<Datum>.from(json["data"]?.map((x) => Datum.fromJson(x)) ?? []),
        totalrecords: json["totalrecords"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": message,
        "data": data.map((x) => x.toJson()).toList(),
        "totalrecords": totalrecords,
      };
}

class Datum {
  final int requestId;
  final String requestNumber;
  final String entryDate;
  final String requestStatus;
  final dynamic referenceNo;
  final dynamic orderTypeId;
  final dynamic contractNo;
  final dynamic instructions;
  final dynamic fao;
  final dynamic deliveryCode;
  final dynamic categoryCode;
  final dynamic expCode1;
  final dynamic expCode2;
  final dynamic expCode3;
  final dynamic ccyCode;
  final dynamic datumCcyCode;
  final dynamic fob;
  final dynamic shipVia;
  final dynamic expenseType;
  final dynamic requestBudgetHeader;
  final dynamic requestDescription;
  final double requestValue;
  final double totalTax;
  final double grossTotal;
  final dynamic ruleStatus;
  final dynamic requestApproverStatus;
  final dynamic originatorId;
  final dynamic originatorName;
  final dynamic originatorEmail;
  final int requestApproverId;
  final dynamic requestApproverName;
  final dynamic buyerId;
  final dynamic buyerName;
  final dynamic buyerEmail;
  final int regionId;
  final dynamic regionCode;
  final bool bRfqLimitRequired;
  final double decRfqLimit;
  final bool boolPmAssignOwnership;
  final int purchasingManagerId;
  final bool boolSendEmail;
  final dynamic strPurchaseDepEmail;
  final int hdRuleEntityId;
  final bool btnApprove;
  final dynamic rejectReason;
  final int customer;

  Datum({
    required this.requestId,
    required this.requestNumber,
    required this.entryDate,
    required this.requestStatus,
    this.referenceNo,
    this.orderTypeId,
    this.contractNo,
    this.instructions,
    this.fao,
    this.deliveryCode,
    this.categoryCode,
    this.expCode1,
    this.expCode2,
    this.expCode3,
    this.ccyCode,
    this.datumCcyCode,
    this.fob,
    this.shipVia,
    this.expenseType,
    this.requestBudgetHeader,
    this.requestDescription,
    required this.requestValue,
    required this.totalTax,
    required this.grossTotal,
    this.ruleStatus,
    this.requestApproverStatus,
    this.originatorId,
    this.originatorName,
    this.originatorEmail,
    required this.requestApproverId,
    this.requestApproverName,
    this.buyerId,
    this.buyerName,
    this.buyerEmail,
    required this.regionId,
    this.regionCode,
    required this.bRfqLimitRequired,
    required this.decRfqLimit,
    required this.boolPmAssignOwnership,
    required this.purchasingManagerId,
    required this.boolSendEmail,
    this.strPurchaseDepEmail,
    required this.hdRuleEntityId,
    required this.btnApprove,
    this.rejectReason,
    required this.customer,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        requestId: json["Request_ID"] ?? 0,
        requestNumber: json["Request_Number"] ?? "",
        entryDate: json["Entry_Date"] ?? "",
        requestStatus: json["Request_Status"] ?? "",
        referenceNo: json["ReferenceNo"],
        orderTypeId: json["OrderTypeID"],
        contractNo: json["ContractNo"],
        instructions: json["Instructions"],
        fao: json["FAO"],
        deliveryCode: json["DeliveryCode"],
        categoryCode: json["CategoryCode"],
        expCode1: json["ExpCode1"],
        expCode2: json["ExpCode2"],
        expCode3: json["ExpCode3"],
        ccyCode: json["CCYCode"],
        datumCcyCode: json["Ccy_Code"],
        fob: json["FOB"],
        shipVia: json["Ship_Via"],
        expenseType: json["Expense_Type"],
        requestBudgetHeader: json["Request_Budget_header"],
        requestDescription: json["Request_Description"],
        requestValue: (json["Request_Value"] ?? 0).toDouble(),
        totalTax: (json["TotalTax"] ?? 0).toDouble(),
        grossTotal: (json["GrossTotal"] ?? 0).toDouble(),
        ruleStatus: json["Rule_status"],
        requestApproverStatus: json["Request_Approver_Status"],
        originatorId: json["Originator_ID"],
        originatorName: json["Originator_Name"],
        originatorEmail: json["Originator_Email"],
        requestApproverId: json["RequestApprover_ID"] ?? 0,
        requestApproverName: json["RequestApproverName"],
        buyerId: json["Buyer_ID"],
        buyerName: json["Buyer_Name"],
        buyerEmail: json["Buyer_Email"],
        regionId: json["Region_ID"] ?? 0,
        regionCode: json["Region_Code"],
        bRfqLimitRequired: json["bRFQ_Limit_Required"] ?? false,
        decRfqLimit: (json["decRFQ_Limit"] ?? 0).toDouble(),
        boolPmAssignOwnership: json["boolPM_Assign_Ownership"] ?? false,
        purchasingManagerId: json["PurchasingManager_ID"] ?? 0,
        boolSendEmail: json["boolSendEmail"] ?? false,
        strPurchaseDepEmail: json["strPurchase_Dep_Email"],
        hdRuleEntityId: json["hd_Rule_EntityID"] ?? 0,
        btnApprove: json["btnApprove"] ?? false,
        rejectReason: json["Reject_Reason"],
        customer: json["Customer"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "Request_ID": requestId,
        "Request_Number": requestNumber,
        "Entry_Date": entryDate,
        "Request_Status": requestStatus,
        "ReferenceNo": referenceNo,
        "OrderTypeID": orderTypeId,
        "ContractNo": contractNo,
        "Instructions": instructions,
        "FAO": fao,
        "DeliveryCode": deliveryCode,
        "CategoryCode": categoryCode,
        "ExpCode1": expCode1,
        "ExpCode2": expCode2,
        "ExpCode3": expCode3,
        "CCYCode": ccyCode,
        "Ccy_Code": datumCcyCode,
        "FOB": fob,
        "Ship_Via": shipVia,
        "Expense_Type": expenseType,
        "Request_Budget_header": requestBudgetHeader,
        "Request_Description": requestDescription,
        "Request_Value": requestValue,
        "TotalTax": totalTax,
        "GrossTotal": grossTotal,
        "Rule_status": ruleStatus,
        "Request_Approver_Status": requestApproverStatus,
        "Originator_ID": originatorId,
        "Originator_Name": originatorName,
        "Originator_Email": originatorEmail,
        "RequestApprover_ID": requestApproverId,
        "RequestApproverName": requestApproverName,
        "Buyer_ID": buyerId,
        "Buyer_Name": buyerName,
        "Buyer_Email": buyerEmail,
        "Region_ID": regionId,
        "Region_Code": regionCode,
        "bRFQ_Limit_Required": bRfqLimitRequired,
        "decRFQ_Limit": decRfqLimit,
        "boolPM_Assign_Ownership": boolPmAssignOwnership,
        "PurchasingManager_ID": purchasingManagerId,
        "boolSendEmail": boolSendEmail,
        "strPurchase_Dep_Email": strPurchaseDepEmail,
        "hd_Rule_EntityID": hdRuleEntityId,
        "btnApprove": btnApprove,
        "Reject_Reason": rejectReason,
        "Customer": customer,
      };
}
