import 'package:bloc/bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/usecases/create_configuracao_maquina.dart' as create_usecase;
import '../../domain/usecases/delete_configuracao_maquina.dart' as delete_usecase;
import '../../domain/usecases/get_configuracao_by_maquina_and_chave.dart';
import '../../domain/usecases/get_configuracao_maquina_by_id.dart';
import '../../domain/usecases/get_configuracoes_maquina.dart';
import '../../domain/usecases/update_configuracao_maquina.dart' as update_usecase;
import 'configuracao_maquina_event.dart';
import 'configuracao_maquina_state.dart';

/// BLoC para gerenciar o estado das configurações de máquina
class ConfiguracaoMaquinaBloc extends Bloc<ConfiguracaoMaquinaEvent, ConfiguracaoMaquinaState> {
  final GetConfiguracoesMaquina _getConfiguracoesMaquina;
  final GetConfiguracaoMaquinaById _getConfiguracaoMaquinaById;
  final create_usecase.CreateConfiguracaoMaquina _createConfiguracaoMaquina;
  final update_usecase.UpdateConfiguracaoMaquina _updateConfiguracaoMaquina;
  final delete_usecase.DeleteConfiguracaoMaquina _deleteConfiguracaoMaquina;
  final GetConfiguracaoByMaquinaAndChave _getConfiguracaoByMaquinaAndChave;

  ConfiguracaoMaquinaBloc({
    required GetConfiguracoesMaquina getConfiguracoesMaquina,
    required GetConfiguracaoMaquinaById getConfiguracaoMaquinaById,
    required create_usecase.CreateConfiguracaoMaquina createConfiguracaoMaquina,
    required update_usecase.UpdateConfiguracaoMaquina updateConfiguracaoMaquina,
    required delete_usecase.DeleteConfiguracaoMaquina deleteConfiguracaoMaquina,
    required GetConfiguracaoByMaquinaAndChave getConfiguracaoByMaquinaAndChave,
  })  : _getConfiguracoesMaquina = getConfiguracoesMaquina,
        _getConfiguracaoMaquinaById = getConfiguracaoMaquinaById,
        _createConfiguracaoMaquina = createConfiguracaoMaquina,
        _updateConfiguracaoMaquina = updateConfiguracaoMaquina,
        _deleteConfiguracaoMaquina = deleteConfiguracaoMaquina,
        _getConfiguracaoByMaquinaAndChave = getConfiguracaoByMaquinaAndChave,
        super(const ConfiguracaoMaquinaInitial()) {
    on<LoadConfiguracoesMaquina>(_onLoadConfiguracoesMaquina);
    on<LoadConfiguracaoMaquinaById>(_onLoadConfiguracaoMaquinaById);
    on<CreateConfiguracaoMaquina>(_onCreateConfiguracaoMaquina);
    on<UpdateConfiguracaoMaquina>(_onUpdateConfiguracaoMaquina);
    on<DeleteConfiguracaoMaquina>(_onDeleteConfiguracaoMaquina);
    on<LoadConfiguracaoByMaquinaAndChave>(_onLoadConfiguracaoByMaquinaAndChave);
    on<ResetConfiguracaoMaquinaState>(_onResetState);
    on<ClearConfiguracaoMaquinaMessages>(_onClearMessages);
  }

  /// Handler para carregar configurações com filtros
  Future<void> _onLoadConfiguracoesMaquina(
    LoadConfiguracoesMaquina event,
    Emitter<ConfiguracaoMaquinaState> emit,
  ) async {
    emit(const ConfiguracaoMaquinaLoading());

    final params = GetConfiguracoesMaquinaParams(
      registroMaquinaId: event.registroMaquinaId,
      chaveConfiguracao: event.chaveConfiguracao,
      ativo: event.ativo,
      page: event.page,
      size: event.size,
    );

    final result = await _getConfiguracoesMaquina(params);

    result.fold(
      (failure) => emit(ConfiguracaoMaquinaError(
        message: _getFailureMessage(failure),
        errorCode: _getFailureCode(failure),
      )),
      (paginatedResponse) => emit(ConfiguracoesMaquinaLoaded(
        configuracoes: paginatedResponse.content,
        totalElements: paginatedResponse.totalElements,
        currentPage: paginatedResponse.number,
        totalPages: paginatedResponse.totalPages,
      )),
    );
  }

  /// Handler para carregar configuração por ID
  Future<void> _onLoadConfiguracaoMaquinaById(
    LoadConfiguracaoMaquinaById event,
    Emitter<ConfiguracaoMaquinaState> emit,
  ) async {
    emit(const ConfiguracaoMaquinaLoading());

    final params = GetConfiguracaoMaquinaByIdParams(id: event.id);
    final result = await _getConfiguracaoMaquinaById(params);

    result.fold(
      (failure) => emit(ConfiguracaoMaquinaError(
        message: _getFailureMessage(failure),
        errorCode: _getFailureCode(failure),
      )),
      (configuracao) => emit(ConfiguracaoMaquinaLoaded(configuracao: configuracao)),
    );
  }

