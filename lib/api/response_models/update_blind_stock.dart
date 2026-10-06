// To parse this JSON data:
//
//     final updateBlindStockResponse = updateBlindStockResponseFromJson(jsonString);

import 'dart:convert';

UpdateBlindStockResponse updateBlindStockResponseFromJson(String str) =>
    UpdateBlindStockResponse.fromJson(json.decode(str));

String updateBlindStockResponseToJson(UpdateBlindStockResponse data) =>
    json.encode(data.toJson());

class UpdateBlindStockResponse {
  final String code;
  final List<String> message;
  final String data;
  final int totalrecords;

  UpdateBlindStockResponse({
    required this.code,
    required this.message,
    required this.data,
    required this.totalrecords,
  });

  factory UpdateBlindStockResponse.fromJson(Map<String, dynamic> json) {
    return UpdateBlindStockResponse(
      code: json["code"] ?? "", // fallback to empty string
      message: json["message"] != null
          ? List<String>.from(json["message"].map((x) => x.toString()))
          : <String>[], // fallback to empty list
      data: json["data"]?.toString() ?? "", // safely convert to string
      totalrecords: json["totalrecords"] is int
          ? json["totalrecords"]
          : int.tryParse(json["totalrecords"]?.toString() ?? "0") ?? 0,
    );
  }

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": List<dynamic>.from(message.map((x) => x)),
        "data": data,
        "totalrecords": totalrecords,
      };
}
