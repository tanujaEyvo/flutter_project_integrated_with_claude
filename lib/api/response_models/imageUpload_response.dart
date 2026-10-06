import 'dart:convert';

ImageUploadResponse imageUploadResponseFromJson(String str) =>
    ImageUploadResponse.fromJson(json.decode(str));

String imageUploadResponseToJson(ImageUploadResponse data) =>
    json.encode(data.toJson());

class ImageUploadResponse {
  String code;
  List<String> message;
  Map<String, dynamic>? data;
  int totalRecords;

  ImageUploadResponse({
    required this.code,
    required this.message,
    this.data,
    required this.totalRecords,
  });

  factory ImageUploadResponse.fromJson(Map<String, dynamic> json) =>
      ImageUploadResponse(
        code: json["code"] ?? '',
        message: json["message"] != null
            ? List<String>.from(json["message"].map((x) => x.toString()))
            : [],
        data: json["data"] != null
            ? Map<String, dynamic>.from(json["data"])
            : null,
        totalRecords: json["totalrecords"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": List<dynamic>.from(message.map((x) => x)),
        "data": data,
        "totalrecords": totalRecords,
      };
}
