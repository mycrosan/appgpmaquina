import '../../domain/repositories/sonoff_repository.dart';
import '../datasources/sonoff_datasource.dart';

class SonoffRepositoryImpl implements SonoffRepository {
  final SonoffDataSource dataSource;

  SonoffRepositoryImpl({required this.dataSource});

  @override
  Future<bool> ligarRele() async {
    return await dataSource.ligarRele();
  }

  @override
  Future<bool> desligarRele() async {
    return await dataSource.desligarRele();
  }

  @override
  Future<bool> verificarStatusRele() async {
    return await dataSource.verificarStatusRele();
  }
}