import 'package:eyvo_v3/app/app_prefs.dart';
import 'package:eyvo_v3/app/sizes_helper.dart';
import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/strings_manager.dart';
import 'package:eyvo_v3/core/resources/styles_manager.dart';
import 'package:eyvo_v3/core/widgets/alert.dart';
import 'package:eyvo_v3/core/widgets/button.dart';
import 'package:eyvo_v3/core/widgets/title_header.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

void showSnackBar(BuildContext context, String content) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        backgroundColor: ColorManager.green,
        content: Text(content,
            style: getRegularStyle(
                color: ColorManager.white, fontSize: FontSize.s16)),
      ),
    );
}

void showAlertDialog(BuildContext context, String title, String content) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            child: Text(AppStrings.ok,
                style: getBoldStyle(
                    color: ColorManager.black, fontSize: FontSize.s20)),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ],
      );
    },
  );
}

void showSuccessDialog(
  BuildContext context,
  String imageString,
  String titleString,
  String messageString,
  bool isNeedToPopBack, {
  bool normalAlertButtonColor = false,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return CustomImageActionAlert(
        iconString: '',
        imageString: imageString,
        titleString: titleString,
        subTitleString: messageString,
        destructiveActionString: '',
        normalActionString: AppStrings.ok,
        onDestructiveActionTap: () {},
        onNormalActionTap: () {
          Navigator.pop(context);
          if (isNeedToPopBack) {
            Navigator.pop(context);
          }
        },
        isNormalAlert: true,
        normalAlertButtonColor: normalAlertButtonColor,
      );
    },
  );
}

void showErrorDialog(
    BuildContext context, String message, bool isNeedToPopBack) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomImageActionAlert(
          iconString: '',
          imageString: ImageAssets.errorMessageIcon,
          titleString: '',
          subTitleString: message,
          destructiveActionString: '',
          normalActionString: AppStrings.ok,
          onDestructiveActionTap: () {},
          onNormalActionTap: () {
            Navigator.pop(context);
            if (isNeedToPopBack) {
              Navigator.pop(context);
            }
          },
          isNormalAlert: true);
    },
  );
}

void showImageActionDialog({
  required BuildContext context,
  required String imageString,
  required String titleString,
  required String messageString,
  String destructiveActionString = '',
  String normalActionString = 'OK',
  VoidCallback? onDestructiveActionTap,
  VoidCallback? onNormalActionTap,
  bool isNeedToPopBack = false,
}) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return CustomImageActionAlert(
        iconString: '',
        imageString: imageString,
        titleString: titleString,
        subTitleString: messageString,
        destructiveActionString: destructiveActionString,
        normalActionString: normalActionString,
        onDestructiveActionTap: onDestructiveActionTap ?? () {},
        onNormalActionTap: () {
          Navigator.pop(context); // close dialog

          if (isNeedToPopBack) {
            Navigator.pop(context); // go back if needed
          }

          if (onNormalActionTap != null) {
            onNormalActionTap();
          }
        },
        isNormalAlert: true,
      );
    },
  );
}

void showImageMessageDialog({
  required BuildContext context,
  required String imageString,
  required String titleString,
  required String messageString,
  bool isDismissible = false,
  bool preventBackPress = false,
  VoidCallback? onOkPressed,
}) {
  showDialog(
    context: context,
    barrierDismissible: isDismissible,
    builder: (BuildContext context) {
      final mediaQuery = MediaQuery.of(context);
      final screenWidth = mediaQuery.size.width;
      final screenHeight = mediaQuery.size.height;
      final isLandscape = mediaQuery.orientation == Orientation.landscape;

      // Responsive image size
      final double imageSize = isLandscape
          ? (screenHeight * 0.35).clamp(70.0, 120.0)
          : (screenWidth * 0.4).clamp(100.0, 180.0);

      Widget dialog = AlertDialog(
        backgroundColor: ColorManager.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        content: SizedBox(
          width: isLandscape ? screenWidth * 0.65 : screenWidth - 30,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  imageString,
                  width: imageSize,
                  height: imageSize,
                  fit: BoxFit.contain,
                ),

                SizedBox(
                  height: isLandscape ? 8 : 20,
                ),

                CenterTitleHeader(
                  titleText: titleString,
                  detailText: messageString,
                ),

                SizedBox(
                  height: isLandscape ? 8 : 20,
                ),

                // OK button using CustomButton
                if (onOkPressed != null)
                  CustomButton(
                    buttonText: 'Update Now',
                    onTap: onOkPressed,
                    isEnabled: true,
                    isDefault: false,
                    height: 45,
                  ),
              ],
            ),
          ),
        ),
      );

      if (preventBackPress) {
        dialog = WillPopScope(
          onWillPop: () async => false,
          child: dialog,
        );
      }

      return dialog;
    },
  );
}

