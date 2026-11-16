import 'package:allpa/dominio/aceptacion.dart';
import 'package:allpa/servicios/bitacora_servicio.dart';
import 'package:allpa/ui/comun.dart';
import 'package:allpa/ui/tema.dart';
import 'package:flutter/material.dart';

/// Pantalla de sustentación: contraste con Tabla 21 del Capítulo V de la tesis.
class PantallaVerificacion extends StatefulWidget {
  final BitacoraServicio servicio;
  final String codigo;

  const PantallaVerificacion({super.key, required this.servicio, required this.codigo});

  @override
  State<PantallaVerificacion> createState() => _PantallaVerificacionState();
}

class _PantallaVerificacionState extends State<PantallaVerificacion> {
  List<CriterioAceptacion> _criterios = [];
  Map<String, int> _tablas = {};
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final gestion = await widget.servicio.fichaUnidad(widget.codigo);
    final app = await widget.servicio.calidad();
    final tablas = await widget.servicio.repo.conteoTablas();
    if (!mounted) return;
    setState(() {
      _criterios = criteriosUpIll001(
        gestion: gestion,
        app: app,
        cantidadTablas: tablas.length,
      );
      _tablas = tablas;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ok = _criterios.where((c) => c.cumple).length;
    final total = _criterios.length;
    final todosCumplen = total > 0 && ok == total;

    return Cascaron(
      servicio: widget.servicio,
      alCambiarSenal: () => setState(() => widget.servicio.establecerSenal(!widget.servicio.haySenal)),
      cuerpo: _cargando
          ? const Center(child: CircularProgressIndicator(color: ColoresAllpa.verdeBosque))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Banner Hero de Sustentación
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: todosCumplen
                          ? [ColoresAllpa.verdeBosque, ColoresAllpa.verdeOscuro]
                          : [ColoresAllpa.tierraBarro, const Color(0xFF6B2618)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: (todosCumplen ? ColoresAllpa.verdeBosque : ColoresAllpa.tierraBarro).withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.18),
                              shape: BoxShape.circle,
                              border: Border.all(color: ColoresAllpa.doradoClaro, width: 1.5),
                            ),
                            child: const Icon(Icons.verified_rounded, size: 28, color: ColoresAllpa.doradoClaro),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Verificación UP-ILL-001',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  todosCumplen ? 'Aceptación 100% Conforme a Tesis' : 'Verificación de Criterios',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: ColoresAllpa.doradoClaro,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      const Text(
                        'Criterios de aceptación del Capítulo V (Tabla 21) frente a los valores calculados por Allpa.',
                        style: TextStyle(fontSize: 12.5, color: Colors.white70, height: 1.35),
                      ),
                      const SizedBox(height: 14),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: ColoresAllpa.doradoClaro.withOpacity(0.5)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              todosCumplen ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                              size: 18,
                              color: ColoresAllpa.doradoClaro,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '$ok / $total criterios cumplidos',
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),

                // Lista de Criterios de Aceptación
                const Text(
                  'Matriz de Criterios de Aceptación',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: ColoresAllpa.textoPrincipal),
                ),
                const SizedBox(height: 10),

                for (final c in _criterios) ...[
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            c.cumple ? Icons.check_circle_rounded : Icons.cancel_rounded,
                            color: c.cumple ? ColoresAllpa.verdeMedio : ColoresAllpa.tierraBarro,
                            size: 24,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.indicador,
                                  style: const TextStyle(
                                    fontSize: 14.5,
                                    fontWeight: FontWeight.w700,
                                    color: ColoresAllpa.textoPrincipal,
                                  ),
                                ),
                                const SizedBox(height: 3),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Esperado: ${c.esperado}',
                                        style: const TextStyle(fontSize: 12, color: ColoresAllpa.textoSecundario),
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        'Obtenido: ${c.obtenido}',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: c.cumple ? ColoresAllpa.verdeBosque : ColoresAllpa.tierraBarro,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: c.cumple ? ColoresAllpa.verdeSuperficie : ColoresAllpa.tierraClara,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: c.cumple ? ColoresAllpa.verdeMentaSuave : ColoresAllpa.tierraBarro.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              c.cumple ? 'CUMPLE' : 'REVISAR',
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: c.cumple ? ColoresAllpa.verdeOscuro : ColoresAllpa.tierraBarro,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                ],

                const SizedBox(height: 16),

                // Sección SQLite 22 Tablas
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.table_chart_outlined, color: ColoresAllpa.verdeBosque, size: 20),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Base SQLite (22 tablas)',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ColoresAllpa.textoPrincipal),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: ColoresAllpa.verdeSuperficie,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                '${_tablas.length} verificadas',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: ColoresAllpa.verdeBosque),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Esquema versión 2 verificado con claves foráneas activadas (PRAGMA foreign_keys = ON).',
                          style: TextStyle(fontSize: 12, color: ColoresAllpa.textoSecundario),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: ColoresAllpa.divisor, height: 1),
                        const SizedBox(height: 8),
                        for (final e in _tablas.entries)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.circle, size: 6, color: ColoresAllpa.verdeMedio),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    e.key,
                                    style: const TextStyle(fontSize: 13, color: ColoresAllpa.textoPrincipal),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: ColoresAllpa.fondoPapel,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${e.value}',
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: ColoresAllpa.textoPrincipal),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }
}
