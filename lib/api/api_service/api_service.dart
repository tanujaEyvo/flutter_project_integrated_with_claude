// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:eyvo_v3/Environment/environment.dart';
import 'package:eyvo_v3/api/response_models/default_api_response.dart';
import 'package:eyvo_v3/api/response_models/token_response.dart';
import 'package:eyvo_v3/app/app_prefs.dart';
import 'package:eyvo_v3/core/network/ssl_http_client.dart';
import 'package:eyvo_v3/core/resources/routes_manager.dart';
import 'package:eyvo_v3/core/resources/strings_manager.dart';
import 'package:eyvo_v3/core/utils.dart';
import 'package:eyvo_v3/log_data.dart/logger_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:pdf/widgets.dart';

class ApiService {
  // static const String baseUrl = "https://service.eyvo.net/eBA API 2.0";
  static const String clientCode = "login/clientcode";
  static const String loadLogin = "login/loadlogin";
  static const String externalLogin = "login/externalaunthenication";
  static const String login = "login/checkcredential";
  static const String forgotUserID = "login/forgetuserid";
  static const String forgotPassword = "login/forgetpassword";
  static const String verifyOTP = "login/verifyotp";
  static const String resetPassword = "login/resetpassword";
  static const String changePassword = "login/changepassword";
  static const String refreshToken = "login/refreshtoken";
  static const String dashboard = "dashboard/index";
  static const String regionList = "region/index";
  static const String locationList = "location/index";
  static const String goodReceiveOrderList = 'GoodsReceive/listing';
  static const String goodReceiveItemList = 'GoodsReceive/orderitemslisting';
  static const String goodReceivePrint = 'GoodsReceive/grprint';
  static const String goodReceiveUpdate = 'GoodsReceive/updategr';
  static const String itemsListing = 'Items/listing';
  static const String itemDetails = 'Items/details';
  static const String itemsInOut = 'Items/inout';
  static const String switchboard = "switchboard/index";
  static const String orderApprovalList = "order/approvallist";
  static const String orderApprovalDetails = "order/approval";
  static const String groupApproverList = "groupapprover/list";
  static const String orderApprovalApproved = "order/approve";
  static const String orderApprovalReject = "order/reject";
  static const String requestApprovalList = "request/approvallist";
  static const String requestApprovalDetails = "request/Approval";
  static const String requestApprovalReject = "request/reject";
  static const String requestApprovalApproved = "request/approve";
  static const String blindStockListing = 'Items/blindstocklisting';
  static const String blindStockDetails = 'Items/blindstockdetails';
  static const String updateBlindStock = 'Items/updateblindstock';
  static const String inventoryManagerLocationCheck = 'location/imloctioncheck';
  static const String imageUpload = 'attachdocument/attachdocument';
  static const String createOrderHeader = 'common/getgroupdata';
  static const String itemScan = 'Items/scan';
  static const String logError = 'error/senderror';
  //================ offline DB ==================================================
  static const String saveDataInOfflineDB = 'Items/getofflinedata';
  static const String syncOfflineStock = 'Items/offline_to_online';
  //----------------------------------------------------------------------------------

  Future<bool> updateToken(BuildContext context) async {
    Map<String, dynamic> data = {
      'jwttoken': SharedPrefs().jwtToken,
      'jwtrefreshtoken': SharedPrefs().refreshToken,
    };
    final jsonResponse =
        await postRequest(context, ApiService.refreshToken, data);
    if (jsonResponse != null) {
      final response = TokenResponse.fromJson(jsonResponse);
      if (response.code == '200') {
        debugPrint('PS:- token refreshed');
        SharedPrefs().jwtToken = response.data.jwttoken;
        SharedPrefs().refreshToken = response.data.jwtrefreshtoken;
        return true;
      } else {
        debugPrint('PS:- token refresh process failed');
        Navigator.pushNamedAndRemoveUntil(
            context, Routes.loginRoute, (Route<dynamic> route) => false);
        showSnackBar(context, response.message.join(', '));
        return false;
      }
    } else {
      return false;
    }
  }

