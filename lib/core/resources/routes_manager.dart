import 'package:eyvo_v3/app/app_prefs.dart';
import 'package:eyvo_v3/core/widgets/approver_detailed_page.dart';
import 'package:eyvo_v3/core/widgets/thankYouPage.dart';
import 'package:eyvo_v3/features/auth/view/screens/approval/approval_view.dart';
import 'package:eyvo_v3/features/auth/view/screens/approval/order_approval_view.dart';
import 'package:eyvo_v3/features/auth/view/screens/approval/order_details_view.dart';
import 'package:eyvo_v3/features/auth/view/screens/approval/request_approval_details.dart';
import 'package:eyvo_v3/features/auth/view/screens/approval/request_approval_view.dart';
import 'package:eyvo_v3/features/auth/view/screens/approval/show_group_approver_list.dart';
import 'package:eyvo_v3/features/auth/view/screens/dashboard/dashbord.dart';
import 'package:eyvo_v3/features/auth/view/screens/company_code/company_code.dart';
import 'package:eyvo_v3/features/logout/logout_page.dart';
import 'package:eyvo_v3/local_db/view/offline_blind_stock_details_view.dart';
import 'package:eyvo_v3/local_db/view/offline_blind_stock_list_view.dart';
import 'package:eyvo_v3/local_db/view/transaction_history.dart';
import 'package:eyvo_v3/log_data.dart/logger_data.dart';
import 'package:eyvo_v3/presentation/blind_stock/blindstock_list.dart';
import 'package:eyvo_v3/presentation/blind_stock_details/blindstock_details.dart';
import 'package:eyvo_v3/presentation/change_password/change_password.dart';
import 'package:eyvo_v3/presentation/create_pin/create_pin.dart';
import 'package:eyvo_v3/presentation/pdf_view/pdf_view.dart';
import 'package:eyvo_v3/presentation/email_sent/email_sent.dart';
import 'package:eyvo_v3/presentation/enter_pin/enter_pin.dart';
import 'package:eyvo_v3/presentation/enter_user_id/enter_user_id.dart';
import 'package:eyvo_v3/presentation/forgot_password/forgot_password.dart';
import 'package:eyvo_v3/presentation/forgot_user_id/forgot_user_id.dart';
import 'package:eyvo_v3/presentation/home/home.dart';
import 'package:eyvo_v3/presentation/item_details/item_details.dart';
import 'package:eyvo_v3/presentation/item_list/item_list.dart';
import 'package:eyvo_v3/features/auth/view/screens/login/login.dart';
import 'package:eyvo_v3/presentation/location_list/location_list.dart';
import 'package:eyvo_v3/presentation/password_changed/password_changed.dart';
import 'package:eyvo_v3/presentation/pin_changed/pin_changed.dart';
import 'package:eyvo_v3/presentation/received_item_list/received_item_list.dart';
import 'package:eyvo_v3/core/resources/strings_manager.dart';
import 'package:eyvo_v3/presentation/reset_password/reset_password.dart';
import 'package:eyvo_v3/presentation/select_order/select_order.dart';
import 'package:eyvo_v3/presentation/set_pin/set_pin.dart';
import 'package:eyvo_v3/presentation/site_list/region_list.dart';
import 'package:eyvo_v3/presentation/splash/splash.dart';
import 'package:eyvo_v3/presentation/verify_email/verify_email.dart';
import 'package:flutter/material.dart';

//final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

