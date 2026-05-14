class Validators {
  const Validators._();

  static String? requiredField(String? value, {String fieldName = 'Field'}) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  static String? maxLength(
    String? value, {
    required int max,
    String fieldName = 'Field',
  }) {
    if (value != null && value.trim().length > max) {
      return '$fieldName must be $max characters or less';
    }
    return null;
  }
}
