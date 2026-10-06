import 'dart:convert';
import 'dart:io';
import 'package:dotted_border/dotted_border.dart';
import 'package:eyvo_v3/api/api_service/api_service.dart';
import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/constants.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/styles_manager.dart';
import 'package:eyvo_v3/core/widgets/common_app_bar.dart';
import 'package:eyvo_v3/core/widgets/form_field_helper.dart';
import 'package:eyvo_v3/core/widgets/progress_indicator.dart';
import 'package:eyvo_v3/services/image_upload_helper.dart';
import 'package:flutter/material.dart';

enum UploadType { file, url }

class FileUploadPage extends StatefulWidget {
  const FileUploadPage({Key? key}) : super(key: key);

  @override
  State<FileUploadPage> createState() => _FileUploadPageState();
}

class _FileUploadPageState extends State<FileUploadPage> {
  final ApiService apiService = ApiService();
  final ImageHelper _imageHelper = ImageHelper();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _itemDescriptionController =
      TextEditingController();

  List<bool> _isCardSelected = [false, false];

  File? _selectedImage;
  String? _fileExtension;
  String? _fileSize;
  bool _isUploading = false;
  bool _isFileTooLarge = false;
  bool _isInvalidFormat = false;

  UploadType _selectedUploadType = UploadType.file;

  @override
  void dispose() {
    _descriptionController.dispose();
    _itemDescriptionController.dispose();
    super.dispose();
  }

  String _formatBytes(int bytes, int decimals) {
    if (bytes <= 0) return "0 KB";
    const int kb = 1000;
    const int mb = kb * 1000;
    if (bytes >= mb) return (bytes / mb).toStringAsFixed(decimals) + " MB";
    return (bytes / kb).toStringAsFixed(decimals) + " KB";
  }

  Future<void> _pickImage() async {
    final pickedFile = await _imageHelper.pickImageWithChoice(context: context);
    if (pickedFile != null) {
      final bytes = await pickedFile.length();
      final ext = pickedFile.path.split('.').last.toLowerCase();

      setState(() {
        _fileExtension = ext;
        _isInvalidFormat = !AppConstants.allowedImageFormats.contains(ext);
        _fileSize = _formatBytes(bytes, 2);
        _selectedImage = pickedFile;
        _isFileTooLarge = bytes > AppConstants.imageSizeLimitBytes;
      });
    }
  }

  Widget _buildFileUploadUI() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // ---- Upload Box ----
        FormFieldHelper.buildUploadBox(
          selectedFile: _selectedImage,
          onPickFile: _pickImage,
          onRemoveFile: () {
            setState(() {
              _selectedImage = null;
              _fileExtension = null;
              _fileSize = null;
              _isFileTooLarge = false;
              _isInvalidFormat = false;
            });
          },
          isUploading: _isUploading,
        ),

        const SizedBox(height: 10),
        FormFieldHelper.buildFileStatus(
          isInvalidFormat: _isInvalidFormat,
          isFileTooLarge: _isFileTooLarge,
          fileSize: _fileSize,
        ),

        const SizedBox(height: 10),

        // ---- Description Text Box ----
        FormFieldHelper.buildMultilineTextField(
          label: "Item Description",
          controller: _itemDescriptionController,
          hintText: "Enter detailed item description",
        ),

        const SizedBox(height: 10),

