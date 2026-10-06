// ignore_for_file: use_build_context_synchronously

import 'package:eyvo_v3/app/app_prefs.dart';
import 'package:eyvo_v3/app/sizes_helper.dart';
import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/strings_manager.dart';
import 'package:eyvo_v3/core/resources/styles_manager.dart';
import 'package:eyvo_v3/core/utils.dart';
import 'package:eyvo_v3/core/widgets/common_app_bar.dart';
import 'package:eyvo_v3/core/widgets/progress_indicator.dart';
import 'package:eyvo_v3/local_db/dao/offline_db_dao.dart';
import 'package:eyvo_v3/local_db/model/offline_region_model.dart';

import 'package:eyvo_v3/log_data.dart/logger_data.dart';
import 'package:flutter/material.dart';

class OfflineRegionListView extends StatefulWidget {
  final String selectedItem;
  final String selectedTitle;

  const OfflineRegionListView({
    super.key,
    required this.selectedItem,
    required this.selectedTitle,
  });

  @override
  State<OfflineRegionListView> createState() => _OfflineRegionListViewState();
}

class _OfflineRegionListViewState extends State<OfflineRegionListView> {
  bool isLoading = false;
  bool isError = false;
  String errorText = AppStrings.somethingWentWrong;
  final OfflineDBDao _dbDao = OfflineDBDao();
  List<OfflineRegion> regionItems = [];

  @override
  void initState() {
    super.initState();
    fetchRegionsFromDB();
  }

  // ---------------- FETCH FROM SQLITE ----------------
  Future<void> fetchRegionsFromDB() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      final result = await _dbDao.getAllRegions();

      if (result.isEmpty) {
        setState(() {
          isError = true;
          errorText = 'No regions found';
        });
      } else {
        regionItems = result.map((e) => OfflineRegion.fromMap(e)).toList();

        LoggerData.dataLog('Fetched regions count: ${regionItems.length}');

        for (final region in regionItems) {
          LoggerData.dataLog(
            'Region -> ID: ${region.id}, Code: ${region.code}',
          );
        }
      }
    } catch (e, stackTrace) {
      await _dbDao.insertErrorLog(
        exceptionMessage: e.toString(),
        stackTrace: stackTrace.toString(),
        apiUrl: 'OFFLINE - SQLite - getAllRegions',
        requestBody: null,
        screenName: 'offline_region_list.dart',
        methodName: 'fetchRegionsFromDB',
      );
      isError = true;
      errorText = 'Failed to load regions';
      LoggerData.dataLog('Error loading regions: $e');
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorManager.grey,
        toolbarHeight: 56,
        leadingWidth: 40,
        titleSpacing: 0,
        leading: IconButton(
          icon: SizedBox(
            width: 18,
            height: 18,
            child: Image.asset(
              ImageAssets.backButton,
              color: ColorManager.white,
            ),
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.selectSite,
              style: getBoldStyle(
                color: ColorManager.white,
                fontSize: FontSize.s20,
              ),
            ),
            const SizedBox(width: 8),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: ColorManager.white,
                    width: 1,
                  ),
                ),
                child: Text(
                  'OFFLINE MODE',
                  style: getSemiBoldStyle(
                    color: ColorManager.white,
                    fontSize: FontSize.s12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: isLoading
          ? const Center(child: CustomProgressIndicator())
          : isError
              ? _buildErrorView()
              : _buildRegionList(),
    );
  }

  //---------------- REGION LIST ----------------
  Widget _buildRegionList() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: regionItems.length,
          separatorBuilder: (_, __) => Divider(
            height: 0.1,
            thickness: 0.1,
            color: ColorManager.primary,
          ),
          itemBuilder: (context, index) {
            final item = regionItems[index];

            return Container(
              decoration: BoxDecoration(
                color: ColorManager.white,
                borderRadius: BorderRadius.circular(6),
              ),
              child: ListTile(
                dense: true,
                visualDensity: const VisualDensity(vertical: -2),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                title: Text(
                  item.code,
                  style: item.code == widget.selectedItem
                      ? getMediumStyle(
                          color: ColorManager.orange2,
                          fontSize: FontSize.s17,
                        )
                      : getRegularStyle(
                          color: ColorManager.lightGrey2,
                          fontSize: FontSize.s17,
                        ),
                ),
                // onTap: () {
                //   SharedPrefs().selectedRegion = item.code;
                //   SharedPrefs().selectedRegionID = item.id;

                //   showSnackBar(
                //     context,
                //     '${AppStrings.siteSelectedMessage}${item.code}',
                //   );

                //   Navigator.pop(context, item.code);
                // },
                onTap: () {
                  // Log the selected region name
                  LoggerData.dataLog('===== REGION SELECTED =====');
                  LoggerData.dataLog('Region Code: ${item.code}');
                  LoggerData.dataLog('Region ID: ${item.id}');
                  LoggerData.dataLog(
                      'Previous selected: ${widget.selectedItem}');

                  SharedPrefs().selectedRegion = item.code;
                  SharedPrefs().selectedRegionID = item.id;
                  SharedPrefs().offlineRegionSubName = item.code;
                  SharedPrefs().offlineRegionLableName = widget.selectedTitle;

                  showSnackBar(
                    context,
                    '${AppStrings.siteSelectedMessage}${item.code}',
                  );

                  Navigator.pop(context, item.code);
                },
              ),
            );
          },
        ),
      ),
    );
  }

  //---------------- ERROR VIEW ----------------
  Widget _buildErrorView() {
    return Column(
      children: [
        const SizedBox(height: 40),
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            height: displayHeight(context) * 0.65,
            width: displayWidth(context),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              color: ColorManager.white,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  ImageAssets.noRecordFoundIcon,
                  width: displayWidth(context) * 0.5,
                ),
                const SizedBox(height: 10),
                Text(
                  errorText,
                  style: getRegularStyle(
                    color: ColorManager.lightGrey,
                    fontSize: FontSize.s17,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
