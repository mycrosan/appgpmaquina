import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

// Features - Auth
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/auth/domain/usecases/login.dart';
import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/data/datasources/auth_remote_datasource.dart';
import 'features/auth/data/datasources/auth_remote_datasource_impl.dart';
import 'features/auth/data/datasources/auth_local_datasource.dart';
import 'features/auth/data/datasources/auth_local_datasource_impl.dart';

// Features - Machine
import 'features/machine/presentation/bloc/machine_bloc.dart';
import 'features/machine/presentation/bloc/machine_config_bloc.dart';
import 'features/machine/domain/usecases/get_all_matrizes.dart';
import 'features/machine/domain/usecases/get_current_machine_config.dart';
import 'features/machine/domain/usecases/select_matriz_for_machine.dart';
import 'features/machine/domain/repositories/machine_repository.dart';
import 'features/machine/data/repositories/machine_repository_impl.dart';
import 'features/machine/data/datasources/machine_local_datasource.dart';
import 'features/machine/data/datasources/machine_local_datasource_impl.dart';
import 'features/machine/data/datasources/machine_remote_datasource.dart';
import 'features/machine/data/datasources/machine_remote_datasource_impl.dart';

// Features - Injection
import 'features/injection/presentation/bloc/injection_bloc.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Bloc
  sl.registerFactory(() => AuthBloc(
    authRepository: sl(),
    loginUseCase: sl(),
  ));

  // Use cases
  sl.registerLazySingleton(() => Login(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: sl(),
      localDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(client: sl()),
  );
  sl.registerLazySingleton<AuthLocalDataSource>(
    () => AuthLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! Features - Machine
  // Bloc
  sl.registerFactory(() => MachineBloc());
  sl.registerFactory(() => MachineConfigBloc(
    getAllMatrizes: sl(),
    getCurrentMachineConfig: sl(),
    selectMatrizForMachine: sl(),
  ));

  // Use cases
  sl.registerLazySingleton(() => GetAllMatrizes(sl()));
  sl.registerLazySingleton(() => GetCurrentMachineConfig(sl()));
  sl.registerLazySingleton(() => SelectMatrizForMachine(sl()));

  // Repository
  sl.registerLazySingleton<MachineRepository>(
    () => MachineRepositoryImpl(
      localDataSource: sl(),
      remoteDataSource: sl(),
    ),
  );

  // Data sources
  sl.registerLazySingleton<MachineLocalDataSourceImpl>(
    () => MachineLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton<MachineRemoteDataSourceImpl>(
    () => MachineRemoteDataSourceImpl(client: sl()),
  );

  //! Features - Injection
  // Bloc
  sl.registerFactory(() => InjectionBloc());

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
}