import 'package:flutter_test/flutter_test.dart';
import 'package:live_technical/core/common/custom_exception.dart';
import 'package:live_technical/features/hr/domain/entities/employee_entity.dart';
import 'package:live_technical/features/hr/domain/usecases/add_employee_use_case.dart';
import 'package:live_technical/features/hr/presentation/viewmodels/add_employee_cubit/add_employee_cubit.dart';

import '../../test_support.dart';

void main() {
  const employee = EmployeeEntity(
    firstName: 'Amro',
    lastName: 'Handousa',
    department: 'Marketing',
    jobTitle: 'Manager',
  );

  late FakeEmployeeRepo repo;
  late AddEmployeeCubit cubit;

  setUp(() {
    repo = FakeEmployeeRepo();
    cubit = AddEmployeeCubit(AddEmployeeUseCase(repo));
  });

  tearDown(() => cubit.close());

  test('starts in Initial', () {
    expect(cubit.state, isA<AddEmployeeInitial>());
  });

  test('emits Loading then Success with the saved entity', () async {
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([isA<AddEmployeeLoading>(), isA<AddEmployeeSuccess>()]),
    );

    await cubit.addEmployee(employee);
    await expectation;

    final state = cubit.state as AddEmployeeSuccess;
    expect(state.employeeEntity.id, 'id-1');
    expect(state.employeeEntity.firstName, 'Amro');
    expect(repo.employees, hasLength(1));
  });

  test('emits Loading then Failure with an extracted message', () async {
    repo.addError = FirestoreError('permission-denied');
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([isA<AddEmployeeLoading>(), isA<AddEmployeeFailure>()]),
    );

    await cubit.addEmployee(employee);
    await expectation;

    expect((cubit.state as AddEmployeeFailure).error, 'permission-denied');
  });

  test('maps NoInternetError to the internet message', () async {
    repo.addError = NoInternetError();

    await cubit.addEmployee(employee);

    expect(
      (cubit.state as AddEmployeeFailure).error,
      'please check internet connection',
    );
  });
}
