import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:dotted_border/dotted_border.dart';
import 'package:eyvo_v3/api/api_service/api_service.dart';
import 'package:eyvo_v3/api/response_models/imageUpload_response.dart';
import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/constants.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/strings_manager.dart';
import 'package:eyvo_v3/core/utils.dart';
import 'package:eyvo_v3/core/widgets/progress_indicator.dart';
import 'package:eyvo_v3/log_data.dart/logger_data.dart';
import 'package:eyvo_v3/services/image_upload_helper.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

/// -------------------- IMAGE PREVIEW BOX --------------------
class ImagePreviewBox extends StatelessWidget {
  final File? imageFile;
  final Uint8List? imageBytes;
  final VoidCallback? onTapUpload;
  final VoidCallback? onTapDelete;
  final bool isUploading;

  const ImagePreviewBox({
    Key? key,
    this.imageFile,
    this.imageBytes,
    this.onTapUpload,
    this.onTapDelete,
    this.isUploading = false, //  default
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.80,
      height: MediaQuery.of(context).size.height * 0.30,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          DottedBorder(
            borderType: BorderType.RRect,
            radius: const Radius.circular(12),
            dashPattern: const [6, 3],
            color: ColorManager.lightGrey1,
            strokeWidth: 1,
            child: Container(
              decoration: BoxDecoration(
                color: ColorManager.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: (imageFile == null && imageBytes == null)
                  ? _buildUploadPlaceholder()
                  : Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox.expand(
                          child: imageFile != null
                              ? Image.file(imageFile!, fit: BoxFit.cover)
                              : Image.memory(imageBytes!, fit: BoxFit.cover),
                        ),
                      ),
                    ),
            ),
          ),

          //  Delete button will not show while uploading
          if (!isUploading &&
              onTapDelete != null &&
              (imageFile != null || imageBytes != null))
            Positioned(
              top: -12,
              right: -12,
              child: GestureDetector(
                onTap: onTapDelete,
                child: Container(
                  decoration: BoxDecoration(
                    color: ColorManager.red,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.15),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(8),
                  child:
                      Icon(Icons.delete, color: ColorManager.white, size: 20),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildUploadPlaceholder() {
    return Center(
      child: GestureDetector(
        onTap: onTapUpload,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(
              ImageAssets.uploadImage,
              height: 50,
              width: 50,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 8),
            Text(
              "Click to upload",
              style: TextStyle(
                color: ColorManager.darkBlue,
                fontSize: FontSize.s16,
                fontWeight: FontWeightManager.medium,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Allowed formats: JPG, JPEG, PNG, HEIC, HEIF\n(Max ${AppConstants.imageSizeLimitMB} MB)",
              style: TextStyle(
                color: ColorManager.darkBlue,
                fontSize: FontSize.s14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class UploadingDots extends StatefulWidget {
  final String text;
  final TextStyle? style;
  final Duration duration;

  const UploadingDots({
    Key? key,
    this.text = "Uploading",
    this.style,
    this.duration = const Duration(milliseconds: 500),
  }) : super(key: key);

  @override
  _UploadingDotsState createState() => _UploadingDotsState();
}

class _UploadingDotsState extends State<UploadingDots> {
  int dotCount = 0;
  late final Timer _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(widget.duration, (timer) {
      setState(() {
        dotCount = (dotCount + 1) % 6; // 0 → 1 → 2 → 3 -> 4 ->5
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String dots = "".padRight(dotCount, '.').padRight(3, ' ');
    return Text("Uploading$dots", style: widget.style);
  }
}

/// -------------------- CUSTOM BUTTON --------------------
class CustomActionIconButton extends StatelessWidget {
  final String buttonText;
  final Color backgroundColor;
  final Color borderColor;
  final Color fontColor;
  final double buttonWidth;
  final double buttonHeight;
  final double fontSize;
  final bool isBoldFont;
  final bool isUploading;
  final IconData? icon;
  final Color? iconColor;
  final double? iconSize;
  final VoidCallback? onTap;

  const CustomActionIconButton({
    Key? key,
    required this.buttonText,
    required this.backgroundColor,
    required this.borderColor,
    required this.fontColor,
    required this.buttonWidth,
    required this.buttonHeight,
    required this.fontSize,
    this.isBoldFont = false,
    this.isUploading = false,
    this.icon,
    this.iconColor,
    this.iconSize,
    this.onTap,
  }) : super(key: key);

  Widget build(BuildContext context) {
    return SizedBox(
      width: buttonWidth,
      height: buttonHeight,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: borderColor),
          ),
        ),
        onPressed: (isUploading || onTap == null) ? null : onTap,
        icon: isUploading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CustomProgressIndicator(),
              )
            : (icon != null
                ? Icon(icon,
                    color: iconColor ?? fontColor, size: iconSize ?? 20)
                : const SizedBox.shrink()),
        label: isUploading
            ? UploadingDots(
                text: "Uploading",
                style: TextStyle(
                  color: ColorManager.darkBlue,
                  fontSize: fontSize,
                  fontWeight: isBoldFont ? FontWeight.bold : FontWeight.normal,
                ),
              )
            : Text(
                buttonText,
                style: TextStyle(
                  color: fontColor,
                  fontSize: fontSize,
                  fontWeight: isBoldFont ? FontWeight.bold : FontWeight.normal,
                ),
              ),
      ),
    );
  }
}

/// -------------------- UPLOAD IMAGE DIALOG --------------------
class ImageUploadPopup extends StatefulWidget {
  final ValueChanged<bool>? onUploadingChanged;

  const ImageUploadPopup({Key? key, this.onUploadingChanged}) : super(key: key);

  @override
  State<ImageUploadPopup> createState() => _ImageUploadPopupState();
}

class _ImageUploadPopupState extends State<ImageUploadPopup> {
  File? _selectedImage;
  bool _isUploading = false;
  String? _base64Image;
  String? _fileSize;
  bool _isFileTooLarge = false;
  String? _fileExtension;
  bool _isInvalidFormat = false;
  final ApiService apiService = ApiService();
  final ImageHelper _imageHelper = ImageHelper();
  bool isLoading = false;

  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 KB";

    const int kb = 1000;
    const int mb = kb * 1000;
    const int gb = mb * 1000;

    if (bytes >= gb) {
      return (bytes / gb).toStringAsFixed(decimals) + " GB";
    } else if (bytes >= mb) {
      return (bytes / mb).toStringAsFixed(decimals) + " MB";
    } else if (bytes >= kb) {
      return (bytes / kb).toStringAsFixed(decimals) + " KB";
    } else {
      return "$bytes B";
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imageHelper.pickImageWithChoice(context: context);
    if (pickedFile != null) {
      final bytes = await pickedFile.length();
      final ext = pickedFile.path.split('.').last.toLowerCase();

      setState(() {
        _fileExtension = ext;

        //  allow only JPG, JPEG, PNG, HEIC, HEIF
        _isInvalidFormat = !AppConstants.allowedImageFormats.contains(ext);

        _fileSize = _formatBytes(bytes, 2);
        LoggerData.dataLog("bytes = $bytes");
        LoggerData.dataLog("_formatBytes = ${_formatBytes(bytes, 2)}");

        _selectedImage = pickedFile;

        //  file size check
        _isFileTooLarge = bytes > AppConstants.imageSizeLimitBytes;
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() => _isUploading = true);
    widget.onUploadingChanged?.call(true);

    try {
      final bytes = await _selectedImage!.readAsBytes();
      final base64Image = base64Encode(bytes);

      String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      String azureImageName =
          "azureImageName_$timestamp.${_fileExtension ?? 'jpg'}";
      String fileName = _selectedImage!.path.split('/').last;

      Map<String, dynamic> data = {
        'fileName': fileName,
        'fileNameAzure': azureImageName,
        'fileContents': base64Image,
        "updateDB": false,
      };

      final jsonResponse =
          await apiService.postRequest(context, ApiService.imageUpload, data);

      if (jsonResponse != null) {
        final response = ImageUploadResponse.fromJson(jsonResponse);
        if (response.code == '200') {
          // Close popup and return data
          Navigator.of(context).pop({
            "fileName": fileName,
            "azureImageName": azureImageName,
            "base64": base64Image,
          });
        } else {
          showErrorDialog(context, response.message.join(', '), false);
        }
      }
    } finally {
      setState(() => _isUploading = false);
      widget.onUploadingChanged?.call(false);
    }
  }

  Widget _buildFileStatus() {
    if (_isInvalidFormat) {
      return Text(
        "Please upload images in JPG, JPEG, PNG, HEIC, or HEIF formats.",
        style: TextStyle(color: ColorManager.red, fontWeight: FontWeight.bold),
      );
    } else if (_isFileTooLarge) {
      return Text(
        "The file size exceeds ${AppConstants.imageSizeLimitMB} MB",
        style: TextStyle(color: ColorManager.red, fontWeight: FontWeight.bold),
      );
    } else {
      return Text(
        "Size: $_fileSize",
        style:
            TextStyle(color: ColorManager.green, fontWeight: FontWeight.bold),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            "Upload Image",
            style: TextStyle(
              color: ColorManager.darkBlue,
              fontSize: FontSize.s20,
              fontWeight: FontWeightManager.bold,
            ),
          ),
          const SizedBox(height: 16),
          ImagePreviewBox(
            imageFile: _selectedImage,
            onTapUpload: _pickImage,
            onTapDelete: () {
              setState(() {
                _selectedImage = null;
                _base64Image = null;
                _fileSize = null;
                _fileExtension = null;
                _isFileTooLarge = false;
                _isInvalidFormat = false;
              });
            },
            isUploading: _isUploading,
          ),
          const SizedBox(height: 10),
          if (_fileSize != null) _buildFileStatus(),
          const SizedBox(height: 20),
          CustomActionIconButton(
            buttonText: "Upload",
            backgroundColor: ColorManager.darkBlue,
            borderColor: Colors.transparent,
            fontColor: ColorManager.white,
            buttonWidth: MediaQuery.of(context).size.width * 0.80,
            buttonHeight: 50,
            fontSize: FontSize.s16,
            isUploading: _isUploading,
            icon: Icons.file_upload_outlined,
            iconColor: Colors.white,
            iconSize: 24,
            onTap:
                (_selectedImage == null || _isFileTooLarge || _isInvalidFormat)
                    ? null
                    : _uploadImage,
          ),
        ],
      ),
    );
  }
}

/// -------------------- SHOW IMAGE UPLOAD DIALOG --------------------

Future<Map<String, String>?> showImageUploadDialog(BuildContext context) {
  return showDialog<Map<String, String>>(
    context: context,
    barrierDismissible: false, // cannot close by tapping outside
    builder: (context) {
      final screenHeight = MediaQuery.of(context).size.height;
      final screenWidth = MediaQuery.of(context).size.width;

      bool isUploading = false; // track upload state at dialog level

      return StatefulBuilder(
        builder: (context, setState) {
          return WillPopScope(
            onWillPop: () async => !isUploading, // disable back when uploading
            child: Stack(
              children: [
                Dialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  insetPadding: const EdgeInsets.all(16),
                  backgroundColor: ColorManager.white,
                  child: ImageUploadPopup(
                    onUploadingChanged: (uploading) {
                      setState(() => isUploading = uploading);
                    },
                  ),
                ),

                //  Show close button only if not uploading
                if (!isUploading)
                  Positioned(
                    top: screenHeight * 0.18,
                    right: screenWidth * 0.07,
                    child: GestureDetector(
                      onTap: () => Navigator.of(context).pop(),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(6),
                        child: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 22,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      );
    },
  );
}

/// -------------------- SHOW REMOVE IMAGE DIALOG --------------------
Future<bool?> showRemoveImageDialog(
  BuildContext context,
  Uint8List imageBytes,
) {
  bool showConfirm = false;

  return showDialog<bool>(
    context: context,
    builder: (context) {
      final screenWidth = MediaQuery.of(context).size.width;
      final screenHeight = MediaQuery.of(context).size.height;

      return StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "Remove Image?",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: ColorManager.darkBlue,
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Image preview with delete
                      ImagePreviewBox(
                        imageBytes: imageBytes,
                        onTapDelete: () {
                          setState(() {
                            showConfirm = true;
                          });
                        },
                      ),

                      // Confirmation UI
                      if (showConfirm) ...[
                        const SizedBox(height: 20),
                        Text(
                          "Are you sure you want to remove the uploaded image?",
                          style: TextStyle(
                            color: ColorManager.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 100,
                              child: CustomActionIconButton(
                                buttonText: "No",
                                backgroundColor: ColorManager.white,
                                borderColor: ColorManager.grey,
                                fontColor: ColorManager.black,
                                buttonWidth: double.infinity,
                                buttonHeight: 45,
                                fontSize: 16,
                                icon: Icons.close,
                                iconColor: ColorManager.black,
                                onTap: () => Navigator.pop(context, false),
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 100,
                              child: CustomActionIconButton(
                                buttonText: "Yes",
                                backgroundColor: ColorManager.green,
                                borderColor: ColorManager.green,
                                fontColor: ColorManager.white,
                                buttonWidth: double.infinity,
                                buttonHeight: 45,
                                fontSize: 16,
                                isBoldFont: true,
                                icon: Icons.check,
                                iconColor: ColorManager.white,
                                onTap: () => Navigator.pop(context, true),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                /// Close button
                Positioned(
                  top: -screenHeight * 0.045, // little above dialog border
                  right: -screenWidth * 0.02,
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      padding: const EdgeInsets.all(6),
                      child: const Icon(
                        Icons.close,
                        color: Colors.black,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      );
    },
  );
}
