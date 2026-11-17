import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:allpa/data/models/terreno_model.dart';
import 'package:allpa/presentation/providers/allpa_provider.dart';
import 'package:allpa/presentation/screens/terrenos/terreno_detail_screen.dart';

class _TerrainProvider extends AllpaProvider {
  @override
  List<TerrenoModel> get terrenos => [
    TerrenoModel(
      id: 1,
      agricultorId: 1,
      nombre: 'Parcela demo',
      areaHa: 1,
      createdAt: '2026-01-01',
    ),
  ];
}

void main() {
  testWidgets('terrain detail fits a narrow screen with enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(
      ChangeNotifierProvider<AllpaProvider>(
        create: (_) => _TerrainProvider(),
        child: MaterialApp(
          home: MediaQuery(
            data: const MediaQueryData(textScaler: TextScaler.linear(1.4)),
            child: const TerrenoDetailScreen(terrenoId: 1),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('CULTIVOS EN ESTE TERRENO'), findsOneWidget);
    expect(find.text('AGREGAR CULTIVO'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
