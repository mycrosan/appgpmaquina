import '../repositories/sonoff_repository.dart';

class ControlarSonoffUseCase {
  final SonoffRepository repository;

  ControlarSonoffUseCase({required this.repository});

  Future<bool> ligarRele() async {
    return await repository.ligarRele();
  }

  Future<bool> desligarRele() async {
    return await repository.desligarRele();
  }

  Future<bool> verificarStatusRele() async {
    return await repository.verificarStatusRele();
  }
}