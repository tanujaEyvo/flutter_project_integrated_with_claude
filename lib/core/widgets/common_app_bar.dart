import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/styles_manager.dart';
import 'package:flutter/material.dart';

PreferredSizeWidget buildCommonAppBar({
  required BuildContext context,
  required String title,
  bool showBackButton = true,
  VoidCallback? onBackPressed,
  Color? backgroundColor,
}) {
  return AppBar(
    backgroundColor: backgroundColor ?? ColorManager.darkBlue,
    titleSpacing: -10,
    title: Text(
      title,
      style: getBoldStyle(
        color: ColorManager.white,
        fontSize: FontSize.s20,
      ),
    ),
    leading: showBackButton
        ? IconButton(
            icon: SizedBox(
              width: 18,
              height: 18,
              child: Image.asset(ImageAssets.backButton),
            ),
            onPressed: onBackPressed ?? () => Navigator.pop(context),
          )
        : null,
  );
}