// class Routes {
//   static const String splashRoute = "/";
//   static const String companyCodeRoute = "/companyCode";
//   static const String loginRoute = "/login";
//   static const String forgotUserIDRoute = "/forgotUserID";
//   static const String emailSentRoute = "/emailSent";
//   static const String forgotPasswordRoute = "/forgotPassword";
//   static const String enterUserIDRoute = "/enterUserID";
//   static const String verifyEmailRoute = "/verifyEmail";
//   static const String resetPasswordRoute = "/resetPassword";
//   static const String passwordChangedRoute = "/passwordChanged";
//   static const String pinChangedRoute = "/pinChanged";
//   static const String createPINRoute = "/createPIN";
//   static const String enterPINRoute = "/enterPIN";
//   static const String setPINRoute = "/setPIN";
//   static const String homeRoute = "/home";
//   static const String inventoryRoute = "/inventory";
//   static const String changePasswordRoute = "/changePassword";
//   static const String regionListRoute = "/regionList";
//   static const String locationListRoute = "/locationList";
//   static const String itemDetailsRoute = "/itemDetails";
//   static const String itemsInOutRoute = "/itemsInOut";
//   static const String itemListRoute = "/itemList";
//   static const String selectOrderRoute = "/selectOrder";
//   static const String searchOrderRoute = "/searchOrder";
//   static const String receivedItemListRoute = "/receivedItemList";
//   static const String pdfViewRoute = "/pdfView";
//   static const String approvalRoute = "/approvalView";
//   static const String requestApprovalRoute = "/requestApprovalView";
//   static const String requestApprovalDetailsRoute = "/RequestDetailsView";
//   static const String orderApproverPage = "/orderApproverPage";
//   static const String orderDetailsView = "/orderDetailsView";
//   static const String genericDetailRoute = "/genericDetailPage";
//   // static const String genericDetailAPIRoute = "/genericDetailAPIPage";
//   static const String thankYouRoute = "/thankYou";
//   static const String showGroupApprovalListRoute = "/showGroupApprovalList";
//   static const String logOutRoute = "/logOutPage";
//   static const String offlineBlindStockDetailsRoute =
//       "/offlineBlindStockDetailsRoute";
//   static const String transactionsRoute = "/transactions";
//   static const String offlineBlindStockListing = "/offlineBlindStockListing";
// }

// class RouteGenerator {
//   static Route<dynamic> getRoute(RouteSettings routeSettings) {
//     LoggerData.dataLog('Navigate Screen : $routeSettings');
//     switch (routeSettings.name) {
//       case Routes.splashRoute:
//         return MaterialPageRoute(builder: (_) => const SplashView());
//       case Routes.companyCodeRoute:
//         return MaterialPageRoute(builder: (_) => const CompanyCodeView());
//       case Routes.loginRoute:
//         return MaterialPageRoute(builder: (_) => const LoginViewPage());
//       case Routes.forgotUserIDRoute:
//         return MaterialPageRoute(
//             builder: (_) => const ForgotUserIDView(), fullscreenDialog: true);
//       case Routes.emailSentRoute:
//         return MaterialPageRoute(
//             builder: (_) => const EmailSentView(), fullscreenDialog: true);
//       case Routes.forgotPasswordRoute:
//         return MaterialPageRoute(
//             builder: (_) => const ForgotPasswordView(), fullscreenDialog: true);
//       case Routes.enterUserIDRoute:
//         return MaterialPageRoute(
//             builder: (_) => const EnterUserIDView(), fullscreenDialog: true);
//       case Routes.verifyEmailRoute:
//         return MaterialPageRoute(
//             builder: (_) => const VerifyEmailView(userName: ''),
//             fullscreenDialog: true);
//       case Routes.resetPasswordRoute:
//         return MaterialPageRoute(
//             builder: (_) => const ResetPasswordView(), fullscreenDialog: true);
//       case Routes.passwordChangedRoute:
//         return MaterialPageRoute(builder: (_) => const PasswordChangedView());
//       case Routes.pinChangedRoute:
//         return MaterialPageRoute(builder: (_) => const PinChangedView());
//       case Routes.createPINRoute:
//         return MaterialPageRoute(builder: (_) => const CreatePINView());
//       case Routes.enterPINRoute:
//         return MaterialPageRoute(builder: (_) => const EnterPINView());
//       case Routes.setPINRoute:
//         return MaterialPageRoute(builder: (_) => const SetPINView());
//       case Routes.homeRoute:
//         return MaterialPageRoute(builder: (_) => HomeView());
//       case Routes.inventoryRoute:
//         return MaterialPageRoute(builder: (_) => const InverntoryView());
//       case Routes.approvalRoute:
//         return MaterialPageRoute(builder: (_) => const ApprovalView());
//       case Routes.requestApprovalRoute:
//         return MaterialPageRoute(builder: (_) => const RequestApprovalPage());
//       case Routes.requestApprovalDetailsRoute:
//         return MaterialPageRoute(
//             builder: (_) => const RequestDetailsView(
//                   requestId: 0,
//                   requestNumber: '',
//                 ));
//       case Routes.orderApproverPage:
//         return MaterialPageRoute(builder: (_) => const OrderApproverPage());
//       case Routes.orderDetailsView:
//         return MaterialPageRoute(
//           builder: (_) => const OrderDetailsView(
//             orderId: 0,
//             orderNumber: '0',
//           ),
//         );
//       case Routes.genericDetailRoute:
//         final args = routeSettings.arguments as Map<String, dynamic>;

