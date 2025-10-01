import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../../../machine/domain/entities/machine_config.dart';
import '../../../machine/domain/repositories/machine_repository.dart';
import '../entities/carcaca.dart';
import '../entities/producao_response.dart';
import '../repositories/producao_repository.dart';

/// Use case para validar carcaça e verificar compatibilidade da matriz
///
/// Este use case é responsável por:
/// 1. Buscar dados da carcaça pelo número de etiqueta
/// 2. Verificar se a matriz da carcaça é compatível com a matriz da máquina
/// 3. Retornar os dados validados ou erro de incompatibilidade
class ValidarCarcacaUseCase
    implements UseCase<ValidacaoCarcacaResult, ValidarCarcacaParams> {
  final ProducaoRepository producaoRepository;
  final MachineRepository machineRepository;

  ValidarCarcacaUseCase({
    required this.producaoRepository,
    required this.machineRepository,
  });

  @override
  Future<Either<Failure, ValidacaoCarcacaResult>> call(
    ValidarCarcacaParams params,
  ) async {
    print('[VALIDAR_CARCACA] 🚀 Iniciando validação da carcaça: ${params.numeroEtiqueta}');
    
    // 1. Buscar dados da carcaça
    print('[VALIDAR_CARCACA] 🔍 Buscando dados da carcaça...');
    final carcacaResult = await producaoRepository.pesquisarCarcaca(
      params.numeroEtiqueta,
    );

    return carcacaResult.fold(
      (failure) {
        print('[VALIDAR_CARCACA] ❌ Erro ao buscar carcaça: $failure');
        return Left(failure);
      },
      (producaoResponses) async {
        print('[VALIDAR_CARCACA] 📊 Encontradas ${producaoResponses.length} respostas de produção');
        
        if (producaoResponses.isEmpty) {
          print('[VALIDAR_CARCACA] ❌ Nenhuma carcaça encontrada');
          return Left(
            ValidationFailure(
              message: 'Carcaça não encontrada para o número de etiqueta informado',
            ),
          );
        }

        final producaoResponse = producaoResponses.first;
        print('[VALIDAR_CARCACA] ✅ Carcaça encontrada: ${producaoResponse.carcaca.numeroEtiqueta}');

        // 2. Buscar configuração atual da máquina
        final machineConfigResult = await machineRepository.getCurrentMachineConfig(
          params.deviceId,
          params.userId,
        );

        return machineConfigResult.fold(
          (failure) => Left(failure),
          (machineConfig) {
            if (machineConfig == null) {
              return Left(
                ValidationFailure(
                  message: 'Máquina não configurada. Configure a matriz antes de continuar.',
                ),
              );
            }

            // 3. Verificar compatibilidade da matriz
            final matrizCarcaca = producaoResponse.regra.matriz;
            final matrizMaquina = machineConfig.matrizId;

            if (matrizCarcaca.id != matrizMaquina) {
              return Left(
                ValidationFailure(
                  message: 'Máquina errada. A matriz da carcaça (${matrizCarcaca.descricao}) não é compatível com a matriz configurada na máquina.',
                ),
              );
            }

            // 4. Retornar resultado da validação
            return Right(
              ValidacaoCarcacaResult(
                producaoResponse: producaoResponse,
                machineConfig: machineConfig,
                isMatrizCompativel: true,
              ),
            );
          },
        );
      },
    );
  }
}

/// Parâmetros para o use case ValidarCarcacaUseCase
class ValidarCarcacaParams extends Equatable {
  final String numeroEtiqueta;
  final String deviceId;
  final String userId;

  const ValidarCarcacaParams({
    required this.numeroEtiqueta,
    required this.deviceId,
    required this.userId,
  });

  @override
  List<Object> get props => [numeroEtiqueta, deviceId, userId];

  @override
  String toString() {
    return 'ValidarCarcacaParams(numeroEtiqueta: $numeroEtiqueta, deviceId: $deviceId, userId: $userId)';
  }
}

/// Resultado da validação da carcaça
class ValidacaoCarcacaResult extends Equatable {
  final ProducaoResponse producaoResponse;
  final MachineConfig machineConfig;
  final bool isMatrizCompativel;

  const ValidacaoCarcacaResult({
    required this.producaoResponse,
    required this.machineConfig,
    required this.isMatrizCompativel,
  });

  /// Retorna o tempo de injeção em segundos da regra
  int get tempoInjecao {
    return int.tryParse(producaoResponse.regra.tempo) ?? 0;
  }

  /// Retorna informações da carcaça
  Carcaca get carcaca => producaoResponse.carcaca;

  /// Retorna informações da regra
  RegraProducao get regra => producaoResponse.regra;

  /// Retorna informações da matriz
  Matriz get matriz => producaoResponse.regra.matriz;

  @override
  List<Object> get props => [
        producaoResponse,
        machineConfig,
        isMatrizCompativel,
      ];

  @override
  String toString() {
    return 'ValidacaoCarcacaResult(carcaca: ${carcaca.numeroEtiqueta}, matriz: ${matriz.descricao}, compativel: $isMatrizCompativel)';
  }
}