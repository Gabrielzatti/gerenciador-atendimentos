import 'package:sqflite/sqflite.dart';

import '../../../core/database/app_database.dart';
import '../domain/atendimento.dart';

class AtendimentoDao {
  static const String table = 'atendimentos';

  Future<Database> get _db async => AppDatabase.instance.database;

  Future<List<Atendimento>> findAll({
    String? filtroNome,
    AtendimentoStatus? filtroStatus,
  }) async {
    final Database db = await _db;
    final List<String> where = <String>['excluido = 0'];
    final List<dynamic> whereArgs = <dynamic>[];

    if (filtroNome != null && filtroNome.isNotEmpty) {
      where.add('nome LIKE ?');
      whereArgs.add('%$filtroNome%');
    }

    if (filtroStatus != null) {
      where.add('status = ?');
      whereArgs.add(filtroStatus.dbValue);
    }

    final List<Map<String, dynamic>> result = await db.query(
      table,
      where: where.join(' AND '),
      whereArgs: whereArgs,
      orderBy: 'data_criacao DESC',
    );

    return result.map(Atendimento.fromMap).toList();
  }

  Future<int> insert(Atendimento at) async {
    final Database db = await _db;
    return db.insert(table, at.toMap());
  }

  Future<int> update(Atendimento at) async {
    final Database db = await _db;
    return db.update(
      table,
      at.toMap(),
      where: 'id = ?',
      whereArgs: <dynamic>[at.id],
    );
  }

  Future<int> softDelete(int id) async {
    final Database db = await _db;
    return db.update(
      table,
      <String, Object?>{'excluido': 1},
      where: 'id = ?',
      whereArgs: <dynamic>[id],
    );
  }

  Future<int> updateAtivo(int id, bool ativo) async {
    final Database db = await _db;
    return db.update(
      table,
      <String, Object?>{'ativo': ativo ? 1 : 0},
      where: 'id = ?',
      whereArgs: <dynamic>[id],
    );
  }
}
