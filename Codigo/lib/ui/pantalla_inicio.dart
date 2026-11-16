import 'package:allpa/dominio/modelos.dart';
import 'package:allpa/dominio/reglas.dart';
import 'package:allpa/servicios/bitacora_servicio.dart';
import 'package:allpa/ui/comun.dart';
import 'package:allpa/ui/pantalla_calidad.dart';
import 'package:allpa/ui/pantalla_detalle.dart';
import 'package:allpa/ui/pantalla_nueva.dart';
import 'package:allpa/ui/pantalla_verificacion.dart';
import 'package:allpa/ui/tema.dart';
import 'package:flutter/material.dart';

class PantallaInicio extends StatefulWidget {
  final BitacoraServicio servicio;
  final String codigo;
  final String nombre;

  const PantallaInicio({
    super.key,
    required this.servicio,
    required this.codigo,
    required this.nombre,
  });

  @override
  State<PantallaInicio> createState() => _PantallaInicioState();
}

class _PantallaInicioState extends State<PantallaInicio> {
  FichaGestion? _ficha;
  List<Campana> _campanas = [];
  bool _cargando = true;
  bool _sincronizando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    final campanas = await widget.servicio.listar(widget.codigo);
    final ficha = await widget.servicio.fichaUnidad(widget.codigo);
    if (!mounted) return;
    setState(() {
      _campanas = campanas;
      _ficha = ficha;
      _cargando = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final ficha = _ficha;
    final totalPendientes = _campanas.where((c) => !c.sincronizado).length;

    return Cascaron(
      servicio: widget.servicio,
      raiz: true,
      alCambiarSenal: () => setState(() => widget.servicio.establecerSenal(!widget.servicio.haySenal)),
      cuerpo: _cargando
          ? const Center(
              child: CircularProgressIndicator(color: ColoresAllpa.verdeBosque),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              children: [
                // Cabecera del Productor y Unidad Productiva
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
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: ColoresAllpa.verdeSuperficie,
                              shape: BoxShape.circle,
                              border: Border.all(color: ColoresAllpa.verdeMentaSuave, width: 1.5),
                            ),
                            child: const Icon(Icons.person_rounded, color: ColoresAllpa.verdeBosque, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  widget.nombre.isEmpty ? 'Mis chacras' : widget.nombre,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800,
                                    color: ColoresAllpa.textoPrincipal,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: ColoresAllpa.doradoClaro,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        widget.codigo,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: ColoresAllpa.doradoOscuro,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      '${_campanas.length} chacra(s)',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: ColoresAllpa.textoSecundario,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(color: ColoresAllpa.divisor, height: 1),
                      const SizedBox(height: 10),
                      // Estado de sincronización local
                      Row(
                        children: [
                          Icon(
                            totalPendientes == 0 ? Icons.cloud_done_rounded : Icons.cloud_queue_rounded,
                            size: 16,
                            color: totalPendientes == 0 ? ColoresAllpa.verdeMedio : ColoresAllpa.tierraBarro,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              totalPendientes == 0
                                  ? 'Todos los registros están respaldados'
                                  : '$totalPendientes chacra(s) pendiente(s) de respaldo JSON',
                              style: TextStyle(
                                fontSize: 12,
                                color: totalPendientes == 0 ? ColoresAllpa.verdeMedio : ColoresAllpa.tierraBarro,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Fila de Indicadores Rápidos (KPIs)
                if (ficha != null && ficha.campanas > 0) ...[
                  Row(
                    children: [
                      Expanded(
                        child: _TarjetaMetrica(
                          titulo: 'Chacras',
                          valor: '${ficha.campanas}',
                          subtitulo: '${ficha.hectareasDisponibles} ha totales',
                          icono: Icons.terrain_rounded,
                          colorFondo: ColoresAllpa.verdeSuperficie,
                          colorIcono: ColoresAllpa.verdeMedio,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _TarjetaMetrica(
                          titulo: 'Sembrado',
                          valor: '${ficha.porcentajeSuperficieSembrada ?? 0} %',
                          subtitulo: '${ficha.hectareasSembradas} ha sembradas',
                          icono: Icons.pie_chart_outline_rounded,
                          colorFondo: ColoresAllpa.trigoSuave,
                          colorIcono: ColoresAllpa.doradoOscuro,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _TarjetaMetrica(
                          titulo: 'Plan escrito',
                          valor: ficha.planEscritoTexto,
                          subtitulo: ficha.planEscrito == true ? 'Completo' : 'Pendiente',
                          icono: Icons.assignment_turned_in_rounded,
                          colorFondo: ficha.planEscrito == true ? ColoresAllpa.verdeSuperficie : ColoresAllpa.tierraClara,
                          colorIcono: ficha.planEscrito == true ? ColoresAllpa.verdeMedio : ColoresAllpa.tierraBarro,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],

                // Sección Lista de Chacras
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mis Chacras',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: ColoresAllpa.textoPrincipal,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: ColoresAllpa.verdeSuperficie,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: ColoresAllpa.verdeMentaSuave),
                      ),
                      child: Text(
                        '${_campanas.length} registradas',
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

                if (_campanas.isEmpty)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Icon(Icons.grass_rounded, size: 48, color: ColoresAllpa.textoAtenuado.withOpacity(0.5)),
                          const SizedBox(height: 12),
                          const Text(
                            'Todavía no hay chacras guardadas con este código.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 14, color: ColoresAllpa.textoSecundario),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Presione "Nueva chacra" para registrar una o use "Cargar ejemplo de Illpe" desde el ingreso.',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 12, color: ColoresAllpa.textoAtenuado),
                          ),
                        ],
                      ),
                    ),
                  ),

                for (final campana in _campanas) ...[
                  _TarjetaChacra(
                    campana: campana,
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PantallaDetalle(servicio: widget.servicio, campanaId: campana.id),
                        ),
                      );
                      await _cargar();
                    },
                  ),
                  const SizedBox(height: 10),
                ],

                const SizedBox(height: 10),

                // Botón Principal: Nueva chacra
                FilledButton.icon(
                  onPressed: () async {
                    final creada = await Navigator.of(context).push<bool>(
                      MaterialPageRoute(
                        builder: (_) => PantallaNueva(servicio: widget.servicio, codigo: widget.codigo),
                      ),
                    );
                    if (creada == true) await _cargar();
                  },
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                  label: const Text('Nueva chacra'),
                ),
                const SizedBox(height: 10),

                // Botones de Auditoría, Verificación y Respaldo
                OutlinedButton.icon(
                  onPressed: _sincronizando ? null : _sincronizar,
                  icon: _sincronizando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2, color: ColoresAllpa.verdeBosque),
                        )
                      : const Icon(Icons.cloud_upload_outlined, size: 20),
                  label: const Text('Enviar respaldo'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => PantallaCalidad(servicio: widget.servicio)),
                    );
                  },
                  icon: const Icon(Icons.speed_rounded, size: 20),
                  label: const Text('Pruebas del aplicativo'),
                ),
                const SizedBox(height: 10),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: ColoresAllpa.doradoOscuro,
                    side: const BorderSide(color: ColoresAllpa.doradoOscuro, width: 1.2),
                  ),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => PantallaVerificacion(servicio: widget.servicio, codigo: widget.codigo),
                      ),
                    );
                  },
                  icon: const Icon(Icons.verified_outlined, size: 20, color: ColoresAllpa.doradoOscuro),
                  label: const Text('Verificación UP-ILL-001 (tesis)'),
                ),
                const SizedBox(height: 16),
              ],
            ),
    );
  }

  Future<void> _sincronizar() async {
    setState(() => _sincronizando = true);
    final enviadas = await guardar(context, widget.servicio.sincronizar);
    if (!mounted) return;
    setState(() => _sincronizando = false);
    if (enviadas == null) return;
    avisar(context, 'Respaldo listo. Campañas enviadas: $enviadas.');
    await _cargar();
  }
}

