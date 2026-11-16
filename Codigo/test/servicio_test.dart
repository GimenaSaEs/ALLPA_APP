import 'package:allpa/demo.dart';
import 'package:allpa/dominio/cultivos.dart';
import 'package:allpa/dominio/reglas.dart';
import 'package:flutter_test/flutter_test.dart';

import 'apoyo.dart';

void main() {
  test('el ejemplo de Illpe cuadra con la ficha', () async {
    final servicio = await nuevoServicio();
    final id = await cargarEjemplo(servicio);
    final ficha = await servicio.fichaCampana(id);
    expect(ficha.planEscrito, isTrue);
    expect(ficha.diasDesfaseSiembra, 8);
    expect(ficha.porcentajeRegistrosAgronomicosCompletos, 100);
    expect(ficha.porcentajeSuperficieSembrada, 60);
    expect(ficha.kilogramosSemillaPorHectarea, 75);
    expect(ficha.siembraIndividual, isTrue);
    expect(ficha.jornalesFamiliares, 6);
    expect(ficha.rendimientoKgHa, 2400);
    expect(ficha.productividadKgJornal, 440);
    expect((await servicio.calidad()).tiempoRegistroLaborSegundos, 45);
    await servicio.repo.cerrar();
  });

  test('no se repite la siembra ni se acepta un cultivo ajeno', () async {
    final servicio = await nuevoServicio();
    final creada = await abrirCampana(servicio);
    await servicio.registrarSiembra(creada.id, {
      'fecha_real': '2027-11-04',
      'individual': false,
      'kilogramos_semilla': 30,
      'hectareas_sembradas': 1,
      'jornales': 1,
    });
    await expectLater(
      servicio.registrarSiembra(creada.id, {
        'fecha_real': '2027-11-05',
        'individual': true,
        'kilogramos_semilla': 10,
        'hectareas_sembradas': 1,
        'jornales': 1,
      }),
      throwsA(predicate((error) => error is ErrorDeRegla && error.codigo == 'SIEMBRA_REPETIDA')),
    );
    await expectLater(
      servicio.crearCampana({
        'codigo_unidad': 'UP-ILL-001',
        'nombre_parcela': 'Otra',
        'hectareas_disponibles': 1,
        'cultivo': 'papa',
      }),
      throwsA(isA<ErrorDeRegla>()),
    );
    expect(await servicio.repo.contarCampanas(), 1);
    await servicio.repo.cerrar();
  });

  test('la ficha de la unidad suma dos parcelas', () async {
    final servicio = await nuevoServicio();
    final primera = await abrirCampana(servicio, cambios: {
      'nombre_parcela': 'Pampa alta',
      'hectareas_disponibles': 2,
      'hectareas_previstas': 1,
    });
    await servicio.registrarSiembra(primera.id, {
      'fecha_real': '2027-11-05',
      'individual': true,
      'kilogramos_semilla': 50,
      'hectareas_sembradas': 1,
      'jornales': 1,
    });
    final segunda = await servicio.crearCampana({
      'codigo_unidad': 'UP-ILL-001',
      'nombre_parcela': 'Pampa baja',
      'hectareas_disponibles': 2,
      'cultivo': 'haba',
      'hectareas_previstas': 1,
      'fecha_siembra_prevista': '2027-11-01',
      'labores_planificadas': ['Siembra'],
    });
    await servicio.registrarSiembra(segunda.id, {
      'fecha_real': '2027-11-09',
      'individual': true,
      'kilogramos_semilla': 50,
      'hectareas_sembradas': 1,
      'jornales': 1,
    });
    final ficha = await servicio.fichaUnidad('UP-ILL-001');
    expect(ficha.campanas, 2);
    expect(ficha.hectareasDisponibles, 4);
    expect(ficha.hectareasSembradas, 2);
    expect(ficha.kilogramosSemillaPorHectarea, 50);
    expect(ficha.diasDesfaseSiembra, 6);
    expect(ficha.planEscrito, isTrue);
    await servicio.repo.cerrar();
  });

  test('las siete funciones de campaña quedan cubiertas', () async {
    final servicio = await nuevoServicio();
    final id = await cargarEjemplo(servicio);
    await servicio.consultar(id);
    final calidad = await servicio.calidad();
    expect(calidad.funcionesCubiertas, funcionesCampana);
    expect(calidad.coberturaFuncionesPct, 100);
    expect(calidad.registrosParcelaGuardados, 1);
    expect(calidad.tareasBitacoraCompletadasPct, 100);
    expect(calidad.fallosOperacion, 0);
    await servicio.repo.cerrar();
  });

  test('una tarea rechazada baja el porcentaje de tareas y no es un fallo', () async {
    final servicio = await nuevoServicio();
    await cargarEjemplo(servicio);
    await expectLater(
      servicio.crearCampana({
        'codigo_unidad': 'UP-ILL-001',
        'nombre_parcela': 'X',
        'hectareas_disponibles': 1,
        'cultivo': 'papa',
      }),
      throwsA(isA<ErrorDeRegla>()),
    );
    final calidad = await servicio.calidad();
    expect(calidad.fallosOperacion, 0);
    expect(calidad.tareasBitacoraCompletadasPct, lessThan(100));
    expect(calidad.rechazosDeRegla, 1);
    await servicio.repo.cerrar();
  });
}
