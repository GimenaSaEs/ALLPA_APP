import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';

import 'package:allpa/core/database/database_helper.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Database db;

  setUp(() async {
    db = await DatabaseHelper.initInMemoryDatabase();
  });

  tearDown(() async {
    await db.close();
  });

  test('creates the seven SQLite tables and enables foreign keys', () async {
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type = 'table' AND name NOT LIKE 'sqlite_%'",
    );
    final foreignKeys = await db.rawQuery('PRAGMA foreign_keys');

    expect(tables.map((row) => row['name']).toSet(), {
      'agricultor',
      'terreno',
      'cultivo',
      'plan_siembra',
      'labor',
      'insumo',
      'cosecha',
    });
    expect(foreignKeys.single.values.single, 1);
  });

  test('persists linked synthetic records and enforces positive land area',
      () async {
    final now = DateTime.utc(2026).toIso8601String();
    final farmerId = await db.insert('agricultor', {
      'nombre': 'Persona de prueba',
      'codigo_local': 'TEST-01',
      'created_at': now,
    });
    final landId = await db.insert('terreno', {
      'agricultor_id': farmerId,
      'nombre': 'Lote de prueba',
      'area_ha': 1.0,
      'created_at': now,
    });

    final rows = await db.query('terreno', where: 'id = ?', whereArgs: [landId]);
    expect(rows.single['agricultor_id'], farmerId);
    expect(rows.single['area_ha'], 1.0);

    await expectLater(
      db.insert('terreno', {
        'agricultor_id': farmerId,
        'nombre': 'Área inválida',
        'area_ha': 0,
        'created_at': now,
      }),
      throwsA(isA<DatabaseException>()),
    );
  });
}
