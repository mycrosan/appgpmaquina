import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/registro_maquina.dart';
import '../repositories/registro_maquina_repository.dart';

/// Use case para atualizar uma máquina
/// Implementa o padrão UseCase para operações de domínio
class UpdateMaquina implements UseCase<RegistroMaquina, UpdateMaquinaParams> {
  final RegistroMaquinaRepository repository;

  UpdateMaquina(this.repository);

  @override
  Future<Either<Failure, RegistroMaquina>> call(
    UpdateMaquinaParams params,
  ) async {
    return await repository.updateMaquina(params.maquina);
  }
}

/// Parâmetros para o use case UpdateMaquina
class UpdateMaquinaParams {
  final RegistroMaquina maquina;

  const UpdateMaquinaParams({required this.maquina});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UpdateMaquinaParams && other.maquina == maquina;
  }

  @override
  int get hashCode => maquina.hashCode;
}