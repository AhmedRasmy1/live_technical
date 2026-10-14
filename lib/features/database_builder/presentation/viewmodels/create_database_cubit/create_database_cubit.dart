import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';

import '../../../../../core/common/api_result.dart';
import '../../../../../core/resources/app_constants.dart';
import '../../../../../core/utils/extract_error_message.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../hr/domain/entities/employee_entity.dart';
import '../../../../hr/domain/usecases/get_employees_use_case.dart';
import '../../../domain/entities/database_entity.dart';
import '../../../domain/entities/database_enums.dart';
import '../../../domain/usecases/create_database_use_case.dart';

part 'create_database_state.dart';

/// Holds the whole creation wizard (details -> members -> summary) so nothing
/// is lost when the user goes back and forth between the three screens.
@injectable
class CreateDatabaseCubit extends Cubit<CreateDatabaseState> {
  // Employees are read through the existing HR use case (no second query).
  final GetEmployeesUseCase _getEmployeesUseCase;
  final CreateDatabaseUseCase _createDatabaseUseCase;

  CreateDatabaseCubit(this._getEmployeesUseCase, this._createDatabaseUseCase)
    : super(const CreateDatabaseInitial(CreateDatabaseForm()));

  CreateDatabaseForm get form => state.form;

  // ---------------------------------------------------------------- validation

  String? validateTitle(String? value) => Validators.requiredField(value);

  String? validateDescription(String? value) =>
      Validators.requiredMaxLength(value, AppConstants.descriptionMaxLength);

  String? validateAccessType(AccessType? value) =>
      value == null ? Validators.requiredMessage : null;

  String? validatePermissions(DatabasePermission? value) =>
      value == null ? Validators.requiredMessage : null;

  String? validateStartDate(DateTime? value) =>
      value == null ? Validators.requiredMessage : null;

  /// Required, and strictly after the start date.
  String? validateEndDate(DateTime? value) =>
      Validators.endDateAfterStart(value, form.startDate);

  // ------------------------------------------------------------ step 1: details

  void setTitle(String value) => _emitForm(form.copyWith(title: value));

  void setTitleAr(String value) => _emitForm(form.copyWith(titleAr: value));

  void setDescription(String value) {
    _emitForm(form.copyWith(description: value));
  }

  void setDescriptionAr(String value) {
    _emitForm(form.copyWith(descriptionAr: value));
  }

  void setAccessType(AccessType value) {
    _emitForm(form.copyWith(accessType: value));
  }

  // ------------------------------------------------------------- step 2: members

  Future<void> getEmployees() async {
    emit(CreateDatabaseLoading(form, CreateDatabaseOperation.loadEmployees));
    final result = await _getEmployeesUseCase.getEmployees();
    switch (result) {
      case Success<List<EmployeeEntity>>():
        emit(
          CreateDatabaseSuccess(
            form.copyWith(employees: result.data),
            CreateDatabaseOutcome.employeesLoaded,
          ),
        );
        break;
      case Fail<List<EmployeeEntity>>():
        emit(
          CreateDatabaseFailure(
            form,
            extractErrorMessage(result.exception),
            CreateDatabaseOperation.loadEmployees,
          ),
        );
        break;
    }
  }

  void toggleEmployee(String employeeId) {
    final selected = List<String>.of(form.selectedEmployeeIds);
    if (!selected.remove(employeeId)) selected.add(employeeId);
    _emitForm(form.copyWith(selectedEmployeeIds: selected));
  }

  /// The red remove button on the summary screen.
  void removeEmployee(String employeeId) {
    _emitForm(
      form.copyWith(
        selectedEmployeeIds: form.selectedEmployeeIds
            .where((id) => id != employeeId)
            .toList(),
      ),
    );
  }

  void searchEmployees(String query) {
    _emitForm(form.copyWith(employeeQuery: query.trim()));
  }

  /// `null` shows employees from every department.
  void filterEmployeesByDepartment(String? department) {
    _emitForm(
      department == null
          ? form.copyWith(clearEmployeeDepartment: true)
          : form.copyWith(employeeDepartment: department),
    );
  }

  // ------------------------------------------------------------ step 3: summary

  void setPermissions(DatabasePermission value) {
    _emitForm(form.copyWith(permissions: value));
  }

  void setStartDate(DateTime value) =>
      _emitForm(form.copyWith(startDate: value));

  void setEndDate(DateTime value) => _emitForm(form.copyWith(endDate: value));

  // ------------------------------------------------------------------ navigation

  /// Details must be valid to leave step 1, and at least one member must be
  /// picked to leave step 2.
  bool get canGoNext => switch (form.step) {
    DatabaseWizardStep.details => form.isDetailsValid,
    DatabaseWizardStep.members => form.hasMembers,
    DatabaseWizardStep.summary => false,
  };

  /// Moves forward when [canGoNext]; otherwise does nothing.
  void nextStep() {
    if (!canGoNext) return;
    final next = switch (form.step) {
      DatabaseWizardStep.details => DatabaseWizardStep.members,
      _ => DatabaseWizardStep.summary,
    };
    _emitForm(form.copyWith(step: next));
  }

  void previousStep() {
    final previous = switch (form.step) {
      DatabaseWizardStep.summary => DatabaseWizardStep.members,
      _ => DatabaseWizardStep.details,
    };
    if (previous == form.step) return;
    _emitForm(form.copyWith(step: previous));
  }

  void _emitForm(CreateDatabaseForm newForm) {
    emit(CreateDatabaseSuccess(newForm, CreateDatabaseOutcome.formChanged));
  }

  // ------------------------------------------------------------------ submitting

  /// "Save For Later": stores what has been entered so far with the Draft
  /// status. Needs valid details, which the wizard guarantees at steps 2 and 3.
  Future<void> saveDraft() async {
    if (!form.isDetailsValid) return;
    await _save(
      status: DatabaseStatus.draft,
      operation: CreateDatabaseOperation.saveDraft,
      outcome: CreateDatabaseOutcome.draftSaved,
    );
  }

  /// "Grant Access": creates the database and its access list in one batch.
  /// The status follows the chosen access type. Ignored until the form is
  /// valid (the summary screen validates before calling).
  Future<void> createDatabase() async {
    if (!form.isDetailsValid || !form.isSummaryValid) return;
    await _save(
      status: form.accessType!.status,
      operation: CreateDatabaseOperation.createDatabase,
      outcome: CreateDatabaseOutcome.databaseCreated,
    );
  }

  Future<void> _save({
    required DatabaseStatus status,
    required CreateDatabaseOperation operation,
    required CreateDatabaseOutcome outcome,
  }) async {
    emit(CreateDatabaseLoading(form, operation));
    final database = DatabaseEntity(
      title: form.title.trim(),
      titleAr: form.titleAr.trim(),
      description: form.description.trim(),
      descriptionAr: form.descriptionAr.trim(),
      accessType: form.accessType!,
      permissions: form.permissions,
      startDate: form.startDate,
      endDate: form.endDate,
      status: status,
      assignedEmployeeIds: form.selectedEmployeeIds,
    );
    final result = await _createDatabaseUseCase.createDatabase(
      database,
      form.selectedEmployeeIds,
    );
    switch (result) {
      case Success<DatabaseEntity>():
        emit(CreateDatabaseSuccess(form, outcome, database: result.data));
        break;
      case Fail<DatabaseEntity>():
        emit(
          CreateDatabaseFailure(
            form,
            extractErrorMessage(result.exception),
            operation,
          ),
        );
        break;
    }
  }
}
