import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/registro_maquina.dart';
import '../repositories/registro_maquina_repository.dart';

/// Use case para buscar todas as máquinas ativas
/// 
/// Implementa [UseCase] sem parâmetros de entrada
/// Retorna [Either<Failure, List<RegistroMaquina>>]
class GetAllMaquinas implements UseCase<List<RegistroMaquina>, NoParams> {
  final RegistroMaquinaRepository repository;

  const GetAllMaquinas(this.repository);

  @override
  Future<Either<Failure, List<RegistroMaquina>>> call(NoParams params) async {
    return await repository.getAllMaquinas();
  }
}