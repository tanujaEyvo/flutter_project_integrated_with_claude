import 'dart:convert';

OrderApprovalApprovedResponse orderApprovalApprovedResponseFromJson(
        String str) =>
    OrderApprovalApprovedResponse.fromJson(json.decode(str));

String orderApprovalApprovedResponseToJson(
        OrderApprovalApprovedResponse data) =>
    json.encode(data.toJson());

class OrderApprovalApprovedResponse {
  final int code;
  final String? message;
  final List<dynamic>? data;
  final int totalRecords;

  OrderApprovalApprovedResponse({
    required this.code,
    this.message,
    this.data,
    required this.totalRecords,
  });

  factory OrderApprovalApprovedResponse.fromJson(Map<String, dynamic> json) {
    return OrderApprovalApprovedResponse(
      code: json["code"] ?? 0,
      message: json["message"]?.toString(),
      data: json["data"] is List ? json["data"] : [],
      totalRecords: json["totalrecords"] ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": message,
        "data": data,
        "totalrecords": totalRecords,
      };
}
