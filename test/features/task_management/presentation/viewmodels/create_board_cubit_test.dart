import 'package:flutter_test/flutter_test.dart';
import 'package:live_technical/core/common/custom_exception.dart';
import 'package:live_technical/core/utils/validators.dart';
import 'package:live_technical/features/task_management/domain/entities/board_entity.dart';
import 'package:live_technical/features/task_management/presentation/viewmodels/create_board_cubit/create_board_cubit.dart';

import '../../test_support.dart';

void main() {
  late FakeBoardRepo repo;
  late CreateBoardCubit cubit;

  setUp(() {
    repo = FakeBoardRepo(employees: boardEmployees());
    cubit = buildCreateBoardCubit(repo);
  });

  tearDown(() => cubit.close());

  Matcher loading(BoardOperation operation) => isA<CreateBoardLoading>().having(
    (s) => s.operation,
    'operation',
    operation,
  );

  Matcher success(BoardOutcome outcome) =>
      isA<CreateBoardSuccess>().having((s) => s.outcome, 'outcome', outcome);

  Matcher failure(BoardOperation operation) => isA<CreateBoardFailure>().having(
    (s) => s.operation,
    'operation',
    operation,
  );

  test('starts in Initial with an empty form', () {
    expect(cubit.state, isA<CreateBoardInitial>());
    expect(cubit.form.employees, isEmpty);
    expect(cubit.form.selectedEmployeeIds, isEmpty);
    expect(cubit.form.selectedDepartments, isEmpty);
    expect(cubit.form.isMessagingEnabled, isFalse);
  });

  group('validateBoardName', () {
    test('requires a value', () {
      expect(cubit.validateBoardName(null), Validators.requiredMessage);
      expect(cubit.validateBoardName('   '), Validators.requiredMessage);
      expect(cubit.validateBoardName('Marketing'), isNull);
    });
  });

  group('getEmployees', () {
    test('emits Loading then Success with the employees', () async {
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          loading(BoardOperation.loadEmployees),
          success(BoardOutcome.employeesLoaded),
        ]),
      );

      await cubit.getEmployees();
      await expectation;

      expect(cubit.form.employees, hasLength(4));
    });

    test('emits Failure with the extracted message', () async {
      repo.employeesError = FirestoreError('unavailable');
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          loading(BoardOperation.loadEmployees),
          failure(BoardOperation.loadEmployees),
        ]),
      );

      await cubit.getEmployees();
      await expectation;

      expect((cubit.state as CreateBoardFailure).error, 'unavailable');
    });
  });

  group('employee selection', () {
    setUp(() async => cubit.getEmployees());

    test('toggleEmployee selects and unselects, keeping pick order', () {
      cubit.toggleEmployee('e3');
      cubit.toggleEmployee('e1');
      expect(cubit.form.selectedEmployeeIds, ['e3', 'e1']);
      expect(cubit.form.selectedEmployees.map((e) => e.firstName), [
        'Mona',
        'Amro',
      ]);

      cubit.toggleEmployee('e3');
      expect(cubit.form.selectedEmployeeIds, ['e1']);
      expect(cubit.state, success(BoardOutcome.formChanged));
    });

    test('searchEmployees filters the visible employees by name', () {
      cubit.searchEmployees('  SARA ');
      expect(cubit.form.visibleEmployees.map((e) => e.firstName), ['Sara']);

      cubit.searchEmployees('');
      expect(cubit.form.visibleEmployees, hasLength(4));
    });

    test('filterEmployeesByDepartment filters and clears with null', () {
      cubit.filterEmployeesByDepartment('Marketing');
      expect(cubit.form.visibleEmployees.map((e) => e.firstName), [
        'Amro',
        'Mona',
      ]);

      cubit.filterEmployeesByDepartment(null);
      expect(cubit.form.visibleEmployees, hasLength(4));
      expect(cubit.form.employeeDepartment, isNull);
    });

    test('search and department filter combine', () {
      cubit.searchEmployees('mona');
      cubit.filterEmployeesByDepartment('HR');
      expect(cubit.form.visibleEmployees, isEmpty);
    });

    test('filtering never loses the selection', () {
      cubit.toggleEmployee('e2');
      cubit.filterEmployeesByDepartment('Marketing');
      expect(cubit.form.selectedEmployeeIds, ['e2']);
    });

    test('employeeDepartments lists distinct sorted departments', () {
      expect(cubit.form.employeeDepartments, ['Design', 'HR', 'Marketing']);
    });
  });

  group('departments and messaging', () {
    const options = ['Finance', 'IT', 'HR', 'Design'];

    test('toggleDepartment adds and removes', () {
      cubit.toggleDepartment('HR');
      cubit.toggleDepartment('IT');
      expect(cubit.form.selectedDepartments, ['HR', 'IT']);

      cubit.toggleDepartment('HR');
      expect(cubit.form.selectedDepartments, ['IT']);
    });

    test('toggleAllDepartments selects everything, then clears', () {
      cubit.toggleAllDepartments(options);
      expect(cubit.form.selectedDepartments, options);

      cubit.toggleAllDepartments(options);
      expect(cubit.form.selectedDepartments, isEmpty);
    });

    test('toggleAllDepartments completes a partial selection', () {
      cubit.toggleDepartment('HR');
      cubit.toggleAllDepartments(options);
      expect(cubit.form.selectedDepartments, hasLength(4));
    });

    test('removeDepartment drops one chip', () {
      cubit.toggleAllDepartments(options);
      cubit.removeDepartment('IT');
      expect(cubit.form.selectedDepartments, ['Finance', 'HR', 'Design']);
    });

    test('setMessagingEnabled updates the form', () {
      cubit.setMessagingEnabled(true);
      expect(cubit.form.isMessagingEnabled, isTrue);
      cubit.setMessagingEnabled(false);
      expect(cubit.form.isMessagingEnabled, isFalse);
    });
  });

  group('checkBoardName (duplicate name logic)', () {
    BoardEntity existing(String name) => BoardEntity(boardName: name);

    test('emits nameAvailable when no board has this name', () async {
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          loading(BoardOperation.checkName),
          success(BoardOutcome.nameAvailable),
        ]),
      );

      await cubit.checkBoardName('Marketing');
      await expectation;
    });

    test('emits nameExists when a board has exactly this name', () async {
      repo.boards.add(existing('Marketing'));
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          loading(BoardOperation.checkName),
          success(BoardOutcome.nameExists),
        ]),
      );

      await cubit.checkBoardName('Marketing');
      await expectation;
    });

    test('ignores surrounding spaces in the typed name', () async {
      repo.boards.add(existing('Marketing'));

      await cubit.checkBoardName('  Marketing  ');

      expect(cubit.state, success(BoardOutcome.nameExists));
    });

    test('is exact: a different name is available', () async {
      repo.boards.add(existing('Marketing'));

      await cubit.checkBoardName('Marketing 2');

      expect(cubit.state, success(BoardOutcome.nameAvailable));
    });

    test(
      'a board created through the cubit is then reported as taken',
      () async {
        await cubit.checkBoardName('Design');
        expect(cubit.state, success(BoardOutcome.nameAvailable));

        await cubit.createBoard(boardName: 'Design');
        await cubit.checkBoardName('Design');

        expect(cubit.state, success(BoardOutcome.nameExists));
      },
    );

    test('emits Failure when the lookup fails', () async {
      repo.checkError = NoInternetError();

      await cubit.checkBoardName('Marketing');

      expect(cubit.state, failure(BoardOperation.checkName));
      expect(
        (cubit.state as CreateBoardFailure).error,
        'please check internet connection',
      );
    });

    test('keeps the form untouched', () async {
      cubit.toggleDepartment('HR');

      await cubit.checkBoardName('Marketing');

      expect(cubit.form.selectedDepartments, ['HR']);
    });
  });

  group('createBoard', () {
    setUp(() async => cubit.getEmployees());

    test('saves the board with everything selected in the form', () async {
      cubit.toggleEmployee('e1');
      cubit.toggleEmployee('e4');
      cubit.toggleDepartment('HR');
      cubit.toggleDepartment('Design');
      cubit.setMessagingEnabled(true);

      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          loading(BoardOperation.createBoard),
          success(BoardOutcome.boardCreated),
        ]),
      );
      await cubit.createBoard(
        boardName: '  Marketing  ',
        boardNameAr: 'تسويق',
        description: ' About ',
        descriptionAr: 'وصف',
      );
      await expectation;

      final saved = repo.boards.single;
      expect(saved.boardName, 'Marketing');
      expect(saved.boardNameAr, 'تسويق');
      expect(saved.description, 'About');
      expect(saved.descriptionAr, 'وصف');
      expect(saved.departments, ['HR', 'Design']);
      expect(saved.isMessagingEnabled, isTrue);
      expect(saved.assignedEmployeeIds, ['e1', 'e4']);

      final state = cubit.state as CreateBoardSuccess;
      expect(state.boardEntity?.id, 'board-1');
    });

    test('defaults: no departments, no employees, messaging off', () async {
      await cubit.createBoard(boardName: 'Solo');

      final saved = repo.boards.single;
      expect(saved.departments, isEmpty);
      expect(saved.assignedEmployeeIds, isEmpty);
      expect(saved.isMessagingEnabled, isFalse);
    });

    test('emits Failure and saves nothing when Firestore fails', () async {
      repo.createError = FirestoreError('permission-denied');
      final expectation = expectLater(
        cubit.stream,
        emitsInOrder([
          loading(BoardOperation.createBoard),
          failure(BoardOperation.createBoard),
        ]),
      );

      await cubit.createBoard(boardName: 'Marketing');
      await expectation;

      expect((cubit.state as CreateBoardFailure).error, 'permission-denied');
      expect(repo.boards, isEmpty);
    });
  });
}
