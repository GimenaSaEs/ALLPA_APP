import 'package:flutter/material.dart';
import '../../core/utils/csv_exporter.dart';
import '../../data/models/agricultor_model.dart';
import '../../data/models/terreno_model.dart';
import '../../data/models/cultivo_model.dart';
import '../../data/models/plan_siembra_model.dart';
import '../../data/models/labor_model.dart';
import '../../data/models/insumo_model.dart';
import '../../data/models/cosecha_model.dart';
import '../../data/models/indicadores_model.dart';
import '../../data/repositories/agricultor_repository.dart';
import '../../data/repositories/terreno_repository.dart';
import '../../data/repositories/cultivo_repository.dart';
import '../../data/repositories/plan_siembra_repository.dart';
import '../../data/repositories/labor_repository.dart';
import '../../data/repositories/insumo_repository.dart';
import '../../data/repositories/cosecha_repository.dart';
import '../../data/repositories/bitacora_repository.dart';
import '../../data/repositories/indicadores_repository.dart';

class AllpaProvider with ChangeNotifier {
  final AgricultorRepository _agricultorRepo = AgricultorRepository();
  final TerrenoRepository _terrenoRepo = TerrenoRepository();
  final CultivoRepository _cultivoRepo = CultivoRepository();
  final PlanSiembraRepository _planRepo = PlanSiembraRepository();
  final LaborRepository _laborRepo = LaborRepository();
  final InsumoRepository _insumoRepo = InsumoRepository();
  final CosechaRepository _cosechaRepo = CosechaRepository();
  final BitacoraRepository _bitacoraRepo = BitacoraRepository();
  final IndicadoresRepository _indicadoresRepo = IndicadoresRepository();

  bool _isLoading = false;
  String? _errorMessage;

  AgricultorModel? _agricultor;
  List<TerrenoModel> _terrenos = [];
  List<CultivoModel> _cultivos = [];
  List<LaborModel> _labores = [];
  List<InsumoModel> _insumos = [];
  List<CosechaModel> _cosechas = [];
  List<BitacoraItem> _bitacora = [];
  List<IndicadoresModel> _indicadoresCultivos = [];
  ResumenGeneralIndicadores? _resumenIndicadores;

  // Filtros de bitácora
  int? _filtroTerrenoId;
  int? _filtroCultivoId;
  String _filtroTipo = 'Todos';

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  AgricultorModel? get agricultor => _agricultor;
  List<TerrenoModel> get terrenos => _terrenos;
  List<CultivoModel> get cultivos => _cultivos;
  List<LaborModel> get labores => _labores;
  List<InsumoModel> get insumos => _insumos;
  List<CosechaModel> get cosechas => _cosechas;
  List<BitacoraItem> get bitacora => _bitacora;
  List<IndicadoresModel> get indicadoresCultivos => _indicadoresCultivos;
  ResumenGeneralIndicadores? get resumenIndicadores => _resumenIndicadores;

  int? get filtroTerrenoId => _filtroTerrenoId;
  int? get filtroCultivoId => _filtroCultivoId;
  String get filtroTipo => _filtroTipo;

  // Los módulos conectados usan almacenamiento local SQLite.
  bool get isOfflineMode => true;
  String get syncStatusText => 'Almacenamiento local SQLite';