  /// Handler para criar nova configuração
  Future<void> _onCreateConfiguracaoMaquina(
    CreateConfiguracaoMaquina event,
    Emitter<ConfiguracaoMaquinaState> emit,
  ) async {
    emit(const ConfiguracaoMaquinaLoading());

    final result = await _createConfiguracaoMaquina(event.configuracao);

    result.fold(
      (failure) => _handleFailure(failure, emit),
      (configuracao) => emit(ConfiguracaoMaquinaCreated(configuracao: configuracao)),
    );
  }

  /// Handler para atualizar configuração
  Future<void> _onUpdateConfiguracaoMaquina(
    UpdateConfiguracaoMaquina event,
    Emitter<ConfiguracaoMaquinaState> emit,
  ) async {
    emit(const ConfiguracaoMaquinaLoading());

    final params = update_usecase.UpdateConfiguracaoMaquinaParams(
      id: event.id,
      configuracao: event.configuracao,
    );
    final result = await _updateConfiguracaoMaquina(params);

    result.fold(
      (failure) => _handleFailure(failure, emit),
      (configuracao) => emit(ConfiguracaoMaquinaUpdated(configuracao: configuracao)),
    );
  }

  /// Handler para deletar configuração
  Future<void> _onDeleteConfiguracaoMaquina(
    DeleteConfiguracaoMaquina event,
    Emitter<ConfiguracaoMaquinaState> emit,
  ) async {
    emit(const ConfiguracaoMaquinaLoading());

    final params = delete_usecase.DeleteConfiguracaoMaquinaParams(id: event.id);
    final result = await _deleteConfiguracaoMaquina(params);

    result.fold(
      (failure) => emit(ConfiguracaoMaquinaError(
        message: _getFailureMessage(failure),
        errorCode: _getFailureCode(failure),
      )),
      (_) => emit(const ConfiguracaoMaquinaDeleted()),
    );
  }

  /// Handler para buscar configuração por máquina e chave
  Future<void> _onLoadConfiguracaoByMaquinaAndChave(
    LoadConfiguracaoByMaquinaAndChave event,
    Emitter<ConfiguracaoMaquinaState> emit,
  ) async {
    emit(const ConfiguracaoMaquinaLoading());

    final params = GetConfiguracaoByMaquinaAndChaveParams(
      registroMaquinaId: event.registroMaquinaId,
      chaveConfiguracao: event.chaveConfiguracao,
    );
    final result = await _getConfiguracaoByMaquinaAndChave(params);

    result.fold(
      (failure) => emit(ConfiguracaoMaquinaError(
        message: _getFailureMessage(failure),
        errorCode: _getFailureCode(failure),
      )),
      (configuracao) => emit(ConfiguracaoMaquinaLoaded(configuracao: configuracao)),
    );
  }

  /// Handler para resetar o estado
  void _onResetState(
    ResetConfiguracaoMaquinaState event,
    Emitter<ConfiguracaoMaquinaState> emit,
  ) {
    emit(const ConfiguracaoMaquinaInitial());
  }

  /// Handler para limpar mensagens
  void _onClearMessages(
    ClearConfiguracaoMaquinaMessages event,
    Emitter<ConfiguracaoMaquinaState> emit,
  ) {
    if (state is ConfiguracaoMaquinaError ||
        state is ConfiguracaoMaquinaCreated ||
        state is ConfiguracaoMaquinaUpdated ||
        state is ConfiguracaoMaquinaDeleted) {
      emit(const ConfiguracaoMaquinaInitial());
    }
  }

  /// Trata falhas específicas de validação
  void _handleFailure(Failure failure, Emitter<ConfiguracaoMaquinaState> emit) {
    if (failure is ValidationFailure && failure.errors != null) {
      emit(ConfiguracaoMaquinaValidationError(errors: failure.errors!));
    } else {
      emit(ConfiguracaoMaquinaError(
        message: _getFailureMessage(failure),
        errorCode: _getFailureCode(failure),
      ));
    }
  }

  /// Mapeia falhas para mensagens de erro
  String _getFailureMessage(Failure failure) {
    if (failure is ServerFailure) {
      return failure.message;
    } else if (failure is NetworkFailure) {
      return failure.message;
    } else if (failure is ValidationFailure) {
      return failure.message;
    } else if (failure is AuthorizationFailure) {
      return failure.message;
    } else if (failure is NotFoundFailure) {
      return failure.message;
    } else {
      return 'Erro inesperado. Tente novamente.';
    }
  }

  /// Obtém código de erro da falha
  String? _getFailureCode(Failure failure) {
    if (failure is ServerFailure) return 'SERVER_ERROR';
    if (failure is NetworkFailure) return 'NETWORK_ERROR';
    if (failure is ValidationFailure) return 'VALIDATION_ERROR';
    if (failure is AuthenticationFailure) return 'AUTH_ERROR';
    if (failure is AuthorizationFailure) return 'AUTHORIZATION_ERROR';
    if (failure is NotFoundFailure) return 'NOT_FOUND';
    return null;
  }
}