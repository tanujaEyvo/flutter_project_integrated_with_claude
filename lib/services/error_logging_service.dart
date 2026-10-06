import 'dart:convert';

import 'package:eyvo_v3/api/api_service/api_service.dart';
import 'package:eyvo_v3/api/response_models/api_error_log_model.dart';
import 'package:eyvo_v3/app/app_prefs.dart';
import 'package:eyvo_v3/core/resources/constants.dart';
import 'package:eyvo_v3/local_db/dao/offline_db_dao.dart';
import 'package:eyvo_v3/log_data.dart/logger_data.dart';
import 'package:flutter/material.dart';

class ErrorLoggingService {
  static final ErrorLoggingService _instance = ErrorLoggingService._internal();
  factory ErrorLoggingService() => _instance;
  ErrorLoggingService._internal();
  final clientCode = SharedPrefs().companyCode ?? 'Unknown';
  final userId = SharedPrefs().displayUserName ?? 'Unknown';
  Future<void> logApiError({
    String? exceptionMessage,
    String? stackTrace,
    String? apiUrl,
    String? requestBody,
    required String screenName,
    required String methodName,
    BuildContext? context,
  }) async {
    try {
      // Create error log with current dateTime
      final errorLog = ApiErrorLog(
        userId: userId,
        clientCode: clientCode,
        exceptionMessage: exceptionMessage,
        stackTrace: stackTrace,
        apiUrl: apiUrl,
        requestBody: requestBody,
        screenName: screenName,
        methodName: methodName,
        dateTime: DateTime.now().toIso8601String(),
        apptype: AppConstants.apptype,
      );

      // Convert to JSON for API request
      final Map<String, dynamic> data = errorLog.toJson();

      // Send to your backend API
      final apiService = ApiService();
      await apiService.postRequest(
        context!,
        ApiService.logError,
        data,
      );

      // Also log locally for debugging
      LoggerData.dataLog('=== API Error Logged ===');
      LoggerData.dataLog('User ID: $userId');
      LoggerData.dataLog('Client Code: $clientCode');
      LoggerData.dataLog('Exception: ${errorLog.exceptionMessage}');
      LoggerData.dataLog('URL: ${errorLog.apiUrl}');
      LoggerData.dataLog('Method: ${errorLog.methodName}');
      LoggerData.dataLog('Screen: ${errorLog.screenName}');
      LoggerData.dataLog('Request Body: ${errorLog.requestBody}');
      LoggerData.dataLog('DateTime: ${errorLog.dateTime}');
      LoggerData.dataLog('StackTrace: ${errorLog.stackTrace}');
      LoggerData.dataLog('========================');
    } catch (logError, logStackTrace) {
      // Fallback: Log to console if API logging fails
      LoggerData.dataLog('Failed to log error to API: $logError');
      LoggerData.dataLog('Original error: $exceptionMessage');
      LoggerData.dataLog('Original stacktrace: $stackTrace');
    }
  }

  Future<void> syncOfflineErrorLogs(BuildContext context) async {
    try {
      final dao = OfflineDBDao();
      final logs = await dao.getUnsyncedErrorLogs();

      if (logs.isEmpty) {
        LoggerData.dataLog("No offline error logs to sync");
        return;
      }

      final apiService = ApiService();

      for (final log in logs) {
        try {
          final body = {
            "userId": userId,
            "clientCode": clientCode,
            "exceptionMessage": log["exception_message"],
            "stackTrace": log["stack_trace"],
            "apiUrl": log["api_url"],
            "requestBody": log["request_body"] == null
                ? null
                : jsonDecode(log["request_body"]),
            "screenName": log["screen_name"],
            "methodName": log["method_name"],
            "dateTime": log["timestamp"],
            "apptype": AppConstants.apptype,
          };

          final response = await apiService.postRequest(
            context,
            ApiService.logError,
            body,
          );

          if (response != null) {
            await dao.markErrorLogSynced(log["id"]);
            LoggerData.dataLog("Offline error log synced: ${log["id"]}");
          }
        } catch (e, stackTrace) {
          // Log the error but DON'T use logApiError to avoid recursion
          LoggerData.dataLog(
              "Failed syncing offline error log ${log["id"]}: $e");
          LoggerData.dataLog("StackTrace: $stackTrace");

          // Optionally, you can try to log to API directly (without offline fallback)
          // but be careful to avoid recursion
          try {
            final errorBody = {
              "userId": userId,
              "clientCode": clientCode,
              "exceptionMessage": e.toString(),
              "stackTrace": stackTrace.toString(),
              "apiUrl": ApiService.syncOfflineStock,
              "requestBody": {
                "uid": SharedPrefs().uID,
                "apptype": AppConstants.apptype,
              },
              "screenName": 'error_logging_service.dart',
              "methodName": 'syncOfflineErrorLogs',
              "dateTime": DateTime.now().toIso8601String(),
              "apptype": AppConstants.apptype,
            };

            // Direct API call without offline fallback
            final apiService = ApiService();
            await apiService.postRequest(
              context,
              ApiService.logError,
              errorBody,
            );
          } catch (logError, logStackTrace) {
            // If direct API call fails, just log locally
            LoggerData.dataLog("Failed to log sync error to API: $logError");
          }
        }
      }
    } catch (e, stackTrace) {
      LoggerData.dataLog("syncOfflineErrorLogs Exception: $e");
      LoggerData.dataLog("StackTrace: $stackTrace");

      // Try to log the top-level error (again, avoid recursion)
      try {
        final errorBody = {
          "userId": userId,
          "clientCode": clientCode,
          "exceptionMessage": e.toString(),
          "stackTrace": stackTrace.toString(),
          "apiUrl": "syncOfflineErrorLogs",
          "requestBody": null,
          "screenName": 'error_logging_service.dart',
          "methodName": 'syncOfflineErrorLogs',
          "dateTime": DateTime.now().toIso8601String(),
          "apptype": AppConstants.apptype,
        };

        final apiService = ApiService();
        await apiService.postRequest(
          context,
          ApiService.logError,
          errorBody,
        );
      } catch (logError) {
        LoggerData.dataLog("Failed to log top-level sync error: $logError");
      }
    }
  }
}
