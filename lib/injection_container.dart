import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'core/config/network_config.dart';
import 'core/config/app_config.dart';
import 'core/services/device_info_service.dart';

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
import 'features/machine/presentation/bloc/configuracao_maquina_bloc.dart';
import 'features/machine/domain/usecases/get_all_matrizes.dart';
import 'features/machine/domain/usecases/get_current_machine_config.dart';
import 'features/machine/domain/usecases/select_matriz_for_machine.dart';
import 'features/machine/domain/usecases/get_configuracoes_maquina.dart';
import 'features/machine/domain/usecases/get_configuracao_maquina_by_id.dart';
import 'features/machine/domain/usecases/get_configuracao_by_maquina_and_chave.dart';
import 'features/machine/domain/usecases/create_configuracao_maquina.dart';
import 'features/machine/domain/usecases/update_configuracao_maquina.dart';
import 'features/machine/domain/usecases/delete_configuracao_maquina.dart';
import 'features/machine/domain/usecases/remove_all_active_configs_for_device.dart';
import 'features/machine/domain/repositories/machine_repository.dart';
import 'features/machine/domain/repositories/configuracao_maquina_repository.dart';
import 'features/machine/data/repositories/machine_repository_impl.dart';
import 'features/machine/data/repositories/configuracao_maquina_repository_impl.dart';
import 'features/machine/data/datasources/machine_local_datasource_impl.dart';
import 'features/machine/data/datasources/machine_remote_datasource_impl.dart';
import 'features/machine/data/datasources/configuracao_maquina_remote_datasource.dart';
import 'features/machine/data/datasources/configuracao_maquina_remote_datasource_impl.dart';
import 'features/machine/domain/usecases/create_maquina.dart';
import 'features/machine/domain/usecases/get_maquina_by_id.dart';
import 'features/machine/domain/usecases/update_maquina.dart';
import 'features/machine/domain/usecases/get_all_maquinas.dart';
import 'features/machine/domain/usecases/get_current_device_machine.dart';
import 'features/machine/domain/repositories/registro_maquina_repository.dart';
import 'features/machine/data/repositories/registro_maquina_repository_impl.dart';
import 'features/machine/data/datasources/registro_maquina_remote_datasource.dart';
import 'features/machine/data/datasources/registro_maquina_remote_datasource_impl.dart';
import 'features/machine/presentation/bloc/registro_maquina_bloc.dart';

