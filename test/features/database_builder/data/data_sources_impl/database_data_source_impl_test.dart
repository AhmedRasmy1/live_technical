import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_technical/core/api/firestore_constants.dart';
import 'package:live_technical/core/common/api_result.dart';
import 'package:live_technical/core/common/custom_exception.dart';
import 'package:live_technical/features/database_builder/data/data_sources_impl/database_data_source_impl.dart';
import 'package:live_technical/features/database_builder/domain/entities/database_entity.dart';
import 'package:live_technical/features/database_builder/domain/entities/database_enums.dart';

/// Fake Firestore that records how writes are committed.
class _ProbeFirestore extends FakeFirebaseFirestore {
  int batchCount = 0;
  int commitCount = 0;

  /// Number of stored documents (databases + access) right before commit.
  int? documentsBeforeCommit;
  Object? commitError;

  Future<int> countDocuments() async {
    final databases = await collection(FirestoreConstants.databases).get();
    var total = databases.docs.length;
    for (final doc in databases.docs) {
      total += (await doc.reference.collection(FirestoreConstants.access).get())
          .docs
          .length;
    }
    return total;
  }

  @override
  WriteBatch batch() {
    batchCount++;
    return _ProbeBatch(this, super.batch());
  }
}

class _ProbeBatch implements WriteBatch {
  _ProbeBatch(this.firestore, this.inner);

  final _ProbeFirestore firestore;
  final WriteBatch inner;

  @override
  void set<T>(DocumentReference<T> document, T data, [SetOptions? options]) {
    inner.set(document, data, options);
  }

