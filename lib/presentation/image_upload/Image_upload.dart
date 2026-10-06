import 'dart:convert';
import 'dart:io';
import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:eyvo_v3/core/utils.dart';
import 'package:eyvo_v3/core/widgets/progress_indicator.dart';
import 'package:eyvo_v3/log_data.dart/logger_data.dart';
import 'package:eyvo_v3/services/image_upload_helper.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/widgets/common_app_bar.dart';

class ImageUploadView extends StatefulWidget {
  const ImageUploadView({super.key});

  @override
  _ImageUploadViewState createState() => _ImageUploadViewState();
}

class _ImageUploadViewState extends State<ImageUploadView> {
  File? _selectedImage;
  bool _isUploading = false;
  String? _base64Image; // variable to hold base64 string

  final ImageHelper _imageHelper = ImageHelper();

  Future<void> _pickImage() async {
    final pickedFile = await _imageHelper.pickImageWithChoice(context: context);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = pickedFile;
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    setState(() {
      _isUploading = true;
    });

    try {
      // Get image name from path
      String fileName = _selectedImage!.path.split('/').last;

      // Convert image to bytes
      final bytes = await _selectedImage!.readAsBytes();

      // Convert bytes to base64
      _base64Image = base64Encode(bytes);

      LoggerData.dataLog("IMAGE NAME: $fileName");
      LoggerData.dataLog("BASE64 STRING: $_base64Image");

      //Show success dialog
      showImageActionDialog(
        context: context,
        imageString: ImageAssets.successfulIcon,
        titleString: '',
        messageString: "Image uploaded successfully",
        isNeedToPopBack: false,
        onNormalActionTap: () {
          setState(() {
            _selectedImage = null;
            _base64Image = null;
          });
        },
      );
    } catch (e) {
      LoggerData.dataLog("Error converting image: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primary,
      appBar: buildCommonAppBar(
        context: context,
        title: 'Image Upload',
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Upload Icon (big clickable)
            GestureDetector(
              onTap: _pickImage,
              child: Column(
                children: [
                  const SizedBox(height: 200),
                  _selectedImage == null
                      ? const Icon(
                          Icons.upload_file,
                          size: 120,
                          color: Colors.grey,
                        )
                      : Stack(
                          alignment: Alignment.topRight,
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _selectedImage!,
                                height: 180,
                                width: 180,
                                fit: BoxFit.cover,
                              ),
                            ),

                            // Close (X) button
                            Positioned(
                              top: 4,
                              right: 4,
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedImage = null;
                                    _base64Image = null;
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  padding: const EdgeInsets.all(4),
                                  child: const Icon(
                                    Icons.close,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 12),

                  // Instruction text
                  Text(
                    "Upload or select the image from gallery",
                    style: TextStyle(
                      color: ColorManager.green,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const Spacer(),

            // Upload Button (Green)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorManager.green,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: (_isUploading || _selectedImage == null)
                    ? null
                    : _uploadImage,
                icon: _isUploading
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CustomProgressIndicator(),
                      )
                    : Icon(Icons.cloud_upload, color: ColorManager.white),
                label: Text(
                  _isUploading ? "Uploading..." : "Upload",
                  style: TextStyle(fontSize: 16, color: ColorManager.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
