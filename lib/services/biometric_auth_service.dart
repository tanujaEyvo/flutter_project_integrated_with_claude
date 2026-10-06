import 'package:eyvo_v3/app/app_prefs.dart';
import 'package:eyvo_v3/log_data.dart/logger_data.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_darwin/local_auth_darwin.dart';

// ============================================================
// BIOMETRIC RESULT — typed outcome so the Login page can
// distinguish between genuine failure, cancellation, and
// system/lifecycle errors without consuming the 3-attempt counter
// for non-failure outcomes.
// ============================================================

enum BiometricResult {
  /// Face ID / Touch ID matched successfully.
  success,

  /// The biometric did not match (a real failed attempt).
  failed,

  /// User explicitly tapped "Cancel" or pressed the Home button
  /// while the system prompt was active. NOT a failed attempt.
  cancelled,

  /// The native local_auth session was interrupted by the system
  /// (e.g. app backgrounded, phone call, iOS internal error).
  /// NOT a failed attempt.
  systemError,

  /// iOS / Android device-level biometric lockout (too many OS-level
  /// attempts). The Login page should set biometricLocked directly.
  lockedOut,

  /// No biometric is enrolled or the hardware is not available.
  unavailable,
}

class BiometricAuth {
  final LocalAuthentication _localAuth = LocalAuthentication();

  /// Toggle this to enable/disable real biometric authentication.
  final bool simulateBiometrics;

  BiometricAuth({
    this.simulateBiometrics = false,
  });

  // ============================================================
  // CHECK BIOMETRIC AVAILABILITY
  // ============================================================

  /// Check if device supports biometric authentication.
  Future<bool> checkBiometrics() async {
    try {
      final canCheck = await _localAuth.canCheckBiometrics;
      LoggerData.dataLog("BIOMETRIC → canCheckBiometrics = $canCheck");
      return canCheck;
    } on PlatformException catch (e, stackTrace) {
      LoggerData.dataLog(
        "BIOMETRIC → checkBiometrics PlatformException: "
        "${e.code} - ${e.message}\n$stackTrace",
      );
      return false;
    } catch (e, stackTrace) {
      LoggerData.dataLog(
        "BIOMETRIC → checkBiometrics ERROR: $e\n$stackTrace",
      );
      return false;
    }
  }

  /// Check if device supports biometric authentication.
  Future<bool> isDeviceSupported() async {
    try {
      final isSupported = await _localAuth.isDeviceSupported();
      LoggerData.dataLog("BIOMETRIC → isDeviceSupported = $isSupported");
      return isSupported;
    } on PlatformException catch (e, stackTrace) {
      LoggerData.dataLog(
        "BIOMETRIC → isDeviceSupported PlatformException: "
        "${e.code} - ${e.message}\n$stackTrace",
      );
      return false;
    } catch (e, stackTrace) {
      LoggerData.dataLog(
        "BIOMETRIC → isDeviceSupported ERROR: $e\n$stackTrace",
      );
      return false;
    }
  }

  // ============================================================
  // AUTHENTICATION
  // ============================================================

