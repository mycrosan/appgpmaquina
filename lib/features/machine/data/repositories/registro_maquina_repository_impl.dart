import 'dart:developer' as developer;
import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/registro_maquina.dart';
import '../../domain/repositories/registro_maquina_repository.dart';
import '../datasources/registro_maquina_remote_datasource.dart';
import '../models/registro_maquina_dto.dart';

/// Implementação do repositório para registro de máquinas
/// Coordena entre data sources e converte exceções em failures
class RegistroMaquinaRepositoryImpl implements RegistroMaquinaRepository {
  final RegistroMaquinaRemoteDataSource remoteDataSource;

  RegistroMaquinaRepositoryImpl({required this.remoteDataSource}) {
    developer.log(
      '🏗️ RegistroMaquinaRepositoryImpl inicializado',
      name: 'RegistroMaquinaRepo',
    );
  }

  @override
  Future<Either<Failure, RegistroMaquina>> createMaquina(
    RegistroMaquina maquina,
  ) async {
    try {
      developer.log(
        '📋 Criando nova máquina: ${maquina.nome}',
        name: 'RegistroMaquinaRepo',
      );

      // Converte a entidade para DTO de criação
      final createDto = RegistroMaquinaUpdateDTO(
        nome: maquina.nome,
        descricao: maquina.descricao,
        numeroSerie: maquina.numeroSerie,
        modelo: maquina.modelo,
        fabricante: maquina.fabricante,
        localizacao: maquina.localizacao,
        responsavel: maquina.responsavel,
        status: maquina.status,
        ativo: maquina.ativo,
        observacoes: maquina.observacoes,
      );

      final dto = await remoteDataSource.createMaquina(createDto);
      final entity = dto.toEntity();

      developer.log(
        '✅ Máquina criada: ${entity.nome}',
        name: 'RegistroMaquinaRepo',
      );
      return Right(entity);
    } on ServerException catch (e) {
      developer.log(
        '❌ Erro do servidor: ${e.message}',
        name: 'RegistroMaquinaRepo',
      );
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      developer.log(
        '❌ Erro de rede: ${e.message}',
        name: 'RegistroMaquinaRepo',
      );
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      developer.log('❌ Erro inesperado: $e', name: 'RegistroMaquinaRepo');
      return Left(ServerFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, RegistroMaquina>> getMaquinaById(int id) async {
    try {
      developer.log(
        '📋 Buscando máquina por ID: $id',
        name: 'RegistroMaquinaRepo',
      );

      final dto = await remoteDataSource.getMaquinaById(id);
      final entity = dto.toEntity();

      developer.log(
        '✅ Máquina encontrada: ${entity.nome}',
        name: 'RegistroMaquinaRepo',
      );
      return Right(entity);
    } on ServerException catch (e) {
      developer.log(
        '❌ Erro do servidor: ${e.message}',
        name: 'RegistroMaquinaRepo',
      );
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      developer.log(
        '❌ Erro de rede: ${e.message}',
        name: 'RegistroMaquinaRepo',
      );
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      developer.log('❌ Erro inesperado: $e', name: 'RegistroMaquinaRepo');
      return Left(ServerFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, RegistroMaquina>> updateMaquina(
    RegistroMaquina maquina,
  ) async {
    try {
      developer.log(
        '📋 Atualizando máquina: ${maquina.nome}',
        name: 'RegistroMaquinaRepo',
      );

      // Converte a entidade para DTO de atualização
      final updateDto = RegistroMaquinaUpdateDTO(
        nome: maquina.nome,
        descricao: maquina.descricao,
        numeroSerie: maquina.numeroSerie,
        modelo: maquina.modelo,
        fabricante: maquina.fabricante,
        localizacao: maquina.localizacao,
        responsavel: maquina.responsavel,
        status: maquina.status,
        ativo: maquina.ativo,
        observacoes: maquina.observacoes,
      );

      if (maquina.id == null) {
        throw const ServerException(
          message: 'ID da máquina é obrigatório para atualização',
        );
      }

      final dto = await remoteDataSource.updateMaquina(maquina.id!, updateDto);
      final entity = dto.toEntity();

      developer.log(
        '✅ Máquina atualizada: ${entity.nome}',
        name: 'RegistroMaquinaRepo',
      );
      return Right(entity);
    } on ServerException catch (e) {
      developer.log(
        '❌ Erro do servidor: ${e.message}',
        name: 'RegistroMaquinaRepo',
      );
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      developer.log(
        '❌ Erro de rede: ${e.message}',
        name: 'RegistroMaquinaRepo',
      );
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      developer.log('❌ Erro inesperado: $e', name: 'RegistroMaquinaRepo');
      return Left(ServerFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, List<RegistroMaquina>>> getAllMaquinas() async {
    try {
      developer.log(
        '📋 Buscando todas as máquinas',
        name: 'RegistroMaquinaRepo',
      );

      final dtos = await remoteDataSource.getAllMaquinas();
      final entities = dtos.map((dto) => dto.toEntity()).toList();

      developer.log(
        '✅ ${entities.length} máquinas carregadas',
        name: 'RegistroMaquinaRepo',
      );
      return Right(entities);
    } on ServerException catch (e) {
      developer.log(
        '❌ Erro do servidor: ${e.message}',
        name: 'RegistroMaquinaRepo',
      );
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      developer.log(
        '❌ Erro de rede: ${e.message}',
        name: 'RegistroMaquinaRepo',
      );
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      developer.log('❌ Erro inesperado: $e', name: 'RegistroMaquinaRepo');
      return Left(ServerFailure(message: 'Erro inesperado: $e'));
    }
  }
}