import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import '../../domain/entities/regra.dart';
import '../../domain/entities/processo_injecao.dart';
import '../../domain/usecases/validar_carcaca_usecase.dart';
import '../../domain/usecases/controlar_sonoff_usecase.dart';
import '../../../machine/domain/usecases/get_current_machine_config.dart';
import '../../../../core/services/device_info_service.dart';
import '../../../../core/errors/failures.dart';
import '../../data/datasources/vulcanizacao_remote_datasource.dart';
import '../../data/models/pneu_vulcanizado_create_dto.dart';
import '../../data/models/pneu_vulcanizado_response_dto.dart';
import '../../../auth/domain/usecases/get_current_user.dart';

part 'injection_event.dart';
part 'injection_state.dart';

/// BLoC responsável por gerenciar o estado das injeções
/// Versão simplificada para testes iniciais
class InjectionBloc extends Bloc<InjectionEvent, InjectionState> {
  final ValidarCarcacaUseCase? _validarCarcacaUseCase;
  final GetCurrentMachineConfig? _getCurrentMachineConfig;
  final ControlarSonoffUseCase? _controlarSonoffUseCase;
  final VulcanizacaoRemoteDataSource? _vulcanizacaoDataSource;
  final GetCurrentUser? _getCurrentUser;
  Timer? _timer;
  PneuVulcanizadoResponseDTO? _currentPneuVulcanizado;
  int? _currentProducaoId;

  InjectionBloc({
    ValidarCarcacaUseCase? validarCarcacaUseCase,
    GetCurrentMachineConfig? getCurrentMachineConfig,
    ControlarSonoffUseCase? controlarSonoffUseCase,
    VulcanizacaoRemoteDataSource? vulcanizacaoDataSource,
    GetCurrentUser? getCurrentUser,
  }) : _validarCarcacaUseCase = validarCarcacaUseCase,
       _getCurrentMachineConfig = getCurrentMachineConfig,
       _controlarSonoffUseCase = controlarSonoffUseCase,
       _vulcanizacaoDataSource = vulcanizacaoDataSource,
       _getCurrentUser = getCurrentUser,
       super(InjectionInitial()) {
    // Debug logs para verificar dependências
    print('🔧 [INJECTION] Inicializando InjectionBloc...');
    print('🔧 [INJECTION] VulcanizacaoDataSource: ${_vulcanizacaoDataSource != null ? "✅ Disponível" : "❌ Nulo"}');
    print('🔧 [INJECTION] GetCurrentUser: ${_getCurrentUser != null ? "✅ Disponível" : "❌ Nulo"}');
    print('🔧 [INJECTION] ControlarSonoffUseCase: ${_controlarSonoffUseCase != null ? "✅ Disponível" : "❌ Nulo"}');
    on<InjectionLoadRegras>(_onLoadRegras);
    on<InjectionLoadCurrentActiveProcess>(_onLoadCurrentActiveProcess);
    on<InjectionLoadProcessesByStatus>(_onLoadProcessesByStatus);
    on<InjectionStartProcess>(_onStartProcess);
    on<InjectionResumeProcess>(_onResumeProcess);
    on<InjectionCancelProcess>(_onCancelProcess);
    on<InjectionFinishProcess>(_onFinishProcess);
    on<InjectionValidarCarcaca>(_onValidarCarcaca);
    on<InjectionIniciarInjecaoAr>(_onIniciarInjecaoAr);
    on<InjectionUpdateTimer>(_onUpdateTimer);
    on<InjectionFinalizarInjecaoAr>(_onFinalizarInjecaoAr);
    on<InjectionCancelarInjecaoAr>(_onCancelarInjecaoAr);
  }

  @override
  Future<void> close() {
    _timer?.cancel();
    return super.close();
  }

  void _onLoadRegras(InjectionLoadRegras event, Emitter<InjectionState> emit) async {
    emit(InjectionLoading());
    try {
      // TODO: Implement actual data loading
      emit(const InjectionRegrasLoaded(regras: []));
    } catch (e) {
      emit(InjectionError(message: e.toString()));
    }
  }

  void _onLoadCurrentActiveProcess(InjectionLoadCurrentActiveProcess event, Emitter<InjectionState> emit) async {
    emit(InjectionLoading());
    try {
      // TODO: Implement actual active process loading
      // For now, check if there's an active process (simulate no active process)
      emit(InjectionInitial());
    } catch (e) {
      emit(InjectionError(message: e.toString()));
    }
  }

