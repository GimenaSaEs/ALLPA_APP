import 'package:sqflite/sqflite.dart';
import '../../core/constants/input_types.dart';
import '../../core/database/database_helper.dart';
import '../../core/utils/calculations.dart';
import '../models/indicadores_model.dart';

class ResumenGeneralIndicadores {
  final int totalTerrenos;
  final double totalSuperficieTerrenosHa;
  final int totalCultivos;
  final double totalSuperficieSembradaHa;
  final double porcentajeSuperficieSembradaGlobal;
  final double totalSemillaKgGlobal;
  final double promedioSemillaKgHa;
  final double totalJornalesFamiliaresGlobal;
  final double totalProduccionKgGlobal;
  final double totalSuperficieCosechadaHa;
  final double promedioRendimientoKgHa;
  final double promedioProductividadKgJornal;
  final double promedioDesfaseSiembraDias;
  final double porcentajeRegistrosCompletosPromedio;
  final bool siembraIndividual;

  ResumenGeneralIndicadores({
    required this.totalTerrenos,
    required this.totalSuperficieTerrenosHa,
    required this.totalCultivos,
    required this.totalSuperficieSembradaHa,
    required this.porcentajeSuperficieSembradaGlobal,
    required this.totalSemillaKgGlobal,
    required this.promedioSemillaKgHa,
    required this.totalJornalesFamiliaresGlobal,
    required this.totalProduccionKgGlobal,
    required this.totalSuperficieCosechadaHa,
    required this.promedioRendimientoKgHa,
    required this.promedioProductividadKgJornal,
    required this.promedioDesfaseSiembraDias,
    required this.porcentajeRegistrosCompletosPromedio,
    required this.siembraIndividual,
  });
}

class IndicadoresRepository {
  final DatabaseHelper _dbHelper;

  IndicadoresRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<IndicadoresModel>> getIndicadoresPorCultivo() async {
    final db = await _dbHelper.database;
    final List<IndicadoresModel> lista = [];

    // Consulta con todos los joins necesarios
    final List<Map<String, dynamic>> rows = await db.rawQuery('''
      SELECT 
        c.id as cultivo_id,
        c.especie,
        c.variedad,
        c.area_sembrada_ha,
        t.nombre as terreno_nombre,
        t.area_ha as terreno_area_ha,
        a.nombre as agricultor_nombre,
        a.siembra_individual,
        ps.fecha_prevista,
        ps.fecha_real,
        ps.desfase_dias,
        ps.escrito,
        cos.id as cosecha_id,
        cos.fecha as cosecha_fecha,
        cos.area_ha as cosecha_area_ha,
        cos.produccion_kg,
        cos.rendimiento_kg_ha,
        cos.productividad_kg_jornal,
        cos.jornales as cosecha_jornales
      FROM cultivo c
      JOIN terreno t ON c.terreno_id = t.id
      JOIN agricultor a ON t.agricultor_id = a.id
      LEFT JOIN plan_siembra ps ON c.id = ps.cultivo_id
      LEFT JOIN cosecha cos ON c.id = cos.cultivo_id
      ORDER BY c.id DESC
    ''');

    for (final r in rows) {
      final cultivoId = r['cultivo_id'] as int;
      final areaTerreno = (r['terreno_area_ha'] as num).toDouble();
      final areaSembrada = (r['area_sembrada_ha'] as num).toDouble();

      // Sumar semillas en kg para este cultivo
      final insumosRows = await db.rawQuery(
        '''
        SELECT cantidad, unidad FROM insumo 
        WHERE cultivo_id = ? AND LOWER(tipo) LIKE '%semilla%'
      ''',
        [cultivoId],
      );

      double totalSemillaKg = 0.0;
      for (final ins in insumosRows) {
        final cant = (ins['cantidad'] as num).toDouble();
        final unid = ins['unidad'] as String;
        totalSemillaKg += InputTypes.toKg(cant, unid);
      }

      // Sumar jornales familiares (labores + cosecha)
      final laboresRows = await db.rawQuery(
        '''
        SELECT SUM(jornales) as total FROM labor WHERE cultivo_id = ?
      ''',
        [cultivoId],
      );
      final double jornalesLabores =
          (laboresRows.first['total'] as num?)?.toDouble() ?? 0.0;
      final double jornalesCosecha =
          (r['cosecha_jornales'] as num?)?.toDouble() ?? 0.0;
      final double totalJornales = jornalesLabores + jornalesCosecha;

      // Calcular % superficie sembrada
      final pctAreaSembrada =
          AgriculturalCalculations.calculateSownAreaPercentage(
            areaSembradaHa: areaSembrada,
            areaDisponibleHa: areaTerreno,
          ) ??
          0.0;

      // Calcular semilla kg/ha
      final semillaKgHa =
          AgriculturalCalculations.calculateSeedPerHa(
            kgSemilla: totalSemillaKg,
            areaHa: areaSembrada,
          ) ??
          0.0;

      // Cosecha
      final bool tieneCosecha = r['cosecha_id'] != null;
      final double areaCosechada =
          (r['cosecha_area_ha'] as num?)?.toDouble() ?? 0.0;
      final double produccionKg =
          (r['produccion_kg'] as num?)?.toDouble() ?? 0.0;
      final double? rendimiento = (r['rendimiento_kg_ha'] as num?)?.toDouble();
      final double? productividad = (r['productividad_kg_jornal'] as num?)
          ?.toDouble();

      // Completitud de registros agronómicos (%):
      // Campos evaluados: especie(1), variedad(1), area_sembrada(1), plan_siembra(1), fecha_prevista(1), fecha_real(1),
      // al menos 1 labor registrada(1), al menos 1 insumo registrado(1), cosecha registrada(1).
      int completed =
          3; // especie, variedad, area siempre presentes si se guardó cultivo
      int totalExpected = 9;

      if (r['fecha_prevista'] != null &&
          (r['fecha_prevista'] as String).isNotEmpty) {
        completed++;
      }
      if (r['fecha_real'] != null && (r['fecha_real'] as String).isNotEmpty) {
        completed++;
      }

      final int cantLabores =
          Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM labor WHERE cultivo_id = ?',
              [cultivoId],
            ),
          ) ??
          0;
      if (cantLabores > 0) completed++;

