import 'dart:math' as math;

import 'package:allpa/dominio/cultivos.dart';
import 'package:allpa/dominio/modelos.dart';

const _epsilon = 1e-6;
final _codigo = RegExp(r'^[A-Z0-9][A-Z0-9-]{2,19}$');

class ErrorDeRegla implements Exception {
  final String codigo;
  final String mensaje;

  ErrorDeRegla(this.codigo, this.mensaje);

  @override
  String toString() => mensaje;
}

class ErrorPersistencia implements Exception {
  final String mensaje;

  ErrorPersistencia(this.mensaje);

  @override
  String toString() => mensaje;
}

String normalizarCodigo(String? codigo) {
  final limpio = (codigo ?? '').trim().toUpperCase();
  if (!_codigo.hasMatch(limpio)) {
    throw ErrorDeRegla(
      'CODIGO_INVALIDO',
      'El código de unidad usa entre 3 y 20 letras, números o guiones.',
    );
  }
  return limpio;
}

String etiquetaCultivo(String? clave) {
  if (clave == null || clave.isEmpty) return '';
  return cultivos[clave] ?? clave;
}

String? validarCultivo(Object? clave) {
  if (clave == null || clave.toString().trim().isEmpty) return null;
  final codigo = clave
      .toString()
      .trim()
      .toLowerCase()
      .replaceAll(' ', '_')
      .replaceAll('á', 'a')
      .replaceAll('é', 'e')
      .replaceAll('í', 'i')
      .replaceAll('ó', 'o')
      .replaceAll('ú', 'u');
  if (!cultivos.containsKey(codigo)) {
    throw ErrorDeRegla(
      'CULTIVO_FUERA_DE_AMBITO',
      'En Illpe este aplicativo registra cebada, trigo, arveja, maíz amiláceo y haba.',
    );
  }
  return codigo;
}

double validarSuperficieDisponible(double hectareas) {
  if (!hectareas.isFinite || hectareas <= 0) {
    throw ErrorDeRegla(
      'SUPERFICIE_INVALIDA',
      'Las hectáreas disponibles deben ser mayores que cero.',
    );
  }
  if (hectareas > 100) {
    throw ErrorDeRegla(
      'SUPERFICIE_INVALIDA',
      'La superficie supera el tamaño de parcela que se registra en Illpe. Revise el dato.',
    );
  }
  return hectareas;
}

double validarSuperficieUsada(double usada, double disponible, String etiqueta) {
  if (!usada.isFinite || !disponible.isFinite || disponible <= 0 || usada <= 0) {
    throw ErrorDeRegla(
      'SUPERFICIE_INVALIDA',
      'Las hectáreas de $etiqueta deben ser mayores que cero.',
    );
  }
  if (usada - disponible > _epsilon) {
    throw ErrorDeRegla(
      'SUPERFICIE_EXCEDIDA',
      'Las hectáreas de $etiqueta no pueden superar las hectáreas disponibles de la parcela.',
    );
  }
  return usada;
}

bool planEscrito(PlanCampana plan) {
  if (plan.cultivo == null || !cultivos.containsKey(plan.cultivo)) return false;
  if (plan.hectareasPrevistas == null || plan.hectareasPrevistas! <= 0) {
    return false;
  }
  if (plan.fechaSiembraPrevista == null) return false;
  return plan.laboresPlanificadas.isNotEmpty;
}

int? desfaseSiembraDias(DateTime? prevista, DateTime? real) {
  if (prevista == null || real == null) return null;
  final inicio = DateTime(prevista.year, prevista.month, prevista.day);
  final fin = DateTime(real.year, real.month, real.day);
  return fin.difference(inicio).inDays;
}

bool registroAgronomicoCompleto(Campana campana) {
  if (campana.plan.cultivo == null || campana.plan.cultivo!.isEmpty) {
    return false;
  }
  final siembra = campana.siembra;
  if (siembra == null || siembra.kilogramosSemilla <= 0) return false;
  return campana.labores.isNotEmpty;
}

