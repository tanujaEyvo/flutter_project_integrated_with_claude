import 'dart:convert';

OrderApprovalRejectResponse orderApprovalRejectResponseFromJson(String str) =>
    OrderApprovalRejectResponse.fromJson(json.decode(str));

String orderApprovalRejectResponseToJson(OrderApprovalRejectResponse data) =>
    json.encode(data.toJson());

class OrderApprovalRejectResponse {
  final int code;
  final List<String> message;
  final dynamic data;
  final int totalrecords;

  OrderApprovalRejectResponse({
    required this.code,
    required this.message,
    required this.data,
    required this.totalrecords,
  });

  factory OrderApprovalRejectResponse.fromJson(Map<String, dynamic> json) {
    return OrderApprovalRejectResponse(
      code: json['code'] is int ? json['code'] : 0,
      message: (json['message'] is List)
          ? List<String>.from(json['message'].whereType<String>())
          : [],
      data: json.containsKey('data') ? json['data'] : null,
      totalrecords: json['totalrecords'] is int ? json['totalrecords'] : 0,
    );
  }

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": message,
        "data": data,
        "totalrecords": totalrecords,
      };
}