  void _onLoadProcessesByStatus(InjectionLoadProcessesByStatus event, Emitter<InjectionState> emit) async {
    emit(InjectionLoading());
    try {
      // TODO: Implement actual processes loading by status
      // For now, return empty list
      emit(const InjectionProcessesLoaded(processos: []));
    } catch (e) {
      emit(InjectionError(message: e.toString()));
    }
  }

  void _onStartProcess(InjectionStartProcess event, Emitter<InjectionState> emit) async {
    emit(InjectionLoading());
    try {
      // TODO: Implement process start logic
      // For now, create a dummy process
      final dummyProcess = ProcessoInjecao(
        id: 'dummy-1',
        carcacaId: 1,
        carcacaCodigo: 'DUMMY',
        regraId: 1,
        matrizId: 1,
        matrizNome: 'Matriz Teste',
        status: StatusProcesso.injetando,
        tempoTotal: 3600,
        pressaoInicial: 0.0,
        pressaoAtual: 0.0,
        pressaoAlvo: 100.0,
        iniciadoEm: DateTime.now(),
        userId: 1,
        userName: 'Usuário Teste',
      );
      emit(InjectionProcessStarted(processo: dummyProcess));
    } catch (e) {
      emit(InjectionError(message: e.toString()));
    }
  }

  void _onValidarCarcaca(InjectionValidarCarcaca event, Emitter<InjectionState> emit) async {
    emit(InjectionLoading());
    try {
      if (_validarCarcacaUseCase == null) {
        emit(const InjectionCarcacaValidationError(message: 'Use case não configurado'));
        return;
      }

      final params = ValidarCarcacaParams(
        numeroEtiqueta: event.numeroEtiqueta,
        deviceId: event.deviceId,
        userId: event.userId,
      );
      final result = await _validarCarcacaUseCase!.call(params);

      result.fold(
        (failure) => emit(InjectionCarcacaValidationError(message: _getFailureMessage(failure))),
        (validacao) {
          // Armazenar producaoId real para uso na criação do pneu vulcanizado
          _currentProducaoId = validacao.producaoResponse.id;
          print('🧩 [INJECTION] producaoId definido: $_currentProducaoId');

          emit(InjectionCarcacaValidada(
            numeroEtiqueta: event.numeroEtiqueta,
            matrizDescricao: validacao.matriz.descricao,
            tempoInjecao: validacao.tempoInjecao,
            isMatrizCompativel: validacao.isMatrizCompativel,
          ));
        },
      );
    } catch (e) {
      emit(InjectionCarcacaValidationError(message: e.toString()));
    }
  }

