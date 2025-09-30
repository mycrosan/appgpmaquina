import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/models/paginated_response.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/configuracao_maquina.dart';
import '../repositories/configuracao_maquina_repository.dart';

/// Use case para buscar configurações de máquina com filtros
/// 
/// Este use case permite buscar configurações aplicando filtros
/// como máquina, chave de configuração, status ativo e paginação.
class GetConfiguracoesMaquina implements UseCase<PaginatedResponse<ConfiguracaoMaquina>, GetConfiguracoesMaquinaParams> {
  final ConfiguracaoMaquinaRepository repository;

  GetConfiguracoesMaquina(this.repository);

  @override
  Future<Either<Failure, PaginatedResponse<ConfiguracaoMaquina>>> call(GetConfiguracoesMaquinaParams params) async {
    // Valida os parâmetros de paginação
    if (params.page < 0) {
      return Left(ValidationFailure(message: 'Número da página deve ser maior ou igual a 0.'));
    }

    if (params.size <= 0 || params.size > 100) {
      return Left(ValidationFailure(message: 'Tamanho da página deve estar entre 1 e 100.'));
    }

    return await repository.getConfiguracoesMaquina(
      registroMaquinaId: params.registroMaquinaId,
      chaveConfiguracao: params.chaveConfiguracao,
      ativo: params.ativo,
      page: params.page,
      size: params.size,
    );
  }
}

/// Parâmetros para buscar configurações de máquina
class GetConfiguracoesMaquinaParams extends Equatable {
  final int? registroMaquinaId;
  final String? chaveConfiguracao;
  final bool? ativo;
  final int page;
  final int size;

  const GetConfiguracoesMaquinaParams({
    this.registroMaquinaId,
    this.chaveConfiguracao,
    this.ativo,
    this.page = 0,
    this.size = 20,
  });

  /// Cria uma cópia com valores atualizados
  GetConfiguracoesMaquinaParams copyWith({
    int? registroMaquinaId,
    String? chaveConfiguracao,
    bool? ativo,
    int? page,
    int? size,
  }) {
    return GetConfiguracoesMaquinaParams(
      registroMaquinaId: registroMaquinaId ?? this.registroMaquinaId,
      chaveConfiguracao: chaveConfiguracao ?? this.chaveConfiguracao,
      ativo: ativo ?? this.ativo,
      page: page ?? this.page,
      size: size ?? this.size,
    );
  }

  @override
  List<Object?> get props => [registroMaquinaId, chaveConfiguracao, ativo, page, size];

  @override
  String toString() {
    return 'GetConfiguracoesMaquinaParams(registroMaquinaId: $registroMaquinaId, chaveConfiguracao: $chaveConfiguracao, ativo: $ativo, page: $page, size: $size)';
  }
}