import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/registro_maquina.dart';

/// Repositório abstrato para operações com registro de máquinas
/// Define os contratos para acesso aos dados de máquinas
abstract class RegistroMaquinaRepository {
  /// Cria uma nova máquina
  ///
  /// [maquina] - dados da máquina a ser criada
  /// Retorna [Right(RegistroMaquina)] com os dados da máquina criada em caso de sucesso
  /// Retorna [Left(Failure)] em caso de erro
  Future<Either<Failure, RegistroMaquina>> createMaquina(
    RegistroMaquina maquina,
  );

  /// Busca uma máquina por ID
  ///
  /// [id] - ID da máquina
  /// Retorna [Right(RegistroMaquina)] em caso de sucesso
  /// Retorna [Left(Failure)] em caso de erro
  Future<Either<Failure, RegistroMaquina>> getMaquinaById(int id);

  /// Atualiza uma máquina existente
  ///
  /// [maquina] - dados da máquina a ser atualizada
  /// Retorna [Right(RegistroMaquina)] com os dados atualizados em caso de sucesso
  /// Retorna [Left(Failure)] em caso de erro
  Future<Either<Failure, RegistroMaquina>> updateMaquina(
    RegistroMaquina maquina,
  );

  /// Lista todas as máquinas ativas
  ///
  /// Retorna [Right(List<RegistroMaquina>)] com todas as máquinas em caso de sucesso
  /// Retorna [Left(Failure)] em caso de erro
  Future<Either<Failure, List<RegistroMaquina>>> getAllMaquinas();
}