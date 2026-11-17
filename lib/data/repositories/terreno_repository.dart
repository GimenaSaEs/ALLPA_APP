import 'package:sqflite/sqflite.dart';
import '../../core/database/database_helper.dart';
import '../models/terreno_model.dart';

class TerrenoRepository {
  final DatabaseHelper _dbHelper;

  TerrenoRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<TerrenoModel>> getTerrenosByAgricultor(int agricultorId) async {
    final db = await _dbHelper.database;
    // Subconsulta para obtener cultivos_count y area_sembrada_total
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.*, 
        COUNT(c.id) as cultivos_count,
        COALESCE(SUM(c.area_sembrada_ha), 0.0) as area_sembrada_total
      FROM terreno t
      LEFT JOIN cultivo c ON t.id = c.terreno_id
      WHERE t.agricultor_id = ?
      GROUP BY t.id
      ORDER BY t.id DESC
    ''', [agricultorId]);

    return maps.map((m) => TerrenoModel.fromMap(m)).toList();
  }

  Future<TerrenoModel?> getTerrenoById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT t.*, 
        COUNT(c.id) as cultivos_count,
        COALESCE(SUM(c.area_sembrada_ha), 0.0) as area_sembrada_total
      FROM terreno t
      LEFT JOIN cultivo c ON t.id = c.terreno_id
      WHERE t.id = ?
      GROUP BY t.id
    ''', [id]);

    if (maps.isNotEmpty) {
      return TerrenoModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertTerreno(TerrenoModel terreno) async {
    final db = await _dbHelper.database;
    return await db.insert('terreno', terreno.toMap());
  }

  Future<int> updateTerreno(TerrenoModel terreno) async {
    final db = await _dbHelper.database;
    return await db.update(
      'terreno',
      terreno.toMap(),
      where: 'id = ?',
      whereArgs: [terreno.id],
    );
  }

  Future<bool> canDeleteTerreno(int id) async {
    final db = await _dbHelper.database;
    final count = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM cultivo WHERE terreno_id = ?', [id]),
    ) ?? 0;
    return count == 0;
  }

  Future<int> deleteTerreno(int id) async {
    final canDelete = await canDeleteTerreno(id);
    if (!canDelete) {
      throw Exception('No se puede eliminar el terreno porque tiene cultivos registrados.');
    }
    final db = await _dbHelper.database;
    return await db.delete('terreno', where: 'id = ?', whereArgs: [id]);
  }
}
