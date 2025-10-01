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

part 'injection_event.dart';
part 'injection_state.dart';

/// BLoC responsável por gerenciar o estado das injeções
/// Versão simplificada para testes iniciais
class InjectionBloc extends Bloc<InjectionEvent, InjectionState> {
  final ValidarCarcacaUseCase? _validarCarcacaUseCase;
  final GetCurrentMachineConfig? _getCurrentMachineConfig;
  final ControlarSonoffUseCase? _controlarSonoffUseCase;
  Timer? _timer;

  InjectionBloc({
    ValidarCarcacaUseCase? validarCarcacaUseCase,
    GetCurrentMachineConfig? getCurrentMachineConfig,
    ControlarSonoffUseCase? controlarSonoffUseCase,
  }) : _validarCarcacaUseCase = validarCarcacaUseCase,
       _getCurrentMachineConfig = getCurrentMachineConfig,
       _controlarSonoffUseCase = controlarSonoffUseCase,
       super(InjectionInitial()) {
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
        (validacao) => emit(InjectionCarcacaValidada(
          numeroEtiqueta: event.numeroEtiqueta,
          matrizDescricao: validacao.matriz.descricao,
          tempoInjecao: validacao.tempoInjecao,
          isMatrizCompativel: validacao.isMatrizCompativel,
        )),
      );
    } catch (e) {
      emit(InjectionCarcacaValidationError(message: e.toString()));
    }
  }

  void _onIniciarInjecaoAr(InjectionIniciarInjecaoAr event, Emitter<InjectionState> emit) async {
    print('🚀 [INJECTION] Iniciando injeção de ar para etiqueta: ${event.numeroEtiqueta}, tempo: ${event.tempoInjecao}s');
    emit(InjectionLoading());
    
    try {
      // Ligar o relé do Sonoff
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

      // Iniciar timer de injeção
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
        await _controlarSonoffUseCase!.desligarRele();
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