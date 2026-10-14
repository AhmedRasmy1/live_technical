import 'package:flutter_test/flutter_test.dart';
import 'package:live_technical/core/common/custom_exception.dart';
import 'package:live_technical/features/hr/domain/usecases/get_employees_use_case.dart';
import 'package:live_technical/features/hr/presentation/viewmodels/employee_list_cubit/employee_list_cubit.dart';

import '../../test_support.dart';

void main() {
  late FakeEmployeeRepo repo;
  late EmployeeListCubit cubit;

  setUp(() {
    repo = FakeEmployeeRepo(employees: sampleEmployees(3));
    cubit = EmployeeListCubit(GetEmployeesUseCase(repo));
  });

  tearDown(() => cubit.close());

  test('starts in Initial', () {
    expect(cubit.state, isA<EmployeeListInitial>());
  });

  test('emits Loading then Success with the employees', () async {
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([isA<EmployeeListLoading>(), isA<EmployeeListSuccess>()]),
    );

    await cubit.getEmployees();
    await expectation;

    expect((cubit.state as EmployeeListSuccess).employees, hasLength(3));
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
}
