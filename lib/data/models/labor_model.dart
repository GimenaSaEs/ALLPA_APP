class LaborModel {
  final int? id;
  final int cultivoId;
  final String tipo;
  final String fecha;
  final double jornales;
  final String? nota;
  final String createdAt;

  // Campos joins
  final String? cultivoEspecie;
  final String? cultivoVariedad;
  final String? terrenoNombre;

  LaborModel({
    this.id,
    required this.cultivoId,
    required this.tipo,
    required this.fecha,
    this.jornales = 0.0,
    this.nota,
    required this.createdAt,
    this.cultivoEspecie,
    this.cultivoVariedad,
    this.terrenoNombre,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'cultivo_id': cultivoId,
      'tipo': tipo,
      'fecha': fecha,
      'jornales': jornales,
      'nota': nota,
      'created_at': createdAt,
    };
  }

  factory LaborModel.fromMap(Map<String, dynamic> map) {
    return LaborModel(
      id: map['id'] as int?,
      cultivoId: map['cultivo_id'] as int? ?? 0,
      tipo: map['tipo'] as String? ?? '',
      fecha: map['fecha'] as String? ?? '',
      jornales: (map['jornales'] as num?)?.toDouble() ?? 0.0,
      nota: map['nota'] as String?,
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
      cultivoEspecie: map['cultivo_especie'] as String?,
      cultivoVariedad: map['cultivo_variedad'] as String?,
      terrenoNombre: map['terreno_nombre'] as String?,
    );
  }

  LaborModel copyWith({
    int? id,
    int? cultivoId,
    String? tipo,
    String? fecha,
    double? jornales,
    String? nota,
    String? createdAt,
    String? cultivoEspecie,
    String? cultivoVariedad,
    String? terrenoNombre,
  }) {
    return LaborModel(
      id: id ?? this.id,
      cultivoId: cultivoId ?? this.cultivoId,
      tipo: tipo ?? this.tipo,
      fecha: fecha ?? this.fecha,
      jornales: jornales ?? this.jornales,
      nota: nota ?? this.nota,
      createdAt: createdAt ?? this.createdAt,
      cultivoEspecie: cultivoEspecie ?? this.cultivoEspecie,
      cultivoVariedad: cultivoVariedad ?? this.cultivoVariedad,
      terrenoNombre: terrenoNombre ?? this.terrenoNombre,
    );
  }
}
