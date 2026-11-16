import 'package:allpa/datos/base_datos.dart';
import 'package:allpa/datos/esquema.dart';
import 'package:allpa/dominio/modelos.dart';
import 'package:allpa/dominio/reglas.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

/// Persistencia SQLite ampliada (22 tablas del diccionario de tesis).
class Repositorio {
  final String ruta;
  final Database _db;
  bool _falloForzado = false;

  Repositorio._(this.ruta, this._db);

  static Future<Repositorio> abrir(String ruta) async {
    final limpia = ruta.toLowerCase().endsWith('.json')
        ? '${ruta.substring(0, ruta.length - 5)}.db'
        : ruta;
    final db = await abrirBaseDatos(limpia);
    return Repositorio._(limpia, db);
  }

  String get rutaRespaldoPorDefecto => p.join(p.dirname(ruta), 'respaldo_illpe.json');

  Future<void> cerrar() => _db.close();

  void forzarFalloSiguiente() {
    _falloForzado = true;
  }

  Future<void> guardarUnidad(String codigo, String nombre) async {
    final existe = await existeUnidad(codigo);
    if (existe) {
      if (nombre.trim().isNotEmpty) {
        await _db.update('unidad', {'nombre': nombre.trim()}, where: 'codigo = ?', whereArgs: [codigo]);
      }
      return;
    }
    final ahora = DateTime.now().toIso8601String();
    final productorId = await _db.insert('productor', {
      'nombres': nombre.trim().isEmpty ? codigo : nombre.trim(),
      'apellidos': '',
      'telefono': '',
      'comunidad_id': 1,
      'creado_en': ahora,
    });
    await _db.insert('unidad', {
      'codigo': codigo,
      'nombre': nombre.trim(),
      'productor_id': productorId,
      'creado_en': ahora,
    });
  }

  Future<String> nombreUnidad(String codigo) async {
    final filas = await _db.query('unidad', columns: ['nombre'], where: 'codigo = ?', whereArgs: [codigo]);
    if (filas.isEmpty) return '';
    return filas.first['nombre'] as String? ?? '';
  }

  Future<bool> existeUnidad(String codigo) async {
    final filas = await _db.query('unidad', columns: ['codigo'], where: 'codigo = ?', whereArgs: [codigo]);
    return filas.isNotEmpty;
  }

  Future<void> insertarCampana(Campana campana) async {
    _exigirDispositivo();
    await _db.transaction((txn) async {
      final piso = campana.pisoEcologico;
      final parcelaId = await txn.insert('parcela', {
        'codigo_unidad': campana.codigoUnidad,
        'nombre': campana.nombreParcela,
        'piso_ecologico': piso,
        'hectareas_disponibles': campana.hectareasDisponibles,
      });
      await txn.insert('campana', {
        'id': campana.id,
        'codigo_unidad': campana.codigoUnidad,
        'parcela_id': parcelaId,
        'nombre_parcela': campana.nombreParcela,
        'piso_ecologico': piso,
        'hectareas_disponibles': campana.hectareasDisponibles,
        'anio': 2027,
        'origen': campana.origen,
        'sincronizado': campana.sincronizado ? 1 : 0,
      });
      await _guardarPlanTxn(txn, campana.id, campana.plan);
      await txn.insert('evidencia', {
        'campana_id': campana.id,
        'tipo': 'registro_parcela',
        'descripcion': 'Parcela ${campana.nombreParcela} creada en Allpa',
        'ruta': '',
        'creado_en': DateTime.now().toIso8601String(),
      });
    });
  }

  Future<void> guardarPlan(Campana campana) async {
    _exigirDispositivo();
    await _db.transaction((txn) async {
      await _actualizarCabecera(txn, campana);
      await _guardarPlanTxn(txn, campana.id, campana.plan);
    });
  }

