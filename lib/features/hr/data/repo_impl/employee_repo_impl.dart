import 'package:injectable/injectable.dart';

import '../../../../core/common/api_result.dart';
import '../../domain/entities/employee_entity.dart';
import '../../domain/repo/employee_repo.dart';
import '../data_sources/employee_data_source.dart';

@Injectable(as: EmployeeRepo)
class EmployeeRepoImpl implements EmployeeRepo {
  EmployeeDataSource employeeDataSource;

  EmployeeRepoImpl(this.employeeDataSource);

  @override
  Future<Result<EmployeeEntity>> addEmployee(EmployeeEntity employee) {
    return employeeDataSource.addEmployee(employee);
  }

  @override
  Future<Result<List<EmployeeEntity>>> getEmployees() {
    return employeeDataSource.getEmployees();
  }
}
