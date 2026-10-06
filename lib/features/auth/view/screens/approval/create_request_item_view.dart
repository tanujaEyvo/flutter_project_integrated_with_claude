import 'package:eyvo_v3/api/response_models/order_header_response.dart';
import 'package:eyvo_v3/core/widgets/button.dart';
import 'package:eyvo_v3/core/widgets/form_field_helper.dart';
import 'package:eyvo_v3/core/widgets/searchable_dropdown_modal.dart';
import 'package:eyvo_v3/log_data.dart/logger_data.dart';
import 'package:flutter/material.dart';
import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/resources/font_manager.dart';
import 'package:eyvo_v3/core/resources/styles_manager.dart';
import 'package:eyvo_v3/core/widgets/common_app_bar.dart';

class CreateRequestLineView extends StatefulWidget {
  const CreateRequestLineView({Key? key}) : super(key: key);

  @override
  State<CreateRequestLineView> createState() => _CreateRequestLineViewState();
}

class _CreateRequestLineViewState extends State<CreateRequestLineView> {
  // Controllers

  CreateHeaderResponse? apiResponse;
  bool isLoading = true;

// Field Visibility Flags

  bool _showExpCode4 = true;
  bool _showExpCode5Code = true;
  bool _showExpCode6Code = true;
  bool _showDueDate = true;
  bool _showUnit = true;
  bool _showSuppliersPartNo = true;
  bool _showItemCode = true;
  bool _showQuantity = true;
  bool _showPackSize = true;
  bool _showPrice = true;
  bool _showDiscountType = true;
  bool _showDiscount = true;
  bool _showSalesTax = true;
  bool _showOpexCapex = true;
  bool _showMarkup = true;
  bool _showExpenseType = true;
  bool _showSupplier = true;

// Dropdown Selected IDs

  String? _selectedExpCode4Id;
  String? _selectedExpCode5Id;
  String? _selectedExpCode6CodeId;
  String? _selectedUnitId;
  String? _selectedItemCodeId;
  String? _selectedDiscountTypeId;
  String? _selectedOpexCapexId;
  String? _selectedExpenseTypeId;
  String? _selectedSupplierId;

// Dropdown Selected Values

  String? _selectedExpCode4Value;
  String? _selectedExpCode5Value;
  String? _selectedExpCode6CodeValue;
  String? _selectedUnitValue;
  String? _selectedItemCodeValue;
  String? _selectedDiscountTypeValue;
  String? _selectedOpexCapexValue;
  String? _selectedExpenseTypeValue;
  String? _selectedSupplierValue;

// Text Controllers

  final TextEditingController _dueDateController = TextEditingController();
  final TextEditingController _suppliersPartNoController =
      TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _packSizeController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _salesTaxController = TextEditingController();
  final TextEditingController _markupController = TextEditingController();
  final TextEditingController _supplierPartNoController =
      TextEditingController();
  final TextEditingController _itemQuantityController = TextEditingController();
  final TextEditingController _itemPackSizeController = TextEditingController();
  // final TextEditingController _priceController = TextEditingController();
  // final TextEditingController _salesTaxController = TextEditingController();
  final TextEditingController _itemDescriptionController =
      TextEditingController();

  // Dropdown data
  List<DropdownItem> catalogItems() {
    return [
      DropdownItem(id: "1", value: "CAT-001"),
      DropdownItem(id: "1", value: "CAT-002"),
      DropdownItem(id: "1", value: "CAT-003"),
      DropdownItem(id: "1", value: "CAT-004"),
    ];
  }

