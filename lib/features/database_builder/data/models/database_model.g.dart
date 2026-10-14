// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

DatabaseModel _$DatabaseModelFromJson(Map<String, dynamic> json) =>
    DatabaseModel(
      id: json['id'] as String?,
      title: json['title'] as String?,
      titleAr: json['titleAr'] as String?,
      description: json['description'] as String?,
      descriptionAr: json['descriptionAr'] as String?,
      tablesCount: (json['tablesCount'] as num?)?.toInt(),
      accessType: json['accessType'] as String?,
      permissions: json['permissions'] as String?,
      startDate: dateFromFirestore(json['startDate']),
      endDate: dateFromFirestore(json['endDate']),
      status: json['status'] as String?,
      creationDate: dateFromFirestore(json['creationDate']),
      lastEditDate: dateFromFirestore(json['lastEditDate']),
      deletedDate: dateFromFirestore(json['deletedDate']),
      assignedEmployeeIds:
          (json['assignedEmployeeIds'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
    );

Map<String, dynamic> _$DatabaseModelToJson(DatabaseModel instance) =>
    <String, dynamic>{
      'title': ?instance.title,
      'titleAr': ?instance.titleAr,
      'description': ?instance.description,
      'descriptionAr': ?instance.descriptionAr,
      'tablesCount': ?instance.tablesCount,
      'accessType': ?instance.accessType,
      'permissions': ?instance.permissions,
      'startDate': ?dateToFirestore(instance.startDate),
      'endDate': ?dateToFirestore(instance.endDate),
      'status': ?instance.status,
      'deletedDate': ?dateToFirestore(instance.deletedDate),
      'assignedEmployeeIds': ?instance.assignedEmployeeIds,
    };
