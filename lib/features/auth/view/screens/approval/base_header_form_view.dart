import 'package:eyvo_v3/api/api_service/api_service.dart';
import 'package:eyvo_v3/api/response_models/order_header_response.dart';
import 'package:eyvo_v3/app/app_prefs.dart';
import 'package:eyvo_v3/core/resources/constants.dart';
import 'package:eyvo_v3/core/resources/strings_manager.dart';
import 'package:eyvo_v3/core/widgets/button.dart';
import 'package:eyvo_v3/core/widgets/form_field_helper.dart';
import 'package:eyvo_v3/core/widgets/searchable_dropdown_modal.dart';
import 'package:eyvo_v3/log_data.dart/logger_data.dart';
import 'package:flutter/material.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/styles_manager.dart';
import 'package:eyvo_v3/core/widgets/common_app_bar.dart';

class BaseHeaderView extends StatefulWidget {
  final int id;
  final HeaderType headerType;
  final String appBarTitle;

  const BaseHeaderView({
    Key? key,
    required this.id,
    required this.headerType,
    required this.appBarTitle,
  }) : super(key: key);

  @override
  State<BaseHeaderView> createState() => _BaseHeaderViewState();
}

enum HeaderType {
  order,
  request,
}

class _BaseHeaderViewState extends State<BaseHeaderView> {
  // Text Controllers
  final TextEditingController _refNoController = TextEditingController();
  final TextEditingController _deliverToController = TextEditingController();
  final TextEditingController _deliverIncoterms = TextEditingController();
  final TextEditingController _instructionsController = TextEditingController();
  final TextEditingController _shipViaController = TextEditingController();
  final TextEditingController _justificationController =
      TextEditingController();
  final TextEditingController _paymentTermsController = TextEditingController();
  final TextEditingController _requestDescriptionController =
      TextEditingController();
  final TextEditingController _requestBudgetController =
      TextEditingController();

  final ApiService apiService = ApiService();
  bool isError = false;
  String errorText = AppStrings.somethingWentWrong;
  CreateHeaderResponse? apiResponse;
  bool isLoading = true;
  List<Datum>? headerData;
  Map<String, bool> fieldVisible = {};
  Map<String, bool> fieldRequired = {};
  Map<String, bool> fieldReadOnly = {};
  Map<String, String> fieldLabels = {};

  // Dropdown Id
  String? _selectedSupplierCodeId;
  String? _selectedDeliveryCodeId;
  String? _selectedBudgetId;
  String? _selectedContactNumberId;
  String? _selectedRestaurentId;
  String? _selectedAccountId;
  String? _selectedInvoiceCodeId;
  String? _selectedDocumentTypeId;
  String? _selectedCategoryCodeId;
  String? _selectedCustomerId;
  String? _selectedSupplierContactId;
  String? _selectedContractNumberId;
  String? _selectDepartmentCodeId;

  // Dropdown Value
  String? _selectedSupplierCodeValue;
  String? _selectedDeliveryCodeValue;
  String? _selectedBudgetValue;
  String? _selectedContactNumberValue;
  String? _selectedRestaurentValue;
  String? _selectedAccountValue;
  String? _selectedInvoiceCodeValue;
  String? _selectedDocumentTypeValue;
  String? _selectedCategoryCodeValue;
  String? _selectedCustomerValue;
  String? _selectedSupplierContactValue;
  String? _selectedContractNumberValue;
  String? _selectDepartmentCodeValue;

  @override
  void initState() {
    super.initState();
    fetchHeader();
  }

  // Dropdown Data - These can be replaced with API calls
  List<DropdownItem> getBudget() {
    return [
      DropdownItem(id: "In Budget", value: "In Budget"),
      DropdownItem(id: "Out Budget", value: "Out Budget"),
      DropdownItem(id: "Over Budget", value: "Over Budget"),
    ];
  }

