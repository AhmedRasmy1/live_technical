import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:live_technical/core/common/custom_exception.dart';
import 'package:live_technical/core/di/di.dart';
import 'package:live_technical/core/resources/app_constants.dart';
import 'package:live_technical/core/utils/validators.dart';
import 'package:live_technical/core/widgets/app_avatar.dart';
import 'package:live_technical/core/widgets/confirmation_dialog.dart';
import 'package:live_technical/core/widgets/filter_dropdown.dart';
import 'package:live_technical/core/widgets/success_dialog.dart';
import 'package:live_technical/core/widgets/warning_dialog.dart';
import 'package:live_technical/features/task_management/domain/entities/board_entity.dart';
import 'package:live_technical/features/task_management/presentation/views/create_board_view.dart';
import 'package:live_technical/features/task_management/presentation/widgets/department_chips.dart';
import 'package:live_technical/features/task_management/presentation/widgets/selectable_employee_card.dart';
import 'package:live_technical/features/task_management/presentation/widgets/selected_employee_avatars.dart';

import '../../test_support.dart';

void main() {
  late FakeBoardRepo repo;
  bool? popResult;

  setUp(() {
    repo = FakeBoardRepo(employees: boardEmployees());
    popResult = null;
    registerBoardDependencies(repo);
  });

  tearDown(() async => getIt.reset());

  /// Tall surface so the whole page is visible without scrolling.
  Future<void> pumpScreen(
    WidgetTester tester, {
    Size size = const Size(1200, 2400),
  }) async {
    tester.view.physicalSize = size;
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    // Drop any previous tree so the helper can be called more than once.
    await tester.pumpWidget(const SizedBox());
    await tester.pumpWidget(
      MaterialApp(
        home: Builder(
          builder: (context) => Scaffold(
            body: Center(
              child: ElevatedButton(
                onPressed: () async {
                  popResult = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(builder: (_) => const CreateBoardView()),
                  );
                },
                child: const Text('go'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('go'));
    await tester.pumpAndSettle();
  }

  Finder field(int index) => find.byType(TextFormField).at(index);

  Future<void> enterName(WidgetTester tester, String name) async {
    await tester.enterText(field(0), name);
  }

  Future<void> tapCreate(WidgetTester tester) async {
    await tester.tap(find.text('Create'));
    await tester.pumpAndSettle();
  }

  Future<void> openDepartments(WidgetTester tester) async {
    await tester.tap(find.text('Choose Department'));
    await tester.pumpAndSettle();
  }

  Finder menuItem(String label) => find.widgetWithText(MenuItemButton, label);

  group('layout', () {
    testWidgets('renders every section of the design', (tester) async {
      await pumpScreen(tester);

      expect(find.text('Task Management'), findsOneWidget);
      expect(find.text('Creating New Board'), findsOneWidget);
      expect(find.byIcon(Icons.image_outlined), findsOneWidget);
      expect(find.text('Board Name'), findsOneWidget);
      expect(find.text('اسم لوحة'), findsOneWidget);
      expect(find.text('Description'), findsOneWidget);
      expect(find.text('وصف'), findsOneWidget);
      expect(
        find.text('0/${AppConstants.descriptionMaxLength}'),
        findsNWidgets(2),
      );
      // field label + the employee filter placeholder
      expect(find.text('Department'), findsNWidgets(2));
      expect(find.text('Choose Department'), findsOneWidget);
      expect(find.text('Creating Messaging Channels'), findsOneWidget);
      expect(find.byType(CupertinoSwitch), findsOneWidget);
      expect(find.text('Employee Information'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.text('Discard'), findsOneWidget);
      expect(find.text('Create'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('fetches employees from the repo and lists them', (
      tester,
    ) async {
      await pumpScreen(tester);

      expect(repo.employeeCalls, 1);
      expect(find.byType(SelectableEmployeeCard), findsNWidgets(4));
      expect(find.text('Amro Handousa'), findsOneWidget);
    });

    testWidgets('description counter follows the typed text', (tester) async {
      await pumpScreen(tester);

      await tester.enterText(field(2), 'hello');
      await tester.pump();

      expect(
        find.text('5/${AppConstants.descriptionMaxLength}'),
        findsOneWidget,
      );
    });

    testWidgets('employee grid uses 3 / 2 / 1 columns by width', (
      tester,
    ) async {
      Future<int> columnsAt(Size size) async {
        await pumpScreen(tester, size: size);
        final firstTop = tester
            .getTopLeft(find.byType(SelectableEmployeeCard).first)
            .dy;
        return find
            .byType(SelectableEmployeeCard)
            .evaluate()
            .map((e) => tester.getTopLeft(find.byWidget(e.widget)).dy)
            .where((dy) => dy == firstTop)
            .length;
      }

      expect(await columnsAt(const Size(1200, 2400)), 3);
      expect(await columnsAt(const Size(800, 2400)), 2);
      expect(await columnsAt(const Size(360, 3000)), 1);
    });

    testWidgets('name fields sit side by side on wide, stacked on phone', (
      tester,
    ) async {
      await pumpScreen(tester, size: const Size(1200, 2400));
      expect(tester.getTopLeft(field(0)).dy, tester.getTopLeft(field(1)).dy);

      await pumpScreen(tester, size: const Size(360, 3000));
      expect(
        tester.getTopLeft(field(1)).dy > tester.getTopLeft(field(0)).dy,
        isTrue,
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('does not overflow on a small phone', (tester) async {
      await pumpScreen(tester, size: const Size(320, 700));
      expect(tester.takeException(), isNull);
    });
  });

  group('departments, chips and messaging', () {
    testWidgets('menu shows All + options and keeps open while ticking', (
      tester,
    ) async {
      await pumpScreen(tester);
      await openDepartments(tester);

      for (final label in ['All', 'Finance', 'IT', 'HR', 'Design']) {
        expect(menuItem(label), findsOneWidget);
      }

      await tester.tap(menuItem('Finance'));
      await tester.pumpAndSettle();
      await tester.tap(menuItem('IT'));
      await tester.pumpAndSettle();

      // menu still open, two chips below
      expect(menuItem('HR'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(DepartmentChips),
          matching: find.byType(Chip),
        ),
        findsNWidgets(2),
      );
    });

    testWidgets('All selects every department, and again clears them', (
      tester,
    ) async {
      await pumpScreen(tester);
      await openDepartments(tester);

      await tester.tap(menuItem('All'));
      await tester.pumpAndSettle();
      expect(find.byType(Chip), findsNWidgets(4));

      await tester.tap(menuItem('All'));
      await tester.pumpAndSettle();
      expect(find.byType(Chip), findsNothing);
    });

    testWidgets('the red minus on a chip removes the department', (
      tester,
    ) async {
      await pumpScreen(tester);
      await openDepartments(tester);
      await tester.tap(menuItem('Finance'));
      await tester.pumpAndSettle();
      await tester.tap(menuItem('Design'));
      await tester.pumpAndSettle();
      // close the menu by tapping outside
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      expect(find.byType(Chip), findsNWidgets(2));

      await tester.tap(find.byTooltip('Remove Finance'));
      await tester.pumpAndSettle();

      expect(find.byType(Chip), findsOneWidget);
      expect(
        find.descendant(of: find.byType(Chip), matching: find.text('Design')),
        findsOneWidget,
      );
    });

    testWidgets('the messaging switch toggles', (tester) async {
      await pumpScreen(tester);
      expect(
        tester.widget<CupertinoSwitch>(find.byType(CupertinoSwitch)).value,
        isFalse,
      );

      await tester.tap(find.byType(CupertinoSwitch));
      await tester.pumpAndSettle();

      expect(
        tester.widget<CupertinoSwitch>(find.byType(CupertinoSwitch)).value,
        isTrue,
      );
    });
  });

  group('employee assignment', () {
    bool isChecked(WidgetTester tester, String name) {
      final card = find.ancestor(
        of: find.text(name),
        matching: find.byType(SelectableEmployeeCard),
      );
      return tester
          .widget<Checkbox>(
            find.descendant(of: card, matching: find.byType(Checkbox)),
          )
          .value!;
    }

    testWidgets('tapping a card selects it and shows its avatar', (
      tester,
    ) async {
      await pumpScreen(tester);
      expect(find.byType(SelectedEmployeeAvatars), findsNothing);

      await tester.tap(find.text('Sara Ahmed'));
      await tester.pumpAndSettle();

      expect(isChecked(tester, 'Sara Ahmed'), isTrue);
      expect(isChecked(tester, 'Amro Handousa'), isFalse);
      expect(
        find.descendant(
          of: find.byType(SelectedEmployeeAvatars),
          matching: find.byType(AppAvatar),
        ),
        findsOneWidget,
      );

      await tester.tap(find.text('Sara Ahmed'));
      await tester.pumpAndSettle();
      expect(isChecked(tester, 'Sara Ahmed'), isFalse);
      expect(find.byType(SelectedEmployeeAvatars), findsNothing);
    });

    testWidgets('tapping the checkbox selects too', (tester) async {
      await pumpScreen(tester);

      await tester.tap(find.byType(Checkbox).first);
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(SelectedEmployeeAvatars),
          matching: find.byType(AppAvatar),
        ),
        findsOneWidget,
      );
    });

    testWidgets('search narrows the grid and keeps the selection', (
      tester,
    ) async {
      await pumpScreen(tester);
      await tester.tap(find.text('Sara Ahmed'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextField).last, 'omar');
      await tester.pumpAndSettle();

      expect(find.byType(SelectableEmployeeCard), findsOneWidget);
      expect(find.text('Omar Khaled'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SelectedEmployeeAvatars),
          matching: find.byType(AppAvatar),
        ),
        findsOneWidget,
      );

      await tester.enterText(find.byType(TextField).last, 'zzz');
      await tester.pumpAndSettle();
      expect(find.text('No employees found'), findsOneWidget);
    });

    testWidgets('department filter lists real departments and filters', (
      tester,
    ) async {
      await pumpScreen(tester);

      await tester.tap(find.widgetWithText(FilterDropdown, 'Department'));
      await tester.pumpAndSettle();
      expect(find.text('All'), findsOneWidget);
      await tester.tap(find.text('Marketing').last);
      await tester.pumpAndSettle();

      expect(find.byType(SelectableEmployeeCard), findsNWidgets(2));
      expect(find.text('Sara Ahmed'), findsNothing);

      await tester.tap(find.widgetWithText(FilterDropdown, 'Marketing'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('All').last);
      await tester.pumpAndSettle();
      expect(find.byType(SelectableEmployeeCard), findsNWidgets(4));
    });

    testWidgets('shows the error with Retry when employees fail to load', (
      tester,
    ) async {
      repo.employeesError = FirestoreError('unavailable');
      await pumpScreen(tester);

      expect(find.text('unavailable'), findsOneWidget);

      repo.employeesError = null;
      await tester.tap(find.text('Retry'));
      await tester.pumpAndSettle();

      expect(find.byType(SelectableEmployeeCard), findsNWidgets(4));
    });
  });

  group('creating a board', () {
    testWidgets('empty name shows the required error and does nothing', (
      tester,
    ) async {
      await pumpScreen(tester);

      await tapCreate(tester);

      expect(find.text(Validators.requiredMessage), findsOneWidget);
      expect(repo.checkCalls, 0);
      expect(find.byType(ConfirmationDialog), findsNothing);
      expect(find.byType(WarningDialog), findsNothing);
    });

    testWidgets('an existing name shows the warning, not the confirmation', (
      tester,
    ) async {
      repo.boards.add(const BoardEntity(boardName: 'Marketing'));
      await pumpScreen(tester);
      await enterName(tester, 'Marketing');

      await tapCreate(tester);

      expect(repo.checkCalls, 1);
      expect(find.byType(WarningDialog), findsOneWidget);
      expect(find.text('Warning'), findsOneWidget);
      expect(
        find.text(
          'Marketing Already Exist As A Board Please Choose A Different Name',
        ),
        findsOneWidget,
      );
      expect(find.byType(ConfirmationDialog), findsNothing);
      expect(repo.createCalls, 0);
    });

    testWidgets('after the warning the user can fix the name and continue', (
      tester,
    ) async {
      repo.boards.add(const BoardEntity(boardName: 'Marketing'));
      await pumpScreen(tester);
      await enterName(tester, 'Marketing');
      await tapCreate(tester);

      await tester.tapAt(const Offset(5, 5)); // dismiss the warning
      await tester.pumpAndSettle();
      expect(find.byType(WarningDialog), findsNothing);

      await enterName(tester, 'Marketing 2');
      await tapCreate(tester);

      expect(find.byType(ConfirmationDialog), findsOneWidget);
    });

    testWidgets('an available name shows the confirmation dialog', (
      tester,
    ) async {
      await pumpScreen(tester);
      await enterName(tester, 'Marketing');

      await tapCreate(tester);

      expect(find.byType(ConfirmationDialog), findsOneWidget);
      expect(find.text('Creating Boards'), findsOneWidget);
      expect(
        find.text('Are You Sure You Want To Create This Board ?'),
        findsOneWidget,
      );
      expect(find.byType(WarningDialog), findsNothing);
    });

    testWidgets('No in the confirmation does not create the board', (
      tester,
    ) async {
      await pumpScreen(tester);
      await enterName(tester, 'Marketing');
      await tapCreate(tester);

      await tester.tap(find.text('No'));
      await tester.pumpAndSettle();

      expect(find.byType(ConfirmationDialog), findsNothing);
      expect(find.byType(CreateBoardView), findsOneWidget);
      expect(repo.createCalls, 0);
    });

    testWidgets('Yes creates the board with the whole form, then pops', (
      tester,
    ) async {
      repo.createGate = Completer<void>();
      await pumpScreen(tester);

      await enterName(tester, 'Marketing');
      await tester.enterText(field(1), 'تسويق');
      await tester.enterText(field(2), 'English description');
      await tester.enterText(field(3), 'وصف عربي');
      await openDepartments(tester);
      await tester.tap(menuItem('HR'));
      await tester.pumpAndSettle();
      await tester.tap(menuItem('Design'));
      await tester.pumpAndSettle();
      await tester.tapAt(const Offset(5, 5));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(CupertinoSwitch));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sara Ahmed'));
      await tester.tap(find.text('Omar Khaled'));
      await tester.pumpAndSettle();

      await tapCreate(tester);
      await tester.tap(find.text('Yes'));
      await tester.pump();

      expect(repo.createCalls, 1);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      repo.createGate!.complete();
      await tester.pumpAndSettle(const Duration(milliseconds: 100));

      expect(find.byType(SuccessDialog), findsOneWidget);
      expect(find.text('You Successfully Created This Board'), findsOneWidget);

      await tester.pump(AppConstants.successDialogDuration);
      await tester.pumpAndSettle();

      expect(find.byType(CreateBoardView), findsNothing);
      expect(popResult, true);

      final saved = repo.boards.single;
      expect(saved.boardName, 'Marketing');
      expect(saved.boardNameAr, 'تسويق');
      expect(saved.description, 'English description');
      expect(saved.descriptionAr, 'وصف عربي');
      expect(saved.departments, ['HR', 'Design']);
      expect(saved.isMessagingEnabled, isTrue);
      expect(saved.assignedEmployeeIds, ['e2', 'e4']);
    });

    testWidgets('a failure keeps the screen and shows the error', (
      tester,
    ) async {
      repo.createError = FirestoreError('permission-denied');
      await pumpScreen(tester);
      await enterName(tester, 'Marketing');
      await tapCreate(tester);

      await tester.tap(find.text('Yes'));
      await tester.pumpAndSettle();

      expect(find.text('permission-denied'), findsOneWidget);
      expect(find.byType(CreateBoardView), findsOneWidget);
      expect(find.byType(SuccessDialog), findsNothing);
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('a failed name check shows the error and no dialog', (
      tester,
    ) async {
      repo.checkError = NoInternetError();
      await pumpScreen(tester);
      await enterName(tester, 'Marketing');

      await tapCreate(tester);

      expect(find.text('please check internet connection'), findsOneWidget);
      expect(find.byType(ConfirmationDialog), findsNothing);
      expect(find.byType(WarningDialog), findsNothing);
    });

    testWidgets('Discard goes back without saving', (tester) async {
      await pumpScreen(tester);
      await enterName(tester, 'Marketing');

      await tester.tap(find.text('Discard'));
      await tester.pumpAndSettle();

      expect(find.byType(CreateBoardView), findsNothing);
      expect(popResult, isNull);
      expect(repo.createCalls, 0);
    });
  });
}
