import 'dart:convert';

CreateHeaderResponse CreateHeaderResponseFromJson(String str) =>
    CreateHeaderResponse.fromJson(json.decode(str));

String CreateHeaderResponseToJson(CreateHeaderResponse data) =>
    json.encode(data.toJson());

class CreateHeaderResponse {
  final int code;
  final List<String> message;
  final List<Datum> data;
  final int totalrecords;

  CreateHeaderResponse({
    required this.code,
    required this.message,
    required this.data,
    required this.totalrecords,
  });

  factory CreateHeaderResponse.fromJson(Map<String, dynamic> json) =>
      CreateHeaderResponse(
        code: json["code"] ?? 0,
        message: (json["message"] as List<dynamic>?)
                ?.map((x) => x.toString())
                .toList() ??
            [],
        data: (json["data"] as List<dynamic>?)
                ?.map((x) => Datum.fromJson(x))
                .toList() ??
            [],
        totalrecords: json["totalrecords"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": message,
        "data": data.map((x) => x.toJson()).toList(),
        "totalrecords": totalrecords,
      };
}

class Datum {
  final String fieldId;
  final String labelName;
  final String id;
  final String value;
  final ControlType controlType;
  final bool required;
  final bool readWrite;
  final bool visible;

  Datum({
    required this.fieldId,
    required this.labelName,
    required this.id,
    required this.value,
    required this.controlType,
    required this.required,
    required this.readWrite,
    required this.visible,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        fieldId: json["fieldID"]?.toString() ?? "",
        labelName: json["labelName"]?.toString() ?? "",
        id: json["ID"]?.toString() ?? "",
        value: json["value"]?.toString() ?? "",
        controlType:
            controlTypeValues.map[json["controlType"]] ?? ControlType.TEXTBOX,
        required: json["required"] ?? false,
        readWrite: json["readWrite"] ?? false,
        visible: json["visible"] ?? false,
      );

  get readonly => null;

  get label => null;

  Map<String, dynamic> toJson() => {
        "fieldID": fieldId,
        "labelName": labelName,
        "ID": id,
        "value": value,
        "controlType": controlTypeValues.reverse[controlType],
        "required": required,
        "readWrite": readWrite,
        "visible": visible,
      };
}

enum ControlType { DATE, DROPDOWN, TEXTBOX }

final controlTypeValues = EnumValues({
  "date": ControlType.DATE,
  "dropdown": ControlType.DROPDOWN,
  "textbox": ControlType.TEXTBOX
});

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}

class DropdownItem {
  final String id;
  final String value;

  DropdownItem({required this.id, required this.value});

  @override
  String toString() => value;
}