  /// Authenticate using device biometric.
  ///
  /// Returns a [BiometricResult] so the caller can correctly route:
  ///   success     → proceed to API login
  ///   failed      → increment application fail counter
  ///   cancelled   → reset UI, do NOT increment fail counter
  ///   systemError → reset UI, do NOT increment fail counter
  ///   lockedOut   → force-lock application counter
  ///   unavailable → show full login form
  Future<BiometricResult> authenticate() async {
    if (simulateBiometrics) {
      LoggerData.dataLog("BIOMETRIC → Simulated authentication SUCCESS");
      return BiometricResult.success;
    }

    try {
      LoggerData.dataLog("BIOMETRIC → Authentication START");

      // Clear any stale native auth session left over from before the app
      // was backgrounded/killed. Without this, the first authenticate()
      // call after a long background (past mobileSessionTimeOut) can fail
      // instantly on iOS (seen on iPhone 13) because the old LAContext
      // session is still considered active; the very next call then
      // succeeds since it starts with a clean session.
      await _localAuth.stopAuthentication();

      // NOTE: Do NOT gate on canCheckBiometrics() here — right after
      // stopAuthentication() it can transiently report false (context
      // reset timing), which was wrongly routing every 2nd/3rd attempt to
      // BiometricResult.unavailable and kicking the user to the full login
      // form instead of counting it as an attempt. The authenticate() call
      // below already throws NotAvailable/NotEnrolled (caught below and
      // mapped to BiometricResult.unavailable) when biometrics are truly
      // unusable.
      final bool didAuthenticate = await _localAuth.authenticate(
        localizedReason: 'Log in using your biometric credential',
        authMessages: const [
          // Hides the native "Enter Password" fallback button on the Face
          // ID dialog. With biometricOnly: true, iOS never actually lets
          // that button proceed to passcode entry — tapping it just
          // cancels back to the app — so showing it was a confusing
          // dead end. An empty title removes it from the dialog entirely.
          IOSAuthMessages(localizedFallbackTitle: ''),
        ],
        options: const AuthenticationOptions(
          biometricOnly: true,
          useErrorDialogs: true,
          // stickyAuth: true makes the Face ID / Touch ID prompt
          // re-present itself if the app is briefly backgrounded while
          // the prompt is active (e.g. notification shade pulled down),
          // instead of silently failing and returning false.
          stickyAuth: true,
        ),
      );

      LoggerData.dataLog(
          "BIOMETRIC → authenticate() result = $didAuthenticate");

      return didAuthenticate ? BiometricResult.success : BiometricResult.failed;
    } on PlatformException catch (e, stackTrace) {
      LoggerData.dataLog(
        "BIOMETRIC → PlatformException\n"
        "Code    : ${e.code}\n"
        "Message : ${e.message}\n"
        "Details : ${e.details}\n"
        "Stack   : $stackTrace",
      );

      // ── User / system cancelled ──────────────────────────────────────
      // These must NOT increment the application fail counter.
      if (e.code == 'UserCanceled' ||
          e.code == 'user_canceled' ||
          e.code == 'canceledBySystem' ||
          e.code == 'SystemCanceled' ||
          e.code == 'system_canceled') {
        LoggerData.dataLog("BIOMETRIC → Cancelled (user or system)");
        return e.code == 'UserCanceled' || e.code == 'user_canceled'
            ? BiometricResult.cancelled
            : BiometricResult.systemError;
      }

      // ── Interrupted by app lifecycle ───────────────────────────────
      // With stickyAuth: true this is less likely, but still guard it.
      if (e.code == 'SessionExpired' ||
          e.message?.toLowerCase().contains('session') == true ||
          e.message?.toLowerCase().contains('interrupted') == true) {
        LoggerData.dataLog("BIOMETRIC → Session/lifecycle interrupted");
        return BiometricResult.systemError;
      }

      // ── Device-level lockout ─────────────────────────────────────────
      if (e.code == 'LockedOut' || e.code == 'PermanentlyLockedOut') {
        LoggerData.dataLog("BIOMETRIC → Device locked out (${e.code})");
        // Force the application lock immediately; the Login page reads
        // BiometricResult.lockedOut and sets biometricLocked = true.
        return BiometricResult.lockedOut;
      }

      // ── Not enrolled / hardware unavailable ─────────────────────────
      if (e.code == 'NotEnrolled' || e.code == 'NotAvailable') {
        LoggerData.dataLog("BIOMETRIC → Not enrolled / not available");
        return BiometricResult.unavailable;
      }

      // ── Unknown platform error ────────────────────────────────────────
      // Treat as a system error (not a real biometric failure).
      LoggerData.dataLog(
          "BIOMETRIC → Unrecognised PlatformException, treating as systemError");
      return BiometricResult.systemError;
    } catch (e, stackTrace) {
      LoggerData.dataLog(
        "BIOMETRIC → Unexpected error: $e\n"
        "Stack: $stackTrace",
      );
      return BiometricResult.systemError;
    }
  }

  // ============================================================
  // ENABLE / DISABLE BIOMETRIC
  // ============================================================

  /// Enable biometric authentication.
  Future<void> enableBiometric() async {
    final prefs = SharedPrefs.instance;
    prefs.isBiometricEnabled = true;
    prefs.biometricFailCount = 0;
    prefs.biometricLocked = false;
    LoggerData.dataLog("BIOMETRIC → Authentication ENABLED");
    LoggerData.dataLog("BIOMETRIC → Fail count RESET to 0");
  }