  void _onIniciarInjecaoAr(InjectionIniciarInjecaoAr event, Emitter<InjectionState> emit) async {
    print('🚀 [INJECTION] Iniciando injeção de ar para etiqueta: ${event.numeroEtiqueta}, tempo: ${event.tempoInjecao}s');
    emit(InjectionLoading());
    
    try {
      // 1. Criar registro de pneu vulcanizado com status INICIADO
      print('💾 [INJECTION] Criando registro de pneu vulcanizado na API...');
      print('🧩 [INJECTION] producaoId atual: ${_currentProducaoId ?? "❌ Nulo"}');
      if (_vulcanizacaoDataSource != null && _getCurrentUser != null) {
        try {
          // Obter usuário atual
          final userResult = await _getCurrentUser!.call();
          final userId = userResult.fold(
            (failure) {
              print('⚠️ [INJECTION] Erro ao obter usuário atual: ${failure.toString()}');
              return 1; // Fallback para usuário ID 1
            },
            (user) => user.id,
          );

          // Criar DTO para registro de pneu vulcanizado
          if (_currentProducaoId == null) {
            print('⚠️ [INJECTION] AVISO: producaoId não definido. Pule a criação na API.');
          } else {
            final createDto = PneuVulcanizadoCreateDTO(
              usuarioId: userId,
              producaoId: _currentProducaoId!,
            );

            // Criar registro na API
            final pneuVulcanizado = await _vulcanizacaoDataSource!.criarPneuVulcanizado(createDto);
            _currentPneuVulcanizado = pneuVulcanizado;
            print('✅ [INJECTION] Registro de pneu vulcanizado criado com ID: ${pneuVulcanizado.id}');
            print('🔍 [INJECTION] _currentPneuVulcanizado definido: ${_currentPneuVulcanizado?.id}');
          }
        } catch (apiError) {
          print('💥 [INJECTION] ERRO ao criar registro de pneu vulcanizado: $apiError');
          final apiMsg = apiError.toString();
          // Validação: não permitir iniciar nova injeção se já existir um pneu vulcanizado para usuário+produção
          if (apiMsg.contains('Já existe um pneu vulcanizado')) {
            print('❌ [INJECTION] Validação: já existe pneu vulcanizado para este usuário e produção. Abortando início da injeção.');
            emit(const InjectionError(
              message: 'Já existe um pneu vulcanizado para este usuário e produção. Finalize o processo existente antes de iniciar outro.',
            ));
            return;
          }
          // Outros erros: permitir continuar (sem registro na API)
          print('⚠️ [INJECTION] Continuando processo sem registro na API...');
        }
      } else {
        print('⚠️ [INJECTION] AVISO: VulcanizacaoDataSource ou GetCurrentUser não disponível');
      }

      // 2. Ligar o relé do Sonoff
      print('🔌 [INJECTION] Verificando controle do Sonoff...');
      if (_controlarSonoffUseCase != null) {
        print('✅ [INJECTION] ControlarSonoffUseCase disponível, tentando ligar relé...');
        try {
          final releStatus = await _controlarSonoffUseCase!.ligarRele();
          print('📡 [INJECTION] Status do relé após tentativa de ligar: $releStatus');
          
          if (!releStatus) {
            print('❌ [INJECTION] ERRO: Falha ao ligar o relé do Sonoff');
            emit(const InjectionError(message: 'Erro ao ligar o relé do Sonoff'));
            return;
          }
          print('✅ [INJECTION] Relé ligado com sucesso!');
        } catch (releError) {
          print('💥 [INJECTION] ERRO ao comunicar com Sonoff: $releError');
          emit(InjectionError(message: 'Erro de comunicação com Sonoff: $releError'));
          return;
        }
      } else {
        print('⚠️ [INJECTION] AVISO: ControlarSonoffUseCase é null - relé não será controlado');
      }

      // 3. Iniciar timer de injeção
      print('⏱️ [INJECTION] Configurando timer de injeção...');
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        final tempoRestante = event.tempoInjecao - timer.tick;
        if (tempoRestante >= 0) {
          add(InjectionUpdateTimer(tempoRestante: tempoRestante));
        }
      });
      print('✅ [INJECTION] Timer configurado com sucesso');

