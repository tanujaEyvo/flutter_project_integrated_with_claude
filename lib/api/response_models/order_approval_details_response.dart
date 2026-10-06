import 'dart:convert';

// == ENTRY POINT ==
OrderApprovalDetails orderApprovalDetailsFromJson(String str) =>
    OrderApprovalDetails.fromJson(json.decode(str));

String orderApprovalDetailsToJson(OrderApprovalDetails data) =>
    json.encode(data.toJson());

class OrderApprovalDetails {
  int code;
  List<String> message;
  Data data;
  int totalrecords;

  OrderApprovalDetails({
    required this.code,
    required this.message,
    required this.data,
    required this.totalrecords,
  });

  factory OrderApprovalDetails.fromJson(Map<String, dynamic> json) =>
      OrderApprovalDetails(
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

// == DATA ==

class Data {
  Header header;
  List<Line> line;
  List<Rule> rule;
  List<RuleApprover> ruleApprovers;
  List<Costcenter> costcenter;
  List<Approver> approver;
  List<Grpapprover> grpapprover;
  List<AttachDoc> attachdoc;
  List<Log> log;

  Data({
    required this.header,
    required this.line,
    required this.rule,
    required this.ruleApprovers,
    required this.costcenter,
    required this.approver,
    required this.grpapprover,
    required this.attachdoc,
    required this.log,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
        header: Header.fromJson(json["header"]),
        line: List<Line>.from(json["line"].map((x) => Line.fromJson(x))),
        rule: List<Rule>.from(json["rule"].map((x) => Rule.fromJson(x))),
        ruleApprovers: List<RuleApprover>.from(
            json["ruleApprovers"].map((x) => RuleApprover.fromJson(x))),
        costcenter: List<Costcenter>.from(
            json["costcenter"].map((x) => Costcenter.fromJson(x))),
        approver: List<Approver>.from(
            json["approver"].map((x) => Approver.fromJson(x))),
        grpapprover: List<Grpapprover>.from(
            json["grpapprover"].map((x) => Grpapprover.fromJson(x))),
        attachdoc: List<AttachDoc>.from(
            json["attachdoc"].map((x) => AttachDoc.fromJson(x))),
        log: List<Log>.from(json["log"].map((x) => Log.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "header": header.toJson(),
        "line": List<dynamic>.from(line.map((x) => x.toJson())),
        "rule": List<dynamic>.from(rule.map((x) => x.toJson())),
        "ruleApprovers":
            List<dynamic>.from(ruleApprovers.map((x) => x.toJson())),
        "costcenter": List<dynamic>.from(costcenter.map((x) => x.toJson())),
        "approver": List<dynamic>.from(approver.map((x) => x.toJson())),
        "grpapprover": List<dynamic>.from(grpapprover.map((x) => x.toJson())),
        "attachdoc": List<dynamic>.from(attachdoc.map((x) => x.toJson())),
        "log": List<dynamic>.from(log.map((x) => x.toJson())),
      };
}

// == HEADER ==

class Header {
  final int orderId;
  final String orderNumber;
  final String orderStatus;
  final String orderDate;
  final double orderValue;
  final String referenceNo;
  final int supplierId;
  final String supplierName;
  final String fao;
  final int deliveryId;
  final int invoicePtId;
  final int categoryId;
  final int orderTypeId;
  final int expCode1Id;
  final int expCode2Id;
  final int expCode3Id;
  final int contractId;
  final String fob;
  final String orderBudgetHeader;
  final String? approvalType;
  final String ccApproverStatus;
  final String groupApproverStatus;
  final String ruleStatus;
  final String invoicePtCode;
  final String deliveryCode;
  final String categoryCode;
  final String expCode1;
  final String expCode2;
  final String expCode3;
  final String expName1;
  final String expName2;
  final String expName3;
  final double orderGrossTotal;
  final String orderValueLabel;
  final String currencyCode;
  final String clientCode;
  final String accessKey;
  final String connectionString;

  Header({
    required this.orderId,
    required this.orderNumber,
    required this.orderStatus,
    required this.orderDate,
    required this.orderValue,
    required this.referenceNo,
    required this.supplierId,
    required this.supplierName,
    required this.fao,
    required this.deliveryId,
    required this.invoicePtId,
    required this.categoryId,
    required this.orderTypeId,
    required this.expCode1Id,
    required this.expCode2Id,
    required this.expCode3Id,
    required this.contractId,
    required this.fob,
    required this.orderBudgetHeader,
    required this.approvalType,
    required this.ccApproverStatus,
    required this.groupApproverStatus,
    required this.ruleStatus,
    required this.invoicePtCode,
    required this.deliveryCode,
    required this.categoryCode,
    required this.expCode1,
    required this.expCode2,
    required this.expCode3,
    required this.expName1,
    required this.expName2,
    required this.expName3,
    required this.orderGrossTotal,
    required this.orderValueLabel,
    required this.currencyCode,
    required this.clientCode,
    required this.accessKey,
    required this.connectionString,
  });

  factory Header.fromJson(Map<String, dynamic> json) => Header(
        orderId: json["Order_ID"] ?? 0,
        orderNumber: json["OrderNumber"]?.toString() ?? '',
        orderStatus: json["Order_Status"] ?? '',
        orderDate: json["Order_Date"] ?? '',
        orderValue: (json["Order_Value"] ?? 0).toDouble(),
        referenceNo: json["ReferenceNo"] ?? '',
        supplierId: json["SupplierID"] ?? 0,
        supplierName: json["Supplier_Name"] ?? '',
        fao: json["FAO"] ?? '',
        deliveryId: json["DeliveryID"] ?? 0,
        invoicePtId: json["InvoicePtID"] ?? 0,
        categoryId: json["CategoryID"] ?? 0,
        orderTypeId: json["OrderTypeID"] ?? 0,
        expCode1Id: json["ExpCode1_ID"] ?? 0,
        expCode2Id: json["ExpCode2_ID"] ?? 0,
        expCode3Id: json["ExpCode3_ID"] ?? 0,
        contractId: json["ContractID"] ?? 0,
        fob: json["FOB"] ?? '',
        orderBudgetHeader: json["Order_Budget_Header"] ?? '',
        approvalType: json["ApprovalType"],
        ccApproverStatus: json["CC_Approver_Status"] ?? '',
        groupApproverStatus: json["Group_Approver_Status"] ?? '',
        ruleStatus: json["Rule_status"] ?? '',
        invoicePtCode: json["InvoicePtCode"] ?? '',
        deliveryCode: json["DeliveryCode"] ?? '',
        categoryCode: json["CategoryCode"] ?? '',
        expCode1: json["ExpCode1"] ?? '',
        expCode2: json["ExpCode2"] ?? '',
        expCode3: json["ExpCode3"] ?? '',
        expName1: json["ExpName1"] ?? '',
        expName2: json["ExpName2"] ?? '',
        expName3: json["ExpName3"] ?? '',
        orderGrossTotal: (json["OrderGrossTotal"] ?? 0).toDouble(),
        orderValueLabel: json["OrderValueLabel"] ?? '',
        currencyCode: json["Ccy_code"] ?? '',
        clientCode: json["clientcode"] ?? '',
        accessKey: json["accesskey"] ?? '',
        connectionString: json["connectionstring"] ?? '',
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
        "CC_Approver_Status": ccApproverStatus,
        "Group_Approver_Status": groupApproverStatus,
        "Rule_status": ruleStatus,
        "InvoicePtCode": invoicePtCode,
        "DeliveryCode": deliveryCode,
        "CategoryCode": categoryCode,
        "ExpCode1": expCode1,
        "ExpCode2": expCode2,
        "ExpCode3": expCode3,
        "ExpName1": expName1,
        "ExpName2": expName2,
        "ExpName3": expName3,
        "OrderGrossTotal": orderGrossTotal,
        "OrderValueLabel": orderValueLabel,
        "Ccy_code": currencyCode,
        "clientcode": clientCode,
        "accesskey": accessKey,
        "connectionstring": connectionString,
      };
}

// == RULE ==

class Rule {
  int ruleId;
  String ruleName;
  String ruleDescription;
  bool ruleSelected;
  int ruleEntityId;

  Rule({
    required this.ruleId,
    required this.ruleName,
    required this.ruleDescription,
    required this.ruleSelected,
    required this.ruleEntityId,
  });

  factory Rule.fromJson(Map<String, dynamic> json) => Rule(
        ruleId: json["Rule_ID"],
        ruleName: json["Rule_Name"] ?? '',
        ruleDescription: json["Rule_Description"] ?? '',
        ruleSelected: json["Rule_Selected"] ?? false,
        ruleEntityId: json["Rule_Entity_ID"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "Rule_ID": ruleId,
        "Rule_Name": ruleName,
        "Rule_Description": ruleDescription,
        "Rule_Selected": ruleSelected,
        "Rule_Entity_ID": ruleEntityId,
      };
}

// == RULE APPROVER ==

class RuleApprover {
  int ruleStatusId;
  int uid;
  int uidGroup;
  String approvalStatus;
  int approvalOrder;
  int proxyId;
  String userGroupName;
  String userGroupDescription;
  String userName;
  String proxyUserName;
  String? email; 

  RuleApprover({
    required this.ruleStatusId,
    required this.uid,
    required this.uidGroup,
    required this.approvalStatus,
    required this.approvalOrder,
    required this.proxyId,
    required this.userGroupName,
    required this.userGroupDescription,
    required this.userName,
    required this.proxyUserName,
    this.email,
  });

  factory RuleApprover.fromJson(Map<String, dynamic> json) => RuleApprover(
        ruleStatusId: json["Rule_Status_ID"] ?? 0,
        uid: json["UID"] ?? 0,
        uidGroup: json["UID_Group"] ?? 0,
        approvalStatus: json["Approval_Status"] ?? 'N/A',
        approvalOrder: json["Approval_Order"] ?? 0,
        proxyId: json["Proxy_ID"] ?? 0,
        userGroupName: json["User_Group_Name"] ?? 'N/A',
        userGroupDescription: json["User_Group_Description"] ?? 'N/A',
        userName: json["UserName"] ?? 'N/A',
        proxyUserName: json["Proxy_UserName"] ?? 'N/A',
        email: json["Email"],
      );

  Map<String, dynamic> toJson() => {
        "Rule_Status_ID": ruleStatusId,
        "UID": uid,
        "UID_Group": uidGroup,
        "Approval_Status": approvalStatus,
        "Approval_Order": approvalOrder,
        "Proxy_ID": proxyId,
        "User_Group_Name": userGroupName,
        "User_Group_Description": userGroupDescription,
        "UserName": userName,
        "Proxy_UserName": proxyUserName,
        "Email": email,
      };
}

// == LINE ==

class Line {
  final int orderLineId;
  final int orderId;
  final int itemId;
  final int itemOrder;
  final String itemCode;
  final String description;
  final String? suppliersPartNo;
  final String dueDate;
  final double quantity;
  final String unit;
  final double packSize;
  final double price;
  final int discountType;
  final double discount;
  final double tax;
  final double taxValue;
  final double netPrice;
  final double grossPrice;
  final int expCode4Id;
  final String expCode4;
  final String expName4;
  final int expCode5Id;
  final String expCode5;
  final String expName5;
  final int expCode6Id;
  final String expCode6;
  final String expName6;
  final double shippingCharges;
  final int supplierCcyId;
  final String supplierCcyCode;
  final int regionId;
  final double supplierCcyRate;

  Line({
    required this.orderLineId,
    required this.orderId,
    required this.itemId,
    required this.itemOrder,
    required this.itemCode,
    required this.description,
    required this.suppliersPartNo,
    required this.dueDate,
    required this.quantity,
    required this.unit,
    required this.packSize,
    required this.price,
    required this.discountType,
    required this.discount,
    required this.tax,
    required this.taxValue,
    required this.netPrice,
    required this.grossPrice,
    required this.expCode4Id,
    required this.expCode4,
    required this.expName4,
    required this.expCode5Id,
    required this.expCode5,
    required this.expName5,
    required this.expCode6Id,
    required this.expCode6,
    required this.expName6,
    required this.shippingCharges,
    required this.supplierCcyId,
    required this.supplierCcyCode,
    required this.regionId,
    required this.supplierCcyRate,
  });

  factory Line.fromJson(Map<String, dynamic> json) => Line(
        orderLineId: json["Order_Line_ID"] ?? 0,
        orderId: json["Order_ID"] ?? 0,
        itemId: json["ItemID"] ?? 0,
        itemOrder: json["Item_Order"] ?? 0,
        itemCode: json["ItemCode"] ?? '',
        description: json["Description"] ?? '',
        suppliersPartNo: json["SuppliersPartNo"],
        dueDate: json["DueDate"] ?? '',
        quantity: (json["Quantity"] ?? 0).toDouble(),
        unit: json["Unit"]?.toString() ?? '',
        packSize: (json["PackSize"] ?? 0).toDouble(),
        price: (json["Price"] ?? 0).toDouble(),
        discountType: json["Discount_Type"] ?? 0,
        discount: (json["Discount"] ?? 0).toDouble(),
        tax: (json["Tax"] ?? 0).toDouble(),
        taxValue: (json["TaxValue"] ?? 0).toDouble(),
        netPrice: (json["NetPrice"] ?? 0).toDouble(),
        grossPrice: (json["GrossPrice"] ?? 0).toDouble(),
        expCode4Id: json["ExpCode4_ID"] ?? 0,
        expCode4: json["ExpCode4"] ?? '',
        expName4: json["ExpName4"] ?? '',
        expCode5Id: json["ExpCode5_ID"] ?? 0,
        expCode5: json["ExpCode5"] ?? '',
        expName5: json["ExpName5"] ?? '',
        expCode6Id: json["ExpCode6_ID"] ?? 0,
        expCode6: json["ExpCode6"] ?? '',
        expName6: json["ExpName6"] ?? '',
        shippingCharges: (json["Shipping_Charges"] ?? 0).toDouble(),
        supplierCcyId: json["Supplier_CcyID"] ?? 0,
        supplierCcyCode: json["Supplier_CcyCode"] ?? '',
        regionId: json["Region_ID"] ?? 0,
        supplierCcyRate: (json["Supplier_CcyRate"] ?? 0).toDouble(),
      );

  Map<String, dynamic> toJson() => {
        "Order_Line_ID": orderLineId,
        "Order_ID": orderId,
        "ItemID": itemId,
        "Item_Order": itemOrder,
        "ItemCode": itemCode,
        "Description": description,
        "SuppliersPartNo": suppliersPartNo,
        "DueDate": dueDate,
        "Quantity": quantity,
        "Unit": unit,
        "PackSize": packSize,
        "Price": price,
        "Discount_Type": discountType,
        "Discount": discount,
        "Tax": tax,
        "TaxValue": taxValue,
        "NetPrice": netPrice,
        "GrossPrice": grossPrice,
        "ExpCode4_ID": expCode4Id,
        "ExpCode4": expCode4,
        "ExpName4": expName4, 
        "Shipping_Charges": shippingCharges,
        "Supplier_CcyID": supplierCcyId,
        "Supplier_CcyCode": supplierCcyCode,
        "Region_ID": regionId,
        "Supplier_CcyRate": supplierCcyRate,
      };
}

// == COSTCENTER, APPROVER, GRPAPPROVER, ATTACHDOC, LOG ==

class Costcenter {
  final int recNum;
  final int costCentreId;
  final String costCode;
  final String costDescription;
  final double splitPercentage;
  final double splitValue;
  final double costBudget;
  final bool active;
  final bool isSelected;
  final int isExists;
  final int splitType;
  final int userCount;
  final int ruleEntityId;

  Costcenter({
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

  factory Costcenter.fromJson(Map<String, dynamic> json) => Costcenter(
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

class Approver {
  final int recNum;
  final int orderId;
  final int uid;
  final int rank;
  final String approval;
  final String userName;
  final String telephone;
  final String extension;
  final String email;
  final String approvalDate;
  final String uidProxy;

  Approver({
    required this.recNum,
    required this.orderId,
    required this.uid,
    required this.rank,
    required this.approval,
    required this.userName,
    required this.telephone,
    required this.extension,
    required this.email,
    required this.approvalDate,
    required this.uidProxy,
  });

  factory Approver.fromJson(Map<String, dynamic> json) => Approver(
        recNum: json["RecNum"] ?? 0,
        orderId: json["Order_ID"] ?? 0,
        uid: json["UID"] ?? 0,
        rank: json["Rank"] ?? 0,
        approval: json["Approval"] ?? '',
        userName: json["UserName"] ?? '',
        telephone: json["Telephone"] ?? '',
        extension: json["Extension"] ?? '',
        email: json["Email"] ?? '',
        approvalDate: json["Approval_Date"] ?? '',
        uidProxy: json["UID_Proxy"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "RecNum": recNum,
        "Order_ID": orderId,
        "UID": uid,
        "Rank": rank,
        "Approval": approval,
        "UserName": userName,
        "Telephone": telephone,
        "Extension": extension,
        "Email": email,
        "Approval_Date": approvalDate,
        "UID_Proxy": uidProxy,
      };
}

class Grpapprover {
  final int userGroupId;
  final String groupCode;
  final String groupDescription;
  final String mandatory;
  final String approval;
  final int uid;

  Grpapprover({
    required this.userGroupId,
    required this.groupCode,
    required this.groupDescription,
    required this.mandatory,
    required this.approval,
    required this.uid,
  });

  factory Grpapprover.fromJson(Map<String, dynamic> json) => Grpapprover(
        userGroupId: json["UserGroupID"] ?? 0,
        groupCode: json["Group_Code"] ?? '',
        groupDescription: json["Group_Description"] ?? '',
        mandatory: json["Mandatory"] ?? '',
        approval: json["Approval"] ?? '',
        uid: json["UID"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "UserGroupID": userGroupId,
        "Group_Code": groupCode,
        "Group_Description": groupDescription,
        "Mandatory": mandatory,
        "Approval": approval,
        "UID": uid,
      };
}

class AttachDoc {
  final String documentFileName;
  final String documentDescription;
  final String docPrivacyText;
  final String docStamp;
  final String enteredBy;
  final String fileType;
  final String? documentImg;
  final int documentPrivacy;
  final int recNum;
  final int id;
  final int hid;
  final int lineID;
  final String? groupName;
  final String? documentFile;
  final int uid;
  final String? expReceipt;
  final String? fileUrl;

  AttachDoc({
    required this.documentFileName,
    required this.documentDescription,
    required this.docPrivacyText,
    required this.docStamp,
    required this.enteredBy,
    required this.fileType,
    required this.documentPrivacy,
    required this.recNum,
    required this.id,
    required this.hid,
    required this.lineID,
    this.groupName,
    this.documentFile,
    required this.uid,
    this.expReceipt,
    this.documentImg,
    this.fileUrl,
  });

  factory AttachDoc.fromJson(Map<String, dynamic> json) => AttachDoc(
        documentFileName: json['Document_FileName'] ?? 'N/A',
        documentDescription: json['Document_Description'] ?? 'N/A',
        docPrivacyText: json['Doc_PrivacyText'] ?? 'N/A',
        docStamp: json['Doc_Stamp'] ?? 'N/A',
        enteredBy: json['EnteredBy'] ?? 'N/A',
        fileType: json['File_Type'] ?? 'N/A',
        documentPrivacy: json['Document_Privacy'] ?? 0,
        recNum: json['RecNum'] ?? 0,
        id: json['ID'] ?? 0,
        hid: json['Hid'] ?? 0,
        lineID: json['LineID'] ?? 0,
        groupName: json['GroupName'],
        documentFile: json['Document_File'],
        uid: json['UID'] ?? 0,
        expReceipt: json['Exp_Receipt'],
        documentImg: json['Document_Img'],
        fileUrl: json['File_Url'],
      );

  Map<String, dynamic> toJson() => {
        'Document_FileName': documentFileName,
        'Document_Description': documentDescription,
        'Doc_PrivacyText': docPrivacyText,
        'Doc_Stamp': docStamp,
        'EnteredBy': enteredBy,
        'File_Type': fileType,
        'Document_Privacy': documentPrivacy,
        'RecNum': recNum,
        'ID': id,
        'Hid': hid,
        'LineID': lineID,
        'GroupName': groupName,
        'Document_File': documentFile,
        'UID': uid,
        'Exp_Receipt': expReceipt,
        'Document_Img': documentImg,
        'File_Url': fileUrl,
      };
}

class Log {
  final int recNum;
  final int id;
  final int uid;
  final String eventDate;
  final String eventUser;
  final String event;

  Log({
    required this.recNum,
    required this.id,
    required this.uid,
    required this.eventDate,
    required this.eventUser,
    required this.event,
  });

  factory Log.fromJson(Map<String, dynamic> json) => Log(
        recNum: json["RecNum"] ?? 0,
        id: json["ID"] ?? 0,
        uid: json["UID"] ?? 0,
        eventDate: json["EventDate"] ?? '',
        eventUser: json["EventUser"] ?? '',
        event: json["Event"] ?? '',
      );

  Map<String, dynamic> toJson() => {
        "RecNum": recNum,
        "ID": id,
        "UID": uid,
        "EventDate": eventDate,
        "EventUser": eventUser,
        "Event": event,
      };
}
