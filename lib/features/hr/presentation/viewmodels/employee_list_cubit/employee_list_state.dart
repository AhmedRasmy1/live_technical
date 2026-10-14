part of 'employee_list_cubit.dart';

@immutable
sealed class EmployeeListState {}

final class EmployeeListInitial extends EmployeeListState {}

final class EmployeeListLoading extends EmployeeListState {}

final class EmployeeListSuccess extends EmployeeListState {
  final List<EmployeeEntity> employees;
  EmployeeListSuccess(this.employees);
}

final class EmployeeListFailure extends EmployeeListState {
  final String error;
  EmployeeListFailure(this.error);
}
