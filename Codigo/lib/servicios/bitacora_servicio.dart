import 'dart:convert';
import 'dart:io';

import 'package:allpa/datos/base_datos.dart';
import 'package:allpa/datos/repositorio.dart';
import 'package:allpa/dominio/indicadores.dart';
import 'package:allpa/dominio/modelos.dart';
import 'package:allpa/dominio/reglas.dart';

int _secuenciaId = 0;

String nuevoId() => '${DateTime.now().microsecondsSinceEpoch}${_secuenciaId++}';

class BitacoraServicio {
  final Repositorio repo;
  final String rutaRespaldo;
  bool haySenal = true;

  BitacoraServicio(this.repo, {String? rutaRespaldo})
    : rutaRespaldo = rutaRespaldo ?? repo.rutaRespaldoPorDefecto;

  static Future<BitacoraServicio> abrir() async {
    asegurarMotorSqlite();
    final repo = await Repositorio.abrir(rutaBaseDatosPorDefecto());
    return BitacoraServicio(repo);
  }

  void establecerSenal(bool valor) {
    haySenal = valor;
  }

  Future<({String codigo, String nombre})> ingresar(String codigo, [String nombre = '']) async {
    final limpio = normalizarCodigo(codigo);
    await repo.guardarUnidad(limpio, nombre.trim());
    await repo.registrarSincronizacion(null, 'ingreso', true, limpio);
    return (codigo: limpio, nombre: await repo.nombreUnidad(limpio));
  }

  Future<Campana> crearCampana(Map<String, dynamic> datos) async {
    await _intento('parcela');
    try {
      final campana = await _armar(datos);
      await repo.insertarCampana(campana);
      await _exito('parcela');
      if (planEscrito(campana.plan)) {
        await _intento('plan');
        await _exito('plan');
      }
      return campana;
    } on ErrorDeRegla catch (error) {
      await _rechazo('parcela', error);
      rethrow;
    } on ErrorPersistencia catch (error) {
      await _fallo('parcela', error);
      rethrow;
    }
  }

  Future<Campana> registrarPlan(String campanaId, Map<String, dynamic> datos) async {
    await _intento('plan');
    try {
      final campana = await _exigir(campanaId);
      if (campana.siembra != null) {
        throw ErrorDeRegla(
          'PLAN_CERRADO',
          'El plan ya no se modifica: la siembra está registrada y el desfase depende de esa fecha.',
        );
      }
      campana.plan = validarPlan(datos, campana.hectareasDisponibles);
      if (!planEscrito(campana.plan)) {
        throw ErrorDeRegla(
          'PLAN_INCOMPLETO',
          'El plan escrito necesita cultivo, hectáreas previstas, fecha prevista y al menos una labor.',
        );
      }
      _marcarOrigen(campana);
      await repo.guardarPlan(campana);
    } on ErrorDeRegla catch (error) {
      await _rechazo('plan', error);
      rethrow;
    } on ErrorPersistencia catch (error) {
      await _fallo('plan', error);
      rethrow;
    }
    await _exito('plan');
    return (await repo.obtener(campanaId))!;
  }

  Future<Campana> registrarSiembra(String campanaId, Map<String, dynamic> datos) async {
    await _intento('siembra');
    late Siembra siembra;
    try {
      final campana = await _exigir(campanaId);
      if (campana.siembra != null) {
        throw ErrorDeRegla('SIEMBRA_REPETIDA', 'Esta chacra ya tiene la siembra registrada.');
      }
      siembra = validarSiembra(datos, campana.hectareasDisponibles);
      campana.siembra = siembra;
      _marcarOrigen(campana);
      await repo.guardarSiembra(campana);
    } on ErrorDeRegla catch (error) {
      await _rechazo('siembra', error);
      rethrow;
    } on ErrorPersistencia catch (error) {
      await _fallo('siembra', error);
      rethrow;
    }
    await _exito('siembra');
    if (siembra.kilogramosSemilla > 0) {
      await _intento('insumo');
      await _exito('insumo');
    }
    return (await repo.obtener(campanaId))!;
  }

