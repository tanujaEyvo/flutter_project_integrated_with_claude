import 'dart:convert';

import 'package:eyvo_v3/app/sizes_helper.dart';
import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/strings_manager.dart';
import 'package:eyvo_v3/core/resources/styles_manager.dart';
import 'package:eyvo_v3/core/utils.dart';
import 'package:eyvo_v3/log_data.dart/logger_data.dart';
import 'package:eyvo_v3/presentation/image_upload/Image_upload_popUp.dart';
import 'package:flutter/material.dart';

class OrderItemListTile extends StatefulWidget {
  final int itemID;
  final String title;
  final String subtitle;
  final String imageString;
  final double totalQuantity;
  final double receivedQuantity;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final bool isImageUploaded;
  final String? uploadedImageBase64;
  final bool isReject;
  final double? rejectQuantity; // Add this parameter to show reject quantity
  final void Function(
          String fileName, String azureImageName, String base64Image)?
      onImageUploaded;

  const OrderItemListTile({
    super.key,
    required this.itemID,
    required this.title,
    required this.subtitle,
    required this.imageString,
    required this.totalQuantity,
    required this.receivedQuantity,
    required this.isSelected,
    required this.onTap,
    required this.onEdit,
    this.isImageUploaded = false,
    this.onImageUploaded,
    this.uploadedImageBase64,
    required this.isReject,
    this.rejectQuantity, // Add this
  });

  @override
  State<OrderItemListTile> createState() => _OrderItemListTileState();
}

class _OrderItemListTileState extends State<OrderItemListTile> {
  late double selectedQuantity;

  @override
  void initState() {
    super.initState();
    selectedQuantity = widget.receivedQuantity;
  }

  @override
  void didUpdateWidget(covariant OrderItemListTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isSelected != widget.isSelected) {
      setState(() {});
    }
    if (oldWidget.receivedQuantity != widget.receivedQuantity) {
      selectedQuantity = widget.receivedQuantity;
    }
    if (oldWidget.isReject != widget.isReject) {
      setState(() {});
    }
    if (oldWidget.rejectQuantity != widget.rejectQuantity) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    // For rejected items, show reject quantity, for accepted items show received quantity
    final displayQuantity = widget.isReject
        ? widget.rejectQuantity ?? 0.0 // Show reject quantity if available
        : widget.receivedQuantity; // Show received quantity for accepted items

    // colors based on reject state
    final quantityLabel =
        widget.isReject ? "Rejected Quantity" : "Receive Quantity";
    final quantityColor =
        widget.isReject ? ColorManager.red2 : ColorManager.lightGrey1;
    final amountColor =
        widget.isReject ? ColorManager.red2 : ColorManager.lightGrey1;

