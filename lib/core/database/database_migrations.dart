import 'package:sqflite/sqflite.dart';

class DatabaseMigrations {
  static const int currentVersion = 1;

  static Future<void> onCreate(Database db, int version) async {
    // Habilitar integridad referencial
    await db.execute('PRAGMA foreign_keys = ON;');

    // 1. Tabla agricultor
    await db.execute('''
      CREATE TABLE agricultor (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nombre TEXT NOT NULL,
        codigo_local TEXT NOT NULL UNIQUE,
        documento TEXT,
        telefono TEXT,
        comunidad TEXT NOT NULL DEFAULT 'Illpe',
        distrito TEXT NOT NULL DEFAULT 'Pachamarca',
        provincia TEXT NOT NULL DEFAULT 'Churcampa',
        departamento TEXT NOT NULL DEFAULT 'Huancavelica',
        siembra_individual INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL
      );
    ''');

    // 2. Tabla terreno
    await db.execute('''
      CREATE TABLE terreno (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        agricultor_id INTEGER NOT NULL,
        nombre TEXT NOT NULL,
        area_ha REAL NOT NULL CHECK(area_ha > 0),
        ubicacion TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (agricultor_id) REFERENCES agricultor(id) ON DELETE RESTRICT
      );
    ''');

    // 3. Tabla cultivo
    await db.execute('''
      CREATE TABLE cultivo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        terreno_id INTEGER NOT NULL,
        especie TEXT NOT NULL,
        variedad TEXT,
        area_sembrada_ha REAL NOT NULL DEFAULT 0.0,
        fecha_inicio TEXT NOT NULL,
        estado TEXT NOT NULL DEFAULT 'En curso',
        created_at TEXT NOT NULL,
        FOREIGN KEY (terreno_id) REFERENCES terreno(id) ON DELETE RESTRICT
      );
    ''');

    // 4. Tabla plan_siembra
    await db.execute('''
      CREATE TABLE plan_siembra (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cultivo_id INTEGER NOT NULL UNIQUE,
        fecha_prevista TEXT,
        fecha_real TEXT,
        escrito INTEGER NOT NULL DEFAULT 1 CHECK(escrito IN (0, 1)),
        desfase_dias INTEGER,
        estado TEXT NOT NULL DEFAULT 'Pendiente',
        observacion TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (cultivo_id) REFERENCES cultivo(id) ON DELETE CASCADE
      );
    ''');

    // 5. Tabla labor
    await db.execute('''
      CREATE TABLE labor (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cultivo_id INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        fecha TEXT NOT NULL,
        jornales REAL NOT NULL DEFAULT 0.0 CHECK(jornales >= 0),
        nota TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (cultivo_id) REFERENCES cultivo(id) ON DELETE CASCADE
      );
    ''');

    // 6. Tabla insumo
    await db.execute('''
      CREATE TABLE insumo (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cultivo_id INTEGER NOT NULL,
        tipo TEXT NOT NULL,
        nombre TEXT NOT NULL,
        cantidad REAL NOT NULL CHECK(cantidad >= 0),
        unidad TEXT NOT NULL,
        fecha TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (cultivo_id) REFERENCES cultivo(id) ON DELETE CASCADE
      );
    ''');

    // 7. Tabla cosecha
    await db.execute('''
      CREATE TABLE cosecha (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cultivo_id INTEGER NOT NULL UNIQUE,
        fecha TEXT NOT NULL,
        area_ha REAL NOT NULL CHECK(area_ha > 0),
        produccion_kg REAL NOT NULL CHECK(produccion_kg >= 0),
        jornales REAL NOT NULL DEFAULT 0.0 CHECK(jornales >= 0),
        rendimiento_kg_ha REAL,
        productividad_kg_jornal REAL,
        observacion TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (cultivo_id) REFERENCES cultivo(id) ON DELETE CASCADE
      );
    ''');

    // Índices de optimización para búsquedas y consultas de bitácora
    await db.execute(
      'CREATE INDEX idx_terreno_agricultor ON terreno(agricultor_id);',
    );
    await db.execute(
      'CREATE INDEX idx_cultivo_terreno ON cultivo(terreno_id);',
    );
    await db.execute(
      'CREATE INDEX idx_labor_cultivo_fecha ON labor(cultivo_id, fecha);',
    );
    await db.execute(
      'CREATE INDEX idx_insumo_cultivo_fecha ON insumo(cultivo_id, fecha);',
    );
  }

  static Future<void> onUpgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    // Soporte para futuras migraciones incrementales
    if (oldVersion < 2) {
      // Futuras migraciones v2
    }
  }

  static Future<void> onConfigure(Database db) async {
    await db.execute('PRAGMA foreign_keys = ON;');
  }
}
