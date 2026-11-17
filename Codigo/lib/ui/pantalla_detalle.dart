import 'package:allpa/dominio/modelos.dart';
import 'package:allpa/dominio/reglas.dart';
import 'package:allpa/servicios/bitacora_servicio.dart';
import 'package:allpa/ui/comun.dart';
import 'package:allpa/ui/pantalla_cosecha.dart';
import 'package:allpa/ui/pantalla_ficha.dart';
import 'package:allpa/ui/pantalla_labor.dart';
import 'package:allpa/ui/pantalla_siembra.dart';
import 'package:allpa/ui/tema.dart';
import 'package:flutter/material.dart';

class PantallaDetalle extends StatefulWidget {
  final BitacoraServicio servicio;
  final String campanaId;

  const PantallaDetalle({super.key, required this.servicio, required this.campanaId});

  @override
  State<PantallaDetalle> createState() => _PantallaDetalleState();
}

class _PantallaDetalleState extends State<PantallaDetalle> {
  Campana? _campana;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final campana = await widget.servicio.consultar(widget.campanaId);
    if (!mounted) return;
    setState(() {
      _campana = campana;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final campana = _campana;

    return Cascaron(
      servicio: widget.servicio,
      alCambiarSenal: () => setState(() => widget.servicio.establecerSenal(!widget.servicio.haySenal)),
      cuerpo: _cargando || campana == null
          ? const Center(child: CircularProgressIndicator(color: ColoresAllpa.verdeBosque))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Tarjeta de la Parcela
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: ColoresAllpa.bordeTarjeta),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: ColoresAllpa.verdeSuperficie,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: ColoresAllpa.verdeMentaSuave),
                            ),
                            child: const Icon(Icons.terrain_rounded, color: ColoresAllpa.verdeBosque, size: 28),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  campana.nombreParcela,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: ColoresAllpa.textoPrincipal,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _meta(campana),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: ColoresAllpa.textoSecundario,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      // Estado de conectividad y origen
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: campana.sincronizado
                              ? ColoresAllpa.verdeSuperficie
                              : ColoresAllpa.tierraClara.withOpacity(0.6),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: campana.sincronizado ? ColoresAllpa.verdeMentaSuave : ColoresAllpa.tierraBarro.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              campana.sincronizado ? Icons.check_circle_outline_rounded : Icons.offline_pin_outlined,
                              size: 16,
                              color: campana.sincronizado ? ColoresAllpa.verdeMedio : ColoresAllpa.tierraBarro,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                campana.sincronizado
                                    ? 'Guardada en el dispositivo · respaldo local creado'
                                    : 'Guardada en el dispositivo · pendiente de respaldo local',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: campana.sincronizado ? ColoresAllpa.verdeOscuro : ColoresAllpa.tierraBarro,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Sección: Las Siete Funciones de Campaña (RNF-01)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.checklist_rounded, color: ColoresAllpa.verdeBosque, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Siete funciones de campaña',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: ColoresAllpa.textoPrincipal,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Contrato funcional del aplicativo móvil según el Capítulo III y V de la tesis.',
                          style: TextStyle(fontSize: 12, color: ColoresAllpa.textoSecundario),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final f in _funciones(campana))
                              _PildoraFuncion(nombre: f.$1, completada: f.$2),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 18),

                // Botones de Registro de Etapas de Campaña
                if (campana.siembra == null) ...[
                  FilledButton.icon(
                    onPressed: () => _abrir(PantallaSiembra(servicio: widget.servicio, campanaId: campana.id)),
                    icon: const Icon(Icons.eco_rounded, size: 20),
                    label: const Text('Registrar siembra (RF-04 / RF-05)'),
                  ),
                  const SizedBox(height: 10),
                ],

                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: campana.siembra == null ? ColoresAllpa.verdeMedio : ColoresAllpa.verdeBosque,
                  ),
                  onPressed: () => _abrir(PantallaLabor(servicio: widget.servicio, campanaId: campana.id)),
                  icon: const Icon(Icons.timer_outlined, size: 20),
                  label: const Text('Registrar labor (RF-06)'),
                ),
                const SizedBox(height: 10),

                if (campana.siembra != null && campana.cosecha == null) ...[
                  FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: ColoresAllpa.doradoOscuro),
                    onPressed: () => _abrir(PantallaCosecha(servicio: widget.servicio, campanaId: campana.id)),
                    icon: const Icon(Icons.agriculture_rounded, size: 20),
                    label: const Text('Registrar cosecha (RF-07)'),
                  ),
                  const SizedBox(height: 10),
                ],

                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PantallaFicha(servicio: widget.servicio, campanaId: campana.id),
                      ),
                    );
                  },
                  icon: const Icon(Icons.analytics_outlined, size: 20),
                  label: const Text('Ver ficha de indicadores (RF-08 / RF-12)'),
                ),
                const SizedBox(height: 18),

                // Labores registradas
                if (campana.labores.isNotEmpty) ...[
                  Row(
                    children: [
                      const Icon(Icons.work_history_outlined, size: 18, color: ColoresAllpa.verdeBosque),
                      const SizedBox(width: 8),
                      const Text(
                        'Labores registradas',
                        style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: ColoresAllpa.textoPrincipal),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: ColoresAllpa.verdeSuperficie,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          '${campana.labores.length}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: ColoresAllpa.verdeBosque,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  for (final labor in campana.labores) ...[
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        child: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: ColoresAllpa.trigoSuave,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.handyman_rounded, size: 18, color: ColoresAllpa.doradoOscuro),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    labor.nombre,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w700,
                                      color: ColoresAllpa.textoPrincipal,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${isoFecha(labor.fecha)} · ${labor.jornales} jornal(es)',
                                    style: const TextStyle(fontSize: 12.5, color: ColoresAllpa.textoSecundario),
                                  ),
                                ],
                              ),
                            ),
                            if (labor.segundosRegistro != null)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: ColoresAllpa.verdeSuperficie,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: ColoresAllpa.verdeMentaSuave),
                                ),
                                child: Text(
                                  '⏱️ ${labor.segundosRegistro} s',
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: ColoresAllpa.verdeOscuro,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
                const SizedBox(height: 16),
              ],
            ),
    );
  }

  List<(String, bool)> _funciones(Campana campana) {
    final planOk = planEscrito(campana.plan);
    final siembraOk = campana.siembra != null;
    final laborOk = campana.labores.isNotEmpty;
    final insumoOk = (campana.siembra?.kilogramosSemilla ?? 0) > 0;
    final cosechaOk = campana.cosecha != null;
    return [
      ('parcela', true),
      ('plan', planOk),
      ('siembra', siembraOk),
      ('labor', laborOk),
      ('insumo', insumoOk),
      ('consulta', true),
      ('cosecha', cosechaOk),
    ];
  }

  String _meta(Campana campana) {
    final partes = <String>[
      etiquetaCultivo(campana.plan.cultivo).isEmpty ? 'Sin cultivo' : etiquetaCultivo(campana.plan.cultivo),
      '${campana.hectareasDisponibles} ha disponibles',
      if (campana.pisoEcologico.isNotEmpty) 'Piso ${campana.pisoEcologico}',
    ];
    final desfase = desfaseSiembraDias(campana.plan.fechaSiembraPrevista, campana.siembra?.fechaReal);
    if (desfase != null) partes.add('desfase $desfase días');
    return partes.join(' · ');
  }

  Future<void> _abrir(Widget pantalla) async {
    await Navigator.of(context).push(MaterialPageRoute(builder: (_) => pantalla));
    await _cargar();
  }
}

class _PildoraFuncion extends StatelessWidget {
  final String nombre;
  final bool completada;

  const _PildoraFuncion({required this.nombre, required this.completada});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: completada ? ColoresAllpa.verdeMentaSuave : const Color(0xFFF0EBE3),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: completada ? ColoresAllpa.verdeClaro.withOpacity(0.5) : const Color(0xFFDDD6CB),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            completada ? Icons.check_circle_rounded : Icons.radio_button_unchecked_rounded,
            size: 15,
            color: completada ? ColoresAllpa.verdeBosque : ColoresAllpa.textoAtenuado,
          ),
          const SizedBox(width: 6),
          Text(
            nombre.toUpperCase(),
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.3,
              color: completada ? ColoresAllpa.verdeBosque : ColoresAllpa.textoSecundario,
            ),
          ),
        ],
      ),
    );
  }
}
