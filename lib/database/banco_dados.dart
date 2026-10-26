import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'dart:io';

class BancoDados {
  static final BancoDados instance = BancoDados._init();

  static Database? _database;

  BancoDados._init();

  Future<Database> get database async {
    if (_database != null) {
      return _database!;
    }

    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    final String caminho;

    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
      final diretorio = await getApplicationSupportDirectory();
      await diretorio.create(recursive: true);
      caminho = join(diretorio.path, 'petshop.db');

      return await databaseFactory.openDatabase(
        caminho,
        options: OpenDatabaseOptions(version: 1, onCreate: _criarBanco),
      );
    } else {
      final diretorio = await getDatabasesPath();
      caminho = join(diretorio, 'petshop.db');

      return await openDatabase(caminho, version: 1, onCreate: _criarBanco);
    }
  }

  Future<void> _criarBanco(Database db, int version) async {
    await db.execute('''
      CREATE TABLE atendimentos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        pet TEXT NOT NULL,
        tutor TEXT NOT NULL,
        servico TEXT NOT NULL,
        data TEXT NOT NULL,
        valor REAL NOT NULL
      )
    ''');
  }

  Future<int> inserir(Map<String, dynamic> dados) async {
    final db = await database;

    return await db.insert('atendimentos', dados);
  }

  Future<List<Map<String, dynamic>>> listar({String busca = ''}) async {
    final db = await database;

    if (busca.trim().isEmpty) {
      return await db.query('atendimentos', orderBy: 'id DESC');
    }

    return await db.query(
      'atendimentos',
      where: 'pet LIKE ? OR tutor LIKE ?',
      whereArgs: ['%${busca.trim()}%', '%${busca.trim()}%'],
      orderBy: 'id DESC',
    );
  }

  Future<int> atualizar(int id, Map<String, dynamic> dados) async {
    final db = await database;

    return await db.update(
      'atendimentos',
      dados,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> excluir(int id) async {
    final db = await database;

    return await db.delete('atendimentos', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> totalArrecadado() async {
    final db = await database;

    final resultado = await db.rawQuery(
      'SELECT SUM(valor) AS total FROM atendimentos',
    );

    return (resultado.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> quantidadeAtendimentos() async {
    final db = await database;

    final resultado = await db.rawQuery(
      'SELECT COUNT(*) AS quantidade FROM atendimentos',
    );

    return (resultado.first['quantidade'] as int?) ?? 0;
  }
}
