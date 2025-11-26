import 'package:equatable/equatable.dart';

import '../../domain/atendimento.dart';

class AtendimentoListState extends Equatable {
  const AtendimentoListState({
    this.itens = const <Atendimento>[],
    this.loading = false,
    this.filtroNome,
    this.filtroStatus,
    this.error,
  });

  final List<Atendimento> itens;
  final bool loading;
  final String? filtroNome;
  final AtendimentoStatus? filtroStatus;
  final String? error;

  AtendimentoListState copyWith({
    List<Atendimento>? itens,
    bool? loading,
    String? filtroNome,
    AtendimentoStatus? filtroStatus,
    String? error,
  }) {
    return AtendimentoListState(
      itens: itens ?? this.itens,
      loading: loading ?? this.loading,
      filtroNome: filtroNome ?? this.filtroNome,
      filtroStatus: filtroStatus ?? this.filtroStatus,
      error: error,
    );
  }

  @override
  List<Object?> get props => <Object?>[
        itens,
        loading,
        filtroNome,
        filtroStatus,
        error,
      ];
}
