// // ignore_for_file: use_build_context_synchronously

// import 'dart:developer';

// import 'package:eyvo_v3/api/api_service/api_service.dart';
// import 'package:eyvo_v3/api/api_service/bloc.dart';
// import 'package:eyvo_v3/api/response_models/company_code_response.dart';
// import 'package:eyvo_v3/app/app_prefs.dart';
// import 'package:eyvo_v3/app/sizes_helper.dart';
// import 'package:eyvo_v3/core/resources/assets_manager.dart';
// import 'package:eyvo_v3/core/resources/font_manager.dart';
// import 'package:eyvo_v3/core/resources/routes_manager.dart';
// import 'package:eyvo_v3/core/resources/styles_manager.dart';
// import 'package:eyvo_v3/core/widgets/button.dart';
// import 'package:eyvo_v3/core/widgets/custom_field.dart';
// import 'package:eyvo_v3/core/widgets/header_logo.dart';
// import 'package:eyvo_v3/core/widgets/progress_indicator.dart';
// import 'package:eyvo_v3/core/widgets/text_error.dart';
// import 'package:flutter/material.dart';
// import 'package:eyvo_v3/core/resources/color_manager.dart';
// import 'package:eyvo_v3/core/resources/strings_manager.dart';
// import 'package:flutter/services.dart';

// class CompanyCodeView extends StatefulWidget {
//   const CompanyCodeView({super.key});

//   @override
//   State<CompanyCodeView> createState() => _CompanyCodeViewState();
// }

// class _CompanyCodeViewState extends State<CompanyCodeView> {
//   final codeController = TextEditingController();
//   bool isFormValidated = false;
//   bool isError = false;
//   bool isLoading = false;
//   String codeText = AppStrings.enterCompanyCode;
//   String errorText = AppStrings.companyCodeCannotBeBlank;
//   final ApiService apiService = ApiService();

//   @override
//   void initState() {
//     super.initState();
//     codeController.addListener(_onTextChange);
//     codeController.text = SharedPrefs().companyCode;
//   }

//   @override
//   void dispose() {
//     codeController.dispose();
//     super.dispose();
//   }

//   void _onTextChange() {
//     if (codeText != AppStrings.enterCompanyCode) {
//       setState(() {
//         isError = codeController.text.trim().isEmpty;
//       });
//     }
//     codeText = codeController.text.trim();
//   }

//   void validateFields() {
//     if (isFormValidated) {
//       setState(() {
//         isError = codeController.text.isEmpty;
//       });
//     }
//   }

//   // void validateCompanyCode() async {
//   //   setState(() {
//   //     isLoading = true;
//   //   });

//   //   final clientCode = codeController.text.trim();
//   //   Map<String, dynamic> data = {'clientcode': clientCode};
//   //   final jsonResponse =
//   //       await apiService.postRequest(context, ApiService.clientCode, data);
//   //   if (jsonResponse != null) {
//   //     final response = CompanyCodeResponse.fromJson(jsonResponse);

//   //     if (response.code == '200') {
//   //       SharedPrefs().companyCode = response.data.clientCode;
//   //       SharedPrefs().accessKey = response.data.accessKey;
//   //       codeController.text = '';
//   //       Navigator.pushNamed(context, Routes.loginRoute);
//   //     } else {
//   //       isError = true;
//   //       errorText = response.message.join(', ');
//   //     }
//   //   }

//   //   // var res = await globalBloc.afterFillCompanyCodeApi(context, clientCode);
//   //   // if (res.code == '200') {
//   //   //   SharedPrefs().companyCode = res.data.clientCode;
//   //   //   SharedPrefs().accessKey = res.data.accessKey;
//   //   //   codeController.text = '';
//   //   //   Navigator.pushNamed(context, Routes.loginRoute);
//   //   // } else {
//   //   //   isError = true;
//   //   //   errorText = res.message.join(', ');
//   //   // }

//   //   setState(() {
//   //     isLoading = false;
//   //   });
//   // }
//   // void validateCompanyCode() async {
//   //   setState(() {
//   //     isLoading = true;
//   //     isError = false; // Reset error state before validation
//   //   });

//   //   final clientCode = codeController.text.trim();
//   //   Map<String, dynamic> data = {'clientcode': clientCode};
//   //   final jsonResponse =
//   //       await apiService.postRequest(context, ApiService.clientCode, data);

//   //   if (jsonResponse != null) {
//   //     final response = CompanyCodeResponse.fromJson(jsonResponse);

