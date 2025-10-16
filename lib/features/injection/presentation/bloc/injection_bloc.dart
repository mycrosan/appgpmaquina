import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'dart:async';
import '../../domain/entities/regra.dart';
import '../../domain/entities/processo_injecao.dart';
import '../../domain/usecases/validar_carcaca_usecase.dart';
import '../../domain/usecases/controlar_sonoff_usecase.dart';
import '../../data/datasources/sonoff_datasource.dart';
import '../../../machine/domain/usecases/get_current_machine_config.dart';
import '../../../../core/services/device_info_service.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/config/network_config.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
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
  SonoffDataSource? _runtimeSonoffDs;

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
      // Obter usuário atual
      int userId = 1; // Fallback
      String userName = 'Usuário Desconhecido';
      
      if (_getCurrentUser != null) {
        final userResult = await _getCurrentUser!.call();
        userResult.fold(
          (failure) {
            print('⚠️ [INJECTION] Erro ao obter usuário atual: ${failure.toString()}');
            // Mantém fallback
          },
          (user) {
             userId = user.id;
             userName = user.name ?? 'Usuário Desconhecido';
           },
        );
      }

      // Buscar carcaça por código para obter carcacaId e matrizId
      // TODO: Implementar busca real da carcaça
      // Por enquanto, usar dados do evento
      final processo = ProcessoInjecao(
        id: 'proc-${DateTime.now().millisecondsSinceEpoch}',
        carcacaId: 0, // Será definido quando implementarmos busca de carcaça
        carcacaCodigo: event.carcacaCodigo,
        regraId: event.regraId,
        matrizId: 0, // Será obtido da carcaça
        matrizNome: 'Matriz a definir',
        status: StatusProcesso.injetando,
        tempoTotal: 3600,
        pressaoInicial: event.pressaoInicial,
        pressaoAtual: event.pressaoInicial,
        pressaoAlvo: 100.0,
        iniciadoEm: DateTime.now(),
        userId: userId,
        userName: userName,
      );
      
      emit(InjectionProcessStarted(processo: processo));
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
            final displayMsg = (apiError is ServerException && apiError.message.isNotEmpty)
                ? apiError.message
                : 'Já existe um pneu vulcanizado para este usuário e produção.';
            print('❌ [INJECTION] Validação: já existe pneu vulcanizado para este usuário e produção. Abortando início da injeção. Mensagem: $displayMsg');
            emit(InjectionError(
              message: displayMsg,
            ));
            return;
          }
          // Status 500: tratar como erro bloqueante e exibir mensagem
          if (apiError is ServerException && (apiError.statusCode == 500)) {
            print('❌ [INJECTION] Erro 500 recebido. Abortando início da injeção.');
            emit(InjectionError(
              message: apiError.message,
            ));
            return;
          }
          if (apiMsg.contains('Status: 500') || apiMsg.contains('INTERNAL_SERVER_ERROR') || apiMsg.contains('Erro interno')) {
            print('❌ [INJECTION] Erro de servidor (500) detectado via mensagem. Abortando início da injeção.');
            emit(const InjectionError(
              message: 'Erro no servidor ao criar registro. Processo interrompido.',
            ));
            return;
          }
          // Demais erros: interromper e exibir mensagem genérica
          emit(InjectionError(message: 'Erro ao criar registro na API: $apiMsg'));
          return;
        }
      } else {
        print('⚠️ [INJECTION] AVISO: VulcanizacaoDataSource ou GetCurrentUser não disponível');
      }

      // 2. Ligar o relé do Sonoff (buscando IP por celularId)
      print('🔌 [INJECTION] Preparando controle do Sonoff com IP por celularId...');
      final ds = await _ensureRuntimeSonoffDataSource();
      if (ds == null) {
        // Fallback para usecase padrão, se existir
        print('⚠️ [INJECTION] Nenhum relé configurado para este celular. Tentando fallback padrão...');
        if (_controlarSonoffUseCase != null) {
          try {
            final releStatus = await _controlarSonoffUseCase!.ligarRele();
            print('📡 [INJECTION] Status do relé (fallback) após tentativa de ligar: $releStatus');
            if (!releStatus) {
              emit(const InjectionError(message: 'Nenhum relé configurado para este celular e falha no fallback ao ligar relé'));
              return;
            }
          } catch (releError) {
            emit(InjectionError(message: 'Nenhum relé configurado para este celular. Erro ao tentar fallback: $releError'));
            return;
          }
        } else {
          emit(const InjectionError(message: 'Nenhum relé configurado para este celular'));
          return;
        }
      } else {
        print('✅ [INJECTION] SonoffDataSource configurado com IP do dispositivo. Ligando relé...');
        try {
          final releStatus = await ds.ligarRele();
          print('📡 [INJECTION] Status do relé (por IP) após ligar: $releStatus');
          if (!releStatus) {
            emit(const InjectionError(message: 'Erro ao ligar o relé do Sonoff (por IP)'));
            return;
          }
        } catch (releError) {
          emit(InjectionError(message: 'Erro de comunicação com Sonoff (por IP): $releError'));
          return;
        }
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
    
    // Desligar o relé do Sonoff (usando IP por celularId quando disponível)
    print('🔌 [INJECTION] Desligando relé do Sonoff com IP do dispositivo...');
    final dsFinalizar = await _ensureRuntimeSonoffDataSource();
    if (dsFinalizar != null) {
      try {
        final releStatus = await dsFinalizar.desligarRele();
        print('📡 [INJECTION] Status do relé (por IP) após desligar: $releStatus');
      } catch (e) {
        print('💥 [INJECTION] ERRO ao desligar relé (por IP): $e');
      }
    } else if (_controlarSonoffUseCase != null) {
      try {
        final releStatus = await _controlarSonoffUseCase!.desligarRele();
        print('📡 [INJECTION] Status do relé (fallback) após desligar: $releStatus');
      } catch (e) {
        print('💥 [INJECTION] ERRO ao desligar relé (fallback): $e');
      }
    } else {
      print('⚠️ [INJECTION] AVISO: Nenhuma fonte de controle do relé disponível para desligar');
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
    
    // Desligar o relé do Sonoff (por IP quando disponível)
    final dsCancelar = await _ensureRuntimeSonoffDataSource();
    if (dsCancelar != null) {
      try {
        await dsCancelar.desligarRele();
      } catch (e) {
        print('Erro ao desligar relé (por IP): $e');
      }
    } else if (_controlarSonoffUseCase != null) {
      try {
        await _controlarSonoffUseCase.desligarRele();
      } catch (e) {
        print('Erro ao desligar relé (fallback): $e');
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
      // Obter usuário atual
      int userId = 1; // Fallback
      String userName = 'Usuário Desconhecido';
      
      if (_getCurrentUser != null) {
        final userResult = await _getCurrentUser!.call();
        userResult.fold(
          (failure) {
            print('⚠️ [INJECTION] Erro ao obter usuário atual: ${failure.toString()}');
            // Mantém fallback
          },
          (user) {
            userId = user.id;
            userName = user.name ?? 'Usuário Desconhecido';
          },
        );
      }

      // TODO: Implementar lógica real de retomada de processo
      // Por enquanto, criar processo genérico
      final processo = ProcessoInjecao(
         id: 'resume-${DateTime.now().millisecondsSinceEpoch}',
        carcacaId: 0, // Será obtido do processo existente
        carcacaCodigo: 'RETOMADA',
        regraId: 0, // Será obtido do processo existente
        matrizId: 0, // Será obtido do processo existente
        matrizNome: 'Matriz a definir',
        status: StatusProcesso.injetando,
        tempoTotal: 3600,
        pressaoInicial: 0.0,
        pressaoAtual: 50.0,
        pressaoAlvo: 100.0,
        iniciadoEm: DateTime.now().subtract(const Duration(minutes: 30)),
        userId: userId,
        userName: userName,
      );
      emit(InjectionProcessResumed(processo: processo));
    } catch (e) {
      emit(InjectionError(message: e.toString()));
    }
  }

  void _onCancelProcess(InjectionCancelProcess event, Emitter<InjectionState> emit) async {
    emit(InjectionLoading());
    try {
      // Obter usuário atual
      int userId = 1; // Fallback
      String userName = 'Usuário Desconhecido';
      
      if (_getCurrentUser != null) {
        final userResult = await _getCurrentUser!.call();
        userResult.fold(
          (failure) {
            print('⚠️ [INJECTION] Erro ao obter usuário atual: ${failure.toString()}');
            // Mantém fallback
          },
          (user) {
            userId = user.id;
            userName = user.name ?? 'Usuário Desconhecido';
          },
        );
      }

      // TODO: Implementar lógica real de cancelamento de processo
      // Por enquanto, criar processo genérico cancelado
      final processo = ProcessoInjecao(
        id: 'cancel-${DateTime.now().millisecondsSinceEpoch}',
        carcacaId: 0, // Será obtido do processo existente
        carcacaCodigo: 'CANCELADO',
        regraId: 0, // Será obtido do processo existente
        matrizId: 0, // Será obtido do processo existente
        matrizNome: 'Matriz a definir',
        status: StatusProcesso.cancelado,
        tempoTotal: 3600,
        pressaoInicial: 0.0,
        pressaoAtual: 50.0,
        pressaoAlvo: 100.0,
        iniciadoEm: DateTime.now().subtract(const Duration(minutes: 30)),
        userId: userId,
        userName: userName,
        motivoErro: event.motivo ?? 'Cancelado pelo usuário',
      );
      emit(InjectionProcessCanceled(processo: processo));
    } catch (e) {
      emit(InjectionError(message: e.toString()));
    }
  }

  void _onFinishProcess(InjectionFinishProcess event, Emitter<InjectionState> emit) async {
    emit(InjectionLoading());
    try {
      // Obter usuário atual
      int userId = 1; // Fallback
      String userName = 'Usuário Desconhecido';
      
      if (_getCurrentUser != null) {
        final userResult = await _getCurrentUser!.call();
        userResult.fold(
          (failure) {
            print('⚠️ [INJECTION] Erro ao obter usuário atual: ${failure.toString()}');
            // Mantém fallback
          },
          (user) {
            userId = user.id;
            userName = user.name ?? 'Usuário Desconhecido';
          },
        );
      }

      // TODO: Implementar lógica real de finalização de processo
      // Por enquanto, criar processo genérico finalizado
      final processo = ProcessoInjecao(
        id: 'finish-${DateTime.now().millisecondsSinceEpoch}',
        carcacaId: 0, // Será obtido do processo existente
        carcacaCodigo: 'FINALIZADO',
        regraId: 0, // Será obtido do processo existente
        matrizId: 0, // Será obtido do processo existente
        matrizNome: 'Matriz a definir',
        status: StatusProcesso.concluido,
        tempoTotal: 3600,
        pressaoInicial: 0.0,
        pressaoAtual: 100.0,
        pressaoAlvo: 100.0,
        iniciadoEm: DateTime.now().subtract(const Duration(hours: 1)),
        finalizadoEm: DateTime.now(),
        userId: userId,
        userName: userName,
      );
      emit(InjectionProcessFinished(processo: processo));
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

  /// Busca o IP do relé configurado para o celular atual e prepara um DataSource em runtime
  Future<SonoffDataSource?> _ensureRuntimeSonoffDataSource() async {
    if (_runtimeSonoffDs != null) return _runtimeSonoffDs;

    try {
      final deviceId = await DeviceInfoService.instance.getDeviceId();
      final dio = NetworkConfig.dio;
      Response response;
      try {
        response = await dio.get(
          ApiEndpoints.rele,
          queryParameters: {
            'celularId': deviceId,
          },
        );
      } catch (e) {
        print('❌ [INJECTION] Falha ao buscar relé por celularId: $e');
        return null;
      }

      List items = [];
      final data = response.data;
      if (data is List) {
        items = data;
      } else if (data is Map && data['content'] is List) {
        items = data['content'];
      }

      if (items.isEmpty) {
        print('⚠️ [INJECTION] Nenhum relé configurado para celularId=$deviceId');
        return null;
      }

      String? ip;
      final first = items.first;
      if (first is Map) {
        ip = (first['ip'] ?? '').toString().trim();
      }

      if (ip == null || ip.isEmpty) {
        print('⚠️ [INJECTION] IP do relé vazio para celularId=$deviceId');
        return null;
      }

      final baseUrl = ip.startsWith('http://') || ip.startsWith('https://') ? ip : 'http://$ip';
      _runtimeSonoffDs = SonoffDataSourceImpl(client: http.Client(), baseUrl: baseUrl);
      print('✅ [INJECTION] DataSource do Sonoff preparado com baseUrl=$baseUrl');
      return _runtimeSonoffDs;
    } catch (e) {
      print('❌ [INJECTION] Erro ao preparar DataSource runtime do Sonoff: $e');
      return null;
    }
  }
}