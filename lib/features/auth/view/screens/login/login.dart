// // ignore_for_file: use_build_context_synchronously

// import 'dart:convert';
// import 'dart:io';
// import 'package:barcode_scan2/barcode_scan2.dart';
// import 'package:eyvo_v3/CommonCode/global_utils.dart';
// import 'package:eyvo_v3/api/api_service/api_service.dart';
// import 'package:eyvo_v3/api/response_models/load_login_response.dart';
// import 'package:eyvo_v3/api/response_models/login_response.dart';
// import 'package:eyvo_v3/app/app_prefs.dart';
// import 'package:eyvo_v3/app/sizes_helper.dart';
// import 'package:eyvo_v3/core/resources/assets_manager.dart';
// import 'package:eyvo_v3/core/resources/color_manager.dart';
// import 'package:eyvo_v3/core/resources/font_manager.dart';
// import 'package:eyvo_v3/core/resources/routes_manager.dart';
// import 'package:eyvo_v3/core/resources/strings_manager.dart';
// import 'package:eyvo_v3/core/resources/styles_manager.dart';
// import 'package:eyvo_v3/core/utils.dart';
// import 'package:eyvo_v3/core/widgets/alert.dart';
// import 'package:eyvo_v3/core/widgets/button.dart';
// import 'package:eyvo_v3/core/widgets/checkbox_list_tile.dart';
// import 'package:eyvo_v3/core/widgets/custom_field.dart';
// import 'package:eyvo_v3/core/widgets/dashed_line_text.dart';
// import 'package:eyvo_v3/core/widgets/header_logo.dart';
// import 'package:eyvo_v3/core/widgets/or_divider.dart';
// import 'package:eyvo_v3/core/widgets/progress_indicator.dart';
// import 'package:eyvo_v3/core/widgets/sso_web_view.dart';
// import 'package:eyvo_v3/core/widgets/text_error.dart';
// import 'package:eyvo_v3/features/auth/view/screens/company_code/company_code.dart';
// import 'package:eyvo_v3/features/auth/view/screens/dashboard/dashbord.dart';
// import 'package:eyvo_v3/log_data.dart/logger_data.dart';
// import 'package:eyvo_v3/presentation/forgot_password/forgot_password.dart';
// import 'package:eyvo_v3/presentation/forgot_user_id/forgot_user_id.dart';
// import 'package:eyvo_v3/presentation/home/home.dart';
// import 'package:eyvo_v3/services/azure_auth_service.dart';
// import 'package:eyvo_v3/services/biometric_auth_service.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:flutter_linkify/flutter_linkify.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';
// import 'package:logger/logger.dart';
// import 'package:url_launcher/url_launcher.dart';
// import 'package:http/http.dart' as http;

// class LoginViewPage extends StatefulWidget {
//   const LoginViewPage({super.key});

//   @override
//   State<LoginViewPage> createState() => _LoginViewPageState();
// }

// class _LoginViewPageState extends State<LoginViewPage> {
//   final usernameController = TextEditingController();
//   final passwordController = TextEditingController();
//   final formKey = GlobalKey<FormState>();
//   bool checkedValue = false;
//   bool isUserNameError = false;
//   bool isPasswordError = false;
//   bool isFormValidated = false;
//   bool isLoading = false;
//   bool isLoadingForScan = false;
//   bool isLoadingForAzureAD = false;
//   bool isLoginWithScan = false;
//   bool isLoginazureAd = false;
//   String ssoButtonText = '';
//   String userNameText = AppStrings.userID;
//   String passwordText = AppStrings.password;
//   String errorText = AppStrings.requiresValue;
//   final ApiService apiService = ApiService();
//   int tapCount = 0;
//   bool isLoginOptionsLoaded = false;
//   bool isBiometricPopupVisible = false;
//   bool showFullLoginForm = false;
//   final hasSeenPrompt = SharedPrefs().hasSeenBiometricPrompt;
//   bool _hasBiometricTriggered = false;
//   bool biometricAvailable = false;
//   bool biometricEnabled = false;
//   bool authFailed = false;
//   bool isAuthenticating = false;
//   bool showErrorScreen = false;
//   bool isError = false;
//   bool isVersionChange = false;
//   String versionChangedMessage = "";
//   int biometricFailCount = 0;
//   bool biometricLocked = false;
//   @override
//   // void initState() {
//   //   super.initState();
//   //   fetchLoginDetails();
//   //   saveDevicePlatform();
//   //   // LoggerData.dataLog(
//   //   //     '################ Mobile Version ${SharedPrefs().mobileVersion}');
//   //   _initBiometric();
//   //   usernameController.addListener(_onUserNameTextChange);
//   //   passwordController.addListener(_onPasswordTextChange);

//   //   usernameController.text = SharedPrefs().username;
//   //   passwordController.text = SharedPrefs().password;
//   //   checkedValue = SharedPrefs().isRememberMeSelected;
//   //   if (usernameController.text.isEmpty && passwordController.text.isEmpty) {
//   //     checkedValue = false;
//   //   }

//   //   SharedPrefs().userEmail = '';
//   // }
//   @override
//   void initState() {
//     super.initState();
//     fetchLoginDetails();
//     saveDevicePlatform();
//     _initBiometric();
//     usernameController.addListener(_onUserNameTextChange);
//     passwordController.addListener(_onPasswordTextChange);

//     checkedValue = SharedPrefs().isRememberMeSelected;

//     // ONLY load if remember me was checked
//     if (checkedValue) {
//       usernameController.text = SharedPrefs().username;
//       passwordController.text = SharedPrefs().password;
//     } else {
//       usernameController.text = '';
//       passwordController.text = '';
//       // Ensure credentials are cleared
//       // SharedPrefs().username = '';
//       // SharedPrefs().password = '';
//     }

//     SharedPrefs().userEmail = '';
//   }

//   @override
//   void dispose() {
//     usernameController.dispose();
//     passwordController.dispose();
//     super.dispose();
//     formKey.currentState?.validate();
//   }

//   Future<void> _initBiometric() async {
//     biometricAvailable = await BiometricAuth().checkBiometrics();
//     biometricEnabled = BiometricAuth().isBiometricEnabled();
//     // setState(() {});
//   }

//   void saveDevicePlatform() {
//     if (Platform.isAndroid) {
//       SharedPrefs().devicePlatform = 'Android';
//       LoggerData.dataLog('Device Platform:${SharedPrefs().devicePlatform}');
//     } else if (Platform.isIOS) {
//       SharedPrefs().devicePlatform = 'iOS';
//       LoggerData.dataLog('Device Platform:${SharedPrefs().devicePlatform}');
//     } else {
//       SharedPrefs().devicePlatform = 'Unknown';
//       LoggerData.dataLog('Device Platform:${SharedPrefs().devicePlatform}');
//     }
//   }

//   String getInitials(String displayName) {
//     if (displayName.isEmpty) return 'U'; // Default fallback

//     // Split the name by spaces and get first letter of each word
//     List<String> nameParts = displayName.trim().split(' ');
//     String initials = '';

//     for (String part in nameParts) {
//       if (part.isNotEmpty) {
//         initials += part[0].toUpperCase();
//       }
//     }

//     // If no initials found, return first character or default
//     return initials.isNotEmpty ? initials : displayName[0].toUpperCase();
//   }

//   void fetchLoginDetails() async {
//     Map<String, dynamic> data = {
//       'uid': SharedPrefs().uID,
//       'devicePlateform': SharedPrefs().devicePlatform,
//       'appVersion': SharedPrefs().mobileVersion
//     };

//     setState(() {
//       isLoginOptionsLoaded = false;
//     });

//     final jsonResponse =
//         await apiService.postRequest(context, ApiService.loadLogin, data);

//     if (jsonResponse != null) {
//       final response = LoadLoginResponse.fromJson(jsonResponse);

//       if (response.code == '200') {
//         setState(() {
//           SharedPrefs().tanentId = response.data?.tenantId ?? '';
//           SharedPrefs().clientId = response.data?.clientId ?? '';
//           SharedPrefs().redirectURI = response.data?.redirectUri ?? '';
//           SharedPrefs().ssoSession = response.data?.ssoSession ?? '';
//           SharedPrefs().mobileSessionTimeOut =
//               response.data.mobileSessionTimeOut;
//           isLoginWithScan = response.data?.isLoginWithScan ?? false;
//           // Use whichever flag matches your UI logic
//           //   LoggerData.dataLog(SharedPrefs().mobileSessionTimeOut.toString());
//           isLoginazureAd = response.data?.isSSOlogin ?? false;
//           SharedPrefs().isLoginazureAd = response.data?.isSSOlogin ?? false;

//           ssoButtonText = response.data?.ssoButtonText ?? 'Login with SSO';

//           isLoginOptionsLoaded = true;
//           isVersionChange = response.data?.versionChanged ?? false;
//           // isVersionChange = true;
//           versionChangedMessage = response.data?.versionChangedMessage ?? '';
//           // LoggerData.dataLog(
//           //     '######################################## $versionChangedMessage and $isVersionChange');

//           // If version change is true, show the popup
//           if (isVersionChange) {
//             WidgetsBinding.instance.addPostFrameCallback((_) {
//               _showVersionUpdateDialog();
//             });
//           }
//         });
//       } else if (response.code == '401') {
//         String cleanedMessage = response.message
//             .join(', ')
//             .replaceAll(RegExp(r"<[^>]*>"), '')
//             .replaceAll("mailto:", "");

//         setState(() {
//           showErrorScreen = true;
//           errorText = cleanedMessage.trim();
//           isLoginOptionsLoaded = true;
//         });
//       } else {
//         setState(() {
//           isLoginWithScan = false;
//           isLoginazureAd = false;
//           isLoginOptionsLoaded = true;
//         });
//       }
//     } else {
//       setState(() {
//         isLoginOptionsLoaded = true;
//       });
//     }
//   }

//   void _showVersionUpdateDialog() {
//     showImageMessageDialog(
//       context: context,
//       imageString: ImageAssets.forceUpdateApplication,
//       titleString: 'Update Required',
//       messageString: versionChangedMessage,
//       isDismissible: false,
//       preventBackPress: true,
//     );
//   }

//   Future<void> _onOpenLink(LinkableElement link) async {
//     final url = link.url;

//     // Handle email links
//     if (url.startsWith('mailto:')) {
//       final uri = Uri.parse(url);
//       if (await canLaunchUrl(uri)) {
//         await launchUrl(uri);
//       } else {
//         // Fallback
//         await launchUrl(Uri.parse('mailto:${url.replaceFirst('mailto:', '')}'));
//       }
//     } else {
//       // Handle normal http/https links
//       final uri = Uri.parse(url);
//       if (await canLaunchUrl(uri)) {
//         await launchUrl(uri, mode: LaunchMode.externalApplication);
//       }
//     }
//   }

//   void validateFields() {
//     if (isFormValidated) {
//       setState(() {
//         isUserNameError = usernameController.text.isEmpty;
//         isPasswordError = passwordController.text.isEmpty;
//         errorText = AppStrings.requiresValue;
//       });
//     }
//   }

//   void loginUser() async {
//     setState(() {
//       isLoading = true;
//     });
//     final username = usernameController.text.trim();
//     final password = passwordController.text.trim();

//     if (checkedValue) {
//       SharedPrefs().username = username;
//       SharedPrefs().password = password;
//     } else {
//       SharedPrefs().username = '';
//       SharedPrefs().password = '';
//     }

//     Map<String, dynamic> data = {
//       'userid': username,
//       'password': password,
//     };

//     final jsonResponse =
//         await apiService.postRequest(context, ApiService.login, data);