//   //     if (response.code == '200') {
//   //       SharedPrefs().companyCode = response.data.clientCode;
//   //       SharedPrefs().accessKey = response.data.accessKey;
//   //       // Navigate without rebuilding the widget to avoid showing error
//   //       Navigator.pushNamed(context, Routes.loginRoute).then((_) {
//   //         codeController.clear();
//   //       });
//   //     } else {
//   //       setState(() {
//   //         isError = true;
//   //         errorText = response.message.join(', ');
//   //       });
//   //     }
//   //   }

//   //   setState(() {
//   //     isLoading = false;
//   //   });
//   // }
//   void validateCompanyCode() async {
//     setState(() {
//       isLoading = true;
//       isError = false; // Reset error state
//     });

//     final clientCode = codeController.text.trim();
//     Map<String, dynamic> data = {'clientcode': clientCode};

//     final jsonResponse =
//         await apiService.postRequest(context, ApiService.clientCode, data);

//     if (jsonResponse != null) {
//       final response = CompanyCodeResponse.fromJson(jsonResponse);

//       if (response.code == '200') {
//         SharedPrefs().companyCode = response.data.clientCode;
//         SharedPrefs().accessKey = response.data.accessKey;

//         Navigator.pushNamed(context, Routes.loginRoute).then((_) {
//           codeController.clear();
//         });
//       } else if (response.code == '401') {
//         // Handle unauthorized / invalid company code
//         setState(() {
//           isError = true;
//           errorText = response.message.join(', ');
//         });
//       } else {
//         setState(() {
//           isError = true;
//           errorText = response.message.join(', ');
//         });
//       }
//     }

//     setState(() {
//       isLoading = false;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return AnnotatedRegion(
//       value: SystemUiOverlayStyle.dark,
//       child: PopScope(
//         canPop: false,
//         onPopInvokedWithResult: (didPop, result) => {SystemNavigator.pop()},
//         child: GestureDetector(
//           onTap: () {
//             FocusScope.of(context).unfocus();
//           },
//           // child: Scaffold(
//           //     backgroundColor: ColorManager.white,
//           //     body: SingleChildScrollView(
//           //       padding: EdgeInsets.only(
//           //           bottom: MediaQuery.of(context).viewInsets.bottom),
//           //       child: Column(
//           //         children: [
//           //           const HeaderLogo(),
//           //           Padding(
//           //             padding: const EdgeInsets.only(left: 30, right: 30),
//           //             child: Column(
//           //               mainAxisAlignment: MainAxisAlignment.start,
//           //               children: [
//           //                 Padding(
//           //                   padding: const EdgeInsets.only(top: 50),
//           //                   child: Text(AppStrings.companyCodeTitle,
//           //                       style: getRegularStyle(
//           //                           color: ColorManager.black,
//           //                           fontSize: FontSize.s22_5)),
//           //                 ),
//           //                 const SizedBox(height: 50),
//           //                 SizedBox(
//           //                   width: displayWidth(context),
//           //                   child: CustomTextField(
//           //                       iconString: ImageAssets.companyCodeIcon,
//           //                       hintText: AppStrings.enterCompanyCode,
//           //                       controller: codeController,
//           //                       isValid: !isError,
//           //                       onTextChanged: validateFields),
//           //                 ),
//           //                 isError
//           //                     ? ErrorTextViewBox(titleString: errorText)
//           //                     : const SizedBox(height: 50),
//           //                 isError
//           //                     ? const SizedBox(height: 20)
//           //                     : const SizedBox(),
//           //                 isLoading
//           //                     ? const CustomProgressIndicator()
//           //                     : CustomButton(
//           //                         buttonText: AppStrings.submit,
//           //                         // onTap: () {
//           //                         //   isFormValidated = true;
//           //                         //   validateFields();
//           //                         //   if (!isError) {
//           //                         //     validateCompanyCode();
//           //                         //   } else {
//           //                         //     setState(() {
//           //                         //       isError = true;
//           //                         //     });
//           //                         //   }
//           //                         // },
//           //                         onTap: () {
//           //                           isFormValidated = true;
//           //                           validateFields();
//           //                           if (!isError &&
//           //                               codeController.text.trim().isNotEmpty) {
//           //                             validateCompanyCode();
//           //                           } else {
//           //                             setState(() {
//           //                               isError =
//           //                                   codeController.text.trim().isEmpty;
//           //                               errorText =
//           //                                   AppStrings.companyCodeCannotBeBlank;
//           //                             });
//           //                           }
//           //                         },
//           //                       )
//           //               ],
//           //             ),
//           //           ),
//           //         ],
//           //       ),
//           //     )),

