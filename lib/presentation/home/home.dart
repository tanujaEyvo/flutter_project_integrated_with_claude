import 'dart:async';
import 'dart:developer';

import 'package:eyvo_v3/CommonCode/global_utils.dart';
import 'package:eyvo_v3/api/api_service/api_service.dart';
import 'package:eyvo_v3/api/response_models/dashboard_response.dart';
import 'package:eyvo_v3/api/response_models/inventory_manager_check_response.dart';
import 'package:eyvo_v3/api/response_models/location_response.dart';
import 'package:eyvo_v3/api/response_models/offline_db_response.dart';
import 'package:eyvo_v3/api/response_models/save_response.dart';
import 'package:eyvo_v3/api/response_models/switchboard_response.dart';
import 'package:eyvo_v3/app/app_prefs.dart';
import 'package:eyvo_v3/app/sizes_helper.dart';
import 'package:eyvo_v3/core/logout_helper.dart';
import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/constants.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/routes_manager.dart';
import 'package:eyvo_v3/core/resources/strings_manager.dart';
import 'package:eyvo_v3/core/resources/styles_manager.dart';
import 'package:eyvo_v3/core/utils.dart';
import 'package:eyvo_v3/core/widgets/alert.dart';
import 'package:eyvo_v3/core/widgets/animented_text_with%20dots.dart';
import 'package:eyvo_v3/core/widgets/common_app_bar.dart';
import 'package:eyvo_v3/core/widgets/custom_card_item.dart';
import 'package:eyvo_v3/core/widgets/custom_list_tile.dart';
import 'package:eyvo_v3/core/widgets/setting_page.dart';
import 'package:eyvo_v3/core/widgets/progress_indicator.dart';
import 'package:eyvo_v3/core/widgets/title_header.dart';
import 'package:eyvo_v3/features/logout/logout_page.dart';
import 'package:eyvo_v3/local_db/dao/offline_db_dao.dart';
import 'package:eyvo_v3/local_db/view/offline_location_list.dart';
import 'package:eyvo_v3/local_db/view/offline_region_list.dart';
import 'package:eyvo_v3/log_data.dart/logger_data.dart';
import 'package:eyvo_v3/presentation/blind_stock/blindstock_list.dart';
import 'package:eyvo_v3/presentation/blind_stock_details/blindstock_details.dart';
import 'package:eyvo_v3/presentation/change_password/change_password.dart';
import 'package:eyvo_v3/presentation/image_upload/Image_upload.dart';
import 'package:eyvo_v3/presentation/item_details/item_details.dart';
import 'package:eyvo_v3/presentation/item_list/item_list.dart';
import 'package:eyvo_v3/presentation/location_list/location_list.dart';
import 'package:eyvo_v3/presentation/select_order/select_order.dart';
import 'package:eyvo_v3/presentation/site_list/region_list.dart';
import 'package:eyvo_v3/services/error_logging_service.dart';
import 'package:eyvo_v3/services/internet_connectivity_service.dart';
import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:barcode_scan2/barcode_scan2.dart';

class InverntoryView extends StatefulWidget {
  const InverntoryView({super.key});

  @override
  State<InverntoryView> createState() => _InverntoryViewState();
}

class _InverntoryViewState extends State<InverntoryView> with RouteAware {
  bool isPermissionDenied = false;
  bool isLoading = false;
  bool isRegionEnabled = false;
  bool isRegionEditable = false;
  bool isLocationEnabled = false;
  bool isLocationEditable = false;
  bool isScanItemsEnabled = false;
  bool isListItemsEnabled = false;
  bool isGREnabled = false;
//--------------switchboard api-----------------------------------
  bool isRequestEnabled = false;
  bool isOrderEnabled = false;
  bool isExpenseEnabled = false;
  bool isInvoiceEnabled = false;
  bool isInventoryEnabled = false;
  bool region = false;
  List<String> items = [];
  List<String> menuItems = [];
  String selectRegionTitle = '';
  String selectRegionTitleForDashboard = '';
  String selectLocationTitle = '';
  String? selectedRegion;
  String? selectedLocation;
  int? selectedLocationID;
  final ApiService apiService = ApiService();
  bool isError = false;
  String errorText = AppStrings.somethingWentWrong;
  bool isFetchingLocation = false; // Add this variable
  bool isLoginazureAd = SharedPrefs().isLoginazureAd;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  int? selectedRegionId;
  bool isLocationNull = false;
  bool inventoryManager = SharedPrefs().inventoryManager;
  //bool blindStockEdit = SharedPrefs().blindStockEdit;
  String displayUserName = SharedPrefs().displayUserName;
  int totalRecords = 0;
  bool isTransitioning = false;
  bool isOfflineBlindStockEnabled = true;
  final Map<String, IconData> menuIcons = {
    AppStrings.home: Icons.home_outlined,
    AppStrings.settings: Icons.settings_outlined,
    AppStrings.changePassword: Icons.lock_outlined,
    AppStrings.offlineMode: Icons.offline_bolt_rounded,
  };
  // ============= OFFLINE DB VARIABLES (COPIED FROM HOME VIEW) =============
  final dbDao = OfflineDBDao();
  bool isOfflineMode = SharedPrefs().isOfflineMode;
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    routeObserver.unsubscribe(this);

    final route = ModalRoute.of(context);
    if (route is PageRoute) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // @override
  // void didPopNext() {
  //   //  fetchNewInvebtoryMangaerLocation();
  // }
  @override
  void didPopNext() {
    super.didPopNext();

    // Refresh offline UI when returning to this screen
    if (SharedPrefs().isOfflineMode) {
      setupOfflineLocationUI();
    }
  }

  @override
  void initState() {
    super.initState();
    // _initializeOfflineMode();
    if (SharedPrefs().isOfflineMode) {
      setupOfflineLocationUI();
    }
    // Only fetch switchboard items if NOT in offline mode
    if (!SharedPrefs().isOfflineMode) {
      initializeData();
    }

    menuItems = [
      AppStrings.inventory,
      AppStrings.settings,
      //  AppStrings.offlineMode
    ];
    if (!isLoginazureAd) {
      menuItems.add(AppStrings.changePassword);
    }
    menuItems.add(AppStrings.offlineMode);
  }