        // ---- Cards ----
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'File Privacy',
            style: getSemiBoldStyle(
              color: ColorManager.black,
              fontSize: FontSize.s14,
            ),
          ),
        ),
        const SizedBox(height: 5),
        FormFieldHelper.buildInfoCard(
          index: 0,
          icon: Icons.lock_outlined,
          title: "Private",
          subtitle: "Only you and Invited members can see this file",
          isCardSelected: _isCardSelected,
          onTap: () {
            setState(() {
              _isCardSelected[0] = !_isCardSelected[0];
            });
          },
        ),
        const SizedBox(height: 12),
        FormFieldHelper.buildInfoCard(
          index: 1,
          icon: Icons.public,
          title: "Public",
          subtitle: "Anyone with the link can view this file \n",
          isCardSelected: _isCardSelected,
          onTap: () {
            setState(() {
              _isCardSelected[1] = !_isCardSelected[1];
            });
          },
        ),

        const SizedBox(height: 30),

        // // ---- Upload Button ----
        // SizedBox(
        //   width: double.infinity,
        //   height: 50,
        //   child: ElevatedButton.icon(
        //     style: ElevatedButton.styleFrom(
        //       backgroundColor: ColorManager.darkBlue,
        //       shape: RoundedRectangleBorder(
        //         borderRadius: BorderRadius.circular(12),
        //       ),
        //     ),
        //     icon: _isUploading
        //         ? const SizedBox(
        //             height: 18,
        //             width: 18,
        //             child: CustomProgressIndicator(),
        //           )
        //         : const Icon(Icons.cloud_upload, color: Colors.white),
        //     label: Text(
        //       _isUploading ? "Uploading..." : "Upload File",
        //       style: TextStyle(color: ColorManager.white, fontSize: 16),
        //     ),
        //     onPressed: () {
        //       // _isUploading ? null : _uploadImage
        //     },
        //   ),
        // ),
      ],
    );
  }

  Widget _buildUrlInputBox() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        FormFieldHelper.buildTextField(
          label: "File URL",
          controller: _descriptionController,
          hintText: "Enter file URL here",
        ),
        const SizedBox(height: 12),
        FormFieldHelper.buildMultilineTextField(
          label: "File Description",
          controller: _descriptionController,
          hintText: "Enter File URL description here",
        ),
        const SizedBox(height: 12),
        // ---- Cards ----
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'File Privacy',
            style: getSemiBoldStyle(
              color: ColorManager.black,
              fontSize: FontSize.s14,
            ),
          ),
        ),
        const SizedBox(height: 5),
        FormFieldHelper.buildInfoCard(
          index: 0,
          icon: Icons.lock_outlined,
          title: "Private",
          subtitle: "Only you and Invited members can see this file",
          isCardSelected: _isCardSelected,
          onTap: () {
            setState(() {
              _isCardSelected[0] = !_isCardSelected[0];
            });
          },
        ),
        const SizedBox(height: 12),
        FormFieldHelper.buildInfoCard(
          index: 1,
          icon: Icons.public,
          title: "Public",
          subtitle: "Anyone with the link can view this file \n",
          isCardSelected: _isCardSelected,
          onTap: () {
            setState(() {
              _isCardSelected[1] = !_isCardSelected[1];
            });
          },
        ),

        const SizedBox(height: 30),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCommonAppBar(
        context: context,
        title: 'Attachment',
      ),
      body: Column(
        children: [
          // ---- Tabs ----
          Container(
            decoration: BoxDecoration(
              color: ColorManager.white,
              border: Border(
                bottom: BorderSide(
                  color: ColorManager.lightGrey,
                  width: 1,
                ),
              ),
            ),
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedUploadType = UploadType.file;
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "File Upload",
                        style: TextStyle(
                          color: _selectedUploadType == UploadType.file
                              ? ColorManager.darkBlue
                              : ColorManager.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 2,
                        width: 80,
                        color: _selectedUploadType == UploadType.file
                            ? ColorManager.darkBlue
                            : Colors.transparent,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 20),
                GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedUploadType = UploadType.url;
                    });
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "File URL Upload",
                        style: TextStyle(
                          color: _selectedUploadType == UploadType.url
                              ? ColorManager.darkBlue
                              : ColorManager.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        height: 2,
                        width: 120,
                        color: _selectedUploadType == UploadType.url
                            ? ColorManager.darkBlue
                            : Colors.transparent,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ---- Scrollable Content ----
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _selectedUploadType == UploadType.file
                  ? _buildFileUploadUI()
                  : _buildUrlInputBox(),
            ),
          ),
          // ---- Upload Button ----
          SizedBox(
            width: MediaQuery.of(context).size.width * 0.90,
            height: 50,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorManager.darkBlue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              // icon: _isUploading
              //     ? const SizedBox(
              //         height: 18,
              //         width: 18,
              //         child: CustomProgressIndicator(),
              //       )
              //     : const Icon(Icons.cloud_upload, color: Colors.white),
              label: Text(
                _isUploading ? "Uploading..." : "Save",
                style: getBoldStyle(
                  color: ColorManager.white,
                  fontSize: FontSize.s18,
                ),
              ),
              onPressed: () {
                // _isUploading ? null : _uploadImage
              },
            ),
          ),
          const SizedBox(
            height: 20,
          )
        ],
      ),
    );
  }
}
