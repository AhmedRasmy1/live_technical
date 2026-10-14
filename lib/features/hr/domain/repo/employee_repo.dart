import '../../../../core/common/api_result.dart';
import '../entities/employee_entity.dart';

abstract class EmployeeRepo {
  Future<Result<EmployeeEntity>> addEmployee(EmployeeEntity employee);

  Future<Result<List<EmployeeEntity>>> getEmployees();
}
