// To parse this JSON data, do
//
//     final SaveTerms = SaveTermsFromJson(jsonString);

import 'dart:convert';

SaveResponse saveResponseFromJson(String str) =>
    SaveResponse.fromJson(json.decode(str));

String saveResponseToJson(SaveResponse data) => json.encode(data.toJson());

class SaveResponse {
  int code;
  List<String> message;
  dynamic data;
  int totalrecords;

  SaveResponse({
    required this.code,
    required this.message,
    required this.data,
    required this.totalrecords,
  });

  factory SaveResponse.fromJson(Map<String, dynamic> json) => SaveResponse(
        code: json["code"],
        message: List<String>.from(json["message"].map((x) => x)),
        data: json["data"],
        totalrecords: json["totalrecords"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": List<dynamic>.from(message.map((x) => x)),
        "data": data,
        "totalrecords": totalrecords,
      };
}
