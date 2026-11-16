import 'dart:io';

import 'package:allpa/datos/esquema.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

bool _motorListo = false;

void asegurarMotorSqlite() {
  if (_motorListo) return;
  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }
  _motorListo = true;
}

String carpetaDatosAllpa() {
  if (Platform.isWindows) {
    final base = Platform.environment['LOCALAPPDATA'] ?? Directory.current.path;
    return p.join(base, 'Allpa');
  }
  if (Platform.isAndroid) {
    return '/data/data/pe.edu.continental.allpa/files';
  }
  return p.join(Directory.current.path, 'Allpa');
}

String rutaBaseDatosPorDefecto() => p.join(carpetaDatosAllpa(), 'allpa.db');

Future<void> _crearEsquema(Database db) async {
  for (final sql in sqlCrear) {
    await db.execute(sql);
  }
  await _sembrar(db);
}

Future<void> _sembrar(Database db) async {
  final ahora = DateTime.now().toIso8601String();
  await db.insert('comunidad', {
    'nombre': 'Illpe',
    'distrito': 'Pachamarca',
    'provincia': 'Churcampa',
    'departamento': 'Huancavelica',
    'anio_estudio': 2027,
  });
  for (final cultivo in cultivosSemilla) {
    await db.insert('cultivo', cultivo, conflictAlgorithm: ConflictAlgorithm.ignore);
  }
  for (final piso in pisosSemilla) {
    await db.insert('piso_ecologico', piso, conflictAlgorithm: ConflictAlgorithm.ignore);
  }
  for (final labor in laboresSemilla) {
    await db.insert('tipo_labor', {'nombre': labor}, conflictAlgorithm: ConflictAlgorithm.ignore);
  }
  await db.insert('configuracion', {'clave': 'version_app', 'valor': '1.0.0'});
  await db.insert('configuracion', {'clave': 'modo_offline', 'valor': 'true'});
  await db.insert('configuracion', {'clave': 'campania_referencia', 'valor': 'UP-ILL-001'});
  await db.insert('configuracion', {'clave': 'creado_en', 'valor': ahora});
}

Future<Database> abrirBaseDatos(String ruta) async {
  asegurarMotorSqlite();
  await Directory(p.dirname(ruta)).create(recursive: true);
  return openDatabase(
    ruta,
    version: versionEsquema,
    onConfigure: (db) async {
      await db.execute('PRAGMA foreign_keys = ON');
    },
    onCreate: (db, version) async {
      await _crearEsquema(db);
    },
    onUpgrade: (db, oldVersion, newVersion) async {
      for (final tabla in nombresTablas.reversed) {
        await db.execute('DROP TABLE IF EXISTS $tabla');
      }
      await _crearEsquema(db);
    },
  );
}
