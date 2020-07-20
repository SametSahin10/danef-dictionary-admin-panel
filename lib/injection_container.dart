import 'package:danef_dictionary_admin_panel/features/auth/data/data_sources/user_remote_data_source.dart';
import 'package:danef_dictionary_admin_panel/features/auth/data/repositories/user_repository_impl.dart';
import 'package:danef_dictionary_admin_panel/features/auth/domain/repositories/user_repository.dart';
import 'package:danef_dictionary_admin_panel/features/auth/domain/use_cases/sign_in_use_case.dart';
import 'package:get_it/get_it.dart';

final sl = GetIt.instance;

void init() async {
  // Use cases
  sl.registerLazySingleton(() => SignInUseCase(sl()));

  // Repositories
  sl.registerLazySingleton<UserRepository>(() {
    return UserRepositoryImpl(remoteDataSource: sl());
  });

  // Data sources
  sl.registerLazySingleton<UserRemoteDataSource>(() {
    return UserRemoteDataSourceImpl();
  });
}
