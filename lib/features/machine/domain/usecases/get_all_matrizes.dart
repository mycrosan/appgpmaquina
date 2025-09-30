import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/matriz.dart';
import '../repositories/machine_repository.dart';

/// Use case para buscar todas as matrizes ativas
///
/// Este use case é responsável por recuperar todas as matrizes
/// disponíveis no sistema que estão ativas e podem ser utilizadas
/// na configuração da máquina.
class GetAllMatrizes implements UseCase<List<Matriz>, NoParams> {
  final MachineRepository repository;

  GetAllMatrizes(this.repository);

  @override
  Future<Either<Failure, List<Matriz>>> call(NoParams params) async {
    return await repository.getAllMatrizes();
  }
}