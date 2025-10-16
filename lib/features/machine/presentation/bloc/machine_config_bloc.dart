import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:developer' as developer;
import '../../../../core/usecases/usecase.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/utils/app_logger.dart';
import '../../domain/usecases/get_all_matrizes.dart';
import '../../domain/usecases/get_current_machine_config.dart';
import '../../domain/usecases/select_matriz_for_machine.dart' as usecases;
import '../../domain/usecases/delete_configuracao_maquina.dart';
import '../../domain/usecases/remove_all_active_configs_for_device.dart';
import 'machine_config_event.dart';
import 'machine_config_state.dart';

class MachineConfigBloc extends Bloc<MachineConfigEvent, MachineConfigState> {
  final GetAllMatrizes _getAllMatrizes;
  final GetCurrentMachineConfig _getCurrentMachineConfig;
  final usecases.SelectMatrizForMachine _selectMatrizForMachine;
  final DeleteConfiguracaoMaquina _deleteConfiguracaoMaquina;
  final RemoveAllActiveConfigsForDevice _removeAllActiveConfigsForDevice;

  MachineConfigBloc({
    required GetAllMatrizes getAllMatrizes,
    required GetCurrentMachineConfig getCurrentMachineConfig,
    required usecases.SelectMatrizForMachine selectMatrizForMachine,
    required DeleteConfiguracaoMaquina deleteConfiguracaoMaquina,
    required RemoveAllActiveConfigsForDevice removeAllActiveConfigsForDevice,
  }) : _getAllMatrizes = getAllMatrizes,
       _getCurrentMachineConfig = getCurrentMachineConfig,
       _selectMatrizForMachine = selectMatrizForMachine,
       _deleteConfiguracaoMaquina = deleteConfiguracaoMaquina,
       _removeAllActiveConfigsForDevice = removeAllActiveConfigsForDevice,
       super(const MachineConfigInitial()) {
    developer.log('🔧 MachineConfigBloc inicializado', name: 'MachineConfig');
    on<LoadAvailableMatrizes>(_onLoadAvailableMatrizes);
    on<LoadCurrentMachineConfig>(_onLoadCurrentMachineConfig);
    on<SelectMatrizForMachine>(_onSelectMatrizForMachine);
    on<RemoveMachineConfig>(_onRemoveMachineConfig);
    on<ResetMachineConfig>(_onResetMachineConfig);
  }

  Future<void> _onLoadAvailableMatrizes(
    LoadAvailableMatrizes event,
    Emitter<MachineConfigState> emit,
  ) async {
    developer.log(
      '🔄 Iniciando carregamento de matrizes disponíveis',
      name: 'MachineConfigBloc',
    );
    emit(const MachineConfigLoading());

    try {
      developer.log(
        '📡 Chamando getAllMatrizes use case',
        name: 'MachineConfigBloc',
      );
      final result = await _getAllMatrizes(NoParams());
      developer.log(
        '📡 Resultado da busca de matrizes recebido',
        name: 'MachineConfigBloc',
      );

      result.fold(
        (failure) {
          AppLogger.error(
            'ERRO ao carregar matrizes: ${failure.toString()}',
            name: 'MachineConfigBloc',
          );
          AppLogger.error(
            'Tipo de erro: ${failure.runtimeType}',
            name: 'MachineConfigBloc',
          );
          if (failure is ServerFailure) {
            AppLogger.error(
              'ServerFailure - Código: ${failure.statusCode}, Mensagem: ${failure.message}',
              name: 'MachineConfigBloc',
            );
          } else if (failure is NetworkFailure) {
            AppLogger.error(
              'NetworkFailure - Mensagem: ${failure.message}',
              name: 'MachineConfigBloc',
            );
          } else if (failure is CacheFailure) {
            AppLogger.error(
              'CacheFailure - Mensagem: ${failure.message}',
              name: 'MachineConfigBloc',
            );
          }
          emit(MachineConfigError(message: _getFailureMessage(failure)));
        },
        (matrizes) {
          developer.log(
            '✅ SUCESSO: Matrizes carregadas com sucesso!',
            name: 'MachineConfigBloc',
          );
          developer.log(
            '📊 RESPOSTA COMPLETA DAS MATRIZES:',
            name: 'MachineConfigBloc',
          );
          developer.log(
            '  - Total de matrizes: ${matrizes.length}',
            name: 'MachineConfigBloc',
          );
          developer.log(
            '  - Matrizes ativas: ${matrizes.where((m) => m.isActive).length}',
            name: 'MachineConfigBloc',
          );
          developer.log(
            '  - Matrizes inativas: ${matrizes.where((m) => !m.isActive).length}',
            name: 'MachineConfigBloc',
          );

          for (int i = 0; i < matrizes.length; i++) {
            var matriz = matrizes[i];
            developer.log('📋 Matriz ${i + 1}:', name: 'MachineConfigBloc');
            developer.log('    - ID: ${matriz.id}', name: 'MachineConfigBloc');
            developer.log(
              '    - Nome: ${matriz.nome}',
              name: 'MachineConfigBloc',
            );
            developer.log(
              '    - Código: ${matriz.codigo}',
              name: 'MachineConfigBloc',
            );
            developer.log(
              '    - Descrição: ${matriz.descricao}',
              name: 'MachineConfigBloc',
            );
            developer.log(
              '    - Ativa: ${matriz.isActive}',
              name: 'MachineConfigBloc',
            );
            developer.log(
              '    - toString(): ${matriz.toString()}',
              name: 'MachineConfigBloc',
            );
          }

          developer.log(
            '🎯 Emitindo estado AvailableMatrizesLoaded',
            name: 'MachineConfigBloc',
          );
          emit(AvailableMatrizesLoaded(matrizes: matrizes));
        },
      );
    } catch (e, stackTrace) {
      developer.log(
        '💥 EXCEÇÃO INESPERADA ao carregar matrizes: $e',
        name: 'MachineConfigBloc',
      );
      developer.log('📍 Stack trace: $stackTrace', name: 'MachineConfigBloc');
      emit(
        MachineConfigError(message: 'Erro inesperado ao carregar matrizes: $e'),
      );
    }
  }

