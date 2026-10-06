import 'package:eyvo_v3/core/resources/color_manager.dart';
import 'package:eyvo_v3/core/widgets/common_app_bar.dart';
import 'package:eyvo_v3/features/auth/view/screens/approval/approval_12/form_field_custom.dart';
import 'package:flutter/material.dart';

class CommonFormPage extends StatefulWidget {
  final String pageTitle;
  final List<FormSection> sections; // Changed from fields to sections
  final bool isEditMode;
  final Function(Map<String, dynamic>)? onSubmit;
  final Function()? onCancel;
  final Widget? customBottomActions;

  const CommonFormPage({
    Key? key,
    required this.pageTitle,
    required this.sections,
    this.isEditMode = false,
    this.onSubmit,
    this.onCancel,
    this.customBottomActions,
  }) : super(key: key);

  @override
  State<CommonFormPage> createState() => _CommonFormPageState();
}

class FormSection {
  final String title;
  final IconData icon;
  final List<FormFieldConfig> fields;
  final bool isExpandable;
  final int? count;
  final VoidCallback? onSectionTap;
  final bool showInEditMode;
  final bool showInViewMode;

  FormSection({
    required this.title,
    required this.icon,
    required this.fields,
    this.isExpandable = true,
    this.count,
    this.onSectionTap,
    this.showInEditMode = true,
    this.showInViewMode = true,
  });
}

