import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/api/firestore_constants.dart';
import '../../../../core/common/api_result.dart';
import '../../../../core/common/custom_exception.dart';
import '../../../hr/data/models/employee_model.dart';
import '../../../hr/domain/entities/employee_entity.dart';
import '../../domain/entities/board_entity.dart';
import '../data_sources/board_data_source.dart';
import '../models/board_model.dart';

@Injectable(as: BoardDataSource)
class BoardDataSourceImpl implements BoardDataSource {
  CollectionReference<Map<String, dynamic>> get _boards =>
      FirebaseFirestore.instance.collection(FirestoreConstants.boards);

  CollectionReference<Map<String, dynamic>> get _employees =>
      FirebaseFirestore.instance.collection(FirestoreConstants.employees);

  @override
  Future<Result<BoardEntity>> createBoard(BoardEntity board) {
    return _guard(() async {
      final model = BoardModel.fromEntity(board);
      final reference = await _boards.add({
        ...model.toJson(),
        FirestoreConstants.createdAt: FieldValue.serverTimestamp(),
      });
      model.id = reference.id;
      return model.toEntity();
    });
  }

  @override
  Future<Result<bool>> checkBoardExists(String boardName) {
    return _guard(() async {
      final snapshot = await _boards
          .where(FirestoreConstants.boardName, isEqualTo: boardName.trim())
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    });
  }

  @override
  Future<Result<List<EmployeeEntity>>> getEmployees() {
    return _guard(() async {
      final snapshot = await _employees
          .orderBy(FirestoreConstants.createdAt, descending: true)
          .get();
      return snapshot.docs
          .map(
            (doc) => EmployeeModel.fromJson({
              ...doc.data(),
              'id': doc.id,
            }).toEntity(),
          )
          .toList();
    });
  }

  /// Runs a Firestore call and maps every failure to a `Fail`.
  Future<Result<T>> _guard<T>(Future<T> Function() call) async {
    try {
      return Success(await call().timeout(FirestoreConstants.timeout));
    } on TimeoutException {
      return Fail(NoInternetError());
    } on FirebaseException catch (e) {
      return Fail(FirestoreError(e.message ?? e.code));
    } on Exception catch (e) {
      return Fail(e);
    }
  }
}
