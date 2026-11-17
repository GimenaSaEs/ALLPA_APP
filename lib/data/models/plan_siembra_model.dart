class PlanSiembraModel {
  final int? id;
  final int cultivoId;
  final String? fechaPrevista;
  final String? fechaReal;
  final int escrito; // 1 = sí, 0 = no
  final int? desfaseDias; // positivo = retraso, 0 = a tiempo, negativo = adelantado
  final String estado; // 'Pendiente', 'Cumplido a tiempo', 'Cumplido con desfase'
  final String? observacion;
  final String createdAt;

  PlanSiembraModel({
    this.id,
    required this.cultivoId,
    this.fechaPrevista,
    this.fechaReal,
    this.escrito = 1,
    this.desfaseDias,
    this.estado = 'Pendiente',
    this.observacion,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'cultivo_id': cultivoId,
      'fecha_prevista': fechaPrevista,
      'fecha_real': fechaReal,
      'escrito': escrito,
      'desfase_dias': desfaseDias,
      'estado': estado,
      'observacion': observacion,
      'created_at': createdAt,
    };
  }

  factory PlanSiembraModel.fromMap(Map<String, dynamic> map) {
    return PlanSiembraModel(
      id: map['id'] as int?,
      cultivoId: map['cultivo_id'] as int? ?? 0,
      fechaPrevista: map['fecha_prevista'] as String?,
      fechaReal: map['fecha_real'] as String?,
      escrito: map['escrito'] as int? ?? 1,
      desfaseDias: map['desfase_dias'] as int?,
      estado: map['estado'] as String? ?? 'Pendiente',
      observacion: map['observacion'] as String?,
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  PlanSiembraModel copyWith({
    int? id,
    int? cultivoId,
    String? fechaPrevista,
    String? fechaReal,
    int? escrito,
    int? desfaseDias,
    String? estado,
    String? observacion,
    String? createdAt,
  }) {
    return PlanSiembraModel(
      id: id ?? this.id,
      cultivoId: cultivoId ?? this.cultivoId,
      fechaPrevista: fechaPrevista ?? this.fechaPrevista,
      fechaReal: fechaReal ?? this.fechaReal,
      escrito: escrito ?? this.escrito,
      desfaseDias: desfaseDias ?? this.desfaseDias,
      estado: estado ?? this.estado,
      observacion: observacion ?? this.observacion,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
