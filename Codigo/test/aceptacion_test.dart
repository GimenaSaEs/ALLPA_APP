import 'package:allpa/demo.dart';
import 'package:allpa/dominio/aceptacion.dart';
import 'package:flutter_test/flutter_test.dart';

import 'apoyo.dart';

void main() {
  test('UP-ILL-001 cumple los criterios de aceptación del Capítulo V', () async {
    final servicio = await nuevoServicio();
    await cargarEjemplo(servicio);
    final gestion = await servicio.fichaUnidad('UP-ILL-001');
    final app = await servicio.calidad();
    final criterios = criteriosUpIll001(gestion: gestion, app: app);
    expect(criterios.every((c) => c.cumple), isTrue, reason: criterios.where((c) => !c.cumple).map((c) => c.indicador).join(', '));
    await servicio.repo.cerrar();
  });
}
