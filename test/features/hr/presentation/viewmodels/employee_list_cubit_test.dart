import 'package:flutter_test/flutter_test.dart';
import 'package:live_technical/core/common/custom_exception.dart';
import 'package:live_technical/features/hr/domain/entities/employee_entity.dart';
import 'package:live_technical/features/hr/domain/usecases/get_employees_use_case.dart';
import 'package:live_technical/features/hr/presentation/viewmodels/employee_list_cubit/employee_list_cubit.dart';

import '../../test_support.dart';

EmployeeEntity employee(
  String first,
  String last,
  String department,
  String jobTitle, {
  String middle = '',
}) => EmployeeEntity(
  firstName: first,
  middleName: middle,
  lastName: last,
  department: department,
  jobTitle: jobTitle,
);

void main() {
  late FakeEmployeeRepo repo;
  late EmployeeListCubit cubit;

  // 0 Amro Handousa (Marketing / Manager)
  // 1 Sara Ahmed (HR / Specialist)
  // 2 Omar Khaled Amro (Engineering / Developer)
  // 3 Mona Adel Hassan (Marketing / Designer)
  final data = [
    employee('Amro', 'Handousa', 'Marketing', 'Manager'),
    employee('Sara', 'Ahmed', 'HR', 'Specialist'),
    employee('Omar', 'Amro', 'Engineering', 'Developer', middle: 'Khaled'),
    employee('Mona', 'Hassan', 'Marketing', 'Designer', middle: 'Adel'),
  ];

  List<String> names() => (cubit.state as EmployeeListSuccess).employees
      .map((e) => e.firstName)
      .toList();

  setUp(() {
    repo = FakeEmployeeRepo(employees: List.of(data));
    cubit = EmployeeListCubit(GetEmployeesUseCase(repo));
  });

  tearDown(() => cubit.close());

  group('getEmployees', () {
    test('starts in Initial', () {
      expect(cubit.state, isA<EmployeeListInitial>());
    });

    test('emits Loading then Success and fills both lists', () async {
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([isA<EmployeeListLoading>(), isA<EmployeeListSuccess>()]),
      );

      await cubit.getEmployees();
      await expectation;

      expect(cubit.originalList, hasLength(4));
      expect(cubit.filteredList, hasLength(4));
      expect((cubit.state as EmployeeListSuccess).employees, hasLength(4));
    });

    test('emits Success with an empty list when there is no data', () async {
      repo.employees.clear();

      await cubit.getEmployees();

      expect((cubit.state as EmployeeListSuccess).employees, isEmpty);
    });

    test('emits Loading then Failure when the data source fails', () async {
      repo.getError = FirestoreError('unavailable');
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([isA<EmployeeListLoading>(), isA<EmployeeListFailure>()]),
      );

      await cubit.getEmployees();
      await expectation;

      expect((cubit.state as EmployeeListFailure).error, 'unavailable');
    });

    test('keeps the active search after a refresh', () async {
      await cubit.getEmployees();
      cubit.searchEmployees('sara');

      repo.employees.add(employee('Sarah', 'Younes', 'HR', 'Recruiter'));
      await cubit.getEmployees();

      expect(names(), ['Sara', 'Sarah']);
      expect(cubit.originalList, hasLength(5));
    });
  });

  group('searchEmployees', () {
    setUp(() async => cubit.getEmployees());

    test('matches first name, case-insensitive', () {
      cubit.searchEmployees('SARA');
      expect(names(), ['Sara']);
    });

    test('matches last name', () {
      cubit.searchEmployees('handousa');
      expect(names(), ['Amro']);
    });

    test('matches the full name, including the middle name', () {
      cubit.searchEmployees('omar khaled');
      expect(names(), ['Omar']);
    });

    test('matches partial text across first and last names', () {
      cubit.searchEmployees('amro');
      expect(names(), ['Amro', 'Omar']);
    });

    test('ignores surrounding spaces', () {
      cubit.searchEmployees('  sara  ');
      expect(names(), ['Sara']);
    });

    test('empty query shows everyone again', () {
      cubit.searchEmployees('sara');
      cubit.searchEmployees('');
      expect(names(), ['Amro', 'Sara', 'Omar', 'Mona']);
    });

    test('no match emits Success with an empty list', () {
      cubit.searchEmployees('zzz');
      expect(cubit.state, isA<EmployeeListSuccess>());
      expect(names(), isEmpty);
    });

    test('never changes originalList', () {
      cubit.searchEmployees('sara');
      expect(cubit.originalList, hasLength(4));
      expect(cubit.filteredList, hasLength(1));
    });

    test('emits a new Success state', () async {
      final expectation = expectLater(
        cubit.stream,
        emits(isA<EmployeeListSuccess>()),
      );
      cubit.searchEmployees('sara');
      await expectation;
    });

    test('is ignored while there is no data yet', () async {
      final fresh = EmployeeListCubit(GetEmployeesUseCase(repo));
      fresh.searchEmployees('sara');
      expect(fresh.state, isA<EmployeeListInitial>());
      await fresh.close();
    });
  });

  group('applyFilter', () {
    setUp(() async => cubit.getEmployees());

    test('filters by department', () {
      cubit.applyFilter(department: 'Marketing');
      expect(names(), ['Amro', 'Mona']);
    });

    test('filters by job title', () {
      cubit.applyFilter(jobTitle: 'Specialist');
      expect(names(), ['Sara']);
    });

    test('combines department and job title', () {
      cubit.applyFilter(department: 'Marketing', jobTitle: 'Designer');
      expect(names(), ['Mona']);
    });

    test('is case-insensitive', () {
      cubit.applyFilter(department: 'marketing');
      expect(names(), ['Amro', 'Mona']);
    });

    test('no match emits Success with an empty list', () {
      cubit.applyFilter(department: 'HR', jobTitle: 'Designer');
      expect(names(), isEmpty);
    });

    test('null values mean any', () {
      cubit.applyFilter(department: 'HR');
      cubit.applyFilter();
      expect(names(), hasLength(4));
    });

    test('works together with an active search', () {
      cubit.searchEmployees('a');
      cubit.applyFilter(department: 'Marketing');
      expect(names(), ['Amro', 'Mona']);

      cubit.searchEmployees('mona');
      expect(names(), ['Mona']);
    });

    test('exposes the selected values for the panel', () {
      cubit.applyFilter(department: 'HR', jobTitle: 'Specialist');
      expect(cubit.selectedDepartment, 'HR');
      expect(cubit.selectedJobTitle, 'Specialist');
    });

    test('never changes originalList', () {
      cubit.applyFilter(department: 'HR');
      expect(cubit.originalList, hasLength(4));
    });
  });

  group('resetFilter', () {
    setUp(() async => cubit.getEmployees());

    test('brings back the whole list', () {
      cubit.applyFilter(department: 'Marketing', jobTitle: 'Manager');
      expect(names(), ['Amro']);

      cubit.resetFilter();

      expect(names(), ['Amro', 'Sara', 'Omar', 'Mona']);
      expect(cubit.filteredList, cubit.originalList);
      expect(cubit.selectedDepartment, isNull);
      expect(cubit.selectedJobTitle, isNull);
    });

    test('keeps the search text applied', () {
      cubit.searchEmployees('sara');
      cubit.applyFilter(department: 'Marketing');
      expect(names(), isEmpty);

      cubit.resetFilter();

      expect(names(), ['Sara']);
    });

    test('emits Success', () async {
      cubit.applyFilter(department: 'HR');
      final expectation = expectLater(
        cubit.stream,
        emits(isA<EmployeeListSuccess>()),
      );
      cubit.resetFilter();
      await expectation;
    });
  });

  group('jobTitles', () {
    test('lists distinct, sorted job titles from the fetched data', () async {
      repo.employees.add(employee('Z', 'W', 'HR', 'Designer')); // duplicate
      repo.employees.add(employee('Q', 'R', 'HR', '  ')); // blank is ignored
      await cubit.getEmployees();

      expect(cubit.jobTitles, [
        'Designer',
        'Developer',
        'Manager',
        'Specialist',
      ]);
    });

    test('is empty before data is loaded', () {
      expect(cubit.jobTitles, isEmpty);
    });
  });
}
