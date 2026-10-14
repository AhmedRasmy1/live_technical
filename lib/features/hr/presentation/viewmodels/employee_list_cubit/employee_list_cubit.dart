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

  Future<void> getEmployees() async {
    emit(EmployeeListLoading());
    final result = await _getEmployeesUseCase.getEmployees();
    switch (result) {
      case Success<List<EmployeeEntity>>():
        emit(EmployeeListSuccess(result.data));
        break;
      case Fail<List<EmployeeEntity>>():
        emit(EmployeeListFailure(extractErrorMessage(result.exception)));
        break;
    }
  }
}
