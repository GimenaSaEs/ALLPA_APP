import '../../core/database/database_helper.dart';

class BitacoraItem {
  final String tipoRegistro; // 'Siembra', 'Labor', 'Insumo', 'Cosecha'
  final int id;
  final int cultivoId;
  final String cultivoEspecie;
  final String? cultivoVariedad;
  final int terrenoId;
  final String terrenoNombre;
  final String fecha;
  final String titulo;
  final String detalle;
  final String? observacion;
  final double? cantidadJornales;
  final String? unidad;

  BitacoraItem({
    required this.tipoRegistro,
    required this.id,
    required this.cultivoId,
    required this.cultivoEspecie,
    this.cultivoVariedad,
    required this.terrenoId,
    required this.terrenoNombre,
    required this.fecha,
    required this.titulo,
    required this.detalle,
    this.observacion,
    this.cantidadJornales,
    this.unidad,
  });

  Map<String, dynamic> toMap() {
    return {
      'tipo_registro': tipoRegistro,
      'cultivo_nombre': '$cultivoEspecie ${cultivoVariedad ?? ""}'.trim(),
      'especie': cultivoEspecie,
      'variedad': cultivoVariedad ?? '',
      'terreno_nombre': terrenoNombre,
      'fecha': fecha,
      'detalle': detalle,
      'cantidad_jornales': cantidadJornales ?? '',
      'unidad': unidad ?? '',
      'observacion': observacion ?? '',
    };
  }
}

class BitacoraRepository {
  final DatabaseHelper _dbHelper;

  BitacoraRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<List<BitacoraItem>> getBitacora({
    int? terrenoId,
    int? cultivoId,
    String? tipoFiltro,
  }) async {
    final db = await _dbHelper.database;
    final List<BitacoraItem> items = [];

    // 1. Labores
    if (tipoFiltro == null || tipoFiltro == 'Todos' || tipoFiltro == 'Labor') {
      String query = '''
        SELECT l.id, l.cultivo_id, l.tipo, l.fecha, l.jornales, l.nota,
               c.especie as cultivo_especie, c.variedad as cultivo_variedad,
               t.id as terreno_id, t.nombre as terreno_nombre
        FROM labor l
        JOIN cultivo c ON l.cultivo_id = c.id
        JOIN terreno t ON c.terreno_id = t.id
        WHERE 1=1
      ''';
      List<dynamic> args = [];
      if (terrenoId != null) {
        query += ' AND t.id = ?';
        args.add(terrenoId);
      }
      if (cultivoId != null) {
        query += ' AND c.id = ?';
        args.add(cultivoId);
      }

      final res = await db.rawQuery(query, args);
      for (final row in res) {
        items.add(
          BitacoraItem(
            tipoRegistro: 'Labor',
            id: row['id'] as int,
            cultivoId: row['cultivo_id'] as int,
            cultivoEspecie: row['cultivo_especie'] as String,
            cultivoVariedad: row['cultivo_variedad'] as String?,
            terrenoId: row['terreno_id'] as int,
            terrenoNombre: row['terreno_nombre'] as String,
            fecha: row['fecha'] as String,
            titulo: 'Labor: ${row['tipo']}',
            detalle:
                '${(row['jornales'] as num).toDouble()} jornales familiares dedicados',
            observacion: row['nota'] as String?,
            cantidadJornales: (row['jornales'] as num).toDouble(),
            unidad: 'jornales',
          ),
        );
      }
    }

    // 2. Insumos
    if (tipoFiltro == null || tipoFiltro == 'Todos' || tipoFiltro == 'Insumo') {
      String query = '''
        SELECT i.id, i.cultivo_id, i.tipo, i.nombre, i.cantidad, i.unidad, i.fecha,
               c.especie as cultivo_especie, c.variedad as cultivo_variedad,
               t.id as terreno_id, t.nombre as terreno_nombre
        FROM insumo i
        JOIN cultivo c ON i.cultivo_id = c.id
        JOIN terreno t ON c.terreno_id = t.id
        WHERE 1=1
      ''';
      List<dynamic> args = [];
      if (terrenoId != null) {
        query += ' AND t.id = ?';
        args.add(terrenoId);
      }
      if (cultivoId != null) {
        query += ' AND c.id = ?';
        args.add(cultivoId);
      }

      final res = await db.rawQuery(query, args);
      for (final row in res) {
        items.add(
          BitacoraItem(
            tipoRegistro: 'Insumo',
            id: row['id'] as int,
            cultivoId: row['cultivo_id'] as int,
            cultivoEspecie: row['cultivo_especie'] as String,
            cultivoVariedad: row['cultivo_variedad'] as String?,
            terrenoId: row['terreno_id'] as int,
            terrenoNombre: row['terreno_nombre'] as String,
            fecha: row['fecha'] as String,
            titulo: '${row['tipo']}: ${row['nombre']}',
            detalle:
                'Aplicado: ${(row['cantidad'] as num).toDouble()} ${row['unidad']}',
            cantidadJornales: (row['cantidad'] as num).toDouble(),
            unidad: row['unidad'] as String?,
          ),
        );
      }
    }

    // 3. Siembras (Plan y Fecha Real)
    if (tipoFiltro == null ||
        tipoFiltro == 'Todos' ||
        tipoFiltro == 'Siembra') {
      String query = '''
        SELECT ps.id, ps.cultivo_id, ps.fecha_prevista, ps.fecha_real, ps.desfase_dias, ps.estado, ps.observacion,
               c.especie as cultivo_especie, c.variedad as cultivo_variedad, c.area_sembrada_ha,
               t.id as terreno_id, t.nombre as terreno_nombre
        FROM plan_siembra ps
        JOIN cultivo c ON ps.cultivo_id = c.id
        JOIN terreno t ON c.terreno_id = t.id
        WHERE ps.fecha_real IS NOT NULL
      ''';
      List<dynamic> args = [];
      if (terrenoId != null) {
        query += ' AND t.id = ?';
        args.add(terrenoId);
      }
      if (cultivoId != null) {
        query += ' AND c.id = ?';
        args.add(cultivoId);
      }

      final res = await db.rawQuery(query, args);
      for (final row in res) {
        final desfase = row['desfase_dias'] as int?;
        String desfaseTxt = 'Sin fecha prevista';
        if (desfase != null) {
          desfaseTxt = desfase == 0
              ? 'Siembra puntual (0 días)'
              : (desfase > 0
                    ? 'Desfase de +$desfase días'
                    : 'Adelanto de $desfase días');
        }
        items.add(
          BitacoraItem(
            tipoRegistro: 'Siembra',
            id: row['id'] as int,
            cultivoId: row['cultivo_id'] as int,
            cultivoEspecie: row['cultivo_especie'] as String,
            cultivoVariedad: row['cultivo_variedad'] as String?,
            terrenoId: row['terreno_id'] as int,
            terrenoNombre: row['terreno_nombre'] as String,
            fecha: row['fecha_real'] as String,
            titulo: 'Siembra de ${row['cultivo_especie']}',
            detalle: 'Superficie: ${row['area_sembrada_ha']} ha • $desfaseTxt',
            observacion: row['observacion'] as String?,
            cantidadJornales: (row['area_sembrada_ha'] as num).toDouble(),
            unidad: 'ha',
          ),
        );
      }
    }

    // 4. Cosechas
    if (tipoFiltro == null ||
        tipoFiltro == 'Todos' ||
        tipoFiltro == 'Cosecha') {
      String query = '''
        SELECT cos.id, cos.cultivo_id, cos.fecha, cos.area_ha, cos.produccion_kg,
               cos.rendimiento_kg_ha, cos.jornales, cos.observacion,
               c.especie as cultivo_especie, c.variedad as cultivo_variedad,
               t.id as terreno_id, t.nombre as terreno_nombre
        FROM cosecha cos
        JOIN cultivo c ON cos.cultivo_id = c.id
        JOIN terreno t ON c.terreno_id = t.id
        WHERE 1=1
      ''';
      List<dynamic> args = [];
      if (terrenoId != null) {
        query += ' AND t.id = ?';
        args.add(terrenoId);
      }
      if (cultivoId != null) {
        query += ' AND c.id = ?';
        args.add(cultivoId);
      }

      final res = await db.rawQuery(query, args);
      for (final row in res) {
        final rend = (row['rendimiento_kg_ha'] as num?)?.toDouble() ?? 0.0;
        items.add(
          BitacoraItem(
            tipoRegistro: 'Cosecha',
            id: row['id'] as int,
            cultivoId: row['cultivo_id'] as int,
            cultivoEspecie: row['cultivo_especie'] as String,
            cultivoVariedad: row['cultivo_variedad'] as String?,
            terrenoId: row['terreno_id'] as int,
            terrenoNombre: row['terreno_nombre'] as String,
            fecha: row['fecha'] as String,
            titulo: 'Cosecha de ${row['cultivo_especie']}',
            detalle:
                'Producción: ${row['produccion_kg']} kg en ${row['area_ha']} ha • Rendimiento: $rend kg/ha',
            observacion: row['observacion'] as String?,
            cantidadJornales: (row['produccion_kg'] as num).toDouble(),
            unidad: 'kg',
          ),
        );
      }
    }

    // Ordenar cronológicamente descendente (más reciente primero)
    items.sort((a, b) => b.fecha.compareTo(a.fecha));
    return items;
  }
}
