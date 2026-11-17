import 'package:allpa/ui/fila_calidad.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

const funciones = 'parcela, plan, siembra, labor, insumo, consulta, cosecha';

Widget pantalla({required double ancho, double escala = 1, String valor = funciones}) {
  return MaterialApp(
    home: Scaffold(
      body: MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(escala)),
        child: Align(
          alignment: Alignment.topLeft,
          child: SizedBox(width: ancho, child: FilaCalidad(titulo: 'Funciones cubiertas', valor: valor)),
        ),
      ),
    ),
  );
}

void main() {
  testWidgets('la lista larga aparece debajo del título sin comprimirlo', (tester) async {
    await tester.pumpWidget(pantalla(ancho: 280));
    final titulo = tester.getRect(find.text('Funciones cubiertas'));
    final valor = tester.getRect(find.text(funciones));
    expect(valor.top, greaterThan(titulo.bottom));
    expect(titulo.height, lessThan(35));
    expect(valor.right, lessThanOrEqualTo(280));
    expect(tester.takeException(), isNull);
  });

  testWidgets('admite un ancho reducido con el texto ampliado', (tester) async {
    await tester.pumpWidget(pantalla(ancho: 240, escala: 1.5));
    final titulo = tester.getRect(find.text('Funciones cubiertas'));
    final valor = tester.getRect(find.text(funciones));
    expect(valor.top, greaterThan(titulo.bottom));
    // A esta escala el título puede ocupar dos líneas, pero dispone de todo el ancho.
    expect(titulo.width, 240);
    expect(titulo.height, lessThan(70));
    expect(valor.right, lessThanOrEqualTo(240));
    expect(tester.takeException(), isNull);
  });

  testWidgets('con espacio suficiente mantiene los valores cortos en la misma fila', (tester) async {
    await tester.pumpWidget(pantalla(ancho: 520, valor: '7 de 7'));
    final titulo = tester.getRect(find.text('Funciones cubiertas'));
    final valor = tester.getRect(find.text('7 de 7'));
    expect(valor.top, titulo.top);
    expect(valor.left, greaterThan(titulo.left));
    expect(tester.takeException(), isNull);
  });
}
