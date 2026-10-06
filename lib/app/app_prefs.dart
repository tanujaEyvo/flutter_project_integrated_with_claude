// ignore_for_file: constant_identifier_names

import "dart:convert";

import "package:eyvo_v3/core/resources/routes_manager.dart";
import "package:shared_preferences/shared_preferences.dart";

const String PREFS_GENERIC_ACCESS_KEY = "PREFS_GENERIC_ACCESS_KEY";
const String PREFS_ACCESS_KEY = "PREFS_ACCESS_KEY";
const String PREFS_KEY_COMPANYCODE = "PREFS_KEY_COMPANYCODE";
const String PREFS_KEY_USERNAME = "PREFS_KEY_USERNAME";
const String PREFS_KEY_UID = "PREFS_KEY_UID";
const String PREFS_KEY_PASSWORD = "PREFS_KEY_PASSWORD";
const String PREFS_KEY_IS_REMEMBER_ME = "PREFS_KEY_IS_REMEMBER_ME";
const String PREFS_KEY_TOKEN = "PREFS_KEY_TOKEN";
const String PREFS_KEY_REFRESH_TOKEN = "PREFS_KEY_REFRESH_TOKEN";
const String PREFS_KEY_COMPANYCODE_SCREEN = "PREFS_KEY_COMPANYCODE_SCREEN";
const String PREFS_KEY_IS_USER_LOGGED_IN = "PREFS_KEY_IS_USER_LOGGED_IN";
const String PREFS_KEY_APP_PIN = "PREFS_KEY_APP_PIN";
const String PREFS_KEY_EMAIL = "PREFS_KEY_EMAIL";
const String PREFS_KEY_SELECTED_REGION = "PREFS_KEY_SELECTED_REGION";
const String PREFS_KEY_SELECTED_REGION_ID = "PREFS_KEY_SELECTED_REGION_ID";
const String PREFS_KEY_SELECTED_LOCATION = "PREFS_KEY_SELECTED_LOCATION";
const String PREFS_KEY_SELECTED_TRIMMED_LOCATION =
    "PREFS_KEY_SELECTED_TRIMMED_LOCATION";
const String PREFS_KEY_SELECTED_LOCATION_ID = "PREFS_KEY_SELECTED_LOCATION_ID";
const String PREFS_KEY_USER_SESSION = "PREFS_KEY_USER_SESSION";
const String PREFS_KEY_DECIMAL_PLACES = "PREFS_KEY_DECIMAL_PLACES";
const String PREFS_KEY_DECIMAL_PLACES_PRICE = "PREFS_KEY_DECIMAL_PLACES_PRICE";
const String PREFS_KEY_DECIMAL_PLACES_QUANTITY =
    "PREFS_KEY_DECIMAL_PLACES_QUANTITY";
const String PREFS_KEY_IS_ITEM_SCANNED = "PREFS_KEY_IS_ITEM_SCANNED";
const String PREFS_KEY_SCANNED_REGION_ID = "PREFS_KEY_SCANNED_REGION_ID";
const String PREFS_KEY_SCANNED_LOCATION_ID = "PREFS_KEY_SCANNED_LOCATION_ID";
const String PREFS_KEY_IS_DEVELOPER_MODE = "PREFS_KEY_IS_DEVELOPER_MODE";
const String PREFS_TANENT_ID = "PREFS_TANENT_ID";
const String PREFS_CLIENT_ID = "PREFS_CLIENT_ID";
const String REDIRECT_URI = "REDIRECT_URI";
const String SSO_SESSION = "SSO_SESSION";
const String DISPLAY_USER_NAME = "DISPLAY_USER_NAME";
const String IS_LOGIN_WITH_AZURE = "IS_LOGIN_WITH_AZURE";
const String MOBILE_VERSION = "MOBILE_VERSION";
const String BIOMETRIC_AUTH_ID = "BIOMETRIC_AUTH_ID";
const String IS_BIOMATRIC_ENABLED = "IS_BIOMATRIC_ENABLED";
const String BIOMETRIC_PROMPT_SHOWKEY = "BIOMETRIC_PROMPT_SHOWKEY";
const String REQUEST_FLAG = "REQUEST_FLAG";
const String ORDER_FLAG = "ORDER_FLAG";
const String INVENTORY_FLAG = "INVENTORY_FLAG";
const String INVOICE_FLAG = "INVOICE_FLAG";
const String EXPENSE_FLAG = "EXPENSE_FLAG ";
const String REGION = "REGION ";
const String SELECT_REGIN_TITLE = "SELECT_REGIN_TITLE ";
const String SELECT_REGIN_TITLE_DASHBOARD = "SELECT_REGIN_TITLE_DASHBOARD ";
const String BLIND_STOCK_EDIT = "BLIND_STOCK_EDIT";
const String INVENTORY_MANAGER = "INVENTORY_MANAGER";
const String PREFS_KEY_OFFLINE_MODE = "PREFS_KEY_OFFLINE_MODE";
const String OFFLINE_REGION_SUB_NAME = "OFFLINE_REGION_SUB_NAME";
const String OFFLINE_REGION_LABLE_NAME = "OFFLINE_REGION_LABLE_NAME";
const String OFFLINE_REGION_ENABLED = "OFFLINE_REGION_ENABLED";
const String OFFLINE_REGION_EDITABLE = "OFFLINE_REGION_EDITABLE";

