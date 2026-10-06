import 'package:eyvo_v3/app/sizes_helper.dart';
import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/constants.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/styles_manager.dart';
import 'package:eyvo_v3/core/resources/values_manager.dart';
import 'package:eyvo_v3/core/widgets/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomSearchField extends StatefulWidget {
  final TextEditingController controller;
  final String placeholderText;
  final TextInputType inputType;
  final bool autoFocus;
  final bool readOnly;
  final VoidCallback? onTap;

  const CustomSearchField({
    super.key,
    required this.controller,
    required this.placeholderText,
    this.inputType = TextInputType.number,
    this.autoFocus = false,
    this.readOnly = false,
    this.onTap,
  });

  @override
  State<CustomSearchField> createState() => _CustomSearchFieldState();
}

class _CustomSearchFieldState extends State<CustomSearchField> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: TextField(
        controller: widget.controller,
        autofocus: widget.autoFocus,
        maxLines: 1,
        readOnly: widget.readOnly,
        onTap: widget.onTap,
        textInputAction: TextInputAction.search,
        keyboardType: widget.inputType,
        style: TextStyle(
          overflow: TextOverflow.ellipsis,
          fontSize: 13,
          fontFamily: FontConstants.fontFamily,
          fontWeight: FontWeightManager.regular,
          color: ColorManager.black,
        ),
        inputFormatters: [
          LengthLimitingTextInputFormatter(AppConstants.maxCharacters),
        ],
        decoration: InputDecoration(
          hintText: widget.placeholderText,
          hintStyle: getRegularStyle(
            color: ColorManager.lightGrey3,
            fontSize: 14,
          ),
          fillColor: ColorManager.white,
          filled: true,
          border: OutlineInputBorder(
            borderSide:
                BorderSide(color: ColorManager.light2, width: AppSize.s1),
          ),
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: ColorManager.light2, width: AppSize.s1),
            borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: ColorManager.light2, width: AppSize.s1),
            borderRadius: const BorderRadius.all(Radius.circular(AppSize.s8)),
          ),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
          suffixIcon: Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Image.asset(
              ImageAssets.searchIcon,
              width: 22,
              height: 22,
              fit: BoxFit.contain,
            ),
          ),
          suffixIconConstraints: const BoxConstraints(
            maxHeight: 80,
            maxWidth: 80,
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final String iconString;
  final String hintText;
  final TextEditingController controller;
  final bool isObscureText;
  final bool isValid;
  final TextInputType inputType;
  final VoidCallback onTextChanged;
  const CustomTextField(
      {super.key,
      required this.iconString,
      required this.hintText,
      required this.controller,
      this.isObscureText = false,
      required this.isValid,
      this.inputType = TextInputType.text,
      required this.onTextChanged});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 70,
      child: TextField(
        controller: controller,
        obscureText: isObscureText,
        obscuringCharacter: "*",
        keyboardType: inputType,
        autocorrect: false,
        inputFormatters: [
          LengthLimitingTextInputFormatter(AppConstants.maxCharacters),
        ],
        spellCheckConfiguration: const SpellCheckConfiguration.disabled(),
        textCapitalization: TextCapitalization.none,
        style:
            getRegularStyle(color: ColorManager.grey1, fontSize: FontSize.s20),
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.only(left: 12, right: 5),
            child: CustomIconButton(imageString: iconString),
          ),
          labelText: hintText,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          border: OutlineInputBorder(
            borderSide: BorderSide(
              color: isValid ? ColorManager.grey2 : ColorManager.darkRed,
              width: AppSize.s1_5,
            ),
            borderRadius: BorderRadius.circular(AppSize.s15),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
              color: isValid ? ColorManager.blue : ColorManager.darkRed,
              width: AppSize.s1_5,
            ),
            borderRadius: BorderRadius.circular(AppSize.s15),
          ),
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          floatingLabelAlignment: FloatingLabelAlignment.start,
          floatingLabelStyle: getRegularStyle(
              color: ColorManager.light1, fontSize: FontSize.s18),
          hintStyle: getRegularStyle(
              color: ColorManager.grey1, fontSize: FontSize.s16),
          labelStyle: getRegularStyle(
              color: ColorManager.light1, fontSize: FontSize.s14),
          errorStyle: const TextStyle(height: 0, color: Colors.transparent),
        ),
        onChanged: (text) => onTextChanged,
        onTapOutside: (event) {
          FocusManager.instance.primaryFocus?.unfocus();
        },
      ),
    );
  }
}