  Future<Map<String, dynamic>?> getRequest(
      BuildContext context, String endpoint, Map<String, dynamic> data) async {
    final url = Uri.encodeFull('$baseUrl/$endpoint');
    //debugPrint('PS:- URL: $url');
    final token = SharedPrefs().jwtToken;
    final headers = {
      'Content-Type': 'application/json',
      'clientcode': SharedPrefs().companyCode,
      'accessKey': SharedPrefs().accessKey,
      'Authorization': 'Bearer $token',
    };
    final body = json.encode(data);
    // debugPrint('PS:- headers: $headers');
    // debugPrint('PS:- body: $body');
    try {
      final response = await http.get(Uri.parse(url), headers: headers);
      LoggerData.dataLog("Url : $url --Header : $headers --BodyData : $body");
      return await processResponse(context, response, url);
    } catch (e) {
      LoggerData.dataLog("Url : $url Error : $e");
      //debugPrint('Get request error: $e');
      rethrow;
    }
  }

//---------------------------------------main code------------------------------------------------
  Future<Map<String, dynamic>?> postRequest(
    BuildContext context,
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    final url = Uri.parse('$baseUrl/$endpoint');
    http.Client? client;

    try {
      debugPrint('PS:- URL: $url');

      final env = Environment.current;

      // Use SSL pinning in DEV & PROD
      if (env == Environment.PROD || env == Environment.DEV) {
        client = await getHttpClient();
      }

      final token = SharedPrefs().jwtToken;

      final headers = endpoint == clientCode
          ? {
              'Content-Type': 'application/json',
              'GenericAccessKey': SharedPrefs().genericAccessKey,
            }
          : (endpoint.contains('login') && !endpoint.contains('changepassword'))
              ? {
                  'Content-Type': 'application/json',
                  'clientcode': SharedPrefs().companyCode,
                  'accessKey': SharedPrefs().accessKey,
                }
              : {
                  'Content-Type': 'application/json',
                  'clientcode': SharedPrefs().companyCode,
                  'accessKey': SharedPrefs().accessKey,
                  'Authorization': 'Bearer $token',
                };

      final body = json.encode(data);

      LoggerData.dataLog(
        'Url : $url --Header : $headers --body: $body',
      );

      /// PROD & DEV → pinned client
      /// STAGING/others → system http
      final response = (env == Environment.PROD || env == Environment.DEV)
          ? await client!
              .post(url, headers: headers, body: body)
              .timeout(const Duration(seconds: 30))
          : await http
              .post(url, headers: headers, body: body)
              .timeout(const Duration(seconds: 30));

      /// TOKEN EXPIRED HANDLING (UNCHANGED LOGIC)
      if (response.statusCode == 401) {
        if (response.body.isNotEmpty) {
          final jsonResponse =
              DefaultAPIResponse.fromJson(json.decode(response.body));
          final message = jsonResponse.message.join(', ');

          if (message == AppStrings.apiTokenExpired) {
            debugPrint('PS:- token expired called: $message');

            bool tokenRefreshed = await updateToken(context);
            if (tokenRefreshed) {
              return postRequest(context, endpoint, data);
            }
          }
        }
      }

      return await processResponse(context, response, url.toString());
    } on HandshakeException catch (e) {
      LoggerData.dataLog(' SSL HANDSHAKE FAILED: $e');
      rethrow;
    } catch (e) {
      LoggerData.dataLog(' API Error : $e');
    } finally {
      client?.close(); //close only pinned client
    }

    return null;
  }

  Future<Map<String, dynamic>?> processResponse(
      BuildContext context, http.Response response, String url) async {
    if (response.statusCode == 401) {
      if (response.body.isEmpty) {
        showSnackBar(context,
            'User is not authorized. Please login with authorized credentials.');
        return null;
      } else {
        return json.decode(response.body);
      }
    } else {
      final jsonResponse = json.decode(response.body);
      // debugPrint('PS:- jsonResponse: $jsonResponse');
      if (response.statusCode == 200 || response.statusCode == 201) {
        LoggerData.dataLog("Url : $url --Response : $jsonResponse");
        return jsonResponse;
      } else {
        if (response.body.isNotEmpty) {
          LoggerData.dataLog("Url : $url --Response : $jsonResponse");
          return jsonResponse;
        } else {
          LoggerData.dataLog(
              'Url : $url --Error: ${response.statusCode}, ${response.body}');
          throw Exception('Failed to process request: ${response.statusCode}');
        }
      }
    }
  }
  //------------------------------------------------------------------------------------------