class _TarjetaMetrica extends StatelessWidget {
  final String titulo;
  final String valor;
  final String subtitulo;
  final IconData icono;
  final Color colorFondo;
  final Color colorIcono;

  const _TarjetaMetrica({
    required this.titulo,
    required this.valor,
    required this.subtitulo,
    required this.icono,
    required this.colorFondo,
    required this.colorIcono,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: colorIcono.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                titulo,
                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: ColoresAllpa.textoSecundario),
              ),
              Icon(icono, size: 16, color: colorIcono),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            valor,
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: colorIcono),
          ),
          const SizedBox(height: 2),
          Text(
            subtitulo,
            style: const TextStyle(fontSize: 10, color: ColoresAllpa.textoSecundario),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _TarjetaChacra extends StatelessWidget {
  final Campana campana;
  final VoidCallback onTap;

  const _TarjetaChacra({required this.campana, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final cultivoNombre = etiquetaCultivo(campana.plan.cultivo);
    final tieneSiembra = campana.siembra != null;
    final tieneCosecha = campana.cosecha != null;

    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: ColoresAllpa.doradoClaro,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: ColoresAllpa.doradoAndino.withOpacity(0.3)),
                    ),
                    child: const Icon(Icons.grain_rounded, color: ColoresAllpa.doradoOscuro, size: 24),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          campana.nombreParcela,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: ColoresAllpa.textoPrincipal,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _Pildora(
                              texto: cultivoNombre.isEmpty ? 'Sin cultivo' : cultivoNombre,
                              colorFondo: ColoresAllpa.verdeSuperficie,
                              colorTexto: ColoresAllpa.verdeOscuro,
                            ),
                            _Pildora(
                              texto: '${campana.hectareasDisponibles} ha',
                              colorFondo: ColoresAllpa.trigoSuave,
                              colorTexto: ColoresAllpa.doradoOscuro,
                            ),
                            if (campana.pisoEcologico.isNotEmpty)
                              _Pildora(
                                texto: campana.pisoEcologico,
                                colorFondo: const Color(0xFFF1EAE0),
                                colorTexto: ColoresAllpa.textoSecundario,
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right_rounded, color: ColoresAllpa.textoAtenuado),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(color: ColoresAllpa.divisor, height: 1),
              const SizedBox(height: 10),
              // Progreso de funciones básicas
              Row(
                children: [
                  _PasoIndicador(etiqueta: 'Plan', activo: planEscrito(campana.plan)),
                  const SizedBox(width: 6),
                  _PasoIndicador(etiqueta: 'Siembra', activo: tieneSiembra),
                  const SizedBox(width: 6),
                  _PasoIndicador(etiqueta: 'Labores (${campana.labores.length})', activo: campana.labores.isNotEmpty),
                  const SizedBox(width: 6),
                  _PasoIndicador(etiqueta: 'Cosecha', activo: tieneCosecha),
                  const Spacer(),
                  Icon(
                    campana.sincronizado ? Icons.check_circle_rounded : Icons.pending_rounded,
                    size: 14,
                    color: campana.sincronizado ? ColoresAllpa.verdeMedio : ColoresAllpa.tierraBarro,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    campana.sincronizado ? 'Sincronizado' : 'Sin señal',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: campana.sincronizado ? ColoresAllpa.verdeMedio : ColoresAllpa.tierraBarro,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Pildora extends StatelessWidget {
  final String texto;
  final Color colorFondo;
  final Color colorTexto;

  const _Pildora({required this.texto, required this.colorFondo, required this.colorTexto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
      decoration: BoxDecoration(
        color: colorFondo,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        texto,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: colorTexto),
      ),
    );
  }
}

class _PasoIndicador extends StatelessWidget {
  final String etiqueta;
  final bool activo;

  const _PasoIndicador({required this.etiqueta, required this.activo});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
      decoration: BoxDecoration(
        color: activo ? ColoresAllpa.verdeMentaSuave : const Color(0xFFEBE5DC),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            activo ? Icons.check_rounded : Icons.circle,
            size: 10,
            color: activo ? ColoresAllpa.verdeOscuro : ColoresAllpa.textoAtenuado,
          ),
          const SizedBox(width: 3),
          Text(
            etiqueta,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: activo ? ColoresAllpa.verdeOscuro : ColoresAllpa.textoSecundario,
            ),
          ),
        ],
      ),
    );
  }
}