//           child: Scaffold(
//             backgroundColor: ColorManager.white,
//             body: isError &&
//                     errorText.isNotEmpty &&
//                     errorText != AppStrings.companyCodeCannotBeBlank
//                 ? Center(
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       crossAxisAlignment: CrossAxisAlignment.center,
//                       children: [
//                         const Spacer(),
//                         Image.asset(
//                           width: displayWidth(context) * 0.5,
//                           ImageAssets.errorMessageIcon,
//                         ),
//                         Padding(
//                           padding: const EdgeInsets.symmetric(
//                               horizontal: 30, vertical: 20),
//                           child: Text(
//                             errorText,
//                             textAlign: TextAlign.center,
//                             style: getRegularStyle(
//                               color: ColorManager.lightGrey,
//                               fontSize: FontSize.s17,
//                             ),
//                           ),
//                         ),
//                         const Spacer(),
//                       ],
//                     ),
//                   )
//                 : SingleChildScrollView(
//                     padding: EdgeInsets.only(
//                         bottom: MediaQuery.of(context).viewInsets.bottom),
//                     child: Column(
//                       children: [
//                         const HeaderLogo(),
//                         Padding(
//                           padding: const EdgeInsets.only(left: 30, right: 30),
//                           child: Column(
//                             mainAxisAlignment: MainAxisAlignment.start,
//                             children: [
//                               Padding(
//                                 padding: const EdgeInsets.only(top: 50),
//                                 child: Text(
//                                   AppStrings.companyCodeTitle,
//                                   style: getRegularStyle(
//                                       color: ColorManager.black,
//                                       fontSize: FontSize.s22_5),
//                                 ),
//                               ),
//                               const SizedBox(height: 50),
//                               SizedBox(
//                                 width: displayWidth(context),
//                                 child: CustomTextField(
//                                   iconString: ImageAssets.companyCodeIcon,
//                                   hintText: AppStrings.enterCompanyCode,
//                                   controller: codeController,
//                                   isValid: !isError,
//                                   onTextChanged: validateFields,
//                                 ),
//                               ),
//                               isError &&
//                                       errorText ==
//                                           AppStrings.companyCodeCannotBeBlank
//                                   ? ErrorTextViewBox(titleString: errorText)
//                                   : const SizedBox(height: 50),
//                               isLoading
//                                   ? const CustomProgressIndicator()
//                                   : CustomButton(
//                                       buttonText: AppStrings.submit,
//                                       onTap: () {
//                                         isFormValidated = true;
//                                         validateFields();
//                                         if (!isError &&
//                                             codeController.text
//                                                 .trim()
//                                                 .isNotEmpty) {
//                                           validateCompanyCode();
//                                         } else {
//                                           setState(() {
//                                             isError = codeController.text
//                                                 .trim()
//                                                 .isEmpty;
//                                             errorText = AppStrings
//                                                 .companyCodeCannotBeBlank;
//                                           });
//                                         }
//                                       },
//                                     ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//           ),
//         ),
//       ),
//     );
//   }
// }

// ignore_for_file: use_build_context_synchronously

import 'dart:developer';
import 'package:eyvo_v3/api/api_service/api_service.dart';
import 'package:eyvo_v3/api/response_models/company_code_response.dart';
import 'package:eyvo_v3/app/app_prefs.dart';
import 'package:eyvo_v3/app/sizes_helper.dart';
import 'package:eyvo_v3/core/resources/assets_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/routes_manager.dart';
import 'package:eyvo_v3/core/resources/styles_manager.dart';
import 'package:eyvo_v3/core/widgets/button.dart';
import 'package:eyvo_v3/core/widgets/custom_field.dart';
import 'package:eyvo_v3/core/widgets/header_logo.dart';
import 'package:eyvo_v3/core/widgets/progress_indicator.dart';
import 'package:eyvo_v3/core/widgets/text_error.dart';
import 'package:flutter/material.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/strings_manager.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher.dart';

class CompanyCodeView extends StatefulWidget {
  const CompanyCodeView({super.key});

  @override
  State<CompanyCodeView> createState() => _CompanyCodeViewState();
}

class _CompanyCodeViewState extends State<CompanyCodeView> {
  final codeController = TextEditingController();
  bool isFormValidated = false;
  bool isError = false;
  bool isLoading = false;
  bool showErrorScreen = false;
  String codeText = AppStrings.enterCompanyCode;
  String errorText = AppStrings.companyCodeCannotBeBlank;
  final ApiService apiService = ApiService();