  final List<String> itemUnits = [
    "Box",
    "Piece",
    "Kg",
    "Liters",
  ];
  final String mockJson = '''{
    "code": 200,
    "message": [
        "success"
    ],
    "data": [
        {
            "fieldID": "ExpCode4_ID",
            "labelName": "GL",
            "ID": "35",
            "value": "010",
            "controlType": "dropdown",
            "required": false,
            "readWrite": true,
            "visible": true
        },
        {
            "fieldID": "ExpCode5_ID",
            "labelName": "Property Code",
            "ID": "23",
            "value": "5435",
            "controlType": "dropdown",
            "required": false,
            "readWrite": true,
            "visible": true
        },
        {
            "fieldID": "ExpCode6_ID",
            "labelName": "Nominal Code",
            "ID": "8",
            "value": "62610-016",
            "controlType": "dropdown",
            "required": false,
            "readWrite": true,
            "visible": true
        },
        {
            "fieldID": "DueDate",
            "labelName": "Due Date",
            "ID": "0",
            "value": "",
            "controlType": "date",
            "required": false,
            "readWrite": true,
            "visible": true
        },
        {
            "fieldID": "SupplierID",
            "labelName": "Supplier",
            "ID": "315",
            "value": "DLF",
            "controlType": "dropdown",
            "required": false,
            "readWrite": true,
            "visible": true
        },
        {
            "fieldID": "Unit",
            "labelName": "Unit",
            "ID": "9",
            "value": "Pound",
            "controlType": "dropdown",
            "required": false,
            "readWrite": true,
            "visible": true
        },
        {
            "fieldID": "SuppliersPartNo",
            "labelName": "Suppliers Part Number",
            "ID": "0",
            "value": "CHIA_25LB",
            "controlType": "textbox",
            "required": false,
            "readWrite": true,
            "visible": true
        },
        {
            "fieldID": "Expense_Type",
            "labelName": "Expense Type",
            "ID": "",
            "value": "",
            "controlType": "dropdown",
            "required": false,
            "readWrite": true,
            "visible": true
        },
        {
            "fieldID": "ItemID",
            "labelName": "Item Code",
            "ID": "2142",
            "value": "Chia Seeds Black DLF 1x25lb",
            "controlType": "dropdown",
            "required": true,
            "readWrite": true,
            "visible": true
        },
        {
            "fieldID": "Quantity",
            "labelName": "Item Quantity",
            "ID": "0",
            "value": "3.125",
            "controlType": "textbox",
            "required": true,
            "readWrite": true,
            "visible": true
        },
        {
            "fieldID": "PackSize",
            "labelName": "Item Pack Size",
            "ID": "0",
            "value": "25",
            "controlType": "textbox",
            "required": true,
            "readWrite": true,
            "visible": true
        },
        {
            "fieldID": "Price",
            "labelName": "Item Price",
            "ID": "0",
            "value": "230.784000",
            "controlType": "textbox",
            "required": true,
            "readWrite": true,
            "visible": true
        },
        {
            "fieldID": "Discount_Type",
            "labelName": "Discount Type",
            "ID": "0",
            "value": "%",
            "controlType": "dropdown",
            "required": true,
            "readWrite": true,
            "visible": true
        },
        {
            "fieldID": "Discount",
            "labelName": "Item Discount",
            "ID": "0",
            "value": "0.0000000",
            "controlType": "textbox",
            "required": true,
            "readWrite": true,
            "visible": true
        },
        {
            "fieldID": "Tax",
            "labelName": "Sales Tax %",
            "ID": "0",
            "value": "0.0000000",
            "controlType": "textbox",
            "required": true,
            "readWrite": true,
            "visible": true
        },
        {
            "fieldID": "Opex_Capex",
            "labelName": "Opex/Capex",
            "ID": "Opex",
            "value": "Opex",
            "controlType": "dropdown",
            "required": true,
            "readWrite": true,
            "visible": true
        },
        {
            "fieldID": "Markup",
            "labelName": "Markup",
            "ID": "0",
            "value": "0.000000",
            "controlType": "textbox",
            "required": true,
            "readWrite": true,
            "visible": false
        }
    ],
    "totalrecords": 17
}''';
  @override
  void initState() {
    super.initState();
    loadMockData();
  }

