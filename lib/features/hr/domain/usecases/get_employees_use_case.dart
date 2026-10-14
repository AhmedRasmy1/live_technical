import 'package:injectable/injectable.dart';

import '../../../../core/common/api_result.dart';
import '../entities/employee_entity.dart';
import '../repo/employee_repo.dart';

@injectable
class GetEmployeesUseCase {
  EmployeeRepo employeeRepo;

  GetEmployeesUseCase(this.employeeRepo);

  Future<Result<List<EmployeeEntity>>> getEmployees() {
    return employeeRepo.getEmployees();
  }
}
