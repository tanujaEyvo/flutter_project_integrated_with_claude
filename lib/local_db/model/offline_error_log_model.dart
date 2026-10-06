import 'dart:convert';

class OfflineErrorLog {
  final int? id;
  final String? userId;
  final String? clientCode;
  final String? exceptionMessage;
  final String? stackTrace;
  final String? apiUrl;
  final String? requestBody;
  final String? screenName;
  final String? methodName;
  final String timestamp;
  final int synced;

  OfflineErrorLog({
    this.id,
    this.userId,
    this.clientCode,
    this.exceptionMessage,
    this.stackTrace,
    this.apiUrl,
    this.requestBody,
    this.screenName,
    this.methodName,
    required this.timestamp,
    this.synced = 0,
  });

  factory OfflineErrorLog.fromMap(Map<String, dynamic> map) {
    return OfflineErrorLog(
      id: map['id'],
      userId: map['user_id'],
      clientCode: map['client_code'],
      exceptionMessage: map['exception_message'],
      stackTrace: map['stack_trace'],
      apiUrl: map['api_url'],
      requestBody: map['request_body'],
      screenName: map['screen_name'],
      methodName: map['method_name'],
      timestamp: map['timestamp'] ?? DateTime.now().toIso8601String(),
      synced: map['synced'] ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'client_code': clientCode,
      'exception_message': exceptionMessage,
      'stack_trace': stackTrace,
      'api_url': apiUrl,
      'request_body': requestBody,
      'screen_name': screenName,
      'method_name': methodName,
      'timestamp': timestamp,
      'synced': synced,
    };
  }

  // Convert to JSON for API submission
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'clientCode': clientCode,
      'exceptionMessage': exceptionMessage,
      'stackTrace': stackTrace,
      'apiUrl': apiUrl,
      'requestBody': requestBody != null ? jsonDecode(requestBody!) : null,
      'screenName': screenName,
      'methodName': methodName,
      'timestamp': timestamp,
    };
  }
}