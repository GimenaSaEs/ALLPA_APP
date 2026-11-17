import 'package:allpa/servicios/compartir_respaldo.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const canal = MethodChannel('allpa/respaldo');
  final mensajero = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  tearDown(() => mensajero.setMockMethodCallHandler(canal, null));

  test('pide abrir el selector de Android para el archivo generado', () async {
    MethodCall? recibido;
    mensajero.setMockMethodCallHandler(canal, (llamada) async {
      recibido = llamada;
      return null;
    });
    await compartirRespaldo('/datos/respaldo_illpe.json');
    expect(recibido!.method, 'compartir');
    expect(recibido!.arguments, {'ruta': '/datos/respaldo_illpe.json'});
  });

  test('si Android no puede compartir comunica el fallo al llamador', () async {
    mensajero.setMockMethodCallHandler(canal, (_) async {
      throw PlatformException(code: 'RESPALDO_NO_COMPARTIDO');
    });
    await expectLater(compartirRespaldo('/datos/respaldo_illpe.json'),
        throwsA(isA<PlatformException>()));
  });
}
