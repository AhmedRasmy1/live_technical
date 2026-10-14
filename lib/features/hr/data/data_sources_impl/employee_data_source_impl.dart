import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/api/firestore_constants.dart';
import '../../../../core/common/api_result.dart';
import '../../../../core/common/custom_exception.dart';
import '../../domain/entities/employee_entity.dart';
import '../data_sources/employee_data_source.dart';
import '../models/employee_model.dart';

@Injectable(as: EmployeeDataSource)
class EmployeeDataSourceImpl implements EmployeeDataSource {
  CollectionReference<Map<String, dynamic>> get _employees =>
      FirebaseFirestore.instance.collection(FirestoreConstants.employees);

  @override
  Future<Result<EmployeeEntity>> addEmployee(EmployeeEntity employee) async {
    try {
      final model = EmployeeModel.fromEntity(employee);
      final reference = await _employees
          .add({
            ...model.toJson(),
            FirestoreConstants.createdAt: FieldValue.serverTimestamp(),
          })
          .timeout(FirestoreConstants.timeout);
      model.id = reference.id;
      return Success(model.toEntity());
    } on TimeoutException {
      return Fail(NoInternetError());
    } on FirebaseException catch (e) {
      return Fail(FirestoreError(e.message ?? e.code));
    } on Exception catch (e) {
      return Fail(e);
    }
  }

  @override
  Future<Result<List<EmployeeEntity>>> getEmployees() async {
    try {
      final snapshot = await _employees
          .orderBy(FirestoreConstants.createdAt, descending: true)
          .get()
          .timeout(FirestoreConstants.timeout);
      final employees = snapshot.docs
          .map(
            (doc) => EmployeeModel.fromJson({
              ...doc.data(),
              'id': doc.id,
            }).toEntity(),
          )
          .toList();
      return Success(employees);
    } on TimeoutException {
      return Fail(NoInternetError());
    } on FirebaseException catch (e) {
      return Fail(FirestoreError(e.message ?? e.code));
    } on Exception catch (e) {
      return Fail(e);
    }
  }
}
