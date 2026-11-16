import 'package:allpa/dominio/modelos.dart';
import 'package:allpa/dominio/reglas.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('solo acepta los cultivos de Illpe', () {
    expect(validarCultivo('cebada'), 'cebada');
    expect(validarCultivo('maiz_amilaceo'), 'maiz_amilaceo');
    expect(() => validarCultivo('papa'), throwsA(isA<ErrorDeRegla>()));
  });

  test('el desfase es la diferencia en días y puede ser un adelanto', () {
    final prevista = DateTime(2027, 11, 10);
    expect(desfaseSiembraDias(prevista, DateTime(2027, 11, 18)), 8);
    expect(desfaseSiembraDias(prevista, DateTime(2027, 11, 8)), -2);
    expect(desfaseSiembraDias(null, DateTime(2027, 11, 8)), isNull);
  });

  test('el plan escrito exige cultivo, superficie, fecha y labor', () {
    expect(
      planEscrito(PlanCampana(cultivo: 'cebada', hectareasPrevistas: 1, fechaSiembraPrevista: DateTime(2027, 11, 1))),
      isFalse,
    );
    expect(
      planEscrito(
        PlanCampana(
          cultivo: 'trigo',
          hectareasPrevistas: 1,
          fechaSiembraPrevista: DateTime(2027, 11, 1),
          laboresPlanificadas: ['Arado'],
        ),
      ),
      isTrue,
    );
  });

  test('no se siembra más superficie de la disponible', () {
    expect(
      () => validarSiembra({
        'fecha_real': '2027-11-18',
        'individual': true,
        'kilogramos_semilla': 10,
        'hectareas_sembradas': 3,
        'jornales': 1,
      }, 2),
      throwsA(predicate((error) => error is ErrorDeRegla && error.codigo == 'SUPERFICIE_EXCEDIDA')),
    );
  });

  test('la cosecha no supera lo sembrado y exige siembra previa', () {
    final campana = Campana(id: 'c1', codigoUnidad: 'UP-ILL-001', nombreParcela: 'Pampa', hectareasDisponibles: 2);
    expect(
      () => validarCosecha({'superficie_cosechada_ha': 1, 'produccion_kg': 100}, campana),
      throwsA(isA<ErrorDeRegla>()),
    );
    campana.siembra = Siembra(
      fechaReal: DateTime(2027, 11, 18),
      individual: true,
      kilogramosSemilla: 40,
      hectareasSembradas: 1,
      jornales: 1,
    );
    expect(
      () => validarCosecha({'superficie_cosechada_ha': 1.5, 'produccion_kg': 100}, campana),
      throwsA(isA<ErrorDeRegla>()),
    );
  });

  test('rendimiento, productividad y registro completo', () {
    expect(rendimientoKgHa(2640, 1.1), 2400);
    expect(productividadKgJornal(2640, 6), 440);
    expect(rendimientoKgHa(100, 0), isNull);
    final campana = Campana(
      id: 'c1',
      codigoUnidad: 'UP-ILL-001',
      nombreParcela: 'Pampa',
      hectareasDisponibles: 2,
      plan: PlanCampana(
        cultivo: 'cebada',
        hectareasPrevistas: 1,
        fechaSiembraPrevista: DateTime(2027, 11, 1),
        laboresPlanificadas: ['Arado'],
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
    expect(registroAgronomicoCompleto(campana), isTrue);
    expect(jornalesFamiliares(campana), 6);
    campana.labores = [];
    expect(registroAgronomicoCompleto(campana), isFalse);
  });
}
