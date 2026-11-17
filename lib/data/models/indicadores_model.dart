class IndicadoresModel {
  final int cultivoId;
  final String agricultorNombre;
  final String terrenoNombre;
  final String especie;
  final String variedad;
  final double areaTerrenoHa;
  final double areaSembradaHa;

  // Manejo Agronómico
  final String? fechaPrevista;
  final String? fechaReal;
  final int? desfaseSiembraDias;
  final double pctRegistrosCompletos;

  // Eficiencia y Recursos
  final double pctSuperficieSembrada; // (areaSembrada / areaTerreno) * 100
  final double totalSemillaKg;
  final double semillaKgHa; // totalSemillaKg / areaSembradaHa
  final double jornalesFamiliaresTotal;
  final bool siembraIndividual;

  // Rendimiento y Producción
  final bool tieneCosecha;
  final String? fechaCosecha;
  final double areaCosechadaHa;
  final double produccionTotalKg;
  final double? rendimientoKgHa; // produccionTotalKg / areaCosechadaHa
  final double? productividadKgJornal; // produccionTotalKg / jornalesCosecha

  IndicadoresModel({
    required this.cultivoId,
    required this.agricultorNombre,
    required this.terrenoNombre,
    required this.especie,
    required this.variedad,
    required this.areaTerrenoHa,
    required this.areaSembradaHa,
    this.fechaPrevista,
    this.fechaReal,
    this.desfaseSiembraDias,
    required this.pctRegistrosCompletos,
    required this.pctSuperficieSembrada,
    required this.totalSemillaKg,
    required this.semillaKgHa,
    required this.jornalesFamiliaresTotal,
    required this.siembraIndividual,
    this.tieneCosecha = false,
    this.fechaCosecha,
    this.areaCosechadaHa = 0.0,
    this.produccionTotalKg = 0.0,
    this.rendimientoKgHa,
    this.productividadKgJornal,
  });

  Map<String, dynamic> toMap() {
    return {
      'id_cultivo': cultivoId,
      'agricultor': agricultorNombre,
      'terreno': terrenoNombre,
      'especie': especie,
      'variedad': variedad,
      'fecha_prevista': fechaPrevista ?? '',
      'fecha_real': fechaReal ?? '',
      'desfase_dias': desfaseSiembraDias ?? '',
      'area_terreno_ha': areaTerrenoHa,
      'area_sembrada_ha': areaSembradaHa,
      'pct_area_sembrada': pctSuperficieSembrada,
      'total_semilla_kg': totalSemillaKg,
      'semilla_kg_ha': semillaKgHa,
      'total_jornales': jornalesFamiliaresTotal,
      'siembra_individual': siembraIndividual ? 'Sí' : 'No',
      'tiene_cosecha': tieneCosecha ? 'Sí' : 'No',
      'fecha_cosecha': fechaCosecha ?? '',
      'area_cosechada_ha': areaCosechadaHa,
      'produccion_kg': produccionTotalKg,
      'rendimiento_kg_ha': rendimientoKgHa ?? '',
      'productividad_kg_jornal': productividadKgJornal ?? '',
      'pct_completitud': pctRegistrosCompletos,
    };
  }
}
