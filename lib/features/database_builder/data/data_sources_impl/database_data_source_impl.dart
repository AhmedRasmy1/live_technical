import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/api/firestore_constants.dart';
import '../../../../core/common/api_result.dart';
import '../../../../core/common/custom_exception.dart';
import '../../../../core/utils/firestore_timestamp.dart';
import '../../domain/entities/database_entity.dart';
import '../data_sources/database_data_source.dart';
import '../models/database_model.dart';

@Injectable(as: DatabaseDataSource)
class DatabaseDataSourceImpl implements DatabaseDataSource {
  /// [firestore] is only passed in tests (fake Firestore). The app uses
  /// `FirebaseFirestore.instance`.
  DatabaseDataSourceImpl([@ignoreParam FirebaseFirestore? firestore])
    : _firestoreOverride = firestore;

  final FirebaseFirestore? _firestoreOverride;

  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _databases =>
      _firestore.collection(FirestoreConstants.databases);

  @override
  Future<Result<List<DatabaseEntity>>> getDatabases() {
    return _guard(() async {
      final snapshot = await _databases
          .orderBy(FirestoreConstants.creationDate, descending: true)
          .get();
      return snapshot.docs
          .map(
            (doc) => DatabaseModel.fromJson({
              ...doc.data(),
              'id': doc.id,
            }).toEntity(),
          )
          .toList();
    });
  }

  @override
  Future<Result<DatabaseEntity>> createDatabase(
    DatabaseEntity database,
    List<String> employeeIds,
  ) async {
    // [employeeIds] is the access list; duplicates are dropped, order is kept.
    final members = employeeIds.toSet().toList();
    if (members.length > FirestoreConstants.maxDatabaseMembers) {
      // One batch cannot hold more. Splitting it would break "all or nothing".
      return Fail(
        FirestoreError(
          'A database can have at most '
          '${FirestoreConstants.maxDatabaseMembers} members',
        ),
      );
    }

    return _guard(() async {
      final model = DatabaseModel.fromEntity(database)
        ..assignedEmployeeIds = members;
      final reference = _databases.doc();

      final batch = _firestore.batch();
      batch.set(reference, {
        ...model.toJson(),
        FirestoreConstants.creationDate: FieldValue.serverTimestamp(),
        FirestoreConstants.lastEditDate: FieldValue.serverTimestamp(),
      });
      for (final employeeId in members) {
        batch.set(
          reference.collection(FirestoreConstants.access).doc(employeeId),
          {
            FirestoreConstants.employeeId: employeeId,
            if (model.permissions != null)
              FirestoreConstants.permissions: model.permissions,
            if (model.startDate != null)
              FirestoreConstants.startDate: dateToFirestore(model.startDate),
            if (model.endDate != null)
              FirestoreConstants.endDate: dateToFirestore(model.endDate),
            FirestoreConstants.grantedAt: FieldValue.serverTimestamp(),
          },
        );
      }
      await batch.commit();

      model.id = reference.id;
      return model.toEntity();
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
