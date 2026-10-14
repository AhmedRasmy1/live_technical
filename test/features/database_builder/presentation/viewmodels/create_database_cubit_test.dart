import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:live_technical/core/common/custom_exception.dart';
import 'package:live_technical/core/resources/app_constants.dart';
import 'package:live_technical/core/utils/validators.dart';
import 'package:live_technical/features/database_builder/domain/entities/database_enums.dart';
import 'package:live_technical/features/database_builder/presentation/viewmodels/create_database_cubit/create_database_cubit.dart';

import '../../../hr/test_support.dart';
import '../../test_support.dart';

void main() {
  late FakeDatabaseRepo databaseRepo;
  late FakeEmployeeRepo employeeRepo;
  late CreateDatabaseCubit cubit;

  setUp(() {
    databaseRepo = FakeDatabaseRepo();
    employeeRepo = FakeEmployeeRepo(employees: wizardEmployees());
    cubit = buildCreateDatabaseCubit(databaseRepo, employeeRepo);
  });

  tearDown(() => cubit.close());

  /// Valid step 1.
  void fillDetails() {
    cubit.setTitle('Sales DB');
    cubit.setDescription('All the sales data');
    cubit.setAccessType(AccessType.restricted);
  }

  /// Valid step 1 + 2 people picked, standing on the summary.
  Future<void> reachSummary() async {
    fillDetails();
    await cubit.getEmployees();
    cubit.toggleEmployee('e1');
    cubit.toggleEmployee('e2');
    cubit.nextStep();
    cubit.nextStep();
  }

  void fillSummary() {
    cubit.setPermissions(DatabasePermission.edit);
    cubit.setStartDate(DateTime(2024, 3, 1));
    cubit.setEndDate(DateTime(2024, 6, 1));
  }

  group('step 1: details', () {
    test('starts on the details step with an empty form', () {
      expect(cubit.state, isA<CreateDatabaseInitial>());
      expect(cubit.form.step, DatabaseWizardStep.details);
      expect(cubit.form.title, '');
      expect(cubit.form.accessType, isNull);
      expect(cubit.form.isDetailsValid, isFalse);
    });

    test('keeps what the user types', () {
      cubit.setTitle('Sales');
      cubit.setTitleAr('مبيعات');
      cubit.setDescription('desc');
      cubit.setDescriptionAr('وصف');
      cubit.setAccessType(AccessType.personal);

      expect(cubit.form.title, 'Sales');
      expect(cubit.form.titleAr, 'مبيعات');
      expect(cubit.form.description, 'desc');
      expect(cubit.form.descriptionAr, 'وصف');
      expect(cubit.form.accessType, AccessType.personal);
      expect(cubit.state, isA<CreateDatabaseSuccess>());
    });

    test('the description counter follows the text', () {
      cubit.setDescription('hello');

      expect(cubit.form.descriptionLength, 5);
    });

    test('the title is required', () {
      expect(cubit.validateTitle(''), Validators.requiredMessage);
      expect(cubit.validateTitle('   '), Validators.requiredMessage);
      expect(cubit.validateTitle(null), Validators.requiredMessage);
      expect(cubit.validateTitle('Sales'), isNull);
    });

    test('the description is required and limited to 500 characters', () {
      expect(cubit.validateDescription(''), Validators.requiredMessage);
      expect(cubit.validateDescription('a' * 500), isNull);
      expect(
        cubit.validateDescription('a' * 501),
        'Maximum ${AppConstants.descriptionMaxLength} Characters',
      );
    });

    test('the access type is required', () {
      expect(cubit.validateAccessType(null), Validators.requiredMessage);
      expect(cubit.validateAccessType(AccessType.open), isNull);
    });

    test('details are valid only with title, description and access type', () {
      cubit.setTitle('Sales');
      expect(cubit.form.isDetailsValid, isFalse);
      cubit.setDescription('desc');
      expect(cubit.form.isDetailsValid, isFalse);
      cubit.setAccessType(AccessType.open);
      expect(cubit.form.isDetailsValid, isTrue);

      cubit.setDescription('a' * 501);
      expect(cubit.form.isDetailsValid, isFalse);
    });

    test('Next does nothing while the details are invalid', () {
      cubit.setTitle('Sales');

      expect(cubit.canGoNext, isFalse);
      cubit.nextStep();

      expect(cubit.form.step, DatabaseWizardStep.details);
    });

    test('Next goes to the members step once the details are valid', () {
      fillDetails();

      expect(cubit.canGoNext, isTrue);
      cubit.nextStep();

      expect(cubit.form.step, DatabaseWizardStep.members);
    });
  });

  group('step 2: members', () {
    setUp(() async {
      fillDetails();
      cubit.nextStep();
      await cubit.getEmployees();
    });

    test('getEmployees emits Loading then the fetched employees', () async {
      final fresh = buildCreateDatabaseCubit(databaseRepo, employeeRepo);
      final states = <CreateDatabaseState>[];
      final sub = fresh.stream.listen(states.add);

      await fresh.getEmployees();
      await Future<void>.delayed(Duration.zero);

      final loading = states[0] as CreateDatabaseLoading;
      expect(loading.operation, CreateDatabaseOperation.loadEmployees);
      final success = states[1] as CreateDatabaseSuccess;
      expect(success.outcome, CreateDatabaseOutcome.employeesLoaded);
      expect(success.form.employees, hasLength(4));
      await sub.cancel();
      await fresh.close();
    });

    test(
      'a failed fetch emits the readable error and keeps the form',
      () async {
        employeeRepo.getError = FirestoreError('unavailable');

        await cubit.getEmployees();

        final state = cubit.state as CreateDatabaseFailure;
        expect(state.error, 'unavailable');
        expect(state.operation, CreateDatabaseOperation.loadEmployees);
        expect(state.form.title, 'Sales DB');
        expect(state.form.step, DatabaseWizardStep.members);
      },
    );

    test('toggleEmployee selects and unselects, keeping the order', () {
      cubit.toggleEmployee('e3');
      cubit.toggleEmployee('e1');
      expect(cubit.form.selectedEmployeeIds, ['e3', 'e1']);
      expect(cubit.form.selectedEmployees.map((e) => e.id), ['e3', 'e1']);

      cubit.toggleEmployee('e3');
      expect(cubit.form.selectedEmployeeIds, ['e1']);
      expect(cubit.form.totalEmployees, 1);
    });

    test('search filters by name, ignoring case', () {
      cubit.searchEmployees('  OMAR ');

      expect(cubit.form.visibleEmployees.map((e) => e.id), ['e4']);

      cubit.searchEmployees('');
      expect(cubit.form.visibleEmployees, hasLength(4));
    });

    test('department filter and search work together', () {
      cubit.filterEmployeesByDepartment('Marketing');
      expect(cubit.form.visibleEmployees.map((e) => e.id), ['e1', 'e3']);

      cubit.searchEmployees('mona');
      expect(cubit.form.visibleEmployees.map((e) => e.id), ['e3']);

      cubit.filterEmployeesByDepartment(null);
      expect(cubit.form.employeeDepartment, isNull);
      expect(cubit.form.visibleEmployees.map((e) => e.id), ['e3']);
    });

    test('lists the real departments, sorted', () {
      expect(cubit.form.employeeDepartments, ['Design', 'HR', 'Marketing']);
    });

    test('the selection survives searching and filtering', () {
      cubit.toggleEmployee('e2');
      cubit.filterEmployeesByDepartment('Design');

      expect(cubit.form.selectedEmployeeIds, ['e2']);
      expect(cubit.form.visibleEmployees.map((e) => e.id), ['e4']);
    });

    test('Review needs at least one member', () {
      expect(cubit.form.hasMembers, isFalse);
      expect(cubit.canGoNext, isFalse);
      cubit.nextStep();
      expect(cubit.form.step, DatabaseWizardStep.members);

      cubit.toggleEmployee('e1');
      expect(cubit.canGoNext, isTrue);
      cubit.nextStep();
      expect(cubit.form.step, DatabaseWizardStep.summary);
    });
  });

  group('step 3: summary', () {
    setUp(() async => reachSummary());

    test('shows the totals and keeps the earlier steps', () {
      expect(cubit.form.step, DatabaseWizardStep.summary);
      expect(cubit.form.totalEmployees, 2);
      expect(cubit.form.accessType, AccessType.restricted);
      expect(cubit.form.title, 'Sales DB');
    });

    test('there is no step after the summary', () {
      expect(cubit.canGoNext, isFalse);
      cubit.nextStep();

      expect(cubit.form.step, DatabaseWizardStep.summary);
    });

    test('removeEmployee removes only that employee', () {
      cubit.removeEmployee('e1');

      expect(cubit.form.selectedEmployeeIds, ['e2']);
      expect(cubit.form.totalEmployees, 1);
    });

    test('removing the last employee makes the summary invalid', () {
      fillSummary();
      expect(cubit.form.isSummaryValid, isTrue);

      cubit.removeEmployee('e1');
      cubit.removeEmployee('e2');

      expect(cubit.form.isSummaryValid, isFalse);
    });

    test('permissions and start date are required', () {
      expect(cubit.validatePermissions(null), Validators.requiredMessage);
      expect(cubit.validatePermissions(DatabasePermission.view), isNull);
      expect(cubit.validateStartDate(null), Validators.requiredMessage);
      expect(cubit.validateStartDate(DateTime(2024, 1, 1)), isNull);
    });

    test('the end date is required', () {
      expect(cubit.validateEndDate(null), Validators.requiredMessage);
    });

    test('the end date must be after the start date', () {
      cubit.setStartDate(DateTime(2024, 3, 1));

      expect(
        cubit.validateEndDate(DateTime(2024, 2, 1)),
        Validators.endBeforeStartMessage,
      );
      expect(
        cubit.validateEndDate(DateTime(2024, 3, 1)),
        Validators.endBeforeStartMessage,
      );
      expect(cubit.validateEndDate(DateTime(2024, 3, 2)), isNull);
    });

    test('moving the start date past the end date invalidates the summary', () {
      fillSummary();
      expect(cubit.form.isSummaryValid, isTrue);

      cubit.setStartDate(DateTime(2024, 7, 1));

      expect(cubit.form.isSummaryValid, isFalse);
      expect(
        cubit.validateEndDate(cubit.form.endDate),
        Validators.endBeforeStartMessage,
      );
    });

    test('the summary needs permissions and both dates', () {
      expect(cubit.form.isSummaryValid, isFalse);
      cubit.setPermissions(DatabasePermission.view);
      expect(cubit.form.isSummaryValid, isFalse);
      cubit.setStartDate(DateTime(2024, 3, 1));
      expect(cubit.form.isSummaryValid, isFalse);
      cubit.setEndDate(DateTime(2024, 4, 1));
      expect(cubit.form.isSummaryValid, isTrue);
    });
  });

  group('wizard navigation', () {
    test(
      'Back goes summary -> members -> details and keeps all data',
      () async {
        await reachSummary();
        fillSummary();

        cubit.previousStep();
        expect(cubit.form.step, DatabaseWizardStep.members);
        cubit.previousStep();
        expect(cubit.form.step, DatabaseWizardStep.details);
        cubit.previousStep();
        expect(cubit.form.step, DatabaseWizardStep.details);

        expect(cubit.form.title, 'Sales DB');
        expect(cubit.form.selectedEmployeeIds, ['e1', 'e2']);
        expect(cubit.form.permissions, DatabasePermission.edit);
        expect(cubit.form.endDate, DateTime(2024, 6, 1));
      },
    );

    test('going forward again restores the same state', () async {
      await reachSummary();
      cubit.previousStep();
      cubit.previousStep();

      cubit.nextStep();
      cubit.nextStep();

      expect(cubit.form.step, DatabaseWizardStep.summary);
      expect(cubit.form.selectedEmployeeIds, ['e1', 'e2']);
    });
  });

  group('Save For Later (draft)', () {
    test('saves a Draft with the details, even with no members', () async {
      fillDetails();

      await cubit.saveDraft();

      expect(databaseRepo.createCalls, 1);
      final saved = databaseRepo.lastDatabase!;
      expect(saved.status, DatabaseStatus.draft);
      expect(saved.title, 'Sales DB');
      expect(saved.description, 'All the sales data');
      expect(saved.accessType, AccessType.restricted);
      expect(databaseRepo.lastEmployeeIds, isEmpty);

      final state = cubit.state as CreateDatabaseSuccess;
      expect(state.outcome, CreateDatabaseOutcome.draftSaved);
      expect(state.database!.id, 'db-1');
      expect(databaseRepo.databases.single.isDraft, isTrue);
    });

    test('saves the members and whatever summary data exists so far', () async {
      await reachSummary();
      cubit.setPermissions(DatabasePermission.view);

      await cubit.saveDraft();

      final saved = databaseRepo.lastDatabase!;
      expect(saved.status, DatabaseStatus.draft);
      expect(saved.permissions, DatabasePermission.view);
      expect(saved.startDate, isNull);
      expect(databaseRepo.lastEmployeeIds, ['e1', 'e2']);
    });

    test('shows loading while saving', () async {
      fillDetails();
      databaseRepo.createGate = Completer<void>();

      final saving = cubit.saveDraft();
      await Future<void>.delayed(Duration.zero);

      final loading = cubit.state as CreateDatabaseLoading;
      expect(loading.operation, CreateDatabaseOperation.saveDraft);

      databaseRepo.createGate!.complete();
      await saving;
      expect(cubit.state, isA<CreateDatabaseSuccess>());
    });

    test('does nothing while the details are invalid', () async {
      cubit.setTitle('only a title');

      await cubit.saveDraft();

      expect(databaseRepo.createCalls, 0);
    });

    test('a failure emits the error and keeps the whole form', () async {
      await reachSummary();
      databaseRepo.createError = FirestoreError('permission-denied');

      await cubit.saveDraft();

      final state = cubit.state as CreateDatabaseFailure;
      expect(state.error, 'permission-denied');
      expect(state.operation, CreateDatabaseOperation.saveDraft);
      expect(state.form.selectedEmployeeIds, ['e1', 'e2']);
      expect(state.form.step, DatabaseWizardStep.summary);
    });
  });

  group('Grant Access (create database)', () {
    setUp(() async {
      await reachSummary();
      fillSummary();
    });

    test('creates the database with the access list in one call', () async {
      await cubit.createDatabase();

      expect(databaseRepo.createCalls, 1);
      final saved = databaseRepo.lastDatabase!;
      expect(saved.title, 'Sales DB');
      expect(saved.description, 'All the sales data');
      expect(saved.accessType, AccessType.restricted);
      expect(saved.permissions, DatabasePermission.edit);
      expect(saved.startDate, DateTime(2024, 3, 1));
      expect(saved.endDate, DateTime(2024, 6, 1));
      expect(saved.assignedEmployeeIds, ['e1', 'e2']);
      expect(databaseRepo.lastEmployeeIds, ['e1', 'e2']);
    });

    test('the status follows the access type', () async {
      for (final type in AccessType.values) {
        cubit.setAccessType(type);

        await cubit.createDatabase();

        expect(databaseRepo.lastDatabase!.status, type.status);
      }
      expect(databaseRepo.createCalls, 3);
    });

    test(
      'emits Loading then Success(databaseCreated) with the new database',
      () async {
        final states = <CreateDatabaseState>[];
        final sub = cubit.stream.listen(states.add);

        await cubit.createDatabase();
        await Future<void>.delayed(Duration.zero);

        final loading = states[0] as CreateDatabaseLoading;
        expect(loading.operation, CreateDatabaseOperation.createDatabase);
        final success = states[1] as CreateDatabaseSuccess;
        expect(success.outcome, CreateDatabaseOutcome.databaseCreated);
        expect(success.database!.id, 'db-1');
        expect(success.database!.status, DatabaseStatus.restricted);
        await sub.cancel();
      },
    );

    test('trims the text', () async {
      cubit.setTitle('  Sales DB  ');
      cubit.setDescription('  text  ');

      await cubit.createDatabase();

      expect(databaseRepo.lastDatabase!.title, 'Sales DB');
      expect(databaseRepo.lastDatabase!.description, 'text');
    });

    test('a failure emits the error and keeps the form for a retry', () async {
      databaseRepo.createError = NoInternetError();

      await cubit.createDatabase();

      final state = cubit.state as CreateDatabaseFailure;
      expect(state.error, 'please check internet connection');
      expect(state.operation, CreateDatabaseOperation.createDatabase);
      expect(state.form.selectedEmployeeIds, ['e1', 'e2']);

      databaseRepo.createError = null;
      await cubit.createDatabase();
      expect(
        (cubit.state as CreateDatabaseSuccess).outcome,
        CreateDatabaseOutcome.databaseCreated,
      );
    });

    test('is ignored when the end date is not after the start date', () async {
      cubit.setEndDate(DateTime(2024, 3, 1));

      await cubit.createDatabase();

      expect(databaseRepo.createCalls, 0);
    });

    test('is ignored when permissions are missing', () async {
      final fresh = buildCreateDatabaseCubit(databaseRepo, employeeRepo);
      fresh.setTitle('t');
      fresh.setDescription('d');
      fresh.setAccessType(AccessType.open);

      await fresh.createDatabase();

      expect(databaseRepo.createCalls, 0);
      await fresh.close();
    });

    test('is ignored when no member is left', () async {
      cubit.removeEmployee('e1');
      cubit.removeEmployee('e2');

      await cubit.createDatabase();

      expect(databaseRepo.createCalls, 0);
    });
  });
}