double? kilogramosSemillaPorHectarea(double kilogramos, double hectareasSembradas) {
  if (hectareasSembradas <= 0) return null;
  return _redondear(kilogramos / hectareasSembradas);
}

double? porcentajeSuperficie(double sembradas, double disponibles) {
  if (disponibles <= 0) return null;
  return _redondear(sembradas / disponibles * 100);
}

double? rendimientoKgHa(double produccionKg, double superficieCosechada) {
  if (superficieCosechada <= 0) return null;
  return _redondear(produccionKg / superficieCosechada);
}

double? productividadKgJornal(double produccionKg, double jornales) {
  if (jornales <= 0) return null;
  return _redondear(produccionKg / jornales);
}

double jornalesFamiliares(Campana campana) {
  final base = campana.siembra?.jornales ?? 0;
  final suma = campana.labores.fold<double>(base, (total, labor) => total + labor.jornales);
  return _redondear(suma, 4);
}

PlanCampana validarPlan(Map<String, dynamic> datos, double hectareasDisponibles) {
  final cultivo = validarCultivo(datos['cultivo']);
  final crudo = datos['hectareas_previstas'];
  double? previstas;
  if (crudo != null && crudo.toString().trim().isNotEmpty) {
    previstas = _noNegativo(crudo, 'Las hectáreas previstas');
    if (previstas <= 0) {
      throw ErrorDeRegla(
        'PLAN_INVALIDO',
        'Las hectáreas previstas deben ser mayores que cero.',
      );
    }
    if (previstas - hectareasDisponibles > _epsilon) {
      throw ErrorDeRegla(
        'PLAN_INVALIDO',
        'Las hectáreas previstas no pueden superar las hectáreas disponibles.',
      );
    }
  }
  return PlanCampana(
    cultivo: cultivo,
    hectareasPrevistas: previstas,
    fechaSiembraPrevista: _fechaOpcional(
      datos['fecha_siembra_prevista'],
      'la fecha prevista de siembra',
    ),
    laboresPlanificadas: _labores(datos['labores_planificadas']),
  );
}

Siembra validarSiembra(Map<String, dynamic> datos, double hectareasDisponibles) {
  final fecha = _fechaObligatoria(datos['fecha_real'], 'la fecha real de siembra');
  if (datos['individual'] is! bool) {
    throw ErrorDeRegla('SIEMBRA_INVALIDA', 'Indique si la siembra es individual.');
  }
  return Siembra(
    fechaReal: fecha,
    individual: datos['individual'] == true,
    kilogramosSemilla: _noNegativo(datos['kilogramos_semilla'], 'Los kilogramos de semilla'),
    hectareasSembradas: validarSuperficieUsada(
      _noNegativo(datos['hectareas_sembradas'], 'Las hectáreas sembradas'),
      hectareasDisponibles,
      'siembra',
    ),
    jornales: _noNegativo(datos['jornales'] ?? 0, 'Los jornales de la siembra'),
  );
}

({String nombre, DateTime fecha, double jornales, double? segundos}) validarLabor(
  Map<String, dynamic> datos,
) {
  final nombre = (datos['nombre'] ?? '').toString().trim();
  if (nombre.length < 2) {
    throw ErrorDeRegla('LABOR_INVALIDA', 'Escriba el nombre de la labor.');
  }
  final fecha = _fechaObligatoria(datos['fecha'], 'la fecha de la labor');
  final jornales = _noNegativo(datos['jornales'], 'Los jornales de la labor');
  final crudo = datos['segundos_registro'];
  if (crudo == null || crudo.toString().trim().isEmpty) {
    return (nombre: nombre, fecha: fecha, jornales: jornales, segundos: null);
  }
  final segundos = _noNegativo(crudo, 'El tiempo de registro');
  if (segundos > 7200) {
    throw ErrorDeRegla('TIEMPO_INVALIDO', 'El tiempo de registro de la labor no es válido.');
  }
  return (nombre: nombre, fecha: fecha, jornales: jornales, segundos: _redondear(segundos));
}

