class Validators {
  static const String requiredMessage = 'This Field Is Required';
  static const String endBeforeStartMessage =
      'End Date Must Be After Start Date';

  static String? requiredField(String? value) {
    if (value == null || value.trim().isEmpty) return requiredMessage;
    return null;
  }

  /// Required text that may not exceed [maxLength] characters.
  static String? requiredMaxLength(String? value, int maxLength) {
    final required = requiredField(value);
    if (required != null) return required;
    if (value!.trim().length > maxLength) {
      return 'Maximum $maxLength Characters';
    }
    return null;
  }

  /// Both dates are required and [end] must be strictly after [start].
  static String? endDateAfterStart(DateTime? end, DateTime? start) {
    if (end == null) return requiredMessage;
    if (start != null && !end.isAfter(start)) return endBeforeStartMessage;
    return null;
  }
}