  Future<void> guardarSiembra(Campana campana) async {
    _exigirDispositivo();
    final siembra = campana.siembra;
    if (siembra == null) return;
    await _db.transaction((txn) async {
      await _actualizarCabecera(txn, campana);
      await txn.insert('siembra', {
        'campana_id': campana.id,
        'fecha_real': isoFecha(siembra.fechaReal),
        'individual': siembra.individual ? 1 : 0,
        'kilogramos_semilla': siembra.kilogramosSemilla,
        'hectareas_sembradas': siembra.hectareasSembradas,
        'jornales': siembra.jornales,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
      await txn.insert('insumo', {
        'campana_id': campana.id,
        'tipo': 'semilla',
        'nombre': campana.plan.cultivo ?? 'semilla',
        'cantidad': siembra.kilogramosSemilla,
        'unidad_medida': 'kg',
        'fecha': isoFecha(siembra.fechaReal),
      });
    });
  }

  Future<void> agregarLabor(Campana campana, Labor labor) async {
    _exigirDispositivo();
    await _db.transaction((txn) async {
      await _actualizarCabecera(txn, campana);
      final tipoId = await _tipoLaborId(txn, labor.nombre);
      await txn.insert('labor', {
        'campana_id': campana.id,
        'tipo_labor_id': tipoId,
        'nombre': labor.nombre,
        'fecha': isoFecha(labor.fecha),
        'jornales': labor.jornales,
        'segundos_registro': labor.segundosRegistro,
      });
    });
  }

  Future<void> guardarCosecha(Campana campana) async {
    _exigirDispositivo();
    final cosecha = campana.cosecha;
    if (cosecha == null) return;
    await _db.transaction((txn) async {
      await _actualizarCabecera(txn, campana);
      await txn.insert('cosecha', {
        'campana_id': campana.id,
        'superficie_cosechada_ha': cosecha.superficieCosechadaHa,
        'produccion_kg': cosecha.produccionKg,
      }, conflictAlgorithm: ConflictAlgorithm.replace);
    });
  }

  Future<Campana?> obtener(String id) async {
    final filas = await _db.query('campana', where: 'id = ?', whereArgs: [id]);
    if (filas.isEmpty) return null;
    return _campanaCompleta(filas.first);
  }

  Future<List<Campana>> listar(String codigoUnidad) async {
    final filas = await _db.query(
      'campana',
      where: 'codigo_unidad = ?',
      whereArgs: [codigoUnidad],
      orderBy: 'nombre_parcela COLLATE NOCASE',
    );
    final lista = <Campana>[];
    for (final fila in filas) {
      lista.add(await _campanaCompleta(fila));
    }
    return lista;
  }

  Future<List<Campana>> listarTodas() async {
    final filas = await _db.query('campana', orderBy: 'codigo_unidad, nombre_parcela');
    final lista = <Campana>[];
    for (final fila in filas) {
      lista.add(await _campanaCompleta(fila));
    }
    return lista;
  }

  Future<int> contarCampanas() async {
    final r = await _db.rawQuery('SELECT COUNT(*) AS c FROM campana');
    return (r.first['c'] as int?) ?? 0;
  }

  Future<List<Campana>> pendientes() async {
    final filas = await _db.query('campana', where: 'sincronizado = 0');
    final lista = <Campana>[];
    for (final fila in filas) {
      lista.add(await _campanaCompleta(fila));
    }
    return lista;
  }

  Future<void> marcarSincronizadas(List<String> identificadores) async {
    _exigirDispositivo();
    if (identificadores.isEmpty) return;
    final lote = _db.batch();
    for (final id in identificadores) {
      lote.update('campana', {'sincronizado': 1}, where: 'id = ?', whereArgs: [id]);
    }
    await lote.commit(noResult: true);
  }

  Future<void> registrarEvento(String tipo, String funcion, bool conSenal, [String detalle = '']) async {
    await _db.insert('evento_app', {
      'tipo': tipo,
      'funcion': funcion,
      'con_senal': conSenal ? 1 : 0,
      'detalle': detalle,
      'creado_en': DateTime.now().toIso8601String(),
    });
  }

  Future<List<EventoApp>> listarEventos() async {
    final filas = await _db.query('evento_app', orderBy: 'id ASC');
    return [
      for (final fila in filas)
        EventoApp(
          tipo: fila['tipo'] as String,
          funcion: fila['funcion'] as String,
          conSenal: (fila['con_senal'] as int) == 1,
          detalle: fila['detalle'] as String? ?? '',
        ),
    ];
  }

  Future<List<double>> tiemposLabor() async {
    final filas = await _db.query(
      'labor',
      columns: ['segundos_registro'],
      where: 'segundos_registro IS NOT NULL',
    );
    return [
      for (final fila in filas) (fila['segundos_registro'] as num).toDouble(),
    ];
  }

  /// Conteos por tabla para exposición / verificación (22 tablas).
  Future<Map<String, int>> conteoTablas() async {
    final mapa = <String, int>{};
    for (final tabla in nombresTablas) {
      final r = await _db.rawQuery('SELECT COUNT(*) AS c FROM $tabla');
      mapa[tabla] = (r.first['c'] as int?) ?? 0;
    }
    return mapa;
  }

  Future<void> registrarRechazo(String codigoRegla, String funcion, String mensaje) async {
    await _db.insert('rechazo_regla', {
      'codigo_regla': codigoRegla,
      'funcion': funcion,
      'mensaje': mensaje,
      'creado_en': DateTime.now().toIso8601String(),
    });
  }

  Future<void> registrarRespaldo(String rutaArchivo, int campanas, bool conSenal) async {
    await _db.insert('respaldo', {
      'ruta_archivo': rutaArchivo,
      'campanas': campanas,
      'con_senal': conSenal ? 1 : 0,
      'creado_en': DateTime.now().toIso8601String(),
    });
  }

  Future<void> registrarSesionPrueba({
    required String nombre,
    required double cobertura,
    double? tiempoLabor,
    double? disponibilidad,
    required int fallos,
  }) async {
    await _db.insert('sesion_prueba', {
      'nombre': nombre,
      'cobertura_pct': cobertura,
      'tiempo_labor_s': tiempoLabor,
      'disponibilidad_sin_senal_pct': disponibilidad,
      'fallos': fallos,
      'creado_en': DateTime.now().toIso8601String(),
    });
  }

  Future<void> guardarIndicadorFicha(String campanaId, FichaGestion ficha) async {
    await _db.insert('indicador_ficha', {
      'campana_id': campanaId,
      'codigo_unidad': ficha.codigoUnidad,
      'plan_escrito': ficha.planEscrito == null ? null : (ficha.planEscrito! ? 1 : 0),
      'desfase_dias': ficha.diasDesfaseSiembra,
      'registros_completos_pct': ficha.porcentajeRegistrosAgronomicosCompletos,
      'superficie_sembrada_pct': ficha.porcentajeSuperficieSembrada,
      'semilla_kg_ha': ficha.kilogramosSemillaPorHectarea,
      'siembra_individual': ficha.siembraIndividual == null ? null : (ficha.siembraIndividual! ? 1 : 0),
      'jornales_familiares': ficha.jornalesFamiliares,
      'rendimiento_kg_ha': ficha.rendimientoKgHa,
      'produccion_kg': ficha.produccionTotalKg,
      'superficie_cosechada_ha': ficha.superficieCosechadaHa,
      'productividad_kg_jornal': ficha.productividadKgJornal,
      'calculado_en': DateTime.now().toIso8601String(),
    });
  }

  Future<void> registrarSincronizacion(String? campanaId, String accion, bool exito, [String detalle = '']) async {
    await _db.insert('sincronizacion_log', {
      'campana_id': campanaId,
      'accion': accion,
      'exito': exito ? 1 : 0,
      'detalle': detalle,
      'creado_en': DateTime.now().toIso8601String(),
    });
  }

  Future<void> _actualizarCabecera(Transaction txn, Campana campana) async {
    await txn.update(
      'campana',
      {
        'origen': campana.origen,
        'sincronizado': campana.sincronizado ? 1 : 0,
      },
      where: 'id = ?',
      whereArgs: [campana.id],
    );
  }

  Future<void> _guardarPlanTxn(Transaction txn, String campanaId, PlanCampana plan) async {
    await txn.insert('plan', {
      'campana_id': campanaId,
      'cultivo': plan.cultivo,
      'hectareas_previstas': plan.hectareasPrevistas,
      'fecha_siembra_prevista': isoFecha(plan.fechaSiembraPrevista),
    }, conflictAlgorithm: ConflictAlgorithm.replace);
    await txn.delete('plan_labor', where: 'campana_id = ?', whereArgs: [campanaId]);
    var orden = 0;
    for (final nombre in plan.laboresPlanificadas) {
      final tipoId = await _tipoLaborId(txn, nombre);
      await txn.insert('plan_labor', {
        'campana_id': campanaId,
        'tipo_labor_id': tipoId,
        'nombre': nombre,
        'orden': orden++,
      });
    }
  }

  Future<int?> _tipoLaborId(DatabaseExecutor txn, String nombre) async {
    final filas = await txn.query('tipo_labor', columns: ['id'], where: 'nombre = ?', whereArgs: [nombre]);
    if (filas.isEmpty) return null;
    return filas.first['id'] as int?;
  }

  Future<Campana> _campanaCompleta(Map<String, Object?> fila) async {
    final id = fila['id'] as String;
    final planFilas = await _db.query('plan', where: 'campana_id = ?', whereArgs: [id]);
    final laboresPlan = await _db.query(
      'plan_labor',
      where: 'campana_id = ?',
      whereArgs: [id],
      orderBy: 'orden ASC',
    );
    final siembraFilas = await _db.query('siembra', where: 'campana_id = ?', whereArgs: [id]);
    final laborFilas = await _db.query('labor', where: 'campana_id = ?', whereArgs: [id], orderBy: 'id ASC');
    final cosechaFilas = await _db.query('cosecha', where: 'campana_id = ?', whereArgs: [id]);

    PlanCampana plan = PlanCampana();
    if (planFilas.isNotEmpty) {
      final p = planFilas.first;
      final fecha = p['fecha_siembra_prevista'] as String? ?? '';
      plan = PlanCampana(
        cultivo: p['cultivo'] as String?,
        hectareasPrevistas: (p['hectareas_previstas'] as num?)?.toDouble(),
        fechaSiembraPrevista: fecha.isEmpty ? null : _leerFecha(fecha),
        laboresPlanificadas: [
          for (final l in laboresPlan) l['nombre'] as String,
        ],
      );
    }

    Siembra? siembra;
    if (siembraFilas.isNotEmpty) {
      final s = siembraFilas.first;
      siembra = Siembra(
        fechaReal: _leerFecha(s['fecha_real'] as String)!,
        individual: (s['individual'] as int) == 1,
        kilogramosSemilla: (s['kilogramos_semilla'] as num).toDouble(),
        hectareasSembradas: (s['hectareas_sembradas'] as num).toDouble(),
        jornales: (s['jornales'] as num).toDouble(),
      );
    }

    Cosecha? cosecha;
    if (cosechaFilas.isNotEmpty) {
      final c = cosechaFilas.first;
      cosecha = Cosecha(
        superficieCosechadaHa: (c['superficie_cosechada_ha'] as num).toDouble(),
        produccionKg: (c['produccion_kg'] as num).toDouble(),
      );
    }

    return Campana(
      id: id,
      codigoUnidad: fila['codigo_unidad'] as String,
      nombreParcela: fila['nombre_parcela'] as String,
      pisoEcologico: fila['piso_ecologico'] as String? ?? '',
      hectareasDisponibles: (fila['hectareas_disponibles'] as num).toDouble(),
      plan: plan,
      siembra: siembra,
      labores: [
        for (final l in laborFilas)
          Labor(
            nombre: l['nombre'] as String,
            fecha: _leerFecha(l['fecha'] as String)!,
            jornales: (l['jornales'] as num).toDouble(),
            segundosRegistro: (l['segundos_registro'] as num?)?.toDouble(),
          ),
      ],
      cosecha: cosecha,
      origen: fila['origen'] as String? ?? 'en_linea',
      sincronizado: (fila['sincronizado'] as int?) != 0,
    );
  }

  void _exigirDispositivo() {
    if (_falloForzado) {
      _falloForzado = false;
      throw ErrorPersistencia('No se pudo guardar el registro en el dispositivo.');
    }
  }
}

DateTime? _leerFecha(String? valor) {
  if (valor == null || valor.isEmpty) return null;
  final partes = valor.substring(0, 10).split('-');
  return DateTime(int.parse(partes[0]), int.parse(partes[1]), int.parse(partes[2]));
}