//         return MaterialPageRoute(
//           builder: (_) => GenericDetailPage(
//             title: args['title'],
//             data: args['data'],
//           ),
//         );

//       case Routes.thankYouRoute:
//         final args = routeSettings.arguments as Map<String, dynamic>;

//         return MaterialPageRoute(
//           builder: (_) => ThankYouPage(
//               message: args['message'] ?? '',
//               approverName: args['approverName'] ?? '',
//               status: args['status'] ?? '',
//               requestName: args['requestName'] ?? '',
//               number: args['number'] ?? ''),
//         );

//       case Routes.showGroupApprovalListRoute:
//         final args = routeSettings.arguments as Map<String, dynamic>;

//         return MaterialPageRoute(
//           builder: (_) => ShowGroupApprovalList(
//             id: args['id'],
//             from: args['from'],
//           ),
//         );

//       case Routes.changePasswordRoute:
//         return MaterialPageRoute(builder: (_) => const ChangePasswordView());
//       case Routes.regionListRoute:
//         return MaterialPageRoute(
//             builder: (_) =>
//                 const RegionListView(selectedItem: '', selectedTitle: ''));
//       case Routes.locationListRoute:
//         return MaterialPageRoute(
//             builder: (_) => const LocationListView(
//                   selectedItem: '',
//                   selectedTitle: '',
//                   selectedRegioId: 0,
//                 ));
//       case Routes.itemDetailsRoute:
//         return MaterialPageRoute(
//             builder: (_) => const ItemDetailsView(
//                   resultString: '',
//                   entryType: EntryType.listing,
//                   scanFormat: '',
//                   itemId: 0,
//                 ));
//       case Routes.itemListRoute:
//         return MaterialPageRoute(builder: (_) => const ItemListView());
//       case Routes.selectOrderRoute:
//         return MaterialPageRoute(builder: (_) => const SelectOrderView());
//       case Routes.receivedItemListRoute:
//         return MaterialPageRoute(
//             builder: (_) => const ReceivedItemListView(
//                   orderNumber: '',
//                   orderId: 0,
//                 ));
//       case Routes.pdfViewRoute:
//         return MaterialPageRoute(
//             builder: (_) => const PDFViewScreen(
//                   orderNumber: '',
//                   orderId: 0,
//                   itemId: 0,
//                   grNo: "",
//                 ));
//       case Routes.logOutRoute:
//         return MaterialPageRoute(builder: (_) => LogOutPage());
//       // case Routes.genericDetailAPIRoute:
//       //   final args = routeSettings.arguments as Map<String, dynamic>;
//       //   return MaterialPageRoute(
//       //     builder: (_) => GenericDetailAPIPage(
//       //       title: args['title'] ?? '',
//       //       id: args['id'],
//       //       type: args['type'],
//       //       lineId: args['lineId'],
//       //     ),
//       //   );
//       case Routes.offlineBlindStockDetailsRoute:
//         final args = routeSettings.arguments as Map<String, dynamic>;
//         return MaterialPageRoute(
//           settings: RouteSettings(
//             name: Routes.offlineBlindStockDetailsRoute,
//             arguments: args,
//           ),
//           builder: (_) => OfflineBlindStockDetailsView(
//             itemId: args['itemId'] as int,
//           ),
//         );
//       case Routes.transactionsRoute:
//         return MaterialPageRoute(
//           settings: const RouteSettings(name: Routes.transactionsRoute),
//           fullscreenDialog: true,
//           builder: (_) => const TransactionsRoute(),
//         );
//       case Routes.offlineBlindStockListing:
//         return MaterialPageRoute(
//           settings: const RouteSettings(name: Routes.offlineBlindStockListing),
//           builder: (_) => const OfflineBlindStockListView(),
//         );