  @override
  Future<void> commit() async {
    firestore.commitCount++;
    firestore.documentsBeforeCommit = await firestore.countDocuments();
    final error = firestore.commitError;
    if (error != null) throw error;
    await inner.commit();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

DatabaseEntity _entity({
  String title = 'Sales DB',
  DatabaseStatus status = DatabaseStatus.restricted,
  DatabasePermission? permissions = DatabasePermission.edit,
  DateTime? start,
  DateTime? end,
  List<String> assigned = const [],
}) => DatabaseEntity(
  title: title,
  titleAr: 'قاعدة',
  description: 'All sales data',
  descriptionAr: 'بيانات',
  accessType: AccessType.restricted,
  status: status,
  permissions: permissions,
  startDate: start,
  endDate: end,
  assignedEmployeeIds: assigned,
);

void main() {
  late _ProbeFirestore firestore;
  late DatabaseDataSourceImpl dataSource;

  setUp(() {
    firestore = _ProbeFirestore();
    dataSource = DatabaseDataSourceImpl(firestore);
  });

  Future<Map<String, dynamic>> databaseDoc(String id) async =>
      (await firestore.collection(FirestoreConstants.databases).doc(id).get())
          .data()!;

  Future<QuerySnapshot<Map<String, dynamic>>> accessDocs(String id) => firestore
      .collection(FirestoreConstants.databases)
      .doc(id)
      .collection(FirestoreConstants.access)
      .get();

  group('createDatabase (batch write)', () {
    test('stores the database document with every field', () async {
      final start = DateTime(2024, 3, 1);
      final end = DateTime(2024, 6, 1);

      final result = await dataSource.createDatabase(
        _entity(start: start, end: end),
        ['e1', 'e2'],
      );

      final created = (result as Success<DatabaseEntity>).data;
      final doc = await databaseDoc(created.id!);
      expect(doc['title'], 'Sales DB');
      expect(doc['titleAr'], 'قاعدة');
      expect(doc['description'], 'All sales data');
      expect(doc['descriptionAr'], 'بيانات');
      expect(doc['tablesCount'], 0);
      expect(doc['accessType'], 'restricted');
      expect(doc['status'], 'restricted');
      expect(doc['permissions'], 'edit');
      expect(doc['startDate'], Timestamp.fromDate(start));
      expect(doc['endDate'], Timestamp.fromDate(end));
      expect(doc['assignedEmployeeIds'], ['e1', 'e2']);
      // set by the server, not by the app
      expect(doc['creationDate'], isA<Timestamp>());
      expect(doc['lastEditDate'], isA<Timestamp>());
      // the id lives in the document path, not in the body
      expect(doc.containsKey('id'), isFalse);
    });

    test('stores one access document per employee', () async {
      final start = DateTime(2024, 3, 1);
      final end = DateTime(2024, 6, 1);

      final result = await dataSource.createDatabase(
        _entity(start: start, end: end),
        ['e1', 'e2', 'e3'],
      );

      final id = (result as Success<DatabaseEntity>).data.id!;
      final access = await accessDocs(id);
      expect(access.docs.map((d) => d.id), unorderedEquals(['e1', 'e2', 'e3']));
      final first = access.docs.firstWhere((d) => d.id == 'e1').data();
      expect(first['employeeId'], 'e1');
      expect(first['permissions'], 'edit');
      expect(first['startDate'], Timestamp.fromDate(start));
      expect(first['endDate'], Timestamp.fromDate(end));
      expect(first['grantedAt'], isA<Timestamp>());
    });

    test('writes the database and its access list in ONE batch', () async {
      await dataSource.createDatabase(_entity(), ['e1', 'e2']);

      expect(firestore.batchCount, 1);
      expect(firestore.commitCount, 1);
      // 1 database + 2 access documents became visible together, only after
      // the single commit (nothing was written beforehand).
      expect(firestore.documentsBeforeCommit, 0);
      expect(await firestore.countDocuments(), 3);
    });

    test('a failing commit stores nothing and returns a Fail', () async {
      firestore.commitError = FirebaseException(
        plugin: 'cloud_firestore',
        code: 'unavailable',
        message: 'Service is down',
      );

      final result = await dataSource.createDatabase(_entity(), ['e1', 'e2']);

      expect(result, isA<Fail<DatabaseEntity>>());
      final error = (result as Fail<DatabaseEntity>).exception;
      expect(error, isA<FirestoreError>());
      expect((error as FirestoreError).message, 'Service is down');
      expect(await firestore.countDocuments(), 0);
    });

    test('a non-Firebase failure is returned as a Fail too', () async {
      firestore.commitError = const FormatException('boom');

      final result = await dataSource.createDatabase(_entity(), ['e1']);

      expect(result, isA<Fail<DatabaseEntity>>());
      expect(await firestore.countDocuments(), 0);
    });

    test('returns the entity with the new id and the members', () async {
      final result = await dataSource.createDatabase(_entity(), ['e1', 'e2']);

      final created = (result as Success<DatabaseEntity>).data;
      expect(created.id, isNotEmpty);
      expect(created.title, 'Sales DB');
      expect(created.status, DatabaseStatus.restricted);
      expect(created.assignedEmployeeIds, ['e1', 'e2']);
    });

    test(
      'the employeeIds argument is the access list (duplicates dropped)',
      () async {
        final result = await dataSource.createDatabase(
          _entity(assigned: ['old']),
          ['e1', 'e2', 'e1'],
        );

        final id = (result as Success<DatabaseEntity>).data.id!;
        expect((await databaseDoc(id))['assignedEmployeeIds'], ['e1', 'e2']);
        expect((await accessDocs(id)).docs.length, 2);
      },
    );

    test('a draft can be saved with no members, permission or dates', () async {
      final result = await dataSource.createDatabase(
        _entity(status: DatabaseStatus.draft, permissions: null),
        [],
      );

      final id = (result as Success<DatabaseEntity>).data.id!;
      final doc = await databaseDoc(id);
      expect(doc['status'], 'draft');
      expect(doc['assignedEmployeeIds'], isEmpty);
      expect(doc.containsKey('permissions'), isFalse);
      expect(doc.containsKey('startDate'), isFalse);
      expect((await accessDocs(id)).docs, isEmpty);
      expect(firestore.batchCount, 1);
    });

    test(
      'accepts the maximum of 499 members (500 writes in the batch)',
      () async {
        final ids = List.generate(
          FirestoreConstants.maxDatabaseMembers,
          (i) => 'e$i',
        );

        final result = await dataSource.createDatabase(_entity(), ids);

        expect(result, isA<Success<DatabaseEntity>>());
        expect(
          await firestore.countDocuments(),
          FirestoreConstants.maxBatchWrites,
        );
      },
    );

    test('more than 499 members is rejected before any write', () async {
      final ids = List.generate(
        FirestoreConstants.maxDatabaseMembers + 1,
        (i) => 'e$i',
      );

      final result = await dataSource.createDatabase(_entity(), ids);

      expect(result, isA<Fail<DatabaseEntity>>());
      expect(
        ((result as Fail<DatabaseEntity>).exception as FirestoreError).message,
        contains('${FirestoreConstants.maxDatabaseMembers}'),
      );
      expect(firestore.batchCount, 0);
      expect(await firestore.countDocuments(), 0);
    });

    test('two databases do not mix their access lists', () async {
      final first = await dataSource.createDatabase(_entity(title: 'A'), [
        'e1',
      ]);
      final second = await dataSource.createDatabase(_entity(title: 'B'), [
        'e2',
        'e3',
      ]);

      final firstId = (first as Success<DatabaseEntity>).data.id!;
      final secondId = (second as Success<DatabaseEntity>).data.id!;
      expect(firstId, isNot(secondId));
      expect((await accessDocs(firstId)).docs.map((d) => d.id), ['e1']);
      expect(
        (await accessDocs(secondId)).docs.map((d) => d.id),
        unorderedEquals(['e2', 'e3']),
      );
    });
  });

  group('getDatabases', () {
    Future<void> seed(
      String id,
      String title, {
      required DateTime created,
      Map<String, dynamic> extra = const {},
    }) {
      return firestore.collection(FirestoreConstants.databases).doc(id).set({
        'title': title,
        'accessType': 'open',
        'status': 'open',
        'tablesCount': 3,
        'creationDate': Timestamp.fromDate(created),
        'assignedEmployeeIds': ['e1'],
        ...extra,
      });
    }

    test('returns an empty list when there are no databases', () async {
      final result = await dataSource.getDatabases();

      expect((result as Success<List<DatabaseEntity>>).data, isEmpty);
    });

    test('returns every database, newest first, with its id', () async {
      await seed('old', 'Old', created: DateTime(2023, 1, 1));
      await seed('new', 'New', created: DateTime(2024, 1, 1));
      await seed('mid', 'Mid', created: DateTime(2023, 6, 1));

      final result = await dataSource.getDatabases();

      final list = (result as Success<List<DatabaseEntity>>).data;
      expect(list.map((d) => d.id), ['new', 'mid', 'old']);
      expect(list.first.title, 'New');
      expect(list.first.tablesCount, 3);
      expect(list.first.creationDate, DateTime(2024, 1, 1));
      expect(list.first.assignedEmployeeIds, ['e1']);
    });

    test('maps status, permissions and dates', () async {
      await seed(
        'a',
        'A',
        created: DateTime(2024, 1, 1),
        extra: {
          'accessType': 'personal',
          'status': 'deleted',
          'permissions': 'export',
          'startDate': Timestamp.fromDate(DateTime(2024, 2, 1)),
          'endDate': Timestamp.fromDate(DateTime(2024, 3, 1)),
          'lastEditDate': Timestamp.fromDate(DateTime(2024, 1, 5)),
          'deletedDate': Timestamp.fromDate(DateTime(2024, 1, 9)),
        },
      );

      final result = await dataSource.getDatabases();

      final database = (result as Success<List<DatabaseEntity>>).data.single;
      expect(database.accessType, AccessType.personal);
      expect(database.status, DatabaseStatus.deleted);
      expect(database.permissions, DatabasePermission.export);
      expect(database.startDate, DateTime(2024, 2, 1));
      expect(database.endDate, DateTime(2024, 3, 1));
      expect(database.lastEditDate, DateTime(2024, 1, 5));
      expect(database.deletedDate, DateTime(2024, 1, 9));
    });

    test('unknown enum values do not crash the list', () async {
      await seed(
        'a',
        'A',
        created: DateTime(2024, 1, 1),
        extra: {'accessType': '???', 'status': '???', 'permissions': '???'},
      );

      final result = await dataSource.getDatabases();

      final database = (result as Success<List<DatabaseEntity>>).data.single;
      expect(database.accessType, AccessType.restricted);
      expect(database.status, DatabaseStatus.restricted);
      expect(database.permissions, isNull);
    });

    test('a database written by createDatabase can be read back', () async {
      await dataSource.createDatabase(_entity(title: 'Round trip'), ['e1']);

      final result = await dataSource.getDatabases();

      final list = (result as Success<List<DatabaseEntity>>).data;
      expect(list.single.title, 'Round trip');
      expect(list.single.creationDate, isNotNull);
      expect(list.single.lastEditDate, isNotNull);
    });
  });
}
