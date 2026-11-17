import '../../core/database/database_helper.dart';
import '../../core/utils/date_formatter.dart';
import '../models/plan_siembra_model.dart';

class PlanSiembraRepository {
  final DatabaseHelper _dbHelper;

  PlanSiembraRepository({DatabaseHelper? dbHelper})
    : _dbHelper = dbHelper ?? DatabaseHelper.instance;

  Future<PlanSiembraModel?> getPlanByCultivoId(int cultivoId) async {
    final db = await _dbHelper.database;
    final List<Map<String, dynamic>> maps = await db.query(
      'plan_siembra',
      where: 'cultivo_id = ?',
      whereArgs: [cultivoId],
    );

    if (maps.isNotEmpty) {
      return PlanSiembraModel.fromMap(maps.first);
    }
    return null;
  }

  Future<int> savePlanSiembra(PlanSiembraModel plan) async {
    final db = await _dbHelper.database;

    // Calcular desfase y estado automáticamente si hay fechas
    int? desfase;
    String estado = plan.estado;
    if (plan.fechaPrevista != null && plan.fechaReal != null) {
      desfase = DateFormatter.calculateDelayDays(
        plan.fechaPrevista,
        plan.fechaReal,
      );
      if (desfase == 0) {
        estado = 'Cumplido a tiempo';
      } else if (desfase != null && desfase > 0) {
        estado = 'Cumplido con desfase (+${desfase}d)';
      } else if (desfase != null && desfase < 0) {
        estado = 'Cumplido adelantado (${desfase}d)';
      }
    } else if (plan.fechaReal != null) {
      estado = 'Realizado sin fecha prevista';
    } else {
      estado = 'Pendiente de siembra';
    }

    final toSave = plan.copyWith(desfaseDias: desfase, estado: estado);

    final existing = await getPlanByCultivoId(plan.cultivoId);
    if (existing == null) {
      return await db.insert('plan_siembra', toSave.toMap());
    } else {
      return await db.update(
        'plan_siembra',
        toSave.toMap(),
        where: 'cultivo_id = ?',
        whereArgs: [plan.cultivoId],
      );
    }
  }
}