//       default:
//         return unDefinedRoute();
//     }
//   }

//   static Route<dynamic> unDefinedRoute() {
//     return MaterialPageRoute(
//         builder: (_) => Scaffold(
//               appBar: AppBar(
//                 title: const Text(AppStrings.noRouteFound),
//               ),
//               body: const Center(
//                 child: Text(AppStrings.noRouteFound),
//               ),
//             ));
//   }
// }
class RouteTracker extends RouteObserver<PageRoute<dynamic>> {
  void _saveScreen(Route? route) {
    if (route is PageRoute) {
      final String? name = route.settings.name;
      final Object? args = route.settings.arguments;

      LoggerData.dataLog('RouteTracker hit → $name');
      LoggerData.dataLog('RouteTracker args → $args');

      if (name == null || name.isEmpty) return;

      // Do NOT save auth / splash screens
      if (name == Routes.splashRoute ||
          name == Routes.loginRoute ||
          name == Routes.companyCodeRoute ||
          name == Routes.logOutRoute) {
        return;
      }

      // Save route name
      SharedPrefs().lastScreen = name;

      // Save arguments safely
      if (args is Map<String, dynamic>) {
        SharedPrefs().lastScreenArgs = args;
      } else {
        SharedPrefs().lastScreenArgs = null;
      }

      LoggerData.dataLog('Saved last screen: $name');
    }
  }

  // When a new screen is pushed (user navigates TO this screen)
  @override
  void didPush(Route route, Route? previousRoute) {
    super.didPush(route, previousRoute);

    // Save the screen we're GOING TO
    _saveScreen(route);
  }

  // When a screen is replaced
  @override
  void didReplace({Route? newRoute, Route? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);

    // Save the new screen
    if (newRoute != null) {
      _saveScreen(newRoute);
    }
  }

  // When user pops (navigates back)
  @override
  void didPop(Route route, Route? previousRoute) {
    super.didPop(route, previousRoute);

    // Save the screen we're RETURNING TO
    _saveScreen(previousRoute);
  }
}

// SINGLE INSTANCE
final RouteTracker routeObserver = RouteTracker();

