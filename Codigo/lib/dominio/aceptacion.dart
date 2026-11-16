import 'package:allpa/dominio/modelos.dart';

/// Valores de aceptación UP-ILL-001 según Capítulo IV y V de la tesis.
class CriterioAceptacion {
  final String indicador;
  final String esperado;
  final String obtenido;
  final bool cumple;

  const CriterioAceptacion({
    required this.indicador,
    required this.esperado,
    required this.obtenido,
    required this.cumple,
  });
}

List<CriterioAceptacion> criteriosUpIll001({
  required FichaGestion gestion,
  required FichaAplicativo app,
  int cantidadTablas = 22,
}) {
  bool cerca(num? a, num b, [num tol = 0.01]) => a != null && (a - b).abs() <= tol;

  return [
    CriterioAceptacion(
      indicador: 'Plan escrito',
      esperado: 'Sí',
      obtenido: gestion.planEscritoTexto,
      cumple: gestion.planEscrito == true,
    ),
    CriterioAceptacion(
      indicador: 'Desfase de siembra',
      esperado: '8 días',
      obtenido: gestion.diasDesfaseSiembra == null ? 'sin dato' : '${gestion.diasDesfaseSiembra} días',
      cumple: gestion.diasDesfaseSiembra == 8,
    ),
    CriterioAceptacion(
      indicador: 'Registros agronómicos',
      esperado: '100 %',
      obtenido: '${gestion.porcentajeRegistrosAgronomicosCompletos} %',
      cumple: cerca(gestion.porcentajeRegistrosAgronomicosCompletos, 100),
    ),
    CriterioAceptacion(
      indicador: 'Superficie sembrada',
      esperado: '60 %',
      obtenido: gestion.porcentajeSuperficieSembrada == null
          ? 'sin dato'
          : '${gestion.porcentajeSuperficieSembrada} %',
      cumple: cerca(gestion.porcentajeSuperficieSembrada, 60),
    ),
    CriterioAceptacion(
      indicador: 'Semilla',
      esperado: '75 kg/ha',
      obtenido: gestion.kilogramosSemillaPorHectarea == null
          ? 'sin dato'
          : '${gestion.kilogramosSemillaPorHectarea} kg/ha',
      cumple: cerca(gestion.kilogramosSemillaPorHectarea, 75),
    ),
    CriterioAceptacion(
      indicador: 'Siembra individual',
      esperado: 'Sí',
      obtenido: gestion.siembraIndividualTexto,
      cumple: gestion.siembraIndividual == true,
    ),
    CriterioAceptacion(
      indicador: 'Jornales familiares',
      esperado: '6',
      obtenido: '${gestion.jornalesFamiliares}',
      cumple: cerca(gestion.jornalesFamiliares, 6),
    ),
    CriterioAceptacion(
      indicador: 'Rendimiento',
      esperado: '2 400 kg/ha',
      obtenido: gestion.rendimientoKgHa == null ? 'sin dato' : '${gestion.rendimientoKgHa} kg/ha',
      cumple: cerca(gestion.rendimientoKgHa, 2400),
    ),
    CriterioAceptacion(
      indicador: 'Producción de cosecha',
      esperado: '2 640 kg',
      obtenido: gestion.produccionTotalKg == null ? 'sin dato' : '${gestion.produccionTotalKg} kg',
      cumple: cerca(gestion.produccionTotalKg, 2640),
    ),
    CriterioAceptacion(
      indicador: 'Superficie cosechada',
      esperado: '1,1 ha',
      obtenido: gestion.superficieCosechadaHa == null ? 'sin dato' : '${gestion.superficieCosechadaHa} ha',
      cumple: cerca(gestion.superficieCosechadaHa, 1.1),
    ),
    CriterioAceptacion(
      indicador: 'Productividad',
      esperado: '440 kg/jornal',
      obtenido: gestion.productividadKgJornal == null
          ? 'sin dato'
          : '${gestion.productividadKgJornal} kg/jornal',
      cumple: cerca(gestion.productividadKgJornal, 440),
    ),
    CriterioAceptacion(
      indicador: 'Cobertura de funciones',
      esperado: '100 %',
      obtenido: '${app.coberturaFuncionesPct} %',
      cumple: cerca(app.coberturaFuncionesPct, 100),
    ),
    CriterioAceptacion(
      indicador: 'Tiempo de labor',
      esperado: '45 s',
      obtenido: app.tiempoRegistroLaborSegundos == null
          ? 'sin dato'
          : '${app.tiempoRegistroLaborSegundos} s',
      cumple: cerca(app.tiempoRegistroLaborSegundos, 45),
    ),
    CriterioAceptacion(
      indicador: 'Fallos de operación',
      esperado: '0',
      obtenido: '${app.fallosOperacion}',
      cumple: app.fallosOperacion == 0,
    ),
    CriterioAceptacion(
      indicador: 'Tablas SQLite',
      esperado: '22',
      obtenido: '$cantidadTablas',
      cumple: cantidadTablas == 22,
    ),
  ];
}