String getFormattedPriceString(double price) {
  var priceFormatter = NumberFormat.currency(
      locale: 'en_US', symbol: '', decimalDigits: SharedPrefs().decimalPlaces);
  String formattedPrice = priceFormatter.format(price);
  return formattedPrice;
}

String formatQuantityString(
  double? value, {
  int numberOfDecimal = 0,
  bool decimalTruncate = false,
}) {
  if (numberOfDecimal == 0) {
    numberOfDecimal = SharedPrefs().decimalplacesquantity;
  }

  if (value == null || value.isNaN) {
    value = 0;
  }

  double result = value;

  // ---- Decimal Truncate logic (mirrors C# exactly) ----
  if (decimalTruncate) {
    final strValue = value.toString();
    if (strValue.contains('.')) {
      final strSplitDecimal = strValue.split('.');
      if (strSplitDecimal.length > 1) {
        var decimalPart = strSplitDecimal[1];
        if (decimalPart.length > 2) {
          if (decimalPart.length == 6) {
            numberOfDecimal = 5;
            if (decimalPart.substring(decimalPart.length - 1) == '0') {
              decimalPart = decimalPart.substring(0, decimalPart.length - 1);
            }
          }
          if (decimalPart.length == 5) {
            numberOfDecimal = 5;
            if (decimalPart.substring(decimalPart.length - 1) == '0') {
              decimalPart = decimalPart.substring(0, decimalPart.length - 1);
              numberOfDecimal = 4;
            }
          }
          if (decimalPart.length == 4) {
            numberOfDecimal = 4;
            if (decimalPart.substring(decimalPart.length - 1) == '0') {
              decimalPart = decimalPart.substring(0, decimalPart.length - 1);
              numberOfDecimal = 3;
            }
          }
          if (decimalPart.length == 3) {
            numberOfDecimal = 3;
            if (decimalPart.substring(decimalPart.length - 1) == '0') {
              decimalPart = decimalPart.substring(0, decimalPart.length - 1);
              numberOfDecimal = 2;
            }
          }
        } else {
          numberOfDecimal = 2;
        }
        result = double.parse('${strSplitDecimal[0]}.$decimalPart');
      }
    }
  }

  // ---- Format with NumberOfDecimal places ----
  final pattern = numberOfDecimal > 0 ? '0.${'0' * numberOfDecimal}' : '0';
  final formatter = NumberFormat(pattern, 'en_US');
  String formatted = formatter.format(result);

  // ✨ NEW: trim trailing zeros, but always keep at least 2 decimals
  if (formatted.contains('.')) {
    formatted =
        formatted.replaceAll(RegExp(r'0+$'), ''); // strip trailing zeros
    final dotIndex = formatted.indexOf('.');
    if (formatted.length - dotIndex - 1 < 2) {
      formatted = formatted.padRight(dotIndex + 3, '0'); // pad back to 2
    }
  }

  return formatted;
}

/// Same as [formatQuantityString] but returns an int-style string
/// (no decimals) — for non-splittable items.
String formatQuantityInt(double value) {
  return value.toInt().toString();
}

/// Parses a quantity string that may contain thousands separators.
/// Returns 0 when the input is empty or invalid.
double parseQuantityString(String text) {
  return double.tryParse(text.replaceAll(',', '').trim()) ?? 0.0;
}

// Internal helper: 10^dp without pulling in dart:math
double _pow10(int dp) {
  double r = 1;
  for (var i = 0; i < dp; i++) {
    r *= 10;
  }
  return r;
}

//Converts a number directly to a string with a fixed number of decimal places
String getFormattedString(double number) {
  return number.toStringAsFixed(SharedPrefs().decimalPlaces);
}

