import 'package:allpa/dominio/reglas.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('rechaza superficies no finitas antes de guardarlas', () {
    for (final valor in [
      double.nan,
      double.infinity,
      double.negativeInfinity,
    ]) {
      expect(
        () => validarSuperficieDisponible(valor),
        throwsA(isA<ErrorDeRegla>()),
      );
      expect(
        () => validarSuperficieUsada(valor, 2, 'siembra'),
        throwsA(isA<ErrorDeRegla>()),
      );
    }
  });

  test('semilla, jornales y tiempo rechazan NaN e infinito', () {
    for (final valor in [
      'NaN',
      'Infinity',
      '-Infinity',
      double.nan,
      double.infinity,
    ]) {
      expect(
        () => validarSiembra({
          'fecha_real': '2027-11-18',
          'individual': true,
          'kilogramos_semilla': valor,
          'hectareas_sembradas': 1,
          'jornales': 2,
        }, 2),
        throwsA(isA<ErrorDeRegla>()),
      );
      for (final campo in ['jornales', 'segundos_registro']) {
        expect(
          () => validarLabor({
            'nombre': 'Arado',
            'fecha': '2027-11-18',
            'jornales': 2,
            'segundos_registro': 30,
            campo: valor,
          }),
          throwsA(isA<ErrorDeRegla>()),
        );
      }
    }
  });

  test('admite decimales con coma en la validación de dominio', () {
    final siembra = validarSiembra({
      'fecha_real': '2027-11-18',
      'individual': true,
      'kilogramos_semilla': '90,5',
      'hectareas_sembradas': '1,2',
      'jornales': '2,5',
    }, 2);
    expect(siembra.kilogramosSemilla, 90.5);
    expect(siembra.hectareasSembradas, 1.2);
    expect(siembra.jornales, 2.5);
  });

  test('no interpreta respuestas inválidas como siembra con apoyo', () {
    for (final valor in [null, 'true', 'no', 1]) {
      expect(
        () => validarSiembra({
          'fecha_real': '2027-11-18',
          'individual': valor,
          'kilogramos_semilla': 90,
          'hectareas_sembradas': 1,
          'jornales': 2,
        }, 2),
        throwsA(isA<ErrorDeRegla>()),
      );
    }
  });
}
