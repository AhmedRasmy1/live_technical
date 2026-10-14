// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:dio/dio.dart' as _i361;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;

import '../../features/hr/data/data_sources/employee_data_source.dart' as _i47;
import '../../features/hr/data/data_sources_impl/employee_data_source_impl.dart'
    as _i825;
import '../../features/hr/data/repo_impl/employee_repo_impl.dart' as _i562;
import '../../features/hr/domain/repo/employee_repo.dart' as _i278;
import '../../features/hr/domain/usecases/add_employee_use_case.dart' as _i306;
import '../../features/hr/domain/usecases/get_employees_use_case.dart' as _i26;
import '../../features/hr/presentation/viewmodels/add_employee_cubit/add_employee_cubit.dart'
    as _i508;
import '../../features/hr/presentation/viewmodels/employee_list_cubit/employee_list_cubit.dart'
    as _i538;
import '../api/api_manager/api_manager.dart' as _i680;
import '../api/dio_module.dart' as _i784;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final dioModule = _$DioModule();
    gh.lazySingleton<_i361.Dio>(() => dioModule.providerDio());
    gh.factory<_i47.EmployeeDataSource>(() => _i825.EmployeeDataSourceImpl());
    gh.factory<_i680.ApiService>(() => _i680.ApiService(gh<_i361.Dio>()));
    gh.factory<_i278.EmployeeRepo>(
      () => _i562.EmployeeRepoImpl(gh<_i47.EmployeeDataSource>()),
    );
    gh.factory<_i306.AddEmployeeUseCase>(
      () => _i306.AddEmployeeUseCase(gh<_i278.EmployeeRepo>()),
    );
    gh.factory<_i26.GetEmployeesUseCase>(
      () => _i26.GetEmployeesUseCase(gh<_i278.EmployeeRepo>()),
    );
    gh.factory<_i538.EmployeeListCubit>(
      () => _i538.EmployeeListCubit(gh<_i26.GetEmployeesUseCase>()),
    );
    gh.factory<_i508.AddEmployeeCubit>(
      () => _i508.AddEmployeeCubit(gh<_i306.AddEmployeeUseCase>()),
    );
    return this;
  }
}

class _$DioModule extends _i784.DioModule {}
