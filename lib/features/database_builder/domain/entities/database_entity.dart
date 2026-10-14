import 'database_enums.dart';

class DatabaseEntity {
  final String? id;
  final String title;
  final String titleAr;
  final String description;
  final String descriptionAr;
  final int tablesCount;
  final AccessType accessType;

  /// What the assigned employees may do. `null` until chosen (drafts).
  final DatabasePermission? permissions;
  final DateTime? startDate;
  final DateTime? endDate;
  final DatabaseStatus status;

  /// Set by the server when the database is created.
  final DateTime? creationDate;

  /// Set by the server on every change.
  final DateTime? lastEditDate;

  /// Only for [DatabaseStatus.deleted].
  final DateTime? deletedDate;
  final List<String> assignedEmployeeIds;

  const DatabaseEntity({
    this.id,
    required this.title,
    this.titleAr = '',
    this.description = '',
    this.descriptionAr = '',
    this.tablesCount = 0,
    required this.accessType,
    this.permissions,
    this.startDate,
    this.endDate,
    required this.status,
    this.creationDate,
    this.lastEditDate,
    this.deletedDate,
    this.assignedEmployeeIds = const [],
  });

  bool get isDraft => status == DatabaseStatus.draft;
  bool get isDeleted => status == DatabaseStatus.deleted;
}
