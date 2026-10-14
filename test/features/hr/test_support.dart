import 'dart:async';

import 'package:live_technical/core/common/api_result.dart';
import 'package:live_technical/core/di/di.dart';
import 'package:live_technical/features/hr/domain/entities/employee_entity.dart';
import 'package:live_technical/features/hr/domain/repo/employee_repo.dart';
import 'package:live_technical/features/hr/domain/usecases/add_employee_use_case.dart';
import 'package:live_technical/features/hr/domain/usecases/get_employees_use_case.dart';
import 'package:live_technical/features/hr/presentation/viewmodels/add_employee_cubit/add_employee_cubit.dart';
import 'package:live_technical/features/hr/presentation/viewmodels/employee_list_cubit/employee_list_cubit.dart';

/// In-memory repo that behaves like Firestore for tests.
class FakeEmployeeRepo implements EmployeeRepo {
  FakeEmployeeRepo({List<EmployeeEntity>? employees})
    : employees = employees ?? [];

  final List<EmployeeEntity> employees;
  Exception? addError;
  Exception? getError;

  /// When set, `addEmployee` waits for it (to observe the loading state).
  Completer<void>? addGate;

  int addCalls = 0;
  int getCalls = 0;

  @override
  Future<Result<EmployeeEntity>> addEmployee(EmployeeEntity employee) async {
    addCalls++;
    if (addGate != null) await addGate!.future;
    final error = addError;
    if (error != null) return Fail(error);
    final saved = EmployeeEntity(
      id: 'id-$addCalls',
      firstName: employee.firstName,
      middleName: employee.middleName,
      lastName: employee.lastName,
      department: employee.department,
      jobTitle: employee.jobTitle,
      imageUrl: employee.imageUrl,
    );
    employees.insert(0, saved);
    return Success(saved);
  }

  @override
  Future<Result<List<EmployeeEntity>>> getEmployees() async {
    getCalls++;
    final error = getError;
    if (error != null) return Fail(error);
    return Success(List.of(employees));
  }
}

List<EmployeeEntity> sampleEmployees(int count) => List.generate(
  count,
  (i) => EmployeeEntity(
    id: 'e$i',
    firstName: 'First$i',
    middleName: 'Mid$i',
    lastName: 'Last$i',
    department: 'Dept$i',
    jobTitle: 'Job$i',
  ),
);

/// Registers the HR cubits on the shared `getIt` with a fake repo.
void registerHrDependencies(FakeEmployeeRepo repo) {
  getIt.registerFactory<EmployeeListCubit>(
    () => EmployeeListCubit(GetEmployeesUseCase(repo)),
  );
  getIt.registerFactory<AddEmployeeCubit>(
    () => AddEmployeeCubit(AddEmployeeUseCase(repo)),
  );
}
