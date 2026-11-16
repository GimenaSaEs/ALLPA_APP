import 'package:allpa/servicios/bitacora_servicio.dart';
import 'package:allpa/ui/comun.dart';
import 'package:allpa/ui/tema.dart';
import 'package:flutter/material.dart';

class PantallaCosecha extends StatefulWidget {
  final BitacoraServicio servicio;
  final String campanaId;

  const PantallaCosecha({super.key, required this.servicio, required this.campanaId});

  @override
  State<PantallaCosecha> createState() => _PantallaCosechaState();
}

class _PantallaCosechaState extends State<PantallaCosecha> {
  final _hectareas = TextEditingController();
  final _kilos = TextEditingController();
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _hectareas.addListener(() => setState(() {}));
    _kilos.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _hectareas.dispose();
    _kilos.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ha = double.tryParse(_hectareas.text.replaceAll(',', '.'));
    final kg = double.tryParse(_kilos.text.replaceAll(',', '.'));
    final rendimientoEstimado = (ha != null && ha > 0 && kg != null && kg >= 0) ? (kg / ha) : null;

    return Cascaron(
      servicio: widget.servicio,
      alCambiarSenal: () => setState(() => widget.servicio.establecerSenal(!widget.servicio.haySenal)),
      cuerpo: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          const Text(
            'Registrar cosecha',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: ColoresAllpa.textoPrincipal,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Cierre de campaña: registro de superficie cosechada y producción total en kilogramos (RF-07).',
            style: TextStyle(fontSize: 13, color: ColoresAllpa.textoSecundario),
          ),
          const SizedBox(height: 16),

          // Tarjeta de Formulario
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.agriculture_rounded, color: ColoresAllpa.verdeBosque, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Datos de Cosecha',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ColoresAllpa.textoPrincipal),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _hectareas,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: campo(
                      'Hectáreas cosechadas',
                      prefixIcon: const Icon(Icons.square_foot_rounded, color: ColoresAllpa.textoSecundario),
                      suffixText: 'ha',
                      hintText: 'Ej. 1.1 (RN-05)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _kilos,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: campo(
                      'Producción total (kg)',
                      prefixIcon: const Icon(Icons.scale_rounded, color: ColoresAllpa.textoSecundario),
                      suffixText: 'kg',
                      hintText: 'Ej. 2640',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Tarjeta de Cálculo en Tiempo Real del Rendimiento (RF-12)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: rendimientoEstimado != null ? ColoresAllpa.trigoSuave : ColoresAllpa.fondoPapel,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: rendimientoEstimado != null ? ColoresAllpa.doradoAndino.withOpacity(0.4) : ColoresAllpa.bordeTarjeta,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: ColoresAllpa.doradoClaro),
                  ),
                  child: const Icon(Icons.insights_rounded, color: ColoresAllpa.doradoOscuro, size: 22),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Rendimiento agrícola estimado (RF-12)',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: ColoresAllpa.textoSecundario),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        rendimientoEstimado != null
                            ? '${rendimientoEstimado.toStringAsFixed(0)} kg/ha'
                            : 'Ingrese superficie y producción',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: rendimientoEstimado != null ? ColoresAllpa.doradoOscuro : ColoresAllpa.textoAtenuado,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Nota de Regla de Negocio RN-05
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: ColoresAllpa.verdeSuperficie,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: ColoresAllpa.verdeMentaSuave),
            ),
            child: const Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.info_outline_rounded, size: 16, color: ColoresAllpa.verdeBosque),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'RN-05: La cosecha exige una siembra previa y la superficie cosechada no debe superar la superficie sembrada.',
                    style: TextStyle(fontSize: 11.5, color: ColoresAllpa.verdeOscuro, height: 1.3),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Botón Guardar cosecha
          FilledButton.icon(
            onPressed: _guardando ? null : _guardar,
            icon: _guardando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle_outline_rounded, size: 20),
            label: const Text('Guardar cosecha'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    final campana = await guardar(
      context,
      () => widget.servicio.registrarCosecha(widget.campanaId, {
        'superficie_cosechada_ha': _hectareas.text.replaceAll(',', '.'),
        'produccion_kg': _kilos.text.replaceAll(',', '.'),
      }),
    );
    if (!mounted) return;
    setState(() => _guardando = false);
    if (campana == null) return;
    Navigator.of(context).pop();
  }
}
