import 'package:flutter_test/flutter_test.dart';
import 'package:live_technical/features/hr/data/models/employee_model.dart';
import 'package:live_technical/features/hr/domain/entities/employee_entity.dart';

void main() {
  group('EmployeeModel', () {
    test('fromJson reads every field including the document id', () {
      final model = EmployeeModel.fromJson({
        'id': 'doc1',
        'firstName': 'Amro',
        'middleName': 'M',
        'lastName': 'Handousa',
        'department': 'Marketing',
        'jobTitle': 'Manager',
        'imageUrl': 'http://img',
        'createdAt': 'ignored',
      });

      expect(model.id, 'doc1');
      expect(model.firstName, 'Amro');
      expect(model.middleName, 'M');
      expect(model.lastName, 'Handousa');
      expect(model.department, 'Marketing');
      expect(model.jobTitle, 'Manager');
      expect(model.imageUrl, 'http://img');
    });

    test('toJson does not store the document id', () {
      final json = EmployeeModel(
        id: 'doc1',
        firstName: 'Amro',
        lastName: 'Handousa',
      ).toJson();

      expect(json.containsKey('id'), isFalse);
      expect(json['firstName'], 'Amro');
      expect(json['lastName'], 'Handousa');
    });

    test('toEntity maps fields and defaults missing ones to empty', () {
      final entity = EmployeeModel(id: 'doc1', firstName: 'Amro').toEntity();

      expect(entity.id, 'doc1');
      expect(entity.firstName, 'Amro');
      expect(entity.middleName, '');
      expect(entity.lastName, '');
      expect(entity.department, '');
      expect(entity.jobTitle, '');
      expect(entity.imageUrl, isNull);
    });

    test('fromEntity -> toEntity round trip keeps the data', () {
      const entity = EmployeeEntity(
        id: 'x',
        firstName: 'A',
        middleName: 'B',
        lastName: 'C',
        department: 'D',
        jobTitle: 'E',
        imageUrl: 'F',
      );

      final back = EmployeeModel.fromEntity(entity).toEntity();

      expect(back.id, entity.id);
      expect(back.firstName, entity.firstName);
      expect(back.middleName, entity.middleName);
      expect(back.lastName, entity.lastName);
      expect(back.department, entity.department);
      expect(back.jobTitle, entity.jobTitle);
      expect(back.imageUrl, entity.imageUrl);
    });
  });

  group('EmployeeEntity.fullName', () {
    test('joins non-empty name parts', () {
      const entity = EmployeeEntity(
        firstName: 'Amro',
        middleName: '',
        lastName: 'Handousa',
        department: 'D',
        jobTitle: 'J',
      );
      expect(entity.fullName, 'Amro Handousa');
    });
  });
}
