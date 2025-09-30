import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/carcaca.dart';
import '../../domain/entities/matriz.dart';

part 'machine_event.dart';
part 'machine_state.dart';

/// BLoC responsável por gerenciar o estado das máquinas
/// Versão simplificada para testes iniciais
class MachineBloc extends Bloc<MachineEvent, MachineState> {
  MachineBloc() : super(MachineInitial()) {
    on<MachineLoadCarcacas>(_onLoadCarcacas);
    on<MachineLoadMatrizes>(_onLoadMatrizes);
    on<MachineLoadCarcacaById>(_onLoadCarcacaById);
    on<MachineLoadMatrizById>(_onLoadMatrizById);
    on<MachineSearchCarcacas>(_onSearchCarcacas);
    on<MachineSearchMatrizes>(_onSearchMatrizes);
    on<MachineCheckCarcacaProcessable>(_onCheckCarcacaProcessable);
  }

  Future<void> _onLoadCarcacas(
    MachineLoadCarcacas event,
    Emitter<MachineState> emit,
  ) async {
    emit(MachineLoading());

    // TODO: Implement actual use case call
    await Future.delayed(const Duration(seconds: 1));

    // Simulated data for testing
    final carcacas = <Carcaca>[
      Carcaca(
        id: 1,
        codigo: 'CARC001',
        matrizId: 1,
        matrizNome: 'Matriz Teste',
        createdAt: DateTime.now(),
      ),
    ];

    emit(MachineCarcacasLoaded(carcacas: carcacas));
  }

  Future<void> _onLoadMatrizes(
    MachineLoadMatrizes event,
    Emitter<MachineState> emit,
  ) async {
    emit(MachineLoading());

    // TODO: Implement actual use case call
    await Future.delayed(const Duration(seconds: 1));

    // Simulated data for testing
    final matrizes = <Matriz>[
      Matriz(
        id: 1,
        descricao: 'Matriz de teste para pneus 205/55R16 Michelin Primacy',
        nome: 'Matriz Teste 1',
        codigo: 'MAT001',
        isActive: true,
        canBeUsed: true,
      ),
    ];

    emit(MachineMatrizesLoaded(matrizes: matrizes));
  }

  Future<void> _onLoadCarcacaById(
    MachineLoadCarcacaById event,
    Emitter<MachineState> emit,
  ) async {
    emit(MachineLoading());

    // TODO: Implement actual use case call
    await Future.delayed(const Duration(seconds: 1));

    // Simulated data for testing
    final carcaca = Carcaca(
      id: event.id,
      codigo: 'CARC${event.id.toString().padLeft(3, '0')}',
      matrizId: 1,
      matrizNome: 'Matriz ${event.id}',
      createdAt: DateTime.now(),
    );

    emit(MachineCarcacaLoaded(carcaca: carcaca));
  }

  Future<void> _onLoadMatrizById(
    MachineLoadMatrizById event,
    Emitter<MachineState> emit,
  ) async {
    emit(MachineLoading());

    // TODO: Implement actual use case call
    await Future.delayed(const Duration(seconds: 1));

    // Simulated data for testing
    final matriz = Matriz(
      id: event.id,
      descricao: 'Matriz de teste para pneus 205/55R16 Michelin Primacy',
      nome: 'Matriz ${event.id}',
      codigo: 'MAT${event.id.toString().padLeft(3, '0')}',
      isActive: true,
      canBeUsed: true,
    );

    emit(MachineMatrizLoaded(matriz: matriz));
  }

  Future<void> _onSearchCarcacas(
    MachineSearchCarcacas event,
    Emitter<MachineState> emit,
  ) async {
    emit(MachineLoading());

    // TODO: Implement actual use case call
    await Future.delayed(const Duration(seconds: 1));

    // Simulated search results
    final carcacas = <Carcaca>[
      Carcaca(
        id: 1,
        codigo: 'CARC001',
        matrizId: 1,
        matrizNome: 'Carcaça encontrada: ${event.searchTerm}',
        createdAt: DateTime.now(),
      ),
    ];

    emit(MachineCarcacasLoaded(carcacas: carcacas));
  }

  Future<void> _onSearchMatrizes(
    MachineSearchMatrizes event,
    Emitter<MachineState> emit,
  ) async {
    emit(MachineLoading());

    // TODO: Implement actual use case call
    await Future.delayed(const Duration(seconds: 1));

    // Simulated search results
    final matrizes = <Matriz>[
      Matriz(
        id: 1,
        descricao: 'Matriz encontrada para: ${event.searchTerm}',
        nome: 'Matriz encontrada: ${event.searchTerm}',
        codigo: 'MAT001',
        isActive: true,
        canBeUsed: true,
      ),
    ];

    emit(MachineMatrizesLoaded(matrizes: matrizes));
  }

  Future<void> _onCheckCarcacaProcessable(
    MachineCheckCarcacaProcessable event,
    Emitter<MachineState> emit,
  ) async {
    // TODO: Implement actual use case call
    await Future.delayed(const Duration(milliseconds: 500));

    // Simulated check - always return true for testing
    emit(
      MachineCarcacaProcessableChecked(
        carcacaId: event.carcacaId,
        canProcess: true,
      ),
    );
  }
}