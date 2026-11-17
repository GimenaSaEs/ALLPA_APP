import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/crop_types.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/cultivo_model.dart';
import '../../providers/allpa_provider.dart';

class CultivoFormScreen extends StatefulWidget {
  final int? terrenoId;
  final CultivoModel? cultivo;

  const CultivoFormScreen({super.key, this.terrenoId, this.cultivo});

  @override
  State<CultivoFormScreen> createState() => _CultivoFormScreenState();
}

class _CultivoFormScreenState extends State<CultivoFormScreen> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedTerrenoId;
  String _selectedEspecie = 'Papa';
  late TextEditingController _variedadCtrl;
  late TextEditingController _areaSembradaCtrl;
  late TextEditingController _fechaInicioCtrl;
  String _estado = 'En curso';

  @override
  void initState() {
    super.initState();
    _selectedTerrenoId = widget.cultivo?.terrenoId ?? widget.terrenoId;
    _selectedEspecie = widget.cultivo?.especie ?? 'Papa';
    _variedadCtrl = TextEditingController(
      text: widget.cultivo?.variedad ?? 'Canchán',
    );
    _areaSembradaCtrl = TextEditingController(
      text: widget.cultivo != null
          ? widget.cultivo!.areaSembradaHa.toString()
          : '',
    );
    _fechaInicioCtrl = TextEditingController(
      text: widget.cultivo?.fechaInicio ?? DateFormatter.toIso(DateTime.now()),
    );
    _estado = widget.cultivo?.estado ?? 'En curso';
  }

  @override
  void dispose() {
    _variedadCtrl.dispose();
    _areaSembradaCtrl.dispose();
    _fechaInicioCtrl.dispose();
    super.dispose();
  }

  Future<void> _seleccionarFecha() async {
    final DateTime initialDate =
        DateFormatter.parseIso(_fechaInicioCtrl.text) ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('es', 'ES'),
      helpText: 'Seleccione fecha de siembra o inicio',
    );
    if (picked != null) {
      setState(() {
        _fechaInicioCtrl.text = DateFormatter.toIso(picked);
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedTerrenoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe seleccionar un terreno.')),
      );
      return;
    }

    final prov = context.read<AllpaProvider>();
    final terreno = prov.terrenos.firstWhere((t) => t.id == _selectedTerrenoId);

    final areaSembrada = double.parse(
      _areaSembradaCtrl.text.trim().replaceAll(',', '.'),
    );

    // Validar coherencia de superficie
    final valErr = Validators.validateAreaAgainstTerreno(
      _areaSembradaCtrl.text.trim(),
      terreno.areaHa,
    );
    if (valErr != null) {
      final proceder = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Advertencia de Superficie'),
          content: Text('$valErr. ¿Está seguro de guardar este valor?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('CORREGIR'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('GUARDAR DE TODOS MODOS'),
            ),
          ],
        ),
      );
      if (!mounted || proceder != true) return;
    }

    final nuevoCultivo = CultivoModel(
      id: widget.cultivo?.id,
      terrenoId: _selectedTerrenoId!,
      especie: _selectedEspecie,
      variedad: _variedadCtrl.text.trim().isEmpty
          ? null
          : _variedadCtrl.text.trim(),
      areaSembradaHa: areaSembrada,
      fechaInicio: _fechaInicioCtrl.text.trim(),
      estado: _estado,
      createdAt: widget.cultivo?.createdAt ?? DateTime.now().toIso8601String(),
    );
    final messenger = ScaffoldMessenger.of(context);

    try {
      await prov.saveCultivo(nuevoCultivo);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.cultivo == null
                ? 'Cultivo registrado con éxito.'
                : 'Cultivo actualizado con éxito.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final prov = context.watch<AllpaProvider>();
    final terrenos = prov.terrenos;
    final esEdicion = widget.cultivo != null;

    if (terrenos.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Nuevo Cultivo')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.warning_amber_rounded,
                  size: 64,
                  color: AppColors.warning,
                ),
                const SizedBox(height: 16),
                const Text(
                  'No hay terrenos registrados',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Antes de registrar un cultivo, debe registrar el terreno o parcela donde se sembrará.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('VOLVER'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Default terrenoId si no estaba seteado
    _selectedTerrenoId ??= terrenos.first.id;

    final variedadesSugeridas =
        CropTypes.varietiesMap[_selectedEspecie] ?? ['Variedad local'];

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar Cultivo' : 'Nuevo Cultivo'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Selector de Terreno
              DropdownButtonFormField<int>(
                initialValue: _selectedTerrenoId,
                decoration: const InputDecoration(
                  labelText: 'Terreno / Parcela *',
                  prefixIcon: Icon(Icons.landscape, color: AppColors.primary),
                ),
                items: terrenos.map((t) {
                  return DropdownMenuItem<int>(
                    value: t.id,
                    child: Text('${t.nombre} (${t.areaHa} ha)'),
                  );
                }).toList(),
                onChanged: esEdicion
                    ? null // No cambiar terreno si ya está en edición para mantener integridad
                    : (val) {
                        setState(() {
                          _selectedTerrenoId = val;
                        });
                      },
                validator: (v) => v == null ? 'Seleccione un terreno' : null,
              ),
              const SizedBox(height: 16),

              // Selector de Especie
              DropdownButtonFormField<String>(
                initialValue: _selectedEspecie,
                decoration: const InputDecoration(
                  labelText: 'Especie Agrícola *',
                  prefixIcon: Icon(Icons.eco, color: AppColors.primary),
                ),
                items: CropTypes.speciesList.map((esp) {
                  return DropdownMenuItem<String>(value: esp, child: Text(esp));
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedEspecie = val;
                      final varList = CropTypes.varietiesMap[val];
                      if (varList != null && varList.isNotEmpty) {
                        _variedadCtrl.text = varList.first;
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Variedad con sugerencias
              TextFormField(
                controller: _variedadCtrl,
                decoration: InputDecoration(
                  labelText: 'Variedad *',
                  hintText: 'Ej. Canchán, Yungay, Blanco común',
                  prefixIcon: const Icon(Icons.spa, color: AppColors.primary),
                  helperText:
                      'Sugeridas: ${variedadesSugeridas.take(4).join(", ")}',
                ),
                validator: (v) =>
                    Validators.requiredField(v, message: 'Ingrese la variedad'),
              ),
              const SizedBox(height: 16),

              // Superficie sembrada en ha
              TextFormField(
                controller: _areaSembradaCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Superficie Sembrada (ha) *',
                  hintText: 'Ej. 0.5, 1.0, 1.25',
                  suffixText: 'ha',
                  prefixIcon: Icon(Icons.straighten, color: AppColors.primary),
                ),
                validator: (v) => Validators.positiveNumber(
                  v,
                  message: 'Ingrese una superficie sembrada mayor a 0 ha',
                ),
              ),
              const SizedBox(height: 16),

              // Fecha de siembra / inicio
              InkWell(
                onTap: _seleccionarFecha,
                child: IgnorePointer(
                  child: TextFormField(
                    controller: _fechaInicioCtrl,
                    decoration: InputDecoration(
                      labelText: 'Fecha de Siembra o Inicio *',
                      prefixIcon: const Icon(
                        Icons.calendar_month,
                        color: AppColors.primary,
                      ),
                      helperText: DateFormatter.toFullDisplay(
                        _fechaInicioCtrl.text,
                      ),
                    ),
                    validator: (v) => Validators.requiredField(
                      v,
                      message: 'Seleccione la fecha',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Estado del cultivo
              DropdownButtonFormField<String>(
                initialValue: _estado,
                decoration: const InputDecoration(
                  labelText: 'Estado del Cultivo *',
                  prefixIcon: Icon(Icons.timelapse, color: AppColors.primary),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'Planificado',
                    child: Text('Planificado'),
                  ),
                  DropdownMenuItem(
                    value: 'En curso',
                    child: Text('En curso (Activo)'),
                  ),
                  DropdownMenuItem(
                    value: 'Cosechado',
                    child: Text('Cosechado'),
                  ),
                  DropdownMenuItem(
                    value: 'Finalizado',
                    child: Text('Finalizado'),
                  ),
                ],
                onChanged: (val) {
                  if (val != null) setState(() => _estado = val);
                },
              ),
              const SizedBox(height: 28),

              ElevatedButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.save),
                label: Text(
                  esEdicion ? 'ACTUALIZAR CULTIVO' : 'GUARDAR CULTIVO',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
