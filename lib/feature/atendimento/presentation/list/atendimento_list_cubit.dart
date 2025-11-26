import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/atendimento.dart';
import '../../domain/atendimento_repository.dart';
import 'atendimento_list_state.dart';

class AtendimentoListCubit extends Cubit<AtendimentoListState> {
  AtendimentoListCubit(this._repo) : super(const AtendimentoListState());

  final AtendimentoRepository _repo;

  Future<void> carregar() async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final itens = await _repo.listar(
        filtroNome: state.filtroNome,
        filtroStatus: state.filtroStatus,
      );
      emit(state.copyWith(loading: false, itens: itens));
    } catch (e) {
      emit(
        state.copyWith(
          loading: false,
          error: e.toString(),
        ),
      );
    }
  }

  void alterarFiltroNome(String nome) {
    emit(state.copyWith(filtroNome: nome));
    carregar();
  }

  void alterarFiltroStatus(AtendimentoStatus? status) {
    emit(state.copyWith(filtroStatus: status));
    carregar();
  }

  Future<void> excluirLogico(int id) async {
    await _repo.excluirLogico(id);
    await carregar();
  }

  Future<void> alterarAtivo(int id, bool ativoAtual) async {
    await _repo.alterarAtivo(id, !ativoAtual);
    await carregar();
  }
}