  Future<Campana> registrarLabor(String campanaId, Map<String, dynamic> datos) async {
    await _intento('labor');
    try {
      final campana = await _exigir(campanaId);
      final labor = validarLabor(datos);
      _marcarOrigen(campana);
      await repo.agregarLabor(
        campana,
        Labor(
          nombre: labor.nombre,
          fecha: labor.fecha,
          jornales: labor.jornales,
          segundosRegistro: labor.segundos,
        ),
      );
    } on ErrorDeRegla catch (error) {
      await _rechazo('labor', error);
      rethrow;
    } on ErrorPersistencia catch (error) {
      await _fallo('labor', error);
      rethrow;
    }
    await _exito('labor');
    return (await repo.obtener(campanaId))!;
  }

  Future<Campana> registrarCosecha(String campanaId, Map<String, dynamic> datos) async {
    await _intento('cosecha');
    try {
      final campana = await _exigir(campanaId);
      if (campana.cosecha != null) {
        throw ErrorDeRegla('COSECHA_REPETIDA', 'Esta chacra ya tiene la cosecha registrada.');
      }
      campana.cosecha = validarCosecha(datos, campana);
      _marcarOrigen(campana);
      await repo.guardarCosecha(campana);
    } on ErrorDeRegla catch (error) {
      await _rechazo('cosecha', error);
      rethrow;
    } on ErrorPersistencia catch (error) {
      await _fallo('cosecha', error);
      rethrow;
    }
    await _exito('cosecha');
    return (await repo.obtener(campanaId))!;
  }

  Future<List<Campana>> listar(String codigoUnidad) {
    return repo.listar(normalizarCodigo(codigoUnidad));
  }

  Future<Campana> consultar(String campanaId) async {
    await _intento('consulta');
    final campana = await repo.obtener(campanaId);
    if (campana == null) {
      final error = ErrorDeRegla('NO_EXISTE', 'No se encontró esa campaña en el celular.');
      await _rechazo('consulta', error);
      throw error;
    }
    await _exito('consulta');
    return campana;
  }

  Future<FichaGestion> fichaUnidad(String codigoUnidad) async {
    final codigo = normalizarCodigo(codigoUnidad);
    return fichaGestion(codigo, await repo.listar(codigo));
  }

  Future<FichaGestion> fichaCampana(String campanaId) async {
    final campana = await _exigir(campanaId);
    final ficha = fichaGestion(campana.codigoUnidad, [campana]);
    await repo.guardarIndicadorFicha(campanaId, ficha);
    return ficha;
  }

  Future<FichaAplicativo> calidad() async {
    final ficha = fichaAplicativo(
      await repo.listarEventos(),
      await repo.contarCampanas(),
      await repo.tiemposLabor(),
    );
    await repo.registrarSesionPrueba(
      nombre: 'calidad_app',
      cobertura: ficha.coberturaFuncionesPct,
      tiempoLabor: ficha.tiempoRegistroLaborSegundos,
      disponibilidad: ficha.disponibilidadSinSenalPct,
      fallos: ficha.fallosOperacion,
    );
    return ficha;
  }

  Future<int> sincronizar() async {
    await _intento('respaldo');
    if (!haySenal) {
      final error = ErrorDeRegla(
        'SIN_SENAL',
        'No hay señal para enviar el respaldo. El registro sigue en el celular.',
      );
      await _rechazo('respaldo', error);
      throw error;
    }
    try {
      final pendientes = await repo.pendientes();
      final todas = await repo.listarTodas();
      final idsPendientes = pendientes.map((campana) => campana.id).toSet();
      final datosRespaldo = [
        for (final campana in todas)
          {
            ...serializarCampana(campana),
            'sincronizado': idsPendientes.contains(campana.id) ? true : campana.sincronizado,
          },
      ];
      final archivo = File(rutaRespaldo);
      await archivo.parent.create(recursive: true);
      await archivo.writeAsString(
        const JsonEncoder.withIndent('  ').convert(datosRespaldo),
      );
      await repo.marcarSincronizadas(pendientes.map((c) => c.id).toList());
      await repo.registrarRespaldo(rutaRespaldo, pendientes.length, true);
      await repo.registrarSincronizacion(null, 'respaldo', true, '${pendientes.length} campañas');
      await _exito('respaldo');
      return pendientes.length;
    } on FileSystemException catch (error) {
      final fallo = ErrorPersistencia(error.message);
      await _fallo('respaldo', fallo);
      throw fallo;
    } on ErrorPersistencia catch (error) {
      await _fallo('respaldo', error);
      rethrow;
    }
  }

  Future<int> pendientes() async => (await repo.pendientes()).length;

