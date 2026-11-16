import 'package:allpa/dominio/indicadores.dart';
import 'package:allpa/dominio/modelos.dart';
import 'package:flutter_test/flutter_test.dart';

Campana campanaDe(String id, int desfaseDias, {bool conLabor = true, String cultivo = 'cebada'}) {
  final prevista = DateTime(2027, 11, 1);
  final real = prevista.add(Duration(days: desfaseDias));
  return Campana(
    id: id,
    codigoUnidad: 'UP-ILL-001',
    nombreParcela: id,
    hectareasDisponibles: 1,
    plan: PlanCampana(
      cultivo: cultivo,
      hectareasPrevistas: 1,
      fechaSiembraPrevista: prevista,
      laboresPlanificadas: ['Arado'],
    ),
    siembra: Siembra(fechaReal: real, individual: true, kilogramosSemilla: 40, hectareasSembradas: 1, jornales: 1),
    labores: conLabor ? [Labor(nombre: 'Deshierbo', fecha: real, jornales: 1, segundosRegistro: 30)] : [],
  );
}

void main() {
  test('plan, desfase y registros de una campaña', () {
    final ficha = fichaGestion('UP-ILL-001', [campanaDe('a', 8)]);
    expect(ficha.planEscrito, isTrue);
    expect(ficha.diasDesfaseSiembra, 8);
    expect(ficha.porcentajeRegistrosAgronomicosCompletos, 100);
    expect(ficha.cultivos, 'Cebada');
  });

  test('sin plan el indicador queda en no', () {
    final campana = campanaDe('a', 0);
    campana.plan = PlanCampana();
    final ficha = fichaGestion('UP-ILL-001', [campana]);
    expect(ficha.planEscrito, isFalse);
    expect(ficha.diasDesfaseSiembra, isNull);
  });

  test('el desfase de varias parcelas es el promedio entero', () {
    final ficha = fichaGestion('UP-ILL-001', [campanaDe('a', 4), campanaDe('b', 6, cultivo: 'haba')]);
    expect(ficha.diasDesfaseSiembra, 5);
    expect(ficha.cultivos, 'Cebada, Haba');
  });

  test('el porcentaje de registros completos cuenta campañas', () {
    final ficha = fichaGestion('UP-ILL-001', [campanaDe('a', 1), campanaDe('b', 1, conLabor: false)]);
    expect(ficha.porcentajeRegistrosAgronomicosCompletos, 50);
  });
}
