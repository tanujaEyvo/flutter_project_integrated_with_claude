import 'package:eyvo_v3/Environment/environment.dart';
import 'package:eyvo_v3/app/app_prefs.dart';
import 'package:eyvo_v3/local_db/database_helper.dart';
import 'package:eyvo_v3/log_data.dart/logger_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:upgrader/upgrader.dart';
import 'app/app.dart';

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Force full screen on iPad
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  //Environment Setup
  const String environment =
      String.fromEnvironment("ENVIRONMENT", defaultValue: Environment.DEV);

  Environment().initConfig(environment);
  LoggerData.logEnviroment = environment;
  await SharedPrefs().init();

  //  Initialize Offline Database
  await DBHelper().db;
  // final dbHelper = DBHelper(); // Create instance
  // await dbHelper.db; // Initialize database

  // // Reset database (only for development - remove in production)
  // await dbHelper.resetDatabase();
  runApp(
    MyApp(),
  );
}
