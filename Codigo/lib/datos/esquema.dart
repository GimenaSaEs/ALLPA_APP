/// Esquema SQLite ampliado Allpa / Illpe (diccionario de tesis).
library;

const versionEsquema = 2;

const nombresTablas = <String>[
  'comunidad',
  'productor',
  'unidad',
  'cultivo',
  'tipo_labor',
  'piso_ecologico',
  'parcela',
  'campana',
  'plan',
  'plan_labor',
  'siembra',
  'insumo',
  'labor',
  'cosecha',
  'indicador_ficha',
  'evento_app',
  'sesion_prueba',
  'respaldo',
  'rechazo_regla',
  'configuracion',
  'evidencia',
  'sincronizacion_log',
];

const sqlCrear = <String>[
  '''
CREATE TABLE comunidad (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre TEXT NOT NULL,
  distrito TEXT NOT NULL,
  provincia TEXT NOT NULL,
  departamento TEXT NOT NULL,
  anio_estudio INTEGER NOT NULL
)
''',
  '''
CREATE TABLE productor (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nombres TEXT NOT NULL,
  apellidos TEXT NOT NULL DEFAULT '',
  telefono TEXT NOT NULL DEFAULT '',
  comunidad_id INTEGER,
  creado_en TEXT NOT NULL,
  FOREIGN KEY (comunidad_id) REFERENCES comunidad(id)
)
''',
  '''
CREATE TABLE unidad (
  codigo TEXT PRIMARY KEY NOT NULL,
  nombre TEXT NOT NULL DEFAULT '',
  productor_id INTEGER,
  creado_en TEXT NOT NULL,
  FOREIGN KEY (productor_id) REFERENCES productor(id)
)
''',
  '''
CREATE TABLE cultivo (
  codigo TEXT PRIMARY KEY NOT NULL,
  nombre TEXT NOT NULL,
  transitorio INTEGER NOT NULL DEFAULT 1
)
''',
  '''
CREATE TABLE tipo_labor (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre TEXT NOT NULL UNIQUE
)
''',
  '''
CREATE TABLE piso_ecologico (
  codigo TEXT PRIMARY KEY NOT NULL,
  nombre TEXT NOT NULL
)
''',
  '''
CREATE TABLE parcela (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  codigo_unidad TEXT NOT NULL,
  nombre TEXT NOT NULL,
  piso_ecologico TEXT NOT NULL DEFAULT '',
  hectareas_disponibles REAL NOT NULL,
  FOREIGN KEY (codigo_unidad) REFERENCES unidad(codigo),
  FOREIGN KEY (piso_ecologico) REFERENCES piso_ecologico(codigo)
)
''',
  '''
CREATE TABLE campana (
  id TEXT PRIMARY KEY NOT NULL,
  codigo_unidad TEXT NOT NULL,
  parcela_id INTEGER,
  nombre_parcela TEXT NOT NULL,
  piso_ecologico TEXT NOT NULL DEFAULT '',
  hectareas_disponibles REAL NOT NULL,
  anio INTEGER NOT NULL DEFAULT 2027,
  origen TEXT NOT NULL DEFAULT 'en_linea',
  sincronizado INTEGER NOT NULL DEFAULT 1,
  FOREIGN KEY (codigo_unidad) REFERENCES unidad(codigo),
  FOREIGN KEY (parcela_id) REFERENCES parcela(id)
)
''',
  '''
CREATE TABLE plan (
  campana_id TEXT PRIMARY KEY NOT NULL,
  cultivo TEXT,
  hectareas_previstas REAL,
  fecha_siembra_prevista TEXT,
  FOREIGN KEY (campana_id) REFERENCES campana(id) ON DELETE CASCADE,
  FOREIGN KEY (cultivo) REFERENCES cultivo(codigo)
)
''',
  '''
CREATE TABLE plan_labor (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campana_id TEXT NOT NULL,
  tipo_labor_id INTEGER,
  nombre TEXT NOT NULL,
  orden INTEGER NOT NULL DEFAULT 0,
  FOREIGN KEY (campana_id) REFERENCES plan(campana_id) ON DELETE CASCADE,
  FOREIGN KEY (tipo_labor_id) REFERENCES tipo_labor(id)
)
''',
  '''
CREATE TABLE siembra (
  campana_id TEXT PRIMARY KEY NOT NULL,
  fecha_real TEXT NOT NULL,
  individual INTEGER NOT NULL,
  kilogramos_semilla REAL NOT NULL,
  hectareas_sembradas REAL NOT NULL,
  jornales REAL NOT NULL DEFAULT 0,
  FOREIGN KEY (campana_id) REFERENCES campana(id) ON DELETE CASCADE
)
''',
  '''
CREATE TABLE insumo (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campana_id TEXT NOT NULL,
  tipo TEXT NOT NULL,
  nombre TEXT NOT NULL,
  cantidad REAL NOT NULL,
  unidad_medida TEXT NOT NULL DEFAULT 'kg',
  fecha TEXT NOT NULL,
  FOREIGN KEY (campana_id) REFERENCES campana(id) ON DELETE CASCADE
)
''',
  '''
CREATE TABLE labor (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campana_id TEXT NOT NULL,
  tipo_labor_id INTEGER,
  nombre TEXT NOT NULL,
  fecha TEXT NOT NULL,
  jornales REAL NOT NULL,
  segundos_registro REAL,
  FOREIGN KEY (campana_id) REFERENCES campana(id) ON DELETE CASCADE,
  FOREIGN KEY (tipo_labor_id) REFERENCES tipo_labor(id)
)
''',
  '''
CREATE TABLE cosecha (
  campana_id TEXT PRIMARY KEY NOT NULL,
  superficie_cosechada_ha REAL NOT NULL,
  produccion_kg REAL NOT NULL,
  fecha TEXT,
  FOREIGN KEY (campana_id) REFERENCES campana(id) ON DELETE CASCADE
)
''',
  '''
CREATE TABLE indicador_ficha (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campana_id TEXT NOT NULL,
  codigo_unidad TEXT NOT NULL,
  plan_escrito INTEGER,
  desfase_dias INTEGER,
  registros_completos_pct REAL,
  superficie_sembrada_pct REAL,
  semilla_kg_ha REAL,
  siembra_individual INTEGER,
  jornales_familiares REAL,
  rendimiento_kg_ha REAL,
  produccion_kg REAL,
  superficie_cosechada_ha REAL,
  productividad_kg_jornal REAL,
  calculado_en TEXT NOT NULL,
  FOREIGN KEY (campana_id) REFERENCES campana(id) ON DELETE CASCADE,
  FOREIGN KEY (codigo_unidad) REFERENCES unidad(codigo)
)
''',
  '''
CREATE TABLE evento_app (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  tipo TEXT NOT NULL,
  funcion TEXT NOT NULL,
  con_senal INTEGER NOT NULL,
  detalle TEXT NOT NULL DEFAULT '',
  creado_en TEXT NOT NULL
)
''',
  '''
CREATE TABLE sesion_prueba (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  nombre TEXT NOT NULL,
  cobertura_pct REAL,
  tiempo_labor_s REAL,
  disponibilidad_sin_senal_pct REAL,
  fallos INTEGER NOT NULL DEFAULT 0,
  creado_en TEXT NOT NULL
)
''',
  '''
CREATE TABLE respaldo (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  ruta_archivo TEXT NOT NULL,
  campanas INTEGER NOT NULL,
  con_senal INTEGER NOT NULL,
  creado_en TEXT NOT NULL
)
''',
  '''
CREATE TABLE rechazo_regla (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  codigo_regla TEXT NOT NULL,
  funcion TEXT NOT NULL,
  mensaje TEXT NOT NULL,
  creado_en TEXT NOT NULL
)
''',
  '''
CREATE TABLE configuracion (
  clave TEXT PRIMARY KEY NOT NULL,
  valor TEXT NOT NULL
)
''',
  '''
CREATE TABLE evidencia (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campana_id TEXT,
  tipo TEXT NOT NULL,
  descripcion TEXT NOT NULL,
  ruta TEXT NOT NULL DEFAULT '',
  creado_en TEXT NOT NULL,
  FOREIGN KEY (campana_id) REFERENCES campana(id) ON DELETE SET NULL
)
''',
  '''
CREATE TABLE sincronizacion_log (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  campana_id TEXT,
  accion TEXT NOT NULL,
  exito INTEGER NOT NULL,
  detalle TEXT NOT NULL DEFAULT '',
  creado_en TEXT NOT NULL,
  FOREIGN KEY (campana_id) REFERENCES campana(id) ON DELETE SET NULL
)
''',
  'CREATE INDEX idx_campana_unidad ON campana(codigo_unidad)',
  'CREATE INDEX idx_labor_campana ON labor(campana_id)',
  'CREATE INDEX idx_insumo_campana ON insumo(campana_id)',
  'CREATE INDEX idx_evento_funcion ON evento_app(funcion)',
  'CREATE INDEX idx_indicador_unidad ON indicador_ficha(codigo_unidad)',
];

const cultivosSemilla = <Map<String, Object>>[
  {'codigo': 'cebada', 'nombre': 'Cebada', 'transitorio': 1},
  {'codigo': 'trigo', 'nombre': 'Trigo', 'transitorio': 1},
  {'codigo': 'arveja', 'nombre': 'Arveja', 'transitorio': 1},
  {'codigo': 'maiz_amilaceo', 'nombre': 'Maíz amiláceo', 'transitorio': 1},
  {'codigo': 'haba', 'nombre': 'Haba', 'transitorio': 1},
];

const pisosSemilla = <Map<String, String>>[
  {'codigo': 'valle', 'nombre': 'Valle'},
  {'codigo': 'quechua', 'nombre': 'Quechua'},
  {'codigo': 'suni', 'nombre': 'Suni'},
  {'codigo': 'puna', 'nombre': 'Puna'},
  {'codigo': '', 'nombre': 'Sin precisar'},
];

const laboresSemilla = <String>[
  'Arado',
  'Siembra',
  'Deshierbo',
  'Aporque',
  'Riego',
  'Abonamiento',
  'Control de plagas',
  'Cosecha',
];
