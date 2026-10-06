import 'package:eyvo_v3/app/app_prefs.dart';
import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/routes_manager.dart';
import 'package:eyvo_v3/core/utils.dart';
import 'package:eyvo_v3/features/auth/view/screens/approval/order_approval_view.dart';
import 'package:eyvo_v3/features/auth/view/screens/approval/order_details_view.dart';
import 'package:eyvo_v3/features/auth/view/screens/approval/request_approval_view.dart';
import 'package:eyvo_v3/log_data.dart/logger_data.dart';
import 'package:flutter/material.dart';

class ApprovalView extends StatefulWidget {
  const ApprovalView({super.key});

  @override
  State<ApprovalView> createState() => _ApprovalViewState();
}

class _ApprovalViewState extends State<ApprovalView> {
  bool request = false;
  bool order = false;
  bool invoice = false;
  bool expense = false;

  @override
  void initState() {
    super.initState();
    // Load flags from SharedPrefs
    request = SharedPrefs().requestFlag;
    order = SharedPrefs().orderFlag;
    invoice = SharedPrefs().invoiceFlag;
    expense = SharedPrefs().expenseFlag;
    LoggerData.dataLog('request: $request');
    LoggerData.dataLog('order: $order');
    LoggerData.dataLog('invoice: $invoice');
    LoggerData.dataLog('expense: $expense');
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final yellowHeight = screenHeight * 0.32;

    // Dynamically generate cards
    List<Widget> cards = [];
    if (request) {
      cards.add(_buildCard(
        titleLine1: "Request",
        titleLine2: "Approval",
        imageAsset: ImageAssets.requestApproval,
        backgroundColor: ColorManager.white,
        onTap: () => navigateToScreen(context, const RequestApprovalPage()),
      ));
    }
    if (order) {
      cards.add(_buildCard(
        titleLine1: "Order",
        titleLine2: "Approval",
        imageAsset: ImageAssets.orderCostCentre,
        backgroundColor: ColorManager.white,
        onTap: () {
          navigateToScreen(context, const OrderApproverPage());
        },
      ));
    }
    if (expense) {
      cards.add(_buildCard(
        titleLine1: "Expense",
        titleLine2: "Approval",
        imageAsset: ImageAssets.expense,
        backgroundColor: ColorManager.white,
        onTap: () => navigateToScreen(context, const RequestApprovalPage()),
      ));
    }
    if (invoice) {
      cards.add(_buildCard(
        titleLine1: "Invoice",
        titleLine2: "Approval",
        imageAsset: ImageAssets.invoiceApproval,
        backgroundColor: ColorManager.white,
        onTap: () => navigateToScreen(context, const RequestApprovalPage()),
      ));
    }

    // Convert cards into 2x2 grid
    List<Widget> rows = [];
    for (int i = 0; i < cards.length; i += 2) {
      rows.add(
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              Expanded(child: cards[i]),
              const SizedBox(width: 16),
              if (i + 1 < cards.length)
                Expanded(child: cards[i + 1])
              else
                const Spacer(),
            ],
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        Navigator.pushReplacementNamed(context, Routes.homeRoute);
        return false;
      },
      child: Scaffold(
        backgroundColor: ColorManager.primary,
        appBar: AppBar(
          backgroundColor: ColorManager.yellow,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.pushReplacementNamed(context, Routes.homeRoute);
            },
          ),
        ),
        body: Stack(
          children: [
            // Yellow Header
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: yellowHeight,
              child: Container(
                color: ColorManager.yellow,
                child: Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Transform.translate(
                        offset: const Offset(0, -30),
                        child: Column(
                          children: [
                            Image.asset(
                              ImageAssets.selectApproval,
                              height: 120,
                              width: 120,
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              "Select Approval",
                              style: TextStyle(
                                fontSize: FontSize.s25_5,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Cards Section
            Positioned.fill(
              top: yellowHeight - 80,
              child: Transform.translate(
                offset: const Offset(0, -20),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      ...rows,
                      const SizedBox(height: 20),
                      if (cards.isEmpty)
                        const Padding(
                          padding: EdgeInsets.only(top: 60.0),
                          child: Text(
                            "No approval items available.",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: FontSize.s16,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard({
    required String titleLine1,
    required String titleLine2,
    required String imageAsset,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 4,
      color: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: SizedBox(
          height: 160,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(imageAsset, height: 60, width: 60),
                const SizedBox(height: 10.0),
                Text(
                  titleLine1,
                  style: const TextStyle(
                    fontSize: FontSize.s20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                Text(
                  titleLine2,
                  style: const TextStyle(
                    fontSize: FontSize.s20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
