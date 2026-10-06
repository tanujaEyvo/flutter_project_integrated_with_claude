// import 'package:eyvo_v3/app/app_prefs.dart';
// import 'package:eyvo_v3/core/resources/assets_manager.dart';
// import 'package:eyvo_v3/core/resources/routes_manager.dart';
// import 'package:eyvo_v3/core/resources/theme_manager.dart';
// import 'package:eyvo_v3/core/utils.dart';
// import 'package:eyvo_v3/log_data.dart/logger_data.dart';
// import 'package:eyvo_v3/main.dart';
// import 'package:flutter/material.dart';
// import 'package:upgrader/upgrader.dart';

// class MyApp extends StatefulWidget {
//   const MyApp._internal();

//   static const MyApp instance = MyApp._internal();
//   factory MyApp() => instance;

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
//   final Upgrader _upgrader = Upgrader(
//     debugLogging: false, // Changed to false for production
//     debugDisplayAlways: false, // Changed to false for production
//   );

//   bool _isHandlingSessionExpiry = false;

//   // Prevent showing the update dialog multiple times
//   // while the same update check is running.
//   bool _isShowingUpdateDialog = false;

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addObserver(this);

//     // Check for application update after the app/navigation has settled.
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       Future.delayed(const Duration(seconds: 3), () {
//         if (mounted) {
//           _checkForAppUpdate();
//         }
//       });
//     });
//   }

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);
//     super.dispose();
//   }

//   // --------------------------------------------------------------------------
//   // APP VERSION UPDATE
//   // --------------------------------------------------------------------------

//   Future<void> _checkForAppUpdate() async {
//     try {
//       LoggerData.dataLog(
//         "APP UPDATE → Checking for new version",
//       );

//       await _upgrader.initialize();

//       LoggerData.dataLog(
//         "APP UPDATE → Installed Version: "
//         "${_upgrader.currentInstalledVersion ?? 'null'}",
//       );

//       LoggerData.dataLog(
//         "APP UPDATE → Store Version: "
//         "${_upgrader.currentAppStoreVersion ?? 'null'}",
//       );

//       LoggerData.dataLog(
//         "APP UPDATE → Update Available: "
//         "${_upgrader.isUpdateAvailable()}",
//       );

//       if (!mounted) {
//         return;
//       }

//       // Only show dialog if update is actually available
//       if (_upgrader.isUpdateAvailable()) {
//         _showVersionUpdateDialog();
//       }
//     } catch (e, stackTrace) {
//       LoggerData.dataLog(
//         "APP UPDATE → Error while checking update: $e",
//       );

//       LoggerData.dataLog(
//         "APP UPDATE → StackTrace: $stackTrace",
//       );
//     }
//   }

//   void _showVersionUpdateDialog() {
//     if (_isShowingUpdateDialog) {
//       LoggerData.dataLog(
//         "APP UPDATE → Update dialog already showing",
//       );
//       return;
//     }

//     final navigator = navigatorKey.currentState;

//     if (navigator == null) {
//       LoggerData.dataLog(
//         "APP UPDATE → Navigator is null",
//       );
//       return;
//     }

//     final dialogContext = navigator.overlay?.context;

//     if (dialogContext == null) {
//       LoggerData.dataLog(
//         "APP UPDATE → Overlay context is null",
//       );
//       return;
//     }

//     _isShowingUpdateDialog = true;

//     LoggerData.dataLog(
//       "APP UPDATE → New version found. Showing force update dialog",
//     );

//     showImageMessageDialog(
//       context: dialogContext,
//       imageString: ImageAssets.forceUpdateApplication,
//       titleString: 'Update Required',
//       messageString: 'A new version of the app is available.\n'
//           'Please update to continue using the app.',
//       isDismissible: false,
//       preventBackPress: true,
//       onOkPressed: () async {
//         LoggerData.dataLog(
//           "APP UPDATE → User clicked OK. Opening App Store",
//         );

//         try {
//           await _upgrader.sendUserToAppStore();

//           LoggerData.dataLog(
//             "APP UPDATE → Store opened successfully",
//           );
//         } catch (e) {
//           LoggerData.dataLog(
//             "APP UPDATE → Failed to open App Store: $e",
//           );
//         }
//       },
//     );
//   }

//   // ONLY save background time
//   // @override
//   // void didChangeAppLifecycleState(AppLifecycleState state) {
//   //   if (state == AppLifecycleState.paused) {
//   //     SharedPrefs().lastBackgroundTime = DateTime.now().millisecondsSinceEpoch;
//   //   }
//   // }

//   @override
//   void didChangeAppLifecycleState(AppLifecycleState state) {
//     final prefs = SharedPrefs();

//     LoggerData.dataLog("LIFECYCLE STATE → $state");

//     // ─── BACKGROUND ────────────────────────────────────────────────────────
//     // iOS 16+ sends `hidden` before `paused`; treat both as going to background.
//     // Record the timestamp only once (the first transition), so that a rapid
//     // hidden → paused sequence does not overwrite a legitimate earlier value.
//     if (state == AppLifecycleState.paused ||
//         state == AppLifecycleState.hidden) {
//       // Only record if we don't already have an in-progress background time
//       // (prevents hidden → paused from stamping two different milliseconds).
//       if (prefs.lastBackgroundTime == null) {
//         final now = DateTime.now().millisecondsSinceEpoch;
//         prefs.lastBackgroundTime = now;
//         LoggerData.dataLog("APP BACKGROUNDED ($state) → Saved time: $now");
//       }

//       // Reset the expiry-navigation guard so the next resume evaluates freshly.
//       _isHandlingSessionExpiry = false;
//       return;
//     }

//     // ─── FOREGROUND ────────────────────────────────────────────────────────
//     if (state == AppLifecycleState.resumed) {
//       LoggerData.dataLog("APP RESUMED");

//       // ── Single-flight guard ─────────────────────────────────────────────
//       // Rapid resumed events (split-screen, notification shade, Face ID prompt)
//       // must not fire multiple pushNamedAndRemoveUntil calls.
//       if (_isHandlingSessionExpiry) {
//         LoggerData.dataLog("SESSION EXPIRY → Already handling, skipping");
//         return;
//       }

//       final lastBg = prefs.lastBackgroundTime;

//       if (lastBg == null) {
//         LoggerData.dataLog("APP RESUMED → No background timestamp, skipping");
//         return;
//       }

//       final diff = DateTime.now().difference(
//         DateTime.fromMillisecondsSinceEpoch(lastBg),
//       );

//       final timeoutMinutes = prefs.mobileSessionTimeOut;

//       LoggerData.dataLog(
//         "APP RESUMED → Background duration: ${diff.inMinutes} min, "
//         "timeout: $timeoutMinutes min",
//       );

//       if (diff.inMinutes >= timeoutMinutes) {
//         LoggerData.dataLog("SESSION EXPIRED → Initiating logout");

//         // ── Acquire guard ───────────────────────────────────────────────
//         _isHandlingSessionExpiry = true;

//         // ── Clear stale timestamp immediately ───────────────────────────
//         // This prevents a subsequent resumed event (e.g. from the iOS
//         // Face ID overlay returning) from re-triggering expiry.
//         prefs.lastBackgroundTime = null;

//         // ── Invalidate session ──────────────────────────────────────────
//         prefs.isLoggedIn = false;
//         prefs.lastScreen = "";
//         prefs.lastScreenArgs = null;

//         // ── Navigate to Login (single call) ─────────────────────────────
//         navigatorKey.currentState?.pushNamedAndRemoveUntil(
//           Routes.loginRoute,
//           (route) => false,
//         );

//         // ── Release guard after navigation stack settles ────────────────
//         // 2 s is sufficient for the navigation animation to complete;
//         // after that, fresh lifecycle events should be evaluated normally.
//         Future.delayed(const Duration(seconds: 2), () {
//           _isHandlingSessionExpiry = false;
//           LoggerData.dataLog("SESSION EXPIRY → Guard released");
//         });
//       } else {
//         // Session is still valid.  Clear the timestamp so the next
//         // background→resume cycle starts with a clean slate.
//         prefs.lastBackgroundTime = null;
//         LoggerData.dataLog("APP RESUMED → Session still valid");
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       navigatorKey: navigatorKey,
//       navigatorObservers: [routeObserver],
//       debugShowCheckedModeBanner: false,
//       onGenerateRoute: RouteGenerator.getRoute,
//       initialRoute: Routes.splashRoute,
//       theme: AppTheme.lightThemeMode,
//       builder: (context, child) {
//         final MediaQueryData data = MediaQuery.of(context);

//         return MediaQuery(
//           data: data.copyWith(
//             textScaler: const TextScaler.linear(1.0),
//           ),
//           child: child!,
//         );
//       },
//     );
//   }
// }
import 'package:eyvo_v3/app/app_prefs.dart';
import 'package:eyvo_v3/core/resources/routes_manager.dart';
import 'package:eyvo_v3/core/resources/theme_manager.dart';
import 'package:eyvo_v3/log_data.dart/logger_data.dart';
import 'package:eyvo_v3/main.dart';
import 'package:flutter/material.dart';

class MyApp extends StatefulWidget {
  const MyApp._internal();

  static const MyApp instance = MyApp._internal();
  factory MyApp() => instance;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  /// Guard: prevents multiple session-expiry navigations on rapid resume events
  /// (e.g. iOS 16+ fires `hidden` → `paused` → `resumed` in sequence).
  bool _isHandlingSessionExpiry = false;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // ONLY save background time
  // @override
  // void didChangeAppLifecycleState(AppLifecycleState state) {
  //   if (state == AppLifecycleState.paused) {
  //     SharedPrefs().lastBackgroundTime = DateTime.now().millisecondsSinceEpoch;
  //   }
  // }
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final prefs = SharedPrefs();

    LoggerData.dataLog("LIFECYCLE STATE → $state");

    // ─── BACKGROUND ────────────────────────────────────────────────────────
    // iOS 16+ sends `hidden` before `paused`; treat both as going to background.
    // Record the timestamp only once (the first transition), so that a rapid
    // hidden → paused sequence does not overwrite a legitimate earlier value.
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden) {
      // Only record if we don't already have an in-progress background time
      // (prevents hidden → paused from stamping two different milliseconds).
      if (prefs.lastBackgroundTime == null) {
        final now = DateTime.now().millisecondsSinceEpoch;
        prefs.lastBackgroundTime = now;
        LoggerData.dataLog("APP BACKGROUNDED ($state) → Saved time: $now");
      }
      // Reset the expiry-navigation guard so the next resume evaluates freshly.
      _isHandlingSessionExpiry = false;
      return;
    }

    // ─── FOREGROUND ────────────────────────────────────────────────────────
    if (state == AppLifecycleState.resumed) {
      LoggerData.dataLog("APP RESUMED");

      // ── Single-flight guard ─────────────────────────────────────────────
      // Rapid resumed events (split-screen, notification shade, Face ID prompt)
      // must not fire multiple pushNamedAndRemoveUntil calls.
      if (_isHandlingSessionExpiry) {
        LoggerData.dataLog("SESSION EXPIRY → Already handling, skipping");
        return;
      }

      final lastBg = prefs.lastBackgroundTime;

      if (lastBg == null) {
        LoggerData.dataLog("APP RESUMED → No background timestamp, skipping");
        return;
      }

      final diff = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(lastBg),
      );

      final timeoutMinutes = prefs.mobileSessionTimeOut;

      LoggerData.dataLog(
          "APP RESUMED → Background duration: ${diff.inMinutes} min, "
          "timeout: $timeoutMinutes min");

      if (diff.inMinutes >= timeoutMinutes) {
        LoggerData.dataLog("SESSION EXPIRED → Initiating logout");

        // ── Acquire guard ───────────────────────────────────────────────
        _isHandlingSessionExpiry = true;

        // ── Clear stale timestamp immediately ───────────────────────────
        // This prevents a subsequent resumed event (e.g. from the iOS
        // Face ID overlay returning) from re-triggering expiry.
        prefs.lastBackgroundTime = null;

        // ── Invalidate session ──────────────────────────────────────────
        prefs.isLoggedIn = false;
        prefs.lastScreen = "";
        prefs.lastScreenArgs = null;

        // ── Navigate to Login (single call) ─────────────────────────────
        navigatorKey.currentState?.pushNamedAndRemoveUntil(
          Routes.loginRoute,
          (route) => false,
        );

        // ── Release guard after navigation stack settles ────────────────
        // 2 s is sufficient for the navigation animation to complete;
        // after that, fresh lifecycle events should be evaluated normally.
        Future.delayed(const Duration(seconds: 2), () {
          _isHandlingSessionExpiry = false;
          LoggerData.dataLog("SESSION EXPIRY → Guard released");
        });
      } else {
        // Session is still valid.  Clear the timestamp so the next
        // background→resume cycle starts with a clean slate.
        prefs.lastBackgroundTime = null;
        LoggerData.dataLog("APP RESUMED → Session still valid");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      navigatorObservers: [routeObserver],
      debugShowCheckedModeBanner: false,
      onGenerateRoute: RouteGenerator.getRoute,
      initialRoute: Routes.splashRoute,
      theme: AppTheme.lightThemeMode,
      builder: (context, child) {
        final MediaQueryData data = MediaQuery.of(context);
        return MediaQuery(
          data: data.copyWith(
            textScaler: const TextScaler.linear(1.0),
          ),
          child: child!,
        );
      },
    );
  }
}