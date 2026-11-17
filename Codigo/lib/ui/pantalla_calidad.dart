import 'package:allpa/dominio/cultivos.dart';
import 'package:allpa/dominio/modelos.dart';
import 'package:allpa/servicios/bitacora_servicio.dart';
import 'package:allpa/ui/comun.dart';
import 'package:allpa/ui/fila_calidad.dart';
import 'package:allpa/ui/tema.dart';
import 'package:flutter/material.dart';

class PantallaCalidad extends StatefulWidget {
  final BitacoraServicio servicio;

  const PantallaCalidad({super.key, required this.servicio});

  @override
  State<PantallaCalidad> createState() => _PantallaCalidadState();
}

class _PantallaCalidadState extends State<PantallaCalidad> {
  FichaAplicativo? _ficha;
  Map<String, int>? _tablas;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final ficha = await widget.servicio.calidad();
    final tablas = await widget.servicio.repo.conteoTablas();
    if (!mounted) return;
    setState(() {
      _ficha = ficha;
      _tablas = tablas;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ficha = _ficha;
    final tablas = _tablas;

    return Cascaron(
      servicio: widget.servicio,
      alCambiarSenal: () => setState(() => widget.servicio.establecerSenal(!widget.servicio.haySenal)),
      cuerpo: _cargando || ficha == null || tablas == null
          ? const Center(child: CircularProgressIndicator(color: ColoresAllpa.verdeBosque))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Cabecera de la Pantalla de Calidad
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [ColoresAllpa.verdeBosque, ColoresAllpa.verdeOscuro],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: ColoresAllpa.verdeBosque.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.15),
                          shape: BoxShape.circle,
                          border: Border.all(color: ColoresAllpa.doradoClaro, width: 1.5),
                        ),
                        child: const Icon(Icons.speed_rounded, color: ColoresAllpa.doradoClaro, size: 28),
                      ),
                      const SizedBox(width: 14),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pruebas del aplicativo',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                            SizedBox(height: 3),
                            Text(
                              'Variable Independiente: Calidad del Software',
                              style: TextStyle(fontSize: 13, color: ColoresAllpa.doradoClaro, fontWeight: FontWeight.w600),
                            ),
                            SizedBox(height: 2),
                            Text(
                              'Funcionalidad, usabilidad y confiabilidad offline (Cap. IV y V).',
                              style: TextStyle(fontSize: 11.5, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Dimensión 1: Funcionalidad (RNF-01)
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
                              'Funcionalidad (RNF-01)',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ColoresAllpa.textoPrincipal),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FilaCalidad(
                          titulo: 'Cobertura de funciones',
                          valor: '${ficha.coberturaFuncionesPct} %',
                          esDestacado: true,
                          colorDestacado: ColoresAllpa.verdeMedio,
                        ),
                        FilaCalidad(
                          titulo: 'Funciones cubiertas',
                          valor: _funciones(ficha.funcionesCubiertas),
                        ),
                        FilaCalidad(
                          titulo: 'Registros de parcela',
                          valor: '${ficha.registrosParcelaGuardados}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Dimensión 2: Usabilidad (RNF-02)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.touch_app_outlined, color: ColoresAllpa.doradoOscuro, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Usabilidad (RNF-02)',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ColoresAllpa.textoPrincipal),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FilaCalidad(
                          titulo: 'Tareas de bitácora',
                          valor: ficha.tareasBitacoraCompletadasPct == null
                              ? 'sin intentos'
                              : '${ficha.tareasBitacoraCompletadasPct} %',
                          esDestacado: ficha.tareasBitacoraCompletadasPct != null,
                          colorDestacado: ColoresAllpa.verdeMedio,
                        ),
                        FilaCalidad(
                          titulo: 'Tiempo de registro de una labor',
                          valor: ficha.tiempoRegistroLaborSegundos == null
                              ? 'sin medición'
                              : '${ficha.tiempoRegistroLaborSegundos} segundos',
                          esDestacado: ficha.tiempoRegistroLaborSegundos != null,
                          colorDestacado: ColoresAllpa.doradoOscuro,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // Dimensión 3: Confiabilidad (RNF-03)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.security_outlined, color: ColoresAllpa.tierraBarro, size: 20),
                            SizedBox(width: 8),
                            Text(
                              'Confiabilidad (RNF-03)',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ColoresAllpa.textoPrincipal),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        FilaCalidad(
                          titulo: 'Disponibilidad sin señal',
                          valor: ficha.disponibilidadSinSenalPct == null
                              ? 'sin intentos sin señal'
                              : '${ficha.disponibilidadSinSenalPct} %',
                          esDestacado: ficha.disponibilidadSinSenalPct != null,
                          colorDestacado: ColoresAllpa.verdeMedio,
                        ),
                        FilaCalidad(
                          titulo: 'Fallos de operación',
                          valor: '${ficha.fallosOperacion}',
                          esDestacado: true,
                          colorDestacado: ficha.fallosOperacion == 0 ? ColoresAllpa.verdeMedio : ColoresAllpa.tierraBarro,
                        ),
                        FilaCalidad(
                          titulo: 'Rechazos de regla',
                          valor: '${ficha.rechazosDeRegla}',
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Sección: Base de Datos SQLite (22 Tablas del Diccionario)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.table_chart_rounded, color: ColoresAllpa.verdeBosque, size: 20),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Base de datos local (SQLite)',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: ColoresAllpa.textoPrincipal),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: ColoresAllpa.verdeSuperficie,
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: ColoresAllpa.verdeMentaSuave),
                              ),
                              child: Text(
                                '${tablas.length} tablas (v2)',
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: ColoresAllpa.verdeOscuro),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Diccionario de datos de la tesis con integridad referencial activa (Capítulo III y V).',
                          style: TextStyle(fontSize: 12, color: ColoresAllpa.textoSecundario),
                        ),
                        const SizedBox(height: 12),
                        const Divider(color: ColoresAllpa.divisor, height: 1),
                        const SizedBox(height: 8),
                        for (final e in tablas.entries)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                const Icon(Icons.storage_rounded, size: 14, color: ColoresAllpa.textoAtenuado),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Tabla ${e.key}',
                                    style: const TextStyle(fontSize: 13, color: ColoresAllpa.textoPrincipal),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                  decoration: BoxDecoration(
                                    color: ColoresAllpa.fondoPapel,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    '${e.value} registro(s)',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: ColoresAllpa.textoSecundario,
                                    ),
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

  String _funciones(List<String> cubiertas) {
    if (cubiertas.isEmpty) return 'ninguna todavía';
    final nombres = {
      'parcela': 'parcela',
      'plan': 'plan',
      'siembra': 'siembra',
      'labor': 'labor',
      'insumo': 'insumo',
      'consulta': 'consulta',
      'cosecha': 'cosecha',
    };
    final orden = [
      for (final funcion in funcionesCampana)
        if (cubiertas.contains(funcion)) nombres[funcion] ?? funcion,
    ];
    return orden.join(', ');
  }
}