      print('🎯 [INJECTION] Emitindo estado de injeção em andamento...');
      emit(InjectionInjecaoArEmAndamento(
        numeroEtiqueta: event.numeroEtiqueta,
        tempoTotal: event.tempoInjecao,
        tempoRestante: event.tempoInjecao,
      ));
      print('✅ [INJECTION] Injeção de ar iniciada com sucesso!');
      
    } catch (e, stackTrace) {
      print('💥 [INJECTION] ERRO GERAL ao iniciar injeção: $e');
      print('📍 [INJECTION] Stack trace: $stackTrace');
      emit(InjectionError(message: 'Erro ao iniciar injeção: $e'));
    }
  }

  void _onUpdateTimer(InjectionUpdateTimer event, Emitter<InjectionState> emit) {
    final currentState = state;
    if (currentState is InjectionInjecaoArEmAndamento) {
      emit(InjectionInjecaoArEmAndamento(
        numeroEtiqueta: currentState.numeroEtiqueta,
        tempoTotal: currentState.tempoTotal,
        tempoRestante: event.tempoRestante,
      ));

      // Finalizar automaticamente quando atingir o tempo zero
      if (event.tempoRestante <= 0) {
        add(const InjectionFinalizarInjecaoAr());
      }
    }
  }

  void _onFinalizarInjecaoAr(InjectionFinalizarInjecaoAr event, Emitter<InjectionState> emit) async {
    print('🏁 [INJECTION] Finalizando injeção de ar...');
    _timer?.cancel();
    print('⏱️ [INJECTION] Timer cancelado');
    
    // Finalizar registro de pneu vulcanizado na API
    print('💾 [INJECTION] Finalizando registro de pneu vulcanizado na API...');
    print('🔍 [INJECTION] Estado das dependências:');
    print('🔍 [INJECTION] _vulcanizacaoDataSource: ${_vulcanizacaoDataSource != null ? "✅ Disponível" : "❌ Nulo"}');
    print('🔍 [INJECTION] _currentPneuVulcanizado: ${_currentPneuVulcanizado != null ? "✅ ID: ${_currentPneuVulcanizado!.id}" : "❌ Nulo"}');
    
    // Fallback: tentar localizar o pneu iniciado por producaoId quando o ID não está disponível
    if (_vulcanizacaoDataSource != null && _currentPneuVulcanizado == null && _currentProducaoId != null) {
      try {
        print('🔎 [INJECTION] Buscando pneus INICIADOS para fallback por producaoId=$_currentProducaoId');
        final iniciados = await _vulcanizacaoDataSource!.listarPneusVulcanizados(status: 'INICIADO');
        PneuVulcanizadoResponseDTO? encontrado;
        for (final pneu in iniciados) {
          if (pneu.producaoId == _currentProducaoId) {
            encontrado = pneu;
            break;
          }
        }
        if (encontrado != null) {
          print('🔗 [INJECTION] Pneu iniciado encontrado (ID=${encontrado.id}). Tentando finalizar via fallback...');
          try {
            print('🔁 [INJECTION] Enviando ID da vulcanização localizada por producaoId (${_currentProducaoId}): ${encontrado.id} para atualização (finalizar)');
            print('📤 [INJECTION] Chamando finalizarPneuVulcanizado(id=${encontrado.id}) via fallback');
            final finalizado = await _vulcanizacaoDataSource!.finalizarPneuVulcanizado(encontrado.id);
            print('✅ [INJECTION] Finalização via fallback concluída! ID: ${finalizado.id}, Status: ${finalizado.status}');
            _currentPneuVulcanizado = finalizado;
          } catch (apiErr) {
            print('💥 [INJECTION] ERRO ao finalizar via fallback: $apiErr');
          }
        } else {
          print('⚠️ [INJECTION] Nenhum pneu INICIADO encontrado para producaoId=$_currentProducaoId');
        }
      } catch (listErr) {
        print('💥 [INJECTION] ERRO ao listar pneus INICIADOS para fallback: $listErr');
      }
    }
    if (_vulcanizacaoDataSource != null && _currentPneuVulcanizado != null) {
      try {
        print('🔁 [INJECTION] Enviando ID da vulcanização criada no início: ${_currentPneuVulcanizado!.id} para atualização (finalizar)');
        print('📤 [INJECTION] Chamando finalizarPneuVulcanizado(id=${_currentPneuVulcanizado!.id})');
        final pneuFinalizado = await _vulcanizacaoDataSource!.finalizarPneuVulcanizado(_currentPneuVulcanizado!.id);
        print('✅ [INJECTION] Pneu vulcanizado finalizado com sucesso! ID: ${pneuFinalizado.id}, Status: ${pneuFinalizado.status}');
        _currentPneuVulcanizado = pneuFinalizado;
      } catch (apiError) {
        print('💥 [INJECTION] ERRO ao finalizar registro de pneu vulcanizado: $apiError');
        // Continuar com o processo mesmo se a API falhar
        print('⚠️ [INJECTION] Continuando processo mesmo com erro na API...');
      }
    } else {
      print('⚠️ [INJECTION] AVISO: VulcanizacaoDataSource não disponível ou nenhum pneu vulcanizado ativo');
    }
    
    // Limpar referência do pneu vulcanizado atual APÓS finalização na API
    _currentPneuVulcanizado = null;
    print('🧹 [INJECTION] Referência do pneu vulcanizado limpa');
    
    // Desligar o relé do Sonoff
    if (_controlarSonoffUseCase != null) {
      print('🔌 [INJECTION] Desligando relé do Sonoff...');
      try {
        final releStatus = await _controlarSonoffUseCase!.desligarRele();
        print('📡 [INJECTION] Status do relé após desligar: $releStatus');
        if (releStatus) {
          print('✅ [INJECTION] Relé desligado com sucesso!');
        } else {
          print('⚠️ [INJECTION] AVISO: Falha ao desligar relé');
        }
      } catch (e) {
        // Log do erro mas não impede a finalização
        print('💥 [INJECTION] ERRO ao desligar relé: $e');
      }
    } else {
      print('⚠️ [INJECTION] AVISO: ControlarSonoffUseCase é null - relé não será desligado');
    }
    
    final currentState = state;
    if (currentState is InjectionInjecaoArEmAndamento) {
      print('🎯 [INJECTION] Emitindo estado de injeção finalizada...');
      emit(InjectionInjecaoArFinalizada(
        numeroEtiqueta: currentState.numeroEtiqueta,
        sucesso: true,
      ));
      print('✅ [INJECTION] Injeção finalizada com sucesso! Pneu pronto: ${currentState.numeroEtiqueta}');
    }
  }

  void _onCancelarInjecaoAr(InjectionCancelarInjecaoAr event, Emitter<InjectionState> emit) async {
    _timer?.cancel();
    
    // Desligar o relé do Sonoff
    if (_controlarSonoffUseCase != null) {
      try {
        await _controlarSonoffUseCase.desligarRele();
      } catch (e) {
        // Log do erro mas não impede o cancelamento
        print('Erro ao desligar relé: $e');
      }
    }
    
    final currentState = state;
    if (currentState is InjectionInjecaoArEmAndamento) {
      emit(InjectionInjecaoArCancelada(numeroEtiqueta: currentState.numeroEtiqueta));
    }
  }

  void _onResumeProcess(InjectionResumeProcess event, Emitter<InjectionState> emit) async {
    emit(InjectionLoading());
    try {
      // TODO: Implement process resume logic
      final dummyProcess = ProcessoInjecao(
        id: 'dummy-1',
        carcacaId: 1,
        carcacaCodigo: 'DUMMY',
        regraId: 1,
        matrizId: 1,
        matrizNome: 'Matriz Teste',
        status: StatusProcesso.injetando,
        tempoTotal: 3600,
        pressaoInicial: 0.0,
        pressaoAtual: 50.0,
        pressaoAlvo: 100.0,
        iniciadoEm: DateTime.now().subtract(const Duration(minutes: 30)),
        userId: 1,
        userName: 'Usuário Teste',
      );
      emit(InjectionProcessResumed(processo: dummyProcess));
    } catch (e) {
      emit(InjectionError(message: e.toString()));
    }
  }

  void _onCancelProcess(InjectionCancelProcess event, Emitter<InjectionState> emit) async {
    emit(InjectionLoading());
    try {
      // TODO: Implement process cancel logic
      final dummyProcess = ProcessoInjecao(
        id: 'dummy-1',
        carcacaId: 1,
        carcacaCodigo: 'DUMMY',
        regraId: 1,
        matrizId: 1,
        matrizNome: 'Matriz Teste',
        status: StatusProcesso.cancelado,
        tempoTotal: 3600,
        pressaoInicial: 0.0,
        pressaoAtual: 50.0,
        pressaoAlvo: 100.0,
        iniciadoEm: DateTime.now().subtract(const Duration(minutes: 30)),
        userId: 1,
        userName: 'Usuário Teste',
        motivoErro: 'Cancelado pelo usuário',
      );
      emit(InjectionProcessCanceled(processo: dummyProcess));
    } catch (e) {
      emit(InjectionError(message: e.toString()));
    }
  }

  void _onFinishProcess(InjectionFinishProcess event, Emitter<InjectionState> emit) async {
    emit(InjectionLoading());
    try {
      // TODO: Implement process finish logic
      final dummyProcess = ProcessoInjecao(
        id: 'dummy-1',
        carcacaId: 1,
        carcacaCodigo: 'DUMMY',
        regraId: 1,
        matrizId: 1,
        matrizNome: 'Matriz Teste',
        status: StatusProcesso.concluido,
        tempoTotal: 3600,
        pressaoInicial: 0.0,
        pressaoAtual: 100.0,
        pressaoAlvo: 100.0,
        iniciadoEm: DateTime.now().subtract(const Duration(hours: 1)),
        finalizadoEm: DateTime.now(),
        userId: 1,
        userName: 'Usuário Teste',
      );
      emit(InjectionProcessFinished(processo: dummyProcess));
    } catch (e) {
      emit(InjectionError(message: e.toString()));
    }
  }

  /// Extrai a mensagem de erro específica de um Failure
  String _getFailureMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ValidationFailure:
        return (failure as ValidationFailure).message;
      case NetworkFailure:
        return (failure as NetworkFailure).message;
      case ServerFailure:
        return (failure as ServerFailure).message;
      case DeviceFailure:
        return (failure as DeviceFailure).message;
      case AuthenticationFailure:
        return (failure as AuthenticationFailure).message;
      case AuthorizationFailure:
        return (failure as AuthorizationFailure).message;
      case NotFoundFailure:
        return (failure as NotFoundFailure).message;
      case CacheFailure:
        return (failure as CacheFailure).message;
      case HardwareFailure:
        return (failure as HardwareFailure).message;
      default:
        return 'Erro desconhecido';
    }
  }
}