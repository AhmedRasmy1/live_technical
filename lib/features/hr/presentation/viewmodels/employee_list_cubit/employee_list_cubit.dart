import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';

import '../../../../../core/common/api_result.dart';
import '../../../../../core/utils/extract_error_message.dart';
import '../../../domain/entities/employee_entity.dart';
import '../../../domain/usecases/get_employees_use_case.dart';

part 'employee_list_state.dart';

@injectable
class EmployeeListCubit extends Cubit<EmployeeListState> {
  final GetEmployeesUseCase _getEmployeesUseCase;

  EmployeeListCubit(this._getEmployeesUseCase) : super(EmployeeListInitial());

  /// Everything fetched from Firestore.
  List<EmployeeEntity> originalList = [];

  /// What the UI currently shows (`originalList` + active search / filter).
  List<EmployeeEntity> filteredList = [];

  String _query = '';
  String? _department;
  String? _jobTitle;

  String? get selectedDepartment => _department;
  String? get selectedJobTitle => _jobTitle;

  /// Distinct job titles found in the fetched data (job title is free text).
  List<String> get jobTitles {
    final titles = originalList
        .map((employee) => employee.jobTitle.trim())
        .where((title) => title.isNotEmpty)
        .toSet()
        .toList();
    titles.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return titles;
  }

  Future<void> getEmployees() async {
    emit(EmployeeListLoading());
    final result = await _getEmployeesUseCase.getEmployees();
    switch (result) {
      case Success<List<EmployeeEntity>>():
        originalList = result.data;
        // Keep whatever search / filter the user already has on screen.
        filteredList = _computeFilteredList();
        emit(EmployeeListSuccess(filteredList));
        break;
      case Fail<List<EmployeeEntity>>():
        emit(EmployeeListFailure(extractErrorMessage(result.exception)));
        break;
    }
  }

  /// Case-insensitive match on first name, last name or full name.
  void searchEmployees(String query) {
    if (state is! EmployeeListSuccess) return;
    _query = query.trim();
    _emitFiltered();
  }

  /// Filters by the Filter panel values. A `null` value means "any".
  void applyFilter({String? department, String? jobTitle}) {
    if (state is! EmployeeListSuccess) return;
    _department = department;
    _jobTitle = jobTitle;
    _emitFiltered();
  }

  /// Clears the department / job title filter. The search text is kept,
  /// because the search field still shows it.
  void resetFilter() {
    if (state is! EmployeeListSuccess) return;
    _department = null;
    _jobTitle = null;
    _emitFiltered();
  }

  void _emitFiltered() {
    filteredList = _computeFilteredList();
    emit(EmployeeListSuccess(filteredList));
  }

  List<EmployeeEntity> _computeFilteredList() {
    final query = _query.toLowerCase();
    return originalList.where((employee) {
      final matchesQuery =
          query.isEmpty ||
          employee.firstName.toLowerCase().contains(query) ||
          employee.lastName.toLowerCase().contains(query) ||
          employee.fullName.toLowerCase().contains(query);
      final matchesDepartment =
          _department == null || _sameText(employee.department, _department!);
      final matchesJobTitle =
          _jobTitle == null || _sameText(employee.jobTitle, _jobTitle!);
      return matchesQuery && matchesDepartment && matchesJobTitle;
    }).toList();
  }

  bool _sameText(String a, String b) =>
      a.trim().toLowerCase() == b.trim().toLowerCase();
}
