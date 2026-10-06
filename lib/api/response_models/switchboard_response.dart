import 'dart:convert';

SwitchboardResponse switchboardResponseFromJson(String str) =>
    SwitchboardResponse.fromJson(json.decode(str));

String switchboardResponseToJson(SwitchboardResponse data) =>
    json.encode(data.toJson());

class SwitchboardResponse {
  int code;
  List<String> message;
  SwitchboardData data;
  int totalrecords;

  SwitchboardResponse({
    required this.code,
    required this.message,
    required this.data,
    required this.totalrecords,
  });

  factory SwitchboardResponse.fromJson(Map<String, dynamic> json) =>
      SwitchboardResponse(
        code: json["code"] ?? 0,
        message: List<String>.from(json["message"] ?? []),
        data: SwitchboardData.fromJson(json["data"] ?? {}),
        totalrecords: json["totalrecords"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": message,
        "data": data.toJson(),
        "totalrecords": totalrecords,
      };
}

class SwitchboardData {
  bool request;
  bool order;
  bool expense;
  bool invoice;
  bool inventory;
  bool region;
  String? regionName;
  bool costCentreApproval;
  bool groupApproval;
  bool ruleApproval;

  SwitchboardData({
    required this.request,
    required this.order,
    required this.expense,
    required this.invoice,
    required this.inventory,
    required this.region,
    this.regionName,
    required this.costCentreApproval,
    required this.groupApproval,
    required this.ruleApproval,
  });

  factory SwitchboardData.fromJson(Map<String, dynamic> json) =>
      SwitchboardData(
        request: json["Request"] ?? false,
        order: json["Order"] ?? false,
        expense: json["Expense"] ?? false,
        invoice: json["Invoice"] ?? false,
        inventory: json["Inventory"] ?? false,
        region: json["Region"] ?? false,
        regionName: json["RegionName"] ?? "",
        costCentreApproval: json["CostCentreApproval"] ?? false,
        groupApproval: json["GroupApproval"] ?? false,
        ruleApproval: json["RuleApproval"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "Request": request,
        "Order": order,
        "Expense": expense,
        "Invoice": invoice,
        "Inventory": inventory,
        "Region": region,
        "RegionName": regionName,
        "CostCentreApproval": costCentreApproval,
        "GroupApproval": groupApproval,
        "RuleApproval": ruleApproval,
      };
}
