import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/cosecha_model.dart';
import '../../providers/allpa_provider.dart';

class CosechaFormScreen extends StatefulWidget {
  const CosechaFormScreen({super.key, required this.cultivoId, this.cosecha});

  final int cultivoId;
  final CosechaModel? cosecha;

  @override
  State<CosechaFormScreen> createState() => _CosechaFormScreenState();
}

class _CosechaFormScreenState extends State<CosechaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _fecha;
  late final TextEditingController _area;
  late final TextEditingController _produccion;
  late final TextEditingController _jornales;
  late final TextEditingController _observacion;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    final cosecha = widget.cosecha;
    _fecha = TextEditingController(
      text: cosecha?.fecha ?? DateTime.now().toIso8601String().substring(0, 10),
    );
    _area = TextEditingController(text: cosecha?.areaHa.toString() ?? '');
    _produccion = TextEditingController(
      text: cosecha?.produccionKg.toString() ?? '',
    );
    _jornales = TextEditingController(
      text: cosecha?.jornales.toString() ?? '0',
    );
    _observacion = TextEditingController(text: cosecha?.observacion ?? '');
  }

  @override
  void dispose() {
    _fecha.dispose();
    _area.dispose();
    _produccion.dispose();
    _jornales.dispose();
    _observacion.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.tryParse(_fecha.text) ?? DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
      helpText: 'Fecha de cosecha',
    );
    if (picked != null) {
      setState(() => _fecha.text = picked.toIso8601String().substring(0, 10));
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _guardando = true);
    final current = widget.cosecha;
    try {
      await context.read<AllpaProvider>().saveCosecha(
        CosechaModel(
          id: current?.id,
          cultivoId: widget.cultivoId,
          fecha: _fecha.text,
          areaHa: double.parse(_area.text.replaceAll(',', '.')),
          produccionKg: double.parse(_produccion.text.replaceAll(',', '.')),
          jornales: double.parse(_jornales.text.replaceAll(',', '.')),
          observacion: _observacion.text.trim().isEmpty
              ? null
              : _observacion.text.trim(),
          createdAt: current?.createdAt ?? DateTime.now().toIso8601String(),
        ),
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cosecha guardada en el dispositivo.')),
      );
      Navigator.pop(context);
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No se pudo guardar la cosecha: $error')),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.cosecha == null ? 'Registrar cosecha' : 'Editar cosecha',
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              'Registra la superficie cosechada, producción obtenida y jornales utilizados.',
            ),
            const SizedBox(height: 18),
            TextFormField(
              controller: _fecha,
              readOnly: true,
              onTap: _pickDate,
              decoration: const InputDecoration(
                labelText: 'Fecha de cosecha *',
                suffixIcon: Icon(Icons.calendar_month),
              ),
              validator: (value) => Validators.requiredField(value),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _area,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Superficie cosechada (ha) *',
              ),
              validator: (value) => Validators.positiveNumber(value),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _produccion,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Producción obtenida (kg) *',
              ),
              validator: (value) => Validators.nonNegativeNumber(value),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _jornales,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Jornales empleados',
              ),
              validator: (value) => Validators.nonNegativeNumber(value),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _observacion,
              minLines: 2,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Observaciones (opcional)',
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _guardando ? null : _save,
              icon: _guardando
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              label: const Text('GUARDAR COSECHA'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                minimumSize: const Size.fromHeight(52),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
