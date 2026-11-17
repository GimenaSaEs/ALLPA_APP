class AgriculturalCalculations {
  /// Calcula el desfase de siembra en días.
  /// fechaReal - fechaPrevista.
  static int? calculateSowingDelay(DateTime? prevista, DateTime? real) {
    if (prevista == null || real == null) return null;
    return real.difference(prevista).inDays;
  }

  /// Calcula el rendimiento agrícola en kg/ha.
  /// Retorna null si la superficie es <= 0 o datos inválidos.
  static double? calculateYield({required double produccionKg, required double areaHa}) {
    if (areaHa <= 0 || produccionKg < 0) return null;
    final res = produccionKg / areaHa;
    return double.parse(res.toStringAsFixed(2));
  }

  /// Calcula la productividad por jornal familiar: kg producidos / jornales.
  static double? calculateProductivityPerJornal({required double produccionKg, required double jornales}) {
    if (jornales <= 0 || produccionKg < 0) return null;
    final res = produccionKg / jornales;
    return double.parse(res.toStringAsFixed(2));
  }

  /// Calcula el porcentaje de superficie sembrada respecto a la disponible: (sembrada / disponible) * 100
  static double? calculateSownAreaPercentage({required double areaSembradaHa, required double areaDisponibleHa}) {
    if (areaDisponibleHa <= 0 || areaSembradaHa < 0) return null;
    final pct = (areaSembradaHa / areaDisponibleHa) * 100.0;
    return double.parse(pct.toStringAsFixed(2));
  }

  /// Calcula los kg de semilla por hectárea: kg_semilla / ha
  static double? calculateSeedPerHa({required double kgSemilla, required double areaHa}) {
    if (areaHa <= 0 || kgSemilla < 0) return null;
    final res = kgSemilla / areaHa;
    return double.parse(res.toStringAsFixed(2));
  }

  /// Calcula el porcentaje de registros agronómicos completos.
  static double calculateCompletenessPercentage({required int completedFields, required int totalFields}) {
    if (totalFields <= 0) return 0.0;
    final pct = (completedFields / totalFields) * 100.0;
    return double.parse(pct.toStringAsFixed(1));
  }
}
