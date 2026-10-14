import 'package:json_annotation/json_annotation.dart';

import '../../../../core/utils/firestore_timestamp.dart';
import '../../domain/entities/database_entity.dart';
import '../../domain/entities/database_enums.dart';

part 'database_model.g.dart';

@JsonSerializable(includeIfNull: false)
class DatabaseModel {
  /// Firestore document id. It is not stored inside the document body.
  @JsonKey(includeToJson: false)
  String? id;
  String? title;
  String? titleAr;
  String? description;
  String? descriptionAr;
  int? tablesCount;

  /// [AccessType.name]
  String? accessType;

  /// [DatabasePermission.name]
  String? permissions;
  @JsonKey(fromJson: dateFromFirestore, toJson: dateToFirestore)
  DateTime? startDate;
  @JsonKey(fromJson: dateFromFirestore, toJson: dateToFirestore)
  DateTime? endDate;

  /// [DatabaseStatus.name]
  String? status;

  /// Written by the server (`FieldValue.serverTimestamp()`), never by the app.
  @JsonKey(
    includeToJson: false,
    fromJson: dateFromFirestore,
    toJson: dateToFirestore,
  )
  DateTime? creationDate;
  @JsonKey(
    includeToJson: false,
    fromJson: dateFromFirestore,
    toJson: dateToFirestore,
  )
  DateTime? lastEditDate;
  @JsonKey(fromJson: dateFromFirestore, toJson: dateToFirestore)
  DateTime? deletedDate;
  @JsonKey(defaultValue: <String>[])
  List<String>? assignedEmployeeIds;

  DatabaseModel({
    this.id,
    this.title,
    this.titleAr,
    this.description,
    this.descriptionAr,
    this.tablesCount,
    this.accessType,
    this.permissions,
    this.startDate,
    this.endDate,
    this.status,
    this.creationDate,
    this.lastEditDate,
    this.deletedDate,
    this.assignedEmployeeIds,
  });

  factory DatabaseModel.fromJson(Map<String, dynamic> json) =>
      _$DatabaseModelFromJson(json);

  Map<String, dynamic> toJson() => _$DatabaseModelToJson(this);

  factory DatabaseModel.fromEntity(DatabaseEntity entity) => DatabaseModel(
    id: entity.id,
    title: entity.title,
    titleAr: entity.titleAr,
    description: entity.description,
    descriptionAr: entity.descriptionAr,
    tablesCount: entity.tablesCount,
    accessType: entity.accessType.name,
    permissions: entity.permissions?.name,
    startDate: entity.startDate,
    endDate: entity.endDate,
    status: entity.status.name,
    creationDate: entity.creationDate,
    lastEditDate: entity.lastEditDate,
    deletedDate: entity.deletedDate,
    assignedEmployeeIds: entity.assignedEmployeeIds,
  );

  /// Unknown or missing enum values fall back to the safest choice
  /// ([AccessType.restricted]) instead of crashing the whole list.
  DatabaseEntity toEntity() {
    final access = AccessType.fromName(accessType) ?? AccessType.restricted;
    return DatabaseEntity(
      id: id,
      title: title ?? '',
      titleAr: titleAr ?? '',
      description: description ?? '',
      descriptionAr: descriptionAr ?? '',
      tablesCount: tablesCount ?? 0,
      accessType: access,
      permissions: DatabasePermission.fromName(permissions),
      startDate: startDate,
      endDate: endDate,
      status: DatabaseStatus.fromName(status) ?? access.status,
      creationDate: creationDate,
      lastEditDate: lastEditDate,
      deletedDate: deletedDate,
      assignedEmployeeIds: assignedEmployeeIds ?? const [],
    );
  }
}