//     if (jsonResponse != null) {
//       final response = LoginResponse.fromJson(jsonResponse);
//       if (response.code == '200') {
//         setState(() {
//           biometricFailCount = 0;
//           biometricLocked = false;
//         });
//         // Save user data
//         SharedPrefs().displayUserName = response.data.username;
//         SharedPrefs().uID = response.data.uid;
//         SharedPrefs().jwtToken = response.data.jwttoken;
//         SharedPrefs().refreshToken = response.data.jwtrefreshtoken;
//         SharedPrefs().userSession = response.data.userSession;

//         // Save credentials for biometric login
//         SharedPrefs().username = username;
//         SharedPrefs().password = password;

//         await BiometricAuth().setBiometricAuthId(response.data.username);

//         // Check if biometrics are available but not enabled
//         if (biometricAvailable && !biometricEnabled && !hasSeenPrompt) {
//           SharedPrefs().hasSeenBiometricPrompt = true;

//           showBiometricEnableDialog(context);
//         } else {
//           navigateToScreen(context, const InverntoryView());
//         }
//       } else {
//         isPasswordError = true;
//         errorText = response.message.join(', ');
//       }
//     }

//     setState(() {
//       isLoading = false;
//     });
//   }

//   Future attemptBiometricLogin() async {
//     // Check if biometric is locked
//     if (biometricLocked) {
//       setState(() {
//         isLoading = false;
//         showFullLoginForm = true;
//       });
//       globalUtils.showNegativeSnackBar(
//           context: context,
//           message:
//               "Biometric authentication locked. Please login with password.");
//       return;
//     }

//     setState(() {
//       isLoading = true;
//     });

//     final biometricAuth = BiometricAuth();

//     // Check if biometrics are enabled
//     if (!await biometricAuth.checkBiometrics()) {
//       setState(() {
//         isLoading = false;
//       });
//       globalUtils.showNegativeSnackBar(
//           context: context, message: "Biometric authentication not set up.");
//       return;
//     }

//     // Attempt authentication
//     bool isAuthenticated = await biometricAuth.authenticate();

//     if (isAuthenticated) {
//       //  SUCCESS - Reset counter on successful biometric authentication
//       setState(() {
//         biometricFailCount = 0;
//         biometricLocked = false;
//       });

//       final username = SharedPrefs().username;
//       final password = SharedPrefs().password;

//       if (username.isNotEmpty && password.isNotEmpty) {
//         loginWithStoredCredentials(username, password);
//       } else {
//         globalUtils.showNegativeSnackBar(
//             context: context, message: "Stored credentials not found.");
//         setState(() {
//           isLoading = false;
//         });
//       }
//     } else {
//       // FAILURE - Increment counter on failed biometric attempt
//       setState(() {
//         biometricFailCount++;
//       });

//       // Check if we've reached 3 consecutive failures
//       if (biometricFailCount >= 3) {
//         setState(() {
//           biometricLocked = true;
//           isLoading = false;
//           showFullLoginForm = true;
//         });

//         // Show dialog about lock
//         _showBiometricLockedDialog();
//       } else {
//         globalUtils.showNegativeSnackBar(
//             context: context,
//             message:
//                 "Biometric authentication failed. Attempt ${biometricFailCount} of 3.");
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }

//   // Future attemptBiometricLogin() async {
//   //   setState(() {
//   //     isLoading = true;
//   //   });

//   //   final biometricAuth = BiometricAuth();

//   //   // Check if biometrics are enabled (user opted-in before)
//   //   if (!await biometricAuth.checkBiometrics()) {
//   //     setState(() {
//   //       isLoading = false;
//   //     });
//   //     globalUtils.showNegativeSnackBar(
//   //         context: context, message: "Biometric authentication not set up.");
//   //     return;
//   //   }

//   //   // Attempt authentication with either Fingerprint or Face ID
//   //   bool isAuthenticated = await biometricAuth.authenticate();

//   //   if (isAuthenticated) {
//   //     final username = SharedPrefs().username;
//   //     final password = SharedPrefs().password;

//   //     if (username.isNotEmpty && password.isNotEmpty) {
//   //       loginWithStoredCredentials(username, password);
//   //     } else {
//   //       globalUtils.showNegativeSnackBar(
//   //           context: context, message: "Stored credentials not found.");
//   //       setState(() {
//   //         isLoading = false;
//   //       });
//   //     }
//   //   } else {
//   //     globalUtils.showNegativeSnackBar(
//   //         context: context, message: "Biometric authentication failed.");
//   //     setState(() {
//   //       isLoading = false;
//   //     });
//   //   }
//   // }

//   // void loginWithStoredCredentials(String username, String password) async {
//   //   setState(() {
//   //     isLoading = true;
//   //   });

//   //   Map<String, dynamic> data = {
//   //     'userid': username,
//   //     'password': password,
//   //   };

//   //   final jsonResponse =
//   //       await apiService.postRequest(context, ApiService.login, data);

//   //   if (jsonResponse != null) {
//   //     final response = LoginResponse.fromJson(jsonResponse);
//   //     if (response.code == '200') {
//   //       SharedPrefs().displayUserName = response.data.username;
//   //       SharedPrefs().uID = response.data.uid;
//   //       SharedPrefs().jwtToken = response.data.jwttoken;
//   //       SharedPrefs().refreshToken = response.data.jwtrefreshtoken;
//   //       SharedPrefs().userSession = response.data.userSession;
//   //       navigateToScreen(context, const InverntoryView());
//   //       // Slight delay to allow loader to show (optional)
//   //       await Future.delayed(const Duration(milliseconds: 200));
//   //     } else {
//   //       globalUtils.showNegativeSnackBar(
//   //           context: context, message: response.message.join(', '));
//   //     }
//   //   }

//   //   setState(() {
//   //     isLoading = false;
//   //   });
//   // }

//   void loginWithStoredCredentials(String username, String password) async {
//     setState(() {
//       isLoading = true;
//     });

//     Map<String, dynamic> data = {
//       'userid': username,
//       'password': password,
//     };

//     final jsonResponse =
//         await apiService.postRequest(context, ApiService.login, data);

//     if (jsonResponse != null) {
//       final response = LoginResponse.fromJson(jsonResponse);
//       if (response.code == '200') {
//         //  SUCCESSFUL API LOGIN - Reset biometric counter
//         setState(() {
//           biometricFailCount = 0;
//           biometricLocked = false;
//         });

//         SharedPrefs().displayUserName = response.data.username;
//         SharedPrefs().uID = response.data.uid;
//         SharedPrefs().jwtToken = response.data.jwttoken;
//         SharedPrefs().refreshToken = response.data.jwtrefreshtoken;
//         SharedPrefs().userSession = response.data.userSession;
//         navigateToScreen(context, const InverntoryView());
//         await Future.delayed(const Duration(milliseconds: 200));
//       } else {
//         //  API LOGIN FAILED - DO NOT reset biometric counter
//         // Keep the existing failure count
//         globalUtils.showNegativeSnackBar(
//             context: context, message: response.message.join(', '));

//         // Check if we should lock after API failure
//         setState(() {
//           biometricFailCount++;
//         });

//         if (biometricFailCount >= 3) {
//           setState(() {
//             biometricLocked = true;
//             showFullLoginForm = true;
//           });
//           _showBiometricLockedDialog();
//         }
//       }
//     } else {
//       //  API CALL FAILED (no response) - DO NOT reset biometric counter
//       globalUtils.showNegativeSnackBar(
//           context: context, message: "Login failed. Please try again.");

//       setState(() {
//         biometricFailCount++;
//       });

//       if (biometricFailCount >= 3) {
//         setState(() {
//           biometricLocked = true;
//           showFullLoginForm = true;
//         });
//         _showBiometricLockedDialog();
//       }
//     }

//     setState(() {
//       isLoading = false;
//     });
//   }

//   void _showBiometricLockedDialog() {
//     showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (BuildContext context) {
//         return CustomImageActionAlert(
//           iconString: '',
//           imageString: ImageAssets
//               .biometricEnableDialogImage, // You might want a different image
//           titleString: 'Biometric Locked',
//           subTitleString:
//               'Biometric authentication has been locked after 3 failed attempts. Please login with your username and password.',
//           destructiveActionString: 'OK',
//           normalActionString: '',
//           onDestructiveActionTap: () {
//             Navigator.pop(context);
//           },
//           onNormalActionTap: () {},
//         );
//       },
//     );
//   }

//   void clearCompanyCode() {
//     SharedPrefs().companyCode = '';
//     SharedPrefs().username = '';
//     SharedPrefs().password = '';
//     Navigator.pushNamedAndRemoveUntil(
//         context, Routes.companyCodeRoute, (Route<dynamic> route) => false);
//   }

//   void showClearCompanyCodeDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return CustomImageActionAlert(
//             iconString: '',
//             imageString: ImageAssets.clearCompanyCodeImage,
//             titleString: AppStrings.clearCompanyCodeTitle,
//             subTitleString: AppStrings.clearCompanyCodeSubTitle,
//             destructiveActionString: AppStrings.yes,
//             normalActionString: AppStrings.no,
//             onDestructiveActionTap: () {
//               clearCompanyCode();
//             },
//             onNormalActionTap: () {
//               Navigator.pop(context);
//             });
//       },
//     );
//   }

//   void showBiometricEnableDialog(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext dialogContext) {
//         return CustomImageActionAlert(
//           iconString: '',
//           imageString: ImageAssets.biometricEnableDialogImage,
//           titleString: 'Quick Login with Biometrics',
//           subTitleString:
//               'Do you want to enable biometric authentication for quicker logins in the future?',
//           destructiveActionString: AppStrings.yes,
//           normalActionString: AppStrings.no,
//           onDestructiveActionTap: () async {
//             Navigator.pop(dialogContext);
//             await BiometricAuth().enableBiometric();
//             navigateToScreen(context, const InverntoryView());
//           },
//           onNormalActionTap: () {
//             Navigator.pop(dialogContext);
//             navigateToScreen(context, const InverntoryView());
//           },
//         );
//       },
//     );
//   }

//   void _onUserNameTextChange() {
//     if (userNameText != AppStrings.userID) {
//       setState(() {
//         isUserNameError = usernameController.text.trim().isEmpty;
//       });
//     }
//     userNameText = usernameController.text.trim();
//   }

//   void _onPasswordTextChange() {
//     if (passwordText != AppStrings.password) {
//       setState(() {
//         isPasswordError = passwordController.text.trim().isEmpty;
//       });
//     }
//     passwordText = passwordController.text.trim();
//     errorText = AppStrings.requiresValue;
//   }

//   Future<void> scanBarcode() async {
//     try {
//       ScanResult barcodeScanResult = await BarcodeScanner.scan();
//       String resultString = barcodeScanResult.rawContent;
//       if (resultString.isNotEmpty && resultString != "-1") {
//         Map<String, dynamic> jsonDict = jsonDecode(resultString);
//         loginWithScan(jsonDict['uid']);
//       }
//     } catch (e) {
//       setState(() {
//         errorText = "Failed to scan";
//       });
//     }
//   }

//   void loginWithScan(int userId) async {
//     SharedPrefs().username = '';
//     SharedPrefs().password = '';
//     setState(() {
//       isLoadingForScan = true;
//     });

//     Map<String, dynamic> data = {
//       'uid': '$userId',
//       'mode': 'scan',
//     };
//     final jsonResponse =
//         await apiService.postRequest(context, ApiService.externalLogin, data);

//     if (jsonResponse != null) {
//       final response = LoginResponse.fromJson(jsonResponse);
//       setState(() {
//         if (response.code == '200') {
//           SharedPrefs().displayUserName = response.data.username;
//           SharedPrefs().uID = response.data.uid;
//           SharedPrefs().jwtToken = response.data.jwttoken;
//           SharedPrefs().refreshToken = response.data.jwtrefreshtoken;
//           SharedPrefs().userSession = response.data.userSession;
//           navigateToScreen(context, const InverntoryView());
//         } else {
//           isPasswordError = true;
//           errorText = response.message.join(', ');
//         }
//       });
//     }
//     setState(() {
//       isLoadingForScan = false;
//     });
//   }

