import 'dart:convert';
import 'dart:io';

import 'package:allpa/datos/repositorio.dart';
import 'package:allpa/dominio/reglas.dart';
import 'package:allpa/servicios/bitacora_servicio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:path/path.dart' as p;

import 'apoyo.dart';

void main() {
  test('sin señal el registro queda en el dispositivo', () async {
    final directorio = await Directory.systemTemp.createTemp('allpa_off_');
    final ruta = p.join(directorio.path, 'allpa.sqlite');
    final repo = await Repositorio.abrir(ruta);
    final servicio = BitacoraServicio(repo, rutaRespaldo: p.join(directorio.path, 'respaldo.json'));
    servicio.establecerSenal(false);
    final creada = await abrirCampana(servicio);
    expect((await repo.obtener(creada.id))!.sincronizado, isFalse);
    await repo.cerrar();

    final reabierto = await Repositorio.abrir(ruta);
    final otra = await reabierto.obtener(creada.id);
    expect(otra!.nombreParcela, 'Pampa');
    expect(otra.sincronizado, isFalse);
    expect(otra.origen, 'sin_senal');
    await reabierto.cerrar();
  });

  test('no envía el respaldo si no hay señal y el dato permanece', () async {
    final servicio = await nuevoServicio();
    servicio.establecerSenal(false);
    final creada = await abrirCampana(servicio);
    await expectLater(
      servicio.sincronizar(),
      throwsA(predicate((error) => error is ErrorDeRegla && error.codigo == 'SIN_SENAL')),
    );
    expect((await servicio.repo.obtener(creada.id))!.sincronizado, isFalse);
    expect(File(servicio.rutaRespaldo).existsSync(), isFalse);
    await servicio.repo.cerrar();
  });

  test('con señal el respaldo marca las campañas', () async {
    final servicio = await nuevoServicio();
    servicio.establecerSenal(false);
    await abrirCampana(servicio);
    servicio.establecerSenal(true);
    final enviadas = await servicio.sincronizar();
    expect(enviadas, 1);
    final guardado = jsonDecode(File(servicio.rutaRespaldo).readAsStringSync()) as List;
    expect(guardado.first['sincronizado'], isTrue);
    expect(await servicio.repo.pendientes(), isEmpty);
    await servicio.repo.cerrar();
  });

  test('un rechazo sin señal no baja la disponibilidad', () async {
    final servicio = await nuevoServicio();
    servicio.establecerSenal(false);
    await servicio.ingresar('UP-ILL-001', 'Unidad');
    await expectLater(
      servicio.crearCampana({
        'codigo_unidad': 'UP-ILL-001',
        'nombre_parcela': 'Pampa',
        'hectareas_disponibles': 1,
        'cultivo': 'papa',
      }),
      throwsA(isA<ErrorDeRegla>()),
    );
    final calidad = await servicio.calidad();
    expect(calidad.disponibilidadSinSenalPct, 100);
    expect(calidad.fallosOperacion, 0);
    expect(calidad.rechazosDeRegla, 1);
    expect(calidad.registrosParcelaGuardados, 0);
    await servicio.repo.cerrar();
  });

  test('una caída al guardar sí baja la disponibilidad', () async {
    final servicio = await nuevoServicio();
    servicio.establecerSenal(false);
    await servicio.ingresar('UP-ILL-001', 'Unidad');
    servicio.repo.forzarFalloSiguiente();
    await expectLater(
      servicio.crearCampana({
        'codigo_unidad': 'UP-ILL-001',
        'nombre_parcela': 'Pampa',
        'hectareas_disponibles': 1.5,
        'cultivo': 'haba',
        'hectareas_previstas': 1,
        'fecha_siembra_prevista': '2027-11-01',
        'labores_planificadas': ['Arado'],
      }),
      throwsA(isA<ErrorPersistencia>()),
    );
    expect(await servicio.repo.contarCampanas(), 0);
    final calidad = await servicio.calidad();
    expect(calidad.fallosOperacion, 1);
    expect(calidad.disponibilidadSinSenalPct, 0);
    await servicio.repo.cerrar();
  });
}