const String PREFS_SESSION_EXPIRED = "PREFS_SESSION_EXPIRED";
const String LAST_BACKGROUND_TIME = "LAST_BACKGROUND_TIME";
const String LAST_SCREEN = "LAST_SCREEN";
const String LAST_SCREEN_ARGS = "LAST_SCREEN_ARGS";
const String PREFS_KEY_LOGIN = "PREFS_KEY_LOGIN";
const String NO_LOCATION_MESSAGE = "NO_LOCATION_MESSAGE";
const String MOBILE_SESSION_TIME_OUT = "MOBILE_SESSION_TIME_OUT";
const String DEVICE_PLATFORM_KEY = "DEVICE_PLATFORM_KEY";
const String KEY_BIOMETRIC_FAIL_COUNT = "KEY_BIOMETRIC_FAIL_COUNT";
const String KEY_BIOMETRIC_LOCKED = "KEY_BIOMETRIC_LOCKED";

class SharedPrefs {
  late final SharedPreferences _sharedPrefs;

  static final SharedPrefs _instance = SharedPrefs._internal();
  factory SharedPrefs() => _instance;
  static SharedPrefs get instance => _instance;
  SharedPrefs._internal();
  Future<void> init() async {
    _sharedPrefs = await SharedPreferences.getInstance();
  }

  String get genericAccessKey =>
      _sharedPrefs.getString(PREFS_GENERIC_ACCESS_KEY) ?? "123456";

  String get accessKey => _sharedPrefs.getString(PREFS_ACCESS_KEY) ?? "";

  set accessKey(String value) {
    _sharedPrefs.setString(PREFS_ACCESS_KEY, value);
  }

  String get companyCode => _sharedPrefs.getString(PREFS_KEY_COMPANYCODE) ?? "";

  set companyCode(String value) {
    _sharedPrefs.setString(PREFS_KEY_COMPANYCODE, value);
  }

  String get username => _sharedPrefs.getString(PREFS_KEY_USERNAME) ?? "";

  set username(String value) {
    _sharedPrefs.setString(PREFS_KEY_USERNAME, value);
  }

  String get uID => _sharedPrefs.getString(PREFS_KEY_UID) ?? "";

  set uID(String value) {
    _sharedPrefs.setString(PREFS_KEY_UID, value);
  }

  String get password => _sharedPrefs.getString(PREFS_KEY_PASSWORD) ?? "";

  set password(String value) {
    _sharedPrefs.setString(PREFS_KEY_PASSWORD, value);
  }

  String get jwtToken => _sharedPrefs.getString(PREFS_KEY_TOKEN) ?? "";

  set jwtToken(String value) {
    _sharedPrefs.setString(PREFS_KEY_TOKEN, value);
  }

  String get refreshToken =>
      _sharedPrefs.getString(PREFS_KEY_REFRESH_TOKEN) ?? "";

  set refreshToken(String value) {
    _sharedPrefs.setString(PREFS_KEY_REFRESH_TOKEN, value);
  }

  String get appPIN => _sharedPrefs.getString(PREFS_KEY_APP_PIN) ?? "";

  set appPIN(String value) {
    _sharedPrefs.setString(PREFS_KEY_APP_PIN, value);
  }

  bool get isCompanyCodeScreenViewed =>
      _sharedPrefs.getBool(PREFS_KEY_COMPANYCODE_SCREEN) ?? false;

