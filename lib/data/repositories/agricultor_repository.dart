import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../models/agricultor_model.dart';

class AgricultorRepository {
  final DatabaseHelper _dbHelper;

  AgricultorRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<AgricultorModel?> getAgricultor() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'agricultor',
      orderBy: 'id ASC',
      limit: 1,
    );

    if (maps.isNotEmpty) {
      return AgricultorModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertAgricultor(AgricultorModel agricultor) async {
    final db = await _dbHelper.database;
    return await db.insert(
      'agricultor',
      agricultor.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<int> updateAgricultor(AgricultorModel agricultor) async {
    final db = await _dbHelper.database;
    return await db.update(
      'agricultor',
      agricultor.toMap(),
      where: 'id = ?',
      whereArgs: [agricultor.id],
    );
  }

  Future<bool> hasAgricultor() async {
    final db = await _dbHelper.database;
    final count =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM agricultor'),
        ) ??
        0;
    return count > 0;
  }
}
