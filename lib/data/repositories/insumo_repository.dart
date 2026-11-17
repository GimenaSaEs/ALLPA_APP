import 'package:sqflite/sqflite.dart';
import '../../core/constants/input_types.dart';
import '../../core/database/database_helper.dart';
import '../models/insumo_model.dart';

class InsumoRepository {
  final DatabaseHelper _dbHelper;

  InsumoRepository({DatabaseHelper? dbHelper})
      : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<InsumoModel>> getAllInsumos() async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT i.*, 
        c.especie as cultivo_especie,
        c.variedad as cultivo_variedad,
        t.nombre as terreno_nombre
      FROM insumo i
      JOIN cultivo c ON i.cultivo_id = c.id
      JOIN terreno t ON c.terreno_id = t.id
      ORDER BY i.fecha DESC, i.id DESC
    ''');

    return maps.map((m) => InsumoModel.fromMap(m)).toList();
  }

  Future<List<InsumoModel>> getInsumosByCultivo(int cultivoId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT i.*, 
        c.especie as cultivo_especie,
        c.variedad as cultivo_variedad,
        t.nombre as terreno_nombre
      FROM insumo i
      JOIN cultivo c ON i.cultivo_id = c.id
      JOIN terreno t ON c.terreno_id = t.id
      WHERE i.cultivo_id = ?
      ORDER BY i.fecha DESC, i.id DESC
    ''', [cultivoId]);

    return maps.map((m) => InsumoModel.fromMap(m)).toList();
  }

  Future<InsumoModel?> getInsumoById(int id) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT i.*, 
        c.especie as cultivo_especie,
        c.variedad as cultivo_variedad,
        t.nombre as terreno_nombre
      FROM insumo i
      JOIN cultivo c ON i.cultivo_id = c.id
      JOIN terreno t ON c.terreno_id = t.id
      WHERE i.id = ?
    ''', [id]);

    if (maps.isNotEmpty) {
      return InsumoModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> insertInsumo(InsumoModel insumo) async {
    final db = await _dbHelper.database;
    return await db.insert('insumo', insumo.toMap());
  }

  Future<int> updateInsumo(InsumoModel insumo) async {
    final db = await _dbHelper.database;
    return await db.update(
      'insumo',
      insumo.toMap(),
      where: 'id = ?',
      whereArgs: [insumo.id],
    );
  }

  Future<int> deleteInsumo(int id) async {
    final db = await _dbHelper.database;
    return await db.delete('insumo', where: 'id = ?', whereArgs: [id]);
  }

  /// Calcula la suma total de semillas en kilogramos equivalentes para un cultivo dado
  Future<double> getTotalSemillaKgByCultivo(int cultivoId) async {
    final insumos = await getInsumosByCultivo(cultivoId);
    double totalKg = 0.0;
    for (final ins in insumos) {
      if (ins.tipo.toLowerCase().contains('semilla')) {
        totalKg += InputTypes.toKg(ins.cantidad, ins.unidad);
      }
    }
    return totalKg;
  }
}
