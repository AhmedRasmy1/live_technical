import 'package:injectable/injectable.dart';

import '../../../../core/common/api_result.dart';
import '../entities/employee_entity.dart';
import '../repo/employee_repo.dart';

@injectable
class AddEmployeeUseCase {
  EmployeeRepo employeeRepo;

  AddEmployeeUseCase(this.employeeRepo);

  Future<Result<EmployeeEntity>> addEmployee(EmployeeEntity employee) {
    return employeeRepo.addEmployee(employee);
  }
}
