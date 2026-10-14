import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_technical/core/common/custom_exception.dart';
import 'package:live_technical/core/di/di.dart';
import 'package:live_technical/core/theme/theme_manager.dart';
import 'package:live_technical/core/widgets/app_date_form_field.dart';
import 'package:live_technical/core/widgets/bilingual_info_fields.dart';
import 'package:live_technical/core/widgets/confirmation_dialog.dart';
import 'package:live_technical/core/widgets/filter_dropdown.dart';
import 'package:live_technical/core/widgets/loading_overlay.dart';
import 'package:live_technical/core/widgets/profile_image_picker.dart';
import 'package:live_technical/core/widgets/success_dialog.dart';
import 'package:live_technical/features/database_builder/domain/entities/database_enums.dart';
import 'package:live_technical/features/database_builder/presentation/views/create_database_view.dart';
import 'package:live_technical/features/database_builder/presentation/views/database_list_view.dart';
import 'package:live_technical/features/database_builder/presentation/widgets/database_card.dart';
import 'package:live_technical/features/database_builder/presentation/widgets/summary_employee_tile.dart';
import 'package:live_technical/features/database_builder/presentation/widgets/summary_info_card.dart';
import 'package:live_technical/features/hr/presentation/widgets/selectable_employee_card.dart';
import 'package:live_technical/features/hr/presentation/widgets/selected_employee_avatars.dart';

import '../../../../core/theme/theme_test_support.dart';
import '../../../hr/test_support.dart';
import '../../test_support.dart';