// String getFormattedPriceStringPrice(double price) {
//   var priceFormatter = NumberFormat.currency(
//       locale: 'en_US',
//       symbol: '',
//       decimalDigits: SharedPrefs().decimalplacesprice);
//   String formattedPrice = priceFormatter.format(price);
//   return formattedPrice;
// }
String getFormattedPriceStringPrice(double price) {
  var priceFormatter = NumberFormat.currency(
      locale: 'en_US',
      symbol: '',
      decimalDigits: SharedPrefs().decimalplacesprice);
  String formattedPrice = priceFormatter.format(price);

  // Ensure at least two decimal places are retained
  if (formattedPrice.contains('.')) {
    formattedPrice =
        formattedPrice.replaceAll(RegExp(r'0+$'), ''); // Remove trailing zeroes

    // Ensure at least two decimal places remain
    int decimalIndex = formattedPrice.indexOf('.');
    if (decimalIndex != -1 && formattedPrice.length - decimalIndex - 1 < 2) {
      formattedPrice = formattedPrice.padRight(decimalIndex + 3, '0');
    }
  }

  return formattedPrice;
}

// String getFormattedStringPrice(double number) {
//   return number.toStringAsFixed(SharedPrefs().decimalplacesprice);
// }
String getFormattedStringPrice(double number) {
  String formatted = number.toStringAsFixed(SharedPrefs()
      .decimalplacesprice); // Convert to string with 5 decimal places

  if (formatted.contains('.')) {
    formatted =
        formatted.replaceAll(RegExp(r'0+$'), ''); // Remove trailing zeroes

    // Ensure at least two decimal places remain
    int decimalIndex = formatted.indexOf('.');
    if (decimalIndex != -1 && formatted.length - decimalIndex - 1 < 2) {
      formatted = formatted.padRight(decimalIndex + 3, '0');
    }
  }

  return formatted;
}

String getDefaultString(String formattedString) {
  return formattedString.replaceAll(',', '');
}

void navigateToScreen(BuildContext context, Widget screen) {
  Navigator.of(context).push(
    PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return child;
      },
    ),
  );
}

class DecimalTextInputFormatter extends TextInputFormatter {
  final int decimalPlaces;
  final double minValue;
  final double maxValue;

  DecimalTextInputFormatter({
    required this.decimalPlaces,
    required this.minValue,
    required this.maxValue,
  });

  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final text = newValue.text;

    // Allow empty input
    if (text.isEmpty) {
      return newValue;
    }

    // Allow input that matches the regex pattern
    final regExp = RegExp(r'^\d*\.?\d{0,' + decimalPlaces.toString() + r'}$');
    if (regExp.hasMatch(text)) {
      // Parse the text to a double and check if it's within the range, only if it's a complete number
      final double? value = double.tryParse(text);
      if (value != null) {
        if (value >= minValue && value <= maxValue) {
          return newValue;
        } else if (newValue.text != '0.00' && value <= maxValue) {
          return newValue; // Allow intermediate inputs like "0" or "0."
        } else {
          return oldValue;
        }
      }
    }

    // If the input doesn't match the pattern or is out of range, keep the old value
    return oldValue;
  }
}

String capitalizeFirstLetter(String? text) {
  if (text == null || text.isEmpty) return '';
  return text[0].toUpperCase() + text.substring(1).toLowerCase();
}

String getNormalizedStatus(String? status) {
  return (status != null && status.trim().isNotEmpty)
      ? status.trim().toUpperCase()
      : 'REJECTED';
}

Color getStatusColor(String? status) {
  switch (getNormalizedStatus(status)) {
    case 'UNISSUED':
      return const Color(0xFF09AF00);
    case 'ISSUED':
      return const Color(0xFF1976D2);
    case 'PARTIAL':
      return const Color(0xFF4DD0E1);
    case 'CLOSED':
      return const Color(0xFF8D6E63);
    case 'REJECTED':
      return const Color(0xFFC62809);
    case 'PENDING':
      return Colors.orange;
    case 'APPROVED':
      return const Color(0xFFAFB42B);
    case 'RECEIVED':
      return const Color(0xFFA07C03);
    case 'CANCELLED':
      return const Color(0xFFB0BEC5);
    default:
      return Colors.grey;
  }
}
