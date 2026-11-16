import 'package:allpa/main.dart';
import 'package:allpa/servicios/bitacora_servicio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'apoyo.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late BitacoraServicio servicio;

  setUpAll(() async {
    servicio = await nuevoServicio();
  });

  tearDownAll(() async {
    await servicio.repo.cerrar();
  });

  testWidgets('el ingreso muestra Allpa y el código de la unidad', (tester) async {
    await tester.pumpWidget(AllpaApp(servicio: servicio));
    expect(find.text('Allpa'), findsOneWidget);
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.text('Código de unidad productiva'), findsOneWidget);
  });

  testWidgets('un código inválido avisa y no cambia de pantalla', (tester) async {
    await tester.pumpWidget(AllpaApp(servicio: servicio));
    await tester.enterText(find.byType(TextField).first, 'x');
    await tester.tap(find.text('Entrar'));
    await tester.pump();
    expect(find.text('Entrar'), findsOneWidget);
    expect(find.textContaining('3 y 20'), findsOneWidget);
  });
}
