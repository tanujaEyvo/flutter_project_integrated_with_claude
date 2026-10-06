import 'dart:io';

import 'package:dotted_border/dotted_border.dart';
import 'package:eyvo_v3/api/response_models/order_header_response.dart';
import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:eyvo_v3/core/resources/constants.dart';
import 'package:eyvo_v3/core/widgets/progress_indicator.dart';
import 'package:flutter/material.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/styles_manager.dart';
import 'package:eyvo_v3/core/widgets/searchable_dropdown_modal.dart';

class FormFieldHelper {
  //-------------------- TEXT FIELD --------------------

  static Widget buildTextField({
    required String label,
    required TextEditingController controller,
    required String hintText,
    TextInputType keyboardType = TextInputType.text,
    bool isRequired = false,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getSemiBoldStyle(
            color: ColorManager.black,
            fontSize: FontSize.s14,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            FocusScope(
              canRequestFocus: !readOnly,
              child: TextField(
                controller: controller,
                keyboardType: keyboardType,
                readOnly: readOnly,
                style: TextStyle(
                  color: ColorManager.black,
                  fontSize: FontSize.s14,
                ),
                decoration: InputDecoration(
                  hintText: hintText,
                  filled: true,
                  fillColor: readOnly
                      ? ColorManager.readOnlyColor
                      : ColorManager.white,
                  hintStyle: getMediumStyle(
                    color: ColorManager.lightGrey,
                    fontSize: FontSize.s14,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),

                  //Show icon only in read-only mode
                  suffixIcon: readOnly
                      ? Icon(
                          Icons.lock_outline,
                          color: ColorManager.lightGrey3,
                          size: 20,
                        )
                      : null,

                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: readOnly
                          ? ColorManager.lightGrey
                          : ColorManager.darkGrey,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color:
                          readOnly ? ColorManager.lightGrey : ColorManager.blue,
                      width: readOnly ? 1.0 : 2.0,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: ColorManager.lightGrey,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
            ),

            // Red triangle indicator (if required)
            if (isRequired)
              Positioned(
                right: 0,
                top: 0,
                child: CustomPaint(
                  size: const Size(12, 12),
                  painter: _RedTrianglePainter(),
                ),
              ),
          ],
        ),
      ],
    );
  }

  //-------------------- MULTILINE TEXT FIELD --------------------
  static Widget buildMultilineTextField({
    required String label,
    required TextEditingController controller,
    String? hintText,
    int maxLines = 4,
    bool isRequired = false,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              label,
              style: getSemiBoldStyle(
                color: ColorManager.black,
                fontSize: FontSize.s14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.topRight,
          children: [
            FocusScope(
              canRequestFocus: !readOnly,
              child: TextField(
                controller: controller,
                maxLines: maxLines,
                readOnly: readOnly,
                style: TextStyle(
                  fontSize: FontSize.s14,
                  color: ColorManager.black,
                ),
                decoration: InputDecoration(
                  filled: true,
                  fillColor: readOnly
                      ? ColorManager.readOnlyColor
                      : ColorManager.white,
                  hintText: hintText,
                  hintStyle: getMediumStyle(
                    color: ColorManager.lightGrey,
                    fontSize: FontSize.s14,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: ColorManager.darkGrey,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color:
                          readOnly ? ColorManager.darkGrey : ColorManager.blue,
                      width: readOnly ? 1.0 : 2.0,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: ColorManager.darkGrey,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
            ),

            // Lock icon when readonly
            if (readOnly)
              Positioned(
                right: 8,
                top: 8,
                child: Icon(
                  Icons.lock_outline,
                  size: 20,
                  color: ColorManager.lightGrey3,
                ),
              ),

            // Red triangle indicator (if required)
            if (isRequired)
              Positioned(
                right: 0,
                top: 0,
                child: CustomPaint(
                  size: const Size(16, 16),
                  painter: _RedTrianglePainter(),
                ),
              ),
          ],
        ),
      ],
    );
  }

  //-------------------- DROPDOWN FIELD --------------------
  static Widget buildDropdownField({
    required BuildContext context,
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
    bool isRequired = false, // new parameter
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getSemiBoldStyle(
            color: ColorManager.black,
            fontSize: FontSize.s14,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            GestureDetector(
              onTap: () async {
                final selected = await showModalBottomSheet<String>(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (_) => SearchableDropdownModal(
                    items: items,
                    selectedValue: value,
                  ),
                );
                if (selected != null) {
                  onChanged(selected);
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: ColorManager.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: ColorManager.lightGrey),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      value ?? "Select $label",
                      style: TextStyle(
                        fontSize: FontSize.s14,
                        color: value == null
                            ? ColorManager.grey
                            : ColorManager.black,
                      ),
                    ),
                    const Icon(Icons.arrow_drop_down),
                  ],
                ),
              ),
            ),
            // Red triangle if required
            if (isRequired)
              Positioned(
                right: 0,
                top: 0,
                child: CustomPaint(
                  size: const Size(12, 12),
                  painter: _RedTrianglePainter(),
                ),
              ),
          ],
        ),
      ],
    );
  }