class _CommonFormPageState extends State<CommonFormPage> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  final Map<String, TextEditingController> _controllers = {};
  final Map<String, bool> _sectionExpansionState = {};

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  void _initializeForm() {
    // Initialize expansion state - all sections start expanded in view mode
    for (var section in widget.sections) {
      _sectionExpansionState[section.title] = !widget.isEditMode;
    }

    // Initialize form data and controllers
    for (var section in widget.sections) {
      for (var field in section.fields) {
        final initialValue = _formData[field.key] ?? field.value;
        _controllers[field.key] =
            TextEditingController(text: initialValue?.toString() ?? '');
        _formData[field.key] = initialValue;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text(widget.pageTitle),
      //   leading: IconButton(
      //     icon: Icon(Icons.arrow_back),
      //     onPressed: () => Navigator.pop(context),
      //   ),
      //   actions: widget.isEditMode
      //       ? []
      //       : [
      //           IconButton(
      //             icon: Icon(Icons.edit),
      //             onPressed: _switchToEditMode,
      //           ),
      //         ],
      //   backgroundColor: ColorManager.primary,
      // ),
      body: Column(
        children: [
          Expanded(
            child: _buildContent(),
          ),
          if (widget.customBottomActions != null) widget.customBottomActions!,
        ],
      ),
      floatingActionButton: widget.isEditMode ? _buildSubmitButton() : null,
    );
  }

  Widget _buildContent() {
    final filteredSections = widget.sections.where((section) {
      return widget.isEditMode
          ? section.showInEditMode
          : section.showInViewMode;
    }).toList();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: widget.isEditMode
          ? _buildEditForm(filteredSections)
          : _buildViewMode(filteredSections),
    );
  }

  Widget _buildEditForm(List<FormSection> sections) {
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          ...sections.expand((section) => [
                _buildSectionHeader(section),
                ...section.fields.map((field) => _buildFormField(field)),
                const SizedBox(height: 16),
              ]),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildViewMode(List<FormSection> sections) {
    return ListView(
      children: sections.map((section) => _buildViewSection(section)).toList(),
    );
  }

  Widget _buildSectionHeader(FormSection section) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Row(
        children: [
          Icon(section.icon, color: ColorManager.darkBlue),
          const SizedBox(width: 12),
          Text(
            section.title,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: ColorManager.darkBlue,
            ),
          ),
          if (section.count != null) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: ColorManager.orange,
                shape: BoxShape.circle,
              ),
              child: Text(
                '${section.count}',
                style: TextStyle(
                  color: ColorManager.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildViewSection(FormSection section) {
    return Card(
      color: ColorManager.white,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section Header
            Row(
              children: [
                Icon(section.icon, color: ColorManager.darkBlue),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    section.title,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: ColorManager.darkBlue,
                    ),
                  ),
                ),
                if (section.count != null)
                  Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      color: ColorManager.orange,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      '${section.count}',
                      style: TextStyle(
                        color: ColorManager.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            // Fields
            ...section.fields.map((field) => _buildViewField(field)),
          ],
        ),
      ),
    );
  }

  Widget _buildFormField(FormFieldConfig field) {
    if (!field.isEditable) {
      return _buildViewField(field);
    }

    switch (field.type) {
      case FieldType.dropdown:
        return _buildDropdownField(field);
      case FieldType.multiline:
        return _buildMultilineField(field);
      case FieldType.date:
        return _buildDateField(field);
      default:
        return _buildTextField(field);
    }
  }

  Widget _buildTextField(FormFieldConfig field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _controllers[field.key],
        decoration: InputDecoration(
          labelText: field.label,
          border: OutlineInputBorder(),
          suffixIcon: field.isRequired
              ? Icon(Icons.star, size: 12, color: Colors.red)
              : null,
        ),
        keyboardType: field.type == FieldType.number
            ? TextInputType.number
            : TextInputType.text,
        maxLines: field.type == FieldType.multiline ? 3 : 1,
        validator: (value) {
          if (field.isRequired && (value == null || value.isEmpty)) {
            return field.validationMessage ?? '${field.label} is required';
          }
          return null;
        },
        onChanged: (value) => _formData[field.key] = value,
      ),
    );
  }

  Widget _buildMultilineField(FormFieldConfig field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _controllers[field.key],
        decoration: InputDecoration(
          labelText: field.label,
          border: OutlineInputBorder(),
          suffixIcon: field.isRequired
              ? Icon(Icons.star, size: 12, color: Colors.red)
              : null,
          alignLabelWithHint: true,
        ),
        keyboardType: TextInputType.multiline,
        maxLines: 4,
        minLines: 3,
        validator: (value) {
          if (field.isRequired && (value == null || value.isEmpty)) {
            return field.validationMessage ?? '${field.label} is required';
          }
          return null;
        },
        onChanged: (value) => _formData[field.key] = value,
      ),
    );
  }

  Widget _buildDateField(FormFieldConfig field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: _controllers[field.key],
        decoration: InputDecoration(
          labelText: field.label,
          border: OutlineInputBorder(),
          suffixIcon: Icon(Icons.calendar_today),
          suffixIconColor: ColorManager.blue,
        ),
        readOnly: true,
        onTap: () => _selectDate(field),
        validator: (value) {
          if (field.isRequired && (value == null || value.isEmpty)) {
            return field.validationMessage ?? '${field.label} is required';
          }
          return null;
        },
      ),
    );
  }

  Future<void> _selectDate(FormFieldConfig field) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      final formattedDate = "${picked.day}/${picked.month}/${picked.year}";
      _controllers[field.key]!.text = formattedDate;
      _formData[field.key] = formattedDate;
      setState(() {});
    }
  }

  Widget _buildDropdownField(FormFieldConfig field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: DropdownButtonFormField<dynamic>(
        value: _formData[field.key],
        decoration: InputDecoration(
          labelText: field.label,
          border: OutlineInputBorder(),
        ),
        items: field.options?.map((option) {
          return DropdownMenuItem(
            value: option is Map ? option['value'] : option,
            child: Text(option is Map ? option['label'] : option.toString()),
          );
        }).toList(),
        onChanged: (value) {
          setState(() {
            _formData[field.key] = value;
          });
        },
        validator: (value) {
          if (field.isRequired && value == null) {
            return field.validationMessage ?? 'Please select ${field.label}';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildViewField(FormFieldConfig field) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 150,
            child: Text(
              field.label,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: ColorManager.darkGrey,
              ),
            ),
          ),
          Text(
            ' : ',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Expanded(
            child: Text(
              _getDisplayValue(field),
              style: TextStyle(
                fontSize: 16,
                color: ColorManager.darkGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getDisplayValue(FormFieldConfig field) {
    final value = _formData[field.key] ?? field.value;
    if (value == null) return 'Not set';

    if (field.type == FieldType.dropdown && field.options != null) {
      final option = field.options!.firstWhere(
        (opt) {
          final optValue = opt is Map ? opt['value'] : opt;
          return optValue == value;
        },
        orElse: () => value,
      );
      return option is Map ? option['label'] : value.toString();
    }

    return value.toString();
  }

  Widget _buildSubmitButton() {
    return FloatingActionButton.extended(
      onPressed: _submitForm,
      backgroundColor: ColorManager.blue,
      icon: Icon(Icons.save, color: Colors.white),
      label: Text('Submit', style: TextStyle(color: Colors.white)),
    );
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      widget.onSubmit?.call(_formData);
    }
  }

  void _switchToEditMode() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CommonFormPage(
          pageTitle: 'Edit ${widget.pageTitle}',
          sections: widget.sections
              .map((section) => FormSection(
                    title: section.title,
                    icon: section.icon,
                    fields: section.fields
                        .map((f) => f.copyWith(isEditable: true))
                        .toList(),
                    count: section.count,
                  ))
              .toList(),
          isEditMode: true,
          onSubmit: widget.onSubmit,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controllers.values.forEach((controller) => controller.dispose());
    super.dispose();
  }
}
