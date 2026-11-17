import '../../core/database/database_helper.dart';
import '../models/labor_model.dart';

class LaborRepository {
  final DatabaseHelper _dbHelper;

  LaborRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<LaborModel>> getAllLabores() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT l.*, 
        c.especie as cultivo_especie,
        c.variedad as cultivo_variedad,
        t.nombre as terreno_nombre
      FROM labor l
      JOIN cultivo c ON l.cultivo_id = c.id
      JOIN terreno t ON c.terreno_id = t.id
      ORDER BY l.fecha DESC, l.id DESC
    ''');

    return maps.map((m) => LaborModel.fromMap(m)).toList();
  }

  Future<List<LaborModel>> getLaboresByCultivo(int cultivoId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT l.*, 
        c.especie as cultivo_especie,
        c.variedad as cultivo_variedad,
        t.nombre as terreno_nombre
      FROM labor l
      JOIN cultivo c ON l.cultivo_id = c.id
      JOIN terreno t ON c.terreno_id = t.id
      WHERE l.cultivo_id = ?
      ORDER BY l.fecha DESC, l.id DESC
    ''',
      [cultivoId],
    );

    return maps.map((m) => LaborModel.fromMap(m)).toList();
  }

  Future<LaborModel?> getLaborById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT l.*, 
        c.especie as cultivo_especie,
        c.variedad as cultivo_variedad,
        t.nombre as terreno_nombre
      FROM labor l
      JOIN cultivo c ON l.cultivo_id = c.id
      JOIN terreno t ON c.terreno_id = t.id
      WHERE l.id = ?
    ''',
      [id],
    );

    if (maps.isNotEmpty) {
      return LaborModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertLabor(LaborModel labor) async {
    final db = await _dbHelper.database;
    return await db.insert('labor', labor.toMap());
  }

  Future<int> updateLabor(LaborModel labor) async {
    final db = await _dbHelper.database;
    return await db.update(
      'labor',
      labor.toMap(),
      where: 'id = ?',
      whereArgs: [labor.id],
    );
  }

  Future<int> deleteLabor(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('labor', where: 'id = ?', whereArgs: [id]);
  }

  Future<double> getTotalJornalesByCultivo(int cultivoId) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery(
      'SELECT SUM(jornales) as total FROM labor WHERE cultivo_id = ?',
      [cultivoId],
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }
}
