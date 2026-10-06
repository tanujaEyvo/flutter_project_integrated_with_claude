import 'dart:convert';

OrderResponse orderResponseFromJson(String str) =>
    OrderResponse.fromJson(json.decode(str));

String orderResponseToJson(OrderResponse data) => json.encode(data.toJson());

class OrderResponse {
  final String? code;
  final List<String>? message;
  final List<OrderData>? data;
  final int? totalRecords;

  OrderResponse({
    this.code,
    this.message,
    this.data,
    this.totalRecords,
  });

  factory OrderResponse.fromJson(Map<String, dynamic> json) {
    List<OrderData>? parsedData;

    // If data is a JSON-encoded string containing a list
    if (json["data"] is String && (json["data"] as String).isNotEmpty) {
      try {
        var decoded = jsonDecode(json["data"]);
        if (decoded is List) {
          parsedData = decoded.map((item) => OrderData.fromJson(item)).toList();
        }
      } catch (_) {
        parsedData = null;
      }
    }

    return OrderResponse(
      code: json["code"] as String?,
      message: json["message"] != null
          ? List<String>.from(
              (json["message"] as List).map((x) => x.toString()))
          : null,
      data: parsedData,
      totalRecords: json["totalrecords"] is int
          ? json["totalrecords"]
          : int.tryParse(json["totalrecords"]?.toString() ?? ""),
    );
  }

  Map<String, dynamic> toJson() => {
        "code": code,
        "message": message,
        "data": data?.map((x) => x.toJson()).toList(),
        "totalrecords": totalRecords,
      };
}

class OrderData {
  final int? orderId;
  final String? orderNumber;
  final String? orderDate;
  final String? orderStatus;
  final String? supplierName;
  final int? regionId;
  final bool? print;

  OrderData({
    this.orderId,
    this.orderNumber,
    this.orderDate,
    this.orderStatus,
    this.supplierName,
    this.regionId,
    this.print,
  });

  factory OrderData.fromJson(Map<String, dynamic> json) => OrderData(
        orderId: json["orderid"] is int
            ? json["orderid"]
            : int.tryParse(json["orderid"]?.toString() ?? ""),
        orderNumber: json["ordernumber"] as String?,
        orderDate: json["order_date"] as String?,
        orderStatus: json["order_status"] as String?,
        supplierName: json["supplier_name"] as String?,
        regionId: json["regionid"] is int
            ? json["regionid"]
            : int.tryParse(json["regionid"]?.toString() ?? ""),
        print: json["print"] is bool
            ? json["print"]
            : json["print"]?.toString().toLowerCase() == "true",
      );

  Map<String, dynamic> toJson() => {
        "orderid": orderId,
        "ordernumber": orderNumber,
        "order_date": orderDate,
        "order_status": orderStatus,
        "supplier_name": supplierName,
        "regionid": regionId,
        "print": print,
      };
}
