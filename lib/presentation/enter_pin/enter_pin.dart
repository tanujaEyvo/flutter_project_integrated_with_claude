import 'package:eyvo_v3/app/app_prefs.dart';
import 'package:eyvo_v3/app/sizes_helper.dart';
import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/routes_manager.dart';
import 'package:eyvo_v3/core/resources/strings_manager.dart';
import 'package:eyvo_v3/core/resources/styles_manager.dart';
import 'package:eyvo_v3/core/utils.dart';
import 'package:eyvo_v3/core/widgets/button.dart';
import 'package:eyvo_v3/core/widgets/custom_field.dart';
import 'package:eyvo_v3/core/widgets/dashed_line_text.dart';
import 'package:eyvo_v3/core/widgets/title_header.dart';
import 'package:eyvo_v3/presentation/home/home.dart';
import 'package:eyvo_v3/presentation/set_pin/set_pin.dart';
import 'package:flutter/material.dart';

class EnterPINView extends StatefulWidget {
  const EnterPINView({super.key});

  @override
  State<EnterPINView> createState() => _EnterPINViewState();
}

class _EnterPINViewState extends State<EnterPINView> {
  bool isValid = true;
  bool isEnabled = true;
  int attemptsRemaining = 3;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  void _verifyPIN(String enteredPIN) {
    setState(() {
      isValid = enteredPIN == SharedPrefs().appPIN;
    });
    if (!isValid) {
      attemptsRemaining -= 1;
    } else {
      navigateToScreen(context, const InverntoryView());
    }
    if (attemptsRemaining <= 0) {
      setState(() {
        isEnabled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = displayWidth(context);
    double topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      backgroundColor: ColorManager.white,
      body: Column(
        children: [
          SizedBox(height: topPadding),
          Container(
            alignment: Alignment.topRight,
            width: displayWidth(context),
            child: CustomImageButton(
                imageString: ImageAssets.closeIcon,
                onTap: () {
                  Navigator.pushNamedAndRemoveUntil(context, Routes.loginRoute,
                      (Route<dynamic> route) => false);
                }),
          ),
          Padding(
            padding:
                const EdgeInsets.only(top: 0, left: 18, right: 18, bottom: 0),
            child: SizedBox(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    width: screenWidth,
                    child: const TitleHeader(
                        titleText: AppStrings.enterPINTitle,
                        detailText: AppStrings.enterPINSubtTitle),
                  ),
                  const SizedBox(height: 50),
                  SizedBox(
                      child: PINField(
                          onPINComplete: _verifyPIN,
                          isValid: isValid,
                          isEnabled: isEnabled)),
                  const SizedBox(height: 30),
                  isValid
                      ? const SizedBox()
                      : Text(
                          '${AppStrings.wrongPIN} $attemptsRemaining ${AppStrings.attemptsRemaining}',
                          style: getRegularStyle(
                              color: ColorManager.red2,
                              fontSize: FontSize.s14)),
                  const SizedBox(height: 20),
                  GestureDetector(
                    onTap: () {
                      resetPIN();
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: DashedLineText(
                          titleString: AppStrings.resetPIN,
                          titleStyle: getDottedUnderlineStyle(
                              color: ColorManager.lightGrey2,
                              lineColor: ColorManager.lightGrey2,
                              fontSize: FontSize.s18)),
                    ),
                  )
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void resetPIN() {
    navigateToScreen(context, const SetPINView());
  }
}
