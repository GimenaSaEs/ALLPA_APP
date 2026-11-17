import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/terreno_model.dart';
import '../../providers/allpa_provider.dart';

class TerrenoFormScreen extends StatefulWidget {
  final TerrenoModel? terreno;

  const TerrenoFormScreen({super.key, this.terreno});

  @override
  State<TerrenoFormScreen> createState() => _TerrenoFormScreenState();
}

class _TerrenoFormScreenState extends State<TerrenoFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _areaCtrl;
  late TextEditingController _ubicacionCtrl;

  @override
  void initState() {
    super.initState();
    _nombreCtrl = TextEditingController(text: widget.terreno?.nombre ?? '');
    _areaCtrl = TextEditingController(
      text: widget.terreno != null ? widget.terreno!.areaHa.toString() : '',
    );
    _ubicacionCtrl = TextEditingController(
      text: widget.terreno?.ubicacion ?? '',
    );
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _areaCtrl.dispose();
    _ubicacionCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final prov = context.read<AllpaProvider>();

    // Validar duplicados de nombre de terreno accidental
    final nombreIngresado = _nombreCtrl.text.trim();
    final existeDuplicado = prov.terrenos.any(
      (t) =>
          t.id != widget.terreno?.id &&
          t.nombre.toLowerCase() == nombreIngresado.toLowerCase(),
    );

    if (existeDuplicado) {
      final proceder = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Nombre similar detectado'),
          content: Text(
            'Ya tienes un terreno llamado "$nombreIngresado". ¿Deseas guardarlo de todas formas con el mismo nombre?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('CONTINUAR'),
            ),
          ],
        ),
      );
      if (!mounted || proceder != true) return;
    }

    final areaHa = double.parse(_areaCtrl.text.trim().replaceAll(',', '.'));
    final nuevoTerreno = TerrenoModel(
      id: widget.terreno?.id,
      agricultorId: prov.agricultor?.id ?? 1,
      nombre: nombreIngresado,
      areaHa: areaHa,
      ubicacion: _ubicacionCtrl.text.trim().isEmpty
          ? null
          : _ubicacionCtrl.text.trim(),
      createdAt: widget.terreno?.createdAt ?? DateTime.now().toIso8601String(),
    );
    final messenger = ScaffoldMessenger.of(context);

    try {
      await prov.saveTerreno(nuevoTerreno);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            widget.terreno == null
                ? 'Terreno registrado con éxito.'
                : 'Terreno actualizado con éxito.',
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
    final esEdicion = widget.terreno != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(esEdicion ? 'Editar Terreno' : 'Nuevo Terreno'),
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
                      Icon(Icons.info_outline, color: AppColors.primaryDark),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Indica el nombre de la parcela y su superficie total disponible en hectáreas (ha).',
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
              const SizedBox(height: 20),

              // Nombre del terreno
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre del Terreno / Parcela *',
                  hintText: 'Ej. Huayllapampa, Pampa Chuyma',
                  prefixIcon: Icon(Icons.badge, color: AppColors.primary),
                ),
                validator: (v) => Validators.requiredField(
                  v,
                  message: 'Ingrese el nombre del terreno',
                ),
              ),
              const SizedBox(height: 16),

              // Superficie disponible en ha
              TextFormField(
                controller: _areaCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Superficie Disponible (en hectáreas - ha) *',
                  hintText: 'Ej. 1.5, 0.75, 2.0',
                  suffixText: 'ha',
                  prefixIcon: Icon(Icons.square_foot, color: AppColors.primary),
                ),
                validator: (v) => Validators.positiveNumber(
                  v,
                  message: 'Ingrese una superficie mayor a 0 ha',
                ),
              ),
              const SizedBox(height: 16),

              // Ubicación descriptiva
              TextFormField(
                controller: _ubicacionCtrl,
                maxLines: 2,
                decoration: const InputDecoration(
                  labelText: 'Ubicación Descriptiva (Sector, linderos)',
                  hintText: 'Ej. Sector Alto Illpe, lindero con quebrada sur',
                  prefixIcon: Icon(Icons.place, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 28),

              ElevatedButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.save),
                label: Text(
                  esEdicion ? 'ACTUALIZAR TERRENO' : 'GUARDAR TERRENO',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