class Routes {
  static const String splashRoute = "/";
  static const String companyCodeRoute = "/companyCode";
  static const String loginRoute = "/login";
  static const String forgotUserIDRoute = "/forgotUserID";
  static const String emailSentRoute = "/emailSent";
  static const String forgotPasswordRoute = "/forgotPassword";
  static const String enterUserIDRoute = "/enterUserID";
  static const String verifyEmailRoute = "/verifyEmail";
  static const String resetPasswordRoute = "/resetPassword";
  static const String passwordChangedRoute = "/passwordChanged";
  static const String pinChangedRoute = "/pinChanged";
  static const String createPINRoute = "/createPIN";
  static const String enterPINRoute = "/enterPIN";
  static const String setPINRoute = "/setPIN";
  static const String homeRoute = "/home";
  static const String inventoryRoute = "/inventory";
  static const String changePasswordRoute = "/changePassword";
  static const String regionListRoute = "/regionList";
  static const String locationListRoute = "/locationList";
  static const String itemDetailsRoute = "/itemDetails";
  static const String itemsInOutRoute = "/itemsInOut";
  static const String itemListRoute = "/itemList";
  static const String selectOrderRoute = "/selectOrder";
  static const String searchOrderRoute = "/searchOrder";
  static const String receivedItemListRoute = "/receivedItemList";
  static const String pdfViewRoute = "/pdfView";
  static const String approvalRoute = "/approvalView";
  static const String requestApprovalRoute = "/requestApprovalView";
  static const String requestApprovalDetailsRoute = "/RequestDetailsView";
  static const String orderApproverPage = "/orderApproverPage";
  static const String orderDetailsView = "/orderDetailsView";
  static const String genericDetailRoute = "/genericDetailPage";
  // static const String genericDetailAPIRoute = "/genericDetailAPIPage";
  static const String thankYouRoute = "/thankYou";
  static const String showGroupApprovalListRoute = "/showGroupApprovalList";
  static const String logOutRoute = "/logOutPage";
  static const String offlineBlindStockDetailsRoute =
      "/offlineBlindStockDetailsRoute";
  static const String blindStockDetailsRoute = "/blindStockDetailsRoute";
  static const String settingPage = "/settingPage";
  static const String offlineBlindStockListing = "/offlineBlindStockListing";
  static const String blindStockListing = "/blindStockListing";
  static const String transactionsRoute = "/transactions";
  static const String inventoryItemListRoute = "/inventoryItemListRoute";
  static const String inventoryItemDetailsRoute = "/inventoryItemDetailsRoute";
}

class RouteGenerator {
  static Route<dynamic> getRoute(RouteSettings routeSettings) {
    LoggerData.dataLog('Navigate Screen : $routeSettings');

    switch (routeSettings.name) {
      // ============ AUTH & SPLASH ROUTES (No Arguments) ============
      case Routes.splashRoute:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Routes.splashRoute),
          builder: (_) => const SplashView(),
        );

