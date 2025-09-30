import 'dart:developer' as developer;
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/usecases/create_maquina.dart';
import '../../domain/usecases/get_maquina_by_id.dart';
import '../../domain/usecases/update_maquina.dart';
import '../../domain/usecases/get_all_maquinas.dart';
import '../../domain/usecases/get_current_device_machine.dart';
import 'registro_maquina_event.dart';
import 'registro_maquina_state.dart';

/// BLoC para gerenciar estado de registro de máquinas
/// Coordena entre a UI e os use cases de domínio
class RegistroMaquinaBloc
    extends Bloc<RegistroMaquinaEvent, RegistroMaquinaState> {
  final CreateMaquina createMaquina;
  final GetMaquinaById getMaquinaById;
  final UpdateMaquina updateMaquina;
  final GetAllMaquinas getAllMaquinas;
  final GetCurrentDeviceMachine getCurrentDeviceMachine;

  RegistroMaquinaBloc({
    required this.createMaquina,
    required this.getMaquinaById,
    required this.updateMaquina,
    required this.getAllMaquinas,
    required this.getCurrentDeviceMachine,
  }) : super(const RegistroMaquinaInitial()) {
    developer.log(
      '🎯 RegistroMaquinaBloc inicializado',
      name: 'RegistroMaquinaBloc',
    );

    // Registra os handlers para cada evento
    on<CreateMaquinaEvent>(_onCreateMaquina);
    on<GetMaquinaByIdEvent>(_onGetMaquinaById);
    on<UpdateMaquinaEvent>(_onUpdateMaquina);
    on<GetAllMaquinasEvent>(_onGetAllMaquinas);
    on<GetCurrentDeviceMachineEvent>(_onGetCurrentDeviceMachine);
    on<ClearRegistroMaquinaEvent>(_onClearRegistroMaquina);
    on<ResetUpdateStatusEvent>(_onResetUpdateStatus);
  }

  /// Handler para criar nova máquina
  Future<void> _onCreateMaquina(
    CreateMaquinaEvent event,
    Emitter<RegistroMaquinaState> emit,
  ) async {
    try {
      developer.log(
        '📋 Criando nova máquina: ${event.maquina.nome}',
        name: 'RegistroMaquinaBloc',
      );
      emit(const RegistroMaquinaLoading());

      final result = await createMaquina(
        CreateMaquinaParams(maquina: event.maquina),
      );

      result.fold(
        (failure) {
          final message = _getFailureMessage(failure);
          developer.log(
            '❌ Erro ao criar máquina: $message',
            name: 'RegistroMaquinaBloc',
          );
          emit(RegistroMaquinaError(message: message));
        },
        (maquina) {
          developer.log(
            '✅ Máquina criada: ${maquina.nome}',
            name: 'RegistroMaquinaBloc',
          );
          emit(RegistroMaquinaCreated(maquina: maquina));
        },
      );
    } catch (e) {
      developer.log(
        '❌ Erro inesperado ao criar máquina: $e',
        name: 'RegistroMaquinaBloc',
      );
      emit(RegistroMaquinaError(message: 'Erro inesperado: $e'));
    }
  }

  /// Handler para buscar máquina por ID
  Future<void> _onGetMaquinaById(
    GetMaquinaByIdEvent event,
    Emitter<RegistroMaquinaState> emit,
  ) async {
    try {
      developer.log(
        '📋 Buscando máquina ID: ${event.id}',
        name: 'RegistroMaquinaBloc',
      );
      emit(const RegistroMaquinaLoading());

      final result = await getMaquinaById(GetMaquinaByIdParams(id: event.id));

      result.fold(
        (failure) {
          final message = _getFailureMessage(failure);
          developer.log(
            '❌ Erro ao buscar máquina: $message',
            name: 'RegistroMaquinaBloc',
          );
          emit(RegistroMaquinaError(message: message));
        },
        (maquina) {
          developer.log(
            '✅ Máquina carregada: ${maquina.nome}',
            name: 'RegistroMaquinaBloc',
          );
          emit(RegistroMaquinaLoaded(maquina: maquina));
        },
      );
    } catch (e) {
      developer.log(
        '❌ Erro inesperado ao buscar máquina: $e',
        name: 'RegistroMaquinaBloc',
      );
      emit(RegistroMaquinaError(message: 'Erro inesperado: $e'));
    }
  }

  /// Handler para atualizar máquina
  Future<void> _onUpdateMaquina(
    UpdateMaquinaEvent event,
    Emitter<RegistroMaquinaState> emit,
  ) async {
    try {
      developer.log(
        '📋 Atualizando máquina: ${event.maquina.nome}',
        name: 'RegistroMaquinaBloc',
      );
      emit(RegistroMaquinaUpdating(maquina: event.maquina));

      final result = await updateMaquina(
        UpdateMaquinaParams(maquina: event.maquina),
      );

      result.fold(
        (failure) {
          final message = _getFailureMessage(failure);
          developer.log(
            '❌ Erro ao atualizar máquina: $message',
            name: 'RegistroMaquinaBloc',
          );
          emit(RegistroMaquinaError(message: message));
        },
        (maquina) {
          developer.log(
            '✅ Máquina atualizada: ${maquina.nome}',
            name: 'RegistroMaquinaBloc',
          );
          emit(RegistroMaquinaUpdated(maquina: maquina));
        },
      );
    } catch (e) {
      developer.log(
        '❌ Erro inesperado ao atualizar máquina: $e',
        name: 'RegistroMaquinaBloc',
      );
      emit(RegistroMaquinaError(message: 'Erro inesperado: $e'));
    }
  }

  /// Handler para limpar estado
  void _onClearRegistroMaquina(
    ClearRegistroMaquinaEvent event,
    Emitter<RegistroMaquinaState> emit,
  ) {
    developer.log(
      '🧹 Limpando estado do registro de máquina',
      name: 'RegistroMaquinaBloc',
    );
    emit(const RegistroMaquinaInitial());
  }

  /// Handler para resetar status de atualização
  void _onResetUpdateStatus(
    ResetUpdateStatusEvent event,
    Emitter<RegistroMaquinaState> emit,
  ) {
    if (state is RegistroMaquinaUpdated) {
      final currentState = state as RegistroMaquinaUpdated;
      developer.log(
        '🔄 Resetando status de atualização',
        name: 'RegistroMaquinaBloc',
      );
      emit(RegistroMaquinaLoaded(maquina: currentState.maquina));
    }
  }

  /// Handler para carregar lista de todas as máquinas
  Future<void> _onGetAllMaquinas(
    GetAllMaquinasEvent event,
    Emitter<RegistroMaquinaState> emit,
  ) async {
    try {
      developer.log(
        '📋 Carregando lista de máquinas',
        name: 'RegistroMaquinaBloc',
      );
      emit(const RegistroMaquinaLoading());

      final result = await getAllMaquinas(NoParams());

      result.fold(
        (failure) {
          final message = _getFailureMessage(failure);
          developer.log(
            '❌ Erro ao carregar máquinas: $message',
            name: 'RegistroMaquinaBloc',
          );
          emit(RegistroMaquinaError(message: message));
        },
        (maquinas) {
          developer.log(
            '✅ ${maquinas.length} máquinas carregadas',
            name: 'RegistroMaquinaBloc',
          );
          emit(RegistroMaquinasLoaded(maquinas: maquinas));
        },
      );
    } catch (e) {
      developer.log(
        '❌ Erro inesperado ao carregar máquinas: $e',
        name: 'RegistroMaquinaBloc',
      );
      emit(RegistroMaquinaError(message: 'Erro inesperado: $e'));
    }
  }

  /// Handler para buscar a máquina atual do dispositivo
  Future<void> _onGetCurrentDeviceMachine(
    GetCurrentDeviceMachineEvent event,
    Emitter<RegistroMaquinaState> emit,
  ) async {
    try {
      developer.log(
        '📱 Buscando máquina atual do dispositivo',
        name: 'RegistroMaquinaBloc',
      );
      emit(const RegistroMaquinaLoading());

      final result = await getCurrentDeviceMachine();

      result.fold(
        (failure) {
          final message = _getFailureMessage(failure);
          developer.log(
            '❌ Erro ao buscar máquina atual: $message',
            name: 'RegistroMaquinaBloc',
          );
          emit(RegistroMaquinaError(message: message));
        },
        (currentMachine) {
          if (currentMachine != null) {
            developer.log(
              '✅ Máquina atual encontrada: ${currentMachine.nome}',
              name: 'RegistroMaquinaBloc',
            );
          } else {
            developer.log(
              'ℹ️ Nenhuma máquina configurada para este dispositivo',
              name: 'RegistroMaquinaBloc',
            );
          }
          emit(CurrentDeviceMachineLoaded(currentMachine: currentMachine));
        },
      );
    } catch (e) {
      developer.log(
        '❌ Erro inesperado ao buscar máquina atual: $e',
        name: 'RegistroMaquinaBloc',
      );
      emit(RegistroMaquinaError(message: 'Erro inesperado: $e'));
    }
  }

  /// Extrai a mensagem de erro de um Failure
  String _getFailureMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return failure.message;
    } else if (failure is CacheFailure) {
      return failure.message;
    } else {
      return 'Erro desconhecido';
    }
  }
}