void main() {
  late FakeDatabaseRepo databaseRepo;
  late FakeEmployeeRepo employeeRepo;

  setUp(() async {
    databaseRepo = FakeDatabaseRepo(databases: sampleDatabases());
    employeeRepo = FakeEmployeeRepo(employees: wizardEmployees());
    registerDatabaseListDependencies(databaseRepo);
    registerCreateDatabaseDependencies(databaseRepo, employeeRepo);
    await registerThemeDependencies();
  });

  tearDown(() async => getIt.reset());

  /// Pushes the wizard on top of a home route so pops can be observed.
  /// [popResult] is filled when the wizard closes.
  Future<void> pumpWizard(
    WidgetTester tester, {
    Size size = const Size(1200, 900),
    ThemeData? theme,
    List<bool?>? popResult,
    double textScale = 1,
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(
      MaterialApp(
        theme: theme,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(textScale)),
          child: child!,
        ),
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: TextButton(
                onPressed: () async {
                  final result = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(
                      builder: (_) => const CreateDatabaseView(),
                    ),
                  );
                  popResult?.add(result);
                },
                child: const Text('open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
  }

  final accessDropdown = find.byType(DropdownButtonFormField<String>);

  Finder field(int index) => find.byType(TextFormField).at(index);

  Future<void> next(WidgetTester tester) async {
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
  }

  Future<void> pickAccess(WidgetTester tester, String label) async {
    await tester.ensureVisible(accessDropdown);
    await tester.pumpAndSettle();
    await tester.tap(accessDropdown);
    await tester.pumpAndSettle();
    await tester.tap(find.text(label).last);
    await tester.pumpAndSettle();
  }

  Future<void> fillDetails(
    WidgetTester tester, {
    String title = 'Sales Data',
    String description = 'All the sales',
  }) async {
    await tester.enterText(field(0), title);
    await tester.enterText(field(2), description);
    await pickAccess(tester, 'Restricted Access');
  }

  Future<void> goToMembers(WidgetTester tester) async {
    await fillDetails(tester);
    await next(tester);
  }

  Future<void> selectEmployee(WidgetTester tester, String name) async {
    await tester.tap(find.text(name));
    await tester.pumpAndSettle();
  }

  group('step 1 - details', () {
    testWidgets('renders every field and both buttons', (tester) async {
      await pumpWizard(tester);

      expect(find.byType(ProfileImagePicker), findsOneWidget);
      expect(find.text('Database Title'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('Access Management'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);
      expect(find.text('Next'), findsOneWidget);
      expect(find.text('Database Builder'), findsOneWidget);
      expect(find.text('Create Database'), findsOneWidget);
      expect(find.byType(BilingualInfoFields), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Next with empty fields shows the 3 required errors', (
      tester,
    ) async {
      await pumpWizard(tester);

      await next(tester);

      expect(find.text('This Field Is Required'), findsNWidgets(3));
      expect(find.text('Review'), findsNothing);
      expect(find.text('Next'), findsOneWidget);
    });

    testWidgets('description counter updates live and stops at 500', (
      tester,
    ) async {
      await pumpWizard(tester);
      expect(find.text('0/500'), findsWidgets);

      await tester.enterText(field(2), 'hello');
      await tester.pump();
      expect(find.text('5/500'), findsOneWidget);

      await tester.enterText(field(2), 'x' * 600);
      await tester.pump();
      expect(find.text('500/500'), findsOneWidget);
    });

    testWidgets('the access dropdown offers the three access types', (
      tester,
    ) async {
      await pumpWizard(tester);

      await tester.tap(accessDropdown);
      await tester.pumpAndSettle();

      for (final type in AccessType.values) {
        expect(find.text(type.label), findsOneWidget);
      }
    });

    testWidgets('missing access type alone blocks Next', (tester) async {
      await pumpWizard(tester);
      await tester.enterText(field(0), 'Sales Data');
      await tester.enterText(field(2), 'All the sales');

      await next(tester);

      expect(find.text('This Field Is Required'), findsOneWidget);
      expect(find.text('Review'), findsNothing);
    });

    testWidgets('valid details move to the members step', (tester) async {
      await pumpWizard(tester);

      await goToMembers(tester);

      expect(find.text('Review'), findsOneWidget);
      expect(find.text('Save For Later'), findsOneWidget);
      expect(find.text('Next'), findsNothing);
    });

    testWidgets('Discard closes the wizard without saving', (tester) async {
      final result = <bool?>[];
      await pumpWizard(tester, popResult: result);

      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      expect(find.byType(CreateDatabaseView), findsNothing);
      expect(result, [null]);
      expect(databaseRepo.createCalls, 0);
    });
  });

  group('step 2 - members', () {
    testWidgets('lists the real employees', (tester) async {
      await pumpWizard(tester);
      await goToMembers(tester);

      expect(employeeRepo.getCalls, 1);
      expect(find.byType(SelectableEmployeeCard), findsNWidgets(4));
      expect(find.text('Amro Handousa'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Department'), findsOneWidget);
      expect(find.byType(SelectedEmployeeAvatars), findsNothing);
    });

    testWidgets('selecting shows avatars on top and removing clears them', (
      tester,
    ) async {
      await pumpWizard(tester);
      await goToMembers(tester);

      await selectEmployee(tester, 'Amro Handousa');
      await selectEmployee(tester, 'Sara Ahmed');

      final avatars = tester.widget<SelectedEmployeeAvatars>(
        find.byType(SelectedEmployeeAvatars),
      );
      expect(avatars.employees.map((e) => e.id), ['e1', 'e2']);

      await tester.tap(find.byIcon(Icons.close).first);
      await tester.pumpAndSettle();
      final after = tester.widget<SelectedEmployeeAvatars>(
        find.byType(SelectedEmployeeAvatars),
      );
      expect(after.employees.map((e) => e.id), ['e2']);

      await selectEmployee(tester, 'Sara Ahmed');
      expect(find.byType(SelectedEmployeeAvatars), findsNothing);
    });

    testWidgets('search filters the grid', (tester) async {
      await pumpWizard(tester);
      await goToMembers(tester);

      await tester.enterText(find.byType(TextField).last, 'omar');
      await tester.pumpAndSettle();
      expect(find.byType(SelectableEmployeeCard), findsOneWidget);
      expect(find.text('Omar Khaled'), findsOneWidget);

      await tester.enterText(find.byType(TextField).last, 'zzz');
      await tester.pumpAndSettle();
      expect(find.text('No employees found'), findsOneWidget);
    });

    testWidgets('department filter narrows and resets', (tester) async {
      await pumpWizard(tester);
      await goToMembers(tester);

      await tester.tap(find.widgetWithText(FilterDropdown, 'Department'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Marketing').last);
      await tester.pumpAndSettle();
      expect(find.byType(SelectableEmployeeCard), findsNWidgets(2));

      await tester.tap(find.widgetWithText(FilterDropdown, 'Marketing'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All').last);
      await tester.pumpAndSettle();
      expect(find.byType(SelectableEmployeeCard), findsNWidgets(4));
    });

    testWidgets('selection survives filtering', (tester) async {
      await pumpWizard(tester);
      await goToMembers(tester);
      await selectEmployee(tester, 'Sara Ahmed');

      await tester.enterText(find.byType(TextField).last, 'omar');
      await tester.pumpAndSettle();

      final avatars = tester.widget<SelectedEmployeeAvatars>(
        find.byType(SelectedEmployeeAvatars),
      );
      expect(avatars.employees.map((e) => e.id), ['e2']);
    });

    testWidgets('Review without members stays and explains why', (
      tester,
    ) async {
      await pumpWizard(tester);
      await goToMembers(tester);

      await tester.tap(find.text('Review'));
      await tester.pumpAndSettle();

      expect(find.text('Please Select At Least One Employee'), findsOneWidget);
      expect(find.text('Review'), findsOneWidget);
    });

    testWidgets('Review with members moves to the summary step', (
      tester,
    ) async {
      await pumpWizard(tester);
      await goToMembers(tester);
      await selectEmployee(tester, 'Sara Ahmed');

      await tester.tap(find.text('Review'));
      await tester.pumpAndSettle();

      expect(find.text('Review'), findsNothing);
      expect(find.text('Grant Access'), findsOneWidget);
      expect(find.text('Selected Employees'), findsOneWidget);
    });

    testWidgets('shows the error with Retry when employees fail to load', (
      tester,
    ) async {
      employeeRepo.getError = FirestoreError('unavailable');
      await pumpWizard(tester);
      await goToMembers(tester);

      expect(find.text('unavailable'), findsOneWidget);

      employeeRepo.getError = null;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();
      expect(find.byType(SelectableEmployeeCard), findsNWidgets(4));
    });

    testWidgets('Save For Later stores a draft with the picked members', (
      tester,
    ) async {
      final result = <bool?>[];
      await pumpWizard(tester, popResult: result);
      await goToMembers(tester);
      await selectEmployee(tester, 'Sara Ahmed');
      await selectEmployee(tester, 'Omar Khaled');

      await tester.tap(find.text('Save For Later'));
      await tester.pump();
      await tester.pump();

      expect(find.byType(SuccessDialog), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(databaseRepo.createCalls, 1);
      expect(databaseRepo.lastDatabase!.status, DatabaseStatus.draft);
      expect(databaseRepo.lastDatabase!.title, 'Sales Data');
      expect(databaseRepo.lastDatabase!.accessType, AccessType.restricted);
      expect(databaseRepo.lastEmployeeIds, ['e2', 'e4']);
      expect(find.byType(CreateDatabaseView), findsNothing);
      expect(result, [true]);
    });

    testWidgets('Save For Later works with no members picked yet', (
      tester,
    ) async {
      final result = <bool?>[];
      await pumpWizard(tester, popResult: result);
      await goToMembers(tester);

      await tester.tap(find.text('Save For Later'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(databaseRepo.lastDatabase!.status, DatabaseStatus.draft);
      expect(databaseRepo.lastEmployeeIds, isEmpty);
      expect(result, [true]);
    });

    testWidgets('shows a loader while saving', (tester) async {
      databaseRepo.createGate = Completer<void>();
      await pumpWizard(tester);
      await goToMembers(tester);

      await tester.tap(find.text('Save For Later'));
      await tester.pump();

      expect(find.byType(LoadingOverlay), findsOneWidget);

      databaseRepo.createGate!.complete();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.byType(LoadingOverlay), findsNothing);
    });

    testWidgets('a failed save shows the error and keeps the wizard open', (
      tester,
    ) async {
      databaseRepo.createError = FirestoreError('quota exceeded');
      final result = <bool?>[];
      await pumpWizard(tester, popResult: result);
      await goToMembers(tester);

      await tester.tap(find.text('Save For Later'));
      await tester.pumpAndSettle();

      expect(find.text('quota exceeded'), findsOneWidget);
      expect(find.byType(CreateDatabaseView), findsOneWidget);
      expect(result, isEmpty);
    });
  });

  group('step 3 - summary', () {
    Future<void> goToSummary(WidgetTester tester) async {
      await goToMembers(tester);
      await selectEmployee(tester, 'Sara Ahmed');
      await selectEmployee(tester, 'Omar Khaled');
      await tester.ensureVisible(find.text('Review'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Review'));
      await tester.pumpAndSettle();
    }

    Finder dateField(int index) => find.descendant(
      of: find.byType(AppDateFormField).at(index),
      matching: find.byType(InkWell),
    );

    Future<void> pickDay(WidgetTester tester, int index, int day) async {
      await tester.ensureVisible(dateField(index));
      await tester.pumpAndSettle();
      await tester.tap(dateField(index));
      await tester.pumpAndSettle();
      await tester.tap(find.text('$day').last);
      await tester.pumpAndSettle();
      await tester.tap(find.text('OK'));
      await tester.pumpAndSettle();
    }

    Future<void> pickPermission(WidgetTester tester, String label) async {
      await tester.ensureVisible(accessDropdown);
      await tester.pumpAndSettle();
      await tester.tap(accessDropdown);
      await tester.pumpAndSettle();
      await tester.tap(find.text(label).last);
      await tester.pumpAndSettle();
    }

    Future<void> fillSummary(WidgetTester tester) async {
      await pickPermission(tester, 'Edit');
      await pickDay(tester, 0, 10);
      await pickDay(tester, 1, 20);
    }

    Future<void> grant(WidgetTester tester) async {
      await tester.ensureVisible(find.text('Grant Access'));
      await tester.tap(find.text('Grant Access'));
      await tester.pumpAndSettle();
    }

    testWidgets('shows the read-only cards, fields and chosen members', (
      tester,
    ) async {
      await pumpWizard(tester);
      await goToSummary(tester);

      expect(find.text('Total Employees'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SummaryInfoCard).first,
          matching: find.text('2'),
        ),
        findsOneWidget,
      );
      expect(find.text('Access Management'), findsOneWidget);
      expect(find.text('Restricted Access'), findsOneWidget);
      expect(find.text('Permissions'), findsOneWidget);
      expect(find.text('Start Date'), findsOneWidget);
      expect(find.text('End Date'), findsOneWidget);
      expect(find.text('Selected Employees'), findsOneWidget);
      expect(find.byType(SummaryEmployeeTile), findsNWidgets(2));
      expect(find.text('Sara Ahmed'), findsOneWidget);
      expect(find.text('Omar Khaled'), findsOneWidget);
      expect(find.text('Save For Later'), findsOneWidget);
      expect(find.text('Grant Access'), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('the permissions dropdown offers the four permissions', (
      tester,
    ) async {
      await pumpWizard(tester);
      await goToSummary(tester);

      await tester.tap(accessDropdown);
      await tester.pumpAndSettle();

      for (final permission in DatabasePermission.values) {
        expect(find.text(permission.label), findsOneWidget);
      }
    });

    testWidgets('remove buttons drop members and update the total', (
      tester,
    ) async {
      await pumpWizard(tester);
      await goToSummary(tester);

      await tester.tap(find.byTooltip('Remove Sara Ahmed'));
      await tester.pumpAndSettle();

      expect(find.byType(SummaryEmployeeTile), findsOneWidget);
      expect(find.text('Sara Ahmed'), findsNothing);
      expect(
        find.descendant(
          of: find.byType(SummaryInfoCard).first,
          matching: find.text('1'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('with no members left Grant Access is refused', (tester) async {
      await pumpWizard(tester);
      await goToSummary(tester);
      await fillSummary(tester);
      await tester.tap(find.byTooltip('Remove Sara Ahmed'));
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('Remove Omar Khaled'));
      await tester.pumpAndSettle();

      expect(find.text('No employees selected'), findsOneWidget);
      await grant(tester);

      expect(find.text('Please Select At Least One Employee'), findsOneWidget);
      expect(find.byType(ConfirmationDialog), findsNothing);
      expect(databaseRepo.createCalls, 0);
    });

    testWidgets('Grant Access with empty fields shows the 3 required errors', (
      tester,
    ) async {
      await pumpWizard(tester);
      await goToSummary(tester);

      await grant(tester);

      expect(find.text('This Field Is Required'), findsNWidgets(3));
      expect(find.byType(ConfirmationDialog), findsNothing);
      expect(databaseRepo.createCalls, 0);
    });

    testWidgets('an end date before the start date is rejected', (
      tester,
    ) async {
      await pumpWizard(tester);
      await goToSummary(tester);
      await pickPermission(tester, 'Edit');
      await pickDay(tester, 0, 20);
      await pickDay(tester, 1, 10);

      await grant(tester);

      expect(find.text('End Date Must Be After Start Date'), findsOneWidget);
      expect(find.byType(ConfirmationDialog), findsNothing);
      expect(databaseRepo.createCalls, 0);
    });

    testWidgets('the same day for start and end is rejected', (tester) async {
      await pumpWizard(tester);
      await goToSummary(tester);
      await pickPermission(tester, 'Edit');
      await pickDay(tester, 0, 15);
      await pickDay(tester, 1, 15);

      await grant(tester);

      expect(find.text('End Date Must Be After Start Date'), findsOneWidget);
    });

    testWidgets('moving the start date re-checks an already picked end date', (
      tester,
    ) async {
      await pumpWizard(tester);
      await goToSummary(tester);
      await pickDay(tester, 0, 10);
      await pickDay(tester, 1, 20);
      expect(find.text('End Date Must Be After Start Date'), findsNothing);

      await pickDay(tester, 0, 25);

      expect(find.text('End Date Must Be After Start Date'), findsOneWidget);

      await pickDay(tester, 0, 5);

      expect(find.text('End Date Must Be After Start Date'), findsNothing);
    });

    testWidgets('declining the confirmation saves nothing', (tester) async {
      await pumpWizard(tester);
      await goToSummary(tester);
      await fillSummary(tester);

      await grant(tester);
      expect(find.byType(ConfirmationDialog), findsOneWidget);
      expect(
        find.text('Are You Sure You Want To Create This Database?'),
        findsOneWidget,
      );
      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();

      expect(databaseRepo.createCalls, 0);
      expect(find.byType(CreateDatabaseView), findsOneWidget);
    });

    testWidgets('confirming writes the database, shows success and closes', (
      tester,
    ) async {
      final result = <bool?>[];
      await pumpWizard(tester, popResult: result);
      await goToSummary(tester);
      await fillSummary(tester);

      await grant(tester);
      await tester.tap(find.text('Yes'));
      await tester.pump();
      await tester.pump();

      expect(find.byType(SuccessDialog), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(databaseRepo.createCalls, 1);
      final saved = databaseRepo.lastDatabase!;
      expect(saved.title, 'Sales Data');
      expect(saved.status, DatabaseStatus.restricted);
      expect(saved.accessType, AccessType.restricted);
      expect(saved.permissions, DatabasePermission.edit);
      expect(saved.startDate!.day, 10);
      expect(saved.endDate!.day, 20);
      expect(databaseRepo.lastEmployeeIds, ['e2', 'e4']);
      expect(find.byType(CreateDatabaseView), findsNothing);
      expect(result, [true]);
    });

    testWidgets('removed members are not written', (tester) async {
      await pumpWizard(tester);
      await goToSummary(tester);
      await fillSummary(tester);
      await tester.tap(find.byTooltip('Remove Sara Ahmed'));
      await tester.pumpAndSettle();

      await grant(tester);
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(databaseRepo.lastEmployeeIds, ['e4']);
    });

    testWidgets('shows a loader while the batch is written', (tester) async {
      databaseRepo.createGate = Completer<void>();
      await pumpWizard(tester);
      await goToSummary(tester);
      await fillSummary(tester);

      await grant(tester);
      await tester.tap(find.text('Yes'));
      await tester.pump();

      expect(find.byType(LoadingOverlay), findsOneWidget);
      expect(find.byType(SuccessDialog), findsNothing);

      databaseRepo.createGate!.complete();
      await tester.pumpAndSettle(const Duration(seconds: 3));
      expect(find.byType(LoadingOverlay), findsNothing);
    });

    testWidgets('a failed write shows the error and keeps the wizard open', (
      tester,
    ) async {
      databaseRepo.createError = FirestoreError('quota exceeded');
      final result = <bool?>[];
      await pumpWizard(tester, popResult: result);
      await goToSummary(tester);
      await fillSummary(tester);

      await grant(tester);
      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      expect(find.text('quota exceeded'), findsOneWidget);
      expect(find.byType(SuccessDialog), findsNothing);
      expect(find.byType(CreateDatabaseView), findsOneWidget);
      expect(result, isEmpty);
    });

    testWidgets('Save For Later keeps what was filled in as a draft', (
      tester,
    ) async {
      final result = <bool?>[];
      await pumpWizard(tester, popResult: result);
      await goToSummary(tester);
      await pickPermission(tester, 'View');

      await tester.tap(find.text('Save For Later'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      final saved = databaseRepo.lastDatabase!;
      expect(saved.status, DatabaseStatus.draft);
      expect(saved.permissions, DatabasePermission.view);
      expect(saved.startDate, isNull);
      expect(databaseRepo.lastEmployeeIds, ['e2', 'e4']);
      expect(result, [true]);
    });

    testWidgets('the back arrow keeps the summary values', (tester) async {
      await pumpWizard(tester);
      await goToSummary(tester);
      await pickPermission(tester, 'Export');
      await pickDay(tester, 0, 12);

      await tester.tap(find.byTooltip('Back'));
      await tester.pumpAndSettle();
      expect(find.text('Review'), findsOneWidget);
      expect(find.byTooltip('Back'), findsOneWidget);

      await tester.tap(find.text('Review'));
      await tester.pumpAndSettle();

      expect(find.text('Export'), findsOneWidget);
      expect(find.textContaining('12 '), findsOneWidget);
    });

    testWidgets(
      'Create Database from the dashboard updates list and counters',
      (tester) async {
        tester.view.physicalSize = const Size(1200, 900);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.reset);
        await tester.pumpWidget(const MaterialApp(home: DatabaseListView()));
        await tester.pumpAndSettle();

        await tester.tap(find.text('Create Database'));
        await tester.pumpAndSettle();
        await goToSummary(tester);
        await fillSummary(tester);
        await grant(tester);
        await tester.tap(find.text('Yes'));
        await tester.pumpAndSettle(const Duration(seconds: 3));

        expect(find.byType(CreateDatabaseView), findsNothing);
        expect(databaseRepo.getCalls, 2);
        expect(find.byType(DatabaseCard), findsNWidgets(8));
        Finder counter(String tab, String count) => find.descendant(
          of: find.byKey(ValueKey('tab-$tab')),
          matching: find.text(count),
        );
        expect(counter('all', '8'), findsOneWidget);
        expect(counter('restricted', '2'), findsOneWidget);
        expect(counter('drafts', '1'), findsOneWidget);
      },
    );

    for (final size in const [
      Size(360, 640),
      Size(800, 600),
      Size(1440, 900),
    ]) {
      testWidgets('the summary fits at ${size.width.toInt()}px', (
        tester,
      ) async {
        await pumpWizard(tester, size: size);
        await goToSummary(tester);
        await fillSummary(tester);

        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('large text and dark theme do not overflow', (tester) async {
      await pumpWizard(
        tester,
        size: const Size(600, 800),
        textScale: 1.8,
        theme: ThemeManager.dark,
      );
      await goToSummary(tester);

      expect(find.byType(SummaryEmployeeTile), findsNWidgets(2));
      expect(tester.takeException(), isNull);
    });
  });

  group('navigation', () {
    testWidgets('system back returns to step 1 with the data kept', (
      tester,
    ) async {
      await pumpWizard(tester);
      await goToMembers(tester);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.text('Next'), findsOneWidget);
      expect(find.byType(CreateDatabaseView), findsOneWidget);
      expect(find.text('Sales Data'), findsOneWidget);
      expect(find.text('All the sales'), findsOneWidget);
      expect(find.text('Restricted Access'), findsOneWidget);
    });

    testWidgets('back on step 1 closes the wizard', (tester) async {
      await pumpWizard(tester);

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();

      expect(find.byType(CreateDatabaseView), findsNothing);
    });

    testWidgets('picked members survive going back and forward', (
      tester,
    ) async {
      await pumpWizard(tester);
      await goToMembers(tester);
      await selectEmployee(tester, 'Mona Adel');

      await tester.binding.handlePopRoute();
      await tester.pumpAndSettle();
      await next(tester);

      final avatars = tester.widget<SelectedEmployeeAvatars>(
        find.byType(SelectedEmployeeAvatars),
      );
      expect(avatars.employees.map((e) => e.id), ['e3']);
    });
  });

  group('from the dashboard', () {
    testWidgets('Create Database opens the wizard and a saved draft '
        'refreshes the list and counters', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: DatabaseListView()));
      await tester.pumpAndSettle();
      expect(databaseRepo.getCalls, 1);
      expect(find.byType(DatabaseCard), findsNWidgets(7));

      await tester.tap(find.text('Create Database'));
      await tester.pumpAndSettle();
      expect(find.byType(CreateDatabaseView), findsOneWidget);

      await fillDetails(tester);
      await next(tester);
      await tester.tap(find.text('Save For Later'));
      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.byType(CreateDatabaseView), findsNothing);
      expect(databaseRepo.getCalls, 2);
      expect(find.byType(DatabaseCard), findsNWidgets(8));
      expect(
        find.descendant(
          of: find.byKey(const ValueKey('tab-drafts')),
          matching: find.text('2'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('discarding does not reload the dashboard', (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.pumpWidget(const MaterialApp(home: DatabaseListView()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Create Database'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      expect(databaseRepo.getCalls, 1);
    });
  });

  group('responsive and theming', () {
    for (final size in const [
      Size(360, 640),
      Size(800, 600),
      Size(1440, 900),
    ]) {
      testWidgets('both steps fit at ${size.width.toInt()}px', (tester) async {
        await pumpWizard(tester, size: size);
        expect(tester.takeException(), isNull);

        await goToMembers(tester);
        await selectEmployee(tester, 'Sara Ahmed');
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('large text does not overflow', (tester) async {
      await pumpWizard(tester, size: const Size(600, 800), textScale: 1.8);
      expect(tester.takeException(), isNull);

      await goToMembers(tester);
      expect(tester.takeException(), isNull);
    });

    testWidgets('renders in the dark theme', (tester) async {
      await pumpWizard(tester, theme: ThemeManager.dark);
      expect(tester.takeException(), isNull);

      await goToMembers(tester);
      expect(find.byType(SelectableEmployeeCard), findsNWidgets(4));
      expect(tester.takeException(), isNull);
    });
  });
}