  List<DropdownItem> getSupplierCodes() {
    return [
      DropdownItem(id: "1", value: "Supplier 1"),
      DropdownItem(id: "2", value: "Supplier 2"),
      DropdownItem(id: "3", value: "Supplier 3"),
      DropdownItem(id: "236", value: "MFAX2"),
    ];
  }

  List<DropdownItem> getDeliveryCodes() {
    return [
      DropdownItem(id: "1", value: "D001"),
      DropdownItem(id: "2", value: "D002"),
      DropdownItem(id: "3", value: "D003"),
      DropdownItem(id: "4", value: "D004"),
      DropdownItem(id: "5", value: "D005"),
    ];
  }

  String _getGroupName() {
    return widget.headerType == HeaderType.order ? 'Order' : 'Request';
  }

  String _getHeaderPrefix() {
    return widget.headerType == HeaderType.order ? 'Order' : 'Request';
  }

  Future<void> fetchHeader() async {
    setState(() {
      isLoading = true;
      isError = false;
    });

    try {
      final jsonResponse = await apiService.postRequest(
        context,
        ApiService.createOrderHeader,
        {
          'uid': SharedPrefs().uID,
          'ID': widget.id,
          'LineID': 0,
          'group': _getGroupName(),
          'section': 'Header',
          'apptype':AppConstants.apptype,
        },
      );

      if (jsonResponse == null) {
        setState(() {
          isError = true;
          errorText = "No response from server";
          isLoading = false;
        });
        return;
      }

      final resp = CreateHeaderResponse.fromJson(jsonResponse);

      if (resp.code == 200 && resp.data != null) {
        setState(() {
          apiResponse = resp;
          headerData = resp.data;
          isLoading = false;

          // Reset old data
          fieldVisible.clear();
          fieldRequired.clear();
          fieldReadOnly.clear();

          // Parse each field dynamically
          for (var field in resp.data!) {
            // Store field-level properties
            fieldVisible[field.fieldId] = field.visible;
            fieldRequired[field.fieldId] = field.required;
            fieldReadOnly[field.fieldId] = !field.readWrite;
            fieldLabels[field.fieldId] = field.labelName;

            // Assign values and handle visibility
            _assignFieldValue(field);
          }
        });
      } else {
        setState(() {
          isError = true;
          errorText = resp.message?.join(', ') ?? "Failed to fetch data";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isError = true;
        errorText = "Something went wrong: $e";
        isLoading = false;
      });
    }
  }

  void _assignFieldValue(Datum field) {
    if (field.visible && field.value.isNotEmpty) {
      switch (field.fieldId) {
        case "ExpCode1_ID":
          _selectedAccountId = field.id.toString();
          _selectedAccountValue = field.value;
          break;
        case "ExpCode2_ID":
          _selectedRestaurentId = field.id.toString();
          _selectedRestaurentValue = field.value;
          break;
        case "ExpCode3_ID":
          _selectDepartmentCodeId = field.id.toString();
          _selectDepartmentCodeValue = field.value;
          break;
        case "InvoicePtID":
          _selectedInvoiceCodeId = field.id.toString();
          _selectedInvoiceCodeValue = field.value;
          break;
        case "OrderTypeID":
          _selectedDocumentTypeId = field.id.toString();
          _selectedDocumentTypeValue = field.value;
          break;
        case "ReferenceNo":
          _refNoController.text = field.value;
          break;
        case "DeliveryID":
          _selectedDeliveryCodeId = field.id.toString();
          _selectedDeliveryCodeValue = field.value;
          break;
        case "Instructions":
          _instructionsController.text = field.value;
          break;
        case "CategoryID":
          _selectedCategoryCodeId = field.id.toString();
          _selectedCategoryCodeValue = field.value;
          break;
        case "Cust_ID":
          _selectedCustomerId = field.id.toString();
          _selectedCustomerValue = field.value;
          break;
        case "FOB":
          _deliverIncoterms.text = field.value;
          break;
        case "Ship_Via":
          _shipViaController.text = field.value;
          break;
        case "Justification":
          _justificationController.text = field.value;
          break;
        case "Order_Budget_Header":
          _selectedBudgetId = field.id.toString();
          _selectedBudgetValue = field.value;
          break;
        case "FAO":
          _deliverToController.text = field.value;
          break;
        case "Payment_Terms":
          _paymentTermsController.text = field.value;
          break;
        case "Supp_Cont_ID":
          _selectedSupplierContactId = field.id.toString();
          _selectedSupplierContactValue = field.value;
          break;
        case "ContractID":
          _selectedContractNumberId = field.id.toString();
          _selectedContractNumberValue = field.value;
          break;
        case "SupplierID":
          _selectedSupplierCodeId = field.id.toString();
          _selectedSupplierCodeValue = field.value;
          break;
      }
    } else if (field.visible) {
      // Handle text fields without values
      switch (field.fieldId) {
        case "ReferenceNo":
          _refNoController.text = field.value;
          break;
        case "Instructions":
          _instructionsController.text = field.value;
          break;
        case "FOB":
          _deliverIncoterms.text = field.value;
          break;
        case "Ship_Via":
          _shipViaController.text = field.value;
          break;
        case "Justification":
          _justificationController.text = field.value;
          break;
        case "FAO":
          _deliverToController.text = field.value;
          break;
        case "Payment_Terms":
          _paymentTermsController.text = field.value;
          break;
      }
    }
  }

  @override
  void dispose() {
    _refNoController.dispose();
    _deliverToController.dispose();
    _deliverIncoterms.dispose();
    _instructionsController.dispose();
    _shipViaController.dispose();
    _justificationController.dispose();
    _paymentTermsController.dispose();
    super.dispose();
  }

  void _saveForm() {
    // Prepare data for API
    Map<String, dynamic> formData = {
      'ReferenceNo': _refNoController.text,
      'SupplierCode': _selectedSupplierCodeId,
      'FAO': _deliverToController.text,
      'DeliveryID': _selectedDeliveryCodeId,
      'CategoryID': _selectedCategoryCodeId,
      'OrderTypeID': _selectedDocumentTypeId,
      'InvoicePtID': _selectedInvoiceCodeId,
      'ExpCode1_ID': _selectedAccountId,
      'ExpCode2_ID': _selectedRestaurentId,
      'Supp_Cont_ID': _selectedContactNumberId,
      'FOB': _deliverIncoterms.text,
      'Order_Budget_Header': _selectedBudgetId,
      'Instructions': _instructionsController.text,
      'Ship_Via': _shipViaController.text,
      'Justification': _justificationController.text,
      'Payment_Terms': _paymentTermsController.text,
      'Cust_ID': _selectedCustomerId,
      'ContractID': _selectedContractNumberId,
    };

    print("Saving ${_getHeaderPrefix()} Header...");
    LoggerData.dataLog("Form Data: $formData");

    // Here you would call your actual API
    // await HeaderService.saveHeader(formData, _getGroupName());

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("${_getHeaderPrefix()} Header Saved Successfully!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return Scaffold(
        backgroundColor: ColorManager.primary,
        appBar: buildCommonAppBar(
          context: context,
          title: widget.appBarTitle,
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: ColorManager.primary,
      appBar: buildCommonAppBar(
        context: context,
        title: widget.appBarTitle,
      ),
      body: ScrollbarTheme(
        data: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(ColorManager.blue),
          radius: const Radius.circular(8),
          thickness: WidgetStateProperty.all(6),
          trackColor:
              WidgetStateProperty.all(ColorManager.lightGrey.withOpacity(0.3)),
          trackBorderColor: WidgetStateProperty.all(ColorManager.grey),
          minThumbLength: 50,
          crossAxisMargin: 2,
          mainAxisMargin: 20,
        ),
        child: Scrollbar(
          thumbVisibility: true,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(8),
            child: Card(
              color: ColorManager.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Constant Fields
                    _buildConstantFieldsSection(),
                    const SizedBox(height: 16),

                    // Dynamic Fields
                    ..._buildDynamicFields(),

                    const SizedBox(height: 30),

                    // Save Button
                    SizedBox(
                      height: 50,
                      child: CustomButton(
                        buttonText: 'Save',
                        onTap: _saveForm,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildConstantFieldsSection() {
    final prefix = _getHeaderPrefix();
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: ColorManager.primary.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorManager.darkBlue.withOpacity(0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildConstantField("$prefix No", "${widget.id}"),
          const SizedBox(height: 8),
          _buildConstantField("$prefix Date", _getCurrentDate()),
          const SizedBox(height: 8),
          _buildConstantField("$prefix Status", "Pending"),
        ],
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return "${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}";
  }

  List<Widget> _buildDynamicFields() {
    List<Widget> fields = [];

    void addFieldIfVisible(String fieldId, Widget fieldWidget) {
      if (fieldVisible[fieldId] ?? false) {
        fields.add(fieldWidget);
        fields.add(const SizedBox(height: 10));
      }
    }

    // Text Fields
    addFieldIfVisible(
      "ReferenceNo",
      FormFieldHelper.buildTextField(
        label: fieldLabels["ReferenceNo"] ?? "",
        controller: _refNoController,
        hintText: 'Enter ${fieldLabels["ReferenceNo"] ?? ""}',
        isRequired: fieldRequired["ReferenceNo"] ?? false,
        readOnly: fieldReadOnly["ReferenceNo"] ?? false,
      ),
    );

    addFieldIfVisible(
      "FAO",
      FormFieldHelper.buildTextField(
        label: fieldLabels["FAO"] ?? "",
        controller: _deliverToController,
        hintText: 'Enter ${fieldLabels["FAO"] ?? ""}',
        isRequired: fieldRequired["FAO"] ?? false,
        readOnly: fieldReadOnly["FAO"] ?? false,
      ),
    );

    addFieldIfVisible(
      "FOB",
      FormFieldHelper.buildTextField(
        label: fieldLabels["FOB"] ?? "",
        controller: _deliverIncoterms,
        hintText: 'Enter ${fieldLabels["FOB"] ?? ""}',
        isRequired: fieldRequired["FOB"] ?? false,
        readOnly: fieldReadOnly["FOB"] ?? false,
      ),
    );

    addFieldIfVisible(
      "Instructions",
      FormFieldHelper.buildTextField(
        label: fieldLabels["Instructions"] ?? "",
        controller: _instructionsController,
        hintText: 'Enter ${fieldLabels["Instructions"] ?? ""}',
        isRequired: fieldRequired["Instructions"] ?? false,
        readOnly: fieldReadOnly["Instructions"] ?? false,
      ),
    );

    addFieldIfVisible(
      "Ship_Via",
      FormFieldHelper.buildTextField(
        label: fieldLabels["Ship_Via"] ?? "Ship Via",
        controller: _shipViaController,
        hintText: 'Enter ${fieldLabels["Ship_Via"] ?? "Ship Via"}',
        isRequired: fieldRequired["Ship_Via"] ?? false,
        readOnly: fieldReadOnly["Ship_Via"] ?? false,
      ),
    );

    addFieldIfVisible(
      "Justification",
      FormFieldHelper.buildTextField(
        label: fieldLabels["Justification"] ?? "Justification",
        controller: _justificationController,
        hintText: 'Enter ${fieldLabels["Justification"] ?? ""}',
        isRequired: fieldRequired["Justification"] ?? false,
        readOnly: fieldReadOnly["Justification"] ?? false,
      ),
    );

    addFieldIfVisible(
      "Payment_Terms",
      FormFieldHelper.buildTextField(
        label: fieldLabels["Payment_Terms"] ?? "",
        controller: _paymentTermsController,
        hintText: 'Enter ${fieldLabels["Payment_Terms"] ?? ""}',
        isRequired: fieldRequired["Payment_Terms"] ?? false,
        readOnly: fieldReadOnly["Payment_Terms"] ?? false,
      ),
    );

    // Dropdown Fields
    addFieldIfVisible(
      "SupplierID",
      FormFieldHelper.buildDropdownFieldWithIds(
        context: context,
        label: fieldLabels["SupplierID"] ?? "",
        value: _selectedSupplierCodeId,
        apiDisplayValue: _selectedSupplierCodeValue,
        items: getSupplierCodes(),
        onChanged: (value) {
          setState(() {
            _selectedSupplierCodeId = value;
          });
        },
        isRequired: fieldRequired["SupplierID"] ?? false,
        readOnly: fieldReadOnly["SupplierID"] ?? false,
      ),
    );

    addFieldIfVisible(
      "DeliveryID",
      FormFieldHelper.buildDropdownFieldWithIds(
        context: context,
        label: fieldLabels["DeliveryID"] ?? "",
        value: _selectedDeliveryCodeId,
        items: getSupplierCodes(),
        apiDisplayValue: _selectedDeliveryCodeValue,
        onChanged: (value) {
          setState(() {
            _selectedDeliveryCodeId = value;
          });
        },
        isRequired: fieldRequired["DeliveryID"] ?? false,
        readOnly: fieldReadOnly["DeliveryID"] ?? false,
      ),
    );

    addFieldIfVisible(
      "CategoryID",
      FormFieldHelper.buildDropdownFieldWithIds(
        context: context,
        label: fieldLabels["CategoryID"] ?? "",
        value: _selectedCategoryCodeId,
        apiDisplayValue: _selectedCategoryCodeValue,
        items: getSupplierCodes(),
        onChanged: (value) {
          setState(() {
            _selectedCategoryCodeId = value;
          });
        },
        isRequired: fieldRequired["CategoryID"] ?? false,
        readOnly: fieldReadOnly["CategoryID"] ?? false,
      ),
    );

    addFieldIfVisible(
      "OrderTypeID",
      FormFieldHelper.buildDropdownFieldWithIds(
        context: context,
        label: fieldLabels["OrderTypeID"] ?? "",
        value: _selectedDocumentTypeId,
        apiDisplayValue: _selectedDocumentTypeValue,
        items: getSupplierCodes(),
        onChanged: (value) {
          setState(() {
            _selectedDocumentTypeId = value;
          });
        },
        isRequired: fieldRequired["OrderTypeID"] ?? false,
        readOnly: fieldReadOnly["OrderTypeID"] ?? false,
      ),
    );

    addFieldIfVisible(
      "InvoicePtID",
      FormFieldHelper.buildDropdownFieldWithIds(
        context: context,
        label: fieldLabels["InvoicePtID"] ?? "",
        value: _selectedInvoiceCodeId,
        apiDisplayValue: _selectedInvoiceCodeValue,
        items: getSupplierCodes(),
        onChanged: (value) {
          setState(() {
            _selectedInvoiceCodeId = value;
          });
        },
        isRequired: fieldRequired["InvoicePtID"] ?? false,
        readOnly: fieldReadOnly["InvoicePtID"] ?? false,
      ),
    );

    addFieldIfVisible(
      "ExpCode1_ID",
      FormFieldHelper.buildDropdownFieldWithIds(
        context: context,
        label: fieldLabels["ExpCode1_ID"] ?? "",
        value: _selectedAccountId,
        apiDisplayValue: _selectedAccountValue,
        items: getSupplierCodes(),
        onChanged: (value) {
          setState(() {
            _selectedAccountId = value;
          });
        },
        isRequired: fieldRequired["ExpCode1_ID"] ?? false,
        readOnly: fieldReadOnly["ExpCode1_ID"] ?? false,
      ),
    );

    addFieldIfVisible(
      "ExpCode2_ID",
      FormFieldHelper.buildDropdownFieldWithIds(
        context: context,
        label: fieldLabels["ExpCode2_ID"] ?? "",
        value: _selectedRestaurentId,
        apiDisplayValue: _selectedRestaurentValue,
        items: getSupplierCodes(),
        onChanged: (value) {
          setState(() {
            _selectedRestaurentId = value;
          });
        },
        isRequired: fieldRequired["ExpCode2_ID"] ?? false,
        readOnly: fieldReadOnly["ExpCode2_ID"] ?? false,
      ),
    );

    addFieldIfVisible(
      "Supp_Cont_ID",
      FormFieldHelper.buildDropdownFieldWithIds(
        context: context,
        label: fieldLabels["Supp_Cont_ID"] ?? "",
        value: _selectedSupplierContactId,
        apiDisplayValue: _selectedSupplierContactValue,
        items: getSupplierCodes(),
        onChanged: (value) {
          setState(() {
            _selectedSupplierContactId = value;
          });
        },
        isRequired: fieldRequired["Supp_Cont_ID"] ?? false,
        readOnly: fieldReadOnly["Supp_Cont_ID"] ?? false,
      ),
    );

    addFieldIfVisible(
      "Order_Budget_Header",
      FormFieldHelper.buildDropdownFieldWithIds(
        context: context,
        label: fieldLabels["Order_Budget_Header"] ?? "",
        value: _selectedBudgetId,
        apiDisplayValue: _selectedBudgetValue,
        items: getBudget(),
        onChanged: (value) {
          setState(() {
            _selectedBudgetId = value;
          });
        },
        isRequired: fieldRequired["Order_Budget_Header"] ?? false,
        readOnly: fieldReadOnly["Order_Budget_Header"] ?? false,
      ),
    );

    addFieldIfVisible(
      "Cust_ID",
      FormFieldHelper.buildDropdownFieldWithIds(
        context: context,
        label: fieldLabels["Cust_ID"] ?? "Customer",
        value: _selectedCustomerId,
        apiDisplayValue: _selectedCustomerValue,
        items: getSupplierCodes(),
        onChanged: (value) {
          setState(() {
            _selectedCustomerId = value;
          });
        },
        isRequired: fieldRequired["Cust_ID"] ?? false,
        readOnly: fieldReadOnly["Cust_ID"] ?? false,
      ),
    );

    addFieldIfVisible(
      "ContractID",
      FormFieldHelper.buildDropdownFieldWithIds(
        context: context,
        label: fieldLabels["ContractID"] ?? "",
        value: _selectedContractNumberId,
        apiDisplayValue: _selectedContractNumberValue,
        items: getDeliveryCodes(),
        onChanged: (value) {
          setState(() {
            _selectedContractNumberId = value;
          });
        },
        isRequired: fieldRequired["ContractID"] ?? false,
        readOnly: fieldReadOnly["ContractID"] ?? false,
      ),
    );

    addFieldIfVisible(
      "ExpCode3_ID",
      FormFieldHelper.buildDropdownFieldWithIds(
        context: context,
        label: fieldLabels["ExpCode3_ID"] ?? "",
        value: _selectDepartmentCodeId,
        apiDisplayValue: _selectDepartmentCodeValue,
        items: getSupplierCodes(),
        onChanged: (value) {
          setState(() {
            _selectDepartmentCodeId = value;
          });
        },
        isRequired: fieldRequired["ExpCode3_ID"] ?? false,
        readOnly: fieldReadOnly["ExpCode3_ID"] ?? false,
      ),
    );

    return fields;
  }

  Widget _buildConstantField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: FontSize.s16,
              ),
            ),
          ),
          const Text(
            ' : ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: FontSize.s16,
            ),
          ),
          const SizedBox(width: 5),
          Expanded(
            flex: 4,
            child: Text(
              value,
              style: TextStyle(
                fontSize: FontSize.s16,
                color: ColorManager.darkGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