  void showTransitionLoader({bool isGoingOffline = true}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: Center(
            child: SizedBox(
              width: MediaQuery.of(context).size.width * 0.80,
              child: Card(
                color: ColorManager.white,
                elevation: 8,
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        isGoingOffline
                            ? ImageAssets.onlineToOffline
                            : ImageAssets.offlineToOnline,
                        width: 150,
                        height: 150,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(height: 10),
                      AnimatedTextWithDots(
                        text: isGoingOffline ? 'Going Offline' : 'Going Online',
                        subtitle: isGoingOffline
                            ? 'Preparing your device for offline mode...'
                            : 'Syncing your data and switching to online mode...',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildErrorWidget(String errorMessage) {
    return Padding(
      padding: const EdgeInsets.all(18.0),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: ColorManager.white,
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                ImageAssets.noRecordFoundIcon,
                width: displayWidth(context) * 0.5,
              ),
              const SizedBox(height: 10),
              Text(
                errorMessage,
                style: getRegularStyle(
                  color: ColorManager.lightGrey,
                  fontSize: FontSize.s20,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void hideTransitionLoader() {
    // Only pop if the dialog is actually showing
    if (Navigator.canPop(context)) {
      Navigator.pop(context);
    }
  }

  bool _isMenuEnabled(String title) {
    // Offline mode  ONLY offline toggle enabled
    if (isOfflineMode) {
      return title == AppStrings.offlineMode;
    }
    return true;
  }

  Future<void> initializeData() async {
    // First call fetchSwitchboardItems and wait for it to complete
    await fetchSwitchboardItems();

    // Then call fetchDashboardItems
    await fetchDashboardItems();
  }

  Future<void> setupOfflineLocationUI() async {
    //1. Get all regions from DB
    final allRegions = await dbDao.getAllRegions();
    LoggerData.dataLog("Regions in DB: $allRegions");
    final allRegions1 = await dbDao.getAllRegions();
    final allLocations = await dbDao.getAllLocations();
    LoggerData.dataLog("ALL REGIONS IN DB: $allRegions1");
    LoggerData.dataLog("ALL LOCATIONS IN DB: $allLocations");
    LoggerData.dataLog(
        "SharedPrefs selectedRegionID: ${SharedPrefs().selectedRegionID}");
    LoggerData.dataLog(
        "SharedPrefs selectedLocationID: ${SharedPrefs().selectedLocationID}");
    if (allRegions.isEmpty) {
      setState(() {
        isLocationEnabled = false;
        isOfflineBlindStockEnabled = false;
        selectRegionTitle = "No regions available";
        selectedRegion = "";
        selectedRegionId = 0;
      });
      return;
    }

    // Validate saved region ID — does it exist in DB?
    final int savedRegionId = SharedPrefs().selectedRegionID;
    Map<String, dynamic>? matchedRegion;

    try {
      matchedRegion = allRegions.firstWhere(
        (r) => r['Region_ID'] == savedRegionId,
      );
      LoggerData.dataLog("Saved region $savedRegionId found in DB");
    } catch (_) {
      matchedRegion = null;
    }

    //  If saved region doesn't exist → use FIRST region from DB
    if (matchedRegion == null) {
      matchedRegion = allRegions.first;
      LoggerData.dataLog(
          "Saved region $savedRegionId NOT in DB. Falling back to first region: ${matchedRegion['Region_ID']}");

      SharedPrefs().selectedRegionID = matchedRegion['Region_ID'];
      SharedPrefs().selectedRegion = matchedRegion['Region_Code'] ?? '';
      SharedPrefs().offlineRegionSubName = matchedRegion['Region_Code'] ?? '';
      SharedPrefs().selectedLocationID = 0; // reset location too
      SharedPrefs().selectedLocation = '';
    }

    //  Bind region UI
    setState(() {
      selectedRegionId = SharedPrefs().selectedRegionID;
      selectedRegion = SharedPrefs().offlineRegionSubName;
      selectRegionTitle = SharedPrefs().offlineRegionLableName.isNotEmpty
          ? SharedPrefs().offlineRegionLableName
          : (matchedRegion!['Region_Code'] ?? 'Select Region');
    });

    LoggerData.dataLog(
        "Region bound: ID=${selectedRegionId}, Code=${selectedRegion}, Title=$selectRegionTitle");

    //  Get locations for the (validated) region
    final locations = await dbDao.getLocationsForDashboard();
    LoggerData.dataLog("Locations for region $selectedRegionId: $locations");

    if (locations.isEmpty) {
      setState(() {
        isLocationEnabled = true;
        isLocationEditable = false;
        isOfflineBlindStockEnabled = false;

        selectLocationTitle =
            "No locations are available for the selected region";
        selectedLocation = "";
        selectedLocationID = 0;

        SharedPrefs().selectedLocation = "";
        SharedPrefs().selectedLocationID = 0;
      });
      return;
    }

    //  Pick saved location or first
    final int savedLocationId = SharedPrefs().selectedLocationID;
    Map<String, dynamic>? selectedLoc;

    try {
      selectedLoc = locations.firstWhere(
        (loc) => loc['Location_ID'] == savedLocationId,
      );
    } catch (_) {
      selectedLoc = null;
    }
    selectedLoc ??= locations.first;

    setState(() {
      isLocationEnabled = true;
      isLocationEditable = locations.length > 1;
      isOfflineBlindStockEnabled = true;

      selectLocationTitle = selectedLoc!['Location_Code'] ?? "Select Location";
      selectedLocation = selectedLoc['Location_Code'];
      selectedLocationID = selectedLoc['Location_ID'];

      SharedPrefs().selectedLocation = selectedLoc['Location_Code'];
      SharedPrefs().selectedLocationID = selectedLoc['Location_ID'];
    });

    LoggerData.dataLog(
        "Location setup done. Location=$selectedLocation (ID=$selectedLocationID)");
  }

  // Future<void> setupOfflineLocationUI() async {
  //   // Get locations for selected region
  //   final locations = await dbDao.getLocationsForDashboard();
  //   LoggerData.dataLog("Locations from DB: $locations");

  //   if (locations.isEmpty) {
  //     setState(() {
  //       isLocationEnabled = true;
  //       isLocationEditable = false;
  //       isOfflineBlindStockEnabled = false;

  //       selectLocationTitle =
  //           "No locations are available for the selected region";
  //       selectedLocation = "";
  //       selectedLocationID = 0;

  //       SharedPrefs().selectedLocation = "";
  //       SharedPrefs().selectedLocationID = 0;
  //     });

  //     LoggerData.dataLog("No locations found for selected region");
  //     return;
  //   }

  //   final int savedLocationId = SharedPrefs().selectedLocationID;
  //   LoggerData.dataLog("Saved Location ID: $savedLocationId");

  //   Map<String, dynamic>? selectedLoc;

  //   // Check whether saved location exists in current region
  //   try {
  //     selectedLoc = locations.firstWhere(
  //       (loc) => loc['Location_ID'] == savedLocationId,
  //     );

  //     LoggerData.dataLog(
  //         "Restored saved location: ${selectedLoc['Location_Code']} (${selectedLoc['Location_ID']})");
  //   } catch (_) {
  //     selectedLoc = null;
  //     LoggerData.dataLog(
  //         "Saved location not found in current region. Using default location.");
  //   }

  //   // If no saved location exists, use first/default location
  //   selectedLoc ??= locations.first;

  //   setState(() {
  //     isLocationEnabled = true;
  //     isLocationEditable = locations.length > 1;
  //     isOfflineBlindStockEnabled = true;

  //     selectLocationTitle = selectedLoc!['Location_Code'] ?? "Select Location";
  //     selectedLocation = selectedLoc['Location_Code'];
  //     selectedLocationID = selectedLoc['Location_ID'];

  //     SharedPrefs().selectedLocation = selectedLoc['Location_Code'];
  //     SharedPrefs().selectedLocationID = selectedLoc['Location_ID'];

  //     selectRegionTitle = SharedPrefs().offlineRegionLableName;
  //     selectedRegion = SharedPrefs().offlineRegionSubName;
  //     selectedRegionId = SharedPrefs().selectedRegionID;
  //   });

  //   LoggerData.dataLog(
  //       "Location setup completed. Selected: $selectedLocation (ID: $selectedLocationID)");
  // }

  Future<void> dataSaveInOfflineDB() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      final requestBody = {
        'uid': SharedPrefs().uID,
        'apptype': AppConstants.apptype,
      };

      final jsonResponse = await apiService.postRequest(
        context,
        ApiService.saveDataInOfflineDB,
        requestBody,
      );

      if (jsonResponse == null) {
        setState(() {
          isError = true;
          errorText = 'No response from server';
        });
        return;
      }

      final resp = GetOfflineDataResponse.fromJson(jsonResponse);

      if (resp.code != 200) {
        await ErrorLoggingService().logApiError(
          exceptionMessage: resp.message.join(', '),
          stackTrace: StackTrace.current.toString(),
          apiUrl: ApiService.saveDataInOfflineDB,
          requestBody: jsonEncode(requestBody),
          screenName: 'home.dart',
          methodName: 'dataSaveInOfflineDB',
          context: context,
        );

        setState(() {
          isError = true;
          errorText = resp.message.join(', ');
        });
        return;
      }

      final data = jsonResponse['data'];
      SharedPrefs().noLocationMessage = resp.data.noLocationMessage;
      await dbDao.clearOfflineData();
      await dbDao.insertLocations(data['locations']);
      await dbDao.insertRegions(data['regions']);
      await dbDao.insertItems(data['items']);
      await dbDao.insertItemsRegion(data['items_region']);
      SharedPrefs().selectedRegionID = 0;
      SharedPrefs().selectedLocationID = 0;
      SharedPrefs().selectedRegion = '';
      SharedPrefs().selectedLocation = '';
      SharedPrefs().offlineRegionSubName = '';
      SharedPrefs().offlineRegionLableName = '';

      LoggerData.dataLog(
          "Reset region/location prefs after fresh offline DB save");

      SharedPrefs().isOfflineMode = true;
      LoggerData.dataLog('Location::::${SharedPrefs().selectedLocationID}');
      LoggerData.dataLog('region::::${SharedPrefs().selectedRegionID}');
      setState(() {
        isOfflineMode = true;
      });
    } catch (e, stackTrace) {
      await ErrorLoggingService().logApiError(
        exceptionMessage: e.toString(),
        stackTrace: stackTrace.toString(),
        apiUrl: ApiService.saveDataInOfflineDB,
        requestBody: jsonEncode({
          'uid': SharedPrefs().uID,
          'apptype': AppConstants.apptype,
        }),
        screenName: 'home.dart',
        methodName: 'dataSaveInOfflineDB',
        context: context,
      );

      setState(() {
        isError = true;
        errorText = 'Failed to save offline data';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<bool> callOfflineToOnlineApi(BuildContext context) async {
    try {
      final unsyncedItems = await dbDao.getUnsyncedItems();

      if (unsyncedItems.isEmpty) {
        // Use Completer to wait for user's choice
        final completer = Completer<bool>();

        await showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => CustomImageActionAlert(
            iconString: '',
            imageString: ImageAssets.goingOffline,
            titleString: "No Data to Resync",
            subTitleString:
                "There is no offline data to resync. Are you sure you want to go online?",
            destructiveActionString: "Yes",
            normalActionString: "No",
            onDestructiveActionTap: () {
              Navigator.pop(context);
              completer.complete(true); // User said YES
            },
            onNormalActionTap: () {
              Navigator.pop(context);
              completer.complete(false); // User said NO
            },
            isConfirmationAlert: true,
            isNormalAlert: true,
          ),
        );

        return await completer.future; // Wait for user's choice
      }

      final Map<String, dynamic> payload = {
        "uid": SharedPrefs().uID,
        "apptype": AppConstants.apptype,
        "items": unsyncedItems.map((item) {
          return {
            "itemId": item.itemId,
            "locationId": item.locationId ?? 0,
            "regionId": item.regionId,
            "quantity": item.totalStockCount,
            "newQuantity": item.newStockCount,
            "comments": item.comments ?? "",
            "updatedOn": item.updatedOn,
            "UOMID": item.unitSelected?.toInt() ?? 0,
            "unitType": item.unitType ?? 'purchase',
          };
        }).toList(),
      };

      LoggerData.dataLog("Offline→Online Payload: $payload");

      final jsonResponse = await apiService.postRequest(
        context,
        ApiService.syncOfflineStock,
        payload,
      );

      if (jsonResponse == null) {
        await ErrorLoggingService().logApiError(
          exceptionMessage: 'No response from server',
          stackTrace: StackTrace.current.toString(),
          apiUrl: ApiService.syncOfflineStock,
          requestBody: jsonEncode(payload),
          screenName: 'home.dart',
          methodName: 'callOfflineToOnlineApi',
          context: context,
        );

        LoggerData.dataLog("Sync failed: No response");
        return false;
      }

      final resp = SaveResponse.fromJson(jsonResponse);

      if (resp.code != 200) {
        await ErrorLoggingService().logApiError(
          exceptionMessage: resp.message.join(", "),
          stackTrace: StackTrace.current.toString(),
          apiUrl: ApiService.syncOfflineStock,
          requestBody: jsonEncode(payload),
          screenName: 'home.dart',
          methodName: 'callOfflineToOnlineApi',
          context: context,
        );

        LoggerData.dataLog("Sync failed: ${resp.message.join(", ")}");
        return false;
      }
      // Mark items as synced
      await dbDao.markItemsAsSynced(unsyncedItems);

      LoggerData.dataLog("Offline data synced successfully");

      return true;
    } catch (e, stackTrace) {
      await ErrorLoggingService().logApiError(
        exceptionMessage: e.toString(),
        stackTrace: stackTrace.toString(),
        apiUrl: ApiService.syncOfflineStock,
        requestBody: jsonEncode({
          "uid": SharedPrefs().uID,
          "apptype": AppConstants.apptype,
        }),
        screenName: 'home.dart',
        methodName: 'callOfflineToOnlineApi',
        context: context,
      );

      LoggerData.dataLog("Sync Exception: $e");
      LoggerData.dataLog(stackTrace.toString());

      return false;
    }
  }

  Future<int> getUnsyncedItemCount() async {
    final items = await dbDao.getUnsyncedItems();
    return items.length;
  }

  Widget _buildOfflineSelectionUI() {
    if (isError) {
      return _buildErrorWidget(errorText);
    }
    return SingleChildScrollView(
      child: Padding(
        padding:
            const EdgeInsets.only(top: 15, left: 10, right: 10, bottom: 15),
        child: Column(
          children: [
            // Region card
            // SharedPrefs().offlineRegionEnabled
            //     ? CustomItemCardWithEdit(
            //         imageString: ImageAssets.selectSite,
            //         title: SharedPrefs().offlineRegionLableName,
            //         subtitle: SharedPrefs().offlineRegionSubName,
            //         onEdit: SharedPrefs().offlineRegionEditable
            //             ? () async {
            //                 final result = await Navigator.push(
            //                   context,
            //                   MaterialPageRoute(
            //                     builder: (context) => OfflineRegionListView(
            //                       selectedItem:
            //                           SharedPrefs().offlineRegionSubName,
            //                       selectedTitle:
            //                           SharedPrefs().offlineRegionLableName,
            //                     ),
            //                   ),
            //                 );

            //                 if (result != null) {
            //                   setState(() {
            //                     selectedRegion = SharedPrefs().selectedRegion;
            //                     selectedRegionId =
            //                         SharedPrefs().selectedRegionID;
            //                     selectRegionTitle =
            //                         SharedPrefs().offlineRegionLableName;

            //                     // Clear previous location while loading new region locations
            //                     selectedLocation = "";
            //                     selectedLocationID = 0;
            //                     isFetchingLocation = true;
            //                   });

            //                   // Reload locations for newly selected region
            //                   await setupOfflineLocationUI();

            //                   setState(() {
            //                     isFetchingLocation = false;
            //                   });
            //                 }
            //               }
            //             : () {},
            //         backgroundColor: ColorManager.white,
            //         cornerRadius: 10,
            //         isEditable: SharedPrefs().offlineRegionEditable,
            //       )
            //     : const SizedBox(),
            SharedPrefs().offlineRegionEnabled
                ? CustomItemCardWithEdit(
                    imageString: ImageAssets.selectSite,
                    title: selectRegionTitle.isNotEmpty
                        ? selectRegionTitle
                        : "Select Region",
                    subtitle: selectedRegion ?? "",
                    onEdit: SharedPrefs().offlineRegionEditable
                        ? () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => OfflineRegionListView(
                                  selectedItem: selectedRegion ?? '',
                                  selectedTitle: selectRegionTitle,
                                ),
                              ),
                            );

                            if (result != null) {
                              setState(() {
                                selectedRegion = SharedPrefs().selectedRegion;
                                selectedRegionId =
                                    SharedPrefs().selectedRegionID;
                                selectRegionTitle =
                                    SharedPrefs().offlineRegionLableName;

                                selectedLocation = "";
                                selectedLocationID = 0;
                                isFetchingLocation = true;
                              });

                              await setupOfflineLocationUI();

                              setState(() {
                                isFetchingLocation = false;
                              });
                            }
                          }
                        : () {},
                    backgroundColor: ColorManager.white,
                    cornerRadius: 10,
                    isEditable: SharedPrefs().offlineRegionEditable,
                  )
                : const SizedBox(),
            SharedPrefs().offlineRegionEditable
                ? const SizedBox(height: 8)
                : const SizedBox(),

            // Location card
            isLocationEnabled
                ? Visibility(
                    visible: !isFetchingLocation,
                    replacement: const Center(child: CustomProgressIndicator()),
                    child: CustomItemCardWithEdit(
                      imageString: ImageAssets.selectLocation,
                      title: (selectedLocation == null ||
                              selectedLocation!.isEmpty)
                          ? SharedPrefs().noLocationMessage
                          : selectLocationTitle,
                      subtitle: selectedLocation!,
                      onEdit: isLocationEditable
                          ? () async {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => OfflineLocationListView(
                                    selectedItem: selectedLocation!,
                                    selectedTitle: selectLocationTitle,
                                  ),
                                ),
                              );

                              LoggerData.dataLog(
                                  "Returned from location selection with result: $result");

                              if (result != null && result is String) {
                                // The result is the selected location code
                                setState(() {
                                  // Update from SharedPrefs
                                  selectedLocation =
                                      SharedPrefs().selectedLocation;
                                  selectedLocationID =
                                      SharedPrefs().selectedLocationID;
                                  selectLocationTitle =
                                      SharedPrefs().selectedLocation ??
                                          "Select Location";
                                });

                                LoggerData.dataLog(
                                    "Updated UI - Location: $selectedLocation (ID: $selectedLocationID)");
                                LoggerData.dataLog(
                                    "Title: $selectLocationTitle");
                              }
                            }
                          : () {},
                      backgroundColor: ColorManager.white,
                      cornerRadius: 10,
                      isEditable: isLocationEditable,
                    ),
                  )
                : const SizedBox(),

            const SizedBox(height: 20),

            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 1,
              crossAxisSpacing: 5,
              mainAxisSpacing: 5,
              childAspectRatio: 4.0,
              children: [
                Opacity(
                  opacity: isOfflineBlindStockEnabled ? 1.0 : 0.5,
                  child: CustomItemCard(
                    imageString: ImageAssets.blindstocklisting,
                    title: "Blind Stock Listing",
                    backgroundColor: ColorManager.white,
                    cornerRadius: 10,
                    onTap: () {
                      if (!isOfflineBlindStockEnabled) {
                        globalUtils.showNegativeSnackBar(
                          context: context,
                          message:
                              "No locations are available for the selected region.",
                        );
                        return;
                      }

                      Navigator.pushNamed(
                        context,
                        Routes.offlineBlindStockListing,
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ========================================================================

  Future<void> fetchSwitchboardItems() async {
    setState(() {
      isLoading = true;
    });
    if (SharedPrefs().isOfflineMode) {
      LoggerData.dataLog('[SWITCHBOARD] Skipping - offline mode');
      return;
    }
    Map<String, dynamic> requestData = {
      'uid': SharedPrefs().uID,
    };

    final jsonResponse = await apiService.postRequest(
      context,
      ApiService.switchboard,
      requestData,
    );

    if (jsonResponse != null) {
      final response = SwitchboardResponse.fromJson(jsonResponse);

      if (response.code == 200) {
        final data = response.data;

        // Save to SharedPrefs
        SharedPrefs().requestFlag = data.request;
        SharedPrefs().orderFlag = data.order;
        SharedPrefs().expenseFlag = data.expense;
        SharedPrefs().invoiceFlag = data.invoice;
        SharedPrefs().inventoryFlag = data.inventory;
        SharedPrefs().region = data.region;

        String regionName = data.regionName ?? '';
        if (regionName.toLowerCase().endsWith(' code')) {
          regionName = regionName.substring(0, regionName.length - 5).trim();
        }

        SharedPrefs().selectRegionTitleSwitchboard = regionName;

        // Read from SharedPrefs (to ensure sync with prefs)
        setState(() {
          isRequestEnabled = SharedPrefs().requestFlag;
          isOrderEnabled = SharedPrefs().orderFlag;
          isExpenseEnabled = SharedPrefs().expenseFlag;
          isInvoiceEnabled = SharedPrefs().invoiceFlag;
          isInventoryEnabled = SharedPrefs().inventoryFlag;
          region = SharedPrefs().region;
          selectRegionTitle = SharedPrefs().selectRegionTitle;
          selectRegionTitleForDashboard =
              SharedPrefs().selectRegionTitleSwitchboard;
          isLoading = false;
        });
      } else {
        setState(() {
          isError = true;
          errorText = response.message.join(', ');
          isLoading = false;
        });
      }
    } else {
      setState(() {
        isError = true;
        errorText = 'Something went wrong. Please try again.';
        isLoading = false;
      });
    }
  }

  Future<void> fetchDashboardItems() async {
    if (SharedPrefs().isOfflineMode) {
      LoggerData.dataLog('[DASHBOARD] Skipping - offline mode');
      return;
    }
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> data = {
      'uid': SharedPrefs().uID,
    };
    final jsonResponse =
        await apiService.postRequest(context, ApiService.dashboard, data);
    if (jsonResponse != null) {
      final response = DashboardResponse.fromJson(jsonResponse);
      if (response.code == '200') {
        // ADD THIS LOG:
        print('🔍 Inventory Manager from API: $inventoryManager');
        print('🔍 Is SSO Login: ${SharedPrefs().isLoginazureAd}');
        setState(() {
          var dataList = jsonResponse['data'] as String;
          List<dynamic> data = jsonDecode(dataList);
          for (var item in data) {
            item.forEach((key, value) {
              if (value is bool && value == true) {
                if (key != AppStrings.apiKeyRegion &&
                    key != AppStrings.apiKeyEditRegion &&
                    key != AppStrings.apiKeyLocation &&
                    key != AppStrings.apiKeyEditLocation) {
                  items.add(key);
                }
              }
            });
          }

          if (response.data.isNotEmpty) {
            SharedPrefs().selectedRegionID = response.data[0].regionId;
            SharedPrefs().selectedLocationID = response.data[0].locationId;
            selectRegionTitle = response.data[0].regionLabelName;
            selectedRegion = response.data[0].regionName;
            selectLocationTitle = response.data[0].locationLabelName;
            selectedLocation = response.data[0].locationName;
            SharedPrefs().selectedLocation = response.data[0].locationName;
            isRegionEnabled = response.data[0].region;
            isRegionEditable = response.data[0].regionEdit;
            isLocationEnabled = response.data[0].location;
            isLocationEditable = response.data[0].locationEdit;
            isScanItemsEnabled = response.data[0].scanYourItem;
            isListItemsEnabled = response.data[0].listAllItems;
            selectedRegionId = response.data[0].regionId;
            SharedPrefs().offlineRegionEnabled = response.data[0].region;
            SharedPrefs().offlineRegionEditable = response.data[0].regionEdit;
            SharedPrefs().offlineRegionLableName =
                response.data[0].regionLabelName;
            SharedPrefs().offlineRegionSubName = response.data[0].regionName;
            SharedPrefs().inventoryManager = response.data[0].inventoryManager;
            SharedPrefs().blindStockEdit = response.data[0].blindStockEdit;
            inventoryManager = response.data[0].inventoryManager;
            // blindStockEdit =
            //  response.data[0].blindStockEdit;
            isGREnabled = response.data[0].gr;
            SharedPrefs().decimalPlaces = response.data[0].decimalPlaces;
            SharedPrefs().decimalplacesprice =
                response.data[0].decimalplacesprice;
            SharedPrefs().decimalplacesquantity =
                response.data[0].decimalplacesquantity!;
            isPermissionDenied = (!isRegionEnabled &&
                    !isLocationEnabled &&
                    !isScanItemsEnabled &&
                    !isListItemsEnabled &&
                    !isGREnabled)
                ? true
                : false;
          }
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

  Future<void> scanBarcode() async {
    try {
      ScanResult barcodeScanResult = await BarcodeScanner.scan();
      String resultString = barcodeScanResult.rawContent;
      String format = barcodeScanResult.format.toString();

      // Log the format for debugging
      LoggerData.dataLog('=== BARCODE SCAN ===');
      LoggerData.dataLog('Format: $format');
      LoggerData.dataLog('Raw Content: $resultString');

      if (resultString.isEmpty || resultString == "-1") {
        return;
      }
      navigateToItemDetails(resultString, format);
    } catch (e) {
      setState(() {
        errorText = "Failed to scan: $e";
        //  showSnackBar(context, errorText);
      });
    }
  }

  void navigateToItemDetails(String resultString, String scanFormat) {
    navigateToScreen(
        context,
        ItemDetailsView(
            resultString: resultString,
            entryType: EntryType.scan,
            scanFormat: scanFormat));
  }

  void navigateToScanItems() {
    scanBarcode();
  }

  void navigateToListItems() {
    navigateToScreen(context, const ItemListView());
  }

  void navigateToReceiveGoods() {
    navigateToScreen(context, const SelectOrderView());
  }

  void navigateFromSideMenuAsPerSelectedTitle(String title) {
    if (title == AppStrings.home) {
      Navigator.pop(context);
    }
    if (title == AppStrings.changePassword) {
      navigateToScreen(context, const ChangePasswordView());
    }
    if (title == AppStrings.settings) {
      navigateToScreen(context, const SettingPage());
    }
  }

  Future<void> fetchNewLocation(int regionId) async {
    setState(() {
      isFetchingLocation = true;
    });

    Map<String, dynamic> data = {
      'uid': SharedPrefs().uID,
      'regionid': regionId
    };
    final jsonResponse =
        await apiService.postRequest(context, ApiService.locationList, data);

    if (jsonResponse != null) {
      final response = LocationResponse.fromJson(jsonResponse);
      totalRecords = response.totalRecords;

      if (response.code == '200') {
        setState(() {
          selectedLocation = response.data![0].locationCode;
          SharedPrefs().selectedLocation = response.data![0].locationCode!;
          SharedPrefs().selectedLocationID = response.data![0].locationId!;
          isLocationNull = false;
          isLocationEditable = totalRecords > 1;

          //  UPDATE OFFLINE PREFS WITH NEW REGION INFO
          SharedPrefs().offlineRegionLableName = selectRegionTitle;
          SharedPrefs().offlineRegionSubName = selectedRegion!;
          SharedPrefs().selectedRegionID = selectedRegionId!;
        });

        // Now call the inventory manager check
        await fetchNewInvebtoryMangaerLocation();
      } else if (response.code == '400') {
        setState(() {
          selectedLocation = '';
          isLocationNull = true;
        });
      } else {
        setState(() {
          isError = true;
          errorText = response.message.join(', ');
        });
      }
    }

    setState(() {
      isFetchingLocation = false;
    });
  }

// Also change this to Future<void> if needed
  Future<void> fetchNewInvebtoryMangaerLocation() async {
    setState(() {
      isLoading = true;
    });
    Map<String, dynamic> data = {
      'uid': SharedPrefs().uID,
      'locationid': SharedPrefs().selectedLocationID
    };
    final jsonResponse = await apiService.postRequest(
        context, ApiService.inventoryManagerLocationCheck, data);

    if (jsonResponse != null) {
      final response = InventoryManagerCheckResponse.fromJson(jsonResponse);

      if (response.code == '200') {
        setState(() {
          SharedPrefs().blindStockEdit = response.data.blindstockedit;
          log("&&&&&&&&&&&&&&&&&&&&&&&blindStockEdit: ${SharedPrefs().blindStockEdit}");
        });
      } else if (response.code == '400') {
        setState(() {
          SharedPrefs().blindStockEdit = false;
        });
      } else {
        setState(() {
          isError = true;
          errorText = response.message.join(', ');
        });
      }
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    double topPadding = MediaQuery.of(context).padding.top;
    final screenHeight = MediaQuery.of(context).size.height;
    final isTablet = screenHeight >= 800;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: ColorManager.primary,
      appBar: AppBar(
        backgroundColor:
            isOfflineMode ? ColorManager.grey : ColorManager.darkBlue,
        toolbarHeight: 56,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.dashboard,
              style: getBoldStyle(
                color: ColorManager.white,
                fontSize: FontSize.s20,
              ),
            ),
            const SizedBox(width: 8),
            if (isOfflineMode)
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
        leading: IconButton(
          icon: Image.asset(
            ImageAssets.menu,
            width: 20,
            height: 20,
          ),
          onPressed: () {
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      drawer: Drawer(
        backgroundColor: ColorManager.light3,
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: topPadding + 10),
              Image.asset(ImageAssets.splashLogo, width: 90, height: 72),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(2),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.person, color: ColorManager.blue, size: 20),
                    const SizedBox(width: 6),
                    Flexible(
                      child: Text(
                        displayUserName,
                        style:
                            TextStyle(fontSize: 18, color: ColorManager.blue),
                        maxLines: 2,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: ColorManager.white,
                    border: Border.all(color: ColorManager.grey4, width: 1.0),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.zero,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: menuItems.length,
                          separatorBuilder: (context, index) => Divider(
                            height: 0.5,
                            thickness: 0.5,
                            color: ColorManager.primary,
                          ),
                          itemBuilder: (context, index) {
                            final title = menuItems[index];
                            final icon =
                                menuIcons[title] ?? Icons.arrow_forward_ios;

                            final bool isEnabled = _isMenuEnabled(title);

                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 0.5),
                              child: title == AppStrings.offlineMode
                                  ? Opacity(
                                      opacity: inventoryManager
                                          ? 1.0
                                          : 0.5, // uncomment it letter offline toggle switch disabled
                                      //opacity: 0.5,
                                      child: ListTile(
                                        contentPadding:
                                            const EdgeInsets.symmetric(
                                          horizontal: 10,
                                        ),
                                        minLeadingWidth: 24,
                                        horizontalTitleGap: 12,
                                        leading: SizedBox(
                                          width: 24,
                                          child: Icon(
                                            isOfflineMode
                                                ? Icons.cloud_download
                                                : Icons.wifi,
                                            color: isOfflineMode
                                                ? ColorManager.orange2
                                                : ColorManager.lightGrey1,
                                            size: FontSize.s20,
                                          ),
                                        ),
                                        title: Text(
                                          isOfflineMode
                                              ? AppStrings.offlineMode
                                              : 'Online Mode',
                                          style: getRegularStyle(
                                            color: isOfflineMode
                                                ? ColorManager.orange2
                                                : ColorManager.lightGrey1,
                                            fontSize: FontSize.s16,
                                          ),
                                        ),
                                        trailing: Switch(
                                          value: isOfflineMode,
                                          activeTrackColor:
                                              ColorManager.orange2,
                                          inactiveTrackColor:
                                              ColorManager.green,
                                          activeColor: ColorManager.white,
                                          inactiveThumbColor:
                                              ColorManager.white,
                                          trackOutlineColor:
                                              WidgetStateProperty.all(
                                                  ColorManager.white),

                                          // Disable switch if:
                                          // 1. Transition is in progress
                                          // 2. User is not Inventory Manager
                                          // onChanged:
                                          //     null, // for now then uncomment onchanged
                                          onChanged: (isTransitioning ||
                                                  !inventoryManager)
                                              ? null
                                              : (value) {
                                                  if (isTransitioning) return;

                                                  showDialog(
                                                    context: context,
                                                    barrierDismissible: false,
                                                    builder: (BuildContext
                                                        dialogContext) {
                                                      final bool goingOffline =
                                                          value;

                                                      return CustomImageActionAlert(
                                                        iconString: '',
                                                        imageString: ImageAssets
                                                            .goingOffline,
                                                        titleString:
                                                            goingOffline
                                                                ? "Offline Mode"
                                                                : "Online Mode",
                                                        subTitleString: goingOffline
                                                            ? "Are you sure you want to go offline?"
                                                            : "Are you sure you want to go online?",
                                                        destructiveActionString:
                                                            "Yes",
                                                        normalActionString:
                                                            "No",
                                                        onDestructiveActionTap:
                                                            () async {
                                                          // Close confirmation dialog
                                                          Navigator.pop(
                                                              dialogContext);

                                                          // Set transitioning state
                                                          setState(() {
                                                            isTransitioning =
                                                                true;
                                                          });

                                                          try {
                                                            if (!goingOffline) {
                                                              // ---- GOING ONLINE ----

                                                              final hasInternet =
                                                                  await Internets
                                                                      .checkInternet();

                                                              LoggerData
                                                                  .dataLog(
                                                                "========== ONLINE MODE INTERNET CHECK ==========",
                                                              );

                                                              LoggerData
                                                                  .dataLog(
                                                                "Internet available: $hasInternet",
                                                              );

                                                              if (!hasInternet) {
                                                                if (mounted) {
                                                                  setState(() {
                                                                    isTransitioning =
                                                                        false;
                                                                  });

                                                                  showSuccessDialog(
                                                                    context,
                                                                    ImageAssets
                                                                        .noInternet,
                                                                    'No Internet',
                                                                    'Your internet is off. Please turn on internet to go online.',
                                                                    true,
                                                                    normalAlertButtonColor:
                                                                        true,
                                                                  );
                                                                }

                                                                return;
                                                              }

                                                              // Internet available
                                                              if (mounted) {
                                                                showTransitionLoader(
                                                                  isGoingOffline:
                                                                      false,
                                                                );
                                                              }

                                                              setState(() {
                                                                isError = false;
                                                                errorText =
                                                                    AppStrings
                                                                        .somethingWentWrong;
                                                              });

                                                              final success =
                                                                  await callOfflineToOnlineApi(
                                                                      context);

                                                              // User cancelled "No Data to Resync"
                                                              if (!success) {
                                                                if (mounted) {
                                                                  hideTransitionLoader();

                                                                  setState(() {
                                                                    isTransitioning =
                                                                        false;
                                                                  });
                                                                }

                                                                return;
                                                              }

                                                              // Sync offline error logs
                                                              await ErrorLoggingService()
                                                                  .syncOfflineErrorLogs(
                                                                      context);

                                                              // Switch to ONLINE
                                                              SharedPrefs()
                                                                      .isOfflineMode =
                                                                  false;

                                                              await initializeData();

                                                              if (mounted) {
                                                                hideTransitionLoader();

                                                                setState(() {
                                                                  isOfflineMode =
                                                                      false;
                                                                  isTransitioning =
                                                                      false;
                                                                });
                                                              }
                                                            } else {
                                                              // ---- GOING OFFLINE ----

                                                              LoggerData
                                                                  .dataLog(
                                                                "========== GOING OFFLINE ==========",
                                                              );

                                                              final hasInternet =
                                                                  await Internets
                                                                      .checkInternet();

                                                              LoggerData
                                                                  .dataLog(
                                                                "Internet available before going offline: $hasInternet",
                                                              );

                                                              if (!hasInternet) {
                                                                if (mounted) {
                                                                  setState(() {
                                                                    isTransitioning =
                                                                        false;
                                                                  });

                                                                  showSuccessDialog(
                                                                    context,
                                                                    ImageAssets
                                                                        .noInternet,
                                                                    'No Internet',
                                                                    'Your internet is off. Please turn on internet to go offline.',
                                                                    true,
                                                                    normalAlertButtonColor:
                                                                        true,
                                                                  );
                                                                }

                                                                return;
                                                              }

                                                              // Show loader
                                                              if (mounted) {
                                                                showTransitionLoader(
                                                                  isGoingOffline:
                                                                      true,
                                                                );
                                                              }

                                                              try {
                                                                // Save data to offline DB
                                                                await dataSaveInOfflineDB();

                                                                // Switch to OFFLINE
                                                                SharedPrefs()
                                                                        .isOfflineMode =
                                                                    true;

                                                                // Setup offline location
                                                                await setupOfflineLocationUI();

                                                                if (mounted) {
                                                                  hideTransitionLoader();

                                                                  setState(() {
                                                                    isOfflineMode =
                                                                        true;
                                                                    isTransitioning =
                                                                        false;
                                                                  });
                                                                }
                                                              } catch (e) {
                                                                if (mounted) {
                                                                  hideTransitionLoader();

                                                                  setState(() {
                                                                    isTransitioning =
                                                                        false;
                                                                  });

                                                                  showErrorDialog(
                                                                    context,
                                                                    "Failed to switch to offline mode: $e",
                                                                    false,
                                                                  );
                                                                }
                                                              }
                                                            }
                                                          } catch (e) {
                                                            if (mounted) {
                                                              hideTransitionLoader();

                                                              setState(() {
                                                                isTransitioning =
                                                                    false;
                                                              });
                                                            }

                                                            showErrorDialog(
                                                              context,
                                                              "An error occurred: $e",
                                                              false,
                                                            );
                                                          }
                                                        },
                                                        onNormalActionTap: () {
                                                          Navigator.pop(
                                                              dialogContext);
                                                        },
                                                        isConfirmationAlert:
                                                            true,
                                                        isNormalAlert: true,
                                                      );
                                                    },
                                                  );
                                                },

                                          //-------------------------------upto here uncomment
                                        ),
                                      ),
                                    )
                                  : IgnorePointer(
                                      ignoring: !isEnabled,
                                      child: Opacity(
                                        opacity: isEnabled ? 1.0 : 0.4,
                                        child: MenuItemListTile(
                                          title: title,
                                          iconData: icon,
                                          onTap: () {
                                            if (!isEnabled) return;

                                            navigateFromSideMenuAsPerSelectedTitle(
                                                title);
                                          },
                                        ),
                                      ),
                                    ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 6),
                      IgnorePointer(
                        ignoring: isOfflineMode,
                        child: Opacity(
                          opacity: isOfflineMode ? 0.4 : 1.0,
                          child: GestureDetector(
                            onTap: () async {
                              if (isOfflineMode) return;
                              LogoutHelper.forceLogout();
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LogOutPage(),
                                ),
                              );
                            },
                            child: SizedBox(
                              height: 60,
                              width: displayWidth(context),
                              child: Column(
                                children: [
                                  Container(
                                      height: 1, color: ColorManager.grey6),
                                  const SizedBox(height: 10),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Image.asset(
                                        ImageAssets.logoutIcon,
                                        width: 20,
                                        height: 20,
                                        color: ColorManager.orange,
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        AppStrings.logout,
                                        style: getSemiBoldStyle(
                                          color: ColorManager.orange,
                                          fontSize: FontSize.s18,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                height: isTablet ? screenHeight * 0.52 : screenHeight * 0.4,
              ), // Replaced Spacer with fixed height
              Padding(
                padding: const EdgeInsets.all(10.0),
                child: Text(
                  'V${SharedPrefs().mobileVersion}',
                  style: TextStyle(
                    fontSize: 13,
                    color: ColorManager.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CustomProgressIndicator())
          : isError
              ? _buildErrorWidget(errorText) // Same widget for all errors
              : isOfflineMode
                  ? _buildOfflineSelectionUI()
                  : isPermissionDenied
                      ? SingleChildScrollView(
                          child: Padding(
                            padding: const EdgeInsets.all(18.0),
                            child: Container(
                              height: displayHeight(context) - 150,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                borderRadius:
                                    const BorderRadius.all(Radius.circular(8)),
                                color: ColorManager.white,
                              ),
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    child: Image(
                                      image: AssetImage(
                                          ImageAssets.permissionDenied),
                                    ),
                                  ),
                                  SizedBox(
                                    child: CenterTitleHeader(
                                      titleText:
                                          AppStrings.permissionDeniedTitle,
                                      detailText:
                                          AppStrings.permissionDeniedSubTitle,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        )
                      : selectRegionTitle.isEmpty
                          ? Container(
                              color: ColorManager.white,
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      ImageAssets.noRecordFoundIcon,
                                      width: displayWidth(context) * 0.5,
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Region is not selected. Please contact the system administrator.",
                                      style: getMediumStyle(
                                        color: ColorManager.black,
                                        fontSize: FontSize.s16,
                                      ),
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SingleChildScrollView(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    top: 15, left: 10, right: 10, bottom: 15),
                                child: Column(
                                  children: [
                                    // Region card
                                    isRegionEnabled
                                        ? CustomItemCardWithEdit(
                                            imageString: ImageAssets.selectSite,
                                            title: selectRegionTitle,
                                            subtitle: selectedRegion!,
                                            onEdit: isRegionEditable
                                                ? () async {
                                                    final result =
                                                        await Navigator.push(
                                                      context,
                                                      MaterialPageRoute(
                                                        builder: (context) =>
                                                            RegionListView(
                                                          selectedItem:
                                                              selectedRegion!,
                                                          selectedTitle:
                                                              selectRegionTitle,
                                                        ),
                                                      ),
                                                    );

                                                    if (result != null) {
                                                      setState(() {
                                                        selectedRegion =
                                                            SharedPrefs()
                                                                .selectedRegion;
                                                        selectedRegionId =
                                                            SharedPrefs()
                                                                .selectedRegionID;
                                                      });

                                                      // Wait until new location is loaded and inventory manager check is done
                                                      await fetchNewLocation(
                                                          SharedPrefs()
                                                              .selectedRegionID);
                                                    }
                                                  }
                                                : () {},
                                            backgroundColor: ColorManager.white,
                                            cornerRadius: 10,
                                            isEditable: isRegionEditable)
                                        : const SizedBox(),
                                    isRegionEnabled
                                        ? const SizedBox(height: 8)
                                        : const SizedBox(),
                                    // Location card
                                    isLocationEnabled
                                        ? Visibility(
                                            visible: !isFetchingLocation,
                                            replacement: const Center(
                                                child:
                                                    CustomProgressIndicator()),
                                            child: CustomItemCardWithEdit(
                                              imageString:
                                                  ImageAssets.selectLocation,
                                              title: (selectedLocation ==
                                                          null ||
                                                      selectedLocation!.isEmpty)
                                                  ? "No locations are available  for the selected $selectRegionTitleForDashboard"
                                                  : selectLocationTitle,
                                              subtitle: selectedLocation!,
                                              onEdit: isLocationEditable
                                                  ? () async {
                                                      final result =
                                                          await Navigator.push(
                                                        context,
                                                        MaterialPageRoute(
                                                          builder: (context) =>
                                                              LocationListView(
                                                            selectedItem:
                                                                selectedLocation!,
                                                            selectedTitle:
                                                                selectLocationTitle,
                                                            selectedRegioId:
                                                                selectedRegionId!,
                                                          ),
                                                        ),
                                                      );
                                                      if (result != null) {
                                                        setState(() {
                                                          selectedLocation =
                                                              SharedPrefs()
                                                                  .selectedLocation;
                                                        });

                                                        await fetchNewInvebtoryMangaerLocation();
                                                      }
                                                    }
                                                  : () {},
                                              backgroundColor:
                                                  ColorManager.white,
                                              cornerRadius: 10,
                                              isEditable: isLocationEditable &&
                                                  (selectedLocation
                                                          ?.isNotEmpty ??
                                                      false),
                                            ),
                                          )
                                        : const SizedBox(),
                                    const SizedBox(height: 10),

                                    GridView.count(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 10,
                                      mainAxisSpacing: 10,
                                      childAspectRatio: 1.7,
                                      children: [
                                        // Scan Item
                                        if (items.contains(
                                            AppStrings.apiKeyScanItems))
                                          CustomItemCard(
                                            imageString:
                                                ImageAssets.scanYourItems,
                                            title: AppStrings.scanYourItem,
                                            backgroundColor: ColorManager.white,
                                            cornerRadius: 10,
                                            onTap: isLocationNull
                                                ? () => globalUtils
                                                        .showNegativeSnackBar(
                                                      context: context,
                                                      message:
                                                          "Location Required",
                                                    )
                                                : navigateToScanItems,
                                          ),

                                        // List Items
                                        if (items.contains(
                                            AppStrings.apiKeyListItems))
                                          CustomItemCard(
                                            imageString:
                                                ImageAssets.listAllItems,
                                            title: AppStrings.listAllItems,
                                            backgroundColor: ColorManager.white,
                                            cornerRadius: 10,
                                            onTap: isLocationNull
                                                ? () => globalUtils
                                                        .showNegativeSnackBar(
                                                      context: context,
                                                      message:
                                                          "Location Required",
                                                    )
                                                : navigateToListItems,
                                          ),

                                        // Receive Goods
                                        if (items.contains(
                                            AppStrings.apiKeyReceiveGoods))
                                          CustomItemCard(
                                            imageString:
                                                ImageAssets.receiveGoods,
                                            title: AppStrings.receiveGoods,
                                            backgroundColor: ColorManager.white,
                                            cornerRadius: 10,
                                            onTap: isLocationNull
                                                ? () => globalUtils
                                                        .showNegativeSnackBar(
                                                      context: context,
                                                      message:
                                                          "Location Required",
                                                    )
                                                : navigateToReceiveGoods,
                                          ),

                                        // Blind Stock
                                        if (inventoryManager == true)
                                          Opacity(
                                            opacity:
                                                SharedPrefs().blindStockEdit ==
                                                        true
                                                    ? 1.0
                                                    : 0.5,
                                            child: CustomItemCard(
                                              imageString:
                                                  ImageAssets.blindstocklisting,
                                              title: "Blind Stock Listing",
                                              backgroundColor:
                                                  ColorManager.white,
                                              cornerRadius: 10,
                                              onTap: () {
                                                if (SharedPrefs()
                                                        .blindStockEdit !=
                                                    true) {
                                                  globalUtils
                                                      .showNegativeSnackBar(
                                                    context: context,
                                                    message:
                                                        "You are not designated as the Inventory Manager for ${SharedPrefs().selectedLocation} location.",
                                                  );
                                                  LoggerData.dataLog(
                                                      "You are not designated as the Inventory Manager for ${SharedPrefs().selectedLocation} location.");
                                                  return;
                                                }
                                                if (isLocationNull) {
                                                  globalUtils
                                                      .showNegativeSnackBar(
                                                    context: context,
                                                    message:
                                                        "Location Required",
                                                  );
                                                  return;
                                                }

                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const BlindStockListView(),
                                                  ),
                                                );
                                              },
                                            ),
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