  set isCompanyCodeScreenViewed(bool value) {
    _sharedPrefs.setBool(PREFS_KEY_COMPANYCODE_SCREEN, value);
  }

  bool get isRememberMeSelected =>
      _sharedPrefs.getBool(PREFS_KEY_IS_REMEMBER_ME) ?? false;

  set isRememberMeSelected(bool value) {
    _sharedPrefs.setBool(PREFS_KEY_IS_REMEMBER_ME, value);
  }

  String get userEmail => _sharedPrefs.getString(PREFS_KEY_EMAIL) ?? "";

  set userEmail(String value) {
    _sharedPrefs.setString(PREFS_KEY_EMAIL, value);
  }

  String get selectedRegion =>
      _sharedPrefs.getString(PREFS_KEY_SELECTED_REGION) ?? "";

  set selectedRegion(String value) {
    _sharedPrefs.setString(PREFS_KEY_SELECTED_REGION, value);
  }

  int get selectedRegionID =>
      _sharedPrefs.getInt(PREFS_KEY_SELECTED_REGION_ID) ?? 0;

  set selectedRegionID(int value) {
    _sharedPrefs.setInt(PREFS_KEY_SELECTED_REGION_ID, value);
  }

  String get selectedLocation =>
      _sharedPrefs.getString(PREFS_KEY_SELECTED_LOCATION) ?? "";

  set selectedLocation(String value) {
    _sharedPrefs.setString(PREFS_KEY_SELECTED_LOCATION, value);
  }

  String get selectedTrimmedLocation =>
      _sharedPrefs.getString(PREFS_KEY_SELECTED_TRIMMED_LOCATION) ?? "";

  set selectedTrimmedLocation(String value) {
    _sharedPrefs.setString(PREFS_KEY_SELECTED_TRIMMED_LOCATION, value);
  }

  int get selectedLocationID =>
      _sharedPrefs.getInt(PREFS_KEY_SELECTED_LOCATION_ID) ?? 0;

  set selectedLocationID(int value) {
    _sharedPrefs.setInt(PREFS_KEY_SELECTED_LOCATION_ID, value);
  }

  int get decimalPlaces => _sharedPrefs.getInt(PREFS_KEY_DECIMAL_PLACES) ?? 0;

  set decimalPlaces(int value) {
    _sharedPrefs.setInt(PREFS_KEY_DECIMAL_PLACES, value);
  }

  int get decimalplacesprice =>
      _sharedPrefs.getInt(PREFS_KEY_DECIMAL_PLACES_PRICE) ?? 0;

  set decimalplacesprice(int value) {
    _sharedPrefs.setInt(PREFS_KEY_DECIMAL_PLACES_PRICE, value);
  }

  int get decimalplacesquantity =>
      _sharedPrefs.getInt(PREFS_KEY_DECIMAL_PLACES_QUANTITY) ?? 0;

  set decimalplacesquantity(int value) {
    _sharedPrefs.setInt(PREFS_KEY_DECIMAL_PLACES_QUANTITY, value);
  }

  String get userSession =>
      _sharedPrefs.getString(PREFS_KEY_USER_SESSION) ?? "";

  set userSession(String value) {
    _sharedPrefs.setString(PREFS_KEY_USER_SESSION, value);
  }

  bool get isItemScanned =>
      _sharedPrefs.getBool(PREFS_KEY_IS_ITEM_SCANNED) ?? false;

  set isItemScanned(bool value) {
    _sharedPrefs.setBool(PREFS_KEY_IS_ITEM_SCANNED, value);
  }

  int get scannedRegionID =>
      _sharedPrefs.getInt(PREFS_KEY_SCANNED_REGION_ID) ?? 0;

  set scannedRegionID(int value) {
    _sharedPrefs.setInt(PREFS_KEY_SCANNED_REGION_ID, value);
  }

  int get scannedLocationID =>
      _sharedPrefs.getInt(PREFS_KEY_SCANNED_LOCATION_ID) ?? 0;

  set scannedLocationID(int value) {
    _sharedPrefs.setInt(PREFS_KEY_SCANNED_LOCATION_ID, value);
  }

  String get tanentId => _sharedPrefs.getString(PREFS_TANENT_ID) ?? "";

  set tanentId(String value) {
    _sharedPrefs.setString(PREFS_TANENT_ID, value);
  }