  /// Disable biometric authentication.
  Future<void> disableBiometric() async {
    final prefs = SharedPrefs.instance;
    prefs.isBiometricEnabled = false;
    prefs.biometricFailCount = 0;
    prefs.biometricLocked = false;
    LoggerData.dataLog("BIOMETRIC → Authentication DISABLED");
  }

  /// Check if biometric is enabled by the user.
  bool isBiometricEnabled() {
    return SharedPrefs.instance.isBiometricEnabled;
  }

  // ============================================================
  // FAILURE COUNT
  // ============================================================

  /// Get current biometric failure count.
  int getBiometricFailCount() {
    return SharedPrefs.instance.biometricFailCount;
  }

  /// Increment biometric failure count.
  /// Maximum value is 3.
  Future<void> incrementFailCount() async {
    final prefs = SharedPrefs.instance;
    int currentFailCount = prefs.biometricFailCount;

    LoggerData.dataLog("BIOMETRIC → Current fail count = $currentFailCount");

    if (currentFailCount >= 3) {
      prefs.biometricFailCount = 3;
      prefs.biometricLocked = true;
      LoggerData.dataLog("BIOMETRIC → Already LOCKED at 3 attempts");
      return;
    }

    currentFailCount++;
    prefs.biometricFailCount = currentFailCount;

    LoggerData.dataLog("BIOMETRIC → Fail count = $currentFailCount/3");

    if (currentFailCount >= 3) {
      prefs.biometricFailCount = 3;
      prefs.biometricLocked = true;
      LoggerData.dataLog("BIOMETRIC → LOCKED after 3 failed attempts");
    }
  }

  /// Force-lock the application biometric counter in a single atomic write.
  ///
  /// Used when [BiometricResult.lockedOut] is received (iOS/Android
  /// device-level lockout). Avoids calling incrementFailCount() three times,
  /// which would produce redundant SharedPrefs writes and log noise.
  Future<void> forceApplicationLock() async {
    final prefs = SharedPrefs.instance;
    prefs.biometricFailCount = 3;
    prefs.biometricLocked = true;
    LoggerData.dataLog("BIOMETRIC → Application lock FORCED (device locked out)");
  }

  /// Reset biometric failure count.
  Future<void> resetFailCount() async {
    final prefs = SharedPrefs.instance;
    prefs.biometricFailCount = 0;
    prefs.biometricLocked = false;
    LoggerData.dataLog("BIOMETRIC → Failure count RESET");
  }

  /// Check if biometric is locked.
  bool isBiometricLocked() {
    return SharedPrefs.instance.biometricLocked;
  }

  // ============================================================
  // AVAILABLE BIOMETRIC TYPES
  // ============================================================

  /// Get available biometric types.
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      final available = await _localAuth.getAvailableBiometrics();
      LoggerData.dataLog("BIOMETRIC → Available types: $available");
      return available;
    } on PlatformException catch (e, stackTrace) {
      LoggerData.dataLog(
        "BIOMETRIC → getAvailableBiometrics PlatformException: "
        "${e.code} - ${e.message}\n$stackTrace",
      );
      return [];
    } catch (e, stackTrace) {
      LoggerData.dataLog(
        "BIOMETRIC → getAvailableBiometrics ERROR: $e\n$stackTrace",
      );
      return [];
    }
  }

  // ============================================================
  // BIOMETRIC AUTH ID
  // ============================================================

  /// Store biometric authentication ID.
  Future<void> setBiometricAuthId(String value) async {
    SharedPrefs.instance.biometricAuthId = value;
    LoggerData.dataLog("BIOMETRIC → Authentication ID saved");
  }

  /// Get stored biometric authentication ID.
  String getBiometricAuthId() {
    return SharedPrefs.instance.biometricAuthId;
  }

  // ============================================================
  // LOG AVAILABLE METHODS
  // ============================================================

  /// Log available biometric methods.
  Future<void> logAvailableBiometricMethods() async {
    final available = await getAvailableBiometrics();

    if (available.contains(BiometricType.face)) {
      LoggerData.dataLog("BIOMETRIC → Face ID / Face authentication available");
    }

    if (available.contains(BiometricType.fingerprint)) {
      LoggerData.dataLog("BIOMETRIC → Fingerprint authentication available");
    }

    if (available.isEmpty) {
      LoggerData.dataLog("BIOMETRIC → No biometric methods available");
    }
  }
}
