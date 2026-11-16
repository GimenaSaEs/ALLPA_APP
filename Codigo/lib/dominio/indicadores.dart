import 'package:allpa/dominio/cultivos.dart';
import 'package:allpa/dominio/modelos.dart';
import 'package:allpa/dominio/reglas.dart';

/// Agrega las campañas de una unidad productiva.
///
/// El desfase de la ficha es el promedio entero cuando hay más de una parcela.
/// La semilla por hectárea, el rendimiento y la productividad usan los totales.
FichaGestion fichaGestion(String codigoUnidad, List<Campana> campanas) {
  if (campanas.isEmpty) {
    return FichaGestion(
      codigoUnidad: codigoUnidad,
      cultivos: '',
      planEscrito: null,
      diasDesfaseSiembra: null,
      porcentajeRegistrosAgronomicosCompletos: 0,
      hectareasDisponibles: 0,
      hectareasSembradas: 0,
      kilogramosSemilla: 0,
      kilogramosSemillaPorHectarea: null,
      porcentajeSuperficieSembrada: null,
      siembraIndividual: null,
      jornalesFamiliares: 0,
      rendimientoKgHa: null,
      produccionTotalKg: null,
      superficieCosechadaHa: null,
      productividadKgJornal: null,
      campanas: 0,
    );
  }

  final nombres = <String>[];
  final desfases = <int>[];
  var sembradas = 0.0;
  var semilla = 0.0;
  var jornales = 0.0;
  final individuales = <bool>[];
  var produccion = 0.0;
  var cosechada = 0.0;
  var hayCosecha = false;
  var completas = 0;

  for (final campana in campanas) {
    final etiqueta = etiquetaCultivo(campana.plan.cultivo);
    if (etiqueta.isNotEmpty && !nombres.contains(etiqueta)) nombres.add(etiqueta);
    final siembra = campana.siembra;
    if (siembra != null) {
      final desfase = desfaseSiembraDias(campana.plan.fechaSiembraPrevista, siembra.fechaReal);
      if (desfase != null) desfases.add(desfase);
      sembradas += siembra.hectareasSembradas;
      semilla += siembra.kilogramosSemilla;
      individuales.add(siembra.individual);
    }
    jornales += jornalesFamiliares(campana);
    final cosecha = campana.cosecha;
    if (cosecha != null) {
      hayCosecha = true;
      produccion += cosecha.produccionKg;
      cosechada += cosecha.superficieCosechadaHa;
    }
    if (registroAgronomicoCompleto(campana)) completas += 1;
  }

  final disponibles = _cuatro(campanas.fold<double>(0, (s, c) => s + c.hectareasDisponibles));
  sembradas = _cuatro(sembradas);
  semilla = _cuatro(semilla);
  jornales = _cuatro(jornales);

  return FichaGestion(
    codigoUnidad: codigoUnidad,
    cultivos: nombres.join(', '),
    planEscrito: campanas.any((c) => planEscrito(c.plan)),
    diasDesfaseSiembra: _promedioEntero(desfases),
    porcentajeRegistrosAgronomicosCompletos: _dos(completas / campanas.length * 100),
    hectareasDisponibles: disponibles,
    hectareasSembradas: sembradas,
    kilogramosSemilla: semilla,
    kilogramosSemillaPorHectarea: kilogramosSemillaPorHectarea(semilla, sembradas),
    porcentajeSuperficieSembrada: porcentajeSuperficie(sembradas, disponibles),
    siembraIndividual: individuales.isEmpty ? null : individuales.every((v) => v),
    jornalesFamiliares: jornales,
    rendimientoKgHa: hayCosecha ? rendimientoKgHa(produccion, cosechada) : null,
    produccionTotalKg: hayCosecha ? _cuatro(produccion) : null,
    superficieCosechadaHa: hayCosecha ? _cuatro(cosechada) : null,
    productividadKgJornal: hayCosecha ? productividadKgJornal(produccion, jornales) : null,
    campanas: campanas.length,
  );
}

/// Traduce los eventos del aplicativo a funcionalidad, usabilidad y confiabilidad.
///
/// La disponibilidad sin señal cuenta si el aplicativo atendió el intento.
/// Una caída al guardar la reduce. Un rechazo de regla no es un fallo de operación.
/// Las tareas completadas sí bajan cuando el registro no se guardó.
FichaAplicativo fichaAplicativo(
  List<EventoApp> eventos,
  int registrosGuardados,
  List<double> tiemposLabor,
) {
  final deCampana = eventos.where((e) => funcionesCampana.contains(e.funcion)).toList();
  final intentos = deCampana.where((e) => e.tipo == 'intento').toList();
  final exitos = deCampana.where((e) => e.tipo == 'exito').toList();
  final sinSenal = deCampana.where((e) => !e.conSenal && e.tipo == 'intento').toList();
  final caidasSinSenal = deCampana.where((e) => !e.conSenal && e.tipo == 'fallo').toList();
  final fallos = eventos.where((e) => e.tipo == 'fallo').toList();
  final rechazos = eventos.where((e) => e.tipo == 'rechazo').toList();
  final cubiertas = <String>[
    for (final funcion in funcionesCampana)
      if (exitos.any((e) => e.funcion == funcion)) funcion,
  ];

  return FichaAplicativo(
    coberturaFuncionesPct: _dos(cubiertas.length / funcionesCampana.length * 100),
    registrosParcelaGuardados: registrosGuardados,
    tareasBitacoraCompletadasPct: intentos.isEmpty ? null : _dos(exitos.length / intentos.length * 100),
    tiempoRegistroLaborSegundos: tiemposLabor.isEmpty
        ? null
        : _dos(tiemposLabor.reduce((a, b) => a + b) / tiemposLabor.length),
    disponibilidadSinSenalPct: sinSenal.isEmpty
        ? null
        : _dos((sinSenal.length - caidasSinSenal.length) / sinSenal.length * 100),
    fallosOperacion: fallos.length,
    rechazosDeRegla: rechazos.length,
    funcionesCubiertas: cubiertas,
  );
}

int? _promedioEntero(List<int> valores) {
  if (valores.isEmpty) return null;
  final suma = valores.reduce((a, b) => a + b);
  return (suma / valores.length).round();
}

double _dos(double valor) => (valor * 100).round() / 100;

double _cuatro(double valor) => (valor * 10000).round() / 10000;
