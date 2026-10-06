import 'dart:convert';

InventoryManagerCheckResponse inventoryManagerCheckResponseFromJson(
        String str) =>
    InventoryManagerCheckResponse.fromJson(json.decode(str));

String inventoryManagerCheckResponseToJson(
        InventoryManagerCheckResponse data) =>
    json.encode(data.toJson());

class InventoryManagerCheckResponse {
  String code;
  List<String> message;
  BlindStockEdit data;
  int totalrecords;

  InventoryManagerCheckResponse({
    required this.code,
    required this.message,
    required this.data,
    required this.totalrecords,
  });

  factory InventoryManagerCheckResponse.fromJson(Map<String, dynamic> json) =>
      InventoryManagerCheckResponse(
        code: json["code"],
        message: List<String>.from(json["message"].map((x) => x)),
        data: BlindStockEdit.fromJson(jsonDecode(json["data"])),
        totalrecords: json["totalrecords"],
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": List<dynamic>.from(message.map((x) => x)),
        "data": json.encode(data.toJson()),
        "totalrecords": totalrecords,
      };
}

class BlindStockEdit {
  bool blindstockedit;

  BlindStockEdit({
    required this.blindstockedit,
  });

  factory BlindStockEdit.fromJson(Map<String, dynamic> json) => BlindStockEdit(
        blindstockedit: json["blindstockedit"] ?? false,
      );

  Map<String, dynamic> toJson() => {
        "blindstockedit": blindstockedit,
      };
}
