import 'package:eyvo_v3/app/sizes_helper.dart';
import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/styles_manager.dart';
import 'package:eyvo_v3/core/utils.dart';
import 'package:flutter/material.dart';

class CustomItemCard extends StatelessWidget {
  final String imageString;
  final String title;
  final Color backgroundColor;
  final double cornerRadius;
  final VoidCallback onTap;

  const CustomItemCard({
    super.key,
    required this.imageString,
    required this.title,
    required this.backgroundColor,
    required this.cornerRadius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: (displayWidth(context) * 0.45), // reduced width
        height: 100,
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(cornerRadius),
        ),
        padding: const EdgeInsets.all(10.0), // reduced padding
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                imageString,
                height: 40, // reduced image size
                width: 40,
              ),
              const SizedBox(height: 6.0), // reduced spacing
              Text(
                title,
                style: getSemiBoldStyle(
                  color: ColorManager.lightGrey1,
                  fontSize: FontSize.s14, // reduced font size
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomItemCardDashboard extends StatelessWidget {
  final String imageString;
  final String title;
  final Color backgroundColor;
  final double cornerRadius;
  final VoidCallback onTap;

  const CustomItemCardDashboard({
    super.key,
    required this.imageString,
    required this.title,
    required this.backgroundColor,
    required this.cornerRadius,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: displayWidth(context) * 0.5,
        height: 160, // keep this fixed height
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(cornerRadius),
        ),
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // center everything
          children: [
            Image.asset(
              imageString,
              height: 60,
              width: 60,
            ),
            const SizedBox(height: 10.0),
            Text(
              title,
              style: getSemiBoldStyle(
                color: ColorManager.lightGrey1,
                fontSize: FontSize.s18,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis, // handle long text gracefully
            ),
          ],
        ),
      ),
    );
  }
}

class CustomItemCardWithEdit extends StatelessWidget {
  final String imageString;
  final String title;
  final String subtitle;
  final VoidCallback onEdit;
  final Color backgroundColor;
  final double cornerRadius;
  final bool isEditable;

  const CustomItemCardWithEdit({
    super.key,
    required this.imageString,
    required this.title,
    required this.subtitle,
    required this.onEdit,
    required this.backgroundColor,
    required this.cornerRadius,
    this.isEditable = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isEditable ? onEdit : null,
      child: Stack(
        children: [
          Container(
            //  height: 80,
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: BorderRadius.circular(cornerRadius),
            ),
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(cornerRadius),
                  child: Image.asset(
                    imageString,
                    width: 40,
                    height: 40,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        title,
                        style: getSemiBoldStyle(
                          color: ColorManager.lightGrey1,
                          fontSize: FontSize.s16,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: getRegularStyle(
                          color: ColorManager.lightGrey2,
                          fontSize: FontSize.s14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isEditable)
            Positioned(
              top: 4.0,
              right: 4.0,
              child: IconButton(
                icon: Image.asset(
                  ImageAssets.editIcon,
                  width: 20,
                  height: 20,
                ),
                onPressed: onEdit,
              ),
            ),
        ],
      ),
    );
  }
}

class CommonCardWidget extends StatelessWidget {
  final List<Map<String, String>> subtitles;
  final VoidCallback? onTap;

  const CommonCardWidget({
    super.key,
    required this.subtitles,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color: ColorManager.white,
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Table(
            columnWidths: const {
              0: IntrinsicColumnWidth(),
              1: FixedColumnWidth(24),
              2: FlexColumnWidth(),
            },
            defaultVerticalAlignment: TableCellVerticalAlignment.middle,
            children: List.generate(subtitles.length, (index) {
              final item = subtitles[index];
              final label = item.keys.first;
              final value = item.values.first;

              final isOrderNo = label == 'Order No';
              final isRequestNo = label == 'Request No';

              return TableRow(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(right: 10.0, bottom: 4),
                    child: Text(
                      label,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: FontSize.s16,
                        color: ColorManager.darkGrey,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      ':',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: FontSize.s16,
                        color: ColorManager.darkGrey,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Text(
                      value,
                      style: TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: FontSize.s16,
                        color: isOrderNo || isRequestNo
                            ? ColorManager.blue
                            : ColorManager.darkGrey,
                        decoration: isOrderNo || isRequestNo
                            ? TextDecoration.underline
                            : null,
                      ),
                    ),
                  ),
                ],
              );
            }),
          ),
        ),
      ),
    );
  }
}

class GenericCardWidget extends StatelessWidget {
  final String? titleKey;
  final String? statusKey;
  final String? supplierKey;
  final String? dateKey;
  final String? valueKey;
  final String? valueNameKey;
  final String? itemCountKey;
  final VoidCallback? onTap;

  const GenericCardWidget({
    super.key,
    this.titleKey,
    this.statusKey,
    this.supplierKey,
    this.dateKey,
    this.valueKey,
    this.valueNameKey,
    this.itemCountKey,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final title = titleKey ?? '-';
    final status = statusKey ?? '-';
    final supplier = supplierKey ?? '-';
    final date = dateKey ?? '-';
    final itemCount = itemCountKey ?? '-';
    final value = valueKey ?? '-';
    final labelName = valueNameKey ?? '';
    final statusColor = getStatusColor(status);
    return Card(
      color: ColorManager.white,
      elevation: 2,
      surfaceTintColor: ColorManager.white,
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top Row: title + status chip
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: FontSize.s20,
                      color: ColorManager.blue,
                    ),
                  ),
                  if (status.isNotEmpty && status != '-')
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        getNormalizedStatus(status),
                        style: getBoldStyle(
                          color: statusColor,
                          fontSize: FontSize.s12,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),

              // Supplier Name
              if (supplier.isNotEmpty && supplier != '-')
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.person_2_sharp,
                      color: ColorManager.lightBlack,
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        supplier,
                        style: getMediumStyle(
                          color: ColorManager.lightBlack,
                          fontSize: FontSize.s16,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

              if (supplier.isNotEmpty && supplier != '-')
                const SizedBox(height: 8),

              Divider(color: ColorManager.grey4, thickness: 1, height: 10),
              const SizedBox(height: 4),

              // Bottom Row: date & value
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date left side
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.date_range,
                              color: ColorManager.grey,
                              size: 18,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              date,
                              style: getSemiBoldStyle(
                                color: ColorManager.darkGrey,
                                fontSize: FontSize.s14,
                              ),
                            ),
                          ]),
                      const SizedBox(height: 6),
                      Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: ColorManager.grey,
                              size: 18,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              '${itemCount} Items',
                              style: getSemiBoldStyle(
                                color: ColorManager.darkGrey,
                                fontSize: FontSize.s14,
                              ),
                            ),
                          ]),
                    ],
                  ),

                  // Value section right side
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      if (labelName.isNotEmpty)
                        Text(
                          labelName,
                          style: getMediumStyle(
                            color: ColorManager.grey,
                            fontSize: FontSize.s14,
                          ),
                        ),
                      const SizedBox(height: 4),
                      Text(
                        value,
                        style: getBoldStyle(
                          color: ColorManager.lightBlack,
                          fontSize: FontSize.s18,
                        ),
                      ),
                    ],
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
