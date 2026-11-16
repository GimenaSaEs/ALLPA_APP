import 'package:allpa/dominio/indicadores.dart';
import 'package:allpa/dominio/modelos.dart';
import 'package:allpa/dominio/reglas.dart';
import 'package:flutter_test/flutter_test.dart';

Campana parcela(String id, double disponibles, double sembradas, double semilla, bool individual, double jornales) {
  return Campana(
    id: id,
    codigoUnidad: 'UP-ILL-001',
    nombreParcela: id,
    hectareasDisponibles: disponibles,
    plan: PlanCampana(
      cultivo: 'trigo',
      hectareasPrevistas: sembradas,
      fechaSiembraPrevista: DateTime(2027, 11, 1),
      laboresPlanificadas: ['Siembra'],
    ),
    siembra: Siembra(
      fechaReal: DateTime(2027, 11, 2),
      individual: individual,
      kilogramosSemilla: semilla,
      hectareasSembradas: sembradas,
      jornales: jornales,
    ),
  );
}

void main() {
  test('fórmulas de semilla y superficie', () {
    expect(kilogramosSemillaPorHectarea(90, 1.2), 75);
    expect(porcentajeSuperficie(1.2, 2), 60);
  });

  test('la semilla por hectárea usa los totales de la unidad', () {
    final ficha = fichaGestion('UP-ILL-001', [
      parcela('a', 2, 1, 100, true, 2),
      parcela('b', 4, 3, 60, true, 3),
    ]);
    expect(ficha.hectareasDisponibles, 6);
    expect(ficha.hectareasSembradas, 4);
    expect(ficha.kilogramosSemilla, 160);
    expect(ficha.kilogramosSemillaPorHectarea, 40);
    expect(ficha.porcentajeSuperficieSembrada, (4 / 6 * 100 * 100).round() / 100);
    expect(ficha.siembraIndividual, isTrue);
    expect(ficha.jornalesFamiliares, 5);
  });

  test('si una parcela tiene apoyo la unidad no es siembra individual', () {
    final ficha = fichaGestion('UP-ILL-001', [
      parcela('a', 1, 1, 10, true, 1),
      parcela('b', 1, 1, 10, false, 2),
    ]);
    expect(ficha.siembraIndividual, isFalse);
  });
}
