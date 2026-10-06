import 'dart:convert';

import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/utils.dart';
import 'package:eyvo_v3/core/widgets/common_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:eyvo_v3/app/app_prefs.dart';
import 'package:eyvo_v3/log_data.dart/logger_data.dart';
import 'package:eyvo_v3/Environment/environment.dart';
import 'package:eyvo_v3/presentation/home/home.dart';

class SSOWebViewScreen extends StatefulWidget {
  const SSOWebViewScreen({Key? key}) : super(key: key);

  @override
  State<SSOWebViewScreen> createState() => _SSOWebViewScreenState();
}

class _SSOWebViewScreenState extends State<SSOWebViewScreen> {
  late final WebViewController _controller;
  bool _isProcessing = false;
  bool _showLoader = true;
  static const Color primaryColor = Color(0xFF23367C);

  @override
  void initState() {
    super.initState();

    final String urlString =
        '$baseUrl/auth/login?session=${SharedPrefs().ssoSession ?? ''}';

    LoggerData.dataLog('Loading URL: $urlString');

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            LoggerData.dataLog('Page Started: $url');
            setState(() {
              _showLoader = true;
            });
          },
          onPageFinished: (url) {
            LoggerData.dataLog('Page Finished: $url');
            setState(() {
              _showLoader = false;
            });
          },
          onHttpError: (error) {
            LoggerData.dataLog('HTTP Error: ${error.response?.statusCode}');
            setState(() {
              _showLoader = false;
            });
          },
          onWebResourceError: (error) {
            LoggerData.dataLog('Web Resource Error: ${error.description}');
            setState(() {
              _showLoader = false;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            LoggerData.dataLog('Navigation Request: ${request.url}');

            if (request.url.startsWith('eyvo3://callback')) {
              LoggerData.dataLog('Deep link detected!');
              _handleDeepLink(request.url);
              return NavigationDecision.prevent;
            }

            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(
        Uri.parse(urlString),
      );
  }

  void _handleDeepLink(String url) {
    if (_isProcessing) return;
    _isProcessing = true;

    try {
      LoggerData.dataLog('Processing deep link: $url');

      final uri = Uri.parse(url);
      final String? encodedData = uri.queryParameters['data'];

      if (encodedData != null) {
        final String decodedData = Uri.decodeComponent(encodedData);
        LoggerData.dataLog('Decoded Data: $decodedData');

        final Map<String, dynamic> responseData = jsonDecode(decodedData);
        LoggerData.dataLog('Response Data: $responseData');

        if (responseData['code'] == '200') {
          final String userDataString = responseData['data'];
          final Map<String, dynamic> userData = jsonDecode(userDataString);

          LoggerData.dataLog('User Data: $userData');

          _saveUserData(userData);
          _navigateToInventoryWithSuccess();
        } else {
          // Login failed - go back to login page
          LoggerData.dataLog('Login failed: ${responseData['message']}');
          _showErrorAndGoBack('SSO Login failed: ${responseData['message']}');
        }
      } else {
        LoggerData.dataLog('No data parameter found in deep link');
        _showErrorAndGoBack('Invalid callback data');
      }
    } catch (e) {
      LoggerData.dataLog('Error handling deep link: $e');
      _showErrorAndGoBack('Error processing login: $e');
    }
  }

  Future<void> _saveUserData(Map<String, dynamic> userData) async {
    try {
      LoggerData.dataLog('Saving user data...');

      SharedPrefs().displayUserName = userData['username'] ?? '';
      SharedPrefs().uID = userData['uid'] ?? '';
      SharedPrefs().jwtToken = userData['jwttoken'] ?? '';
      SharedPrefs().refreshToken = userData['jwtrefreshtoken'] ?? '';
      SharedPrefs().userSession = userData['usersession'] ?? '';

      LoggerData.dataLog(' User data saved successfully');
    } catch (e) {
      LoggerData.dataLog('Error saving user data: $e');
      _showErrorAndGoBack('Failed to save user data');
    }
  }

  void _navigateToInventoryWithSuccess() {
    if (mounted) {
      LoggerData.dataLog('Navigating to Inventory with success...');

      // Show success snackbar

      showSnackBar(
        context,
        'Login Successful!',
      );
      // Navigate to Inventory after a short delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => const InverntoryView(),
            ),
          );
        }
      });
    }
  }

  void _showErrorAndGoBack(String message) {
    if (!mounted) {
      _isProcessing = false;
      return;
    }

    LoggerData.dataLog(' Error: $message');

    // Show error message and then go back
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(' $message'),
        backgroundColor: ColorManager.red2,
        duration: const Duration(seconds: 5),
      ),
    );

    // Navigate back to login page after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        Navigator.pop(context);
      }
    });
  }

  @override
  void dispose() {
    _isProcessing = false;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCommonAppBar(
        context: context,
        title: 'SSO Login',
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_showLoader)
            const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(primaryColor),
              ),
            ),
        ],
      ),
    );
  }
}