//   void loginWithAzureAD() async {
//     setState(() {
//       isLoadingForAzureAD = true;
//       debugPrint("isLoadingForAzureAD: $isLoadingForAzureAD");
//     });

//     final token = await AzureAuthService.login();

//     if (token != null) {
//       debugPrint("Login Success. Token: $token");
//       if (mounted) {
//         await fetchAzureUserDetails(token);
//       }
//     } else {
//       if (mounted) {
//         globalUtils.showNegativeSnackBar(
//             context: context, message: "Azure login failed");
//       }
//     }

//     setState(() {
//       isLoadingForAzureAD = false;
//       debugPrint("isLoadingForAzureAD: $isLoadingForAzureAD");
//     });
//   }

//   Future<void> fetchAzureUserDetails(String token) async {
//     Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
//     //  debugPrint("########################################################");
//     //debugPrint(decodedToken.toString());
//     // debugPrint("########################################################");

//     String? email = decodedToken["unique_name"]; // "email"
//     // String? email = "abc@eyvo.com";
//     if (email != null) {
//       loginWithAsureSSO(email); // here’s where you pass the email
//     } else {
//       debugPrint("No email found in token.");
//       if (mounted) {
//         globalUtils.showNegativeSnackBar(
//             context: context, message: "No email found in Azure token");
//       }
//     }
//   }

//   void loginWithAsureSSO(String email) async {
//     debugPrint("Starting SSO login with email: $email");
//     SharedPrefs().username = '';
//     SharedPrefs().password = '';
//     setState(() {
//       isLoadingForScan = true;
//     });

//     Map<String, dynamic> data = {
//       'email': email,
//       'mode': 'sso',
//     };

//     final jsonResponse =
//         await apiService.postRequest(context, ApiService.externalLogin, data);

//     debugPrint("Raw response: $jsonResponse");

//     if (jsonResponse != null) {
//       final response = LoginResponse.fromJson(jsonResponse);

//       if (response.code == '200') {
//         debugPrint(" SSO Login successful for UID: ${response.data.uid}");
//         SharedPrefs().displayUserName = response.data.username;
//         SharedPrefs().uID = response.data.uid;
//         SharedPrefs().jwtToken = response.data.jwttoken;
//         SharedPrefs().refreshToken = response.data.jwtrefreshtoken;
//         SharedPrefs().userSession = response.data.userSession;
//         // debugPrint(
//         //     " ###############################: ${response.data.username}");
//         navigateToScreen(context, const InverntoryView());
//       } else {
//         //Show proper message from backend
//         setState(() {
//           isPasswordError = true;
//           errorText = response.message.join(', ');
//         });
//         debugPrint(" Login failed: $errorText");

//         if (mounted) {
//           globalUtils.showNegativeSnackBar(
//               context: context, message: "SSO Login failed: $errorText");
//         }
//       }
//     } else {
//       debugPrint(" No response from server.");
//       if (mounted) {
//         globalUtils.showNegativeSnackBar(
//             context: context, message: "No response from login server");
//       }
//     }

//     setState(() {
//       isLoadingForScan = false;
//     });
//   }

//   Widget buildLoginAndPasswordBlock(BuildContext context) {
//     return Column(
//       children: [
//         // Forgot User ID
//         SizedBox(
//           width: displayWidth(context),
//           child: Row(
//             children: [
//               const Spacer(),
//               CustomTextButton(
//                 buttonText: AppStrings.forgotUserID,
//                 onTap: () {
//                   navigateToScreen(
//                     context,
//                     const ForgotUserIDView(),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),

//         // User ID
//         CustomTextField(
//           iconString: ImageAssets.userIdIcon,
//           hintText: AppStrings.userID,
//           controller: usernameController,
//           isValid: !isUserNameError,
//           onTextChanged: validateFields,
//         ),

//         isUserNameError ? const ErrorTextViewBox() : const SizedBox(),

//         isUserNameError ? const SizedBox(height: 20) : const SizedBox(),

//         // Forgot Password
//         SizedBox(
//           width: displayWidth(context),
//           child: Row(
//             children: [
//               const Spacer(),
//               CustomTextButton(
//                 buttonText: AppStrings.forgotPassword,
//                 onTap: () {
//                   navigateToScreen(
//                     context,
//                     const ForgotPasswordView(),
//                   );
//                 },
//               ),
//             ],
//           ),
//         ),

//         // Password
//         CustomTextField(
//           iconString: ImageAssets.passwordIcon,
//           hintText: AppStrings.password,
//           controller: passwordController,
//           isObscureText: true,
//           isValid: !isPasswordError,
//           onTextChanged: validateFields,
//         ),

//         isPasswordError
//             ? ErrorTextViewBox(titleString: errorText)
//             : const SizedBox(),

//         isPasswordError ? const SizedBox(height: 20) : const SizedBox(),

//         // Remember Me
//         CustomCheckboxListTile(
//           title: Text(
//             AppStrings.rememberMe,
//             style: getRegularStyle(
//               color: ColorManager.lightGrey1,
//               fontSize: FontSize.s18,
//             ),
//           ),
//           value: checkedValue,
//           onChanged: (value) {
//             setState(() {
//               checkedValue = value!;
//               SharedPrefs().isRememberMeSelected = checkedValue;
//             });
//           },
//         ),

//         const SizedBox(height: 50),

//         // Sign In Button
//         isLoading
//             ? const CustomProgressIndicator()
//             : CustomButton(
//                 buttonText: AppStrings.signIn,
//                 onTap: () {
//                   isFormValidated = true;
//                   validateFields();

//                   if (!isUserNameError && !isPasswordError) {
//                     loginUser();
//                   }
//                 },
//                 height: 50,
//               ),
//       ],
//     );
//   }

//   Widget buildBiometricLoginBlock(BuildContext context) {
//     debugPrint('''
// Biometric Status:
// - biometricAvailable: $biometricAvailable
// - biometricEnabled: $biometricEnabled
// - biometricLocked: $biometricLocked
// - showFullLoginForm: $showFullLoginForm
// - Condition Result: ${biometricAvailable && biometricEnabled && !biometricLocked && !showFullLoginForm}
// ''');
//     return Column(
//       children: [
//         SizedBox(
//           height: 20,
//         ),
//         SizedBox(
//           width: double.infinity,
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.start,
//             children: [
//               Container(
//                 width: 65,
//                 height: 65,
//                 decoration: BoxDecoration(
//                   color: ColorManager.welcomcircleBackgroundColor,
//                   shape: BoxShape.circle,
//                   border: Border.all(
//                     color: ColorManager.white,
//                     width: 2.0,
//                   ),
//                 ),
//                 alignment: Alignment.center,
//                 child: Text(
//                   getInitials(SharedPrefs().displayUserName),
//                   style: getBoldStyle(
//                     color: ColorManager.darkBlue,
//                     fontSize: FontSize.s21,
//                   ),
//                 ),
//               ),
//               const SizedBox(width: 20),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Welcome Back,',
//                     style: getRegularStyle(
//                       color: ColorManager.grey,
//                       fontSize: FontSize.s18,
//                     ),
//                   ),
//                   const SizedBox(height: 5),
//                   Text(
//                     SharedPrefs().displayUserName,
//                     style: getBoldStyle(
//                       color: ColorManager.black,
//                       fontSize: FontSize.s25_5,
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 50),
//         Container(
//           width: double.infinity,
//           padding: const EdgeInsets.symmetric(
//             vertical: 25,
//           ),
//           decoration: BoxDecoration(
//             color: ColorManager.fingerPrintBackgroundColor,
//             border: Border.all(
//               color: ColorManager.darkBlue.withOpacity(0.20),
//               width: 1,
//             ),
//             borderRadius: BorderRadius.circular(15),
//           ),
//           child: Column(
//             children: [
//               Padding(
//                 padding: const EdgeInsets.only(
//                   left: 30,
//                   right: 30,
//                 ),
//                 child: isAuthenticating
//                     ? const Center(
//                         child: CustomProgressIndicator(),
//                       )
//                     : Center(
//                         child: GestureDetector(
//                           onTap: () async {
//                             setState(() {
//                               isAuthenticating = true;
//                               authFailed = false;
//                             });

//                             try {
//                               final success =
//                                   await BiometricAuth().authenticate();

//                               if (context.mounted && success == true) {
//                                 setState(() {
//                                   biometricFailCount = 0;
//                                   biometricLocked = false;
//                                 });

//                                 navigateToScreen(
//                                   context,
//                                   const InverntoryView(),
//                                 );
//                               } else {
//                                 setState(() {
//                                   biometricFailCount++;
//                                 });

//                                 if (biometricFailCount >= 3) {
//                                   setState(() {
//                                     biometricLocked = true;
//                                     isAuthenticating = false;
//                                     showFullLoginForm = true;
//                                   });

//                                   _showBiometricLockedDialog();
//                                 } else {
//                                   setState(() {
//                                     isAuthenticating = false;
//                                     authFailed = true;
//                                   });
//                                 }
//                               }
//                             } catch (e) {
//                               setState(() {
//                                 biometricFailCount++;
//                                 authFailed = true;
//                                 isAuthenticating = false;
//                               });

//                               if (biometricFailCount >= 3) {
//                                 setState(() {
//                                   biometricLocked = true;
//                                   showFullLoginForm = true;
//                                 });

//                                 _showBiometricLockedDialog();
//                               }
//                             }
//                           },
//                           child: Container(
//                             width: 55,
//                             height: 55,
//                             decoration: BoxDecoration(
//                               color: ColorManager.white,
//                               shape: BoxShape.circle,
//                               border: Border.all(
//                                 color: biometricLocked
//                                     ? ColorManager.red
//                                     : ColorManager.darkBlue.withOpacity(0.20),
//                                 width: 1,
//                               ),
//                             ),
//                             child: Icon(
//                               biometricLocked ? Icons.lock : Icons.fingerprint,
//                               size: 40,
//                               color: biometricLocked
//                                   ? ColorManager.red
//                                   : ColorManager.darkBlue,
//                             ),
//                           ),
//                         ),
//                       ),
//               ),
//               const SizedBox(height: 20),
//               Text(
//                 'Use Fingerprint/Face Id',
//                 style: getRegularStyle(
//                   color: ColorManager.lightGrey3,
//                   fontSize: FontSize.s16,
//                 ),
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 50),
//       ],
//     );
//   }

