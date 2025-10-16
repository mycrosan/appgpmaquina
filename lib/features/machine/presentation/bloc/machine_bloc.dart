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

    // Simulated data for testing - usando IDs dinâmicos
    final carcacas = <Carcaca>[
      Carcaca(
        id: DateTime.now().millisecondsSinceEpoch % 1000,
        codigo: 'CARC${DateTime.now().millisecondsSinceEpoch % 1000}',
        matrizId: DateTime.now().millisecondsSinceEpoch % 100,
        matrizNome: 'Matriz Dinâmica ${DateTime.now().millisecondsSinceEpoch % 100}',
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

    // Simulated data for testing - usando IDs dinâmicos
    final matrizId = DateTime.now().millisecondsSinceEpoch % 1000;
    final matrizes = <Matriz>[
      Matriz(
        id: matrizId,
        descricao: 'Matriz dinâmica para pneus 205/55R16 Michelin Primacy',
        nome: 'Matriz Dinâmica $matrizId',
        codigo: 'MAT${matrizId.toString().padLeft(3, '0')}',
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

    // Simulated data for testing - usando IDs dinâmicos
    final matrizId = (event.id * 10) % 1000; // Gera matrizId baseado no ID da carcaça
    final carcaca = Carcaca(
      id: event.id,
      codigo: 'CARC${event.id.toString().padLeft(3, '0')}',
      matrizId: matrizId,
      matrizNome: 'Matriz Dinâmica $matrizId',
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

    // Simulated search results - usando IDs dinâmicos
    final searchId = event.searchTerm.hashCode.abs() % 1000;
    final matrizId = searchId % 100;
    final carcacas = <Carcaca>[
      Carcaca(
        id: searchId,
        codigo: 'CARC${searchId.toString().padLeft(3, '0')}',
        matrizId: matrizId,
        matrizNome: 'Carcaça encontrada: ${event.searchTerm} (Matriz $matrizId)',
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

    // Simulated search results - usando IDs dinâmicos
    final searchId = event.searchTerm.hashCode.abs() % 1000;
    final matrizes = <Matriz>[
      Matriz(
        id: searchId,
        descricao: 'Matriz encontrada para: ${event.searchTerm}',
        nome: 'Matriz encontrada: ${event.searchTerm}',
        codigo: 'MAT${searchId.toString().padLeft(3, '0')}',
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