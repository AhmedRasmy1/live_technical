import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_technical/features/database_builder/data/models/database_model.dart';
import 'package:live_technical/features/database_builder/domain/entities/database_entity.dart';
import 'package:live_technical/features/database_builder/domain/entities/database_enums.dart';

void main() {
  final start = DateTime(2024, 3, 1);
  final end = DateTime(2024, 6, 1);

  final entity = DatabaseEntity(
    id: 'db1',
    title: 'Sales',
    titleAr: 'مبيعات',
    description: 'desc',
    descriptionAr: 'وصف',
    tablesCount: 4,
    accessType: AccessType.personal,
    permissions: DatabasePermission.view,
    startDate: start,
    endDate: end,
    status: DatabaseStatus.personal,
    creationDate: DateTime(2024, 1, 1),
    lastEditDate: DateTime(2024, 1, 2),
    assignedEmployeeIds: const ['e1', 'e2'],
  );

  group('DatabaseModel', () {
    test('entity -> model -> entity keeps every field', () {
      final back = DatabaseModel.fromEntity(entity).toEntity();

      expect(back.id, 'db1');
      expect(back.title, 'Sales');
      expect(back.titleAr, 'مبيعات');
      expect(back.description, 'desc');
      expect(back.descriptionAr, 'وصف');
      expect(back.tablesCount, 4);
      expect(back.accessType, AccessType.personal);
      expect(back.permissions, DatabasePermission.view);
      expect(back.startDate, start);
      expect(back.endDate, end);
      expect(back.status, DatabaseStatus.personal);
      expect(back.creationDate, DateTime(2024, 1, 1));
      expect(back.lastEditDate, DateTime(2024, 1, 2));
      expect(back.assignedEmployeeIds, ['e1', 'e2']);
    });

    test('toJson stores enums by name and dates as Timestamps', () {
      final json = DatabaseModel.fromEntity(entity).toJson();

      expect(json['accessType'], 'personal');
      expect(json['status'], 'personal');
      expect(json['permissions'], 'view');
      expect(json['startDate'], Timestamp.fromDate(start));
      expect(json['endDate'], Timestamp.fromDate(end));
      expect(json['assignedEmployeeIds'], ['e1', 'e2']);
    });

    test('toJson leaves out the id and the server-managed dates', () {
      final json = DatabaseModel.fromEntity(entity).toJson();

      expect(json.containsKey('id'), isFalse);
      expect(json.containsKey('creationDate'), isFalse);
      expect(json.containsKey('lastEditDate'), isFalse);
    });

    test('toJson leaves out null optional fields', () {
      final json = DatabaseModel.fromEntity(
        const DatabaseEntity(
          title: 'Draft',
          accessType: AccessType.open,
          status: DatabaseStatus.draft,
        ),
      ).toJson();

      expect(json.containsKey('permissions'), isFalse);
      expect(json.containsKey('startDate'), isFalse);
      expect(json.containsKey('endDate'), isFalse);
      expect(json.containsKey('deletedDate'), isFalse);
    });

    test('fromJson reads Timestamps', () {
      final model = DatabaseModel.fromJson({
        'id': 'x',
        'title': 'T',
        'accessType': 'open',
        'status': 'open',
        'startDate': Timestamp.fromDate(start),
        'creationDate': Timestamp.fromDate(DateTime(2024, 1, 1)),
      });

      expect(model.id, 'x');
      expect(model.startDate, start);
      expect(model.creationDate, DateTime(2024, 1, 1));
    });

    test('a pending server timestamp (null) does not crash', () {
      final model = DatabaseModel.fromJson({
        'title': 'T',
        'accessType': 'open',
        'status': 'open',
        'creationDate': null,
      });

      expect(model.toEntity().creationDate, isNull);
    });

    test('missing fields get safe defaults', () {
      final database = DatabaseModel.fromJson({}).toEntity();

      expect(database.title, '');
      expect(database.description, '');
      expect(database.tablesCount, 0);
      expect(database.assignedEmployeeIds, isEmpty);
      expect(database.permissions, isNull);
      expect(database.accessType, AccessType.restricted);
      expect(database.status, DatabaseStatus.restricted);
    });

    test('a missing status follows the access type', () {
      final database = DatabaseModel.fromJson({
        'accessType': 'open',
      }).toEntity();

      expect(database.status, DatabaseStatus.open);
    });
  });

  group('enums', () {
    test('AccessType maps to the matching status', () {
      expect(AccessType.open.status, DatabaseStatus.open);
      expect(AccessType.restricted.status, DatabaseStatus.restricted);
      expect(AccessType.personal.status, DatabaseStatus.personal);
    });

    test('labels match the design', () {
      expect(AccessType.restricted.label, 'Restricted Access');
      expect(DatabasePermission.values.map((p) => p.label), [
        'Full Access',
        'Edit',
        'Export',
        'View',
      ]);
      expect(DatabaseStatus.values.map((s) => s.label), [
        'Open',
        'Restricted',
        'Personal',
        'Draft',
        'Deleted',
      ]);
    });

    test('fromName finds a value or returns null', () {
      expect(AccessType.fromName('open'), AccessType.open);
      expect(AccessType.fromName('nope'), isNull);
      expect(AccessType.fromName(null), isNull);
      expect(DatabaseStatus.fromName('draft'), DatabaseStatus.draft);
      expect(
        DatabasePermission.fromName('fullAccess'),
        DatabasePermission.fullAccess,
      );
    });

    test('isDraft / isDeleted follow the status', () {
      expect(entity.isDraft, isFalse);
      const draft = DatabaseEntity(
        title: 'd',
        accessType: AccessType.open,
        status: DatabaseStatus.draft,
      );
      expect(draft.isDraft, isTrue);
      expect(draft.isDeleted, isFalse);
    });
  });
}
