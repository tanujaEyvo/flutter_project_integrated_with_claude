import 'dart:io';

import 'package:eyvo_v3/Environment/environment.dart';
import 'package:eyvo_v3/log_data.dart/logger_data.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

class SSLError implements Exception {
  final String message;
  final String? host;
  final int? port;

  SSLError(this.message, {this.host, this.port});

  @override
  String toString() =>
      'SSLError: $message${host != null ? ' (Host: $host, Port: $port)' : ''}';
}

//-------------------------main code---------------------------------------------------------
Future<http.Client> getHttpClient() async {
  final env = Environment.current;
  LoggerData.dataLog('getHttpClient ENV = $env');

  if (env == "PROD" || env == "DEV") {
    try {
      final certificatePath = env == "PROD"
          ? 'assets/certificates/certificate_prod.pem'
          : 'assets/certificates/certificate_dev.pem';

      LoggerData.dataLog('Loading certificate: $certificatePath');

      final sslCert = await rootBundle.load(certificatePath);

      final context = SecurityContext(withTrustedRoots: true);
      context.setTrustedCertificatesBytes(
        sslCert.buffer.asUint8List(),
      );

      final client = HttpClient(context: context);

      client.connectionTimeout = const Duration(seconds: 30);

      // Don't override certificate validation unless you have a
      // very specific reason to do so.
      client.badCertificateCallback =
          (X509Certificate cert, String host, int port) {
        LoggerData.dataLog('Certificate verification failed');
        LoggerData.dataLog('Host: $host');
        LoggerData.dataLog('Subject: ${cert.subject}');
        LoggerData.dataLog('Issuer: ${cert.issuer}');

        return false; // Never accept invalid certificates in PROD/DEV
      };

      LoggerData.dataLog('SSL client created successfully');

      return IOClient(client);
    } catch (e) {
      LoggerData.dataLog('SSL setup failed: $e');
      rethrow;
    }
  }

  // Other environments
  return http.Client();
}
//------------------------------------------------------------------------------
// Future<http.Client> getHttpClient() async {
//   final env = Environment.current;
//   LoggerData.dataLog('getHttpClient ENV = $env');

//   if (env == Environment.PROD) {
//     LoggerData.dataLog('SSL PINNING ENABLED (PROD)');

//     try {
//       final sslCert = await rootBundle.load(
//         'assets/certificates/certificate_prod.pem',
//       );

//       final context = SecurityContext(withTrustedRoots: false);

//       context.setTrustedCertificatesBytes(
//         sslCert.buffer.asUint8List(),
//       );

//       final httpClient = HttpClient(context: context)
//         ..connectionTimeout = const Duration(seconds: 30);

//       return IOClient(httpClient);
//     } catch (e) {
//       LoggerData.dataLog('Critical SSL setup error: $e');
//       throw SSLError('SSL setup failed: $e');
//     }
//   }

//   // DEV / STAGING
//   LoggerData.dataLog('SSL BYPASS ENABLED (DEV/STAGING)');

//   final httpClient = HttpClient()
//     ..badCertificateCallback = (X509Certificate cert, String host, int port) {
//       LoggerData.dataLog(
//         '⚠️ SSL Certificate bypassed for Host: $host Port: $port',
//       );
//       return true;
//     }
//     ..connectionTimeout = const Duration(seconds: 30);

//   return IOClient(httpClient);
// }
