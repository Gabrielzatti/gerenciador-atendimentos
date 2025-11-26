import 'package:injectable/injectable.dart';

import '../domain/atendimento.dart';
import '../domain/atendimento_repository.dart';
import 'atendimento_dao.dart';

@LazySingleton(as: AtendimentoRepository)
class AtendimentoRepositoryImpl implements AtendimentoRepository {
  AtendimentoRepositoryImpl(this._dao);

  final AtendimentoDao _dao;

  @override
  Future<List<Atendimento>> listar({
    String? filtroNome,
    AtendimentoStatus? filtroStatus,
  }) {
    return _dao.findAll(
      filtroNome: filtroNome,
      filtroStatus: filtroStatus,
    );
  }

  @override
  Future<void> salvar(Atendimento atendimento) async {
    if (atendimento.id == null) {
      await _dao.insert(atendimento);
    } else {
      await _dao.update(atendimento);
    }
  }

  @override
  Future<void> excluirLogico(int id) => _dao.softDelete(id);

  @override
  Future<void> alterarAtivo(int id, bool ativo) =>
      _dao.updateAtivo(id, ativo);
}