  /// Carga inicial de datos al iniciar la app
  Future<void> initializeApp() async {
    _isLoading = true;
    notifyListeners();

    try {
      _agricultor = await _agricultorRepo.getAgricultor();
      if (_agricultor != null) {
        await refreshAll();
      }
    } catch (e) {
      _errorMessage = 'Error al inicializar la base de datos: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Recarga todos los datos
  Future<void> refreshAll() async {
    if (_agricultor == null) return;
    try {
      _terrenos = await _terrenoRepo.getTerrenosByAgricultor(_agricultor!.id!);
      _cultivos = await _cultivoRepo.getAllCultivos();
      _labores = await _laborRepo.getAllLabores();
      _insumos = await _insumoRepo.getAllInsumos();
      _cosechas = await _cosechaRepo.getAllCosechas();
      await refreshBitacora();
      await refreshIndicadores();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Error al actualizar registros: $e';
      notifyListeners();
    }
  }

  // --- AGRICULTOR ---
  Future<void> saveAgricultor(AgricultorModel model) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_agricultor == null) {
        final id = await _agricultorRepo.insertAgricultor(model);
        _agricultor = model.copyWith(id: id);
      } else {
        await _agricultorRepo.updateAgricultor(model);
        _agricultor = model;
      }
      await refreshAll();
    } catch (e) {
      _errorMessage = 'Error al guardar perfil: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // --- TERRENOS ---
  Future<void> saveTerreno(TerrenoModel model) async {
    if (_agricultor == null) return;
    try {
      if (model.id == null) {
        await _terrenoRepo.insertTerreno(
          model.copyWith(agricultorId: _agricultor!.id!),
        );
      } else {
        await _terrenoRepo.updateTerreno(model);
      }
      await refreshAll();
    } catch (e) {
      _errorMessage = 'Error al guardar terreno: $e';
      rethrow;
    }
  }

  Future<void> deleteTerreno(int id) async {
    try {
      await _terrenoRepo.deleteTerreno(id);
      await refreshAll();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    }
  }

  // --- CULTIVOS ---
  Future<int> saveCultivo(CultivoModel model) async {
    try {
      int cultivoId;
      if (model.id == null) {
        cultivoId = await _cultivoRepo.insertCultivo(model);
      } else {
        await _cultivoRepo.updateCultivo(model);
        cultivoId = model.id!;
      }
      await refreshAll();
      return cultivoId;
    } catch (e) {
      _errorMessage = 'Error al guardar cultivo: $e';
      rethrow;
    }
  }

  Future<void> deleteCultivo(int id) async {
    try {
      await _cultivoRepo.deleteCultivo(id);
      await refreshAll();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    }
  }

  // --- PLAN DE SIEMBRA ---
  Future<PlanSiembraModel?> getPlanSiembra(int cultivoId) async {
    return await _planRepo.getPlanByCultivoId(cultivoId);
  }

  Future<void> savePlanSiembra(PlanSiembraModel model) async {
    try {
      await _planRepo.savePlanSiembra(model);
      await refreshAll();
    } catch (e) {
      _errorMessage = 'Error al guardar plan de siembra: $e';
      rethrow;
    }
  }

  // --- LABORES ---
  Future<void> saveLabor(LaborModel model) async {
    try {
      if (model.id == null) {
        await _laborRepo.insertLabor(model);
      } else {
        await _laborRepo.updateLabor(model);
      }
      await refreshAll();
    } catch (e) {
      _errorMessage = 'Error al guardar labor: $e';
      rethrow;
    }
  }

  Future<void> deleteLabor(int id) async {
    try {
      await _laborRepo.deleteLabor(id);
      await refreshAll();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    }
  }

  // --- INSUMOS ---
  Future<void> saveInsumo(InsumoModel model) async {
    try {
      if (model.id == null) {
        await _insumoRepo.insertInsumo(model);
      } else {
        await _insumoRepo.updateInsumo(model);
      }
      await refreshAll();
    } catch (e) {
      _errorMessage = 'Error al guardar insumo: $e';
      rethrow;
    }
  }

  Future<void> deleteInsumo(int id) async {
    try {
      await _insumoRepo.deleteInsumo(id);
      await refreshAll();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    }
  }

  // --- COSECHAS ---
  Future<CosechaModel?> getCosechaByCultivo(int cultivoId) async {
    return await _cosechaRepo.getCosechaByCultivoId(cultivoId);
  }

  Future<void> saveCosecha(CosechaModel model) async {
    try {
      await _cosechaRepo.saveCosecha(model);
      await refreshAll();
    } catch (e) {
      _errorMessage = 'Error al guardar cosecha: $e';
      rethrow;
    }
  }

  Future<void> deleteCosecha(int id) async {
    try {
      await _cosechaRepo.deleteCosecha(id);
      await refreshAll();
    } catch (e) {
      _errorMessage = e.toString();
      rethrow;
    }
  }

  // --- BITÁCORA ---
  void setBitacoraFilter({int? terrenoId, int? cultivoId, String? tipo}) {
    _filtroTerrenoId = terrenoId;
    _filtroCultivoId = cultivoId;
    if (tipo != null) _filtroTipo = tipo;
    refreshBitacora();
  }

  Future<void> refreshBitacora() async {
    _bitacora = await _bitacoraRepo.getBitacora(
      terrenoId: _filtroTerrenoId,
      cultivoId: _filtroCultivoId,
      tipoFiltro: _filtroTipo,
    );
    notifyListeners();
  }

  // --- INDICADORES ---
  Future<void> refreshIndicadores() async {
    _indicadoresCultivos = await _indicadoresRepo.getIndicadoresPorCultivo();
    _resumenIndicadores = await _indicadoresRepo.getResumenGeneral();
    notifyListeners();
  }

  // --- EXPORTACIÓN CSV ---
  String exportBitacoraCsv() {
    final list = _bitacora.map((item) => item.toMap()).toList();
    return CsvExporter.exportAgronomicLogToCsv(list);
  }

  String exportIndicadoresCsv() {
    final list = _indicadoresCultivos.map((item) => item.toMap()).toList();
    return CsvExporter.exportIndicatorsToCsv(list);
  }
}
