import 'package:eyvo_v3/app/app_prefs.dart';
import 'package:eyvo_v3/core/resources/routes_manager.dart';
import 'package:eyvo_v3/main.dart';

class LogoutHelper {
  // Call ONLY for:
  // - Manual logout
  // - After user interaction when session is expired
  static void forceLogout() {
    final prefs = SharedPrefs();

    // Clear auth flags
    prefs.isLoggedIn = false;
    prefs.isSessionExpired = false;

    // Clear navigation stack and go to login
    navigatorKey.currentState?.pushNamedAndRemoveUntil(
      Routes.loginRoute,
      (route) => false,
    );
  }
}
