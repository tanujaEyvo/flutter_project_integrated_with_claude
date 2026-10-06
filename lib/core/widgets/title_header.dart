import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/styles_manager.dart';
import 'package:flutter/material.dart';

class TitleHeader extends StatelessWidget {
  const TitleHeader({
    super.key,
    required this.titleText,
    required this.detailText,
  });

  final String titleText;
  final String detailText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(titleText,
            style: getBoldStyle(
                color: ColorManager.darkBlue, fontSize: FontSize.s21)),
        const SizedBox(height: 20),
        Text(detailText,
            style: getRegularStyle(
                color: ColorManager.lightGrey, fontSize: FontSize.s17)),
      ],
    );
  }
}

class CenterTitleHeader extends StatelessWidget {
  const CenterTitleHeader({
    super.key,
    required this.titleText,
    required this.detailText,
  });

  final String titleText;
  final String detailText;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          titleText.isNotEmpty
              ? Text(titleText,
                  textAlign: TextAlign.center,
                  style: getBoldStyle(
                      color: ColorManager.darkBlue, fontSize: FontSize.s20))
              : const SizedBox(),
          detailText.isNotEmpty
              ? Text(detailText,
                  textAlign: TextAlign.center,
                  style: getRegularStyle(
                      color: ColorManager.lightGrey, fontSize: FontSize.s16))
              : const SizedBox(),
        ],
      ),
    );
  }
}