//----------------------------------DROPDOWN FIELD with IDs---------------------------------------------

  static Widget buildDropdownFieldWithIds({
    required BuildContext context,
    required String label,
    required String? value, // String ID
    required List<DropdownItem> items,
    required ValueChanged<String?> onChanged, // String ID
    bool isRequired = false,
    String? apiDisplayValue,
    bool readOnly = false,
  }) {
    // Determine display value for the given ID
    String? displayValue;

    if (value != null) {
      try {
        final foundItem = items.firstWhere(
          (item) => item.id == value,
          orElse: () => DropdownItem(id: '', value: ''),
        );
        displayValue =
            foundItem.id.isNotEmpty ? foundItem.value : apiDisplayValue;
      } catch (e) {
        displayValue = apiDisplayValue;
      }
    } else {
      displayValue = apiDisplayValue;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getSemiBoldStyle(
            color: ColorManager.black,
            fontSize: FontSize.s14,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            GestureDetector(
              onTap: readOnly
                  ? null
                  : () async {
                      List<String> displayItems =
                          items.map((item) => item.value).toList();

                      if (apiDisplayValue != null &&
                          !displayItems.contains(apiDisplayValue)) {
                        displayItems.add(apiDisplayValue!);
                      }

                      final selectedDisplayValue =
                          await showModalBottomSheet<String>(
                        context: context,
                        isScrollControlled: true,
                        shape: const RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.vertical(top: Radius.circular(16)),
                        ),
                        builder: (_) => SearchableDropdownModal(
                          items: displayItems,
                          selectedValue: displayValue,
                        ),
                      );

                      if (selectedDisplayValue != null) {
                        String selectedId;
                        if (selectedDisplayValue == apiDisplayValue) {
                          selectedId = value ?? '';
                        } else {
                          selectedId = items
                              .firstWhere(
                                  (item) => item.value == selectedDisplayValue)
                              .id;
                        }
                        onChanged(selectedId);
                      }
                    },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  color: readOnly
                      ? ColorManager.readOnlyColor
                      : ColorManager.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: ColorManager.darkGrey,
                    width: 1.0,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        displayValue ?? "Select $label",
                        style: TextStyle(
                          fontSize: FontSize.s14,
                          color: displayValue == null
                              ? ColorManager.grey
                              : ColorManager.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    // Row(
                    //   mainAxisSize: MainAxisSize.min,
                    //   children: [
                    //     if (readOnly) ...[
                    //       Icon(
                    //         Icons.arrow_drop_down,
                    //         color: ColorManager.lightGrey3,
                    //       ),
                    //       Icon(
                    //         Icons.lock_outline,
                    //         size: 20,
                    //         color: ColorManager.lightGrey3,
                    //       ),
                    //     ] else
                    //       Icon(
                    //         Icons.arrow_drop_down,
                    //         color: ColorManager.darkGrey,
                    //       ),
                    //   ],
                    // )

                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (readOnly)
                          Icon(
                            Icons.lock_outline,
                            size: 20,
                            color: ColorManager.lightGrey3,
                          )
                        else
                          Icon(
                            Icons.arrow_drop_down,
                            color: ColorManager.darkGrey,
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // Red triangle (if required)
            if (isRequired)
              Positioned(
                right: 0,
                top: 0,
                child: CustomPaint(
                  size: const Size(12, 12),
                  painter: _RedTrianglePainter(),
                ),
              ),
          ],
        ),
      ],
    );
  }

  //-------------------- DATE PICKER FIELD --------------------
  static Widget buildDatePickerField({
    required BuildContext context,
    required String label,
    required TextEditingController controller,
    bool isRequired = false,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getSemiBoldStyle(
            color: ColorManager.black,
            fontSize: FontSize.s14,
          ),
        ),
        const SizedBox(height: 8),
        Stack(
          children: [
            FocusScope(
              canRequestFocus: !readOnly,
              child: TextField(
                controller: controller,
                readOnly: true,
                onTap: readOnly
                    ? null
                    : () async {
                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                          builder: (context, child) {
                            return Theme(
                              data: Theme.of(context).copyWith(
                                colorScheme: ColorScheme.light(
                                  primary: ColorManager.darkBlue,
                                  onPrimary: ColorManager.white,
                                  onSurface: ColorManager.darkGrey,
                                ),
                                dialogBackgroundColor: ColorManager.white,
                              ),
                              child: child!,
                            );
                          },
                        );
                        if (pickedDate != null) {
                          controller.text =
                              "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
                        }
                      },
                style: TextStyle(
                  fontSize: FontSize.s14,
                  color: ColorManager.black,
                ),
                decoration: InputDecoration(
                  hintText: "Select date",
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: Icon(
                          Icons.calendar_month,
                          size: readOnly ? 20 : 25,
                          color: readOnly
                              ? ColorManager.lightGrey3
                              : ColorManager.darkGrey,
                        ),
                      ),
                      if (readOnly)
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.lock_outline,
                            size: 20,
                            color: ColorManager.lightGrey3,
                          ),
                        ),
                    ],
                  ),
                  filled: true,
                  fillColor: readOnly
                      ? ColorManager.readOnlyColor
                      : ColorManager.white,
                  hintStyle: getMediumStyle(
                    color: ColorManager.lightGrey,
                    fontSize: FontSize.s14,
                  ),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: readOnly
                          ? ColorManager.darkGrey
                          : ColorManager.darkGrey,
                      width: 1.0,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color:
                          readOnly ? ColorManager.darkGrey : ColorManager.blue,
                      width: readOnly ? 1.0 : 2.0,
                    ),
                  ),
                  disabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: ColorManager.darkGrey,
                      width: 1.0,
                    ),
                  ),
                ),
              ),
            ),

            // Red triangle indicator (if required)
            if (isRequired)
              Positioned(
                right: 0,
                top: 0,
                child: CustomPaint(
                  size: const Size(12, 12),
                  painter: _RedTrianglePainter(),
                ),
              ),
          ],
        ),
      ],
    );
  }

  //-------------------- INFO CARD --------------------
  static Widget buildInfoCard({
    required int index,
    required IconData icon,
    required String title,
    required String subtitle,
    required List<bool> isCardSelected,
    required VoidCallback onTap,
  }) {
    final isSelected = isCardSelected[index];

    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isSelected ? ColorManager.darkBlue : ColorManager.lightGrey,
            width: 1,
          ),
        ),
        color: isSelected ? ColorManager.highlightColor : Colors.white,
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(icon, color: ColorManager.darkBlue, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: getSemiBoldStyle(
                        color: ColorManager.black,
                        fontSize: FontSize.s16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: getRegularStyle(
                        color: ColorManager.darkGrey,
                        fontSize: FontSize.s14,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: ColorManager.darkBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.check, color: Colors.white, size: 16),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // -------------------- UPLOAD BOX --------------------
  static Widget buildUploadBox({
    required File? selectedFile,
    required Function() onPickFile,
    required Function() onRemoveFile,
    bool isUploading = false,
  }) {
    return DottedBorder(
      borderType: BorderType.RRect,
      radius: const Radius.circular(12),
      dashPattern: const [6, 3],
      color: ColorManager.lightGrey1,
      strokeWidth: 1,
      child: Container(
        width: double.infinity,
        height: 180,
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: selectedFile == null
            ? Center(
                child: GestureDetector(
                  onTap: onPickFile,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(ImageAssets.uploadIcon2, height: 60),
                      const SizedBox(height: 8),
                      Text(
                        "Choose a file",
                        style: getBoldStyle(
                          color: ColorManager.black,
                          fontSize: FontSize.s16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        "Supports JPEG,PNG,PDF up to 5MB",
                        style: getRegularStyle(
                          color: ColorManager.black,
                          fontSize: FontSize.s14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : Stack(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.file(
                      selectedFile,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: onRemoveFile,
                      child: CircleAvatar(
                        backgroundColor: ColorManager.red,
                        radius: 16,
                        child: Icon(Icons.delete,
                            size: 18, color: ColorManager.white),
                      ),
                    ),
                  ),
                  if (isUploading)
                    const Positioned.fill(
                      child: Center(
                        child: SizedBox(
                          height: 24,
                          width: 24,
                          child: CustomProgressIndicator(),
                        ),
                      ),
                    ),
                ],
              ),
      ),
    );
  }

  //-------------------- FILE STATUS WIDGET --------------------
  static Widget buildFileStatus({
    required bool isInvalidFormat,
    required bool isFileTooLarge,
    String? fileSize,
  }) {
    if (isInvalidFormat) {
      return Text(
        "Invalid format. Please upload JPG, JPEG, PNG, HEIC, or HEIF.",
        style: TextStyle(color: ColorManager.red, fontWeight: FontWeight.bold),
      );
    } else if (isFileTooLarge) {
      return Text(
        "The file size exceeds ${AppConstants.imageSizeLimitMB} MB",
        style: TextStyle(color: ColorManager.red, fontWeight: FontWeight.bold),
      );
    } else if (fileSize != null) {
      return Text(
        "Size: $fileSize",
        style:
            TextStyle(color: ColorManager.green, fontWeight: FontWeight.bold),
      );
    }
    return const SizedBox.shrink();
  }
}

// Custom painter for the red triangle
class _RedTrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = ColorManager.red2;
    final path = Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, 0)
      ..close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