  String get clientId => _sharedPrefs.getString(PREFS_CLIENT_ID) ?? "";

  set clientId(String value) {
    _sharedPrefs.setString(PREFS_CLIENT_ID, value);
  }

  String get redirectURI => _sharedPrefs.getString(REDIRECT_URI) ?? "";

  set redirectURI(String value) {
    _sharedPrefs.setString(REDIRECT_URI, value);
  }

  String get ssoSession => _sharedPrefs.getString(SSO_SESSION) ?? "";

  set ssoSession(String value) {
    _sharedPrefs.setString(SSO_SESSION, value);
  }

  String get displayUserName => _sharedPrefs.getString(DISPLAY_USER_NAME) ?? "";

  set displayUserName(String value) {
    _sharedPrefs.setString(DISPLAY_USER_NAME, value);
  }

  bool get isLoginazureAd => _sharedPrefs.getBool(IS_LOGIN_WITH_AZURE) ?? false;

  set isLoginazureAd(bool value) {
    _sharedPrefs.setBool(IS_LOGIN_WITH_AZURE, value);
  }

  String get mobileVersion => _sharedPrefs.getString(MOBILE_VERSION) ?? "";

  set mobileVersion(String value) {
    _sharedPrefs.setString(MOBILE_VERSION, value);
  }

  String get biometricAuthId => _sharedPrefs.getString(BIOMETRIC_AUTH_ID) ?? "";

  set biometricAuthId(String value) {
    _sharedPrefs.setString(BIOMETRIC_AUTH_ID, value);
  }

  bool get isBiometricEnabled =>
      _sharedPrefs.getBool(IS_BIOMATRIC_ENABLED) ?? false;

  set isBiometricEnabled(bool value) {
    _sharedPrefs.setBool(IS_BIOMATRIC_ENABLED, value);
  }

  bool get hasSeenBiometricPrompt =>
      _sharedPrefs.getBool(BIOMETRIC_PROMPT_SHOWKEY) ?? false;

  set hasSeenBiometricPrompt(bool value) =>
      _sharedPrefs.setBool(BIOMETRIC_PROMPT_SHOWKEY, value);

  bool get requestFlag => _sharedPrefs.getBool(REQUEST_FLAG) ?? false;

  set requestFlag(bool value) => _sharedPrefs.setBool(REQUEST_FLAG, value);

  bool get orderFlag => _sharedPrefs.getBool(ORDER_FLAG) ?? false;

  set orderFlag(bool value) => _sharedPrefs.setBool(ORDER_FLAG, value);

  bool get expenseFlag => _sharedPrefs.getBool(EXPENSE_FLAG) ?? false;

  set expenseFlag(bool value) => _sharedPrefs.setBool(EXPENSE_FLAG, value);

  bool get invoiceFlag => _sharedPrefs.getBool(INVOICE_FLAG) ?? false;

  set invoiceFlag(bool value) => _sharedPrefs.setBool(INVOICE_FLAG, value);

  bool get inventoryFlag => _sharedPrefs.getBool(INVENTORY_FLAG) ?? false;

  set inventoryFlag(bool value) => _sharedPrefs.setBool(INVENTORY_FLAG, value);

  bool get region => _sharedPrefs.getBool(REGION) ?? false;

  set region(bool value) => _sharedPrefs.setBool(REGION, value);

  String get selectRegionTitle =>
      _sharedPrefs.getString(SELECT_REGIN_TITLE) ?? "";

  set selectRegionTitle(String value) =>
      _sharedPrefs.setString(SELECT_REGIN_TITLE, value);

  String get selectRegionTitleSwitchboard =>
      _sharedPrefs.getString(SELECT_REGIN_TITLE_DASHBOARD) ?? "";

  set selectRegionTitleSwitchboard(String value) =>
      _sharedPrefs.setString(SELECT_REGIN_TITLE_DASHBOARD, value);

  bool get blindStockEdit => _sharedPrefs.getBool(BLIND_STOCK_EDIT) ?? false;

  set blindStockEdit(bool value) =>
      _sharedPrefs.setBool(BLIND_STOCK_EDIT, value);

  bool get inventoryManager => _sharedPrefs.getBool(INVENTORY_MANAGER) ?? false;
  set inventoryManager(bool value) =>
      _sharedPrefs.setBool(INVENTORY_MANAGER, value);

