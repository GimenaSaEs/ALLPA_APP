import '../../core/database/database_helper.dart';
import '../models/cultivo_model.dart';

class CultivoRepository {
  final DatabaseHelper _dbHelper;

  CultivoRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<CultivoModel>> getAllCultivos() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT c.*, 
        t.nombre as terreno_nombre,
        t.area_ha as terreno_area_ha,
        ps.id as plan_siembra_id,
        ps.fecha_prevista,
        ps.fecha_real,
        ps.desfase_dias,
        (SELECT COUNT(*) FROM cosecha cos WHERE cos.cultivo_id = c.id) as tiene_cosecha
      FROM cultivo c
      JOIN terreno t ON c.terreno_id = t.id
      LEFT JOIN plan_siembra ps ON c.id = ps.cultivo_id
      ORDER BY c.id DESC
    ''');

    return maps.map((m) => CultivoModel.fromMap(m)).toList();
  }

  Future<List<CultivoModel>> getCultivosByTerreno(int terrenoId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT c.*, 
        t.nombre as terreno_nombre,
        t.area_ha as terreno_area_ha,
        ps.id as plan_siembra_id,
        ps.fecha_prevista,
        ps.fecha_real,
        ps.desfase_dias,
        (SELECT COUNT(*) FROM cosecha cos WHERE cos.cultivo_id = c.id) as tiene_cosecha
      FROM cultivo c
      JOIN terreno t ON c.terreno_id = t.id
      LEFT JOIN plan_siembra ps ON c.id = ps.cultivo_id
      WHERE c.terreno_id = ?
      ORDER BY c.id DESC
    ''',
      [terrenoId],
    );

    return maps.map((m) => CultivoModel.fromMap(m)).toList();
  }

  Future<CultivoModel?> getCultivoById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT c.*, 
        t.nombre as terreno_nombre,
        t.area_ha as terreno_area_ha,
        ps.id as plan_siembra_id,
        ps.fecha_prevista,
        ps.fecha_real,
        ps.desfase_dias,
        (SELECT COUNT(*) FROM cosecha cos WHERE cos.cultivo_id = c.id) as tiene_cosecha
      FROM cultivo c
      JOIN terreno t ON c.terreno_id = t.id
      LEFT JOIN plan_siembra ps ON c.id = ps.cultivo_id
      WHERE c.id = ?
    ''',
      [id],
    );

    if (maps.isNotEmpty) {
      return CultivoModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertCultivo(CultivoModel cultivo) async {
    final db = await _dbHelper.database;
    return await db.insert('cultivo', cultivo.toMap());
  }

  Future<int> updateCultivo(CultivoModel cultivo) async {
    final db = await _dbHelper.database;
    return await db.update(
      'cultivo',
      cultivo.toMap(),
      where: 'id = ?',
      whereArgs: [cultivo.id],
    );
  }

  Future<int> deleteCultivo(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('cultivo', where: 'id = ?', whereArgs: [id]);
  }
}
