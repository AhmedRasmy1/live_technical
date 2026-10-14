import 'package:flutter_test/flutter_test.dart';
import 'package:live_technical/features/task_management/data/models/board_model.dart';
import 'package:live_technical/features/task_management/domain/entities/board_entity.dart';

void main() {
  group('BoardModel', () {
    test('fromJson reads every field and the document id', () {
      final model = BoardModel.fromJson({
        'id': 'doc1',
        'boardName': 'Marketing',
        'boardNameAr': 'تسويق',
        'description': 'About',
        'descriptionAr': 'وصف',
        'departments': ['HR', 'IT'],
        'isMessagingEnabled': true,
        'assignedEmployeeIds': ['e1', 'e2'],
        'createdAt': 'ignored',
      });

      expect(model.id, 'doc1');
      expect(model.boardName, 'Marketing');
      expect(model.boardNameAr, 'تسويق');
      expect(model.description, 'About');
      expect(model.descriptionAr, 'وصف');
      expect(model.departments, ['HR', 'IT']);
      expect(model.isMessagingEnabled, isTrue);
      expect(model.assignedEmployeeIds, ['e1', 'e2']);
    });

    test('fromJson falls back to empty lists and false when missing', () {
      final model = BoardModel.fromJson({'boardName': 'Old board'});

      expect(model.departments, isEmpty);
      expect(model.assignedEmployeeIds, isEmpty);
      expect(model.isMessagingEnabled, isFalse);
    });

    test('toJson does not store the document id', () {
      final json = BoardModel(
        id: 'doc1',
        boardName: 'Marketing',
        departments: ['HR'],
        isMessagingEnabled: true,
        assignedEmployeeIds: ['e1'],
      ).toJson();

      expect(json.containsKey('id'), isFalse);
      expect(json['boardName'], 'Marketing');
      expect(json['departments'], ['HR']);
      expect(json['isMessagingEnabled'], true);
      expect(json['assignedEmployeeIds'], ['e1']);
    });

    test('toEntity defaults missing values', () {
      final entity = BoardModel(id: 'x', boardName: 'A').toEntity();

      expect(entity.id, 'x');
      expect(entity.boardName, 'A');
      expect(entity.description, '');
      expect(entity.departments, isEmpty);
      expect(entity.isMessagingEnabled, isFalse);
      expect(entity.assignedEmployeeIds, isEmpty);
    });

    test('fromEntity -> toEntity round trip keeps the data', () {
      const entity = BoardEntity(
        id: 'b1',
        boardName: 'Board',
        boardNameAr: 'لوحة',
        description: 'D',
        descriptionAr: 'و',
        departments: ['Finance'],
        isMessagingEnabled: true,
        assignedEmployeeIds: ['e9'],
      );

      final back = BoardModel.fromEntity(entity).toEntity();

      expect(back.id, entity.id);
      expect(back.boardName, entity.boardName);
      expect(back.boardNameAr, entity.boardNameAr);
      expect(back.description, entity.description);
      expect(back.descriptionAr, entity.descriptionAr);
      expect(back.departments, entity.departments);
      expect(back.isMessagingEnabled, entity.isMessagingEnabled);
      expect(back.assignedEmployeeIds, entity.assignedEmployeeIds);
    });
  });
}