  // Future<Map<String, dynamic>?> postRequest(
  //   BuildContext context,
  //   String endpoint,
  //   Map<String, dynamic> data,
  // ) async {
  //   final url = Uri.parse('$baseUrl/$endpoint');
  //   http.Client? client;

  //   try {
  //     debugPrint('PS:- URL: $url');

  //     client = await getHttpClient();

  //     final token = SharedPrefs().jwtToken;

  //     final headers = endpoint == clientCode
  //         ? {
  //             'Content-Type': 'application/json',
  //             'GenericAccessKey': SharedPrefs().genericAccessKey,
  //           }
  //         : (endpoint.contains('login') && !endpoint.contains('changepassword'))
  //             ? {
  //                 'Content-Type': 'application/json',
  //                 'clientcode': SharedPrefs().companyCode,
  //                 'accessKey': SharedPrefs().accessKey,
  //               }
  //             : {
  //                 'Content-Type': 'application/json',
  //                 'clientcode': SharedPrefs().companyCode,
  //                 'accessKey': SharedPrefs().accessKey,
  //                 'Authorization': 'Bearer $token',
  //               };

  //     final body = json.encode(data);

  //     LoggerData.dataLog(
  //       'Url : $url\nHeaders : $headers\nBody : $body',
  //     );

  //     final response = await client
  //         .post(
  //           url,
  //           headers: headers,
  //           body: body,
  //         )
  //         .timeout(const Duration(seconds: 30));

  //     /// Token expired handling
  //     if (response.statusCode == 401) {
  //       if (response.body.isNotEmpty) {
  //         final jsonResponse =
  //             DefaultAPIResponse.fromJson(json.decode(response.body));

  //         final message = jsonResponse.message.join(', ');

  //         if (message == AppStrings.apiTokenExpired) {
  //           LoggerData.dataLog('JWT Token Expired. Refreshing token...');

  //           bool tokenRefreshed = await updateToken(context);

  //           if (tokenRefreshed) {
  //             return postRequest(context, endpoint, data);
  //           }
  //         }
  //       }
  //     }

  //     return await processResponse(
  //       context,
  //       response,
  //       url.toString(),
  //     );
  //   } on HandshakeException catch (e) {
  //     LoggerData.dataLog('SSL Handshake Failed: $e');
  //     rethrow;
  //   } on SocketException catch (e) {
  //     LoggerData.dataLog('Network Error: $e');
  //     rethrow;
  //   } on TimeoutException catch (e) {
  //     LoggerData.dataLog('Request Timeout: $e');
  //     rethrow;
  //   } on SSLError catch (e) {
  //     LoggerData.dataLog(e.toString());
  //     rethrow;
  //   } catch (e, stackTrace) {
  //     LoggerData.dataLog('API Error: $e');
  //     LoggerData.dataLog(stackTrace.toString());
  //     return null;
  //   } finally {
  //     client?.close();
  //   }
  // }

  // Future<Map<String, dynamic>?> processResponse(
  //     BuildContext context, http.Response response, String url) async {
  //   if (response.statusCode == 401) {
  //     if (response.body.isEmpty) {
  //       showSnackBar(context,
  //           'User is not authorized. Please login with authorized credentials.');
  //       return null;
  //     } else {
  //       return json.decode(response.body);
  //     }
  //   } else {
  //     final jsonResponse = json.decode(response.body);
  //     // debugPrint('PS:- jsonResponse: $jsonResponse');
  //     if (response.statusCode == 200 || response.statusCode == 201) {
  //       LoggerData.dataLog("Url : $url --Response : $jsonResponse");
  //       return jsonResponse;
  //     } else {
  //       if (response.body.isNotEmpty) {
  //         LoggerData.dataLog("Url : $url --Response : $jsonResponse");
  //         return jsonResponse;
  //       } else {
  //         LoggerData.dataLog(
  //             'Url : $url --Error: ${response.statusCode}, ${response.body}');
  //         throw Exception('Failed to process request: ${response.statusCode}');
  //       }
  //     }
  //   }
  // }
}