  void loadMockData() {
    final decoded = CreateHeaderResponseFromJson(mockJson);
    setState(() {
      apiResponse = decoded;
      isLoading = false;

      // Set field visibility and initial values based on API response
      for (var field in decoded.data) {
        switch (field.fieldId) {
          case "ExpCode4_ID":
            _showExpCode4 = field.visible;
            if (field.visible && field.value.isNotEmpty) {
              _selectedExpCode4Id = field.id.toString();
              _selectedExpCode4Value = field.value;
            }
            break;

          case "ExpCode5_ID":
            _showExpCode5Code = field.visible;
            if (field.visible && field.value.isNotEmpty) {
              _selectedExpCode5Id = field.id.toString();
              _selectedExpCode5Value = field.value;
            }
            break;

          case "ExpCode6_ID":
            _showExpCode6Code = field.visible;
            if (field.visible && field.value.isNotEmpty) {
              _selectedExpCode6CodeId = field.id.toString();
              _selectedExpCode6CodeValue = field.value;
            }
            break;

          case "DueDate":
            _showDueDate = field.visible;
            if (field.visible && field.value.isNotEmpty) {
              _dueDateController.text = field.value;
            }
            break;

          case "Unit":
            _showUnit = field.visible;
            if (field.visible && field.value.isNotEmpty) {
              _selectedUnitId = field.id.toString();
              _selectedUnitValue = field.value;
            }
            break;

          case "SuppliersPartNo":
            _showSuppliersPartNo = field.visible;
            if (field.visible) {
              _suppliersPartNoController.text = field.value;
            }
            break;

          case "ItemID":
            _showItemCode = field.visible;
            if (field.visible && field.value.isNotEmpty) {
              _selectedItemCodeId = field.id.toString();
              _selectedItemCodeValue = field.value;
            }
            break;

          case "Quantity":
            _showQuantity = field.visible;
            if (field.visible) {
              _quantityController.text = field.value;
            }
            break;

          case "PackSize":
            _showPackSize = field.visible;
            if (field.visible) {
              _packSizeController.text = field.value;
            }
            break;

          case "Price":
            _showPrice = field.visible;
            if (field.visible) {
              _priceController.text = field.value;
            }
            break;

          case "Discount_Type":
            _showDiscountType = field.visible;
            if (field.visible && field.value.isNotEmpty) {
              _selectedDiscountTypeId = field.id.toString();
              _selectedDiscountTypeValue = field.value;
            }
            break;

          case "Discount":
            _showDiscount = field.visible;
            if (field.visible) {
              _discountController.text = field.value;
            }
            break;

          case "Tax":
            _showSalesTax = field.visible;
            if (field.visible) {
              _salesTaxController.text = field.value;
            }
            break;

          case "Opex_Capex":
            _showOpexCapex = field.visible;
            if (field.visible && field.value.isNotEmpty) {
              _selectedOpexCapexId = field.id.toString();
              _selectedOpexCapexValue = field.value;
            }
            break;

          case "Markup":
            _showMarkup = field.visible;
            if (field.visible) {
              _markupController.text = field.value;
            }
            break;

          case "Expense_Type":
            _showExpenseType = field.visible;
            if (field.visible && field.value.isNotEmpty) {
              _selectedExpenseTypeId = field.id.toString();
              _selectedExpenseTypeValue = field.value;
            }
            break;

          case "SupplierID":
            _showSupplier = field.visible;
            if (field.visible && field.value.isNotEmpty) {
              _selectedSupplierId = field.id.toString();
              _selectedSupplierValue = field.value;
            }
            break;
        }
      }
    });
  }

  @override
  void dispose() {
    _dueDateController.dispose();
    _suppliersPartNoController.dispose();
    _quantityController.dispose();
    _packSizeController.dispose();
    _priceController.dispose();
    _discountController.dispose();
    _salesTaxController.dispose();
    _markupController.dispose();
    _supplierPartNoController.dispose();
    _itemQuantityController.dispose();
    _itemPackSizeController.dispose();
    _itemDescriptionController.dispose();

    super.dispose();
  }

