class InputTypes {
  static const List<String> types = [
    'Semilla',
    'Fertilizante',
    'Abono orgánico',
    'Fitosanitario / Plaguicida',
    'Otro insumo',
  ];

  static const List<String> units = [
    'Kilogramos (kg)',
    'Sacos / Costales (50 kg)',
    'Arrobas (11.5 kg)',
    'Litros (L)',
    'Gramos (g)',
    'Mililitros (mL)',
    'Unidades',
  ];

  /// Convierte a kilogramos equivalentes si la unidad es compatible, útil para cálculo de semilla
  static double toKg(double cantidad, String unidad) {
    if (unidad.contains('kg') || unidad.contains('Kilogramo')) {
      return cantidad;
    } else if (unidad.contains('Saco') || unidad.contains('Costal')) {
      return cantidad * 50.0;
    } else if (unidad.contains('Arroba')) {
      return cantidad * 11.5;
    } else if (unidad.contains('Gramos') || unidad.contains('g')) {
      return cantidad / 1000.0;
    }
    return cantidad; // Valor por defecto
  }
}
