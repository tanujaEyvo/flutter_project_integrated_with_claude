import 'package:eyvo_v3/core/resources/strings_manager.dart';
import 'package:eyvo_v3/core/utils.dart';
import 'package:eyvo_v3/core/widgets/approval_details_helper.dart';
import 'package:eyvo_v3/core/widgets/button.dart';
import 'package:eyvo_v3/core/widgets/progress_indicator.dart';
import 'package:eyvo_v3/features/auth/view/screens/approval/create_order_item_view.dart';
import 'package:eyvo_v3/features/auth/view/screens/approval/create_order_header_view.dart';
import 'package:eyvo_v3/features/auth/view/screens/approval/file_upload.dart';
import 'package:eyvo_v3/features/auth/view/screens/approval/note_view.dart';
import 'package:flutter/material.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/styles_manager.dart';
import 'package:eyvo_v3/core/widgets/common_app_bar.dart';

import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class CreateOrderDetailsPage extends StatefulWidget {
  const CreateOrderDetailsPage({Key? key}) : super(key: key);

  @override
  State<CreateOrderDetailsPage> createState() => _CreateOrderDetailsPageState();
}

class _CreateOrderDetailsPageState extends State<CreateOrderDetailsPage> {
  String? expandedSection;
  bool isLoading = false, isError = false;
  String errorText = AppStrings.somethingWentWrong;

