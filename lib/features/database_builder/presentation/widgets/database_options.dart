import '../../domain/entities/database_enums.dart';

class DatabaseOptions {
  const DatabaseOptions._();

  /// "no filter" entry of the access-type dropdown.
  static const String allLabel = 'All';

  /// Items of the "Access Management" dropdown.
  static final List<String> accessLabels = [
    for (final type in AccessType.values) type.label,
  ];

  /// Items of the "Permissions" dropdown.
  static final List<String> permissionLabels = [
    for (final permission in DatabasePermission.values) permission.label,
  ];

  /// The permission behind a dropdown [label], or `null`.
  static DatabasePermission? permissionFromLabel(String? label) {
    for (final permission in DatabasePermission.values) {
      if (permission.label == label) return permission;
    }
    return null;
  }

  /// The access type behind a dropdown [label], or `null`.
  static AccessType? accessTypeFromLabel(String? label) {
    for (final type in AccessType.values) {
      if (type.label == label) return type;
    }
    return null;
  }
}
