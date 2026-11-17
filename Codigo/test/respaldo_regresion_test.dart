import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:allpa/dominio/reglas.dart';
import 'package:allpa/servicios/bitacora_servicio.dart';

import 'apoyo.dart';

void main() {
  test('crear con señal no implica que ya exista un respaldo', () async {
    final servicio = await nuevoServicio();
    addTearDown(servicio.repo.cerrar);
    final creada = await abrirCampana(servicio);
    expect((await servicio.repo.obtener(creada.id))!.sincronizado, isFalse);
    expect(await servicio.pendientes(), 1);
    expect(File(servicio.rutaRespaldo).existsSync(), isFalse);
  });

  test(
    'los cambios con señal vuelven a quedar pendientes y se respaldan',
    () async {
      final servicio = await nuevoServicio();
      addTearDown(servicio.repo.cerrar);
      final creada = await abrirCampana(servicio);
      await servicio.sincronizar();
      expect(await servicio.pendientes(), 0);
      await servicio.registrarSiembra(creada.id, {
        'fecha_real': '2027-11-18',
        'individual': true,
        'kilogramos_semilla': 90,
        'hectareas_sembradas': 1,
        'jornales': 2,
      });
      expect(await servicio.pendientes(), 1);
      await servicio.sincronizar();
      expect(await servicio.pendientes(), 0);
      final datos =
          jsonDecode(await File(servicio.rutaRespaldo).readAsString()) as List;
      expect(datos.single['siembra']['kilogramos_semilla'], 90);
      expect(datos.single['sincronizado'], isTrue);
    },
  );

  test('un respaldo fallido conserva las campañas pendientes', () async {
    final servicio = await nuevoServicio();
    addTearDown(servicio.repo.cerrar);
    await abrirCampana(servicio);
    final directorio = await Directory.systemTemp.createTemp(
      'allpa_respaldo_invalido_',
    );
    addTearDown(() => directorio.delete(recursive: true));
    final conRutaInvalida = BitacoraServicio(
      servicio.repo,
      rutaRespaldo: directorio.path,
    );
    await expectLater(
      conRutaInvalida.sincronizar(),
      throwsA(isA<ErrorPersistencia>()),
    );
    expect(await servicio.pendientes(), 1);
    expect((await servicio.calidad()).fallosOperacion, 1);
  });
}
