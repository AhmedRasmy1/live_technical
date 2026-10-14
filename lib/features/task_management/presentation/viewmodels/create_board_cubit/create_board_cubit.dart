import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';

import '../../../../../core/common/api_result.dart';
import '../../../../../core/utils/extract_error_message.dart';
import '../../../../../core/utils/validators.dart';
import '../../../../hr/domain/entities/employee_entity.dart';
import '../../../domain/entities/board_entity.dart';
import '../../../domain/usecases/check_board_exists_use_case.dart';
import '../../../domain/usecases/create_board_use_case.dart';
import '../../../domain/usecases/get_board_employees_use_case.dart';

part 'create_board_state.dart';

@injectable
class CreateBoardCubit extends Cubit<CreateBoardState> {
  final GetBoardEmployeesUseCase _getBoardEmployeesUseCase;
  final CheckBoardExistsUseCase _checkBoardExistsUseCase;
  final CreateBoardUseCase _createBoardUseCase;

  CreateBoardCubit(
    this._getBoardEmployeesUseCase,
    this._checkBoardExistsUseCase,
    this._createBoardUseCase,
  ) : super(const CreateBoardInitial(CreateBoardForm()));

  CreateBoardForm get form => state.form;

  // ---------------------------------------------------------------- validation

  /// Validator for the Board Name field.
  String? validateBoardName(String? value) => Validators.requiredField(value);

  // ----------------------------------------------------------------- employees

  Future<void> getEmployees() async {
    emit(CreateBoardLoading(form, BoardOperation.loadEmployees));
    final result = await _getBoardEmployeesUseCase.getEmployees();
    switch (result) {
      case Success<List<EmployeeEntity>>():
        emit(
          CreateBoardSuccess(
            form.copyWith(employees: result.data),
            BoardOutcome.employeesLoaded,
          ),
        );
        break;
      case Fail<List<EmployeeEntity>>():
        emit(
          CreateBoardFailure(
            form,
            extractErrorMessage(result.exception),
            BoardOperation.loadEmployees,
          ),
        );
        break;
    }
  }

  // ----------------------------------------------------------------- selection

  void toggleEmployee(String employeeId) {
    final selected = List<String>.of(form.selectedEmployeeIds);
    if (!selected.remove(employeeId)) selected.add(employeeId);
    _emitForm(form.copyWith(selectedEmployeeIds: selected));
  }

  void toggleDepartment(String department) {
    final selected = List<String>.of(form.selectedDepartments);
    if (!selected.remove(department)) selected.add(department);
    _emitForm(form.copyWith(selectedDepartments: selected));
  }

  /// "All" checkbox: selects every option, or clears them when all are set.
  void toggleAllDepartments(List<String> options) {
    final allSelected = options.every(form.selectedDepartments.contains);
    _emitForm(
      form.copyWith(selectedDepartments: allSelected ? [] : List.of(options)),
    );
  }

  void removeDepartment(String department) {
    _emitForm(
      form.copyWith(
        selectedDepartments: form.selectedDepartments
            .where((selected) => selected != department)
            .toList(),
      ),
    );
  }

  void setMessagingEnabled(bool enabled) {
    _emitForm(form.copyWith(isMessagingEnabled: enabled));
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

  void _emitForm(CreateBoardForm newForm) {
    emit(CreateBoardSuccess(newForm, BoardOutcome.formChanged));
  }

  // ------------------------------------------------------------- create a board

  /// Asks Firestore whether a board with this exact name already exists.
  /// Emits `Success(nameExists)` or `Success(nameAvailable)`.
  Future<void> checkBoardName(String boardName) async {
    emit(CreateBoardLoading(form, BoardOperation.checkName));
    final result = await _checkBoardExistsUseCase.checkBoardExists(
      boardName.trim(),
    );
    switch (result) {
      case Success<bool>():
        emit(
          CreateBoardSuccess(
            form,
            result.data ? BoardOutcome.nameExists : BoardOutcome.nameAvailable,
          ),
        );
        break;
      case Fail<bool>():
        emit(
          CreateBoardFailure(
            form,
            extractErrorMessage(result.exception),
            BoardOperation.checkName,
          ),
        );
        break;
    }
  }

  Future<void> createBoard({
    required String boardName,
    String boardNameAr = '',
    String description = '',
    String descriptionAr = '',
  }) async {
    emit(CreateBoardLoading(form, BoardOperation.createBoard));
    final board = BoardEntity(
      boardName: boardName.trim(),
      boardNameAr: boardNameAr.trim(),
      description: description.trim(),
      descriptionAr: descriptionAr.trim(),
      departments: form.selectedDepartments,
      isMessagingEnabled: form.isMessagingEnabled,
      assignedEmployeeIds: form.selectedEmployeeIds,
    );
    final result = await _createBoardUseCase.createBoard(board);
    switch (result) {
      case Success<BoardEntity>():
        emit(
          CreateBoardSuccess(
            form,
            BoardOutcome.boardCreated,
            boardEntity: result.data,
          ),
        );
        break;
      case Fail<BoardEntity>():
        emit(
          CreateBoardFailure(
            form,
            extractErrorMessage(result.exception),
            BoardOperation.createBoard,
          ),
        );
        break;
    }
  }
}
