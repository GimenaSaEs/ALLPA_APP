import 'package:allpa/dominio/cultivos.dart';
import 'package:allpa/dominio/reglas.dart';
import 'package:allpa/servicios/bitacora_servicio.dart';
import 'package:allpa/ui/comun.dart';
import 'package:allpa/ui/tema.dart';
import 'package:flutter/material.dart';

class PantallaNueva extends StatefulWidget {
  final BitacoraServicio servicio;
  final String codigo;

  const PantallaNueva({super.key, required this.servicio, required this.codigo});

  @override
  State<PantallaNueva> createState() => _PantallaNuevaState();
}

class _PantallaNuevaState extends State<PantallaNueva> {
  final _nombre = TextEditingController();
  final _disponibles = TextEditingController();
  final _previstas = TextEditingController();
  String _piso = '';
  String _cultivo = '';
  DateTime? _fecha;
  final _labores = <String>{};
  bool _guardando = false;

  @override
  void dispose() {
    _nombre.dispose();
    _disponibles.dispose();
    _previstas.dispose();
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
            'Nueva chacra',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: ColoresAllpa.textoPrincipal,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Registro de la parcela y formulación del plan escrito de campaña (RF-02 y RF-03).',
            style: TextStyle(fontSize: 13, color: ColoresAllpa.textoSecundario),
          ),
          const SizedBox(height: 16),

          // Sección 1: Datos de la Parcela (RF-02)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.terrain_rounded, color: ColoresAllpa.verdeBosque, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '1. Datos de la Parcela (RF-02)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ColoresAllpa.textoPrincipal),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _nombre,
                    textCapitalization: TextCapitalization.words,
                    decoration: campo(
                      'Nombre de la parcela',
                      prefixIcon: const Icon(Icons.landscape_outlined, color: ColoresAllpa.textoSecundario),
                      hintText: 'Ej. Pampa de Illpe',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _disponibles,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: campo(
                      'Hectáreas disponibles',
                      prefixIcon: const Icon(Icons.square_foot_rounded, color: ColoresAllpa.textoSecundario),
                      suffixText: 'ha',
                      hintText: 'Ej. 2.0',
                    ),
                  ),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    initialValue: _piso,
                    decoration: campo(
                      'Piso ecológico',
                      prefixIcon: const Icon(Icons.filter_hdr_outlined, color: ColoresAllpa.textoSecundario),
                    ),
                    items: const [
                      DropdownMenuItem(value: '', child: Text('Sin precisar')),
                      DropdownMenuItem(value: 'valle', child: Text('Valle')),
                      DropdownMenuItem(value: 'quechua', child: Text('Quechua')),
                      DropdownMenuItem(value: 'suni', child: Text('Suni')),
                      DropdownMenuItem(value: 'puna', child: Text('Puna')),
                    ],
                    onChanged: (valor) => setState(() => _piso = valor ?? ''),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Sección 2: Plan de Siembra (RF-03 / RN-02 / RN-07)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.assignment_outlined, color: ColoresAllpa.verdeBosque, size: 20),
                      SizedBox(width: 8),
                      Text(
                        '2. Plan Escrito de Campaña (RF-03)',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ColoresAllpa.textoPrincipal),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'RN-07: Un plan escrito requiere cultivo, hectáreas previstas, fecha y al menos una labor.',
                    style: TextStyle(fontSize: 12, color: ColoresAllpa.textoSecundario),
                  ),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    initialValue: _cultivo,
                    decoration: campo(
                      'Cultivo',
                      prefixIcon: const Icon(Icons.eco_outlined, color: ColoresAllpa.textoSecundario),
                    ),
                    items: [
                      const DropdownMenuItem(value: '', child: Text('Todavía sin definir')),
                      for (final entrada in cultivos.entries)
                        DropdownMenuItem(value: entrada.key, child: Text(entrada.value)),
                    ],
                    onChanged: (valor) => setState(() => _cultivo = valor ?? ''),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _previstas,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: campo(
                      'Hectáreas que piensa sembrar',
                      prefixIcon: const Icon(Icons.straighten_rounded, color: ColoresAllpa.textoSecundario),
                      suffixText: 'ha',
                      hintText: 'Ej. 1.2 (RN-03)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  InkWell(
                    onTap: () => elegirFecha(context, _fecha, (fecha) => setState(() => _fecha = fecha)),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: ColoresAllpa.bordeTarjeta),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded, color: ColoresAllpa.verdeBosque, size: 22),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Fecha prevista de siembra',
                                  style: TextStyle(fontSize: 12, color: ColoresAllpa.textoSecundario),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _fecha == null ? 'Seleccionar fecha prevista' : 'Siembra prevista: ${isoFecha(_fecha)}',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: _fecha == null ? FontWeight.normal : FontWeight.w700,
                                    color: _fecha == null ? ColoresAllpa.textoAtenuado : ColoresAllpa.textoPrincipal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down, color: ColoresAllpa.textoSecundario),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Sección 3: Labores Planificadas
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.work_outline_rounded, color: ColoresAllpa.verdeBosque, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        '3. Labores que piensa hacer',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ColoresAllpa.textoPrincipal),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: ColoresAllpa.verdeSuperficie,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${_labores.length} elegida(s)',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: ColoresAllpa.verdeBosque,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Seleccione las actividades programadas para la campaña agrícola:',
                    style: TextStyle(fontSize: 12, color: ColoresAllpa.textoSecundario),
                  ),
                  const SizedBox(height: 10),
                  for (final labor in laboresHabituales)
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(labor, style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w500)),
                      activeColor: ColoresAllpa.verdeBosque,
                      value: _labores.contains(labor),
                      onChanged: (marca) {
                        setState(() {
                          if (marca == true) {
                            _labores.add(labor);
                          } else {
                            _labores.remove(labor);
                          }
                        });
                      },
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Botón Guardar chacra
          FilledButton.icon(
            onPressed: _guardando ? null : _guardar,
            icon: _guardando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.check_circle_outline_rounded, size: 20),
            label: const Text('Guardar chacra'),
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
      () => widget.servicio.crearCampana({
        'codigo_unidad': widget.codigo,
        'nombre_parcela': _nombre.text,
        'hectareas_disponibles': _disponibles.text.replaceAll(',', '.'),
        'piso_ecologico': _piso,
        'cultivo': _cultivo,
        'hectareas_previstas': _previstas.text.replaceAll(',', '.'),
        'fecha_siembra_prevista': isoFecha(_fecha),
        'labores_planificadas': _labores.toList(),
      }),
    );
    if (!mounted) return;
    setState(() => _guardando = false);
    if (campana == null) return;
    Navigator.of(context).pop(true);
  }
}
