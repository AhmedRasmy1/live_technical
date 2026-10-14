import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';
import 'package:meta/meta.dart';

import '../../../../../core/common/api_result.dart';
import '../../../../../core/utils/extract_error_message.dart';
import '../../../domain/entities/employee_entity.dart';
import '../../../domain/usecases/add_employee_use_case.dart';

part 'add_employee_state.dart';

@injectable
class AddEmployeeCubit extends Cubit<AddEmployeeState> {
  final AddEmployeeUseCase _addEmployeeUseCase;

  AddEmployeeCubit(this._addEmployeeUseCase) : super(AddEmployeeInitial());

  Future<void> addEmployee(EmployeeEntity employee) async {
    emit(AddEmployeeLoading());
    final result = await _addEmployeeUseCase.addEmployee(employee);
    switch (result) {
      case Success<EmployeeEntity>():
        emit(AddEmployeeSuccess(result.data));
        break;
      case Fail<EmployeeEntity>():
        emit(AddEmployeeFailure(extractErrorMessage(result.exception)));
        break;
    }
  }
}
