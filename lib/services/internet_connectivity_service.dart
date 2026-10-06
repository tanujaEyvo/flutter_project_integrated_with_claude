// import 'package:connectivity_plus/connectivity_plus.dart';
// import 'package:eyvo_v3/log_data.dart/logger_data.dart';

// class Internets {
//   static Future<bool> checkInternet() async {
//     final res = await Connectivity().checkConnectivity();
//     bool online = res != ConnectivityResult.none;
//     LoggerData.dataLog("[INTERNET] Connectivity check: $res => online: $online");
//     return online;
//   }
// }


import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:eyvo_v3/log_data.dart/logger_data.dart';

class Internets {
  static Future<bool> checkInternet() async {
    final result = await Connectivity().checkConnectivity();

    final online = result.isNotEmpty &&
        !result.contains(ConnectivityResult.none);

    LoggerData.dataLog(
      "[INTERNET] Connectivity check: $result => online: $online",
    );

    return online;
  }
}