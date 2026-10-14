part of 'add_employee_cubit.dart';

@immutable
sealed class AddEmployeeState {}

final class AddEmployeeInitial extends AddEmployeeState {}

final class AddEmployeeLoading extends AddEmployeeState {}

final class AddEmployeeSuccess extends AddEmployeeState {
  final EmployeeEntity employeeEntity;
  AddEmployeeSuccess(this.employeeEntity);
}

final class AddEmployeeFailure extends AddEmployeeState {
  final String error;
  AddEmployeeFailure(this.error);
}
