import 'package:csv/csv.dart';

class CsvExporter {
  /// Genera cadena CSV para los registros agronómicos completos
  static String exportAgronomicLogToCsv(List<Map<String, dynamic>> records) {
    if (records.isEmpty) {
      return '\uFEFFTipo,Cultivo,Terreno,Fecha,Detalle,Cantidad_Jornales,Observaciones\n';
    }

    final List<List<dynamic>> rows = [
      ['Tipo_Registro', 'Cultivo', 'Especie', 'Variedad', 'Terreno', 'Fecha', 'Detalle_Labor_o_Insumo', 'Cantidad_o_Jornales', 'Unidad', 'Observaciones'],
    ];

    for (final r in records) {
      rows.add([
        r['tipo_registro'] ?? '',
        r['cultivo_nombre'] ?? '',
        r['especie'] ?? '',
        r['variedad'] ?? '',
        r['terreno_nombre'] ?? '',
        r['fecha'] ?? '',
        r['detalle'] ?? '',
        r['cantidad_jornales'] ?? '',
        r['unidad'] ?? '',
        r['observacion'] ?? '',
      ]);
    }

    // Retorna con BOM UTF-8 para apertura directa en Microsoft Excel / SPSS
    return '\uFEFF' + const ListToCsvConverter().convert(rows);
  }

  /// Genera cadena CSV para los indicadores de investigación de la tesis
  static String exportIndicatorsToCsv(List<Map<String, dynamic>> indicatorRows) {
    final List<List<dynamic>> rows = [
      [
        'ID_Cultivo',
        'Agricultor',
        'Terreno',
        'Especie',
        'Variedad',
        'Fecha_Prevista',
        'Fecha_Real',
        'Desfase_Siembra_Dias',
        'Superficie_Terreno_ha',
        'Superficie_Sembrada_ha',
        'Pct_Superficie_Sembrada',
        'Total_Semilla_kg',
        'Semilla_kg_ha',
        'Total_Jornales_Familiares',
        'Superficie_Cosechada_ha',
        'Produccion_Total_kg',
        'Rendimiento_kg_ha',
        'Productividad_kg_jornal',
        'Pct_Registros_Completos',
      ],
    ];

    for (final row in indicatorRows) {
      rows.add([
        row['id_cultivo'] ?? '',
        row['agricultor'] ?? '',
        row['terreno'] ?? '',
        row['especie'] ?? '',
        row['variedad'] ?? '',
        row['fecha_prevista'] ?? '',
        row['fecha_real'] ?? '',
        row['desfase_dias'] ?? '',
        row['area_terreno_ha'] ?? '',
        row['area_sembrada_ha'] ?? '',
        row['pct_area_sembrada'] ?? '',
        row['total_semilla_kg'] ?? '',
        row['semilla_kg_ha'] ?? '',
        row['total_jornales'] ?? '',
        row['area_cosechada_ha'] ?? '',
        row['produccion_kg'] ?? '',
        row['rendimiento_kg_ha'] ?? '',
        row['productividad_kg_jornal'] ?? '',
        row['pct_completitud'] ?? '',
      ]);
    }

    return '\uFEFF' + const ListToCsvConverter().convert(rows);
  }
}
