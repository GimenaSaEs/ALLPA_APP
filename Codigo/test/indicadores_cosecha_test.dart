import 'package:allpa/dominio/indicadores.dart';
import 'package:allpa/dominio/modelos.dart';
import 'package:flutter_test/flutter_test.dart';

Campana conCosecha(String id, double sembrada, double cosechada, double produccion, double jornalesLabor) {
  return Campana(
    id: id,
    codigoUnidad: 'UP-ILL-001',
    nombreParcela: id,
    pisoEcologico: 'suni',
    hectareasDisponibles: sembrada,
    plan: PlanCampana(
      cultivo: 'arveja',
      hectareasPrevistas: sembrada,
      fechaSiembraPrevista: DateTime(2027, 10, 1),
      laboresPlanificadas: ['Siembra'],
    ),
    siembra: Siembra(
      fechaReal: DateTime(2027, 10, 5),
      individual: false,
      kilogramosSemilla: 20,
      hectareasSembradas: sembrada,
    ),
    labores: [Labor(nombre: 'Cosecha', fecha: DateTime(2028, 2, 1), jornales: jornalesLabor, segundosRegistro: 20)],
    cosecha: Cosecha(superficieCosechadaHa: cosechada, produccionKg: produccion),
  );
}

void main() {
  test('rendimiento y productividad del ejemplo de Illpe', () {
    final campana = Campana(
      id: 'ej',
      codigoUnidad: 'UP-ILL-001',
      nombreParcela: 'Pampa de Illpe',
      hectareasDisponibles: 2,
      plan: PlanCampana(
        cultivo: 'cebada',
        hectareasPrevistas: 1.2,
        fechaSiembraPrevista: DateTime(2027, 11, 10),
        laboresPlanificadas: ['Arado', 'Siembra', 'Deshierbo'],
      ),
      siembra: Siembra(
        fechaReal: DateTime(2027, 11, 18),
        individual: true,
        kilogramosSemilla: 90,
        hectareasSembradas: 1.2,
        jornales: 2,
      ),
      labores: [Labor(nombre: 'Deshierbo', fecha: DateTime(2027, 12, 20), jornales: 4, segundosRegistro: 45)],
      cosecha: Cosecha(superficieCosechadaHa: 1.1, produccionKg: 2640),
    );
    final ficha = fichaGestion('UP-ILL-001', [campana]);
    expect(ficha.rendimientoKgHa, 2400);
    expect(ficha.produccionTotalKg, 2640);
    expect(ficha.superficieCosechadaHa, 1.1);
    expect(ficha.productividadKgJornal, 440);
    expect(ficha.diasDesfaseSiembra, 8);
  });

  test('sin cosecha los indicadores de rendimiento quedan vacíos', () {
    final campana = conCosecha('a', 1, 1, 500, 2);
    campana.cosecha = null;
    final ficha = fichaGestion('UP-ILL-001', [campana]);
    expect(ficha.rendimientoKgHa, isNull);
    expect(ficha.produccionTotalKg, isNull);
    expect(ficha.productividadKgJornal, isNull);
  });

  test('el rendimiento de la unidad sale de los totales', () {
    final ficha = fichaGestion('UP-ILL-001', [
      conCosecha('a', 1, 1, 1000, 2),
      conCosecha('b', 1, 1, 3000, 2),
    ]);
    expect(ficha.produccionTotalKg, 4000);
    expect(ficha.superficieCosechadaHa, 2);
    expect(ficha.rendimientoKgHa, 2000);
    expect(ficha.jornalesFamiliares, 4);
    expect(ficha.productividadKgJornal, 1000);
  });
}
