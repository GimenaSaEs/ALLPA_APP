class AgricultorModel {
  final int? id;
  final String nombre;
  final String codigoLocal;
  final String? documento;
  final String? telefono;
  final String comunidad;
  final String distrito;
  final String provincia;
  final String departamento;
  final int siembraIndividual; // 1 = sí, 0 = no
  final String createdAt;

  AgricultorModel({
    this.id,
    required this.nombre,
    required this.codigoLocal,
    this.documento,
    this.telefono,
    this.comunidad = 'Illpe',
    this.distrito = 'Pachamarca',
    this.provincia = 'Churcampa',
    this.departamento = 'Huancavelica',
    this.siembraIndividual = 1,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'nombre': nombre,
      'codigo_local': codigoLocal,
      'documento': documento,
      'telefono': telefono,
      'comunidad': comunidad,
      'distrito': distrito,
      'provincia': provincia,
      'departamento': departamento,
      'siembra_individual': siembraIndividual,
      'created_at': createdAt,
    };
  }

  factory AgricultorModel.fromMap(Map<String, dynamic> map) {
    return AgricultorModel(
      id: map['id'] as int?,
      nombre: map['nombre'] as String? ?? '',
      codigoLocal: map['codigo_local'] as String? ?? '',
      documento: map['documento'] as String?,
      telefono: map['telefono'] as String?,
      comunidad: map['comunidad'] as String? ?? 'Illpe',
      distrito: map['distrito'] as String? ?? 'Pachamarca',
      provincia: map['provincia'] as String? ?? 'Churcampa',
      departamento: map['departamento'] as String? ?? 'Huancavelica',
      siembraIndividual: map['siembra_individual'] as int? ?? 1,
      createdAt: map['created_at'] as String? ?? DateTime.now().toIso8601String(),
    );
  }

  AgricultorModel copyWith({
    int? id,
    String? nombre,
    String? codigoLocal,
    String? documento,
    String? telefono,
    String? comunidad,
    String? distrito,
    String? provincia,
    String? departamento,
    int? siembraIndividual,
    String? createdAt,
  }) {
    return AgricultorModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      codigoLocal: codigoLocal ?? this.codigoLocal,
      documento: documento ?? this.documento,
      telefono: telefono ?? this.telefono,
      comunidad: comunidad ?? this.comunidad,
      distrito: distrito ?? this.distrito,
      provincia: provincia ?? this.provincia,
      departamento: departamento ?? this.departamento,
      siembraIndividual: siembraIndividual ?? this.siembraIndividual,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