  Future<Campana> _armar(Map<String, dynamic> datos) async {
    final codigo = normalizarCodigo((datos['codigo_unidad'] ?? '').toString());
    if (!await repo.existeUnidad(codigo)) {
      throw ErrorDeRegla(
        'UNIDAD_NO_INGRESADA',
        'Primero ingrese con el código de la unidad productiva.',
      );
    }
    final nombre = (datos['nombre_parcela'] ?? '').toString().trim();
    if (nombre.length < 2) {
      throw ErrorDeRegla('PARCELA_INVALIDA', 'Escriba el nombre de la parcela.');
    }
    final crudo = datos['hectareas_disponibles'];
    final numero = crudo is num
        ? crudo.toDouble()
        : double.tryParse('${crudo ?? ''}'.trim().replaceAll(',', '.'));
    if (numero == null) {
      throw ErrorDeRegla('SUPERFICIE_INVALIDA', 'Las hectáreas disponibles deben ser un número.');
    }
    final hectareas = validarSuperficieDisponible(numero);
    return Campana(
      id: nuevoId(),
      codigoUnidad: codigo,
      nombreParcela: nombre,
      pisoEcologico: (datos['piso_ecologico'] ?? '').toString().trim().toLowerCase(),
      hectareasDisponibles: hectareas,
      plan: validarPlan(datos, hectareas),
      origen: haySenal ? 'en_linea' : 'sin_senal',
      sincronizado: false,
    );
  }

  Future<Campana> _exigir(String campanaId) async {
    final campana = await repo.obtener(campanaId);
    if (campana == null) {
      throw ErrorDeRegla('NO_EXISTE', 'No se encontró esa campaña en el celular.');
    }
    return campana;
  }

  void _marcarOrigen(Campana campana) {
    // Todo cambio debe incorporarse al siguiente respaldo, con o sin señal.
    campana.sincronizado = false;
    if (!haySenal) {
      campana.origen = 'sin_senal';
    }
  }

  Future<void> _intento(String funcion) => repo.registrarEvento('intento', funcion, haySenal);

  Future<void> _exito(String funcion) => repo.registrarEvento('exito', funcion, haySenal);

  Future<void> _rechazo(String funcion, ErrorDeRegla error) async {
    await repo.registrarEvento('rechazo', funcion, haySenal, error.mensaje);
    await repo.registrarRechazo(error.codigo, funcion, error.mensaje);
  }

  Future<void> _fallo(String funcion, ErrorPersistencia error) {
    return repo.registrarEvento('fallo', funcion, haySenal, error.mensaje);
  }
}

Map<String, dynamic> serializarCampana(Campana campana) {
  final desfase = campana.siembra == null
      ? null
      : desfaseSiembraDias(campana.plan.fechaSiembraPrevista, campana.siembra!.fechaReal);
  return {
    'id': campana.id,
    'codigo_unidad': campana.codigoUnidad,
    'nombre_parcela': campana.nombreParcela,
    'piso_ecologico': campana.pisoEcologico,
    'hectareas_disponibles': campana.hectareasDisponibles,
    'plan': {
      'cultivo': campana.plan.cultivo,
      'cultivo_texto': etiquetaCultivo(campana.plan.cultivo),
      'hectareas_previstas': campana.plan.hectareasPrevistas,
      'fecha_siembra_prevista': isoFecha(campana.plan.fechaSiembraPrevista),
      'labores_planificadas': campana.plan.laboresPlanificadas,
      'escrito': planEscrito(campana.plan),
    },
    'siembra': campana.siembra == null
        ? null
        : {
            'fecha_real': isoFecha(campana.siembra!.fechaReal),
            'individual': campana.siembra!.individual,
            'kilogramos_semilla': campana.siembra!.kilogramosSemilla,
            'hectareas_sembradas': campana.siembra!.hectareasSembradas,
            'jornales': campana.siembra!.jornales,
          },
    'labores': [
      for (final labor in campana.labores)
        {
          'nombre': labor.nombre,
          'fecha': isoFecha(labor.fecha),
          'jornales': labor.jornales,
          'segundos_registro': labor.segundosRegistro,
        },
    ],
    'cosecha': campana.cosecha == null
        ? null
        : {
            'superficie_cosechada_ha': campana.cosecha!.superficieCosechadaHa,
            'produccion_kg': campana.cosecha!.produccionKg,
          },
    'desfase_dias': desfase,
    'origen': campana.origen,
    'sincronizado': campana.sincronizado,
  };
}