      case Routes.companyCodeRoute:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Routes.companyCodeRoute),
          builder: (_) => const CompanyCodeView(),
        );

      case Routes.loginRoute:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Routes.loginRoute),
          builder: (_) => const LoginViewPage(),
        );

      case Routes.forgotUserIDRoute:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Routes.forgotUserIDRoute),
          fullscreenDialog: true,
          builder: (_) => const ForgotUserIDView(),
        );

      case Routes.emailSentRoute:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Routes.emailSentRoute),
          fullscreenDialog: true,
          builder: (_) => const EmailSentView(),
        );

      case Routes.forgotPasswordRoute:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Routes.forgotPasswordRoute),
          fullscreenDialog: true,
          builder: (_) => const ForgotPasswordView(),
        );

      case Routes.enterUserIDRoute:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Routes.enterUserIDRoute),
          fullscreenDialog: true,
          builder: (_) => const EnterUserIDView(),
        );

      case Routes.verifyEmailRoute:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Routes.verifyEmailRoute),
          fullscreenDialog: true,
          builder: (_) => const VerifyEmailView(userName: ''),
        );

      case Routes.resetPasswordRoute:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Routes.resetPasswordRoute),
          fullscreenDialog: true,
          builder: (_) => const ResetPasswordView(),
        );

      case Routes.passwordChangedRoute:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Routes.passwordChangedRoute),
          builder: (_) => const PasswordChangedView(),
        );

      case Routes.pinChangedRoute:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Routes.pinChangedRoute),
          builder: (_) => const PinChangedView(),
        );

      case Routes.createPINRoute:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Routes.createPINRoute),
          builder: (_) => const CreatePINView(),
        );

      case Routes.enterPINRoute:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Routes.enterPINRoute),
          builder: (_) => const EnterPINView(),
        );

      case Routes.setPINRoute:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Routes.setPINRoute),
          builder: (_) => const SetPINView(),
        );

      case Routes.logOutRoute:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Routes.logOutRoute),
          builder: (_) => const LogOutPage(),
        );

      // ============ MAIN SCREENS (No Arguments) ============
      case Routes.homeRoute:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Routes.homeRoute),
          builder: (_) => HomeView(),
        );

      case Routes.inventoryRoute:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Routes.inventoryRoute),
          builder: (_) => const InverntoryView(),
        );

      case Routes.changePasswordRoute:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Routes.changePasswordRoute),
          builder: (_) => const ChangePasswordView(),
        );

      // case Routes.approvalRoute:
      //   return MaterialPageRoute(
      //     settings: const RouteSettings(name: Routes.approvalRoute),
      //     builder: (_) => ApprovalView(),
      //   );

      // case Routes.requestApprovalRoute:
      //   return MaterialPageRoute(
      //     settings: const RouteSettings(name: Routes.requestApprovalRoute),
      //     builder: (_) => const RequestApprovalListPage(),
      //   );

      // case Routes.orderApproverPage:
      //   return MaterialPageRoute(
      //     settings: const RouteSettings(name: Routes.orderApproverPage),
      //     builder: (_) => const OrderApproverListPage(),
      //   );

      case Routes.itemListRoute:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Routes.itemListRoute),
          builder: (_) => const ItemListView(),
        );

      case Routes.selectOrderRoute:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Routes.selectOrderRoute),
          builder: (_) => const SelectOrderView(),
        );

      case Routes.transactionsRoute:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Routes.transactionsRoute),
          fullscreenDialog: true,
          builder: (_) => const TransactionsRoute(),
        );

      case Routes.offlineBlindStockListing:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Routes.offlineBlindStockListing),
          builder: (_) => const OfflineBlindStockListView(),
        );

      case Routes.pdfViewRoute:
        return MaterialPageRoute(
            settings: const RouteSettings(name: Routes.pdfViewRoute),
            builder: (_) => const PDFViewScreen(
                  orderNumber: '',
                  orderId: 0,
                  itemId: 0,
                  grNo: "",
                ));

      // case Routes.thankYouRoute:
      //   return MaterialPageRoute(
      //     settings: const RouteSettings(name: Routes.thankYouRoute),
      //     builder: (_) => const ThankYouPage(),
      //   );

      // ============ ROUTES WITH ARGUMENTS ============

      // Region List
      case Routes.regionListRoute:
        final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          settings: RouteSettings(
            name: Routes.regionListRoute,
            arguments: args,
          ),
          builder: (_) => RegionListView(
            selectedItem: args['selectedItem'] ?? '',
            selectedTitle: args['selectedTitle'] ?? '',
          ),
        );

      // Location List
      case Routes.locationListRoute:
        final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          settings: RouteSettings(
            name: Routes.locationListRoute,
            arguments: args,
          ),
          builder: (_) => LocationListView(
            selectedItem: args['selectedItem'] ?? '',
            selectedTitle: args['selectedTitle'] ?? '',
            selectedRegioId: args['selectedRegioId'] ?? 0,
          ),
        );

      // Item Details
      case Routes.itemDetailsRoute:
        final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          settings: RouteSettings(
            name: Routes.itemDetailsRoute,
            arguments: args,
          ),
          builder: (_) => ItemDetailsView(
            itemId: args['itemId'],
            resultString: args['resultString'],
            entryType: args['entryType'],
            scanFormat: args['scanFormat'],
          ),
        );

      // Items In/Out
      // case Routes.itemsInOutRoute:
      //   final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
      //   return MaterialPageRoute(
      //     settings: RouteSettings(
      //       name: Routes.itemsInOutRoute,
      //       arguments: args,
      //     ),
      //     builder: (_) => ItemsInOutView(
      //       itemId: args['itemId'] ?? 0,
      //     ),
      //   );

      // Search Order
      // case Routes.searchOrderRoute:
      //   final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
      //   return MaterialPageRoute(
      //     settings: RouteSettings(
      //       name: Routes.searchOrderRoute,
      //       arguments: args,
      //     ),
      //     builder: (_) => SearchOrderView(
      //       orderNumber: args['orderNumber'] ?? '',
      //     ),
      //   );

      // Received Item List
      case Routes.receivedItemListRoute:
        final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          settings: RouteSettings(
            name: Routes.receivedItemListRoute,
            arguments: args,
          ),
          builder: (_) => ReceivedItemListView(
            orderNumber: args['orderNumber'] ?? '',
            orderId: args['orderId'] ?? 0,
          ),
        );

      // // Request Approval Details
      // case Routes.requestApprovalDetailsRoute:
      //   final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
      //   return MaterialPageRoute(
      //     settings: RouteSettings(
      //       name: Routes.requestApprovalDetailsRoute,
      //       arguments: args,
      //     ),
      //     builder: (_) => RequestDetailsView(
      //       requestId: args['requestId'] ?? 0,
      //     ),
      //   );

      // // Order Details
      // case Routes.orderDetailsView:
      //   final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
      //   return MaterialPageRoute(
      //     settings: RouteSettings(
      //       name: Routes.orderDetailsView,
      //       arguments: args,
      //     ),
      //     builder: (_) => OrderDetailsView(
      //       orderId: args['orderId'],
      //       constantFieldshow: args['constantFieldshow'] ?? false,
      //       comeFrom: args['comeFrom'],
      //     ),
      //   );

      // Generic Detail
      case Routes.genericDetailRoute:
        final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          settings: RouteSettings(
            name: Routes.genericDetailRoute,
            arguments: args,
          ),
          builder: (_) => GenericDetailPage(
            title: args['title'] ?? '',
            data: args['data'],
          ),
        );

      // Show Group Approval List
      case Routes.showGroupApprovalListRoute:
        final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          settings: RouteSettings(
            name: Routes.showGroupApprovalListRoute,
            arguments: args,
          ),
          builder: (_) => ShowGroupApprovalList(
            id: args['id'],
            from: args['from'],
          ),
        );

      // Offline Blind Stock Details
      case Routes.offlineBlindStockDetailsRoute:
        final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          settings: RouteSettings(
            name: Routes.offlineBlindStockDetailsRoute,
            arguments: args,
          ),
          builder: (_) => OfflineBlindStockDetailsView(
            itemId: args['itemId'] as int,
          ),
        );
      case Routes.blindStockListing:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Routes.blindStockListing),
          builder: (_) => const BlindStockListView(),
        );
      case Routes.inventoryItemListRoute:
        return MaterialPageRoute(
          settings: const RouteSettings(name: Routes.inventoryItemListRoute),
          builder: (_) => const ItemListView(),
        );
      case Routes.inventoryItemDetailsRoute:
        final args = routeSettings.arguments as Map<String, dynamic>? ?? {};
        return MaterialPageRoute(
          settings: RouteSettings(
            name: Routes.inventoryItemDetailsRoute,
            arguments: args,
          ),
          builder: (_) => ItemDetailsView(
            itemId: args['itemId'],
            resultString: args['resultString'],
            entryType: args['entryType'] is EntryType
                ? args['entryType']
                : EntryType.values.firstWhere(
                    (e) =>
                        e.name == (args['entryType'] ?? EntryType.listing.name),
                    orElse: () => EntryType.listing,
                  ),
            scanFormat: args['scanFormat'],
          ),
        );

      case Routes.blindStockDetailsRoute:
        final args = routeSettings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
          settings: RouteSettings(
            name: Routes.blindStockDetailsRoute,
            arguments: args,
          ),
          builder: (_) => BlindStockDetailsView(
            itemId: args['itemId'],
            resultString: args['resultString'], // Will be null if not provided
            entryType: args['entryType'] is EntryType
                ? args['entryType']
                : EntryType.values.firstWhere(
                    (e) =>
                        e.name == (args['entryType'] ?? EntryType.listing.name),
                    orElse: () => EntryType.listing,
                  ),
            scanFormat: args['scanFormat'],
          ),
        );
      // ============ DEFAULT / UNDEFINED ROUTE ============
      default:
        return unDefinedRoute();
    }
  }

  static Route<dynamic> unDefinedRoute() {
    return MaterialPageRoute(
      settings: const RouteSettings(name: 'undefined'),
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: const Text(AppStrings.noRouteFound),
        ),
        body: const Center(
          child: Text(AppStrings.noRouteFound),
        ),
      ),
    );
  }
}
