import 'package:dartz/dartz.dart';
import 'dart:developer' as developer;

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/models/paginated_response.dart';
import '../../domain/entities/configuracao_maquina.dart';
import '../../domain/repositories/configuracao_maquina_repository.dart';
import '../datasources/configuracao_maquina_remote_datasource.dart';
import '../models/configuracao_maquina_model.dart';

/// Implementação do repositório de configuração de máquina
/// Conecta as fontes de dados com a camada de domínio
class ConfiguracaoMaquinaRepositoryImpl
    implements ConfiguracaoMaquinaRepository {
  final ConfiguracaoMaquinaRemoteDataSource remoteDataSource;

  ConfiguracaoMaquinaRepositoryImpl({required this.remoteDataSource}) {
    developer.log(
      '🏗️ ConfiguracaoMaquinaRepositoryImpl inicializado',
      name: 'ConfiguracaoMaquinaRepository',
    );
  }

  @override
  Future<Either<Failure, ConfiguracaoMaquina>> createConfiguracaoMaquina(
    ConfiguracaoMaquina configuracao,
  ) async {
    try {
      developer.log(
        '🔄 Criando configuração de máquina',
        name: 'ConfiguracaoMaquinaRepository',
      );

      final configModel = ConfiguracaoMaquinaModel.fromEntity(configuracao);
      final result = await remoteDataSource.createConfiguracaoMaquina(
        configModel,
      );

      developer.log(
        '✅ Configuração criada com sucesso',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Right(result.toEntity());
    } on ValidationException catch (e) {
      developer.log(
        '💥 Erro de validação: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(ValidationFailure(message: e.message));
    } on AuthenticationException catch (e) {
      developer.log(
        '💥 Erro de autenticação: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(AuthenticationFailure(message: e.message));
    } on AuthorizationException catch (e) {
      developer.log(
        '💥 Erro de autorização: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(AuthenticationFailure(message: e.message));
    } on ServerException catch (e) {
      developer.log(
        '💥 Erro do servidor: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      developer.log(
        '💥 Erro de rede: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      developer.log(
        '💥 Erro inesperado: $e',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(ServerFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, PaginatedResponse<ConfiguracaoMaquina>>>
  getConfiguracoesMaquina({
    int? registroMaquinaId,
    String? chaveConfiguracao,
    bool? ativo,
    int page = 0,
    int size = 20,
  }) async {
    try {
      developer.log(
        '🔄 Buscando configurações de máquina',
        name: 'ConfiguracaoMaquinaRepository',
      );
      developer.log(
        '📋 Filtros: máquina=$registroMaquinaId, chave=$chaveConfiguracao, ativo=$ativo',
        name: 'ConfiguracaoMaquinaRepository',
      );

      final result = await remoteDataSource.getConfiguracoesMaquina(
        registroMaquinaId: registroMaquinaId,
        chaveConfiguracao: chaveConfiguracao,
        ativo: ativo,
        page: page,
        size: size,
      );

      final entities = result.map((model) => model.toEntity()).toList();

      // Criando uma resposta paginada simples
      final paginatedResponse = PaginatedResponse<ConfiguracaoMaquina>(
        content: entities,
        totalElements: entities.length,
        totalPages: 1,
        size: size,
        number: page,
        first: page == 0,
        last: true,
        numberOfElements: entities.length,
      );

      developer.log(
        '✅ ${entities.length} configurações encontradas',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Right(paginatedResponse);
    } on AuthenticationException catch (e) {
      developer.log(
        '💥 Erro de autenticação: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(AuthenticationFailure(message: e.message));
    } on AuthorizationException catch (e) {
      developer.log(
        '💥 Erro de autorização: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(AuthenticationFailure(message: e.message));
    } on ServerException catch (e) {
      developer.log(
        '💥 Erro do servidor: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      developer.log(
        '💥 Erro de rede: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      developer.log(
        '💥 Erro inesperado: $e',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(ServerFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, ConfiguracaoMaquina>> getConfiguracaoMaquinaById(
    int id,
  ) async {
    try {
      developer.log(
        '🔄 Buscando configuração por ID: $id',
        name: 'ConfiguracaoMaquinaRepository',
      );

      final result = await remoteDataSource.getConfiguracaoMaquinaById(id);

      developer.log(
        '✅ Configuração encontrada',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Right(result.toEntity());
    } on NotFoundException catch (e) {
      developer.log(
        '💥 Configuração não encontrada: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(ServerFailure(message: e.message));
    } on AuthenticationException catch (e) {
      developer.log(
        '💥 Erro de autenticação: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(AuthenticationFailure(message: e.message));
    } on AuthorizationException catch (e) {
      developer.log(
        '💥 Erro de autorização: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(AuthenticationFailure(message: e.message));
    } on ServerException catch (e) {
      developer.log(
        '💥 Erro do servidor: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      developer.log(
        '💥 Erro de rede: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      developer.log(
        '💥 Erro inesperado: $e',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(ServerFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, ConfiguracaoMaquina>> updateConfiguracaoMaquina(
    int id,
    ConfiguracaoMaquina configuracao,
  ) async {
    try {
      developer.log(
        '🔄 Atualizando configuração ID: $id',
        name: 'ConfiguracaoMaquinaRepository',
      );

      final configModel = ConfiguracaoMaquinaModel.fromEntity(configuracao);
      final result = await remoteDataSource.updateConfiguracaoMaquina(
        id,
        configModel,
      );

      developer.log(
        '✅ Configuração atualizada com sucesso',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Right(result.toEntity());
    } on ValidationException catch (e) {
      developer.log(
        '💥 Erro de validação: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(ValidationFailure(message: e.message));
    } on NotFoundException catch (e) {
      developer.log(
        '💥 Configuração não encontrada: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(ServerFailure(message: e.message));
    } on AuthenticationException catch (e) {
      developer.log(
        '💥 Erro de autenticação: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(AuthenticationFailure(message: e.message));
    } on AuthorizationException catch (e) {
      developer.log(
        '💥 Erro de autorização: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(AuthenticationFailure(message: e.message));
    } on ServerException catch (e) {
      developer.log(
        '💥 Erro do servidor: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      developer.log(
        '💥 Erro de rede: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      developer.log(
        '💥 Erro inesperado: $e',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(ServerFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteConfiguracaoMaquina(int id) async {
    try {
      developer.log(
        '🔄 Removendo configuração ID: $id',
        name: 'ConfiguracaoMaquinaRepository',
      );

      await remoteDataSource.deleteConfiguracaoMaquina(id);

      developer.log(
        '✅ Configuração removida com sucesso',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return const Right(null);
    } on NotFoundException catch (e) {
      developer.log(
        '💥 Configuração não encontrada: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(ServerFailure(message: e.message));
    } on AuthenticationException catch (e) {
      developer.log(
        '💥 Erro de autenticação: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(AuthenticationFailure(message: e.message));
    } on AuthorizationException catch (e) {
      developer.log(
        '💥 Erro de autorização: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(AuthenticationFailure(message: e.message));
    } on ServerException catch (e) {
      developer.log(
        '💥 Erro do servidor: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      developer.log(
        '💥 Erro de rede: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      developer.log(
        '💥 Erro inesperado: $e',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(ServerFailure(message: 'Erro inesperado: $e'));
    }
  }

  @override
  Future<Either<Failure, ConfiguracaoMaquina>> getConfiguracaoByMaquinaAndChave(
    int registroMaquinaId,
    String chaveConfiguracao,
  ) async {
    try {
      developer.log(
        '🔄 Buscando configuração por máquina e chave',
        name: 'ConfiguracaoMaquinaRepository',
      );
      developer.log(
        '📋 Máquina: $registroMaquinaId, Chave: $chaveConfiguracao',
        name: 'ConfiguracaoMaquinaRepository',
      );

      final result = await remoteDataSource.getConfiguracaoByMaquinaAndChave(
        registroMaquinaId,
        chaveConfiguracao,
      );

      developer.log(
        '✅ Configuração encontrada',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Right(result.toEntity());
    } on NotFoundException catch (e) {
      developer.log(
        '💥 Configuração não encontrada: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(ServerFailure(message: e.message));
    } on AuthenticationException catch (e) {
      developer.log(
        '💥 Erro de autenticação: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(AuthenticationFailure(message: e.message));
    } on AuthorizationException catch (e) {
      developer.log(
        '💥 Erro de autorização: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(AuthenticationFailure(message: e.message));
    } on ServerException catch (e) {
      developer.log(
        '💥 Erro do servidor: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(ServerFailure(message: e.message));
    } on NetworkException catch (e) {
      developer.log(
        '💥 Erro de rede: ${e.message}',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(NetworkFailure(message: e.message));
    } catch (e) {
      developer.log(
        '💥 Erro inesperado: $e',
        name: 'ConfiguracaoMaquinaRepository',
      );
      return Left(ServerFailure(message: 'Erro inesperado: $e'));
    }
  }
}