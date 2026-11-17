import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat _isoFormat = DateFormat('yyyy-MM-dd');
  static final DateFormat _displayFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _fullDisplayFormat = DateFormat("d 'de' MMMM 'de' yyyy", 'es_ES');

  /// Convierte DateTime a formato ISO para SQLite: 'yyyy-MM-dd'
  static String toIso(DateTime date) {
    return _isoFormat.format(date);
  }

  /// Parsea string ISO 'yyyy-MM-dd' a DateTime
  static DateTime? parseIso(String? dateStr) {
    if (dateStr == null || dateStr.trim().isEmpty) return null;
    try {
      return _isoFormat.parse(dateStr.trim());
    } catch (_) {
      try {
        return DateTime.parse(dateStr.trim());
      } catch (_) {
        return null;
      }
    }
  }

  /// Formato legible para el agricultor: 'dd/MM/yyyy'
  static String toDisplay(String? dateStr) {
    final dt = parseIso(dateStr);
    if (dt == null) return 'No registrado';
    return _displayFormat.format(dt);
  }

  /// Formato completo en español
  static String toFullDisplay(String? dateStr) {
    final dt = parseIso(dateStr);
    if (dt == null) return 'Fecha no definida';
    return _fullDisplayFormat.format(dt);
  }

  /// Calcula el desfase en días entre la fecha prevista y la fecha efectiva de siembra.
  /// Retorna positivo si hubo retraso, 0 si fue puntual, negativo si se adelantó.
  static int? calculateDelayDays(String? fechaPrevistaStr, String? fechaRealStr) {
    final prevista = parseIso(fechaPrevistaStr);
    final real = parseIso(fechaRealStr);
    if (prevista == null || real == null) return null;
    return real.difference(prevista).inDays;
  }
}