    return GestureDetector(
      onTap: widget.onTap,
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Card(
          color: widget.isSelected ? ColorManager.darkBlue : ColorManager.white,
          child: Padding(
            padding: const EdgeInsets.all(6.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // LEFT SIDE (Item ID + Image)
                    Column(
                      children: [
                        Text(
                          '${AppStrings.itemIDDetails}${widget.itemID}',
                          maxLines: 1,
                          style: getSemiBoldStyle(
                            color: widget.isSelected
                                ? ColorManager.white
                                : ColorManager.lightGrey1,
                            fontSize: FontSize.s12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          height: 80,
                          width: 80,
                          decoration: BoxDecoration(
                            color: ColorManager.white,
                            border: Border.all(
                                color: ColorManager.grey4, width: 1.0),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Image.network(
                            widget.imageString,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 8),
                    // MIDDLE (Title + Subtitle with camera icon)
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (widget.title.isNotEmpty)
                            Text(
                              widget.title,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: getBoldStyle(
                                color: widget.isSelected
                                    ? ColorManager.white
                                    : ColorManager.darkBlue,
                                fontSize: FontSize.s14,
                              ),
                            ),
                          // Subtitle + Camera Icon Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Text(
                                  widget.subtitle,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: widget.title.isEmpty ? 3 : 2,
                                  style: getRegularStyle(
                                    color: widget.isSelected
                                        ? ColorManager.white
                                        : ColorManager.lightGrey2,
                                    fontSize: FontSize.s14,
                                  ),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: GestureDetector(
                                  onTap: () async {
                                    if (widget.isImageUploaded &&
                                        widget.uploadedImageBase64 != null) {
                                      // Ask if user wants to remove image
                                      bool? remove =
                                          await showRemoveImageDialog(
                                        context,
                                        base64Decode(
                                            widget.uploadedImageBase64!),
                                      );
                                      if (remove == true &&
                                          widget.onImageUploaded != null) {
                                        widget.onImageUploaded!("", "", "");
                                      }
                                    } else {
                                      // Upload new image
                                      final result =
                                          await showImageUploadDialog(context);
                                      if (result != null &&
                                          widget.onImageUploaded != null) {
                                        final fileName = result["fileName"];
                                        final azureImageName =
                                            result["azureImageName"];
                                        final base64 = result["base64"];

                                        if (fileName != null &&
                                            azureImageName != null &&
                                            base64 != null) {
                                          widget.onImageUploaded!(
                                              fileName, azureImageName, base64);
                                        }
                                      }
                                    }
                                  },
                                  child: widget.isImageUploaded &&
                                          widget.uploadedImageBase64 != null
                                      ? Container(
                                          height: 40,
                                          width: 40,
                                          decoration: BoxDecoration(
                                            color: ColorManager.white,
                                            border: Border.all(
                                              color: ColorManager.white,
                                              width: 0.8,
                                            ),
                                            borderRadius:
                                                BorderRadius.circular(20),
                                          ),
                                          child: ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(20),
                                            child: Image.memory(
                                              base64Decode(
                                                  widget.uploadedImageBase64!),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        )
                                      : Image.asset(
                                          ImageAssets.uploadFiles,
                                          height: 30,
                                          width: 30,
                                        ),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${AppStrings.quantityDetail}${getFormattedPriceString(widget.totalQuantity)}',
                      style: getBoldStyle(
                          color: widget.isSelected
                              ? ColorManager.white
                              : ColorManager.lightGrey2,
                          fontSize: FontSize.s17),
                    ),
                    Stack(
                      children: [
                        Container(
                          width: 150,
                          height: 52,
                          child: GestureDetector(
                            onTap: widget.onEdit,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 7),
                              decoration: BoxDecoration(
                                  color: widget.isSelected
                                      ? ColorManager.white
                                      : Colors.transparent,
                                  border: Border.all(
                                      color: widget.isReject
                                          ? ColorManager.red2
                                          : ColorManager.grey4,
                                      width: 1.0),
                                  borderRadius: BorderRadius.circular(6)),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    formatQuantityString(
                                        displayQuantity), // Use displayQuantity instead of widget.receivedQuantity
                                    style: getSemiBoldStyle(
                                        color: amountColor,
                                        fontSize: FontSize.s17),
                                  ),
                                  SizedBox(
                                    height: 12,
                                    width: 13,
                                    child: Image.asset(ImageAssets.dropDownIcon,
                                        height: 20),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Positioned(
                          left: 12,
                          top: -8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 5),
                            decoration: BoxDecoration(
                                color: ColorManager.white,
                                borderRadius: BorderRadius.circular(4)),
                            child: Text(quantityLabel,
                                style: getSemiBoldStyle(
                                    color: quantityColor,
                                    fontSize: FontSize.s12)),
                          ),
                        )
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
// class OrderItemListTile extends StatefulWidget {
//   final int itemID;
//   final String title;
//   final String subtitle;
//   final String imageString;
//   final double totalQuantity;
//   final double receivedQuantity;
//   final bool isSelected;
//   final VoidCallback onTap;
//   final VoidCallback onEdit;
//   final bool isImageUploaded;
//   final String? uploadedImageBase64;
//   final void Function(String fileName, String base64Image)? onImageUploaded;

//   const OrderItemListTile({
//     super.key,
//     required this.itemID,
//     required this.title,
//     required this.subtitle,
//     required this.imageString,
//     required this.totalQuantity,
//     required this.receivedQuantity,
//     required this.isSelected,
//     required this.onTap,
//     required this.onEdit,
//     this.isImageUploaded = false,
//     this.onImageUploaded,
//     this.uploadedImageBase64,
//   });

//   @override
//   State<OrderItemListTile> createState() => _OrderItemListTileState();
// }

//  class _OrderItemListTileState extends State<OrderItemListTile> {
//   late double selectedQuantity;

//   @override
//   void initState() {
//     super.initState();
//     selectedQuantity = widget.receivedQuantity;
//   }

//   @override
//   void didUpdateWidget(covariant OrderItemListTile oldWidget) {
//     super.didUpdateWidget(oldWidget);
//     if (oldWidget.isSelected != widget.isSelected) {
//       setState(() {}); // rebuild if parent changes selection
//     }
//     if (oldWidget.receivedQuantity != widget.receivedQuantity) {
//       selectedQuantity = widget.receivedQuantity;
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: widget.onTap,
//       child: Padding(
//         padding: const EdgeInsets.only(bottom: 8),
//         child: Card(
//           color: widget.isSelected ? ColorManager.darkBlue : ColorManager.white,
//           child: Padding(
//             padding: const EdgeInsets.all(6.0),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Row(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     // LEFT SIDE (Item ID + Image)
//                     Column(
//                       children: [
//                         Text(
//                           '${AppStrings.itemIDDetails}${widget.itemID}',
//                           maxLines: 1,
//                           style: getSemiBoldStyle(
//                             color: widget.isSelected
//                                 ? ColorManager.white
//                                 : ColorManager.lightGrey1,
//                             fontSize: FontSize.s12,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Container(
//                           height: 80,
//                           width: 80,
//                           decoration: BoxDecoration(
//                             color: ColorManager.white,
//                             border: Border.all(
//                                 color: ColorManager.grey4, width: 1.0),
//                             borderRadius: BorderRadius.circular(6),
//                           ),
//                           child: Image.network(
//                             widget.imageString,
//                             fit: BoxFit.contain,
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(width: 8),

//                     // MIDDLE (Title + Subtitle with camera icon)
//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           if (widget.title.isNotEmpty)
//                             Text(
//                               widget.title,
//                               overflow: TextOverflow.ellipsis,
//                               maxLines: 1,
//                               style: getBoldStyle(
//                                 color: widget.isSelected
//                                     ? ColorManager.white
//                                     : ColorManager.darkBlue,
//                                 fontSize: FontSize.s14,
//                               ),
//                             ),

//                           // Subtitle + Camera Icon Row
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   widget.subtitle,
//                                   overflow: TextOverflow.ellipsis,
//                                   maxLines: widget.title.isEmpty ? 3 : 2,
//                                   style: getRegularStyle(
//                                     color: widget.isSelected
//                                         ? ColorManager.white
//                                         : ColorManager.lightGrey2,
//                                     fontSize: FontSize.s14,
//                                   ),
//                                 ),
//                               ),

//                               // Camera or Tick Icon
//                               Padding(
//                                 padding: const EdgeInsets.only(
//                                     right: 8.0), // gap from container border
//                                 child: GestureDetector(
//                                   onTap: () async {
//                                     final result =
//                                         await showImageUploadDialog(context);

//                                     if (result != null &&
//                                         widget.onImageUploaded != null) {
//                                       final fileName =
//                                           result["fileName"] as String?;
//                                       final base64 =
//                                           result["base64"] as String?;

//                                       if (fileName != null && base64 != null) {
//                                         LoggerData.dataLog(
//                                             "Uploaded file: $fileName");
//                                         LoggerData.dataLog(
//                                             "Base64 length: ${base64.length}");

//                                         widget.onImageUploaded
//                                             ?.call(fileName, base64);
//                                       } else {
//                                         LoggerData.dataLog(
//                                             "Image upload failed: fileName or base64 is null");
//                                       }
//                                     }
//                                   },
//                                   // child: widget.isImageUploaded
//                                   //     ? Image.asset(
//                                   //         ImageAssets.uploaded,
//                                   //         height: 30,
//                                   //         width: 30,
//                                   //       )
//                                   //     : Image.asset(
//                                   //         ImageAssets.uploadFiles,
//                                   //         height: 20,
//                                   //         width: 20,
//                                   //       ),

//                                   child: widget.isImageUploaded &&
//                                           widget.uploadedImageBase64 != null
//                                       ? ClipRRect(
//                                           borderRadius:
//                                               BorderRadius.circular(20),
//                                           child: Image.memory(
//                                             base64Decode(
//                                                 widget.uploadedImageBase64!),
//                                             height: 40,
//                                             width: 40,
//                                             fit: BoxFit.cover,
//                                           ),
//                                         )
//                                       : Image.asset(
//                                           ImageAssets.uploadFiles,
//                                           height: 20,
//                                           width: 20,
//                                         ),
//                                 ),
//                               ),
//                               const SizedBox(height: 20),
//                             ],
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 6),
//                 Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     Text(
//                       '${AppStrings.quantityDetail}${getFormattedString(widget.totalQuantity)}',
//                       style: getBoldStyle(
//                           color: widget.isSelected
//                               ? ColorManager.white
//                               : ColorManager.lightGrey2,
//                           fontSize: FontSize.s17),
//                     ),
//                     Stack(
//                       children: [
//                         Container(
//                           width: 150,
//                           height: 52,
//                           child: GestureDetector(
//                             onTap: widget.onEdit,
//                             child: Container(
//                               padding: const EdgeInsets.symmetric(
//                                   horizontal: 10, vertical: 7),
//                               decoration: BoxDecoration(
//                                   color: widget.isSelected
//                                       ? ColorManager.white
//                                       : Colors.transparent,
//                                   border: Border.all(
//                                       color: ColorManager.grey4, width: 1.0),
//                                   borderRadius: BorderRadius.circular(6)),
//                               child: Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Text(
//                                     getFormattedString(widget.receivedQuantity),
//                                     style: getSemiBoldStyle(
//                                         color: ColorManager.lightGrey1,
//                                         fontSize: FontSize.s17),
//                                   ),
//                                   SizedBox(
//                                     height: 12,
//                                     width: 13,
//                                     child: Image.asset(ImageAssets.dropDownIcon,
//                                         height: 20),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ),
//                         ),
//                         Positioned(
//                           left: 12,
//                           top: -8,
//                           child: Container(
//                             padding: const EdgeInsets.symmetric(
//                                 horizontal: 6, vertical: 5),
//                             decoration: BoxDecoration(
//                                 color: ColorManager.white,
//                                 borderRadius: BorderRadius.circular(4)),
//                             child: Text(AppStrings.receiveQuantity,
//                                 style: getSemiBoldStyle(
//                                     color: ColorManager.lightGrey1,
//                                     fontSize: FontSize.s12)),
//                           ),
//                         )
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }

class MenuItemListTile extends StatelessWidget {
  final String title;
  final IconData iconData;
  final VoidCallback onTap;

  const MenuItemListTile({
    super.key,
    required this.title,
    required this.iconData,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
        width: displayWidth(context),
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(iconData, color: ColorManager.lightGrey1, size: 20),
            const SizedBox(width: 12),
            Text(
              title,
              style: getRegularStyle(
                color: ColorManager.lightGrey1,
                fontSize: FontSize.s16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// class MenuItemListTile extends StatelessWidget {
//   final String title;
//   final String imageString;
//   final VoidCallback onTap;

//   const MenuItemListTile({
//     super.key,
//     required this.title,
//     required this.imageString,
//     required this.onTap, required IconData iconData,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 8),
//         width: displayWidth(context),
//         decoration: BoxDecoration(
//           color: ColorManager.white,
//           borderRadius: BorderRadius.circular(8),
//         ),
//         child: Row(
//           children: [
//             SizedBox(
//               height: 12,
//               width: 16,
//               child: Image.asset(imageString),
//             ),
//             const SizedBox(width: 12),
//             Text(
//               title,
//               style: getRegularStyle(
//                 color: ColorManager.lightGrey1,
//                 fontSize: FontSize.s16,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

class ItemListTile extends StatelessWidget {
  final String title;
  final String subtitle1;
  final String subtitle2;
  final String? subtitle3;

  final String imageString;

  final bool isOffline;

  const ItemListTile({
    super.key,
    required this.title,
    required this.subtitle1,
    required this.subtitle2,
    this.subtitle3,
    required this.imageString,
    this.isOffline = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 100,
        width: displayWidth(context),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: ColorManager.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 👇 Show image ONLY if NOT offline
            if (!isOffline) ...[
              Container(
                height: 60,
                width: 60,
                decoration: BoxDecoration(
                  color: ColorManager.white,
                  border: Border.all(color: ColorManager.grey4, width: 1.0),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: (imageString.isNotEmpty)
                    ? Image.network(
                        imageString,
                        errorBuilder: (context, error, stackTrace) {
                          return Image.asset(ImageAssets.noImages);
                        },
                      )
                    : Image.asset(ImageAssets.noImages),
              ),
              const SizedBox(width: 10),
            ],

            // 👇 Text section (always visible)
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: getBoldStyle(
                      color: ColorManager.darkBlue,
                      fontSize: FontSize.s14,
                    ),
                  ),
                  RichText(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    text: TextSpan(
                      text: AppStrings.itemCodeDetails,
                      style: getSemiBoldStyle(
                        color: ColorManager.black,
                        fontSize: FontSize.s12,
                      ),
                      children: [
                        TextSpan(
                          text: subtitle1,
                          style: getRegularStyle(
                            color: ColorManager.black,
                            fontSize: FontSize.s12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  RichText(
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    text: TextSpan(
                      text: AppStrings.categoryCodeDetails,
                      style: getSemiBoldStyle(
                        color: ColorManager.black,
                        fontSize: FontSize.s12,
                      ),
                      children: [
                        TextSpan(
                          text: subtitle2,
                          style: getRegularStyle(
                            color: ColorManager.black,
                            fontSize: FontSize.s12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (subtitle3 != null) ...[
                    const SizedBox(height: 4),
                    isOffline
                        ? RichText(
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            text: TextSpan(
                              text: AppStrings.stockDetails,
                              style: getBoldStyle(
                                color: ColorManager.red,
                                fontSize: FontSize.s14,
                              ),
                              children: [
                                TextSpan(
                                  text: subtitle3!,
                                  style: getBoldStyle(
                                    color: ColorManager.red,
                                    fontSize: FontSize.s14,
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RichText(
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            text: TextSpan(
                              text: AppStrings.stockDetails,
                              style: getSemiBoldStyle(
                                color: ColorManager.black,
                                fontSize: FontSize.s12,
                              ),
                              children: [
                                TextSpan(
                                  text: subtitle3!,
                                  style: getRegularStyle(
                                    color: ColorManager.black,
                                    fontSize: FontSize.s12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                  ],
                ],
              ),
            ),
          ],
        ));
  }
}

// class ItemGridTile extends StatelessWidget {
//   final String title;
//   final String subtitle1;
//   final String subtitle2;
//   final String? subtitle3;
//   final String imageString;
//   final bool isOffline;

//   const ItemGridTile({
//     super.key,
//     required this.title,
//     required this.subtitle1,
//     required this.subtitle2,
//     this.subtitle3,
//     required this.imageString,
//     this.isOffline = false,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       decoration: BoxDecoration(
//         color: ColorManager.white,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: SingleChildScrollView(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             if (!isOffline) ...[
//               Container(
//                 height: 80,
//                 width: double.infinity,
//                 decoration: BoxDecoration(
//                   color: ColorManager.white,
//                   border: Border.all(color: ColorManager.grey4, width: 1.0),
//                   borderRadius: BorderRadius.circular(8),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(5.0),
//                   child: (imageString.isNotEmpty)
//                       ? Image.network(
//                           imageString,
//                           errorBuilder: (context, error, stackTrace) {
//                             return Image.asset(ImageAssets.noImages);
//                           },
//                         )
//                       : Image.asset(ImageAssets.noImages),
//                 ),
//               ),
//               const SizedBox(height: 8),
//             ],

//             /// TITLE
//             Text(
//               title,
//               overflow: TextOverflow.ellipsis,
//               maxLines: 1,
//               style: getBoldStyle(
//                 color: ColorManager.darkBlue,
//                 fontSize: FontSize.s14,
//               ),
//             ),

//             const SizedBox(height: 4),

//             /// ITEM CODE
//             RichText(
//               overflow: TextOverflow.ellipsis,
//               maxLines: 2,
//               text: TextSpan(
//                 text: AppStrings.itemCodeDetails,
//                 style: getSemiBoldStyle(
//                   color: ColorManager.black,
//                   fontSize: FontSize.s12,
//                 ),
//                 children: [
//                   TextSpan(
//                     text: subtitle1,
//                     style: getRegularStyle(
//                       color: ColorManager.black,
//                       fontSize: FontSize.s12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             const SizedBox(height: 4),

//             /// CATEGORY CODE
//             RichText(
//               overflow: TextOverflow.ellipsis,
//               maxLines: 2,
//               text: TextSpan(
//                 text: AppStrings.categoryCodeDetails,
//                 style: getSemiBoldStyle(
//                   color: ColorManager.black,
//                   fontSize: FontSize.s12,
//                 ),
//                 children: [
//                   TextSpan(
//                     text: subtitle2,
//                     style: getRegularStyle(
//                       color: ColorManager.black,
//                       fontSize: FontSize.s12,
//                     ),
//                   ),
//                 ],
//               ),
//             ),

//             if (subtitle3 != null) ...[
//               const SizedBox(height: 4),
//               RichText(
//                 overflow: TextOverflow.ellipsis,
//                 maxLines: 1,
//                 text: TextSpan(
//                   text: AppStrings.stockDetails,
//                   style: getBoldStyle(
//                     color: ColorManager.red,
//                     fontSize: FontSize.s14,
//                   ),
//                   children: [
//                     TextSpan(
//                       text: subtitle3!,
//                       style: getBoldStyle(
//                         color: ColorManager.red,
//                         fontSize: FontSize.s14,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }

class ItemGridTile extends StatelessWidget {
  final String title;
  final String subtitle1;
  final String subtitle2;
  final String? subtitle3;
  final String imageString;
  final bool isOffline;

  const ItemGridTile({
    super.key,
    required this.title,
    required this.subtitle1,
    required this.subtitle2,
    this.subtitle3,
    required this.imageString,
    this.isOffline = false,
  });

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final orientation = MediaQuery.of(context).orientation;

    final bool isTablet = screenWidth >= 600;

    final bool isPhoneLandscape =
        !isTablet && orientation == Orientation.landscape;

    return Container(
      padding: EdgeInsets.all(
        isPhoneLandscape ? 4.0 : (isTablet ? 10.0 : 8.0),
      ),
      decoration: BoxDecoration(
        color: ColorManager.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: ColorManager.grey4.withOpacity(0.3),
          width: 0.5,
        ),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double actualWidth = constraints.maxWidth;
          final double actualHeight = constraints.maxHeight;

          // --------------------------------------------------
          // PHONE LANDSCAPE
          // --------------------------------------------------
          if (isPhoneLandscape) {
            return _buildPhoneLandscape(
              actualHeight: actualHeight,
            );
          }

          // --------------------------------------------------
          // PHONE PORTRAIT
          // --------------------------------------------------
          if (!isTablet) {
            return _buildPhonePortrait(
              actualHeight: actualHeight,
            );
          }

          // --------------------------------------------------
          // TABLET
          // --------------------------------------------------
          return _buildTablet(
            actualHeight: actualHeight,
            actualWidth: actualWidth,
            isLandscape: orientation == Orientation.landscape,
          );
        },
      ),
    );
  }

  // ==========================================================
  // PHONE PORTRAIT - COMPLETE SOLUTION WITH FLEXIBLE
  // ==========================================================

  Widget _buildPhonePortrait({required double actualHeight}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isOffline) ...[
          Expanded(
            // ← was Container(height: imageHeight)
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: ColorManager.light3,
                borderRadius: BorderRadius.circular(6),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: imageString.isNotEmpty
                    ? Image.network(imageString,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                            ImageAssets.noImages,
                            fit: BoxFit.cover))
                    : Image.asset(ImageAssets.noImages, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 4),
        ],
        Text(title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: getBoldStyle(color: ColorManager.darkBlue, fontSize: 12)),
        const SizedBox(height: 2),
        RichText(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            text: AppStrings.itemCodeDetails,
            style: getSemiBoldStyle(color: ColorManager.black, fontSize: 10),
            children: [
              TextSpan(
                  text: subtitle1,
                  style:
                      getRegularStyle(color: ColorManager.black, fontSize: 10))
            ],
          ),
        ),
        const SizedBox(height: 2),
        RichText(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            text: AppStrings.categoryCodeDetails,
            style: getSemiBoldStyle(color: ColorManager.black, fontSize: 10),
            children: [
              TextSpan(
                  text: subtitle2,
                  style:
                      getRegularStyle(color: ColorManager.black, fontSize: 10))
            ],
          ),
        ),
        if (subtitle3 != null) ...[
          const SizedBox(height: 2),
          RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: AppStrings.stockDetails,
              style: getBoldStyle(color: ColorManager.black, fontSize: 10),
              children: [
                TextSpan(
                    text: subtitle3!,
                    style:
                        getBoldStyle(color: ColorManager.black, fontSize: 10))
              ],
            ),
          ),
        ],
      ],
    );
  }
  // ==========================================================
  // PHONE LANDSCAPE - COMPLETE SOLUTION WITH FLEXIBLE
  // ==========================================================

  Widget _buildPhoneLandscape({required double actualHeight}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isOffline) ...[
          Expanded(
            // ← was SizedBox(height: imageHeight)
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: ColorManager.light3,
                borderRadius: BorderRadius.circular(6),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: imageString.isNotEmpty
                    ? Image.network(
                        imageString,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                            ImageAssets.noImages,
                            fit: BoxFit.cover),
                      )
                    : Image.asset(ImageAssets.noImages, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 3),
        ],
        Text(
          title,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: getBoldStyle(color: ColorManager.darkBlue, fontSize: 10),
        ),
        const SizedBox(height: 2),
        RichText(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            text: AppStrings.itemCodeDetails,
            style: getSemiBoldStyle(color: ColorManager.black, fontSize: 9),
            children: [
              TextSpan(
                  text: subtitle1,
                  style:
                      getRegularStyle(color: ColorManager.black, fontSize: 9))
            ],
          ),
        ),
        const SizedBox(height: 1),
        RichText(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            text: AppStrings.categoryCodeDetails,
            style: getSemiBoldStyle(color: ColorManager.black, fontSize: 9),
            children: [
              TextSpan(
                  text: subtitle2,
                  style:
                      getRegularStyle(color: ColorManager.black, fontSize: 9))
            ],
          ),
        ),
        if (subtitle3 != null) ...[
          const SizedBox(height: 1),
          RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: AppStrings.stockDetails,
              style: getBoldStyle(color: ColorManager.red, fontSize: 9),
              children: [
                TextSpan(
                    text: subtitle3!,
                    style: getBoldStyle(color: ColorManager.red, fontSize: 9))
              ],
            ),
          ),
        ],
      ],
    );
  }
  // ==========================================================
  // TABLET - COMPLETE SOLUTION WITH FLEXIBLE
  // ==========================================================

  Widget _buildTablet({
    required double actualHeight,
    required double actualWidth,
    required bool isLandscape,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (!isOffline) ...[
          Expanded(
            // ← KEY: fills remaining space
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: ColorManager.light3,
                borderRadius: BorderRadius.circular(6),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: imageString.isNotEmpty
                    ? Image.network(
                        imageString,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Image.asset(
                            ImageAssets.noImages,
                            fit: BoxFit.cover),
                      )
                    : Image.asset(ImageAssets.noImages, fit: BoxFit.cover),
              ),
            ),
          ),
          const SizedBox(height: 6),
        ],

        // TITLE — no Flexible, natural size, capped at 2 lines
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: getBoldStyle(color: ColorManager.darkBlue, fontSize: 14),
        ),

        const SizedBox(height: 4),

        RichText(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            text: AppStrings.itemCodeDetails,
            style: getSemiBoldStyle(color: ColorManager.black, fontSize: 13),
            children: [
              TextSpan(
                text: subtitle1,
                style: getRegularStyle(color: ColorManager.black, fontSize: 13),
              ),
            ],
          ),
        ),

        const SizedBox(height: 3),

        RichText(
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          text: TextSpan(
            text: AppStrings.categoryCodeDetails,
            style: getSemiBoldStyle(color: ColorManager.black, fontSize: 13),
            children: [
              TextSpan(
                text: subtitle2,
                style: getRegularStyle(color: ColorManager.black, fontSize: 13),
              ),
            ],
          ),
        ),

        if (subtitle3 != null) ...[
          const SizedBox(height: 3),
          RichText(
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            text: TextSpan(
              text: AppStrings.stockDetails,
              style: getBoldStyle(color: ColorManager.black, fontSize: 14),
              children: [
                TextSpan(
                  text: subtitle3!,
                  style: getBoldStyle(color: ColorManager.black, fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

//   final String title;
//   final String subtitle1;
//   final String subtitle2;
//   final String subtitle3;
//   final String imageString;

//   const ItemGridTile(
//       {super.key,
//       required this.title,
//       required this.subtitle1,
//       required this.subtitle2,
//       required this.subtitle3,
//       required this.imageString});

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       // height: 440,
//       decoration: BoxDecoration(
//           color: ColorManager.white, borderRadius: BorderRadius.circular(8)),
//       padding: const EdgeInsets.all(18.0),
//       child: IntrinsicHeight(
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             SizedBox(
//               height: 100,
//               width: double.infinity,
//               child: Image.network(
//                 imageString,
//                 fit: BoxFit.fill,
//               ),
//             ),
//             const SizedBox(height: 10),
//             Text(title,
//                 overflow: TextOverflow.ellipsis,
//                 maxLines: 2,
//                 style: getBoldStyle(
//                     color: ColorManager.darkBlue, fontSize: FontSize.s14)),
//             RichText(
//               overflow: TextOverflow.ellipsis,
//               maxLines: 2,
//               text: TextSpan(
//                 text: AppStrings.itemCodeDetails,
//                 style: getSemiBoldStyle(
//                     color: ColorManager.black, fontSize: FontSize.s12),
//                 children: [
//                   TextSpan(
//                       text: subtitle1,
//                       style: getRegularStyle(
//                           color: ColorManager.black, fontSize: FontSize.s12))
//                 ],
//               ),
//             ),
//             RichText(
//               overflow: TextOverflow.ellipsis,
//               maxLines: 2,
//               text: TextSpan(
//                 text: AppStrings.categoryCodeDetails,
//                 style: getSemiBoldStyle(
//                     color: ColorManager.black, fontSize: FontSize.s12),
//                 children: [
//                   TextSpan(
//                       text: subtitle2,
//                       style: getRegularStyle(
//                           color: ColorManager.black, fontSize: FontSize.s12))
//                 ],
//               ),
//             ),
//             RichText(
//               overflow: TextOverflow.ellipsis,
//               maxLines: 2,
//               text: TextSpan(
//                 text: AppStrings.stockDetails,
//                 style: getSemiBoldStyle(
//                     color: ColorManager.black, fontSize: FontSize.s12),
//                 children: [
//                   TextSpan(
//                       text: subtitle3,
//                       style: getRegularStyle(
//                           color: ColorManager.black, fontSize: FontSize.s12))
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }

