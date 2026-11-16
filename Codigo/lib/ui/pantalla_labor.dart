import 'dart:async';

import 'package:allpa/dominio/cultivos.dart';
import 'package:allpa/dominio/reglas.dart';
import 'package:allpa/servicios/bitacora_servicio.dart';
import 'package:allpa/ui/comun.dart';
import 'package:allpa/ui/tema.dart';
import 'package:flutter/material.dart';

class PantallaLabor extends StatefulWidget {
  final BitacoraServicio servicio;
  final String campanaId;

  const PantallaLabor({super.key, required this.servicio, required this.campanaId});

  @override
  State<PantallaLabor> createState() => _PantallaLaborState();
}

class _PantallaLaborState extends State<PantallaLabor> {
  final _nombre = TextEditingController();
  final _jornales = TextEditingController();
  DateTime? _fecha;
  final _reloj = Stopwatch();
  Timer? _timer;
  int _segundos = 0;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _reloj.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _segundos = _reloj.elapsed.inSeconds);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _nombre.dispose();
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
            'Registrar labor',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: ColoresAllpa.textoPrincipal,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Registro de actividades agrícolas y medición de tiempo de captura (RF-06 y RNF-02).',
            style: TextStyle(fontSize: 13, color: ColoresAllpa.textoSecundario),
          ),
          const SizedBox(height: 16),

          // Tarjeta del Cronómetro de Usabilidad (RNF-02)
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [ColoresAllpa.verdeSuperficie, Color(0xFFE2F2E8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: ColoresAllpa.verdeMentaSuave, width: 1.5),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: ColoresAllpa.verdeBosque.withOpacity(0.12),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.timer_outlined, color: ColoresAllpa.verdeBosque, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            '$_segundos s',
                            style: const TextStyle(
                              fontSize: 30,
                              fontWeight: FontWeight.w900,
                              color: ColoresAllpa.verdeBosque,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: ColoresAllpa.verdeBosque,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Cronómetro activo',
                              style: TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      const Text(
                        'RNF-02: Tiempo de registro de una labor en segundos. Demuestra la usabilidad ágil en campo.',
                        style: TextStyle(fontSize: 11.5, color: ColoresAllpa.textoSecundario, height: 1.3),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),

          // Tarjeta de Formulario de la Labor
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.handyman_outlined, color: ColoresAllpa.verdeBosque, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Datos de la Actividad',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: ColoresAllpa.textoPrincipal),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Selección rápida de labor habitual:',
                    style: TextStyle(fontSize: 12, color: ColoresAllpa.textoSecundario),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: [
                      for (final laborSugerida in laboresHabituales)
                        ActionChip(
                          label: Text(laborSugerida, style: const TextStyle(fontSize: 11.5, fontWeight: FontWeight.w600)),
                          backgroundColor: _nombre.text == laborSugerida ? ColoresAllpa.verdeMentaSuave : ColoresAllpa.fondoPapel,
                          side: BorderSide(
                            color: _nombre.text == laborSugerida ? ColoresAllpa.verdeBosque : ColoresAllpa.bordeTarjeta,
                          ),
                          onPressed: () {
                            setState(() => _nombre.text = laborSugerida);
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _nombre,
                    textCapitalization: TextCapitalization.sentences,
                    decoration: campo(
                      'Labor',
                      prefixIcon: const Icon(Icons.edit_note_rounded, color: ColoresAllpa.textoSecundario),
                      hintText: 'Ej. Deshierbo manual',
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
                                  'Fecha de la labor',
                                  style: TextStyle(fontSize: 12, color: ColoresAllpa.textoSecundario),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  _fecha == null ? 'Elegir fecha de la labor' : 'Fecha: ${isoFecha(_fecha)}',
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
                  const SizedBox(height: 12),
                  TextField(
                    controller: _jornales,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: campo(
                      'Jornales familiares',
                      prefixIcon: const Icon(Icons.people_outline_rounded, color: ColoresAllpa.textoSecundario),
                      suffixText: 'jornales',
                      hintText: 'Ej. 3 (RN-10)',
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 18),

          // Botón Guardar labor
          FilledButton.icon(
            onPressed: _guardando ? null : _guardar,
            icon: _guardando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                  )
                : const Icon(Icons.save_outlined, size: 20),
            label: const Text('Guardar labor'),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    final segundos = _reloj.elapsedMilliseconds / 1000;
    final campana = await guardar(
      context,
      () => widget.servicio.registrarLabor(widget.campanaId, {
        'nombre': _nombre.text,
        'fecha': isoFecha(_fecha),
        'jornales': _jornales.text.replaceAll(',', '.'),
        'segundos_registro': segundos,
      }),
    );
    if (!mounted) return;
    setState(() => _guardando = false);
    if (campana == null) return;
    Navigator.of(context).pop();
  }
}