Cosecha validarCosecha(Map<String, dynamic> datos, Campana campana) {
  final siembra = campana.siembra;
  if (siembra == null) {
    throw ErrorDeRegla('COSECHA_SIN_SIEMBRA', 'Registre la siembra antes de la cosecha.');
  }
  final superficie = _noNegativo(datos['superficie_cosechada_ha'], 'La superficie cosechada');
  final produccion = _noNegativo(datos['produccion_kg'], 'La producción');
  if (superficie <= 0) {
    throw ErrorDeRegla('COSECHA_INVALIDA', 'La superficie cosechada debe ser mayor que cero.');
  }
  if (superficie - siembra.hectareasSembradas > _epsilon) {
    throw ErrorDeRegla(
      'COSECHA_INVALIDA',
      'La superficie cosechada no puede superar la superficie sembrada.',
    );
  }
  return Cosecha(superficieCosechadaHa: superficie, produccionKg: produccion);
}

double _redondear(double valor, [int decimales = 2]) {
  final factor = math.pow(10, decimales).toDouble();
  return (valor * factor).round() / factor;
}

double _noNegativo(Object? valor, String etiqueta) {
  final numero = valor is num
      ? valor.toDouble()
      : double.tryParse(valor.toString().trim().replaceAll(',', '.'));
  if (numero == null || !numero.isFinite) {
    throw ErrorDeRegla('NUMERO_INVALIDO', '$etiqueta debe ser un número.');
  }
  if (numero < 0) {
    throw ErrorDeRegla('NUMERO_INVALIDO', '$etiqueta no puede ser negativo.');
  }
  return numero;
}

DateTime _fechaObligatoria(Object? valor, String etiqueta) {
  final fecha = _fechaOpcional(valor, etiqueta);
  if (fecha == null) throw ErrorDeRegla('FECHA_INVALIDA', 'Falta $etiqueta.');
  return fecha;
}

DateTime? _fechaOpcional(Object? valor, String etiqueta) {
  if (valor == null || valor.toString().trim().isEmpty) return null;
  if (valor is DateTime) {
    return DateTime(valor.year, valor.month, valor.day);
  }
  final texto = valor.toString().trim();
  final partes = texto.length >= 10 ? texto.substring(0, 10).split('-') : <String>[];
  if (partes.length != 3) {
    throw ErrorDeRegla('FECHA_INVALIDA', 'Revise $etiqueta. Use el formato año-mes-día.');
  }
  final anio = int.tryParse(partes[0]);
  final mes = int.tryParse(partes[1]);
  final dia = int.tryParse(partes[2]);
  if (anio == null || mes == null || dia == null) {
    throw ErrorDeRegla('FECHA_INVALIDA', 'Revise $etiqueta. Use el formato año-mes-día.');
  }
  final fecha = DateTime(anio, mes, dia);
  if (fecha.year != anio || fecha.month != mes || fecha.day != dia) {
    throw ErrorDeRegla('FECHA_INVALIDA', 'Revise $etiqueta. Use el formato año-mes-día.');
  }
  return fecha;
}

List<String> _labores(Object? valor) {
  if (valor == null) return [];
  final partes = valor is String ? valor.split(',') : (valor as List).map((e) => e.toString());
  final limpias = <String>[];
  for (final parte in partes) {
    final texto = parte.trim();
    if (texto.isNotEmpty && !limpias.contains(texto)) limpias.add(texto);
  }
  if (limpias.length > 8) return limpias.sublist(0, 8);
  return limpias;
}

String isoFecha(DateTime? fecha) {
  if (fecha == null) return '';
  final mes = fecha.month.toString().padLeft(2, '0');
  final dia = fecha.day.toString().padLeft(2, '0');
  return '${fecha.year}-$mes-$dia';
}
