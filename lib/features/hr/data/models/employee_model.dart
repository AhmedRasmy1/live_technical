import 'package:json_annotation/json_annotation.dart';

import '../../domain/entities/employee_entity.dart';

part 'employee_model.g.dart';

@JsonSerializable()
class EmployeeModel {
  /// Firestore document id. It is not stored inside the document body.
  @JsonKey(includeToJson: false)
  String? id;
  String? firstName;
  String? middleName;
  String? lastName;
  String? department;
  String? jobTitle;
  String? imageUrl;

  EmployeeModel({
    this.id,
    this.firstName,
    this.middleName,
    this.lastName,
    this.department,
    this.jobTitle,
    this.imageUrl,
  });

  factory EmployeeModel.fromJson(Map<String, dynamic> json) =>
      _$EmployeeModelFromJson(json);

  Map<String, dynamic> toJson() => _$EmployeeModelToJson(this);

  factory EmployeeModel.fromEntity(EmployeeEntity entity) => EmployeeModel(
    id: entity.id,
    firstName: entity.firstName,
    middleName: entity.middleName,
    lastName: entity.lastName,
    department: entity.department,
    jobTitle: entity.jobTitle,
    imageUrl: entity.imageUrl,
  );

  EmployeeEntity toEntity() => EmployeeEntity(
    id: id,
    firstName: firstName ?? '',
    middleName: middleName ?? '',
    lastName: lastName ?? '',
    department: department ?? '',
    jobTitle: jobTitle ?? '',
    imageUrl: imageUrl,
  );
}