      final int cantInsumos =
          Sqflite.firstIntValue(
            await db.rawQuery(
              'SELECT COUNT(*) FROM insumo WHERE cultivo_id = ?',
              [cultivoId],
            ),
          ) ??
          0;
      if (cantInsumos > 0) completed++;

      if (tieneCosecha) completed += 2; // cosecha registrada con datos

      final pctCompletitud =
          AgriculturalCalculations.calculateCompletenessPercentage(
            completedFields: completed,
            totalFields: totalExpected,
          );

      lista.add(
        IndicadoresModel(
          cultivoId: cultivoId,
          agricultorNombre: r['agricultor_nombre'] as String,
          terrenoNombre: r['terreno_nombre'] as String,
          especie: r['especie'] as String,
          variedad: r['variedad'] as String? ?? 'Común',
          areaTerrenoHa: areaTerreno,
          areaSembradaHa: areaSembrada,
          fechaPrevista: r['fecha_prevista'] as String?,
          fechaReal: r['fecha_real'] as String?,
          desfaseSiembraDias: r['desfase_dias'] as int?,
          pctRegistrosCompletos: pctCompletitud,
          pctSuperficieSembrada: pctAreaSembrada,
          totalSemillaKg: totalSemillaKg,
          semillaKgHa: semillaKgHa,
          jornalesFamiliaresTotal: totalJornales,
          siembraIndividual: (r['siembra_individual'] as int? ?? 1) == 1,
          tieneCosecha: tieneCosecha,
          fechaCosecha: r['cosecha_fecha'] as String?,
          areaCosechadaHa: areaCosechada,
          produccionTotalKg: produccionKg,
          rendimientoKgHa: rendimiento,
          productividadKgJornal: productividad,
        ),
      );
    }

    return lista;
  }

  Future<ResumenGeneralIndicadores> getResumenGeneral() async {
    final db = await _dbHelper.database;
    final indicadoresList = await getIndicadoresPorCultivo();

    // Terrenos
    final terrenosCount =
        Sqflite.firstIntValue(
          await db.rawQuery('SELECT COUNT(*) FROM terreno'),
        ) ??
        0;
    final areaTerrenosRaw = await db.rawQuery(
      'SELECT SUM(area_ha) as total FROM terreno',
    );
    final double areaTerrenosTotal =
        (areaTerrenosRaw.first['total'] as num?)?.toDouble() ?? 0.0;

    // Cultivos
    final int totalCultivos = indicadoresList.length;
    double totalSuperficieSembrada = 0.0;
    double totalSemillaKg = 0.0;
    double totalJornales = 0.0;
    double totalProduccionKg = 0.0;
    double totalSuperficieCosechada = 0.0;
    double sumaRendimiento = 0.0;
    int countRendimiento = 0;
    double sumaProductividad = 0.0;
    int countProductividad = 0;
    double sumaDesfase = 0.0;
    int countDesfase = 0;
    double sumaCompletitud = 0.0;

    for (final item in indicadoresList) {
      totalSuperficieSembrada += item.areaSembradaHa;
      totalSemillaKg += item.totalSemillaKg;
      totalJornales += item.jornalesFamiliaresTotal;
      sumaCompletitud += item.pctRegistrosCompletos;

      if (item.desfaseSiembraDias != null) {
        sumaDesfase += item.desfaseSiembraDias!;
        countDesfase++;
      }

      if (item.tieneCosecha) {
        totalProduccionKg += item.produccionTotalKg;
        totalSuperficieCosechada += item.areaCosechadaHa;
        if (item.rendimientoKgHa != null) {
          sumaRendimiento += item.rendimientoKgHa!;
          countRendimiento++;
        }
        if (item.productividadKgJornal != null) {
          sumaProductividad += item.productividadKgJornal!;
          countProductividad++;
        }
      }
    }

    final double pctSuperficieGlobal = areaTerrenosTotal > 0
        ? double.parse(
            ((totalSuperficieSembrada / areaTerrenosTotal) * 100)
                .toStringAsFixed(1),
          )
        : 0.0;

    final double promSemillaKgHa = totalSuperficieSembrada > 0
        ? double.parse(
            (totalSemillaKg / totalSuperficieSembrada).toStringAsFixed(1),
          )
        : 0.0;

    final double promRendimiento = countRendimiento > 0
        ? double.parse((sumaRendimiento / countRendimiento).toStringAsFixed(1))
        : 0.0;

    final double promProductividad = countProductividad > 0
        ? double.parse(
            (sumaProductividad / countProductividad).toStringAsFixed(1),
          )
        : 0.0;

    final double promDesfase = countDesfase > 0
        ? double.parse((sumaDesfase / countDesfase).toStringAsFixed(1))
        : 0.0;

    final double promCompletitud = totalCultivos > 0
        ? double.parse((sumaCompletitud / totalCultivos).toStringAsFixed(1))
        : 0.0;

    return ResumenGeneralIndicadores(
      totalTerrenos: terrenosCount,
      totalSuperficieTerrenosHa: areaTerrenosTotal,
      totalCultivos: totalCultivos,
      totalSuperficieSembradaHa: totalSuperficieSembrada,
      porcentajeSuperficieSembradaGlobal: pctSuperficieGlobal,
      totalSemillaKgGlobal: totalSemillaKg,
      promedioSemillaKgHa: promSemillaKgHa,
      totalJornalesFamiliaresGlobal: totalJornales,
      totalProduccionKgGlobal: totalProduccionKg,
      totalSuperficieCosechadaHa: totalSuperficieCosechada,
      promedioRendimientoKgHa: promRendimiento,
      promedioProductividadKgJornal: promProductividad,
      promedioDesfaseSiembraDias: promDesfase,
      porcentajeRegistrosCompletosPromedio: promCompletitud,
      siembraIndividual: true,
    );
  }
}