  @override
  void initState() {
    super.initState();
    expandedSection = "Details"; // default expanded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildCommonAppBar(
        context: context,
        title: "Create Order",
      ),
      backgroundColor: ColorManager.primary,
      body: isLoading
          ? const Center(child: CustomProgressIndicator())
          : isError
              ? Center(child: Text(errorText))
              : Column(
                  children: [
                    // Scrollable sections
                    Expanded(
                      child: ScrollbarTheme(
                        data: ScrollbarThemeData(
                          thumbColor:
                              MaterialStateProperty.all(ColorManager.darkBlue),
                          radius: const Radius.circular(8),
                          thickness: MaterialStateProperty.all(6),
                        ),
                        child: Scrollbar(
                          thumbVisibility: true,
                          thickness: 6,
                          radius: const Radius.circular(8),
                          child: SingleChildScrollView(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: Column(
                              children: [
                                //-------------------- Details Section --------------------
                                ApprovalDetailsHelper.buildSection(
                                  "Details",
                                  Icons.description_outlined,
                                  [
                                    ApprovalDetailsHelper.buildMiniCard({
                                      'Order Number': '1234',
                                      'Order Date': '23/6/2025',
                                      'Order Status': 'pending',
                                      'Supplier Name': 'Tanuja',
                                      'Order Total': '',
                                      'Rule Approval': 'Pending',
                                      'Cost Center Approver': 'Pending',
                                      'Group Approver': 'Pending',
                                    }),
                                    buildAddCard("Add Order Details", () {
                                      navigateToScreen(
                                        context,
                                        const CreateOrderHeaderView(
                                            orderId: 1434),
                                      );
                                    }),
                                  ],
                                  isExpanded: expandedSection == "Details",
                                  toggleSection: () {
                                    setState(() {
                                      expandedSection =
                                          expandedSection == "Details"
                                              ? null
                                              : "Details";
                                    });
                                  },
                                ),

                                //-------------------- Line Items Section --------------------
                                ApprovalDetailsHelper.buildSection(
                                  "Line Items",
                                  Icons.list_alt_outlined,
                                  [
                                    buildAddCard("Add Line Item", () {
                                      navigateToScreen(
                                        context,
                                        const CreateOrderLineView(),
                                      );
                                    }),
                                  ],
                                  isExpanded: expandedSection == "Line Items",
                                  toggleSection: () {
                                    setState(() {
                                      expandedSection =
                                          expandedSection == "Line Items"
                                              ? null
                                              : "Line Items";
                                    });
                                  },
                                ),

                                //-------------------- Rules Section --------------------
                                ApprovalDetailsHelper.buildSection(
                                  "Rules",
                                  Icons.rule,
                                  [
                                    buildAddCard("Add Rule", () {
                                      print("Add Rule tapped");
                                    }),
                                  ],
                                  isExpanded: expandedSection == "Rules",
                                  toggleSection: () {
                                    setState(() {
                                      expandedSection =
                                          expandedSection == "Rules"
                                              ? null
                                              : "Rules";
                                    });
                                  },
                                ),

                                //-------------------- Cost Center Split Section --------------------
                                ApprovalDetailsHelper.buildSection(
                                  "Cost Center Split",
                                  Icons.share,
                                  [
                                    buildAddCard("Add Cost Center", () {
                                      print("Add Cost Center tapped");
                                    }),
                                  ],
                                  isExpanded: expandedSection == "Cost Center",
                                  toggleSection: () {
                                    setState(() {
                                      expandedSection =
                                          expandedSection == "Cost Center"
                                              ? null
                                              : "Cost Center";
                                    });
                                  },
                                ),

                                //-------------------- Cost Center Approvers Section --------------------
                                ApprovalDetailsHelper.buildSection(
                                  "Cost Center Approvers",
                                  FontAwesomeIcons.userCheck,
                                  [
                                    buildAddCard("Add Cost Approvers", () {
                                      print("Add Cost Center Approvers tapped");
                                    }),
                                  ],
                                  isExpanded: expandedSection ==
                                      "Cost Center Approvers",
                                  toggleSection: () {
                                    setState(() {
                                      expandedSection = expandedSection ==
                                              "Cost Center Approvers"
                                          ? null
                                          : "Cost Center Approvers";
                                    });
                                  },
                                ),

                                //-------------------- Attachments Section --------------------
                                ApprovalDetailsHelper.buildSection(
                                  "Attached Documents",
                                  Icons.attach_file,
                                  [
                                    buildAddCard("Add Attached Documents", () {
                                      navigateToScreen(
                                        context,
                                        const FileUploadPage(),
                                      );
                                    }),
                                  ],
                                  isExpanded:
                                      expandedSection == "Attached Documents",
                                  toggleSection: () {
                                    setState(() {
                                      expandedSection = expandedSection ==
                                              "Attached Documents"
                                          ? null
                                          : "Attached Documents";
                                    });
                                  },
                                ),

                                //-------------------- Terms & Conditions Section --------------------
                                ApprovalDetailsHelper.buildSection(
                                  "Terms & Conditions",
                                  Icons.list_alt_outlined,
                                  [
                                    buildAddCard(
                                        "Add Terms & Conditions", () {}),
                                  ],
                                  isExpanded:
                                      expandedSection == "Terms & Conditions",
                                  toggleSection: () {
                                    setState(() {
                                      expandedSection = expandedSection ==
                                              "Terms & Conditions"
                                          ? null
                                          : "Terms & Conditions";
                                    });
                                  },
                                ),

                                //-------------------- Notes Section --------------------
                                ApprovalDetailsHelper.buildSection(
                                  "Notes",
                                  Icons.note_add,
                                  [
                                    buildAddCard("Add Notes", () {
                                      navigateToScreen(
                                        context,
                                        NotesView(),
                                      );
                                    }),
                                  ],
                                  isExpanded: expandedSection == "Notes",
                                  toggleSection: () {
                                    setState(() {
                                      expandedSection =
                                          expandedSection == "Notes"
                                              ? null
                                              : "Notes";
                                    });
                                  },
                                ),

                                //-------------------- Event Log Section --------------------
                                ApprovalDetailsHelper.buildSection(
                                  "Event Log",
                                  Icons.history,
                                  [
                                    buildAddCard("Add Event Log", () {}),
                                  ],
                                  isExpanded: expandedSection == "Event Log",
                                  toggleSection: () {
                                    setState(() {
                                      expandedSection =
                                          expandedSection == "Event Log"
                                              ? null
                                              : "Event Log";
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    //-------------------- Save Button --------------------
                    Container(
                      color: ColorManager.white,
                      padding: const EdgeInsets.all(16),
                      width: double.infinity,
                      child: CustomButton(
                        buttonText: 'Create Order',
                        onTap: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Order Header Saved Successfully!"),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  //-------------------- Helper Widget for Add Card --------------------
  Widget buildAddCard(String text, VoidCallback onTap) {
    return Card(
      color: ColorManager.white,
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.add, color: ColorManager.blue),
              const SizedBox(width: 8),
              Text(
                text,
                style: TextStyle(
                  color: ColorManager.blue,
                  fontWeight: FontWeight.bold,
                  fontSize: FontSize.s16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
