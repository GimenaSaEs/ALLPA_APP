import 'package:allpa/dominio/modelos.dart';
import 'package:allpa/servicios/bitacora_servicio.dart';
import 'package:allpa/ui/comun.dart';
import 'package:allpa/ui/tema.dart';
import 'package:flutter/material.dart';

class PantallaFicha extends StatefulWidget {
  final BitacoraServicio servicio;
  final String campanaId;

  const PantallaFicha({super.key, required this.servicio, required this.campanaId});

  @override
  State<PantallaFicha> createState() => _PantallaFichaState();
}

class _PantallaFichaState extends State<PantallaFicha> {
  FichaGestion? _ficha;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final ficha = await widget.servicio.fichaCampana(widget.campanaId);
    if (!mounted) return;
    setState(() {
      _ficha = ficha;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ficha = _ficha;

    return Cascaron(
      servicio: widget.servicio,
      alCambiarSenal: () => setState(() => widget.servicio.establecerSenal(!widget.servicio.haySenal)),
      cuerpo: _cargando || ficha == null
          ? const Center(child: CircularProgressIndicator(color: ColoresAllpa.verdeBosque))
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Cabecera de la Ficha
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
                        child: const Icon(Icons.analytics_rounded, color: ColoresAllpa.doradoClaro, size: 28),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ficha de la chacra',
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              ficha.cultivos.isEmpty ? 'Sin cultivo definido' : ficha.cultivos,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: ColoresAllpa.doradoClaro,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Unidad ${ficha.codigoUnidad} · ${ficha.campanas} campaña(s)',
                              style: const TextStyle(fontSize: 12, color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Dimensión 1: Manejo agronómico (OE1 / VD)
                _BloqueDimension(
                  titulo: 'Manejo agronómico (VD)',
                  subtitulo: 'Objetivo Específico 1: Plan escrito, desfase y registros completos',
                  icono: Icons.eco_rounded,
                  colorCabecera: ColoresAllpa.verdeBosque,
                  colorFondo: ColoresAllpa.verdeSuperficie,
                  filas: [
                    _FilaMetrica(
                      nombre: 'Plan escrito',
                      valor: ficha.planEscritoTexto,
                      esDestacado: true,
                      colorDestacado: ficha.planEscrito == true ? ColoresAllpa.verdeMedio : ColoresAllpa.tierraBarro,
                    ),
                    _FilaMetrica(
                      nombre: 'Desfase de siembra',
                      valor: _dias(ficha.diasDesfaseSiembra),
                      esDestacado: ficha.diasDesfaseSiembra != null,
                      colorDestacado: ColoresAllpa.doradoOscuro,
                    ),
                    _FilaMetrica(
                      nombre: 'Registros completos',
                      valor: '${ficha.porcentajeRegistrosAgronomicosCompletos} %',
                      esDestacado: true,
                      colorDestacado: ColoresAllpa.verdeMedio,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Dimensión 2: Eficiencia y utilización de recursos (OE2 / VD)
                _BloqueDimension(
                  titulo: 'Eficiencia y utilización de recursos (VD)',
                  subtitulo: 'Objetivo Específico 2: Superficie sembrada, semilla y jornales',
                  icono: Icons.inventory_2_outlined,
                  colorCabecera: ColoresAllpa.doradoOscuro,
                  colorFondo: ColoresAllpa.trigoSuave,
                  filas: [
                    _FilaMetrica(nombre: 'Superficie disponible', valor: '${ficha.hectareasDisponibles} ha'),
                    _FilaMetrica(nombre: 'Superficie sembrada', valor: '${ficha.hectareasSembradas} ha'),
                    _FilaMetrica(
                      nombre: '% superficie sembrada',
                      valor: _pct(ficha.porcentajeSuperficieSembrada),
                      esDestacado: true,
                      colorDestacado: ColoresAllpa.doradoOscuro,
                    ),
                    _FilaMetrica(nombre: 'Semilla total', valor: '${ficha.kilogramosSemilla} kg'),
                    _FilaMetrica(
                      nombre: 'Semilla por hectárea',
                      valor: ficha.kilogramosSemillaPorHectarea == null
                          ? 'sin dato'
                          : '${ficha.kilogramosSemillaPorHectarea} kg/ha',
                      esDestacado: ficha.kilogramosSemillaPorHectarea != null,
                      colorDestacado: ColoresAllpa.verdeMedio,
                    ),
                    _FilaMetrica(nombre: 'Siembra individual', valor: ficha.siembraIndividualTexto),
                    _FilaMetrica(
                      nombre: 'Jornales familiares',
                      valor: '${ficha.jornalesFamiliares}',
                      esDestacado: true,
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Dimensión 3: Rendimiento y producción de cosecha (OE3 / VD)
                _BloqueDimension(
                  titulo: 'Rendimiento y producción de cosecha (VD)',
                  subtitulo: 'Objetivo Específico 3: Rendimiento en kg/ha y productividad en kg/jornal',
                  icono: Icons.agriculture_rounded,
                  colorCabecera: ColoresAllpa.tierraBarro,
                  colorFondo: ColoresAllpa.tierraClara,
                  filas: [
                    _FilaMetrica(
                      nombre: 'Rendimiento',
                      valor: ficha.rendimientoKgHa == null ? 'sin cosecha' : '${ficha.rendimientoKgHa} kg/ha',
                      esDestacado: ficha.rendimientoKgHa != null,
                      colorDestacado: ColoresAllpa.verdeMedio,
                    ),
                    _FilaMetrica(
                      nombre: 'Producción',
                      valor: ficha.produccionTotalKg == null ? 'sin cosecha' : '${ficha.produccionTotalKg} kg',
                    ),
                    _FilaMetrica(
                      nombre: 'Superficie cosechada',
                      valor: ficha.superficieCosechadaHa == null ? 'sin cosecha' : '${ficha.superficieCosechadaHa} ha',
                    ),
                    _FilaMetrica(
                      nombre: 'Productividad',
                      valor: ficha.productividadKgJornal == null
                          ? 'sin dato'
                          : '${ficha.productividadKgJornal} kg/jornal',
                      esDestacado: ficha.productividadKgJornal != null,
                      colorDestacado: ColoresAllpa.doradoOscuro,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
              ],
            ),
    );
  }

  String _dias(int? valor) {
    if (valor == null) return 'sin dato';
    if (valor < 0) return '$valor días (se adelantó)';
    return '$valor días';
  }

  String _pct(double? valor) {
    if (valor == null) return 'sin dato';
    return '$valor %';
  }
}

class _BloqueDimension extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final IconData icono;
  final Color colorCabecera;
  final Color colorFondo;
  final List<_FilaMetrica> filas;

  const _BloqueDimension({
    required this.titulo,
    required this.subtitulo,
    required this.icono,
    required this.colorCabecera,
    required this.colorFondo,
    required this.filas,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: colorFondo,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icono, size: 18, color: colorCabecera),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: colorCabecera),
                      ),
                      Text(
                        subtitulo,
                        style: const TextStyle(fontSize: 11, color: ColoresAllpa.textoSecundario),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Divider(color: ColoresAllpa.divisor, height: 1),
            const SizedBox(height: 8),
            for (final f in filas) f,
          ],
        ),
      ),
    );
  }
}

class _FilaMetrica extends StatelessWidget {
  final String nombre;
  final String valor;
  final bool esDestacado;
  final Color? colorDestacado;

  const _FilaMetrica({
    required this.nombre,
    required this.valor,
    this.esDestacado = false,
    this.colorDestacado,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(
              nombre,
              style: const TextStyle(fontSize: 13.5, color: ColoresAllpa.textoPrincipal),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            padding: esDestacado ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3) : EdgeInsets.zero,
            decoration: esDestacado
                ? BoxDecoration(
                    color: (colorDestacado ?? ColoresAllpa.verdeMedio).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  )
                : null,
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: TextStyle(
                fontSize: esDestacado ? 14 : 13.5,
                fontWeight: FontWeight.w700,
                color: esDestacado ? (colorDestacado ?? ColoresAllpa.verdeBosque) : ColoresAllpa.textoPrincipal,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
