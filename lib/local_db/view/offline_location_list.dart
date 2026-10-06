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
import 'package:eyvo_v3/local_db/model/offline_location_model.dart';

import 'package:eyvo_v3/log_data.dart/logger_data.dart';
import 'package:flutter/material.dart';

/// ---------------- VIEW ----------------
class OfflineLocationListView extends StatefulWidget {
  final String selectedItem;
  final String selectedTitle;

  const OfflineLocationListView({
    super.key,
    required this.selectedItem,
    required this.selectedTitle,
  });

  @override
  State<OfflineLocationListView> createState() =>
      _OfflineLocationListViewState();
}

class _OfflineLocationListViewState extends State<OfflineLocationListView> {
  bool isLoading = false;
  bool isError = false;
  String errorText = AppStrings.somethingWentWrong;

  final OfflineDBDao _dbDao = OfflineDBDao();
  List<OfflineLocation> locationItems = [];

  @override
  void initState() {
    super.initState();
    fetchLocationsFromDB();
  }

  // ---------------- FETCH FROM SQLITE ----------------
  Future<void> fetchLocationsFromDB() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      final result = await _dbDao.getLocationsForDashboard();

      if (result.isEmpty) {
        setState(() {
          isError = true;
          errorText = 'No locations found';
        });
      } else {
        locationItems = result.map((e) => OfflineLocation.fromMap(e)).toList();

        LoggerData.dataLog(
          "Fetched locations count: ${result.length}",
        );

        for (final loc in locationItems) {
          LoggerData.dataLog(
            "Location  ID: ${loc.id}, Code: ${loc.code}, Name: ${loc.name}",
          );
        }
      }
    } catch (e, stackTrace) {
      await _dbDao.insertErrorLog(
        exceptionMessage: e.toString(),
        stackTrace: stackTrace.toString(),
        apiUrl: 'OFFLINE - SQLite - getAllLocations',
        requestBody: null,
        screenName: 'offline_location_list.dart',
        methodName: 'fetchLocationsFromDB',
      );
      setState(() {
        isError = true;
        errorText = 'Failed to load locations';
      });

      LoggerData.dataLog("Error fetching locations: $e");
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
              AppStrings.selectLocation,
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
              ? _buildErrorUI(context)
              : _buildLocationList(),
    );
  }

  // ---------------- ERROR UI ----------------
  Widget _buildErrorUI(BuildContext context) {
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
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Image.asset(
                    ImageAssets.noRecordFoundIcon,
                    width: displayWidth(context) * 0.5,
                  ),
                  const SizedBox(height: 12),
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
    );
  }

  // ---------------- LIST UI ----------------
  Widget _buildLocationList() {
    return ListView.separated(
      padding: const EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: 12,
      ),
      itemCount: locationItems.length,
      separatorBuilder: (context, index) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        child: Divider(
          color: ColorManager.primary,
          height: 0.1,
          thickness: 0.1,
        ),
      ),
      itemBuilder: (context, index) {
        final item = locationItems[index];

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0, horizontal: 4.0),
          child: Container(
            decoration: BoxDecoration(
              color: ColorManager.white,
              borderRadius: BorderRadius.circular(6),
            ),
            child: ListTile(
              dense: true,
              visualDensity: const VisualDensity(vertical: -2),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),

              // -------- LOCATION CODE --------
              title: Text(
                item.code,
                style: (item.code == widget.selectedItem)
                    ? getMediumStyle(
                        color: ColorManager.orange2,
                        fontSize: FontSize.s17,
                      )
                    : getRegularStyle(
                        color: ColorManager.lightGrey2,
                        fontSize: FontSize.s17,
                      ),
              ),

              // -------- LOCATION NAME --------
              subtitle: item.name.isNotEmpty
                  ? Text(
                      item.name,
                      style: (item.code == widget.selectedItem)
                          ? getMediumStyle(
                              color: ColorManager.orange2,
                              fontSize: FontSize.s12,
                            )
                          : getRegularStyle(
                              color: ColorManager.lightGrey2,
                              fontSize: FontSize.s12,
                            ),
                    )
                  : null,

              // -------- SAVE SELECTION --------
              onTap: () {
                SharedPrefs().selectedLocation = item.code;
                SharedPrefs().selectedTrimmedLocation = item.code;
                SharedPrefs().selectedLocationID = item.id;

                showSnackBar(
                  context,
                  '${AppStrings.locationSelectedMessage}${item.code}',
                );

                Navigator.pop(context, item.code);
              },
            ),
          ),
        );
      },
    );
  }
}
