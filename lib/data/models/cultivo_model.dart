class CultivoModel {
  final int? id;
  final int terrenoId;
  final String especie;
  final String? variedad;
  final double areaSembradaHa;
  final String fechaInicio;
  final String estado; // 'Planificado', 'En curso', 'Cosechado', 'Finalizado'
  final String createdAt;

  // Campos calculados / joins
  final String? terrenoNombre;
  final double? terrenoAreaHa;
  final int? planSiembraId;
  final String? fechaPrevista;
  final String? fechaReal;
  final int? desfaseDias;
  final bool tieneCosecha;

  CultivoModel({
    this.id,
    required this.terrenoId,
    required this.especie,
    this.variedad,
    required this.areaSembradaHa,
    required this.fechaInicio,
    this.estado = 'En curso',
    required this.createdAt,
    this.terrenoNombre,
    this.terrenoAreaHa,
    this.planSiembraId,
    this.fechaPrevista,
    this.fechaReal,
    this.desfaseDias,
    this.tieneCosecha = false,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'terreno_id': terrenoId,
      'especie': especie,
      'variedad': variedad,
      'area_sembrada_ha': areaSembradaHa,
      'fecha_inicio': fechaInicio,
      'estado': estado,
      'created_at': createdAt,
    };
  }

  factory CultivoModel.fromMap(Map<String, dynamic> map) {
    return CultivoModel(
      id: map['id'] as int?,
      terrenoId: map['terreno_id'] as int? ?? 0,
      especie: map['especie'] as String? ?? '',
      variedad: map['variedad'] as String?,
      areaSembradaHa: (map['area_sembrada_ha'] as num?)?.toDouble() ?? 0.0,
      fechaInicio: map['fecha_inicio'] as String? ?? '',
      estado: map['estado'] as String? ?? 'En curso',
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
      terrenoNombre: map['terreno_nombre'] as String?,
      terrenoAreaHa: (map['terreno_area_ha'] as num?)?.toDouble(),
      planSiembraId: map['plan_siembra_id'] as int?,
      fechaPrevista: map['fecha_prevista'] as String?,
      fechaReal: map['fecha_real'] as String?,
      desfaseDias: map['desfase_dias'] as int?,
      tieneCosecha: (map['tiene_cosecha'] as int? ?? 0) > 0,
    );
  }

  CultivoModel copyWith({
    int? id,
    int? terrenoId,
    String? especie,
    String? variedad,
    double? areaSembradaHa,
    String? fechaInicio,
    String? estado,
    String? createdAt,
    String? terrenoNombre,
    double? terrenoAreaHa,
    int? planSiembraId,
    String? fechaPrevista,
    String? fechaReal,
    int? desfaseDias,
    bool? tieneCosecha,
  }) {
    return CultivoModel(
      id: id ?? this.id,
      terrenoId: terrenoId ?? this.terrenoId,
      especie: especie ?? this.especie,
      variedad: variedad ?? this.variedad,
      areaSembradaHa: areaSembradaHa ?? this.areaSembradaHa,
      fechaInicio: fechaInicio ?? this.fechaInicio,
      estado: estado ?? this.estado,
      createdAt: createdAt ?? this.createdAt,
      terrenoNombre: terrenoNombre ?? this.terrenoNombre,
      terrenoAreaHa: terrenoAreaHa ?? this.terrenoAreaHa,
      planSiembraId: planSiembraId ?? this.planSiembraId,
      fechaPrevista: fechaPrevista ?? this.fechaPrevista,
      fechaReal: fechaReal ?? this.fechaReal,
      desfaseDias: desfaseDias ?? this.desfaseDias,
      tieneCosecha: tieneCosecha ?? this.tieneCosecha,
    );
  }
}
