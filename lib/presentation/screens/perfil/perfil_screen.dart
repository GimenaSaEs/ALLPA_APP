import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../data/models/agricultor_model.dart';
import '../../providers/allpa_provider.dart';
import '../../widgets/sync_status_badge.dart';
import '../home_dashboard_screen.dart';

class PerfilScreen extends StatefulWidget {
  final bool isFirstTime;

  const PerfilScreen({super.key, this.isFirstTime = false});

  @override
  State<PerfilScreen> createState() => _PerfilScreenState();
}

class _PerfilScreenState extends State<PerfilScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreCtrl;
  late TextEditingController _codigoCtrl;
  late TextEditingController _documentoCtrl;
  late TextEditingController _telefonoCtrl;
  late TextEditingController _comunidadCtrl;
  late TextEditingController _distritoCtrl;
  late TextEditingController _provinciaCtrl;
  late TextEditingController _departamentoCtrl;
  bool _siembraIndividual = true;

  @override
  void initState() {
    super.initState();
    final prov = context.read<AllpaProvider>();
    final agr = prov.agricultor;

    _nombreCtrl = TextEditingController(text: agr?.nombre ?? '');
    _codigoCtrl = TextEditingController(
      text:
          agr?.codigoLocal ??
          'AGR-ILLPE-${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}',
    );
    _documentoCtrl = TextEditingController(text: agr?.documento ?? '');
    _telefonoCtrl = TextEditingController(text: agr?.telefono ?? '');
    _comunidadCtrl = TextEditingController(text: agr?.comunidad ?? 'Illpe');
    _distritoCtrl = TextEditingController(text: agr?.distrito ?? 'Pachamarca');
    _provinciaCtrl = TextEditingController(text: agr?.provincia ?? 'Churcampa');
    _departamentoCtrl = TextEditingController(
      text: agr?.departamento ?? 'Huancavelica',
    );
    _siembraIndividual = (agr?.siembraIndividual ?? 1) == 1;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _codigoCtrl.dispose();
    _documentoCtrl.dispose();
    _telefonoCtrl.dispose();
    _comunidadCtrl.dispose();
    _distritoCtrl.dispose();
    _provinciaCtrl.dispose();
    _departamentoCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    final prov = context.read<AllpaProvider>();
    final nuevoAgricultor = AgricultorModel(
      id: prov.agricultor?.id,
      nombre: _nombreCtrl.text.trim(),
      codigoLocal: _codigoCtrl.text.trim(),
      documento: _documentoCtrl.text.trim().isEmpty
          ? null
          : _documentoCtrl.text.trim(),
      telefono: _telefonoCtrl.text.trim().isEmpty
          ? null
          : _telefonoCtrl.text.trim(),
      comunidad: _comunidadCtrl.text.trim(),
      distrito: _distritoCtrl.text.trim(),
      provincia: _provinciaCtrl.text.trim(),
      departamento: _departamentoCtrl.text.trim(),
      siembraIndividual: _siembraIndividual ? 1 : 0,
      createdAt: prov.agricultor?.createdAt ?? DateTime.now().toIso8601String(),
    );

    try {
      await prov.saveAgricultor(nuevoAgricultor);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Perfil guardado correctamente en la base de datos local.',
          ),
          backgroundColor: AppColors.success,
        ),
      );

      if (widget.isFirstTime) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const HomeDashboardScreen()),
        );
      } else {
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Widget _responsiveFieldPair(Widget first, Widget second) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 620) {
          return Column(
            children: [first, const SizedBox(height: 12), second],
          );
        }
        return Row(
          children: [
            Expanded(child: first),
            const SizedBox(width: 10),
            Expanded(child: second),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isFirstTime ? 'Registro de Productor' : 'Perfil del Productor',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SyncStatusBadge(),
              const SizedBox(height: 18),

              // Cabecera de identidad
              Card(
                elevation: 0,
                color: AppColors.primaryContainer.withValues(alpha: 0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: const BorderSide(color: AppColors.primaryLight),
                ),
                child: const Padding(
                  padding: EdgeInsets.all(14),
                  child: Row(
                    children: [
                      Icon(
                        Icons.person_pin,
                        size: 36,
                        color: AppColors.primaryDark,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Datos del productor agrícola para identificar los registros de terrenos y cultivos.',
                          style: TextStyle(
                            fontSize: 13.5,
                            color: AppColors.primaryDark,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 18),
              const Text(
                'DATOS PERSONALES',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),

              // Nombre
              TextFormField(
                controller: _nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre y Apellidos *',
                  hintText: 'Ej. Persona de prueba',
                  prefixIcon: Icon(Icons.person, color: AppColors.primary),
                ),
                validator: (v) => Validators.requiredField(
                  v,
                  message: 'Ingrese su nombre completo',
                ),
              ),
              const SizedBox(height: 14),

              // Código Local
              TextFormField(
                controller: _codigoCtrl,
                decoration: const InputDecoration(
                  labelText: 'Código Local de Productor *',
                  hintText: 'Ej. AGR-ILLPE-001',
                  prefixIcon: Icon(Icons.badge, color: AppColors.primary),
                ),
                validator: (v) => Validators.requiredField(
                  v,
                  message: 'El código local es requerido',
                ),
              ),
              const SizedBox(height: 14),

              // DNI / Documento
              TextFormField(
                controller: _documentoCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Documento / DNI (Opcional)',
                  hintText: 'Ej. 00000000',
                  prefixIcon: Icon(Icons.credit_card, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 14),

              // Teléfono
              TextFormField(
                controller: _telefonoCtrl,
                keyboardType: TextInputType.phone,
                decoration: const InputDecoration(
                  labelText: 'Teléfono / Celular (Opcional)',
                  hintText: 'Sin teléfono exigido si no dispone',
                  prefixIcon: Icon(Icons.phone, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 22),

              const Text(
                'UBICACIÓN GEOGRÁFICA',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.secondary,
                  letterSpacing: 0.8,
                ),
              ),
              const SizedBox(height: 10),

              _responsiveFieldPair(
                TextFormField(
                  controller: _comunidadCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Comunidad / Centro Poblado',
                    prefixIcon: Icon(Icons.home, color: AppColors.primary),
                  ),
                ),
                TextFormField(
                  controller: _distritoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Distrito',
                    prefixIcon: Icon(
                      Icons.location_city,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              _responsiveFieldPair(
                TextFormField(
                  controller: _provinciaCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Provincia',
                    prefixIcon: Icon(Icons.map, color: AppColors.primary),
                  ),
                ),
                TextFormField(
                  controller: _departamentoCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Departamento',
                    prefixIcon: Icon(Icons.public, color: AppColors.primary),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Indicador: Siembra Individual
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.outlineVariant),
                ),
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text(
                    '¿Siembra y conduce de forma individual?',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                  subtitle: const Text(
                    'Indicador de investigación: conducción de parcelas por cuenta propia.',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textMuted,
                    ),
                  ),
                  value: _siembraIndividual,
                  activeThumbColor: AppColors.primary,
                  onChanged: (val) {
                    setState(() {
                      _siembraIndividual = val;
                    });
                  },
                ),
              ),

              const SizedBox(height: 28),

              ElevatedButton.icon(
                onPressed: _guardar,
                icon: const Icon(Icons.save),
                label: const Text('GUARDAR PERFIL'),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