  Future<void> _onLoadCurrentMachineConfig(
    LoadCurrentMachineConfig event,
    Emitter<MachineConfigState> emit,
  ) async {
    developer.log(
      '🔄 Iniciando carregamento da configuração atual da máquina',
      name: 'MachineConfigBloc',
    );
    developer.log(
      '🔍 Device ID: ${event.deviceId}, User ID: ${event.userId}',
      name: 'MachineConfigBloc',
    );
    emit(const MachineConfigLoading());

    try {
      developer.log(
        '📡 Chamando getCurrentMachineConfig use case',
        name: 'MachineConfigBloc',
      );
      final result = await _getCurrentMachineConfig(
        GetMachineConfigParams(deviceId: event.deviceId, userId: event.userId),
      );
      developer.log(
        '📡 Resultado da busca de configuração recebido',
        name: 'MachineConfigBloc',
      );

      result.fold(
        (failure) {
          AppLogger.error(
            'ERRO ao carregar configuração: ${failure.toString()}',
            name: 'MachineConfigBloc',
          );
          AppLogger.error(
            'Tipo de erro: ${failure.runtimeType}',
            name: 'MachineConfigBloc',
          );
          if (failure is ServerFailure) {
            AppLogger.error(
              'ServerFailure - Código: ${failure.statusCode}, Mensagem: ${failure.message}',
              name: 'MachineConfigBloc',
            );
          } else if (failure is NetworkFailure) {
            AppLogger.error(
              'NetworkFailure - Mensagem: ${failure.message}',
              name: 'MachineConfigBloc',
            );
          } else if (failure is CacheFailure) {
            AppLogger.error(
              'CacheFailure - Mensagem: ${failure.message}',
              name: 'MachineConfigBloc',
            );
          }
          emit(MachineConfigError(message: _getFailureMessage(failure)));
        },
        (config) {
          if (config != null) {
            developer.log(
              '✅ SUCESSO: Configuração atual carregada com sucesso!',
              name: 'MachineConfigBloc',
            );
            developer.log(
              '📊 RESPOSTA COMPLETA DA CONFIGURAÇÃO ATUAL:',
              name: 'MachineConfigBloc',
            );
            developer.log(
              '  - Configuração ID: ${config.id}',
              name: 'MachineConfigBloc',
            );
            developer.log(
              '  - Device ID: ${config.deviceId}',
              name: 'MachineConfigBloc',
            );
            developer.log(
              '  - User ID: ${config.userId}',
              name: 'MachineConfigBloc',
            );
            developer.log(
              '  - Matriz ID: ${config.matrizId}',
              name: 'MachineConfigBloc',
            );
            developer.log(
              '  - Matriz Nome: ${config.matriz?.nome ?? "N/A"}',
              name: 'MachineConfigBloc',
            );
            developer.log(
              '  - Matriz Código: ${config.matriz?.codigo ?? "N/A"}',
              name: 'MachineConfigBloc',
            );
            developer.log(
              '  - Matriz Ativa: ${config.matriz?.isActive ?? "N/A"}',
              name: 'MachineConfigBloc',
            );
            developer.log(
              '  - Data de Configuração: ${config.configuredAt}',
              name: 'MachineConfigBloc',
            );
            developer.log(
              '  - Configuração toString(): ${config.toString()}',
              name: 'MachineConfigBloc',
            );
            developer.log(
              '🎯 Emitindo estado CurrentMachineConfigLoaded com configuração',
              name: 'MachineConfigBloc',
            );
            emit(CurrentMachineConfigLoaded(config: config));
          } else {
            developer.log(
              'ℹ️ SUCESSO: Nenhuma configuração encontrada para este dispositivo',
              name: 'MachineConfigBloc',
            );
            developer.log(
              '📊 RESPOSTA: Configuração é null (dispositivo não configurado)',
              name: 'MachineConfigBloc',
            );
            developer.log(
              '🎯 Emitindo estado CurrentMachineConfigLoaded sem configuração',
              name: 'MachineConfigBloc',
            );
            emit(const CurrentMachineConfigLoaded(config: null));
          }
        },
      );
    } catch (e, stackTrace) {
      developer.log(
        '💥 EXCEÇÃO INESPERADA ao carregar configuração: $e',
        name: 'MachineConfigBloc',
      );
      developer.log('📍 Stack trace: $stackTrace', name: 'MachineConfigBloc');
      emit(
        MachineConfigError(
          message: 'Erro inesperado ao carregar configuração: $e',
        ),
      );
    }
  }

