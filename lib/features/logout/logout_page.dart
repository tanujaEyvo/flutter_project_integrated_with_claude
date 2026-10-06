import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/routes_manager.dart';
import 'package:eyvo_v3/core/resources/styles_manager.dart';
import 'package:eyvo_v3/core/widgets/button.dart';
import 'package:flutter/material.dart';

class LogOutPage extends StatefulWidget {
  const LogOutPage({Key? key}) : super(key: key);

  @override
  _LogOutPageState createState() => _LogOutPageState();
}

class _LogOutPageState extends State<LogOutPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            const Spacer(flex: 2),
            Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(30),
                  decoration: BoxDecoration(
                    color: ColorManager.checkBackground,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: ColorManager.checkBackground,
                      width: 3,
                    ),
                  ),
                  child: Icon(
                    Icons.check,
                    color: ColorManager.darkBlue,
                    size: 80,
                  ),
                ),
                const SizedBox(height: 40),
                Text(
                  "You've logged off",
                  style: getBoldStyle(
                    color: ColorManager.darkBlue,
                    fontSize: FontSize.s22_5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 15),
                Text(
                  "Thank you for using Eyvo app.",
                  style: getSemiBoldStyle(
                    color: ColorManager.lightBlack,
                    fontSize: FontSize.s18,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
            const Spacer(flex: 3),
            CustomTextActionButton(
              buttonText: "Return to Login",
              backgroundColor: ColorManager.darkBlue,
              borderColor: Colors.transparent,
              fontColor: ColorManager.white,
              buttonWidth: double.infinity,
              buttonHeight: 50,
              isBoldFont: true,
              fontSize: FontSize.s20,
              onTap: () {
                Navigator.pushNamedAndRemoveUntil(
                  context,
                  Routes.loginRoute,
                  (Route<dynamic> route) => false,
                );
              },
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