  void _saveForm() {
    // Prepare data for API
    Map<String, dynamic> formData = {
      'ExpCode4_ID': _selectedExpCode4Id,
      'ExpCode5_ID': _selectedExpCode5Id,
      'ExpCode6_ID': _selectedExpCode6CodeId,
      'DueDate': _dueDateController.text,
      'Unit': _selectedUnitId,
      'SuppliersPartNo': _suppliersPartNoController.text,
      'ItemID': _selectedItemCodeId,
      'Quantity': _quantityController.text,
      'PackSize': _packSizeController.text,
      'Price': _priceController.text,
      'Discount_Type': _selectedDiscountTypeId,
      'Discount': _discountController.text,
      'Tax': _salesTaxController.text,
      'Opex_Capex': _selectedOpexCapexId,
      'Markup': _markupController.text,
      'Expense_Type': _selectedExpenseTypeId,
      'SupplierID': _selectedSupplierId,
    };

    LoggerData.dataLog("Order Line Form Data: $formData");
    // print("Order Line Form Data: $formData");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Order Line Saved Successfully!"),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorManager.primary,
      appBar: buildCommonAppBar(
        context: context,
        title: "Order Line",
      ),
      body: ScrollbarTheme(
        data: ScrollbarThemeData(
          thumbColor: WidgetStateProperty.all(ColorManager.blue),
          radius: const Radius.circular(8),
          thickness: WidgetStateProperty.all(6),
          // You can add more customization:
          trackColor:
              WidgetStateProperty.all(ColorManager.lightGrey.withOpacity(0.3)),
          trackBorderColor: WidgetStateProperty.all(ColorManager.grey),
          minThumbLength: 30,
          crossAxisMargin: 2,
          mainAxisMargin: 10,
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
                    //-------------------- DROPDOWN: Catalog Items --------------------
                    if (_showItemCode) ...[
                      FormFieldHelper.buildDropdownFieldWithIds(
                        context: context,
                        label: "Catalog Item",
                        value: _selectedItemCodeId,
                        apiDisplayValue: _selectedItemCodeValue,
                        items: catalogItems(),
                        onChanged: (value) {
                          setState(() {
                            _selectedItemCodeId = value;
                          });
                        },
                        isRequired: true,
                        readOnly: true,
                      ),
                      const SizedBox(height: 10),
                    ],

                    //-------------------- BIG TEXT FIELD: Item Description --------------------
                    FormFieldHelper.buildMultilineTextField(
                      label: "Item Description",
                      controller: _itemDescriptionController,
                      hintText: "Enter detailed item description",
                      isRequired: true,
                    ),
                    const SizedBox(height: 10),
                    //-------------------- TEXT FIELD: Supplier Part No --------------------
                    if (_showSuppliersPartNo) ...[
                      FormFieldHelper.buildTextField(
                        label: "Supplier Part No",
                        controller: _suppliersPartNoController,
                        hintText: "Enter supplier part number",
                        isRequired: true,
                      ),
                      const SizedBox(height: 10),
                    ],

                    //-------------------- DATE PICKER: Item Due Date --------------------
                    if (_showDueDate) ...[
                      FormFieldHelper.buildDatePickerField(
                        context: context,
                        label: "Item Due Date",
                        controller: _dueDateController,
                        isRequired: true,
                        readOnly: true,
                      ),
                      const SizedBox(height: 10),
                    ],
                    //-------------------- TEXT FIELD: Item Quantity --------------------
                    if (_showQuantity) ...[
                      FormFieldHelper.buildTextField(
                        label: "Item Quantity",
                        controller: _quantityController,
                        hintText: "Enter item quantity",
                        keyboardType: TextInputType.number,
                        isRequired: true,
                        readOnly: true,
                      ),
                      const SizedBox(height: 10),
                    ],
                    //-------------------- DROPDOWN: Item Unit --------------------
                    if (_showQuantity) ...[
                      FormFieldHelper.buildDropdownFieldWithIds(
                        context: context,
                        label: "Item Unit",
                        value: _selectedUnitId,
                        items: catalogItems(),
                        apiDisplayValue: _selectedUnitValue,
                        onChanged: (value) {
                          setState(() {
                            _selectedUnitId = value;
                          });
                        },
                        isRequired: true,
                        readOnly: true,
                      ),
                      const SizedBox(height: 10),
                    ],

                    //-------------------- TEXT FIELD: Item Pack Size --------------------
                    if (_showPackSize) ...[
                      FormFieldHelper.buildTextField(
                        label: "Item Pack Size",
                        controller: _itemPackSizeController,
                        hintText: "Enter item pack size",
                        isRequired: true,
                        readOnly: true,
                      ),
                      const SizedBox(height: 10),
                    ],

                    //-------------------- TEXT FIELD: Price (USD) --------------------
                    if (_showPrice) ...[
                      FormFieldHelper.buildTextField(
                        label: "Price (USD)",
                        controller: _priceController,
                        hintText: "Enter price in USD",
                        keyboardType: TextInputType.number,
                        isRequired: true,
                        readOnly: true,
                      ),
                      const SizedBox(height: 10),
                    ],

                    //-------------------- TEXT FIELD: Sales Tax % --------------------
                    if (_showSalesTax) ...[
                      FormFieldHelper.buildTextField(
                        label: "Sales Tax %",
                        controller: _salesTaxController,
                        hintText: "Enter sales tax percentage",
                        keyboardType: TextInputType.number,
                        isRequired: true,
                      ),
                      const SizedBox(height: 10),

                      // const SizedBox(height: 30),
                    ],

//-------------------------------ExpCode4_ID-------------------------------
                    if (_showExpCode4) ...[
                      FormFieldHelper.buildDropdownFieldWithIds(
                        context: context,
                        label: 'GL',
                        value: _selectedExpCode4Id,
                        items: catalogItems(),
                        apiDisplayValue: _selectedExpCode4Value,
                        onChanged: (value) {
                          setState(() {
                            _selectedExpCode4Value = value;
                          });
                        },
                        isRequired: true,
                      ),
                      const SizedBox(height: 10),
                    ],

//----------------------------------ExpCode5_ID---------------------------------
                    if (_showExpCode5Code) ...[
                      FormFieldHelper.buildDropdownFieldWithIds(
                        context: context,
                        label: 'Property Code',
                        value: _selectedExpCode5Id,
                        items: catalogItems(),
                        apiDisplayValue: _selectedExpCode5Value,
                        onChanged: (value) {
                          setState(() {
                            _selectedExpCode5Value = value;
                          });
                        },
                        isRequired: true,
                      ),
                      const SizedBox(height: 10),
                    ],

//-----------------------------------ExpCode6_ID--------------------------
                    if (_showExpCode6Code) ...[
                      FormFieldHelper.buildDropdownFieldWithIds(
                        context: context,
                        label: 'Nominal Code',
                        value: _selectedExpCode6CodeId,
                        items: catalogItems(),
                        apiDisplayValue: _selectedExpCode6CodeValue,
                        onChanged: (value) {
                          setState(() {
                            _selectedExpCode6CodeValue = value;
                          });
                        },
                        isRequired: true,
                      ),
                      const SizedBox(height: 10),
                    ],

// ---------------------------------Unit--------------------
                    if (_showUnit) ...[
                      FormFieldHelper.buildDropdownFieldWithIds(
                        context: context,
                        label: 'Unit',
                        value: _selectedUnitId,
                        items: catalogItems(),
                        apiDisplayValue: _selectedUnitValue,
                        onChanged: (value) {
                          setState(() {
                            _selectedUnitValue = value;
                          });
                        },
                        isRequired: true,
                      ),
                      const SizedBox(height: 10),
                    ],

//-------------------------------Supplier’s Part Number---------------------------
                    if (_showSuppliersPartNo) ...[
                      FormFieldHelper.buildTextField(
                        label: 'Supplier’s Part Number',
                        isRequired: true,
                        controller: _suppliersPartNoController,
                        keyboardType: TextInputType.text,
                        hintText: 'Enter Supplier’s Part Number',
                      ),
                      const SizedBox(height: 10),
                    ],

// ----------------------------Opex/Capex------------------------------
                    if (_showOpexCapex) ...[
                      FormFieldHelper.buildDropdownFieldWithIds(
                        context: context,
                        label: 'Opex/Capex',
                        value: _selectedOpexCapexId,
                        items: catalogItems(),
                        apiDisplayValue: _selectedOpexCapexValue,
                        onChanged: (value) {
                          setState(() {
                            _selectedOpexCapexValue = value;
                          });
                        },
                        isRequired: true,
                      ),
                      const SizedBox(height: 10),
                    ],

//------------------------------------Markup---------------------------
                    if (_showMarkup) ...[
                      FormFieldHelper.buildTextField(
                        label: 'Markup',
                        isRequired: true,
                        controller: _markupController,
                        keyboardType: TextInputType.number,
                        hintText: 'Enter Markup',
                      ),
                      const SizedBox(height: 10),
                    ],

//---------------Expense Type---------------------------
                    if (_showExpenseType) ...[
                      FormFieldHelper.buildDropdownFieldWithIds(
                        context: context,
                        label: 'Expense Type',
                        value: _selectedExpenseTypeId,
                        items: catalogItems(),
                        apiDisplayValue: _selectedExpenseTypeValue,
                        onChanged: (value) {
                          setState(() {
                            _selectedExpenseTypeValue = value;
                          });
                        },
                        isRequired: true,
                      ),
                      const SizedBox(height: 30),
                    ],

                    //-------------------- SAVE BUTTON --------------------
                    SizedBox(
                      height: 50,
                      child: CustomButton(
                        buttonText: 'Save',
                        onTap: () {
                          _saveForm();
                        },
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
}
