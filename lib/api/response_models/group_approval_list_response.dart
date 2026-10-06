// To parse this JSON data, do
//
//     final welcome = welcomeFromJson(jsonString);

import 'dart:convert';

GroupApprovalListResponse groupApprovalListResponseFromJson(String str) =>
    GroupApprovalListResponse.fromJson(json.decode(str));

String groupApprovalListResponseToJson(GroupApprovalListResponse data) =>
    json.encode(data.toJson());

class GroupApprovalListResponse {
  final int code;
  final List<String> message;
  final List<GroupApproval> data;
  final int totalRecords;

  GroupApprovalListResponse({
    required this.code,
    required this.message,
    required this.data,
    required this.totalRecords,
  });

  factory GroupApprovalListResponse.fromJson(Map<String, dynamic> json) =>
      GroupApprovalListResponse(
        code: json["code"] ?? 0,
        message: json["message"] != null
            ? List<String>.from(json["message"].map((x) => x.toString()))
            : [],
        data: json["data"] != null
            ? List<GroupApproval>.from(
                json["data"].map((x) => GroupApproval.fromJson(x)))
            : [],
        totalRecords: json["totalrecords"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": List<dynamic>.from(message.map((x) => x)),
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
        "totalrecords": totalRecords,
      };
}

class GroupApproval {
  final String userName;
  final String email;
  final String telephone;
  final String extension;
  final String proxyFor;

  GroupApproval({
    required this.userName,
    required this.email,
    required this.telephone,
    required this.extension,
    required this.proxyFor,
  });

  factory GroupApproval.fromJson(Map<String, dynamic> json) => GroupApproval(
        userName: json["UserName"] ?? "",
        email: json["Email"] ?? "",
        telephone: json["Telephone"] ?? "",
        extension: json["Extension"] ?? "",
        proxyFor: json["ProxyFor"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "UserName": userName,
        "Email": email,
        "Telephone": telephone,
        "Extension": extension,
        "ProxyFor": proxyFor,
      };
}
