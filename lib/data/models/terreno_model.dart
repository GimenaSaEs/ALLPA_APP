class TerrenoModel {
  final int? id;
  final int agricultorId;
  final String nombre;
  final double areaHa;
  final String? ubicacion;
  final String createdAt;

  // Campos adicionales para presentación (joins)
  final int cultivosCount;
  final double areaSembradaTotal;

  TerrenoModel({
    this.id,
    required this.agricultorId,
    required this.nombre,
    required this.areaHa,
    this.ubicacion,
    required this.createdAt,
    this.cultivosCount = 0,
    this.areaSembradaTotal = 0.0,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'agricultor_id': agricultorId,
      'nombre': nombre,
      'area_ha': areaHa,
      'ubicacion': ubicacion,
      'created_at': createdAt,
    };
  }

  factory TerrenoModel.fromMap(Map<String, dynamic> map) {
    return TerrenoModel(
      id: map['id'] as int?,
      agricultorId: map['agricultor_id'] as int? ?? 1,
      nombre: map['nombre'] as String? ?? '',
      areaHa: (map['area_ha'] as num?)?.toDouble() ?? 0.0,
      ubicacion: map['ubicacion'] as String?,
      createdAt:
          map['created_at'] as String? ?? DateTime.now().toIso8601String(),
      cultivosCount: map['cultivos_count'] as int? ?? 0,
      areaSembradaTotal:
          (map['area_sembrada_total'] as num?)?.toDouble() ?? 0.0,
    );
  }

  TerrenoModel copyWith({
    int? id,
    int? agricultorId,
    String? nombre,
    double? areaHa,
    String? ubicacion,
    String? createdAt,
    int? cultivosCount,
    double? areaSembradaTotal,
  }) {
    return TerrenoModel(
      id: id ?? this.id,
      agricultorId: agricultorId ?? this.agricultorId,
      nombre: nombre ?? this.nombre,
      areaHa: areaHa ?? this.areaHa,
      ubicacion: ubicacion ?? this.ubicacion,
      createdAt: createdAt ?? this.createdAt,
      cultivosCount: cultivosCount ?? this.cultivosCount,
      areaSembradaTotal: areaSembradaTotal ?? this.areaSembradaTotal,
    );
  }
}