  Future<void> _onSelectMatrizForMachine(
    SelectMatrizForMachine event,
    Emitter<MachineConfigState> emit,
  ) async {
    developer.log('⚙️ Selecionando matriz para máquina', name: 'MachineConfig');
    developer.log('  - Device: ${event.deviceId}', name: 'MachineConfig');
    developer.log('  - User: ${event.userId}', name: 'MachineConfig');
    developer.log('  - Matriz ID: ${event.matrizId}', name: 'MachineConfig');

    emit(const MachineConfigLoading());

    try {
      final result = await _selectMatrizForMachine(
        usecases.SelectMatrizParams(
          deviceId: event.deviceId,
          userId: event.userId,
          matrizId: event.matrizId,
          registroMaquinaId: event.registroMaquinaId,
        ),
      );

      result.fold(
        (failure) {
          AppLogger.error(
            'Erro ao selecionar matriz: ${failure.toString()}',
            name: 'MachineConfig',
          );
          emit(MachineConfigError(message: _getFailureMessage(failure)));
        },
        (config) {
          developer.log(
            '✅ SUCESSO: Matriz selecionada com sucesso!',
            name: 'MachineConfig',
          );
          developer.log(
            '📊 RESPOSTA COMPLETA DA CONFIGURAÇÃO:',
            name: 'MachineConfig',
          );
          developer.log(
            '  - Configuração ID: ${config.id}',
            name: 'MachineConfig',
          );
          developer.log(
            '  - Device ID: ${config.deviceId}',
            name: 'MachineConfig',
          );
          developer.log('  - User ID: ${config.userId}', name: 'MachineConfig');
          developer.log(
            '  - Matriz ID: ${config.matrizId}',
            name: 'MachineConfig',
          );
          developer.log(
            '  - Matriz Nome: ${config.matriz?.nome ?? "N/A"}',
            name: 'MachineConfig',
          );
          developer.log(
            '  - Matriz Código: ${config.matriz?.codigo ?? "N/A"}',
            name: 'MachineConfig',
          );
          developer.log(
            '  - Matriz Ativa: ${config.matriz?.isActive ?? "N/A"}',
            name: 'MachineConfig',
          );
          developer.log(
            '  - Data de Configuração: ${config.configuredAt}',
            name: 'MachineConfig',
          );
          developer.log(
            '  - Configuração toString(): ${config.toString()}',
            name: 'MachineConfig',
          );
          developer.log(
            '🎯 Emitindo estado MatrizSelectedSuccess',
            name: 'MachineConfig',
          );
          emit(MatrizSelectedSuccess(config: config));
        },
      );
    } catch (e) {
      developer.log(
        '💥 Exceção não tratada ao selecionar matriz: $e',
        name: 'MachineConfig',
      );
      emit(MachineConfigError(message: 'Erro inesperado: $e'));
    }
  }

