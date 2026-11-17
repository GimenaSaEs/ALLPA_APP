import '../../core/database/database_helper.dart';
import '../../core/utils/calculations.dart';
import '../models/cosecha_model.dart';

class CosechaRepository {
  final DatabaseHelper _dbHelper;

  CosechaRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<CosechaModel>> getAllCosechas() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT cos.*, 
        c.especie as cultivo_especie,
        c.variedad as cultivo_variedad,
        t.nombre as terreno_nombre
      FROM cosecha cos
      JOIN cultivo c ON cos.cultivo_id = c.id
      JOIN terreno t ON c.terreno_id = t.id
      ORDER BY cos.fecha DESC, cos.id DESC
    ''');

    return maps.map((m) => CosechaModel.fromMap(m)).toList();
  }

  Future<CosechaModel?> getCosechaByCultivoId(int cultivoId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT cos.*, 
        c.especie as cultivo_especie,
        c.variedad as cultivo_variedad,
        t.nombre as terreno_nombre
      FROM cosecha cos
      JOIN cultivo c ON cos.cultivo_id = c.id
      JOIN terreno t ON c.terreno_id = t.id
      WHERE cos.cultivo_id = ?
    ''',
      [cultivoId],
    );

    if (maps.isNotEmpty) {
      return CosechaModel.fromMap(maps.first);
    }
    return null;
  }

  Future<CosechaModel?> getCosechaById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
      '''
      SELECT cos.*, 
        c.especie as cultivo_especie,
        c.variedad as cultivo_variedad,
        t.nombre as terreno_nombre
      FROM cosecha cos
      JOIN cultivo c ON cos.cultivo_id = c.id
      JOIN terreno t ON c.terreno_id = t.id
      WHERE cos.id = ?
    ''',
      [id],
    );

    if (maps.isNotEmpty) {
      return CosechaModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> saveCosecha(CosechaModel cosecha) async {
    final db = await _dbHelper.database;

    // Calcular rendimiento y productividad automáticamente
    final rendimiento = AgriculturalCalculations.calculateYield(
      produccionKg: cosecha.produccionKg,
      areaHa: cosecha.areaHa,
    );

    final productividad =
        AgriculturalCalculations.calculateProductivityPerJornal(
          produccionKg: cosecha.produccionKg,
          jornales: cosecha.jornales,
        );

    final toSave = cosecha.copyWith(
      rendimientoKgHa: rendimiento,
      productividadKgJornal: productividad,
    );

    final existing = await getCosechaByCultivoId(cosecha.cultivoId);
    if (existing == null) {
      final id = await db.insert('cosecha', toSave.toMap());
      // Actualizar estado del cultivo a 'Cosechado'
      await db.update(
        'cultivo',
        {'estado': 'Cosechado'},
        where: 'id = ?',
        whereArgs: [cosecha.cultivoId],
      );
      return id;
    } else {
      return await db.update(
        'cosecha',
        toSave.toMap(),
        where: 'cultivo_id = ?',
        whereArgs: [cosecha.cultivoId],
      );
    }
  }

  Future<int> deleteCosecha(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('cosecha', where: 'id = ?', whereArgs: [id]);
  }
}
