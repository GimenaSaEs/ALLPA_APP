import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:allpa/main.dart';
import 'package:allpa/presentation/providers/allpa_provider.dart';
import 'package:allpa/presentation/screens/home_dashboard_screen.dart';

void main() {
  testWidgets('opens the ALLPA first-run welcome screen', (tester) async {
    await tester.pumpWidget(const MyApp(initializeData: false));

    expect(find.text('ALLPA'), findsOneWidget);
    expect(find.text('Gestión de Cultivos Agrícolas'), findsOneWidget);
    expect(find.text('REGISTRAR MI PERFIL'), findsOneWidget);
    expect(find.text('Flutter Demo Home Page'), findsNothing);
  });

  testWidgets('welcome screen opens the producer profile form', (tester) async {
    await tester.pumpWidget(const MyApp(initializeData: false));
    await tester.tap(find.text('REGISTRAR MI PERFIL'));
    await tester.pumpAndSettle();

    expect(find.text('Registro de Productor'), findsOneWidget);
    expect(find.text('GUARDAR PERFIL'), findsOneWidget);
  });

  testWidgets('dashboard exposes ALLPA modules through navigation', (
    tester,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AllpaProvider(),
        child: const MaterialApp(home: HomeDashboardScreen()),
      ),
    );

    expect(find.text('ALLPA'), findsNWidgets(2));
    expect(find.text('Resumen de campaña'), findsOneWidget);

    await tester.tap(find.text('Terrenos').last);
    await tester.pumpAndSettle();
    expect(find.text('Mis Terrenos Agrícolas'), findsOneWidget);

    await tester.tap(find.text('Cultivos').last);
    await tester.pumpAndSettle();
    expect(find.text('Aún no hay cultivos registrados'), findsOneWidget);
  });
}
