import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/registro_maquina.dart';
import '../repositories/registro_maquina_repository.dart';

/// Use case para criar uma nova máquina
class CreateMaquina implements UseCase<RegistroMaquina, CreateMaquinaParams> {
  final RegistroMaquinaRepository repository;

  CreateMaquina(this.repository);

  @override
  Future<Either<Failure, RegistroMaquina>> call(
    CreateMaquinaParams params,
  ) async {
    return await repository.createMaquina(params.maquina);
  }
}

/// Parâmetros para criação de máquina
class CreateMaquinaParams {
  final RegistroMaquina maquina;

  CreateMaquinaParams({required this.maquina});
}