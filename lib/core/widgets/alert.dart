import 'package:eyvo_v3/app/sizes_helper.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/widgets/button.dart';
import 'package:eyvo_v3/core/widgets/title_header.dart';
import 'package:flutter/material.dart';

class CustomImageActionAlert extends StatefulWidget {
  final String iconString;
  final String imageString;
  final String titleString;
  final String subTitleString;
  final String destructiveActionString;
  final String normalActionString;
  final VoidCallback onDestructiveActionTap;
  final VoidCallback onNormalActionTap;

  final bool isNormalAlert;
  final bool normalAlertButtonColor;
  final bool isConfirmationAlert;
  final Color? destructiveButtonColor;

  const CustomImageActionAlert({
    super.key,
    required this.iconString,
    required this.imageString,
    required this.titleString,
    required this.subTitleString,
    required this.destructiveActionString,
    required this.normalActionString,
    required this.onDestructiveActionTap,
    required this.onNormalActionTap,
    this.isNormalAlert = false,
    this.normalAlertButtonColor = false,
    this.isConfirmationAlert = false,
    this.destructiveButtonColor,
  });

  @override
  State<CustomImageActionAlert> createState() => _CustomImageActionAlertState();
}

class _CustomImageActionAlertState extends State<CustomImageActionAlert> {
  @override
  Widget build(BuildContext context) {
    // Default to Green if no color provided
    final Color destructiveColor =
        widget.destructiveButtonColor ?? ColorManager.green;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: displayWidth(context) - 40,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Image with constrained height
              if (widget.imageString.isNotEmpty)
                Image.asset(
                  widget.imageString,
                  height: 120, // Fixed height to prevent overflow
                  width: 120,
                  fit: BoxFit.contain,
                ),

              if (widget.imageString.isNotEmpty) const SizedBox(height: 16),

              // Title
              CenterTitleHeader(
                titleText: widget.titleString,
                detailText: widget.subTitleString,
              ),

              const SizedBox(height: 24),

              // Buttons Row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // NORMAL BUTTON
                  if (widget.normalActionString.isNotEmpty)
                    Expanded(
                      child: CustomTextActionButton(
                        backgroundColor: widget.isNormalAlert
                            ? widget.isConfirmationAlert
                                ? ColorManager.white
                                : widget.normalAlertButtonColor
                                    ? ColorManager.appBarGrey
                                    : ColorManager.green
                            : Colors.transparent,
                        fontColor: widget.isNormalAlert
                            ? widget.isConfirmationAlert
                                ? ColorManager.darkRed
                                : ColorManager.white
                            : ColorManager.lightGrey1,
                        borderColor: widget.isConfirmationAlert
                            ? ColorManager.darkRed
                            : widget.normalAlertButtonColor
                                ? ColorManager.appBarGrey
                                : ColorManager.green,
                        buttonText: widget.normalActionString,
                        onTap: widget.onNormalActionTap,
                      ),
                    ),

                  if (widget.normalActionString.isNotEmpty &&
                      widget.destructiveActionString.isNotEmpty)
                    const SizedBox(width: 10),

                  // DESTRUCTIVE BUTTON
                  if (widget.destructiveActionString.isNotEmpty)
                    Expanded(
                      child: CustomTextActionButton(
                        buttonText: widget.destructiveActionString,
                        backgroundColor: destructiveColor,
                        fontColor: ColorManager.white,
                        borderColor: destructiveColor,
                        onTap: widget.onDestructiveActionTap,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomRejectReasonAlert extends StatefulWidget {
  final String iconString;
  final String imageString;
  final String titleString;
  final String rejectActionString;
  final String cancelActionString;
  final Function(String reason) onRejectTap;
  final VoidCallback onCancelTap;

  const CustomRejectReasonAlert({
    super.key,
    required this.iconString,
    required this.imageString,
    required this.titleString,
    required this.rejectActionString,
    required this.cancelActionString,
    required this.onRejectTap,
    required this.onCancelTap,
  });

  @override
  State<CustomRejectReasonAlert> createState() =>
      _CustomRejectReasonAlertState();
}

class _CustomRejectReasonAlertState extends State<CustomRejectReasonAlert> {
  final TextEditingController _controller = TextEditingController();
  final int _maxLength = 255;
  String? _errorText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ColorManager.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      content: SingleChildScrollView(
        child: SizedBox(
          width: MediaQuery.of(context).size.width - 30, // wider popup
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 30),
              SizedBox(
                height: 120,
                child: Image.asset(widget.imageString, fit: BoxFit.contain),
              ),

              const SizedBox(height: 20),
              Center(
                child: Text(
                  widget.titleString,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: FontSize.s16, // smaller than before
                    fontWeight: FontWeight.w600,
                    color: ColorManager.darkBlue,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              /// TextField Section
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _controller,
                    maxLength: _maxLength,
                    maxLines: 6,
                    onChanged: (_) {
                      setState(() {
                        _errorText = null;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: "Enter Reject Reason Here...",
                      hintStyle: TextStyle(
                        fontSize: FontSize.s14,
                        color: ColorManager.lightGrey,
                      ),
                      alignLabelWithHint: true,
                      errorText: _errorText,
                      errorStyle: TextStyle(
                        fontSize: FontSize.s14,
                        fontWeight: FontWeight.bold,
                        color: ColorManager.red,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.fromLTRB(12, 16, 12, 12),
                      counterText: "",
                    ),
                  ),
                  const SizedBox(height: 4),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      "Characters remaining ${_maxLength - _controller.text.length}",
                      style: TextStyle(
                        fontSize: FontSize.s14,
                        color: ColorManager.darkGrey,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// Button Row

              Row(
                children: [
                  // Left: Cancel
                  Expanded(
                    child: CustomTextActionButton(
                      buttonText: widget.cancelActionString,
                      backgroundColor: ColorManager.white,
                      fontColor: ColorManager.darkRed,
                      borderColor: ColorManager.darkRed,
                      onTap: widget.onCancelTap,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Right: Reject
                  Expanded(
                    child: CustomTextActionButton(
                      buttonText: widget.rejectActionString,
                      backgroundColor: ColorManager.red,
                      fontColor: ColorManager.white,
                      borderColor: ColorManager.red,
                      onTap: () {
                        if (_controller.text.trim().isEmpty) {
                          setState(() {
                            _errorText = "Reason is required";
                          });
                          return;
                        }
                        widget.onRejectTap(_controller.text.trim());
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
