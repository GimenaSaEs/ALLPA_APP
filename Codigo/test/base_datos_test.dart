import 'package:allpa/demo.dart';
import 'package:flutter_test/flutter_test.dart';

import 'apoyo.dart';

void main() {
  test('la base SQLite crea todas las tablas del diccionario y carga UP-ILL-001', () async {
    final servicio = await nuevoServicio();
    final vacio = await servicio.repo.conteoTablas();
    expect(vacio.length, 22);
    expect(vacio.keys, containsAll([
      'comunidad',
      'productor',
      'unidad',
      'parcela',
      'insumo',
      'indicador_ficha',
      'rechazo_regla',
      'configuracion',
      'evidencia',
      'sincronizacion_log',
    ]));
    expect(vacio['cultivo'], 5);
    expect(vacio['comunidad']! >= 1, isTrue);
    expect(vacio['tipo_labor']! >= 8, isTrue);

    await cargarEjemplo(servicio);
    final lleno = await servicio.repo.conteoTablas();
    expect(lleno['unidad'], 1);
    expect(lleno['campana'], 1);
    expect(lleno['plan'], 1);
    expect(lleno['plan_labor'], 3);
    expect(lleno['siembra'], 1);
    expect(lleno['labor'], 1);
    expect(lleno['cosecha'], 1);
    expect(lleno['evento_app']! > 0, isTrue);

    final ficha = await servicio.fichaUnidad('UP-ILL-001');
    expect(ficha.planEscrito, isTrue);
    expect(ficha.diasDesfaseSiembra, 8);
    expect(ficha.kilogramosSemillaPorHectarea, 75);
    expect(ficha.jornalesFamiliares, 6);
    expect(ficha.rendimientoKgHa, 2400);
    expect(ficha.productividadKgJornal, 440);

    await servicio.repo.cerrar();
  });
}
