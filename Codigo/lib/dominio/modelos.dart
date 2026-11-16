// Entidades de la bitácora de campaña.

class PlanCampana {
  String? cultivo;
  double? hectareasPrevistas;
  DateTime? fechaSiembraPrevista;
  List<String> laboresPlanificadas;

  PlanCampana({
    this.cultivo,
    this.hectareasPrevistas,
    this.fechaSiembraPrevista,
    List<String>? laboresPlanificadas,
  }) : laboresPlanificadas = laboresPlanificadas ?? [];
}

class Siembra {
  DateTime fechaReal;
  bool individual;
  double kilogramosSemilla;
  double hectareasSembradas;
  double jornales;

  Siembra({
    required this.fechaReal,
    required this.individual,
    required this.kilogramosSemilla,
    required this.hectareasSembradas,
    this.jornales = 0,
  });
}

class Labor {
  String nombre;
  DateTime fecha;
  double jornales;
  double? segundosRegistro;

  Labor({
    required this.nombre,
    required this.fecha,
    required this.jornales,
    this.segundosRegistro,
  });
}

class Cosecha {
  double superficieCosechadaHa;
  double produccionKg;

  Cosecha({required this.superficieCosechadaHa, required this.produccionKg});
}

class Campana {
  String id;
  String codigoUnidad;
  String nombreParcela;
  String pisoEcologico;
  double hectareasDisponibles;
  PlanCampana plan;
  Siembra? siembra;
  List<Labor> labores;
  Cosecha? cosecha;
  String origen;
  bool sincronizado;

  Campana({
    required this.id,
    required this.codigoUnidad,
    required this.nombreParcela,
    this.pisoEcologico = '',
    required this.hectareasDisponibles,
    PlanCampana? plan,
    this.siembra,
    List<Labor>? labores,
    this.cosecha,
    this.origen = 'en_linea',
    this.sincronizado = true,
  }) : plan = plan ?? PlanCampana(),
       labores = labores ?? [];
}

class FichaGestion {
  String codigoUnidad;
  String cultivos;
  bool? planEscrito;
  int? diasDesfaseSiembra;
  double porcentajeRegistrosAgronomicosCompletos;
  double hectareasDisponibles;
  double hectareasSembradas;
  double kilogramosSemilla;
  double? kilogramosSemillaPorHectarea;
  double? porcentajeSuperficieSembrada;
  bool? siembraIndividual;
  double jornalesFamiliares;
  double? rendimientoKgHa;
  double? produccionTotalKg;
  double? superficieCosechadaHa;
  double? productividadKgJornal;
  int campanas;

  FichaGestion({
    required this.codigoUnidad,
    required this.cultivos,
    required this.planEscrito,
    required this.diasDesfaseSiembra,
    required this.porcentajeRegistrosAgronomicosCompletos,
    required this.hectareasDisponibles,
    required this.hectareasSembradas,
    required this.kilogramosSemilla,
    required this.kilogramosSemillaPorHectarea,
    required this.porcentajeSuperficieSembrada,
    required this.siembraIndividual,
    required this.jornalesFamiliares,
    required this.rendimientoKgHa,
    required this.produccionTotalKg,
    required this.superficieCosechadaHa,
    required this.productividadKgJornal,
    required this.campanas,
  });

  String get planEscritoTexto => _sino(planEscrito);
  String get siembraIndividualTexto => _sino(siembraIndividual);
}

class FichaAplicativo {
  double coberturaFuncionesPct;
  int registrosParcelaGuardados;
  double? tareasBitacoraCompletadasPct;
  double? tiempoRegistroLaborSegundos;
  double? disponibilidadSinSenalPct;
  int fallosOperacion;
  int rechazosDeRegla;
  List<String> funcionesCubiertas;

  FichaAplicativo({
    required this.coberturaFuncionesPct,
    required this.registrosParcelaGuardados,
    required this.tareasBitacoraCompletadasPct,
    required this.tiempoRegistroLaborSegundos,
    required this.disponibilidadSinSenalPct,
    required this.fallosOperacion,
    required this.rechazosDeRegla,
    required this.funcionesCubiertas,
  });
}

class EventoApp {
  String tipo;
  String funcion;
  bool conSenal;
  String detalle;

  EventoApp({
    required this.tipo,
    required this.funcion,
    required this.conSenal,
    this.detalle = '',
  });
}

String _sino(bool? valor) {
  if (valor == null) return 'sin dato';
  return valor ? 'sí' : 'no';
}
