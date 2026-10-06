class FormFieldConfig {
  final String key;
  final String label;
  final FieldType type;
  final dynamic value;
  final List<dynamic>? options;
  final bool isRequired;
  final String? validationMessage;
  final bool isEditable;

  FormFieldConfig({
    required this.key,
    required this.label,
    required this.type,
    this.value,
    this.options,
    this.isRequired = false,
    this.validationMessage,
    this.isEditable = true,
  });

  // Add copyWith method
  FormFieldConfig copyWith({
    String? key,
    String? label,
    FieldType? type,
    dynamic value,
    List<dynamic>? options,
    bool? isRequired,
    String? validationMessage,
    bool? isEditable,
  }) {
    return FormFieldConfig(
      key: key ?? this.key,
      label: label ?? this.label,
      type: type ?? this.type,
      value: value ?? this.value,
      options: options ?? this.options,
      isRequired: isRequired ?? this.isRequired,
      validationMessage: validationMessage ?? this.validationMessage,
      isEditable: isEditable ?? this.isEditable,
    );
  }
}

enum FieldType {
  text,
  dropdown,
  number,
  date,
  multiline,
  readonly,
}