part of 'create_board_cubit.dart';

/// The async operation a [CreateBoardLoading] / [CreateBoardFailure] refers to.
enum BoardOperation { loadEmployees, checkName, createBoard }

/// What a [CreateBoardSuccess] means.
enum BoardOutcome {
  employeesLoaded,
  formChanged,
  nameAvailable,
  nameExists,
  boardCreated,
}

/// Everything the user has picked on the screen. Every state carries it so the
/// UI can always render from `state.form`.
@immutable
class CreateBoardForm {
  final List<EmployeeEntity> employees;
  final List<String> selectedEmployeeIds;
  final List<String> selectedDepartments;
  final bool isMessagingEnabled;
  final String employeeQuery;
  final String? employeeDepartment;

  const CreateBoardForm({
    this.employees = const [],
    this.selectedEmployeeIds = const [],
    this.selectedDepartments = const [],
    this.isMessagingEnabled = false,
    this.employeeQuery = '',
    this.employeeDepartment,
  });

  /// Employees matching the search text and the department filter.
  List<EmployeeEntity> get visibleEmployees {
    final query = employeeQuery.toLowerCase();
    return employees.where((employee) {
      final matchesQuery =
          query.isEmpty || employee.fullName.toLowerCase().contains(query);
      final matchesDepartment =
          employeeDepartment == null ||
          employee.department.trim().toLowerCase() ==
              employeeDepartment!.trim().toLowerCase();
      return matchesQuery && matchesDepartment;
    }).toList();
  }

  /// Selected employees, in the order they were picked.
  List<EmployeeEntity> get selectedEmployees => [
    for (final id in selectedEmployeeIds)
      ...employees.where((employee) => employee.id == id),
  ];

  /// Distinct departments found in the fetched employees (for the filter).
  List<String> get employeeDepartments {
    final departments = employees
        .map((employee) => employee.department.trim())
        .where((department) => department.isNotEmpty)
        .toSet()
        .toList();
    departments.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return departments;
  }

  CreateBoardForm copyWith({
    List<EmployeeEntity>? employees,
    List<String>? selectedEmployeeIds,
    List<String>? selectedDepartments,
    bool? isMessagingEnabled,
    String? employeeQuery,
    String? employeeDepartment,
    bool clearEmployeeDepartment = false,
  }) => CreateBoardForm(
    employees: employees ?? this.employees,
    selectedEmployeeIds: selectedEmployeeIds ?? this.selectedEmployeeIds,
    selectedDepartments: selectedDepartments ?? this.selectedDepartments,
    isMessagingEnabled: isMessagingEnabled ?? this.isMessagingEnabled,
    employeeQuery: employeeQuery ?? this.employeeQuery,
    employeeDepartment: clearEmployeeDepartment
        ? null
        : (employeeDepartment ?? this.employeeDepartment),
  );
}

@immutable
sealed class CreateBoardState {
  final CreateBoardForm form;
  const CreateBoardState(this.form);
}

final class CreateBoardInitial extends CreateBoardState {
  const CreateBoardInitial(super.form);
}

final class CreateBoardLoading extends CreateBoardState {
  final BoardOperation operation;
  const CreateBoardLoading(super.form, this.operation);
}

final class CreateBoardSuccess extends CreateBoardState {
  final BoardOutcome outcome;

  /// Only set when [outcome] is [BoardOutcome.boardCreated].
  final BoardEntity? boardEntity;
  const CreateBoardSuccess(super.form, this.outcome, {this.boardEntity});
}

final class CreateBoardFailure extends CreateBoardState {
  final String error;
  final BoardOperation operation;
  const CreateBoardFailure(super.form, this.error, this.operation);
}