  bool get isOfflineMode =>
      _sharedPrefs.getBool(PREFS_KEY_OFFLINE_MODE) ?? false;

  set isOfflineMode(bool value) {
    _sharedPrefs.setBool(PREFS_KEY_OFFLINE_MODE, value);
  }

  String get offlineRegionLableName =>
      _sharedPrefs.getString(OFFLINE_REGION_LABLE_NAME) ?? "";

  set offlineRegionLableName(String value) {
    _sharedPrefs.setString(OFFLINE_REGION_LABLE_NAME, value);
  }

  String get offlineRegionSubName =>
      _sharedPrefs.getString(OFFLINE_REGION_SUB_NAME) ?? "";

  set offlineRegionSubName(String value) {
    _sharedPrefs.setString(OFFLINE_REGION_SUB_NAME, value);
  }

  bool get offlineRegionEnabled =>
      _sharedPrefs.getBool(OFFLINE_REGION_ENABLED) ?? false;
  set offlineRegionEnabled(bool value) =>
      _sharedPrefs.setBool(OFFLINE_REGION_ENABLED, value);
  bool get offlineRegionEditable =>
      _sharedPrefs.getBool(OFFLINE_REGION_EDITABLE) ?? false;
  set offlineRegionEditable(bool value) =>
      _sharedPrefs.setBool(OFFLINE_REGION_EDITABLE, value);
  bool get isSessionExpired =>
      _sharedPrefs.getBool(PREFS_SESSION_EXPIRED) ?? false;

  set isSessionExpired(bool value) {
    _sharedPrefs.setBool(PREFS_SESSION_EXPIRED, value);
  }

  int? get lastBackgroundTime => _sharedPrefs.getInt(LAST_BACKGROUND_TIME);

  set lastBackgroundTime(int? value) {
    if (value == null) {
      _sharedPrefs.remove(LAST_BACKGROUND_TIME);
    } else {
      _sharedPrefs.setInt(LAST_BACKGROUND_TIME, value);
    }
  }

  bool get isLoggedIn => _sharedPrefs.getBool(PREFS_KEY_LOGIN) ?? false;
  set isLoggedIn(bool value) => _sharedPrefs.setBool(PREFS_KEY_LOGIN, value);
  // Last safe screen (for OS kill)
  String get lastScreen =>
      _sharedPrefs.getString(LAST_SCREEN) ?? Routes.homeRoute;

  set lastScreen(String value) => _sharedPrefs.setString(LAST_SCREEN, value);
  Map<String, dynamic>? get lastScreenArgs {
    final jsonString = _sharedPrefs.getString(LAST_SCREEN_ARGS);
    if (jsonString == null) return null;
    return Map<String, dynamic>.from(json.decode(jsonString));
  }

  set lastScreenArgs(Map<String, dynamic>? value) {
    if (value == null) {
      _sharedPrefs.remove(LAST_SCREEN_ARGS);
    } else {
      _sharedPrefs.setString(LAST_SCREEN_ARGS, json.encode(value));
    }
  }

  String get noLocationMessage =>
      _sharedPrefs.getString(NO_LOCATION_MESSAGE) ?? "";

  set noLocationMessage(String value) =>
      _sharedPrefs.setString(NO_LOCATION_MESSAGE, value);

  int get mobileSessionTimeOut =>
      _sharedPrefs.getInt(MOBILE_SESSION_TIME_OUT) ?? 120;

  set mobileSessionTimeOut(int value) {
    _sharedPrefs.setInt(MOBILE_SESSION_TIME_OUT, value);
  }

  String get devicePlatform =>
      _sharedPrefs.getString(DEVICE_PLATFORM_KEY) ?? "";

  set devicePlatform(String value) =>
      _sharedPrefs.setString(DEVICE_PLATFORM_KEY, value);

  int get biometricFailCount =>
      _sharedPrefs.getInt(KEY_BIOMETRIC_FAIL_COUNT) ?? 0;

  set biometricFailCount(int value) {
    _sharedPrefs.setInt(KEY_BIOMETRIC_FAIL_COUNT, value);
  }

  bool get biometricLocked =>
      _sharedPrefs.getBool(KEY_BIOMETRIC_LOCKED) ?? false;

  set biometricLocked(bool value) {
    _sharedPrefs.setBool(KEY_BIOMETRIC_LOCKED, value);
  }
}
