// To parse this JSON data, do
//
//     final RequestApprovalDetailsResponse = RequestApprovalDetailsResponseFromJson(jsonString);

import 'dart:convert';

RequestApprovalDetailsResponse RequestApprovalDetailsResponseFromJson(
        String str) =>
    RequestApprovalDetailsResponse.fromJson(json.decode(str));

String RequestApprovalDetailsResponseToJson(
        RequestApprovalDetailsResponse data) =>
    json.encode(data.toJson());

class RequestApprovalDetailsResponse {
  int code;
  List<String> message;
  Data data;
  int totalrecords;

  RequestApprovalDetailsResponse({
    required this.code,
    required this.message,
    required this.data,
    required this.totalrecords,
  });

  factory RequestApprovalDetailsResponse.fromJson(Map<String, dynamic> json) =>
      RequestApprovalDetailsResponse(
        code: json["code"],
        message: List<String>.from(json["message"].map((x) => x)),
        data: Data.fromJson(json["data"]),
        totalrecords: json["totalrecords"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": List<dynamic>.from(message.map((x) => x)),
        "data": data.toJson(),
        "totalrecords": totalrecords,
      };
}

class Data {
  Header header;
  List<Line> line;
  List<Rule> rule;
  List<RuleApprover> ruleApprovers;
  List<Log> log;
  List<CostCenter> costCenter;
  dynamic termCondition;
  List<dynamic> attachedDocument;
  dynamic notes;
  bool chkAttachDocuments;
  bool chkStdText;
  bool chkNotes;

