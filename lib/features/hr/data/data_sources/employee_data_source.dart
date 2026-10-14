import '../../../../core/common/api_result.dart';
import '../../domain/entities/employee_entity.dart';

abstract class EmployeeDataSource {
  Future<Result<EmployeeEntity>> addEmployee(EmployeeEntity employee);

  Future<Result<List<EmployeeEntity>>> getEmployees();
}
