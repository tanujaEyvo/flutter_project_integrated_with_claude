import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/strings_manager.dart';
import 'package:eyvo_v3/core/widgets/common_app_bar.dart';
import 'package:eyvo_v3/core/widgets/text_error.dart';
import 'package:eyvo_v3/services/biometric_auth_service.dart';
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  _SettingPageState createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool isBiometricEnabled = false;
  String biometricLabel = 'Biometric';
  final BiometricAuth _biometricAuth = BiometricAuth();

  @override
  void initState() {
    super.initState();
    _loadBiometricSettings();
  }

  Future<void> _loadBiometricSettings() async {
    final enabled = _biometricAuth.isBiometricEnabled();
    final availableTypes = await _biometricAuth.getAvailableBiometrics();

    setState(() {
      isBiometricEnabled = enabled;

      if (availableTypes.contains(BiometricType.face)) {
        biometricLabel = 'Face ID';
      } else if (availableTypes.contains(BiometricType.fingerprint)) {
        biometricLabel = 'Fingerprint';
      } else {
        biometricLabel = 'Biometric';
      }
    });
  }

  // Future<void> _toggleBiometric(bool value) async {
  //   if (value) {
  //     final hasBiometrics = await _biometricAuth.checkBiometrics();
  //     final availableTypes = await _biometricAuth.getAvailableBiometrics();

  //     if (!hasBiometrics || availableTypes.isEmpty) {
  //       ScaffoldMessenger.of(context).showSnackBar(
  //         SnackBar(
  //           content: const Text("No biometric ID is enrolled on this device."),
  //           backgroundColor: ColorManager.darkBlue,
  //         ),
  //       );

  //       return;
  //     }

  //     final success = await _biometricAuth.authenticate();
  //     if (!success) return;

  //     await _biometricAuth.enableBiometric();
  //   } else {
  //     await _biometricAuth.disableBiometric();
  //   }

  //   setState(() {
  //     isBiometricEnabled = value;
  //   });
  // }
  Future<void> _toggleBiometric(bool value) async {
    if (value) {
      final hasBiometrics = await _biometricAuth.checkBiometrics();
      final availableTypes = await _biometricAuth.getAvailableBiometrics();

      if (!hasBiometrics || availableTypes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              "No biometric ID is enrolled on this device.",
            ),
            backgroundColor: ColorManager.darkBlue,
          ),
        );
        return;
      }

      // Manually authenticate only when ENABLE is pressed
      final result = await _biometricAuth.authenticate();

      if (result != BiometricResult.success) {
        return;
      }

      await _biometricAuth.enableBiometric();
    } else {
      await _biometricAuth.disableBiometric();
    }

    if (!mounted) return;

    setState(() {
      isBiometricEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.white,
      appBar: buildCommonAppBar(
        context: context,
        title: AppStrings.settings,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 2),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 10),
            _buildSettingTile(
              title: 'Enable $biometricLabel',
              value: isBiometricEnabled,
              onChanged: _toggleBiometric,
              description:
                  'After enabling $biometricLabel, you can use it to securely log in to your account.',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required String title,
    required bool value,
    required Function(bool) onChanged,
    String? description,
  }) {
    return Center(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.98,
        child: Card(
          surfaceTintColor: ColorManager.primary,
          elevation: 2,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorManager.blue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.fingerprint,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Title and Description
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: FontSize.s16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (description != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          description,
                          style: TextStyle(
                            fontSize: FontSize.s14,
                            color: ColorManager.grey,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                const SizedBox(width: 20),
                SizedBox(
                  width: 50,
                  child: Center(
                    child: Transform.scale(
                      scale: 0.8,
                      child: Switch(
                        value: value,
                        onChanged: onChanged,
                        activeColor: ColorManager.green,
                        activeTrackColor: ColorManager.green.withOpacity(0.5),
                        inactiveTrackColor: ColorManager.lightGrey3,
                        inactiveThumbColor: ColorManager.grey,
                        thumbColor:
                            WidgetStateProperty.resolveWith<Color>((states) {
                          return ColorManager.white;
                        }),
                        trackOutlineColor:
                            WidgetStateProperty.resolveWith<Color>((states) {
                          return !value
                              ? ColorManager.white
                              : Colors.transparent;
                        }),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
