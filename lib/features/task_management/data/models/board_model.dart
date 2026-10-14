import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/board_entity.dart';

part 'board_model.g.dart';

@JsonSerializable()
class BoardModel {
  /// Firestore document id. It is not stored inside the document body.
  @JsonKey(includeToJson: false)
  String? id;
  String? boardName;
  String? boardNameAr;
  String? description;
  String? descriptionAr;
  @JsonKey(defaultValue: <String>[])
  List<String>? departments;
  @JsonKey(defaultValue: false)
  bool? isMessagingEnabled;
  @JsonKey(defaultValue: <String>[])
  List<String>? assignedEmployeeIds;

  BoardModel({
    this.id,
    this.boardName,
    this.boardNameAr,
    this.description,
    this.descriptionAr,
    this.departments,
    this.isMessagingEnabled,
    this.assignedEmployeeIds,
  });

  factory BoardModel.fromJson(Map<String, dynamic> json) =>
      _$BoardModelFromJson(json);

  Map<String, dynamic> toJson() => _$BoardModelToJson(this);

  factory BoardModel.fromEntity(BoardEntity entity) => BoardModel(
    id: entity.id,
    boardName: entity.boardName,
    boardNameAr: entity.boardNameAr,
    description: entity.description,
    descriptionAr: entity.descriptionAr,
    departments: entity.departments,
    isMessagingEnabled: entity.isMessagingEnabled,
    assignedEmployeeIds: entity.assignedEmployeeIds,
  );

  BoardEntity toEntity() => BoardEntity(
    id: id,
    boardName: boardName ?? '',
    boardNameAr: boardNameAr ?? '',
    description: description ?? '',
    descriptionAr: descriptionAr ?? '',
    departments: departments ?? const [],
    isMessagingEnabled: isMessagingEnabled ?? false,
    assignedEmployeeIds: assignedEmployeeIds ?? const [],
  );
}
