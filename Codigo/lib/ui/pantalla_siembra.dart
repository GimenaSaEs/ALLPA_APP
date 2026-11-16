import 'package:allpa/dominio/reglas.dart';
import 'package:allpa/servicios/bitacora_servicio.dart';
import 'package:allpa/ui/comun.dart';
import 'package:allpa/ui/tema.dart';
import 'package:flutter/material.dart';

class PantallaSiembra extends StatefulWidget {
  final BitacoraServicio servicio;
  final String campanaId;

  const PantallaSiembra({super.key, required this.servicio, required this.campanaId});

  @override
  State<PantallaSiembra> createState() => _PantallaSiembraState();
}

class _PantallaSiembraState extends State<PantallaSiembra> {
  DateTime? _fecha;
  final _hectareas = TextEditingController();
  final _semilla = TextEditingController();
  final _jornales = TextEditingController(text: '0');
  bool? _individual;
  bool _guardando = false;

  @override
  void dispose() {
    _hectareas.dispose();
    _semilla.dispose();
    _jornales.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Cascaron(
      servicio: widget.servicio,
      alCambiarSenal: () => setState(() => widget.servicio.establecerSenal(!widget.servicio.haySenal)),
      cuerpo: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          const Text(
            'Registrar siembra',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: ColoresAllpa.textoPrincipal,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Registro definitivo de la siembra real, insumo de semilla y jornales (RF-04 y RF-05).',
            style: TextStyle(fontSize: 13, color: ColoresAllpa.textoSecundario),
          ),
          const SizedBox(height: 16),

          // Tarjeta 1: Fecha Real de Siembra
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.calendar_today_rounded, color: ColoresAllpa.verdeBosque, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Fecha Real de Siembra',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ColoresAllpa.textoPrincipal),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Se contrastará con la fecha prevista para determinar el desfase en días.',
                    style: TextStyle(fontSize: 12, color: ColoresAllpa.textoSecundario),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => elegirFecha(context, _fecha, (fecha) => setState(() => _fecha = fecha)),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: ColoresAllpa.verdeSuperficie,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: ColoresAllpa.verdeMentaSuave),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.event_available_rounded, color: ColoresAllpa.verdeBosque, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              _fecha == null ? 'Elegir fecha en que sembró' : 'Sembró el ${isoFecha(_fecha)}',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: _fecha == null ? ColoresAllpa.textoSecundario : ColoresAllpa.verdeOscuro,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: ColoresAllpa.verdeBosque),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Tarjeta 2: Superficie e Insumos
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.straighten_rounded, color: ColoresAllpa.verdeBosque, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Superficie e Insumos',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ColoresAllpa.textoPrincipal),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _hectareas,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: campo(
                      'Hectáreas sembradas',
                      prefixIcon: const Icon(Icons.square_foot_rounded, color: ColoresAllpa.textoSecundario),
                      suffixText: 'ha',
                      hintText: 'Ej. 1.2 (RN-03)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _semilla,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: campo(
                      'Kilogramos de semilla',
                      prefixIcon: const Icon(Icons.grain_rounded, color: ColoresAllpa.textoSecundario),
                      suffixText: 'kg',
                      hintText: 'Ej. 90.0 (RF-05)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _jornales,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: campo(
                      'Jornales de la familia en la siembra',
                      prefixIcon: const Icon(Icons.people_alt_outlined, color: ColoresAllpa.textoSecundario),
                      suffixText: 'jornales',
                      hintText: 'Ej. 3 (RN-10)',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Tarjeta 3: Modalidad de Siembra
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.diversity_3_rounded, color: ColoresAllpa.verdeBosque, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Modalidad de siembra',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ColoresAllpa.textoPrincipal),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    '¿Sembró de manera individual o hubo apoyo familiar?',
                    style: TextStyle(fontSize: 12.5, color: ColoresAllpa.textoSecundario),
                  ),
                  const SizedBox(height: 10),
                  RadioListTile<bool>(
                    contentPadding: EdgeInsets.zero,
                    activeColor: ColoresAllpa.verdeBosque,
                    title: const Text('Sí, individual (sin apoyo familiar)', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Trabajo exclusivo del productor titular', style: TextStyle(fontSize: 12, color: ColoresAllpa.textoSecundario)),
                    value: true,
                    groupValue: _individual,
                    onChanged: (valor) => setState(() => _individual = valor),
                  ),
                  const Divider(color: ColoresAllpa.divisor, height: 1),
                  RadioListTile<bool>(
                    contentPadding: EdgeInsets.zero,
                    activeColor: ColoresAllpa.verdeBosque,
                    title: const Text('No, hubo apoyo familiar', style: TextStyle(fontSize: 14.5, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Participaron miembros del hogar o ayni', style: TextStyle(fontSize: 12, color: ColoresAllpa.textoSecundario)),
                    value: false,
                    groupValue: _individual,
                    onChanged: (valor) => setState(() => _individual = valor),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Botón Guardar siembra
          FilledButton.icon(
            onPressed: _guardando ? null : _guardar,
            icon: _guardando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle_outline_rounded, size: 20),
            label: const Text('Guardar siembra'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _guardar() async {
    if (_individual == null) {
      avisar(context, 'Indique si la siembra es individual.', esError: true);
      return;
    }
    setState(() => _guardando = true);
    final campana = await guardar(
      context,
      () => widget.servicio.registrarSiembra(widget.campanaId, {
        'fecha_real': isoFecha(_fecha),
        'hectareas_sembradas': _hectareas.text.replaceAll(',', '.'),
        'kilogramos_semilla': _semilla.text.replaceAll(',', '.'),
        'jornales': _jornales.text.replaceAll(',', '.'),
        'individual': _individual,
      }),
    );
    if (!mounted) return;
    setState(() => _guardando = false);
    if (campana == null) return;
    Navigator.of(context).pop();
  }
}
