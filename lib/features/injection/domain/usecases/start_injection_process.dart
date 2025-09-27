import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/processo_injecao.dart';
import '../repositories/injection_repository.dart';
import '../../../machine/domain/repositories/machine_repository.dart';

/// Caso de uso para iniciar um processo de injeção de ar
/// 
/// Valida os parâmetros e inicia o processo de injeção para uma carcaça específica
class StartInjectionProcess implements UseCase<ProcessoInjecao, StartInjectionProcessParams> {
  final InjectionRepository injectionRepository;
  final MachineRepository machineRepository;

  StartInjectionProcess({
    required this.injectionRepository,
    required this.machineRepository,
  });

  @override
  Future<Either<Failure, ProcessoInjecao>> call(StartInjectionProcessParams params) async {
    // Verifica se há algum processo ativo
    final hasActiveResult = await injectionRepository.hasActiveProcess();
    
    return hasActiveResult.fold(
      (failure) => Left(failure),
      (hasActive) async {
        if (hasActive) {
          return Left(ValidationFailure(
            message: 'Já existe um processo de injeção em andamento',
          ));
        }

        // Verifica se a carcaça existe e pode ser processada
        final carcacaResult = await machineRepository.getCarcacaById(params.carcacaId);
        
        return carcacaResult.fold(
          (failure) => Left(failure),
          (carcaca) async {
            if (!carcaca.canBeProcessed) {
              return Left(ValidationFailure(
                message: 'Carcaça ${carcaca.codigo} não pode ser processada',
              ));
            }

            // Busca a regra de injeção para a matriz da carcaça
            final regraResult = await injectionRepository.getRegraByMatrizId(carcaca.matrizId);
            
            return regraResult.fold(
              (failure) => Left(failure),
              (regra) async {
                if (!regra.canBeApplied) {
                  return Left(ValidationFailure(
                    message: 'Regra de injeção para matriz ${regra.matrizNome} não pode ser aplicada',
                  ));
                }

                // Inicia o processo de injeção
                return await injectionRepository.startInjectionProcess(
                  carcacaId: params.carcacaId,
                  regraId: regra.id,
                  userId: params.userId,
                );
              },
            );
          },
        );
      },
    );
  }
}

/// Parâmetros para o caso de uso StartInjectionProcess
class StartInjectionProcessParams extends Equatable {
  final int carcacaId;
  final int userId;

  const StartInjectionProcessParams({
    required this.carcacaId,
    required this.userId,
  });

  @override
  List<Object> get props => [carcacaId, userId];

  @override
  String toString() => 'StartInjectionProcessParams(carcacaId: $carcacaId, userId: $userId)';
}