class OTPField extends StatefulWidget {
  final Function(String) onOTPComplete;
  final bool isValid;
  const OTPField(
      {super.key, required this.onOTPComplete, required this.isValid});

  @override
  OTPFieldState createState() => OTPFieldState();
}

class OTPFieldState extends State<OTPField> {
  final int fieldLength = 4;
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < fieldLength; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _handleSubmit() {
    String otp = _controllers.map((controller) => controller.text).join();
    widget.onOTPComplete(otp);
    FocusScope.of(context).unfocus();
  }

  void _clearFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    setState(() {
      currentIndex = 0;
    });
  }

  Widget _buildTextField(int index) {
    return SizedBox(
      width: displayWidth(context) * 0.23,
      height: 80,
      child: Padding(
        padding: const EdgeInsets.only(top: 0, left: 8, right: 8, bottom: 0),
        child: TextField(
          style: getSemiBoldStyle(
              color: ColorManager.darkBlue, fontSize: FontSize.s25_5),
          autofocus: true,
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.top,
          maxLength: 1,
          decoration: const InputDecoration(
            counterText: "",
            border: OutlineInputBorder(),
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              if (index + 1 != fieldLength) {
                FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
              } else {
                _handleSubmit();
              }
            } else if (value.isEmpty && index != 0) {
              FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
            }
          },
          onSubmitted: (value) {
            if (index + 1 == fieldLength) {
              _handleSubmit();
            }
          },
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(OTPField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isValid && oldWidget.isValid) {
      _clearFields();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children:
              List.generate(fieldLength, (index) => _buildTextField(index)),
        ),
      ],
    );
  }
}

class PINField extends StatefulWidget {
  final Function(String) onPINComplete;
  final bool isValid;
  final bool isEnabled;
  const PINField(
      {super.key,
      required this.onPINComplete,
      required this.isValid,
      this.isEnabled = true});

  @override
  PINFieldState createState() => PINFieldState();
}

class PINFieldState extends State<PINField> {
  final int fieldLength = 4;
  final List<TextEditingController> _controllers = [];
  final List<FocusNode> _focusNodes = [];

  @override
  void initState() {
    super.initState();
    for (int i = 0; i < fieldLength; i++) {
      _controllers.add(TextEditingController());
      _focusNodes.add(FocusNode());
    }
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  void _handleSubmit() {
    String pin = _controllers.map((controller) => controller.text).join();
    widget.onPINComplete(pin);
    FocusScope.of(context).unfocus();
  }

  void _clearFields() {
    for (var controller in _controllers) {
      controller.clear();
    }
    _focusNodes[0].requestFocus();
  }

  Widget _buildTextField(int index) {
    return SizedBox(
      width: 95,
      height: 80,
      child: Padding(
        padding: const EdgeInsets.only(top: 0, left: 8, right: 8, bottom: 0),
        child: TextField(
          enabled: widget.isEnabled,
          obscureText: true,
          obscuringCharacter: '*',
          style: getSemiBoldStyle(
              color: ColorManager.darkBlue, fontSize: FontSize.s25_5),
          autofocus: true,
          controller: _controllers[index],
          focusNode: _focusNodes[index],
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.top,
          maxLength: 1,
          decoration: InputDecoration(
            errorText: widget.isValid ? null : '',
            errorStyle: const TextStyle(height: 0),
            counterText: "",
            border: const OutlineInputBorder(),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.s15),
              borderSide: BorderSide(
                color:
                    widget.isValid ? ColorManager.blue : ColorManager.darkRed,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppSize.s15),
              borderSide: BorderSide(
                color:
                    widget.isValid ? ColorManager.grey2 : ColorManager.darkRed,
              ),
            ),
          ),
          onChanged: (value) {
            if (value.isNotEmpty) {
              if (index + 1 != fieldLength) {
                FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
              } else {
                _handleSubmit();
              }
            } else if (value.isEmpty && index != 0) {
              FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
            }
          },
          onSubmitted: (value) {
            if (index + 1 == fieldLength) {
              _handleSubmit();
            }
          },
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(PINField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.isValid && oldWidget.isValid) {
      _clearFields();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: List.generate(fieldLength, (index) => _buildTextField(index)),
    );
  }
}
