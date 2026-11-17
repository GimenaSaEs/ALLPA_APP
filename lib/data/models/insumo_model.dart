class InsumoModel {
  final int? id;
  final int cultivoId;
  final String tipo;
  final String nombre;
  final double cantidad;
  final String unidad;
  final String fecha;
  final String createdAt;

  // Campos joins
  final String? cultivoEspecie;
  final String? cultivoVariedad;
  final String? terrenoNombre;

  InsumoModel({
    this.id,
    required this.cultivoId,
    required this.tipo,
    required this.nombre,
    required this.cantidad,
    required this.unidad,
    required this.fecha,
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
      'nombre': nombre,
      'cantidad': cantidad,
      'unidad': unidad,
      'fecha': fecha,
      'created_at': createdAt,
    };
  }

  factory InsumoModel.fromMap(Map<String, dynamic> map) {
    return InsumoModel(
      id: map['id'] as int?,
      cultivoId: map['cultivo_id'] as int? ?? 0,
      tipo: map['tipo'] as String? ?? '',
      nombre: map['nombre'] as String? ?? '',
      cantidad: (map['cantidad'] as num?)?.toDouble() ?? 0.0,
      unidad: map['unidad'] as String? ?? '',
      fecha: map['fecha'] as String? ?? '',
      createdAt:
          map['created_at'] as String? ?? DateTime.now().toIso8601String(),
      cultivoEspecie: map['cultivo_especie'] as String?,
      cultivoVariedad: map['cultivo_variedad'] as String?,
      terrenoNombre: map['terreno_nombre'] as String?,
    );
  }

  InsumoModel copyWith({
    int? id,
    int? cultivoId,
    String? tipo,
    String? nombre,
    double? cantidad,
    String? unidad,
    String? fecha,
    String? createdAt,
    String? cultivoEspecie,
    String? cultivoVariedad,
    String? terrenoNombre,
  }) {
    return InsumoModel(
      id: id ?? this.id,
      cultivoId: cultivoId ?? this.cultivoId,
      tipo: tipo ?? this.tipo,
      nombre: nombre ?? this.nombre,
      cantidad: cantidad ?? this.cantidad,
      unidad: unidad ?? this.unidad,
      fecha: fecha ?? this.fecha,
      createdAt: createdAt ?? this.createdAt,
      cultivoEspecie: cultivoEspecie ?? this.cultivoEspecie,
      cultivoVariedad: cultivoVariedad ?? this.cultivoVariedad,
      terrenoNombre: terrenoNombre ?? this.terrenoNombre,
    );
  }
}
