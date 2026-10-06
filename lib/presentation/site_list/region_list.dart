// ignore_for_file: use_build_context_synchronously

import 'package:eyvo_v3/api/api_service/api_service.dart';
import 'package:eyvo_v3/api/response_models/region_response.dart';
import 'package:eyvo_v3/app/app_prefs.dart';
import 'package:eyvo_v3/app/sizes_helper.dart';
import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/strings_manager.dart';
import 'package:eyvo_v3/core/resources/styles_manager.dart';
import 'package:eyvo_v3/core/utils.dart';
import 'package:eyvo_v3/core/widgets/button.dart';
import 'package:eyvo_v3/core/widgets/common_app_bar.dart';
import 'package:eyvo_v3/core/widgets/progress_indicator.dart';
import 'package:flutter/material.dart';

class RegionListView extends StatefulWidget {
  final String selectedItem;
  final String selectedTitle;
  const RegionListView(
      {super.key, required this.selectedItem, required this.selectedTitle});

  @override
  State<RegionListView> createState() => _RegionListViewState();
}

class _RegionListViewState extends State<RegionListView> {
  bool isLoading = false;
  final ApiService apiService = ApiService();
  late List<Region> regionItems = [];
  bool isError = false;
  String errorText = AppStrings.somethingWentWrong;

  @override
  void initState() {
    super.initState();
    fetchRegions();
  }

  void fetchRegions() async {
    setState(() {
      isLoading = true;
    });

    Map<String, dynamic> data = {
      'uid': SharedPrefs().uID,
    };
    final jsonResponse =
        await apiService.postRequest(context, ApiService.regionList, data);
    if (jsonResponse != null) {
      final response = RegionResponse.fromJson(jsonResponse);
      if (response.code == '200') {
        setState(() {
          regionItems = response.data;
        });
      } else {
        isError = true;
        errorText = response.message.join(', ');
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    //double topPadding = MediaQuery.of(context).padding.top;
    return Scaffold(
      appBar: buildCommonAppBar(
        context: context,
        title: SharedPrefs().offlineRegionLableName,
      ),
      body: isLoading
          ? const Center(child: CustomProgressIndicator())
          : isError
              ? Column(
                  children: [
                    const SizedBox(height: 40),
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Container(
                        height: displayHeight(context) * 0.65,
                        width: displayWidth(context),
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(16), // More circular
                          color: ColorManager.white,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              const Spacer(),
                              Image.asset(
                                ImageAssets.noRecordFoundIcon,
                                width: displayWidth(context) * 0.5,
                              ),
                              Text(
                                errorText,
                                style: getRegularStyle(
                                  color: ColorManager.lightGrey,
                                  fontSize: FontSize.s17,
                                ),
                              ),
                              const Spacer(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : SingleChildScrollView(
                  child: SizedBox(
                    //  height: displayHeight(context),
                    child: Column(
                      children: [
                        // SizedBox(height: topPadding),
                        // Padding(
                        //   padding: const EdgeInsets.symmetric(horizontal: 12),
                        //   child: Row(
                        //     children: [
                        //       Text(
                        //         widget.selectedTitle,
                        //         style: getBoldStyle(
                        //           color: ColorManager.darkBlue,
                        //           fontSize: FontSize.s20,
                        //         ),
                        //       ),
                        //       const Spacer(),
                        //       SizedBox(
                        //         height: 20,
                        //         child: CustomImageButton(
                        //           imageString: ImageAssets.closeIcon,
                        //           onTap: () {
                        //             Navigator.pop(context);
                        //           },
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        const SizedBox(height: 10),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            padding: EdgeInsets.zero,
                            itemCount: regionItems.length,
                            separatorBuilder: (context, index) => Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12.0),
                              child: Divider(
                                height: 0.1,
                                thickness: 0.1,
                                color: ColorManager.primary,
                              ),
                            ),
                            itemBuilder: (context, index) {
                              final item = regionItems[index];
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 2.0, horizontal: 4.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: ColorManager.white,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: ListTile(
                                    dense: true,
                                    visualDensity:
                                        const VisualDensity(vertical: -2),
                                    contentPadding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 4),
                                    title: Text(
                                      item.regionCode,
                                      style: item.regionCode ==
                                              widget.selectedItem
                                          ? getMediumStyle(
                                              color: ColorManager.orange2,
                                              fontSize: FontSize.s17,
                                            )
                                          : getRegularStyle(
                                              color: ColorManager.lightGrey2,
                                              fontSize: FontSize.s17,
                                            ),
                                    ),
                                    onTap: () {
                                      SharedPrefs().selectedRegion =
                                          item.regionCode;
                                      SharedPrefs().selectedRegionID =
                                          item.regionId;
                                      showSnackBar(
                                        context,
                                        '${AppStrings.siteSelectedMessage}${item.regionCode}',
                                      );
                                      Navigator.pop(context, item.regionCode);
                                    },
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