  Future<void> _onRemoveMachineConfig(
    RemoveMachineConfig event,
    Emitter<MachineConfigState> emit,
  ) async {
    developer.log(
      '🗑️ Removendo configuração da máquina',
      name: 'MachineConfig',
    );
    developer.log('  - Device: ${event.deviceId}', name: 'MachineConfig');
    developer.log('  - User: ${event.userId}', name: 'MachineConfig');

    emit(const MachineConfigLoading());

    try {
      // Primeiro, tentar buscar a configuração atual para obter o ID
      developer.log(
        '🔍 Buscando configuração atual para obter ID',
        name: 'MachineConfig',
      );
      
      final getCurrentConfigParams = GetMachineConfigParams(
        deviceId: event.deviceId,
        userId: event.userId,
      );
      
      final currentConfigResult = await _getCurrentMachineConfig(getCurrentConfigParams);
      
      await currentConfigResult.fold(
        (failure) async {
          developer.log(
            '💥 Erro ao buscar configuração atual: ${_getFailureMessage(failure)}',
            name: 'MachineConfig',
          );
          
          // Se o erro for de múltiplas configurações (erro 500), 
          // vamos tentar remover todas as configurações ativas para este dispositivo
          if (failure is ServerFailure && failure.message.contains('500')) {
            developer.log(
              '🔄 Detectado erro de múltiplas configurações. Tentando remoção alternativa.',
              name: 'MachineConfig',
            );
            
            // Tentar remover todas as configurações ativas para este dispositivo
            final removeAllResult = await _removeAllActiveConfigsForDevice(event.deviceId);
            
            removeAllResult.fold(
              (removeFailure) {
                developer.log(
                  '💥 Erro ao remover todas as configurações: ${_getFailureMessage(removeFailure)}',
                  name: 'MachineConfig',
                );
                emit(MachineConfigError(
                  message: 'Múltiplas configurações ativas detectadas. Erro ao tentar resolver: ${_getFailureMessage(removeFailure)}'
                ));
              },
              (_) {
                developer.log(
                  '✅ Todas as configurações ativas removidas com sucesso',
                  name: 'MachineConfig',
                );
                emit(const MachineConfigRemovedSuccess());
              },
            );
          } else {
            emit(MachineConfigError(message: 'Erro ao buscar configuração: ${_getFailureMessage(failure)}'));
          }
        },
        (config) async {
          if (config == null || config.id == null) {
            developer.log(
              '⚠️ Nenhuma configuração ativa encontrada para remover',
              name: 'MachineConfig',
            );
            emit(const MachineConfigError(message: 'Nenhuma configuração ativa encontrada'));
            return;
          }

          developer.log(
            '🗑️ Realizando soft delete da configuração ID: ${config.id}',
            name: 'MachineConfig',
          );

          // Realizar o soft delete usando o use case
          final deleteParams = DeleteConfiguracaoMaquinaParams(id: config.id!);
          final deleteResult = await _deleteConfiguracaoMaquina(deleteParams);

          deleteResult.fold(
            (failure) {
              developer.log(
                '💥 Erro ao fazer soft delete: ${_getFailureMessage(failure)}',
                name: 'MachineConfig',
              );
              emit(MachineConfigError(message: 'Erro ao remover configuração: ${_getFailureMessage(failure)}'));
            },
            (_) {
              developer.log(
                '✅ Soft delete realizado com sucesso',
                name: 'MachineConfig',
              );
              emit(const MachineConfigRemovedSuccess());
            },
          );
        },
      );
    } catch (e) {
      developer.log(
        '💥 Exceção não tratada ao remover configuração: $e',
        name: 'MachineConfig',
      );
      emit(MachineConfigError(message: 'Erro inesperado: $e'));
    }
  }

  void _onResetMachineConfig(
    ResetMachineConfig event,
    Emitter<MachineConfigState> emit,
  ) {
    developer.log(
      '🔄 Resetando estado da configuração da máquina',
      name: 'MachineConfig',
    );
    emit(const MachineConfigInitial());
  }

  String _getFailureMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return failure.message;
    } else if (failure is CacheFailure) {
      return failure.message;
    } else if (failure is AuthenticationFailure) {
      return failure.message;
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is DeviceFailure) {
      return failure.message;
    } else if (failure is HardwareFailure) {
      return failure.message;
    }
    return 'Erro desconhecido';
  }
}