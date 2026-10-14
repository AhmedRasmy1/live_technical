part of 'create_database_cubit.dart';

/// The three screens of the creation wizard.
enum DatabaseWizardStep { details, members, summary }

/// The async operation a [CreateDatabaseLoading] / [CreateDatabaseFailure]
/// refers to.
enum CreateDatabaseOperation { loadEmployees, saveDraft, createDatabase }

/// What a [CreateDatabaseSuccess] means.
enum CreateDatabaseOutcome {
  employeesLoaded,
  formChanged,
  draftSaved,
  databaseCreated,
}

/// Everything the user entered across the 3 steps. Every state carries it, so
/// going back and forward never loses data.
@immutable
class CreateDatabaseForm {
  final DatabaseWizardStep step;

  // Step 1 - details
  final String title;
  final String titleAr;
  final String description;
  final String descriptionAr;
  final AccessType? accessType;

  // Step 2 - members
  final List<EmployeeEntity> employees;
  final List<String> selectedEmployeeIds;
  final String employeeQuery;
  final String? employeeDepartment;

  // Step 3 - summary
  final DatabasePermission? permissions;
  final DateTime? startDate;
  final DateTime? endDate;

  const CreateDatabaseForm({
    this.step = DatabaseWizardStep.details,
    this.title = '',
    this.titleAr = '',
    this.description = '',
    this.descriptionAr = '',
    this.accessType,
    this.employees = const [],
    this.selectedEmployeeIds = const [],
    this.employeeQuery = '',
    this.employeeDepartment,
    this.permissions,
    this.startDate,
    this.endDate,
  });

  // ------------------------------------------------------------------ step 1

  /// For the live "n/500" counter.
  int get descriptionLength => description.length;

  bool get isDetailsValid =>
      Validators.requiredField(title) == null &&
      Validators.requiredMaxLength(
            description,
            AppConstants.descriptionMaxLength,
          ) ==
          null &&
      accessType != null;

  // ------------------------------------------------------------------ step 2

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

  bool get hasMembers => selectedEmployeeIds.isNotEmpty;

  /// "Total Employees" on the summary.
  int get totalEmployees => selectedEmployeeIds.length;

  // ------------------------------------------------------------------ step 3

  bool get isSummaryValid =>
      hasMembers &&
      permissions != null &&
      startDate != null &&
      Validators.endDateAfterStart(endDate, startDate) == null;

  CreateDatabaseForm copyWith({
    DatabaseWizardStep? step,
    String? title,
    String? titleAr,
    String? description,
    String? descriptionAr,
    AccessType? accessType,
    List<EmployeeEntity>? employees,
    List<String>? selectedEmployeeIds,
    String? employeeQuery,
    String? employeeDepartment,
    bool clearEmployeeDepartment = false,
    DatabasePermission? permissions,
    DateTime? startDate,
    DateTime? endDate,
  }) => CreateDatabaseForm(
    step: step ?? this.step,
    title: title ?? this.title,
    titleAr: titleAr ?? this.titleAr,
    description: description ?? this.description,
    descriptionAr: descriptionAr ?? this.descriptionAr,
    accessType: accessType ?? this.accessType,
    employees: employees ?? this.employees,
    selectedEmployeeIds: selectedEmployeeIds ?? this.selectedEmployeeIds,
    employeeQuery: employeeQuery ?? this.employeeQuery,
    employeeDepartment: clearEmployeeDepartment
        ? null
        : (employeeDepartment ?? this.employeeDepartment),
    permissions: permissions ?? this.permissions,
    startDate: startDate ?? this.startDate,
    endDate: endDate ?? this.endDate,
  );
}

@immutable
sealed class CreateDatabaseState {
  final CreateDatabaseForm form;
  const CreateDatabaseState(this.form);
}

final class CreateDatabaseInitial extends CreateDatabaseState {
  const CreateDatabaseInitial(super.form);
}

final class CreateDatabaseLoading extends CreateDatabaseState {
  final CreateDatabaseOperation operation;
  const CreateDatabaseLoading(super.form, this.operation);
}

final class CreateDatabaseSuccess extends CreateDatabaseState {
  final CreateDatabaseOutcome outcome;

  /// Only set for [CreateDatabaseOutcome.draftSaved] and
  /// [CreateDatabaseOutcome.databaseCreated].
  final DatabaseEntity? database;
  const CreateDatabaseSuccess(super.form, this.outcome, {this.database});
}

final class CreateDatabaseFailure extends CreateDatabaseState {
  final String error;
  final CreateDatabaseOperation operation;
  const CreateDatabaseFailure(super.form, this.error, this.operation);
}
