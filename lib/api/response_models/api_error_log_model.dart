// import 'package:eyvo_v3/core/resources/constants.dart';

// class ApiErrorLog {
//   final String clientCode;
//   final String userId;
//   final String? exceptionMessage;
//   final String? stackTrace;
//   final String? apiUrl;
//   final String? requestBody;
//   final String screenName;
//   final String methodName;
//   final String? dateTime;
//   final String? apptype;

//   ApiErrorLog({
//     required this.userId,
//     required this.clientCode,
//     this.exceptionMessage,
//     this.stackTrace,
//     this.apiUrl,
//     this.requestBody,
//     required this.screenName,
//     required this.methodName,
//     this.dateTime,
//     required this.apptype,
//   });

//   Map<String, dynamic> toJson() {
//     // Mask sensitive data - handle null case
//     final maskedBody =
//         requestBody != null ? _maskSensitiveData(requestBody!) : null;

//     return {
//       'userId': userId,
//       'clientCode': clientCode,
//       'exceptionMessage': exceptionMessage,
//       'stackTrace': stackTrace,
//       'apiUrl': apiUrl,
//       'requestBody': maskedBody,
//       'screenName': screenName,
//       'methodName': methodName,
//       'dateTime': DateTime.now().toIso8601String(),
//       'apptype': AppConstants.apptype,
//     };
//   }

//   Map<String, dynamic> _maskSensitiveData(Map<String, dynamic> body) {
//     final maskedBody = Map<String, dynamic>.from(body);
//     final sensitiveKeys = [
//       'password',
//       'token',
//       'key',
//       'secret',
//       'authorization',
//       'accessKey',
//       'GenericAccessKey'
//     ];

//     maskedBody.forEach((key, value) {
//       if (sensitiveKeys.any(
//           (sensitive) => key.toLowerCase().contains(sensitive.toLowerCase()))) {
//         maskedBody[key] = '***MASKED***';
//       }
//     });

//     return maskedBody;
//   }
// }
import 'package:eyvo_v3/core/resources/constants.dart';

class ApiErrorLog {
  final String clientCode;
  final String userId;
  final String? exceptionMessage;
  final String? stackTrace;
  final String? apiUrl;
  final String? requestBody;
  final String screenName;
  final String methodName;
  final String? dateTime;
  final String? apptype;

  ApiErrorLog({
    required this.userId,
    required this.clientCode,
    this.exceptionMessage,
    this.stackTrace,
    this.apiUrl,
    this.requestBody,
    required this.screenName,
    required this.methodName,
    this.dateTime,
    required this.apptype,
  });

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'clientCode': clientCode,
      'exceptionMessage': exceptionMessage,
      'stackTrace': stackTrace,
      'apiUrl': apiUrl,
      'requestBody': requestBody,
      'screenName': screenName,
      'methodName': methodName,
      'dateTime': DateTime.now().toIso8601String(),
      'apptype': AppConstants.apptype,
    };
  }
}