//   Widget buildCompanyCodeRow(BuildContext context) {
//     return SizedBox(
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Text(
//             AppStrings.companyCodeDetail,
//             style: getRegularStyle(
//               color: ColorManager.black,
//               fontSize: FontSize.s22_5,
//             ),
//           ),
//           GestureDetector(
//             onTap: () {
//               showClearCompanyCodeDialog(context);
//             },
//             child: Padding(
//               padding: const EdgeInsets.only(top: 8),
//               child: DashedLineText(
//                 titleString: SharedPrefs().companyCode,
//                 titleStyle: getDottedUnderlineSemiBoldStyle(
//                   color: ColorManager.orange,
//                   lineColor: ColorManager.lightGrey1,
//                   fontSize: FontSize.s22_5,
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     // if (isLoginOptionsLoaded && !_hasBiometricTriggered) {
//     //   WidgetsBinding.instance.addPostFrameCallback((_) {
//     //     _hasBiometricTriggered = true;
//     //     if (BiometricAuth().isBiometricEnabled()) {
//     //       attemptBiometricLogin();
//     //     } else {
//     //       setState(() {
//     //         showFullLoginForm = true;
//     //       });
//     //     }
//     //   });
//     // }
//     // bool isPageVisible = ModalRoute.of(context)?.isCurrent ?? false;

//     // if (isLoginOptionsLoaded &&
//     //     !_hasBiometricTriggered &&
//     //     BiometricAuth().isBiometricEnabled() &&
//     //     isPageVisible) {
//     //   // Only trigger if page is visible
//     //   WidgetsBinding.instance.addPostFrameCallback((_) {
//     //     _hasBiometricTriggered = true;
//     //     attemptBiometricLogin();
//     //   });
//     // }

//     //  else {
//     //   setState(() {
//     //     showFullLoginForm = true;
//     //   });
//     // }
//     bool isPageVisible = ModalRoute.of(context)?.isCurrent ?? false;

//     if (isLoginOptionsLoaded &&
//         !_hasBiometricTriggered &&
//         BiometricAuth().isBiometricEnabled() &&
//         isPageVisible &&
//         !biometricLocked &&
//         !showFullLoginForm) {
//       WidgetsBinding.instance.addPostFrameCallback((_) {
//         _hasBiometricTriggered = true;
//         attemptBiometricLogin();
//       });
//     } else if (isLoginOptionsLoaded && !_hasBiometricTriggered) {
//       // If biometric is NOT enabled, show full login form
//       if (!BiometricAuth().isBiometricEnabled()) {
//         setState(() {
//           showFullLoginForm = true;
//         });
//       }
//       // If biometric IS enabled but we're locked, show full login form
//       else if (biometricLocked) {
//         setState(() {
//           showFullLoginForm = true;
//         });
//       }
//       // Mark as triggered to prevent retriggering
//       _hasBiometricTriggered = true;
//     }

//     // Still show a loader if login options aren't ready
//     if (!isLoginOptionsLoaded) {
//       return Scaffold(
//         backgroundColor: ColorManager.white,
//         body: const Center(child: CustomProgressIndicator()),
//       );
//     }

//     return Scaffold(
//       backgroundColor: ColorManager.white,
//       body: PopScope(
//         canPop: false,
//         onPopInvokedWithResult: (didPop, result) => {SystemNavigator.pop()},
//         child: GestureDetector(
//           onTap: onScreenTapped,
//           child: SingleChildScrollView(
//             padding: EdgeInsets.only(
//                 bottom: MediaQuery.of(context).viewInsets.bottom),
//             child: Column(
//               children: [
//                 const HeaderLogo(),
//                 const SizedBox(height: 20),
//                 _buildLoginForm(),
//                 const SizedBox(height: 10),
//                 if (biometricAvailable &&
//                     biometricEnabled &&
//                     !showErrorScreen &&
//                     showFullLoginForm)
//                   Padding(
//                     padding: const EdgeInsets.only(left: 30, right: 30),
//                     child: isAuthenticating
//                         ? const Center(child: CustomProgressIndicator())
//                         : Center(
//                             child: GestureDetector(
//                               onTap: () async {
//                                 setState(() {
//                                   isAuthenticating = true;
//                                   authFailed = false;
//                                 });

//                                 try {
//                                   final success =
//                                       await BiometricAuth().authenticate();
//                                   if (context.mounted && success == true) {
//                                     navigateToScreen(
//                                         context, const InverntoryView());
//                                   } else {
//                                     setState(() {
//                                       isAuthenticating = false;
//                                       authFailed = true;
//                                     });
//                                   }
//                                 } catch (e) {
//                                   setState(() {
//                                     authFailed = true;
//                                     isAuthenticating = false;
//                                   });
//                                 }
//                               },
//                               child: Container(
//                                 width: 55,
//                                 height: 55,
//                                 decoration: BoxDecoration(
//                                   color: ColorManager.white,
//                                   shape: BoxShape.circle,
//                                   border: Border.all(
//                                       color: ColorManager.darkBlue, width: 1),
//                                 ),
//                                 child: Icon(Icons.fingerprint,
//                                     size: 40, color: ColorManager.darkBlue),
//                               ),
//                             ),
//                           ),
//                   ),
//                 // if (biometricAvailable &&
//                 //     biometricEnabled &&
//                 //     !showErrorScreen &&
//                 //     !biometricLocked)
//                 //   Padding(
//                 //     padding: const EdgeInsets.only(left: 30, right: 30),
//                 //     child: isAuthenticating
//                 //         ? const Center(child: CustomProgressIndicator())
//                 //         : Center(
//                 //             child: GestureDetector(
//                 //               onTap: () async {
//                 //                 setState(() {
//                 //                   isAuthenticating = true;
//                 //                   authFailed = false;
//                 //                 });

//                 //                 try {
//                 //                   final success =
//                 //                       await BiometricAuth().authenticate();
//                 //                   if (context.mounted && success == true) {
//                 //                     // ✅ Biometric success - Reset counter
//                 //                     setState(() {
//                 //                       biometricFailCount = 0;
//                 //                       biometricLocked = false;
//                 //                     });
//                 //                     navigateToScreen(
//                 //                         context, const InverntoryView());
//                 //                   } else {
//                 //                     // ❌ Biometric failure - Increment counter
//                 //                     setState(() {
//                 //                       biometricFailCount++;
//                 //                     });

//                 //                     if (biometricFailCount >= 3) {
//                 //                       setState(() {
//                 //                         biometricLocked = true;
//                 //                         isAuthenticating = false;
//                 //                         showFullLoginForm = true;
//                 //                       });
//                 //                       _showBiometricLockedDialog();
//                 //                     } else {
//                 //                       setState(() {
//                 //                         isAuthenticating = false;
//                 //                         authFailed = true;
//                 //                       });
//                 //                     }
//                 //                   }
//                 //                 } catch (e) {
//                 //                   // ❌ Error - Increment counter
//                 //                   setState(() {
//                 //                     biometricFailCount++;
//                 //                     authFailed = true;
//                 //                     isAuthenticating = false;
//                 //                   });

//                 //                   if (biometricFailCount >= 3) {
//                 //                     setState(() {
//                 //                       biometricLocked = true;
//                 //                       showFullLoginForm = true;
//                 //                     });
//                 //                     _showBiometricLockedDialog();
//                 //                   }
//                 //                 }
//                 //               },
//                 //               child: Container(
//                 //                 width: 55,
//                 //                 height: 55,
//                 //                 decoration: BoxDecoration(
//                 //                   color: ColorManager.white,
//                 //                   shape: BoxShape.circle,
//                 //                   border: Border.all(
//                 //                       color: biometricLocked
//                 //                           ? ColorManager.red
//                 //                           : ColorManager.darkBlue,
//                 //                       width: 1),
//                 //                 ),
//                 //                 child: Icon(
//                 //                   biometricLocked
//                 //                       ? Icons.lock
//                 //                       : Icons.fingerprint,
//                 //                   size: 40,
//                 //                   color: biometricLocked
//                 //                       ? ColorManager.red
//                 //                       : ColorManager.darkBlue,
//                 //                 ),
//                 //               ),
//                 //             ),
//                 //           ),
//                 //   ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }

// // Method to handle the screen tap and count the number of taps
//   void onScreenTapped() {
//     setState(() {
//       tapCount++;
//       if (tapCount >= 5) {
//         isLoginazureAd = false;
//       }
//     });
//   }

//   Widget _buildLoginForm() {
//     return Padding(
//       padding: const EdgeInsets.only(left: 30, right: 30),
//       child: SizedBox(
//         child: showErrorScreen
//             // === 401 ERROR SCREEN ===
//             ? Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   const SizedBox(height: 40),
//                   buildCompanyCodeRow(context),
//                   const SizedBox(height: 40),
//                   Image.asset(
//                     ImageAssets.errorMessageIcon,
//                     width: displayWidth(context) * 0.5,
//                   ),
//                   Padding(
//                     padding: const EdgeInsets.symmetric(
//                         horizontal: 30, vertical: 20),
//                     child: Linkify(
//                       onOpen: _onOpenLink,
//                       text: errorText,
//                       textAlign: TextAlign.center,
//                       style: getRegularStyle(
//                         color: ColorManager.lightGrey,
//                         fontSize: FontSize.s17,
//                       ),
//                       linkStyle: const TextStyle(
//                         color: Colors.blue,
//                         decoration: TextDecoration.underline,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 40),
//                   SizedBox(
//                     width: displayWidth(context) * 0.95,
//                     child: CustomButton(
//                       buttonText: "Back",
//                       onTap: () {
//                         Navigator.pushNamedAndRemoveUntil(
//                             context,
//                             Routes.companyCodeRoute,
//                             (Route<dynamic> route) => false);
//                         setState(() {
//                           showErrorScreen = false;
//                           isError = false;
//                           errorText = "";
//                         });
//                       },
//                     ),
//                   ),
//                   const SizedBox(height: 30),
//                 ],
//               )

//             // === NORMAL LOGIN FORM ===
//             : Column(
//                 mainAxisAlignment: MainAxisAlignment.start,
//                 children: [
//                   const SizedBox(height: 40),
//                   // Logic to conditionally show/hide the login form based on isLoginazureAd and tap count
//                   // (isLoginazureAd && tapCount < 5)
//                   //     ? Column(
//                   //         children: [
//                   //           const SizedBox(height: 140),
//                   //           buildCompanyCodeRow(context),
//                   //           const SizedBox(height: 40),
//                   //           CustomButton(
//                   //             buttonText: "Login with URBN SSO",
//                   //             leading: SizedBox(
//                   //               width: 30,
//                   //               height: 30,
//                   //               child: Image.asset(ImageAssets.ssoIcon),
//                   //             ),
//                   //             onTap: loginWithAzureAD,
//                   //             isDefault: true,
//                   //           ),
//                   //         ],
//                   //       )
//                   //     :
//                   Column(
//                     children: [
//                       buildCompanyCodeRow(context),
//                       const SizedBox(height: 20),
//                       // buildLoginAndPasswordBlock(context),
//                       //  buildBiometricLoginBlock(context),
//                       (biometricAvailable &&
//                               biometricEnabled &&
//                               !biometricLocked &&
//                               !showFullLoginForm)
//                           ? buildBiometricLoginBlock(context)
//                           : buildLoginAndPasswordBlock(context),
//                       const SizedBox(height: 20),
//                       // Logic to check if loginWithScan is true
//                       isLoginWithScan
//                           ? const SizedBox(height: 10)
//                           : const SizedBox(),
//                       //const OrDivider(),
//                       isLoginWithScan
//                           ? Column(
//                               children: [
//                                 const OrDivider(),
//                                 const SizedBox(height: 20),
//                                 isLoadingForScan
//                                     ? const CustomProgressIndicator()
//                                     : CustomButton(
//                                         buttonText: AppStrings.loginWithBarcode,
//                                         onTap: () {
//                                           scanBarcode();
//                                         },
//                                         isDefault: true),
//                                 const SizedBox(height: 30),
//                               ],
//                             )
//                           : const SizedBox(),
//                       isLoginazureAd
//                           ? CustomButton(
//                               buttonText: ssoButtonText,
//                               leading: SizedBox(
//                                 width: 20,
//                                 height: 20,
//                                 child: Image.asset(ImageAssets.ssoIcon),
//                               ),
//                               onTap: () {
//                                 Navigator.push(
//                                   context,
//                                   MaterialPageRoute(
//                                     builder: (_) => const SSOWebViewScreen(),
//                                   ),
//                                 );
//                               },
//                               isDefault: true,
//                               height: 50,
//                             )
//                           : const SizedBox(),
//                       const SizedBox(height: 10),
//                       if (biometricAvailable &&
//                           biometricEnabled &&
//                           !biometricLocked &&
//                           !showFullLoginForm)
//                         GestureDetector(
//                           onTap: () {
//                             setState(() {
//                               showFullLoginForm = true;
//                             });
//                           },
//                           child: Column(
//                             children: [
//                               const Divider(),
//                               const SizedBox(height: 10),
//                               Text(
//                                 'Sign In with User Id',
//                                 style: getBoldStyle(
//                                   color: ColorManager.darkBlue,
//                                   fontSize: FontSize.s14,
//                                 ),
//                               ),
//                             ],
//                           ),
//                         ),
//                     ],
//                   ),

//                   const SizedBox(height: 20),
//                 ],
//               ),
//       ),
//     );
//   }
// }

// login_view.dart
// ignore_for_file: use_build_context_synchronously

import 'dart:convert';
import 'dart:io';
import 'package:barcode_scan2/barcode_scan2.dart';
import 'package:eyvo_v3/CommonCode/global_utils.dart';
import 'package:eyvo_v3/api/api_service/api_service.dart';
import 'package:eyvo_v3/api/response_models/load_login_response.dart';
import 'package:eyvo_v3/api/response_models/login_response.dart';
import 'package:eyvo_v3/app/app_prefs.dart';
import 'package:eyvo_v3/app/sizes_helper.dart';
import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/routes_manager.dart';
import 'package:eyvo_v3/core/resources/strings_manager.dart';
import 'package:eyvo_v3/core/resources/styles_manager.dart';
import 'package:eyvo_v3/core/utils.dart';
import 'package:eyvo_v3/core/widgets/alert.dart';
import 'package:eyvo_v3/core/widgets/button.dart';
import 'package:eyvo_v3/core/widgets/checkbox_list_tile.dart';
import 'package:eyvo_v3/core/widgets/custom_field.dart';
import 'package:eyvo_v3/core/widgets/dashed_line_text.dart';
import 'package:eyvo_v3/core/widgets/header_logo.dart';
import 'package:eyvo_v3/core/widgets/or_divider.dart';
import 'package:eyvo_v3/core/widgets/progress_indicator.dart';
import 'package:eyvo_v3/core/widgets/sso_web_view.dart';
import 'package:eyvo_v3/core/widgets/text_error.dart';
import 'package:eyvo_v3/features/auth/view/screens/company_code/company_code.dart';
import 'package:eyvo_v3/features/auth/view/screens/dashboard/dashbord.dart';
import 'package:eyvo_v3/log_data.dart/logger_data.dart';
import 'package:eyvo_v3/presentation/forgot_password/forgot_password.dart';
import 'package:eyvo_v3/presentation/forgot_user_id/forgot_user_id.dart';
import 'package:eyvo_v3/presentation/home/home.dart';
import 'package:eyvo_v3/services/azure_auth_service.dart';
import 'package:eyvo_v3/services/biometric_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:url_launcher/url_launcher.dart';

class LoginViewPage extends StatefulWidget {
  const LoginViewPage({super.key});

  @override
  State<LoginViewPage> createState() => _LoginViewPageState();
}

class _LoginViewPageState extends State<LoginViewPage> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  bool checkedValue = false;
  bool isUserNameError = false;
  bool isPasswordError = false;
  bool isFormValidated = false;
  bool isLoading = false;
  bool isLoadingForScan = false;
  bool isLoadingForAzureAD = false;
  bool isLoginWithScan = false;
  bool isLoginazureAd = false;
  String ssoButtonText = '';
  String userNameText = AppStrings.userID;
  String passwordText = AppStrings.password;
  String errorText = AppStrings.requiresValue;
  final ApiService apiService = ApiService();
  int tapCount = 0;
  bool isLoginOptionsLoaded = false;
  bool showFullLoginForm = false;
  // bool _hasBiometricTriggered = false;
  bool biometricAvailable = false;
  bool biometricEnabled = false;
  bool isAuthenticating = false;
  bool showErrorScreen = false;
  bool isError = false;
  bool isVersionChange = false;
  String versionChangedMessage = "";

  // Fixed: Using SharedPrefs for persistent state
  int get biometricFailCount => SharedPrefs().biometricFailCount;
  bool get biometricLocked => SharedPrefs().biometricLocked;

  // Track if we're currently processing to prevent duplicate calls
  bool _isProcessingBiometric = false;
  bool _isNavigating = false;

// Prevent biometric from automatically starting again
// after app comes back from background.
//   bool _appWasInBackground = false;

// // Prevent build() from automatically triggering biometric
// // more than once.
//   bool _initialBiometricTriggered = false;

  @override
  void initState() {
    super.initState();
    // NOTE: WidgetsBindingObserver is intentionally NOT registered here.
    // MyApp (_MyAppState) is the sole lifecycle owner and session-timeout
    // handler. Dual registration was the root cause of the 3-4 h biometric
    // failure bug on iOS.

    fetchLoginDetails();
    saveDevicePlatform();
    _initBiometric();
    usernameController.addListener(_onUserNameTextChange);
    passwordController.addListener(_onPasswordTextChange);

    checkedValue = SharedPrefs().isRememberMeSelected;

    if (checkedValue) {
      usernameController.text = SharedPrefs().username;
      passwordController.text = SharedPrefs().password;
    } else {
      usernameController.text = '';
      passwordController.text = '';
    }

    SharedPrefs().userEmail = '';
  }

  @override
  void dispose() {
    // NOTE: removeObserver is intentionally absent — this page never
    // calls addObserver (see initState comment above).
    usernameController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  // didChangeAppLifecycleState is intentionally NOT implemented here.
  //
  // Rationale: having both MyApp and LoginViewPage observe lifecycle events
  // creates two independent state machines that conflict with each other
  // when the session expires after 3-4 h of background time:
  //
  //   1. MyApp detects timeout → navigates to login route.
  //   2. Login page observer fires simultaneously → resets isAuthenticating /
  //      _isProcessingBiometric and may override showFullLoginForm,
  //      leaving UI and native local_auth in an inconsistent state.
  //
  // MyApp is now the single source of truth for lifecycle / session handling.
  // The Login page only manages its own UI state in response to explicit
  // user interactions (tapping Face ID, typing credentials, etc.).

//   Future<void> _initBiometric() async {
//     final auth = BiometricAuth();
//     biometricAvailable = await auth.checkBiometrics();
//     biometricEnabled = auth.isBiometricEnabled();

//     // Check if biometric is locked
//     if (auth.isBiometricLocked()) {
//       LoggerData.dataLog("Biometric is locked, showing full login form");
//       setState(() {
//         showFullLoginForm = true;
//       });
//     }

//     LoggerData.dataLog('''
// Biometric Status:
// - available: $biometricAvailable
// - enabled: $biometricEnabled
// - locked: ${auth.isBiometricLocked()}
// - failCount: ${auth.getBiometricFailCount()}
// ''');
//   }
  Future<void> _initBiometric() async {
    final auth = BiometricAuth();

    // Always read fresh state from SharedPrefs
    final available = await auth.checkBiometrics();
    final enabled = auth.isBiometricEnabled();
    final locked = auth.isBiometricLocked();
    final failCount = auth.getBiometricFailCount();

    LoggerData.dataLog('''
BIOMETRIC INIT
available = $available
enabled = $enabled
locked = $locked
failCount = $failCount
''');

    if (!mounted) return;

    setState(() {
      biometricAvailable = available;
      biometricEnabled = enabled;

      // Show full login form if biometric is not available, not enabled, locked, or in offline mode
      if (!available ||
          !enabled ||
          locked ||
          SharedPrefs.instance.isOfflineMode) {
        showFullLoginForm = true;
      } else {
        // Show biometric screen but DO NOT auto-authenticate
        showFullLoginForm = false;
      }
    });
  }

  void saveDevicePlatform() {
    if (Platform.isAndroid) {
      SharedPrefs().devicePlatform = 'Android';
    } else if (Platform.isIOS) {
      SharedPrefs().devicePlatform = 'iOS';
    } else {
      SharedPrefs().devicePlatform = 'Unknown';
    }
    LoggerData.dataLog('Device Platform: ${SharedPrefs().devicePlatform}');
  }

  String getInitials(String displayName) {
    if (displayName.isEmpty) return 'U';
    List<String> nameParts = displayName.trim().split(' ');
    String initials = '';
    for (String part in nameParts) {
      if (part.isNotEmpty) {
        initials += part[0].toUpperCase();
      }
    }
    return initials.isNotEmpty ? initials : displayName[0].toUpperCase();
  }

  void fetchLoginDetails() async {
    Map<String, dynamic> data = {
      'uid': SharedPrefs().uID,
      'devicePlateform': SharedPrefs().devicePlatform,
      'appVersion': SharedPrefs().mobileVersion
    };

    setState(() {
      isLoginOptionsLoaded = false;
    });

    final jsonResponse =
        await apiService.postRequest(context, ApiService.loadLogin, data);

    if (jsonResponse != null) {
      final response = LoadLoginResponse.fromJson(jsonResponse);

      if (response.code == '200') {
        setState(() {
          SharedPrefs().tanentId = response.data?.tenantId ?? '';
          SharedPrefs().clientId = response.data?.clientId ?? '';
          SharedPrefs().redirectURI = response.data?.redirectUri ?? '';
          SharedPrefs().ssoSession = response.data?.ssoSession ?? '';
          SharedPrefs().mobileSessionTimeOut =
              response.data.mobileSessionTimeOut;
          isLoginWithScan = response.data?.isLoginWithScan ?? false;
          isLoginazureAd = response.data?.isSSOlogin ?? false;
          SharedPrefs().isLoginazureAd = response.data?.isSSOlogin ?? false;
          ssoButtonText = response.data?.ssoButtonText ?? 'Login with SSO';
          isLoginOptionsLoaded = true;
          isVersionChange = response.data?.versionChanged ?? false;
          versionChangedMessage = response.data?.versionChangedMessage ?? '';

          if (isVersionChange) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showVersionUpdateDialog();
            });
          }
        });
      } else if (response.code == '401') {
        String cleanedMessage = response.message
            .join(', ')
            .replaceAll(RegExp(r"<[^>]*>"), '')
            .replaceAll("mailto:", "");

        setState(() {
          showErrorScreen = true;
          errorText = cleanedMessage.trim();
          isLoginOptionsLoaded = true;
        });
      } else {
        setState(() {
          isLoginWithScan = false;
          isLoginazureAd = false;
          isLoginOptionsLoaded = true;
        });
      }
    } else {
      setState(() {
        isLoginOptionsLoaded = true;
      });
    }
  }

  void _showVersionUpdateDialog() {
    showImageMessageDialog(
      context: context,
      imageString: ImageAssets.forceUpdateApplication,
      titleString: 'Update Required',
      messageString: versionChangedMessage,
      isDismissible: false,
      preventBackPress: true,
    );
  }

  Future<void> _onOpenLink(LinkableElement link) async {
    final url = link.url;
    if (url.startsWith('mailto:')) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        await launchUrl(Uri.parse('mailto:${url.replaceFirst('mailto:', '')}'));
      }
    } else {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  void validateFields() {
    if (isFormValidated) {
      setState(() {
        isUserNameError = usernameController.text.isEmpty;
        isPasswordError = passwordController.text.isEmpty;
        errorText = AppStrings.requiresValue;
      });
    }
  }

  void loginUser() async {
    setState(() {
      isLoading = true;
    });
    final username = usernameController.text.trim();
    final password = passwordController.text.trim();

    if (checkedValue) {
      SharedPrefs().username = username;
      SharedPrefs().password = password;
    } else {
      SharedPrefs().username = '';
      SharedPrefs().password = '';
    }

    Map<String, dynamic> data = {
      'userid': username,
      'password': password,
    };

    final jsonResponse =
        await apiService.postRequest(context, ApiService.login, data);

    if (jsonResponse != null) {
      final response = LoginResponse.fromJson(jsonResponse);
      if (response.code == '200') {
        // FIXED: Reset biometric state on successful login
        await BiometricAuth().resetFailCount();

        SharedPrefs().displayUserName = response.data.username;
        SharedPrefs().uID = response.data.uid;
        SharedPrefs().jwtToken = response.data.jwttoken;
        SharedPrefs().refreshToken = response.data.jwtrefreshtoken;
        SharedPrefs().userSession = response.data.userSession;

        SharedPrefs().username = username;
        SharedPrefs().password = password;

        await BiometricAuth().setBiometricAuthId(response.data.username);

        // Check if biometrics are available but not enabled
        if (biometricAvailable &&
            !biometricEnabled &&
            !SharedPrefs().hasSeenBiometricPrompt) {
          SharedPrefs().hasSeenBiometricPrompt = true;
          showBiometricEnableDialog(context);
        } else {
          _navigateToHome();
        }
      } else {
        isPasswordError = true;
        errorText = response.message.join(', ');
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  // FIXED: Separate navigation to prevent duplicate calls
  void _navigateToHome() {
    if (_isNavigating) return;
    _isNavigating = true;
    // Use pushAndRemoveUntil (not the shared navigateToScreen push helper)
    // so this Login screen, and any earlier InverntoryView instance still
    // sitting underneath from a previous login, are fully removed. Leaving
    // them in the stack let an old dashboard's in-flight network calls
    // survive and later crash trying to setState() on a disposed screen.
    Navigator.of(context).pushAndRemoveUntil(
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const InverntoryView(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return child;
        },
      ),
      (route) => false,
    );
    // Reset after navigation
    Future.delayed(const Duration(seconds: 1), () {
      _isNavigating = false;
    });
  }

  // FIXED: Biometric login with proper state management
  // Future<void> attemptBiometricLogin() async {
  //   // Never start biometric while app is not active.
  //   if (isVersionChange) {
  //     LoggerData.dataLog(
  //       "BIOMETRIC → Blocked because version update is required",
  //     );
  //     return;
  //   }
  //   if (_appWasInBackground) {
  //     LoggerData.dataLog(
  //       "BIOMETRIC → App was in background, ignoring request",
  //     );
  //     return;
  //   }

  //   // Prevent duplicate authentication calls.
  //   if (_isProcessingBiometric || _isNavigating) {
  //     LoggerData.dataLog(
  //       "BIOMETRIC → Already processing, skipping",
  //     );
  //     return;
  //   }

  //   if (!mounted) return;

  //   final prefs = SharedPrefs();

  //   final bool isLocked = prefs.biometricLocked;
  //   final int failCount = prefs.biometricFailCount;

  //   LoggerData.dataLog(
  //     "BIOMETRIC START → "
  //     "locked=$isLocked, "
  //     "failCount=$failCount",
  //   );

  //   // Already locked
  //   if (isLocked || failCount >= 3) {
  //     LoggerData.dataLog(
  //       "BIOMETRIC → Already locked",
  //     );

  //     if (mounted) {
  //       setState(() {
  //         showFullLoginForm = true;
  //         isAuthenticating = false;
  //         _isProcessingBiometric = false;
  //       });
  //     }

  //     return;
  //   }

  //   if (!biometricAvailable || !biometricEnabled) {
  //     if (mounted) {
  //       setState(() {
  //         showFullLoginForm = true;
  //         isAuthenticating = false;
  //         _isProcessingBiometric = false;
  //       });
  //     }

  //     return;
  //   }

  //   if (prefs.isOfflineMode) {
  //     if (mounted) {
  //       setState(() {
  //         showFullLoginForm = true;
  //         isAuthenticating = false;
  //         _isProcessingBiometric = false;
  //       });
  //     }

  //     return;
  //   }

  //   _isProcessingBiometric = true;

  //   if (mounted) {
  //     setState(() {
  //       isAuthenticating = true;
  //     });
  //   }

  //   try {
  //     final biometricAuth = BiometricAuth();

  //     final canCheck = await biometricAuth.checkBiometrics();

  //     if (!canCheck) {
  //       if (!mounted) return;

  //       setState(() {
  //         isAuthenticating = false;
  //         showFullLoginForm = true;
  //         _isProcessingBiometric = false;
  //       });

  //       return;
  //     }

  //     LoggerData.dataLog(
  //       "BIOMETRIC → Starting authenticate()",
  //     );

  //     final bool isAuthenticated = await biometricAuth.authenticate();

  //     LoggerData.dataLog(
  //       "BIOMETRIC → authenticate result = $isAuthenticated",
  //     );

  //     if (isAuthenticated) {
  //       LoggerData.dataLog(
  //         "BIOMETRIC → SUCCESS",
  //       );

  //       await biometricAuth.resetFailCount();

  //       _hasBiometricTriggered = true;

  //       final username = prefs.username;
  //       final password = prefs.password;

  //       if (username.isNotEmpty && password.isNotEmpty) {
  //         await loginWithStoredCredentials(
  //           username,
  //           password,
  //         );
  //       } else {
  //         if (!mounted) return;

  //         setState(() {
  //           isAuthenticating = false;
  //           showFullLoginForm = true;
  //           _isProcessingBiometric = false;
  //         });

  //         globalUtils.showNegativeSnackBar(
  //           context: context,
  //           message: "Stored credentials not found.",
  //         );
  //       }

  //       return;
  //     }

  //     // ------------------------------------------------
  //     // BIOMETRIC FAILED
  //     // ------------------------------------------------

  //     LoggerData.dataLog(
  //       "BIOMETRIC → Authentication failed",
  //     );

  //     await biometricAuth.incrementFailCount();

  //     final newCount = prefs.biometricFailCount;
  //     final isNowLocked = prefs.biometricLocked;

  //     LoggerData.dataLog(
  //       "BIOMETRIC → FAILED "
  //       "Attempt=$newCount/3 "
  //       "Locked=$isNowLocked",
  //     );

  //     if (!mounted) return;

  //     setState(() {
  //       isAuthenticating = false;
  //       _isProcessingBiometric = false;
  //       _hasBiometricTriggered = true;

  //       // Keep biometric screen until 3rd failure.
  //       showFullLoginForm = false;
  //     });

  //     if (isNowLocked || newCount >= 3) {
  //       LoggerData.dataLog(
  //         "BIOMETRIC → 3 failures reached",
  //       );

  //       _showBiometricLockedDialog();
  //       return;
  //     }

  //     final remaining = 3 - newCount;

  //     globalUtils.showNegativeSnackBar(
  //       context: context,
  //       message: "Biometric authentication failed. "
  //           "$remaining attempt${remaining > 1 ? 's' : ''} remaining.",
  //     );
  //   } catch (e, stackTrace) {
  //     LoggerData.dataLog(
  //       "BIOMETRIC ERROR → $e\n$stackTrace",
  //     );

  //     if (!mounted) return;

  //     setState(() {
  //       isAuthenticating = false;
  //       _isProcessingBiometric = false;
  //       _hasBiometricTriggered = true;
  //     });

  //     final prefs = SharedPrefs();

  //     // Only count the error as an attempt if it is actually
  //     // a biometric authentication failure.
  //     if (prefs.biometricFailCount < 3) {
  //       await BiometricAuth().incrementFailCount();
  //     }

  //     final count = prefs.biometricFailCount;

  //     if (prefs.biometricLocked || count >= 3) {
  //       _showBiometricLockedDialog();
  //     } else {
  //       final remaining = 3 - count;

  //       globalUtils.showNegativeSnackBar(
  //         context: context,
  //         message: "Biometric authentication failed. "
  //             "$remaining attempt${remaining > 1 ? 's' : ''} remaining.",
  //       );
  //     }
  //   }
  // }
  Future<void> attemptBiometricLogin() async {
    if (!mounted) return;

    final prefs = SharedPrefs.instance;

    // ----------------------------------------------------------
    // SAFETY CHECKS (all must pass before touching local_auth)
    // ----------------------------------------------------------

    if (isVersionChange) {
      LoggerData.dataLog("BIOMETRIC → Blocked: version update required");
      return;
    }

    if (prefs.isOfflineMode) {
      LoggerData.dataLog("BIOMETRIC → Blocked: offline mode");
      if (mounted) setState(() => showFullLoginForm = true);
      return;
    }

    if (!biometricAvailable || !biometricEnabled) {
      LoggerData.dataLog("BIOMETRIC → Not available or not enabled");
      if (mounted) setState(() => showFullLoginForm = true);
      return;
    }

    // Always read lock state from SharedPrefs (not stale local variables).
    if (prefs.biometricLocked || prefs.biometricFailCount >= 3) {
      LoggerData.dataLog("BIOMETRIC → Application locked: "
          "locked=${prefs.biometricLocked}, "
          "failCount=${prefs.biometricFailCount}");
      if (mounted) {
        setState(() {
          showFullLoginForm = true;
          isAuthenticating = false;
          _isProcessingBiometric = false;
        });
      }
      _showBiometricLockedDialog();
      return;
    }

    if (_isProcessingBiometric || isAuthenticating || _isNavigating) {
      LoggerData.dataLog("BIOMETRIC → Already processing, skipping");
      return;
    }

    // ----------------------------------------------------------
    // START
    // ----------------------------------------------------------

    _isProcessingBiometric = true;
    if (mounted) setState(() => isAuthenticating = true);

    try {
      final biometricAuth = BiometricAuth();

      // NOTE: Do NOT pre-check checkBiometrics() here and bail out on
      // `false` — canCheckBiometrics() can transiently report false right
      // after a failed Face ID attempt (iOS biometric cooldown), which
      // isn't a real "unavailable" state. Bailing out here skipped the
      // fail counter entirely and dropped straight to the full login form
      // after 2 failures instead of 3. authenticate() below already
      // performs this same check internally and routes the result through
      // BiometricResult.unavailable / lockedOut correctly.
      LoggerData.dataLog("BIOMETRIC → Calling authenticate()");
      final BiometricResult result = await biometricAuth.authenticate();
      LoggerData.dataLog("BIOMETRIC → Result = $result");

      // --------------------------------------------------------
      // ROUTE ON TYPED RESULT
      // --------------------------------------------------------
      switch (result) {
        // ─── SUCCESS ────────────────────────────────────────────────────────
        case BiometricResult.success:
          LoggerData.dataLog("BIOMETRIC → SUCCESS");
          await biometricAuth.resetFailCount();

          final username = prefs.username;
          final password = prefs.password;

          if (username.isEmpty || password.isEmpty) {
            LoggerData.dataLog("BIOMETRIC → Stored credentials not found");
            if (!mounted) return;
            setState(() {
              isAuthenticating = false;
              _isProcessingBiometric = false;
              showFullLoginForm = true;
            });
            globalUtils.showNegativeSnackBar(
              context: context,
              message: "Stored credentials not found. "
                  "Please sign in with your User ID.",
            );
            return;
          }

          // Biometric OK → get a fresh API session.
          // Do NOT navigate to Inventory without this call.
          await loginWithStoredCredentials(username, password);
          return;

        // ─── ANYTHING OTHER THAN SUCCESS ────────────────────────────────────
        // Face ID mismatch, user cancel, system/lifecycle interruption,
        // device-level lockout, or hardware temporarily unavailable — every
        // one of these counts as one of the 3 attempts and keeps the user on
        // buildBiometricLoginBlock. Only the 3rd attempt locks it and shows
        // the full login form (via _showBiometricLockedDialog's OK button).
        case BiometricResult.failed:
        case BiometricResult.cancelled:
        case BiometricResult.systemError:
        case BiometricResult.lockedOut:
        case BiometricResult.unavailable:
          LoggerData.dataLog(
              "BIOMETRIC → $result (counts as an attempt, stay on biometric)");
          await biometricAuth.incrementFailCount();

          final newCount = prefs.biometricFailCount;
          final locked = prefs.biometricLocked;

          LoggerData.dataLog("BIOMETRIC → Attempt $newCount/3, locked=$locked");

          if (!mounted) return;
          setState(() {
            isAuthenticating = false;
            _isProcessingBiometric = false;
          });

          if (locked || newCount >= 3) {
            LoggerData.dataLog("BIOMETRIC → 3 attempts → LOCKED");
            if (mounted) setState(() => showFullLoginForm = true);
            _showBiometricLockedDialog();
          } else {
            final remaining = 3 - newCount;
            globalUtils.showNegativeSnackBar(
              context: context,
              message: "Biometric authentication failed. "
                  "$remaining attempt"
                  "${remaining > 1 ? 's' : ''} remaining.",
            );
          }
          return;
      }
    } catch (e, stackTrace) {
      // Unexpected Dart-level error — still counts as an attempt and stays
      // on the biometric screen, never jumps straight to the login form.
      LoggerData.dataLog("BIOMETRIC → Unexpected Dart error: $e\n$stackTrace");

      final biometricAuth = BiometricAuth();
      await biometricAuth.incrementFailCount();

      final newCount = prefs.biometricFailCount;
      final locked = prefs.biometricLocked;

      LoggerData.dataLog("BIOMETRIC → Attempt $newCount/3, locked=$locked");

      if (!mounted) return;
      setState(() {
        isAuthenticating = false;
        _isProcessingBiometric = false;
      });

      if (locked || newCount >= 3) {
        LoggerData.dataLog("BIOMETRIC → 3 attempts → LOCKED");
        if (mounted) setState(() => showFullLoginForm = true);
        _showBiometricLockedDialog();
      } else {
        final remaining = 3 - newCount;
        globalUtils.showNegativeSnackBar(
          context: context,
          message: "Biometric authentication failed. "
              "$remaining attempt"
              "${remaining > 1 ? 's' : ''} remaining.",
        );
      }
    }
  }

  Future<void> loginWithStoredCredentials(
      String username, String password) async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> data = {
      'userid': username,
      'password': password,
    };

    final jsonResponse =
        await apiService.postRequest(context, ApiService.login, data);

    if (jsonResponse != null) {
      final response = LoginResponse.fromJson(jsonResponse);
      if (response.code == '200') {
        // SUCCESSFUL API LOGIN - Reset biometric counter
        await BiometricAuth().resetFailCount();

        SharedPrefs().displayUserName = response.data.username;
        SharedPrefs().uID = response.data.uid;
        SharedPrefs().jwtToken = response.data.jwttoken;
        SharedPrefs().refreshToken = response.data.jwtrefreshtoken;
        SharedPrefs().userSession = response.data.userSession;

        // Clear biometric trigger flag
        // _hasBiometricTriggered = true;
        if (!mounted) return;
        setState(() {
          isLoading = false;
          isAuthenticating = false;
          _isProcessingBiometric = false;
        });

        _navigateToHome();
      } else {
        // API LOGIN FAILED - Show login form, don't auto-retry biometric
        setState(() {
          isLoading = false;
          isAuthenticating = false;
          _isProcessingBiometric = false;
          showFullLoginForm = true;
        });

        globalUtils.showNegativeSnackBar(
            context: context, message: response.message.join(', '));
      }
    } else {
      // API CALL FAILED
      setState(() {
        isLoading = false;
        isAuthenticating = false;
        _isProcessingBiometric = false;
        showFullLoginForm = true;
      });

      globalUtils.showNegativeSnackBar(
          context: context, message: "Login failed. Please try again.");
    }
  }

  // void _showBiometricLockedDialog() {
  //   showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (BuildContext context) {
  //       return CustomImageActionAlert(
  //         iconString: '',
  //         imageString: ImageAssets.biometricEnableDialogImage,
  //         titleString: 'Biometric Locked',
  //         subTitleString:
  //             'Biometric authentication has been locked after 3 failed attempts. Please login with your username and password.',
  //         destructiveActionString: 'OK',
  //         normalActionString: '',
  //         onDestructiveActionTap: () {
  //           Navigator.pop(context);
  //         },
  //         onNormalActionTap: () {},
  //       );
  //     },
  //   );
  // }
  void _showBiometricLockedDialog() {
    if (!mounted) return;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext dialogContext) {
          return WillPopScope(
            onWillPop: () async => false,
            child: CustomImageActionAlert(
              iconString: '',
              imageString: ImageAssets.biometricEnableDialogImage,
              titleString: 'Biometric Locked',
              subTitleString:
                  'Biometric authentication has been locked after 3 failed attempts. Please login with your username and password.',
              destructiveActionString: 'OK',
              normalActionString: '',
              onDestructiveActionTap: () {
                Navigator.pop(dialogContext);

                if (mounted) {
                  setState(() {
                    showFullLoginForm = true;
                    isAuthenticating = false;
                    _isProcessingBiometric = false;
                  });
                }
              },
              onNormalActionTap: () {},
            ),
          );
        },
      );
    });
  }

  void clearCompanyCode() {
    SharedPrefs().companyCode = '';
    SharedPrefs().username = '';
    SharedPrefs().password = '';
    Navigator.pushNamedAndRemoveUntil(
        context, Routes.companyCodeRoute, (Route<dynamic> route) => false);
  }

  void showClearCompanyCodeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return CustomImageActionAlert(
            iconString: '',
            imageString: ImageAssets.clearCompanyCodeImage,
            titleString: AppStrings.clearCompanyCodeTitle,
            subTitleString: AppStrings.clearCompanyCodeSubTitle,
            destructiveActionString: AppStrings.yes,
            normalActionString: AppStrings.no,
            onDestructiveActionTap: () {
              clearCompanyCode();
            },
            onNormalActionTap: () {
              Navigator.pop(context);
            });
      },
    );
  }

  void showBiometricEnableDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return CustomImageActionAlert(
          iconString: '',
          imageString: ImageAssets.biometricEnableDialogImage,
          titleString: 'Quick Login with Biometrics',
          subTitleString:
              'Do you want to enable biometric authentication for quicker logins in the future?',
          destructiveActionString: AppStrings.yes,
          normalActionString: AppStrings.no,
          onDestructiveActionTap: () async {
            Navigator.pop(dialogContext);
            await BiometricAuth().enableBiometric();
            _navigateToHome();
          },
          onNormalActionTap: () {
            Navigator.pop(dialogContext);
            _navigateToHome();
          },
        );
      },
    );
  }

  void _onUserNameTextChange() {
    if (userNameText != AppStrings.userID) {
      setState(() {
        isUserNameError = usernameController.text.trim().isEmpty;
      });
    }
    userNameText = usernameController.text.trim();
  }

  void _onPasswordTextChange() {
    if (passwordText != AppStrings.password) {
      setState(() {
        isPasswordError = passwordController.text.trim().isEmpty;
      });
    }
    passwordText = passwordController.text.trim();
    errorText = AppStrings.requiresValue;
  }

  Future<void> scanBarcode() async {
    try {
      ScanResult barcodeScanResult = await BarcodeScanner.scan();
      String resultString = barcodeScanResult.rawContent;
      if (resultString.isNotEmpty && resultString != "-1") {
        Map<String, dynamic> jsonDict = jsonDecode(resultString);
        loginWithScan(jsonDict['uid']);
      }
    } catch (e) {
      setState(() {
        errorText = "Failed to scan";
      });
    }
  }

  void loginWithScan(int userId) async {
    SharedPrefs().username = '';
    SharedPrefs().password = '';
    setState(() {
      isLoadingForScan = true;
    });

    Map<String, dynamic> data = {
      'uid': '$userId',
      'mode': 'scan',
    };
    final jsonResponse =
        await apiService.postRequest(context, ApiService.externalLogin, data);

    if (jsonResponse != null) {
      final response = LoginResponse.fromJson(jsonResponse);
      setState(() {
        if (response.code == '200') {
          SharedPrefs().displayUserName = response.data.username;
          SharedPrefs().uID = response.data.uid;
          SharedPrefs().jwtToken = response.data.jwttoken;
          SharedPrefs().refreshToken = response.data.jwtrefreshtoken;
          SharedPrefs().userSession = response.data.userSession;
          _navigateToHome();
        } else {
          isPasswordError = true;
          errorText = response.message.join(', ');
        }
      });
    }
    setState(() {
      isLoadingForScan = false;
    });
  }

  void loginWithAzureAD() async {
    setState(() {
      isLoadingForAzureAD = true;
    });

    final token = await AzureAuthService.login();

    if (token != null) {
      if (mounted) {
        await fetchAzureUserDetails(token);
      }
    } else {
      if (mounted) {
        globalUtils.showNegativeSnackBar(
            context: context, message: "Azure login failed");
      }
    }

    setState(() {
      isLoadingForAzureAD = false;
    });
  }

  Future<void> fetchAzureUserDetails(String token) async {
    Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
    String? email = decodedToken["unique_name"];
    if (email != null) {
      loginWithAsureSSO(email);
    } else {
      if (mounted) {
        globalUtils.showNegativeSnackBar(
            context: context, message: "No email found in Azure token");
      }
    }
  }

  void loginWithAsureSSO(String email) async {
    SharedPrefs().username = '';
    SharedPrefs().password = '';
    setState(() {
      isLoadingForScan = true;
    });

    Map<String, dynamic> data = {
      'email': email,
      'mode': 'sso',
    };

    final jsonResponse =
        await apiService.postRequest(context, ApiService.externalLogin, data);

    if (jsonResponse != null) {
      final response = LoginResponse.fromJson(jsonResponse);
      if (response.code == '200') {
        SharedPrefs().displayUserName = response.data.username;
        SharedPrefs().uID = response.data.uid;
        SharedPrefs().jwtToken = response.data.jwttoken;
        SharedPrefs().refreshToken = response.data.jwtrefreshtoken;
        SharedPrefs().userSession = response.data.userSession;
        _navigateToHome();
      } else {
        setState(() {
          isPasswordError = true;
          errorText = response.message.join(', ');
        });
        if (mounted) {
          globalUtils.showNegativeSnackBar(
              context: context, message: "SSO Login failed: $errorText");
        }
      }
    } else {
      if (mounted) {
        globalUtils.showNegativeSnackBar(
            context: context, message: "No response from login server");
      }
    }

    setState(() {
      isLoadingForScan = false;
    });
  }

  Widget buildLoginAndPasswordBlock(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: displayWidth(context),
          child: Row(
            children: [
              const Spacer(),
              CustomTextButton(
                buttonText: AppStrings.forgotUserID,
                onTap: () {
                  navigateToScreen(context, const ForgotUserIDView());
                },
              ),
            ],
          ),
        ),
        CustomTextField(
          iconString: ImageAssets.userIdIcon,
          hintText: AppStrings.userID,
          controller: usernameController,
          isValid: !isUserNameError,
          onTextChanged: validateFields,
        ),
        isUserNameError ? const ErrorTextViewBox() : const SizedBox(),
        isUserNameError ? const SizedBox(height: 20) : const SizedBox(),
        SizedBox(
          width: displayWidth(context),
          child: Row(
            children: [
              const Spacer(),
              CustomTextButton(
                buttonText: AppStrings.forgotPassword,
                onTap: () {
                  navigateToScreen(context, const ForgotPasswordView());
                },
              ),
            ],
          ),
        ),
        CustomTextField(
          iconString: ImageAssets.passwordIcon,
          hintText: AppStrings.password,
          controller: passwordController,
          isObscureText: true,
          isValid: !isPasswordError,
          onTextChanged: validateFields,
        ),
        isPasswordError
            ? ErrorTextViewBox(titleString: errorText)
            : const SizedBox(),
        isPasswordError ? const SizedBox(height: 20) : const SizedBox(),
        CustomCheckboxListTile(
          title: Text(
            AppStrings.rememberMe,
            style: getRegularStyle(
              color: ColorManager.lightGrey1,
              fontSize: FontSize.s18,
            ),
          ),
          value: checkedValue,
          onChanged: (value) {
            setState(() {
              checkedValue = value!;
              SharedPrefs().isRememberMeSelected = checkedValue;
            });
          },
        ),
        const SizedBox(height: 50),
        isLoading
            ? const CustomProgressIndicator()
            : CustomButton(
                buttonText: AppStrings.signIn,
                onTap: () {
                  isFormValidated = true;
                  validateFields();
                  if (!isUserNameError && !isPasswordError) {
                    loginUser();
                  }
                },
                height: 50,
              ),
      ],
    );
  }

  Widget buildBiometricLoginBlock(BuildContext context) {
    final remainingAttempts = 3 - biometricFailCount;
    final isLocked = biometricLocked;

    return Column(
      children: [
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: ColorManager.welcomcircleBackgroundColor,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: ColorManager.white,
                    width: 2.0,
                  ),
                ),
                alignment: Alignment.center,
                child: Text(
                  getInitials(SharedPrefs().displayUserName),
                  style: getBoldStyle(
                    color: ColorManager.darkBlue,
                    fontSize: FontSize.s21,
                  ),
                ),
              ),
              const SizedBox(width: 20),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back,',
                    style: getRegularStyle(
                      color: ColorManager.grey,
                      fontSize: FontSize.s18,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    SharedPrefs().displayUserName,
                    style: getBoldStyle(
                      color: ColorManager.black,
                      fontSize: FontSize.s25_5,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 50),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(
            vertical: 25,
          ),
          decoration: BoxDecoration(
            color: ColorManager.fingerPrintBackgroundColor,
            border: Border.all(
              color: ColorManager.darkBlue.withOpacity(0.20),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(15),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 30,
                  right: 30,
                ),
                child: isAuthenticating
                    ? const Center(
                        child: CustomProgressIndicator(),
                      )
                    : Center(
                        // child: GestureDetector(
                        //   onTap: () async {
                        //     if (_isProcessingBiometric) return;
                        //     await attemptBiometricLogin();
                        //   },
                        //   child: Container(
                        //     width: 55,
                        //     height: 55,
                        //     decoration: BoxDecoration(
                        //       color: ColorManager.white,
                        //       shape: BoxShape.circle,
                        //       border: Border.all(
                        //         color: isLocked
                        //             ? ColorManager.red
                        //             : ColorManager.darkBlue.withOpacity(0.20),
                        //         width: 1,
                        //       ),
                        //     ),
                        //     child: Icon(
                        //       isLocked ? Icons.lock : Icons.fingerprint,
                        //       size: 40,
                        //       color: isLocked
                        //           ? ColorManager.red
                        //           : ColorManager.darkBlue,
                        //     ),
                        //   ),
                        // ),
                        child: GestureDetector(
                        onTap: () async {
                          if (_isProcessingBiometric ||
                              isAuthenticating ||
                              _isNavigating ||
                              biometricLocked ||
                              isVersionChange ||
                              SharedPrefs().isOfflineMode) {
                            return;
                          }

                          await attemptBiometricLogin();
                        },
                        child: Container(
                          width: 120,
                          height: 55,
                          decoration: BoxDecoration(
                            color: ColorManager.white,
                            shape: BoxShape.rectangle,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: ColorManager.darkBlue.withOpacity(0.20),
                              width: 1,
                            ),
                          ),
                          child: Image.asset(
                            ImageAssets.biometricIcon,
                          ),
                        ),
                      )),
              ),
              const SizedBox(height: 10),
              Center(
                child: Text(
                  isLocked
                      ? 'Biometric Locked - Use User ID Login'
                      : remainingAttempts > 0
                          ? 'Use Face ID/Fingerprint\n($remainingAttempts attempt${remainingAttempts > 1 ? 's' : ''} remaining)'
                          : 'Use Face ID/Fingerprint',
                  textAlign: TextAlign.center,
                  style: getRegularStyle(
                    color: isLocked ? ColorManager.red2 : ColorManager.darkBlue,
                    fontSize: FontSize.s16,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 50),
      ],
    );
  }

  Widget buildCompanyCodeRow(BuildContext context) {
    return SizedBox(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppStrings.companyCodeDetail,
            style: getRegularStyle(
              color: ColorManager.black,
              fontSize: FontSize.s22_5,
            ),
          ),
          GestureDetector(
            onTap: () {
              showClearCompanyCodeDialog(context);
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: DashedLineText(
                titleString: SharedPrefs().companyCode,
                titleStyle: getDottedUnderlineSemiBoldStyle(
                  color: ColorManager.orange,
                  lineColor: ColorManager.lightGrey1,
                  fontSize: FontSize.s22_5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricButton(BuildContext context) {
    final remainingAttempts = 3 - SharedPrefs().biometricFailCount;

    return Padding(
      padding: const EdgeInsets.only(
        top: 20,
        bottom: 20,
      ),
      child: Column(
        children: [
          // const Divider(),
          // const SizedBox(height: 15),
          // Text(
          //   'OR',
          //   style: getRegularStyle(
          //     color: ColorManager.lightGrey3,
          //     fontSize: FontSize.s14,
          //   ),
          // ),
          const SizedBox(height: 15),
          isAuthenticating
              ? const CustomProgressIndicator()
              : GestureDetector(
                  onTap: () async {
                    if (_isProcessingBiometric ||
                        _isNavigating ||
                        biometricLocked) {
                      return;
                    }

                    await attemptBiometricLogin();
                  },
                  child: Container(
                    width: 55,
                    height: 55,
                    decoration: BoxDecoration(
                      color: ColorManager.white,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: ColorManager.darkBlue,
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.fingerprint,
                      size: 40,
                      color: ColorManager.darkBlue,
                    ),
                  ),
                ),
          const SizedBox(height: 10),
          Text(
            remainingAttempts > 0
                ? 'Login with Fingerprint / Face ID'
                : 'Biometric Locked',
            textAlign: TextAlign.center,
            style: getRegularStyle(
              color:
                  biometricLocked ? ColorManager.red : ColorManager.lightGrey3,
              fontSize: FontSize.s14,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check if biometric should be triggered
    // final currentFailCount = SharedPrefs().biometricFailCount;
    // final isLocked = SharedPrefs().biometricLocked;

    // // ⭐ ONLY auto-trigger if NO failures yet (prevent loop)
    // final shouldTriggerBiometric = isLoginOptionsLoaded &&
    //     !_initialBiometricTriggered &&
    //     !_appWasInBackground &&
    //     biometricAvailable &&
    //     biometricEnabled &&
    //     !isLocked &&
    //     !showFullLoginForm &&
    //     !_isProcessingBiometric &&
    //     !_isNavigating &&
    //     !SharedPrefs().isOfflineMode &&
    //     !isVersionChange &&
    //     ModalRoute.of(context)?.isCurrent == true &&
    //     currentFailCount == 0;

    // if (shouldTriggerBiometric) {
    //   _initialBiometricTriggered = true;

    //   WidgetsBinding.instance.addPostFrameCallback((_) {
    //     if (!mounted) return;

    //     if (_appWasInBackground) {
    //       LoggerData.dataLog(
    //         "BIOMETRIC → Auto trigger cancelled because app was backgrounded",
    //       );
    //       return;
    //     }

    //     if (_isProcessingBiometric || _isNavigating) {
    //       return;
    //     }

    //     attemptBiometricLogin();
    //   });
    // } else if (isLoginOptionsLoaded && !_hasBiometricTriggered) {
    //   // If biometric is NOT available or locked, show login form
    //   if (!biometricEnabled || isLocked || SharedPrefs().isOfflineMode) {
    //     setState(() {
    //       showFullLoginForm = true;
    //     });
    //   } else if (biometricAvailable && biometricEnabled && !isLocked) {
    //     // ⭐ Show biometric screen even if there are failures
    //     setState(() {
    //       showFullLoginForm = false;
    //     });
    //   }
    //   _hasBiometricTriggered = true;
    // }

    if (!isLoginOptionsLoaded) {
      return Scaffold(
        backgroundColor: ColorManager.white,
        body: const Center(child: CustomProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: ColorManager.white,
      body: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) => {SystemNavigator.pop()},
        child: GestureDetector(
          onTap: onScreenTapped,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: Column(
              children: [
                const HeaderLogo(),
                const SizedBox(height: 20),
                _buildLoginForm(),
                const SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onScreenTapped() {
    setState(() {
      tapCount++;
      if (tapCount >= 5) {
        isLoginazureAd = false;
      }
    });
  }

  Widget _buildLoginForm() {
    // Check if biometric should be shown
    final showBiometricBlock = biometricAvailable &&
        biometricEnabled &&
        !showErrorScreen &&
        !biometricLocked &&
        !showFullLoginForm &&
        !isVersionChange &&
        !SharedPrefs().isOfflineMode;

    return Padding(
      padding: const EdgeInsets.only(left: 30, right: 30),
      child: SizedBox(
        child: showErrorScreen
            ? Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(height: 40),
                  buildCompanyCodeRow(context),
                  const SizedBox(height: 40),
                  Image.asset(
                    ImageAssets.errorMessageIcon,
                    width: displayWidth(context) * 0.5,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 20),
                    child: Linkify(
                      onOpen: _onOpenLink,
                      text: errorText,
                      textAlign: TextAlign.center,
                      style: getRegularStyle(
                        color: ColorManager.lightGrey,
                        fontSize: FontSize.s17,
                      ),
                      linkStyle: const TextStyle(
                        color: Colors.blue,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: displayWidth(context) * 0.95,
                    child: CustomButton(
                      buttonText: "Back",
                      onTap: () {
                        Navigator.pushNamedAndRemoveUntil(
                            context,
                            Routes.companyCodeRoute,
                            (Route<dynamic> route) => false);
                        setState(() {
                          showErrorScreen = false;
                          isError = false;
                          errorText = "";
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 30),
                ],
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Logic to conditionally show/hide the login form based on isLoginazureAd and tap count
                  // (isLoginazureAd && tapCount < 5)
                  //     ? Column(
                  //         children: [
                  //           const SizedBox(height: 140),
                  //           buildCompanyCodeRow(context),
                  //           const SizedBox(height: 40),
                  //           CustomButton(
                  //             buttonText: "Login with URBN SSO",
                  //             leading: SizedBox(
                  //               width: 30,
                  //               height: 30,
                  //               child: Image.asset(ImageAssets.ssoIcon),
                  //             ),
                  //             onTap: loginWithAzureAD,
                  //             isDefault: true,
                  //           ),
                  //         ],
                  //       )
                  //     :
                  Column(
                    children: [
                      buildCompanyCodeRow(context),
                      const SizedBox(height: 20),
                      showBiometricBlock
                          ? buildBiometricLoginBlock(context)
                          : buildLoginAndPasswordBlock(context),
                      const SizedBox(height: 20),
                      isLoginWithScan
                          ? Column(
                              children: [
                                const OrDivider(),
                                const SizedBox(height: 20),
                                isLoadingForScan
                                    ? const CustomProgressIndicator()
                                    : CustomButton(
                                        buttonText: AppStrings.loginWithBarcode,
                                        onTap: () {
                                          scanBarcode();
                                        },
                                        isDefault: true),
                                const SizedBox(height: 30),
                              ],
                            )
                          : const SizedBox(),
                      isLoginazureAd
                          ? CustomButton(
                              buttonText: ssoButtonText,
                              leading: SizedBox(
                                width: 20,
                                height: 20,
                                child: Image.asset(ImageAssets.ssoIcon),
                              ),
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const SSOWebViewScreen(),
                                  ),
                                );
                              },
                              isDefault: true,
                              height: 50,
                            )
                          : const SizedBox(),
                      const SizedBox(height: 10),
                      if (showBiometricBlock)
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              showFullLoginForm = true;
                            });
                          },
                          child: Column(
                            children: [
                              const Divider(),
                              const SizedBox(height: 10),
                              Text(
                                'Sign In with User Id',
                                style: getBoldStyle(
                                  color: ColorManager.darkBlue,
                                  fontSize: FontSize.s14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      if (biometricAvailable &&
                          biometricEnabled &&
                          !showErrorScreen &&
                          !biometricLocked &&
                          !SharedPrefs().isOfflineMode &&
                          showFullLoginForm)
                        _buildBiometricButton(context),
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
      ),
    );
  }
}