  Data({
    required this.header,
    required this.line,
    required this.rule,
    required this.ruleApprovers,
    required this.log,
    required this.costCenter,
    this.termCondition,
    required this.attachedDocument,
    this.notes,
    required this.chkAttachDocuments,
    required this.chkStdText,
    required this.chkNotes,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        header: Header.fromJson(json["header"] ?? {}),
        line: json["line"] != null
            ? List<Line>.from(json["line"].map((x) => Line.fromJson(x)))
            : [],
        rule: json["rule"] != null
            ? List<Rule>.from(json["rule"].map((x) => Rule.fromJson(x)))
            : [],
        ruleApprovers: json["ruleApprovers"] != null
            ? List<RuleApprover>.from(
                json["ruleApprovers"].map((x) => RuleApprover.fromJson(x)))
            : [],
        log: json["Log"] != null
            ? List<Log>.from(json["Log"].map((x) => Log.fromJson(x)))
            : [],
        costCenter: json["CostCenter"] != null
            ? List<CostCenter>.from(
                json["CostCenter"].map((x) => CostCenter.fromJson(x)))
            : [],
        termCondition: json["TermCondition"],
        attachedDocument: json["AttachedDocument"] != null
            ? List<dynamic>.from(json["AttachedDocument"])
            : [],
        notes: json["Notes"],
        chkAttachDocuments: json["chk_Attach_Documents"] ?? false,
        chkStdText: json["chk_Std_Text"] ?? false,
        chkNotes: json["chk_Notes"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "header": header.toJson(),
        "line": List<dynamic>.from(line.map((x) => x.toJson())),
        "rule": List<dynamic>.from(rule.map((x) => x.toJson())),
        "ruleApprovers":
            List<dynamic>.from(ruleApprovers.map((x) => x.toJson())),
        "Log": List<dynamic>.from(log.map((x) => x.toJson())),
        "CostCenter": List<dynamic>.from(costCenter.map((x) => x.toJson())),
        "TermCondition": termCondition,
        "AttachedDocument": List<dynamic>.from(attachedDocument.map((x) => x)),
        "Notes": notes,
        "chk_Attach_Documents": chkAttachDocuments,
        "chk_Std_Text": chkStdText,
        "chk_Notes": chkNotes,
      };
}

class CostCenter {
  int recNum;
  int costCentreId;
  String costCode;
  String costDescription;
  double splitPercentage;
  double splitValue;
  double costBudget;
  bool active;
  bool isSelected;
  int isExists;
  int splitType;
  int userCount;
  int ruleEntityId;

  CostCenter({
    required this.recNum,
    required this.costCentreId,
    required this.costCode,
    required this.costDescription,
    required this.splitPercentage,
    required this.splitValue,
    required this.costBudget,
    required this.active,
    required this.isSelected,
    required this.isExists,
    required this.splitType,
    required this.userCount,
    required this.ruleEntityId,
  });

  factory CostCenter.fromJson(Map<String, dynamic> json) => CostCenter(
        recNum: json["RecNum"] ?? 0,
        costCentreId: json["CostCentre_ID"] ?? 0,
        costCode: json["Cost_Code"] ?? '',
        costDescription: json["Cost_Description"] ?? '',
        splitPercentage: (json["SplitPercentage"] ?? 0).toDouble(),
        splitValue: (json["SplitValue"] ?? 0).toDouble(),
        costBudget: (json["Cost_Budget"] ?? 0).toDouble(),
        active: json["Active"] ?? false,
        isSelected: json["IsSelected"] ?? false,
        isExists: json["IsExists"] ?? 0,
        splitType: json["Split_Type"] ?? 0,
        userCount: json["UserCount"] ?? 0,
        ruleEntityId: json["Rule_Entity_ID"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "RecNum": recNum,
        "CostCentre_ID": costCentreId,
        "Cost_Code": costCode,
        "Cost_Description": costDescription,
        "SplitPercentage": splitPercentage,
        "SplitValue": splitValue,
        "Cost_Budget": costBudget,
        "Active": active,
        "IsSelected": isSelected,
        "IsExists": isExists,
        "Split_Type": splitType,
        "UserCount": userCount,
        "Rule_Entity_ID": ruleEntityId,
      };
}

class Header {
  int requestId;
  String requestNumber;
  String entryDate;
  String requestStatus;
  String referenceNo;
  int orderTypeId;
  String contractNo;
  String instructions;
  String fao;
  String deliveryCode;
  String categoryCode;
  String expCode1;
  String expCode2;
  String expCode3;
  String expName1;
  String expName2;
  String expName3;
  String requestValueLabel;
  String ccyCode;
  String headerCcyCode;
  String fob;
  String shipVia;
  dynamic expenseType;
  String requestBudgetHeader;
  String requestDescription;
  double requestValue;
  double totalTax;
  double grossTotal;
  String ruleStatus;
  String requestApproverStatus;
  int originatorId;
  String originatorName;
  String originatorEmail;
  int requestApproverId;
  String requestApproverName;
  int buyerId;
  String buyerName;
  String buyerEmail;
  int regionId;
  String regionCode;
  bool bRfqLimitRequired;
  double decRfqLimit;
  bool boolPmAssignOwnership;
  int purchasingManagerId;
  bool boolSendEmail;
  dynamic strPurchaseDepEmail;
  int hdRuleEntityId;
  bool btnApprove;
  dynamic rejectReason;
  int customer;

  Header({
    required this.requestId,
    required this.requestNumber,
    required this.entryDate,
    required this.requestStatus,
    required this.referenceNo,
    required this.orderTypeId,
    required this.contractNo,
    required this.instructions,
    required this.fao,
    required this.deliveryCode,
    required this.categoryCode,
    required this.expCode1,
    required this.expCode2,
    required this.expCode3,
    required this.expName1,
    required this.expName2,
    required this.expName3,
    required this.requestValueLabel,
    required this.ccyCode,
    required this.headerCcyCode,
    required this.fob,
    required this.shipVia,
    this.expenseType,
    required this.requestBudgetHeader,
    required this.requestDescription,
    required this.requestValue,
    required this.totalTax,
    required this.grossTotal,
    required this.ruleStatus,
    required this.requestApproverStatus,
    required this.originatorId,
    required this.originatorName,
    required this.originatorEmail,
    required this.requestApproverId,
    required this.requestApproverName,
    required this.buyerId,
    required this.buyerName,
    required this.buyerEmail,
    required this.regionId,
    required this.regionCode,
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

  factory Header.fromJson(Map<String, dynamic> json) => Header(
        requestId: json["Request_ID"] ?? 0,
        requestNumber: json["Request_Number"] ?? '',
        entryDate: json["Entry_Date"] ?? '',
        requestStatus: json["Request_Status"] ?? '',
        referenceNo: json["ReferenceNo"] ?? '',
        orderTypeId: json["OrderTypeID"] ?? 0,
        contractNo: json["ContractNo"] ?? '',
        instructions: json["Instructions"] ?? '',
        fao: json["FAO"] ?? '',
        deliveryCode: json["DeliveryCode"] ?? '',
        categoryCode: json["CategoryCode"] ?? '',
        expCode1: json["ExpCode1"] ?? '',
        expCode2: json["ExpCode2"] ?? '',
        expCode3: json["ExpCode3"] ?? '',
        expName1: json["ExpName1"] ?? '',
        expName2: json["ExpName2"] ?? '',
        expName3: json["ExpName3"] ?? '',
        requestValueLabel: json["RequestValueLabel"] ?? '',
        ccyCode: json["CCYCode"] ?? '',
        headerCcyCode: json["Ccy_Code"] ?? '',
        fob: json["FOB"] ?? '',
        shipVia: json["Ship_Via"] ?? '',
        expenseType: json["Expense_Type"],
        requestBudgetHeader: json["Request_Budget_header"] ?? '',
        requestDescription: json["Request_Description"] ?? '',
        requestValue: (json["Request_Value"] ?? 0).toDouble(),
        totalTax: (json["TotalTax"] ?? 0).toDouble(),
        grossTotal: (json["GrossTotal"] ?? 0).toDouble(),
        ruleStatus: json["Rule_status"] ?? '',
        requestApproverStatus: json["Request_Approver_Status"] ?? '',
        originatorId: json["Originator_ID"] ?? 0,
        originatorName: json["Originator_Name"] ?? '',
        originatorEmail: json["Originator_Email"] ?? '',
        requestApproverId: json["RequestApprover_ID"] ?? 0,
        requestApproverName: json["RequestApproverName"] ?? '',
        buyerId: json["Buyer_ID"] ?? 0,
        buyerName: json["Buyer_Name"] ?? '',
        buyerEmail: json["Buyer_Email"] ?? '',
        regionId: json["Region_ID"] ?? 0,
        regionCode: json["Region_Code"] ?? '',
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
        "ExpName1": expName1,
        "ExpName2": expName2,
        "ExpName3": expName3,
        "RequestValueLabel": requestValueLabel,
        "CCYCode": ccyCode,
        "Ccy_Code": headerCcyCode,
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

class Line {
  int requestLineId;
  int itemOrder;
  int itemId;
  int supplierId;
  int costCentreId;
  int requestId;
  String itemCode;
  String description;
  String unit;
  double packSize;
  double quantity;
  double price;
  double discount;
  double tax;
  double taxValue;
  double netPrice;
  double grossPrice;
  String expCode4;
  dynamic expCode5;
  dynamic expCode6;
  int expCode4Id;
  int expCode5Id;
  int expCode6Id;
  String dueDate;
  dynamic expenseType;
  int supplierCcyId;
  String supplierCcyCode;
  double supplierCcyRate;
  int discountType;
  int regionId;
  dynamic suppliersPartNo;

  Line({
    required this.requestLineId,
    required this.itemOrder,
    required this.itemId,
    required this.supplierId,
    required this.costCentreId,
    required this.requestId,
    required this.itemCode,
    required this.description,
    required this.unit,
    required this.packSize,
    required this.quantity,
    required this.price,
    required this.discount,
    required this.tax,
    required this.taxValue,
    required this.netPrice,
    required this.grossPrice,
    required this.expCode4,
    this.expCode5,
    this.expCode6,
    required this.expCode4Id,
    required this.expCode5Id,
    required this.expCode6Id,
    required this.dueDate,
    this.expenseType,
    required this.supplierCcyId,
    required this.supplierCcyCode,
    required this.supplierCcyRate,
    required this.discountType,
    required this.regionId,
    this.suppliersPartNo,
  });

  factory Line.fromJson(Map<String, dynamic> json) => Line(
        requestLineId: json["Request_Line_ID"] ?? 0,
        itemOrder: json["Item_Order"] ?? 0,
        itemId: json["ItemID"] ?? 0,
        supplierId: json["SupplierID"] ?? 0,
        costCentreId: json["CostCentre_ID"] ?? 0,
        requestId: json["Request_ID"] ?? 0,
        itemCode: json["ItemCode"] ?? '',
        description: json["Description"] ?? '',
        unit: json["Unit"] ?? '',
        packSize: (json["PackSize"] ?? 0).toDouble(),
        quantity: (json["Quantity"] ?? 0).toDouble(),
        price: (json["Price"] ?? 0).toDouble(),
        discount: (json["Discount"] ?? 0).toDouble(),
        tax: (json["Tax"] ?? 0).toDouble(),
        taxValue: (json["TaxValue"] ?? 0).toDouble(),
        netPrice: (json["NetPrice"] ?? 0).toDouble(),
        grossPrice: (json["GrossPrice"] ?? 0).toDouble(),
        expCode4: json["ExpCode4"] ?? '',
        expCode5: json["ExpCode5"],
        expCode6: json["ExpCode6"],
        expCode4Id: json["ExpCode4_ID"] ?? 0,
        expCode5Id: json["ExpCode5_ID"] ?? 0,
        expCode6Id: json["ExpCode6_ID"] ?? 0,
        dueDate: json["DueDate"] ?? '',
        expenseType: json["Expense_Type"],
        supplierCcyId: json["Supplier_CcyID"] ?? 0,
        supplierCcyCode: json["Supplier_CcyCode"] ?? '',
        supplierCcyRate: (json["Supplier_CcyRate"] ?? 0).toDouble(),
        discountType: json["Discount_Type"] ?? 0,
        regionId: json["Region_ID"] ?? 0,
        suppliersPartNo: json["SuppliersPartNo"],
      );

  Map<String, dynamic> toJson() => {
        "Request_Line_ID": requestLineId,
        "Item_Order": itemOrder,
        "ItemID": itemId,
        "SupplierID": supplierId,
        "CostCentre_ID": costCentreId,
        "Request_ID": requestId,
        "ItemCode": itemCode,
        "Description": description,
        "Unit": unit,
        "PackSize": packSize,
        "Quantity": quantity,
        "Price": price,
        "Discount": discount,
        "Tax": tax,
        "TaxValue": taxValue,
        "NetPrice": netPrice,
        "GrossPrice": grossPrice,
        "ExpCode4": expCode4,
        "ExpCode5": expCode5,
        "ExpCode6": expCode6,
        "ExpCode4_ID": expCode4Id,
        "ExpCode5_ID": expCode5Id,
        "ExpCode6_ID": expCode6Id,
        "DueDate": dueDate,
        "Expense_Type": expenseType,
        "Supplier_CcyID": supplierCcyId,
        "Supplier_CcyCode": supplierCcyCode,
        "Supplier_CcyRate": supplierCcyRate,
        "Discount_Type": discountType,
        "Region_ID": regionId,
        "SuppliersPartNo": suppliersPartNo,
      };
}

class Log {
  int? recNum;
  int? id;
  int? uid;
  String eventDate;
  String eventUser;
  String event;

  Log({
    this.recNum,
    this.id,
    this.uid,
    required this.eventDate,
    required this.eventUser,
    required this.event,
  });

  factory Log.fromJson(Map<String, dynamic> json) => Log(
        recNum: json["RecNum"] is int
            ? json["RecNum"]
            : (json["RecNum"] != null
                ? int.tryParse(json["RecNum"].toString())
                : null),
        id: json["ID"] is int
            ? json["ID"]
            : (json["ID"] != null ? int.tryParse(json["ID"].toString()) : null),
        uid: json["UID"] is int
            ? json["UID"]
            : (json["UID"] != null
                ? int.tryParse(json["UID"].toString())
                : null),
        eventDate: json["EventDate"]?.toString() ?? '',
        eventUser: json["EventUser"]?.toString() ?? '',
        event: json["Event"]?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        "RecNum": recNum ?? 0,
        "ID": id ?? 0,
        "UID": uid ?? 0,
        "EventDate": eventDate,
        "EventUser": eventUser,
        "Event": event,
      };
}

class Rule {
  int ruleId;
  String ruleName;
  String ruleDescription;
  bool ruleSelected;

  Rule({
    required this.ruleId,
    required this.ruleName,
    required this.ruleDescription,
    required this.ruleSelected,
  });

  factory Rule.fromJson(Map<String, dynamic> json) => Rule(
        ruleId: json["Rule_ID"] ?? 0,
        ruleName: json["Rule_Name"] ?? '',
        ruleDescription: json["Rule_Description"] ?? '',
        ruleSelected: json["Rule_Selected"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "Rule_ID": ruleId,
        "Rule_Name": ruleName,
        "Rule_Description": ruleDescription,
        "Rule_Selected": ruleSelected,
      };
}

class RuleApprover {
  int ruleStatusId;
  int ruleEntityId;
  int uid;
  int uidGroup;
  String approvalStatus;
  int approvalOrder;
  String userName;
  String userGroupName;
  String proxyUserName;

  RuleApprover({
    required this.ruleStatusId,
    required this.ruleEntityId,
    required this.uid,
    required this.uidGroup,
    required this.approvalStatus,
    required this.approvalOrder,
    required this.userName,
    required this.userGroupName,
    required this.proxyUserName,
  });

  factory RuleApprover.fromJson(Map<String, dynamic> json) => RuleApprover(
        ruleStatusId: json["Rule_Status_ID"] ?? 0,
        ruleEntityId: json["Rule_Entity_ID"] ?? 0,
        uid: json["UID"] ?? 0,
        uidGroup: json["UID_Group"] ?? 0,
        approvalStatus: json["Approval_Status"] ?? '',
        approvalOrder: json["Approval_Order"] ?? 0,
        userName: json["UserName"] ?? '',
        userGroupName: json["User_Group_Name"] ?? '',
        proxyUserName: json["Proxy_UserName"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "Rule_Status_ID": ruleStatusId,
        "Rule_Entity_ID": ruleEntityId,
        "UID": uid,
        "UID_Group": uidGroup,
        "Approval_Status": approvalStatus,
        "Approval_Order": approvalOrder,
        "UserName": userName,
        "User_Group_Name": userGroupName,
        "Proxy_UserName": proxyUserName,
      };
}