// Features - Injection
import 'features/injection/presentation/bloc/injection_bloc.dart';
import 'features/injection/domain/usecases/validar_carcaca_usecase.dart';
import 'features/injection/domain/usecases/controlar_sonoff_usecase.dart';
import 'features/injection/domain/repositories/sonoff_repository.dart';
import 'features/injection/data/repositories/sonoff_repository_impl.dart';
import 'features/injection/data/datasources/sonoff_datasource.dart';
import 'features/injection/domain/repositories/producao_repository.dart';
import 'features/injection/data/repositories/producao_repository_impl.dart';
import 'features/injection/data/datasources/producao_remote_datasource.dart';
import 'features/injection/data/datasources/vulcanizacao_remote_datasource.dart';
import 'features/injection/data/datasources/vulcanizacao_remote_datasource_impl.dart';
import 'features/auth/domain/usecases/get_current_user.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Auth
  // Bloc
  sl.registerFactory(() => AuthBloc(authRepository: sl(), loginUseCase: sl()));

  // Use cases
  sl.registerLazySingleton(() => Login(sl()));
  sl.registerLazySingleton(() => GetCurrentUser(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl()),
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
  sl.registerFactory(
    () => MachineConfigBloc(
      getAllMatrizes: sl(),
      getCurrentMachineConfig: sl(),
      selectMatrizForMachine: sl(),
      deleteConfiguracaoMaquina: sl(),
      removeAllActiveConfigsForDevice: sl(),
    ),
  );
  sl.registerFactory(
    () => ConfiguracaoMaquinaBloc(
      getConfiguracoesMaquina: sl(),
      getConfiguracaoMaquinaById: sl(),
      createConfiguracaoMaquina: sl(),
      updateConfiguracaoMaquina: sl(),
      deleteConfiguracaoMaquina: sl(),
      getConfiguracaoByMaquinaAndChave: sl(),
    ),
  );
  sl.registerFactory(
    () => RegistroMaquinaBloc(
      createMaquina: sl(),
      getMaquinaById: sl(),
      updateMaquina: sl(),
      getAllMaquinas: sl(),
      getCurrentDeviceMachine: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => GetAllMatrizes(sl()));
  sl.registerLazySingleton(() => GetCurrentMachineConfig(sl()));
  sl.registerLazySingleton(() => SelectMatrizForMachine(sl()));
  sl.registerLazySingleton(() => GetConfiguracoesMaquina(sl()));
  sl.registerLazySingleton(() => GetConfiguracaoMaquinaById(sl()));
  sl.registerLazySingleton(() => CreateConfiguracaoMaquina(sl()));
  sl.registerLazySingleton(() => UpdateConfiguracaoMaquina(sl()));
  sl.registerLazySingleton(() => DeleteConfiguracaoMaquina(sl()));
  sl.registerLazySingleton(() => RemoveAllActiveConfigsForDevice(sl()));
  sl.registerLazySingleton(() => GetConfiguracaoByMaquinaAndChave(sl()));
  sl.registerLazySingleton(() => CreateMaquina(sl()));
  sl.registerLazySingleton(() => GetMaquinaById(sl()));
  sl.registerLazySingleton(() => UpdateMaquina(sl()));
  sl.registerLazySingleton(() => GetAllMaquinas(sl()));
  sl.registerLazySingleton(
    () => GetCurrentDeviceMachine(repository: sl(), deviceInfoService: sl()),
  );

  // Repository
  sl.registerLazySingleton<MachineRepository>(
    () => MachineRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<ConfiguracaoMaquinaRepository>(
    () => ConfiguracaoMaquinaRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<RegistroMaquinaRepository>(
    () => RegistroMaquinaRepositoryImpl(remoteDataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton(
    () => MachineLocalDataSourceImpl(sharedPreferences: sl()),
  );
  sl.registerLazySingleton(() => MachineRemoteDataSourceImpl(client: sl()));
  sl.registerLazySingleton<ConfiguracaoMaquinaRemoteDataSource>(
    () => ConfiguracaoMaquinaRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<RegistroMaquinaRemoteDataSource>(
    () => RegistroMaquinaRemoteDataSourceImpl(dio: sl()),
  );

  //! Features - Injection
  // Bloc
  sl.registerFactory(
    () => InjectionBloc(
      validarCarcacaUseCase: sl(),
      getCurrentMachineConfig: sl(),
      controlarSonoffUseCase: sl(),
      vulcanizacaoDataSource: sl(),
      getCurrentUser: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(
    () => ValidarCarcacaUseCase(
      producaoRepository: sl(),
      machineRepository: sl(),
    ),
  );
  sl.registerLazySingleton(() => ControlarSonoffUseCase(repository: sl()));

  // Repositories
  sl.registerLazySingleton<ProducaoRepository>(
    () => ProducaoRepositoryImpl(remoteDataSource: sl()),
  );
  sl.registerLazySingleton<SonoffRepository>(
    () => SonoffRepositoryImpl(dataSource: sl()),
  );

  // Data sources
  sl.registerLazySingleton<ProducaoRemoteDataSource>(
    () => ProducaoRemoteDataSourceImpl(
      client: sl(),
      baseUrl: AppConfig.instance.apiBaseUrl,
    ),
  );
  sl.registerLazySingleton<SonoffDataSource>(
    () => SonoffDataSourceImpl(
      client: sl(),
      baseUrl: 'http://192.168.0.165', // IP e porta do Sonoff
    ),
  );
  sl.registerLazySingleton<VulcanizacaoRemoteDataSource>(
    () => VulcanizacaoRemoteDataSourceImpl(dio: sl()),
  );

  //! Core Services
  sl.registerLazySingleton(() => DeviceInfoService.instance);

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => NetworkConfig.dio);
}
