import 'dart:developer';

import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:eyvo_v3/core/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:eyvo_v3/core/resources/routes_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';

class ThankYouPage extends StatelessWidget {
  final String message;
  final String? approverName;
  final String? status;
  final String? requestName;
  final dynamic number;

  const ThankYouPage(
      {super.key,
      required this.message,
      this.approverName,
      this.status,
      this.requestName,
      this.number});

  String cleanMessage(String msg) {
    // Removes surrounding square brackets if present
    return msg.replaceAll(RegExp(r'^\[|\]$'), '');
  }

  @override
  Widget build(BuildContext context) {
    // log('ThankYouPage status: $status');
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) {
        if (!didPop) {
          Navigator.pushReplacementNamed(
            context,
            Routes.orderApproverPage,
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Thank You Image
                status == 'Order Rejected'
                    ? Image.asset(
                        ImageAssets.rejection,
                        height: 150,
                        fit: BoxFit.contain,
                      )
                    : Image.asset(
                        ImageAssets.thankYou1,
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                const SizedBox(height: 24),

                //  Thank You Heading
                // Text(
                //   'Thank You!!',
                //   style: TextStyle(
                //     fontSize: 28,
                //     fontWeight: FontWeight.bold,
                //     color: ColorManager.green,
                //   ),
                //   textAlign: TextAlign.center,
                // ),
                // const SizedBox(height: 16),

                // Status Text

                if (status != null) ...[
                  Text(
                    status!,
                    style: TextStyle(
                      fontSize: FontSize.s20,
                      fontWeight: FontWeight.bold,
                      color: status == 'Order Rejected'
                          ? ColorManager.red
                          : ColorManager.green,
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 8),

                  // RequestName : Number
                  if (requestName != null && number != null)
                    Text(
                      '$requestName: $number',
                      style: TextStyle(
                        fontSize: FontSize.s18,
                        fontWeight: FontWeight.w600,
                        color: ColorManager.darkGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                ],

                const SizedBox(height: 12),

                //  Cleaned Message
                Text(
                  cleanMessage(message),
                  style: TextStyle(
                    fontSize: FontSize.s16,
                    color: ColorManager.darkGrey,
                  ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 32),

                // Custom  Button
                CustomTextActionButton(
                  buttonText: 'OK',
                  onTap: () {
                    Navigator.pop(context);
                  },
                  backgroundColor: ColorManager.green,
                  borderColor: ColorManager.green,
                  fontColor: ColorManager.white,
                  isBoldFont: true,
                  fontSize: FontSize.s18,
                  buttonWidth: 150,
                  buttonHeight: 50,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
