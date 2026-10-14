class Validators {
  static const String requiredMessage = 'This Field Is Required';

  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) return requiredMessage;
    return null;
  }
}
