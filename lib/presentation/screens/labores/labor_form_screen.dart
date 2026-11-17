import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/labor_types.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/labor_model.dart';
import '../../providers/allpa_provider.dart';

class LaborFormScreen extends StatefulWidget {
  final int? cultivoId;
  final LaborModel? labor;

  const LaborFormScreen({super.key, this.cultivoId, this.labor});

  @override
  State<LaborFormScreen> createState() => _LaborFormScreenState();
}

class _LaborFormScreenState extends State<LaborFormScreen> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedCultivoId;
  String _selectedTipo = LaborTypes.types.first;
  late TextEditingController _fechaCtrl;
  late TextEditingController _jornalesCtrl;
  late TextEditingController _notaCtrl;

  @override
  void initState() {
    super.initState();
    _selectedCultivoId = widget.labor?.cultivoId ?? widget.cultivoId;
    _selectedTipo = widget.labor?.tipo ?? LaborTypes.types.first;
    _fechaCtrl = TextEditingController(
      text: widget.labor?.fecha ?? DateFormatter.toIso(DateTime.now()),
    );
    _jornalesCtrl = TextEditingController(
      text: widget.labor != null ? widget.labor!.jornales.toString() : '2.0',
    );
    _notaCtrl = TextEditingController(text: widget.labor?.nota ?? '');
  }

  @override
  void dispose() {
    _fechaCtrl.dispose();
    _jornalesCtrl.dispose();
    _notaCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime initialDate =
        DateFormatter.parseIso(_fechaCtrl.text) ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('es', 'ES'),
      helpText: 'Fecha en que se realizó la labor',
    );
    if (picked != null) {
      setState(() {
        _fechaCtrl.text = DateFormatter.toIso(picked);
      });
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedCultivoId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debe seleccionar el cultivo correspondiente.'),
        ),
      );
      return;
    }

    final jornales = double.parse(
      _jornalesCtrl.text.trim().replaceAll(',', '.'),
    );
    final prov = context.read<AllpaProvider>();

    final nuevaLabor = LaborModel(
      id: widget.labor?.id,
      cultivoId: _selectedCultivoId!,
      tipo: _selectedTipo,
      fecha: _fechaCtrl.text.trim(),
      jornales: jornales,
      nota: _notaCtrl.text.trim().isEmpty ? null : _notaCtrl.text.trim(),
      createdAt: widget.labor?.createdAt ?? DateTime.now().toIso8601String(),
    );

    try {
      await prov.saveLabor(nuevaLabor);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.labor == null
                ? 'Labor registrada con éxito.'
                : 'Labor actualizada con éxito.',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
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
    final cultivos = prov.cultivos;
    final esEdicion = widget.labor != null;

    if (cultivos.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Registrar Labor')),
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
                  'No hay cultivos activos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Para registrar una labor (preparación, deshierbo, riego), primero debe haber al menos un cultivo registrado.',
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

    _selectedCultivoId ??= cultivos.first.id;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          esEdicion ? 'Editar Labor Agrícola' : 'Registro de Labor Agrícola',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 0,
                color: AppColors.primaryContainer.withValues(alpha: 0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.primaryLight),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(Icons.handyman, color: AppColors.primaryDark),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Registre las actividades agronómicas y los jornales familiares dedicados.',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Selector de Cultivo
              DropdownButtonFormField<int>(
                initialValue: _selectedCultivoId,
                decoration: const InputDecoration(
                  labelText: 'Cultivo Asociado *',
                  prefixIcon: Icon(Icons.eco, color: AppColors.primary),
                ),
                items: cultivos.map((c) {
                  return DropdownMenuItem<int>(
                    value: c.id,
                    child: Text(
                      '${c.especie} (${c.variedad ?? "Común"}) en ${c.terrenoNombre}',
                    ),
                  );
                }).toList(),
                onChanged: esEdicion
                    ? null
                    : (val) {
                        setState(() => _selectedCultivoId = val);
                      },
                validator: (v) => v == null ? 'Seleccione un cultivo' : null,
              ),
              const SizedBox(height: 16),

              // Tipo de labor
              DropdownButtonFormField<String>(
                initialValue: _selectedTipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Labor Agrícola *',
                  prefixIcon: Icon(Icons.agriculture, color: AppColors.primary),
                ),
                items: LaborTypes.types.map((tipo) {
                  return DropdownMenuItem<String>(
                    value: tipo,
                    child: Text(tipo),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedTipo = val);
                },
              ),
              const SizedBox(height: 16),

              // Fecha de la labor
              InkWell(
                onTap: _pickDate,
                child: IgnorePointer(
                  child: TextFormField(
                    controller: _fechaCtrl,
                    decoration: InputDecoration(
                      labelText: 'Fecha de la Labor *',
                      prefixIcon: const Icon(
                        Icons.calendar_month,
                        color: AppColors.primary,
                      ),
                      helperText: DateFormatter.toFullDisplay(_fechaCtrl.text),
                    ),
                    validator: (v) => Validators.requiredField(
                      v,
                      message: 'Seleccione la fecha',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Jornales familiares
              TextFormField(
                controller: _jornalesCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Jornales Familiares Dedicados *',
                  hintText: 'Ej. 1.0, 2.5, 4.0',
                  suffixText: 'jornales',
                  prefixIcon: Icon(Icons.people, color: AppColors.primary),
                  helperText:
                      'Días de trabajo dedicados por miembros de la familia',
                ),
                validator: (v) => Validators.nonNegativeNumber(
                  v,
                  message:
                      'Ingrese una cantidad válida de jornales (0 o mayor)',
                ),
              ),
              const SizedBox(height: 16),

              // Observaciones / notas
              TextFormField(
                controller: _notaCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observaciones / Detalle',
                  hintText:
                      'Ej. Se usó yunta para el aporque; participaron 2 familiares.',
                  prefixIcon: Icon(Icons.notes, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 28),

              ElevatedButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.save),
                label: Text(esEdicion ? 'ACTUALIZAR LABOR' : 'GUARDAR LABOR'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
