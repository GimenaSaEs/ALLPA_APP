class CosechaModel {
  final int? id;
  final int cultivoId;
  final String fecha;
  final double areaHa;
  final double produccionKg;
  final double jornales;
  final double? rendimientoKgHa; // produccionKg / areaHa
  final double? productividadKgJornal; // produccionKg / jornales
  final String? observacion;
  final String createdAt;

  // Campos joins
  final String? cultivoEspecie;
  final String? cultivoVariedad;
  final String? terrenoNombre;

  CosechaModel({
    this.id,
    required this.cultivoId,
    required this.fecha,
    required this.areaHa,
    required this.produccionKg,
    this.jornales = 0.0,
    this.rendimientoKgHa,
    this.productividadKgJornal,
    this.observacion,
    required this.createdAt,
    this.cultivoEspecie,
    this.cultivoVariedad,
    this.terrenoNombre,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'cultivo_id': cultivoId,
      'fecha': fecha,
      'area_ha': areaHa,
      'produccion_kg': produccionKg,
      'jornales': jornales,
      'rendimiento_kg_ha': rendimientoKgHa,
      'productividad_kg_jornal': productividadKgJornal,
      'observacion': observacion,
      'created_at': createdAt,
    };
  }

  factory CosechaModel.fromMap(Map<String, dynamic> map) {
    return CosechaModel(
      id: map['id'] as int?,
      cultivoId: map['cultivo_id'] as int? ?? 0,
      fecha: map['fecha'] as String? ?? '',
      areaHa: (map['area_ha'] as num?)?.toDouble() ?? 0.0,
      produccionKg: (map['produccion_kg'] as num?)?.toDouble() ?? 0.0,
      jornales: (map['jornales'] as num?)?.toDouble() ?? 0.0,
      rendimientoKgHa: (map['rendimiento_kg_ha'] as num?)?.toDouble(),
      productividadKgJornal: (map['productividad_kg_jornal'] as num?)?.toDouble(),
      observacion: map['observacion'] as String?,
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
      cultivoEspecie: map['cultivo_especie'] as String?,
      cultivoVariedad: map['cultivo_variedad'] as String?,
      terrenoNombre: map['terreno_nombre'] as String?,
    );
  }

  CosechaModel copyWith({
    int? id,
    int? cultivoId,
    String? fecha,
    double? areaHa,
    double? produccionKg,
    double? jornales,
    double? rendimientoKgHa,
    double? productividadKgJornal,
    String? observacion,
    String? createdAt,
    String? cultivoEspecie,
    String? cultivoVariedad,
    String? terrenoNombre,
  }) {
    return CosechaModel(
      id: id ?? this.id,
      cultivoId: cultivoId ?? this.cultivoId,
      fecha: fecha ?? this.fecha,
      areaHa: areaHa ?? this.areaHa,
      produccionKg: produccionKg ?? this.produccionKg,
      jornales: jornales ?? this.jornales,
      rendimientoKgHa: rendimientoKgHa ?? this.rendimientoKgHa,
      productividadKgJornal: productividadKgJornal ?? this.productividadKgJornal,
      observacion: observacion ?? this.observacion,
      createdAt: createdAt ?? this.createdAt,
      cultivoEspecie: cultivoEspecie ?? this.cultivoEspecie,
      cultivoVariedad: cultivoVariedad ?? this.cultivoVariedad,
      terrenoNombre: terrenoNombre ?? this.terrenoNombre,
    );
  }
}
