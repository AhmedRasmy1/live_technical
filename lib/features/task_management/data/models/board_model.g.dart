// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'board_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

BoardModel _$BoardModelFromJson(Map<String, dynamic> json) => BoardModel(
  id: json['id'] as String?,
  boardName: json['boardName'] as String?,
  boardNameAr: json['boardNameAr'] as String?,
  description: json['description'] as String?,
  descriptionAr: json['descriptionAr'] as String?,
  departments:
      (json['departments'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
  isMessagingEnabled: json['isMessagingEnabled'] as bool? ?? false,
  assignedEmployeeIds:
      (json['assignedEmployeeIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
      [],
);

Map<String, dynamic> _$BoardModelToJson(BoardModel instance) =>
    <String, dynamic>{
      'boardName': instance.boardName,
      'boardNameAr': instance.boardNameAr,
      'description': instance.description,
      'descriptionAr': instance.descriptionAr,
      'departments': instance.departments,
      'isMessagingEnabled': instance.isMessagingEnabled,
      'assignedEmployeeIds': instance.assignedEmployeeIds,
    };
