enum AtendimentoStatus { ativo, emAndamento, finalizado }

extension AtendimentoStatusX on AtendimentoStatus {
  String get dbValue {
    switch (this) {
      case AtendimentoStatus.ativo:
        return 'ativo';
      case AtendimentoStatus.emAndamento:
        return 'em_andamento';
      case AtendimentoStatus.finalizado:
        return 'finalizado';
    }
  }

  String get label {
    switch (this) {
      case AtendimentoStatus.ativo:
        return 'Ativo';
      case AtendimentoStatus.emAndamento:
        return 'Em andamento';
      case AtendimentoStatus.finalizado:
        return 'Finalizado';
    }
  }

  static AtendimentoStatus fromDb(String value) {
    switch (value) {
      case 'em_andamento':
        return AtendimentoStatus.emAndamento;
      case 'finalizado':
        return AtendimentoStatus.finalizado;
      case 'ativo':
      default:
        return AtendimentoStatus.ativo;
    }
  }
}

class Atendimento {
  final int? id;
  final String nome;
  final String descricao;
  final String? imagemPath;
  final DateTime dataCriacao;
  final AtendimentoStatus status;
  final String? observacoes;
  final bool ativo;
  final bool excluido;

  Atendimento({
    this.id,
    required this.nome,
    required this.descricao,
    this.imagemPath,
    required this.dataCriacao,
    this.status = AtendimentoStatus.ativo,
    this.observacoes,
    this.ativo = true,
    this.excluido = false,
  });

  Atendimento copyWith({
    int? id,
    String? nome,
    String? descricao,
    String? imagemPath,
    DateTime? dataCriacao,
    AtendimentoStatus? status,
    String? observacoes,
    bool? ativo,
    bool? excluido,
  }) {
    return Atendimento(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      imagemPath: imagemPath ?? this.imagemPath,
      dataCriacao: dataCriacao ?? this.dataCriacao,
      status: status ?? this.status,
      observacoes: observacoes ?? this.observacoes,
      ativo: ativo ?? this.ativo,
      excluido: excluido ?? this.excluido,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'imagem_path': imagemPath,
      'data_criacao': dataCriacao.toIso8601String(),
      'status': status.dbValue,
      'observacoes': observacoes,
      'ativo': ativo ? 1 : 0,
      'excluido': excluido ? 1 : 0,
    };
  }

  factory Atendimento.fromMap(Map<String, dynamic> map) {
    return Atendimento(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      descricao: map['descricao'] as String,
      imagemPath: map['imagem_path'] as String?,
      dataCriacao: DateTime.parse(map['data_criacao'] as String),
      status: AtendimentoStatusX.fromDb(map['status'] as String),
      observacoes: map['observacoes'] as String?,
      ativo: (map['ativo'] as int) == 1,
      excluido: (map['excluido'] as int) == 1,
    );
  }
}