  @override
  void initState() {
    super.initState();
    codeController.addListener(_onTextChange);
    codeController.text = SharedPrefs().companyCode;
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  void _onTextChange() {
    if (codeText != AppStrings.enterCompanyCode) {
      setState(() {
        isError = codeController.text.trim().isEmpty;
      });
    }
    codeText = codeController.text.trim();
  }

  void validateFields() {
    if (isFormValidated) {
      setState(() {
        isError = codeController.text.isEmpty;
      });
    }
  }

  Future<void> _onOpenLink(LinkableElement link) async {
    final url = link.url;

    // Handle email links
    if (url.startsWith('mailto:')) {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        // Fallback
        await launchUrl(Uri.parse('mailto:${url.replaceFirst('mailto:', '')}'));
      }
    } else {
      // Handle normal http/https links
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
  }

  void validateCompanyCode() async {
    setState(() {
      isLoading = true;
      isError = false;
      showErrorScreen = false;
    });

    final clientCode = codeController.text.trim();
    Map<String, dynamic> data = {'clientcode': clientCode};

    final jsonResponse =
        await apiService.postRequest(context, ApiService.clientCode, data);

    if (jsonResponse != null) {
      final response = CompanyCodeResponse.fromJson(jsonResponse);

      if (response.code == '200') {
        SharedPrefs().companyCode = response.data.clientCode;
        SharedPrefs().accessKey = response.data.accessKey;

        Navigator.pushNamed(context, Routes.loginRoute).then((_) {
          codeController.clear();
        });
      } else if (response.code == '401') {
        //  Clean HTML tags
        String cleanedMessage = response.message
            .join(', ')
            .replaceAll(RegExp(r"<[^>]*>"), '')
            .replaceAll("mailto:", ""); // remove mailto part

        setState(() {
          showErrorScreen = true;
          errorText = cleanedMessage.trim();
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
    return AnnotatedRegion(
      value: SystemUiOverlayStyle.dark,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, result) => {SystemNavigator.pop()},
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Scaffold(
            backgroundColor: ColorManager.white,
            body: showErrorScreen
                // === 401 ERROR SCREEN ===
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Spacer(),
                        Image.asset(
                          ImageAssets.errorMessageIcon,
                          width: displayWidth(context) * 0.5,
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 30, vertical: 20),
                          child: Linkify(
                            onOpen: _onOpenLink,
                            text: errorText,
                            textAlign: TextAlign.center,
                            style: getRegularStyle(
                              color: ColorManager.lightGrey,
                              fontSize: FontSize.s17,
                            ),
                            linkStyle: const TextStyle(
                              color: Colors.blue,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),
                        const Spacer(),
                        SizedBox(
                          width: displayWidth(context) * 0.95,
                          child: CustomButton(
                            buttonText: "Back",
                            onTap: () {
                              setState(() {
                                showErrorScreen = false;
                                isError = false;
                                errorText = AppStrings.enterCompanyCode;
                              });
                            },
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  )

                // === NORMAL FORM ===
                : SingleChildScrollView(
                    padding: EdgeInsets.only(
                        bottom: MediaQuery.of(context).viewInsets.bottom),
                    child: Column(
                      children: [
                        const HeaderLogo(),
                        Padding(
                          padding: const EdgeInsets.only(left: 30, right: 30),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 50),
                                child: Text(
                                  AppStrings.companyCodeTitle,
                                  style: getRegularStyle(
                                      color: ColorManager.black,
                                      fontSize: FontSize.s22_5),
                                ),
                              ),
                              const SizedBox(height: 50),
                              SizedBox(
                                width: displayWidth(context),
                                child: CustomTextField(
                                  iconString: ImageAssets.companyCodeIcon,
                                  hintText: AppStrings.enterCompanyCode,
                                  controller: codeController,
                                  isValid: !isError,
                                  onTextChanged: validateFields,
                                ),
                              ),
                              isError
                                  ? ErrorTextViewBox(titleString: errorText)
                                  : const SizedBox(height: 50),
                              isLoading
                                  ? const CustomProgressIndicator()
                                  : CustomButton(
                                      buttonText: AppStrings.submit,
                                      onTap: () {
                                        isFormValidated = true;
                                        validateFields();
                                        if (!isError &&
                                            codeController.text
                                                .trim()
                                                .isNotEmpty) {
                                          validateCompanyCode();
                                        } else {
                                          setState(() {
                                            isError = codeController.text
                                                .trim()
                                                .isEmpty;
                                            errorText = AppStrings
                                                .companyCodeCannotBeBlank;
                                          });
                                        }
                                      },
                                    ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
