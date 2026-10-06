import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/styles_manager.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onTap;
  final bool isEnabled;
  final bool isDefault;
  final Widget? leading;
  final double? height;

  const CustomButton({
    super.key,
    required this.buttonText,
    required this.onTap,
    this.isEnabled = true,
    this.isDefault = false,
    this.leading,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: height ?? 60,
      decoration: BoxDecoration(
        color: isDefault
            ? ColorManager.white
            : isEnabled
                ? ColorManager.darkBlue
                : ColorManager.grey5,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: isDefault ? ColorManager.grey2 : Colors.transparent,
          width: 1.0,
        ),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (leading != null) ...[
              leading!,
              const SizedBox(width: 2),
            ],
            Expanded(
              child: Text(
                buttonText,
                textAlign: TextAlign.center,
                maxLines: 2,
                softWrap: true,
                overflow: TextOverflow.visible,
                style: getBoldStyle(
                  color: isDefault
                      ? ColorManager.darkBlue
                      : isEnabled
                          ? ColorManager.white
                          : ColorManager.darkGrey2,
                  fontSize: FontSize.s18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class CustomTextButton extends StatelessWidget {
  final String buttonText;
  final VoidCallback onTap;
  const CustomTextButton(
      {super.key, required this.buttonText, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      height: 40,
      child: Row(
        children: [
          const Spacer(),
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
            ),
            child: Text(
              textAlign: TextAlign.right,
              buttonText,
              style: getRegularStyle(
                  color: ColorManager.lightBlue, fontSize: FontSize.s16),
            ),
          ),
        ],
      ),
    );
  }
}

class CustomImageButton extends StatelessWidget {
  final String imageString;
  final VoidCallback onTap;
  const CustomImageButton(
      {super.key, required this.imageString, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: ElevatedButton.icon(
        icon: Image(image: AssetImage(imageString)),
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        label: const Text(''),
      ),
    );
  }
}

class CustomIconButton extends StatelessWidget {
  final String imageString;
  const CustomIconButton({super.key, required this.imageString});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
        child: IconButton(
            icon: Image(image: AssetImage(imageString), width: 30, height: 30),
            onPressed: () {}));
  }
}

class CustomTextActionButton extends StatelessWidget {
  final String buttonText;
  final Color backgroundColor;
  final Color fontColor;
  final Color borderColor;
  final double buttonWidth;
  final double buttonHeight;
  final bool isBoldFont;
  final double fontSize;
  final VoidCallback onTap;
  final IconData? icon; // <-- Optional icon

  const CustomTextActionButton({
    super.key,
    required this.buttonText,
    required this.backgroundColor,
    required this.borderColor,
    required this.fontColor,
    this.buttonWidth = 120,
    this.buttonHeight = 50,
    this.isBoldFont = false,
    this.fontSize = FontSize.s16,
    this.icon, // <-- Added
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          backgroundColor: backgroundColor,
          shadowColor: Colors.transparent,
          side: BorderSide(color: borderColor),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null) ...[
              Icon(icon, color: fontColor, size: fontSize),
              const SizedBox(width: 6),
            ],
            Text(
              buttonText,
              style: isBoldFont
                  ? getBoldStyle(color: fontColor, fontSize: fontSize)
                  : getSemiBoldStyle(color: fontColor, fontSize: fontSize),
            ),
          ],
        ),
      ),
    );
  }
}
