import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/input_types.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/insumo_model.dart';
import '../../providers/allpa_provider.dart';

class InsumoFormScreen extends StatefulWidget {
  final int? cultivoId;
  final InsumoModel? insumo;

  const InsumoFormScreen({super.key, this.cultivoId, this.insumo});

  @override
  State<InsumoFormScreen> createState() => _InsumoFormScreenState();
}

class _InsumoFormScreenState extends State<InsumoFormScreen> {
  final _formKey = GlobalKey<FormState>();

  int? _selectedCultivoId;
  String _selectedTipo = InputTypes.types.first;
  late TextEditingController _nombreCtrl;
  late TextEditingController _cantidadCtrl;
  String _selectedUnidad = InputTypes.units.first;
  late TextEditingController _fechaCtrl;

  @override
  void initState() {
    super.initState();
    _selectedCultivoId = widget.insumo?.cultivoId ?? widget.cultivoId;
    _selectedTipo = widget.insumo?.tipo ?? InputTypes.types.first;
    _nombreCtrl = TextEditingController(
      text: widget.insumo?.nombre ?? (_selectedTipo == 'Semilla' ? 'Semilla seleccionada' : ''),
    );
    _cantidadCtrl = TextEditingController(
      text: widget.insumo != null ? widget.insumo!.cantidad.toString() : '',
    );
    _selectedUnidad = widget.insumo?.unidad ?? InputTypes.units.first;
    _fechaCtrl = TextEditingController(
      text: widget.insumo?.fecha ?? DateFormatter.toIso(DateTime.now()),
    );
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _cantidadCtrl.dispose();
    _fechaCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final DateTime initialDate = DateFormatter.parseIso(_fechaCtrl.text) ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('es', 'ES'),
      helpText: 'Fecha de aplicación o uso del insumo',
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
        const SnackBar(content: Text('Debe seleccionar el cultivo correspondiente.')),
      );
      return;
    }

    final cantidad = double.parse(_cantidadCtrl.text.trim().replaceAll(',', '.'));
    final prov = context.read<AllpaProvider>();

    final nuevoInsumo = InsumoModel(
      id: widget.insumo?.id,
      cultivoId: _selectedCultivoId!,
      tipo: _selectedTipo,
      nombre: _nombreCtrl.text.trim(),
      cantidad: cantidad,
      unidad: _selectedUnidad,
      fecha: _fechaCtrl.text.trim(),
      createdAt: widget.insumo?.createdAt ?? DateTime.now().toIso8601String(),
    );

    try {
      await prov.saveInsumo(nuevoInsumo);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.insumo == null ? 'Insumo registrado con éxito.' : 'Insumo actualizado con éxito.',
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
    final esEdicion = widget.insumo != null;

    if (cultivos.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Registrar Insumo')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning_amber_rounded, size: 64, color: AppColors.warning),
                const SizedBox(height: 16),
                const Text(
                  'No hay cultivos activos',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Para registrar semillas o abonos, primero debe tener al menos un cultivo registrado.',
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
        title: Text(esEdicion ? 'Editar Insumo Agrícola' : 'Registro de Insumo Agrícola'),
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
                color: AppColors.primaryContainer.withOpacity(0.35),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.primaryLight),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(Icons.inventory_2, color: AppColors.primaryDark),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Registre semillas, fertilizantes y abonos. En semillas, la cantidad permite calcular el indicador kg/ha.',
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
                value: _selectedCultivoId,
                decoration: const InputDecoration(
                  labelText: 'Cultivo Asociado *',
                  prefixIcon: Icon(Icons.eco, color: AppColors.primary),
                ),
                items: cultivos.map((c) {
                  return DropdownMenuItem<int>(
                    value: c.id,
                    child: Text('${c.especie} (${c.variedad ?? "Común"}) en ${c.terrenoNombre}'),
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

              // Tipo de insumo
              DropdownButtonFormField<String>(
                value: _selectedTipo,
                decoration: const InputDecoration(
                  labelText: 'Tipo de Insumo *',
                  prefixIcon: Icon(Icons.category, color: AppColors.primary),
                ),
                items: InputTypes.types.map((tipo) {
                  return DropdownMenuItem<String>(
                    value: tipo,
                    child: Text(tipo),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _selectedTipo = val;
                      if (val == 'Semilla' && _nombreCtrl.text.isEmpty) {
                        _nombreCtrl.text = 'Semilla seleccionada';
                      }
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Nombre descriptivo del insumo
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre / Detalle del Insumo *',
                  hintText: 'Ej. Semilla Canchán primera, Guano de corral ovino',
                  prefixIcon: Icon(Icons.description, color: AppColors.primary),
                ),
                validator: (v) => Validators.requiredField(v, message: 'Ingrese el nombre del insumo'),
              ),
              const SizedBox(height: 16),

              // Cantidad y Unidad
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    flex: 5,
                    child: TextFormField(
                      controller: _cantidadCtrl,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true),
                      decoration: const InputDecoration(
                        labelText: 'Cantidad *',
                        hintText: 'Ej. 50, 250, 1200',
                        prefixIcon: Icon(Icons.numbers, color: AppColors.primary),
                      ),
                      validator: (v) => Validators.nonNegativeNumber(
                        v,
                        message: 'Ingrese cantidad >= 0',
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 6,
                    child: DropdownButtonFormField<String>(
                      value: _selectedUnidad,
                      decoration: const InputDecoration(
                        labelText: 'Unidad *',
                      ),
                      items: InputTypes.units.map((u) {
                        return DropdownMenuItem<String>(
                          value: u,
                          child: Text(u, style: const TextStyle(fontSize: 13)),
                        );
                      }).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => _selectedUnidad = val);
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Fecha de uso
              InkWell(
                onTap: _pickDate,
                child: IgnorePointer(
                  child: TextFormField(
                    controller: _fechaCtrl,
                    decoration: InputDecoration(
                      labelText: 'Fecha de Aplicación / Uso *',
                      prefixIcon: const Icon(Icons.calendar_month, color: AppColors.primary),
                      helperText: DateFormatter.toFullDisplay(_fechaCtrl.text),
                    ),
                    validator: (v) => Validators.requiredField(v, message: 'Seleccione la fecha'),
                  ),
                ),
              ),
              const SizedBox(height: 28),

              ElevatedButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.save),
                label: Text(esEdicion ? 'ACTUALIZAR INSUMO' : 'GUARDAR INSUMO'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
