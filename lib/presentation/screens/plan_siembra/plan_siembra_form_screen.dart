import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/date_formatter.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/plan_siembra_model.dart';
import '../../providers/allpa_provider.dart';

class PlanSiembraFormScreen extends StatefulWidget {
  final int cultivoId;

  const PlanSiembraFormScreen({super.key, required this.cultivoId});

  @override
  State<PlanSiembraFormScreen> createState() => _PlanSiembraFormScreenState();
}

class _PlanSiembraFormScreenState extends State<PlanSiembraFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fechaPrevistaCtrl;
  late TextEditingController _fechaRealCtrl;
  late TextEditingController _observacionCtrl;
  bool _planEscrito = true;
  int? _desfaseCalculado;

  @override
  void initState() {
    super.initState();
    _fechaPrevistaCtrl = TextEditingController();
    _fechaRealCtrl = TextEditingController();
    _observacionCtrl = TextEditingController();

    // Cargar plan existente si lo hay
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final plan = await context.read<AllpaProvider>().getPlanSiembra(widget.cultivoId);
      if (plan != null && mounted) {
        setState(() {
          _fechaPrevistaCtrl.text = plan.fechaPrevista ?? '';
          _fechaRealCtrl.text = plan.fechaReal ?? '';
          _observacionCtrl.text = plan.observacion ?? '';
          _planEscrito = plan.escrito == 1;
          _desfaseCalculado = plan.desfaseDias;
        });
      }
    });
  }

  @override
  void dispose() {
    _fechaPrevistaCtrl.dispose();
    _fechaRealCtrl.dispose();
    _observacionCtrl.dispose();
    super.dispose();
  }

  void _recalcularDesfase() {
    final desfase = DateFormatter.calculateDelayDays(
      _fechaPrevistaCtrl.text.isNotEmpty ? _fechaPrevistaCtrl.text : null,
      _fechaRealCtrl.text.isNotEmpty ? _fechaRealCtrl.text : null,
    );
    setState(() {
      _desfaseCalculado = desfase;
    });
  }

  Future<void> _pickDate(TextEditingController ctrl, String title) async {
    final DateTime initialDate = DateFormatter.parseIso(ctrl.text) ?? DateTime.now();
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('es', 'ES'),
      helpText: title,
    );
    if (picked != null) {
      setState(() {
        ctrl.text = DateFormatter.toIso(picked);
      });
      _recalcularDesfase();
    }
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final prov = context.read<AllpaProvider>();

    final plan = PlanSiembraModel(
      cultivoId: widget.cultivoId,
      fechaPrevista: _fechaPrevistaCtrl.text.trim().isEmpty ? null : _fechaPrevistaCtrl.text.trim(),
      fechaReal: _fechaRealCtrl.text.trim().isEmpty ? null : _fechaRealCtrl.text.trim(),
      escrito: _planEscrito ? 1 : 0,
      desfaseDias: _desfaseCalculado,
      observacion: _observacionCtrl.text.trim().isEmpty ? null : _observacionCtrl.text.trim(),
      createdAt: DateTime.now().toIso8601String(),
    );

    try {
      await prov.savePlanSiembra(plan);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Plan de siembra guardado correctamente.'),
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
    final cultivo = prov.cultivos.where((c) => c.id == widget.cultivoId).firstOrNull;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Planificación de Siembra'),
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
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Row(
                    children: [
                      const Icon(Icons.date_range, color: AppColors.primaryDark),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          cultivo != null
                              ? 'Cultivo: ${cultivo.especie} (${cultivo.variedad ?? "Común"}) en ${cultivo.terrenoNombre ?? "Terreno"}'
                              : 'Planificación de Siembra y Desfase Agronómico',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Fecha Prevista
              InkWell(
                onTap: () => _pickDate(_fechaPrevistaCtrl, 'Fecha Prevista de Siembra'),
                child: IgnorePointer(
                  child: TextFormField(
                    controller: _fechaPrevistaCtrl,
                    decoration: InputDecoration(
                      labelText: 'Fecha Prevista de Siembra (Planificada)',
                      prefixIcon: const Icon(Icons.calendar_today, color: AppColors.primary),
                      helperText: _fechaPrevistaCtrl.text.isNotEmpty
                          ? DateFormatter.toFullDisplay(_fechaPrevistaCtrl.text)
                          : 'Fecha en la que el productor planeó sembrar',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 18),

              // Fecha Real / Efectiva
              InkWell(
                onTap: () => _pickDate(_fechaRealCtrl, 'Fecha Efectiva / Real de Siembra'),
                child: IgnorePointer(
                  child: TextFormField(
                    controller: _fechaRealCtrl,
                    decoration: InputDecoration(
                      labelText: 'Fecha Efectiva de Siembra (Realizada)',
                      prefixIcon: const Icon(Icons.event_available, color: AppColors.primary),
                      helperText: _fechaRealCtrl.text.isNotEmpty
                          ? DateFormatter.toFullDisplay(_fechaRealCtrl.text)
                          : 'Día en que efectivamente se colocó la semilla',
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Indicador Visual de Desfase de Siembra
              if (_desfaseCalculado != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _desfaseCalculado == 0
                        ? AppColors.primaryContainer
                        : (_desfaseCalculado! > 0 ? const Color(0xFFFFF3E0) : const Color(0xFFE1F5FE)),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: _desfaseCalculado == 0
                          ? AppColors.primary
                          : (_desfaseCalculado! > 0 ? AppColors.warning : AppColors.info),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _desfaseCalculado == 0
                            ? Icons.check_circle
                            : (_desfaseCalculado! > 0 ? Icons.alarm_on : Icons.fast_forward),
                        color: _desfaseCalculado == 0
                            ? AppColors.primary
                            : (_desfaseCalculado! > 0 ? AppColors.warning : AppColors.info),
                        size: 30,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'INDICADOR: DESFASE DE SIEMBRA',
                              style: TextStyle(fontSize: 11.5, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _desfaseCalculado == 0
                                  ? 'Siembra ejecutada puntualmente (0 días de desfase)'
                                  : (_desfaseCalculado! > 0
                                      ? 'Retraso de +$_desfaseCalculado días respecto a lo previsto'
                                      : 'Adelanto de $_desfaseCalculado días'),
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],

              // Existencia de Plan Escrito
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    '¿Registró el plan de siembra por escrito / app?',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Indicador de manejo agronómico: formalización del plan.',
                    style: TextStyle(fontSize: 12.5, color: AppColors.textMuted),
                  ),
                  value: _planEscrito,
                  activeColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() => _planEscrito = val);
                  },
                ),
              ),
              const SizedBox(height: 18),

              // Observaciones (ej. motivos de desfase por lluvias)
              TextFormField(
                controller: _observacionCtrl,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Observaciones / Causa del desfase',
                  hintText: 'Ej. Retraso por escasez de lluvia o disponibilidad de yunta/jornales en Illpe.',
                  prefixIcon: Icon(Icons.comment, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 28),

              ElevatedButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.save),
                label: const Text('GUARDAR PLAN DE SIEMBRA'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
