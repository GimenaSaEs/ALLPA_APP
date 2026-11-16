import 'package:allpa/demo.dart';
import 'package:allpa/servicios/bitacora_servicio.dart';
import 'package:allpa/ui/comun.dart';
import 'package:allpa/ui/pantalla_inicio.dart';
import 'package:allpa/ui/tema.dart';
import 'package:flutter/material.dart';

class PantallaIngreso extends StatefulWidget {
  final BitacoraServicio servicio;

  const PantallaIngreso({super.key, required this.servicio});

  @override
  State<PantallaIngreso> createState() => _PantallaIngresoState();
}

class _PantallaIngresoState extends State<PantallaIngreso> {
  final _codigo = TextEditingController();
  final _nombre = TextEditingController();
  bool _procesando = false;

  @override
  void dispose() {
    _codigo.dispose();
    _nombre.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Cascaron(
      servicio: widget.servicio,
      raiz: true,
      alCambiarSenal: () => setState(() => widget.servicio.establecerSenal(!widget.servicio.haySenal)),
      cuerpo: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        children: [
          // Banner de bienvenida con identidad agrícola de Illpe
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [ColoresAllpa.verdeBosque, ColoresAllpa.verdeOscuro],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: ColoresAllpa.verdeBosque.withOpacity(0.25),
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
                        color: Colors.white.withOpacity(0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: ColoresAllpa.doradoClaro, width: 1.5),
                      ),
                      child: const Icon(Icons.terrain_rounded, size: 28, color: ColoresAllpa.doradoClaro),
                    ),
                    const SizedBox(width: 14),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Allpa · Illpe',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 0.3,
                            ),
                          ),
                          Text(
                            'Gestión Agrícola de Campaña',
                            style: TextStyle(
                              fontSize: 13,
                              color: ColoresAllpa.doradoClaro,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                const Text(
                  'Bitácora digital para el registro de parcelas, planes, siembras, labores e indicadores agronómicos. '
                  'Opera sin conexión mediante SQLite local de 22 tablas (Capítulos III–V).',
                  style: TextStyle(fontSize: 13, color: Colors.white70, height: 1.4),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.location_on_outlined, size: 14, color: ColoresAllpa.doradoClaro),
                      SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          'Illpe · Churcampa · Huancavelica',
                          style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),

          // Tarjeta de Ingreso
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.badge_outlined, color: ColoresAllpa.verdeBosque, size: 22),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Ingreso a la Unidad Productiva',
                          style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: ColoresAllpa.textoPrincipal),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _codigo,
                    textCapitalization: TextCapitalization.characters,
                    decoration: campo(
                      'Código de unidad productiva',
                      prefixIcon: const Icon(Icons.confirmation_number_outlined, color: ColoresAllpa.textoSecundario),
                      hintText: 'Ej. UP-ILL-001 (RN-01)',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: _nombre,
                    textCapitalization: TextCapitalization.words,
                    decoration: campo(
                      'Nombre del productor',
                      prefixIcon: const Icon(Icons.person_outline_rounded, color: ColoresAllpa.textoSecundario),
                      hintText: 'Opcional (Ej. Productor Illpe)',
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: _procesando ? null : _entrar,
                    icon: _procesando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.arrow_forward_rounded, size: 20),
                    label: const Text('Entrar'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Tarjeta de Sustentación / Ejemplo de Illpe
          Card(
            color: ColoresAllpa.trigoSuave,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: const BorderSide(color: Color(0xFFE8D5B5), width: 1.2),
            ),
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
                          color: ColoresAllpa.doradoAndino.withOpacity(0.18),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.verified_rounded, size: 20, color: ColoresAllpa.doradoOscuro),
                      ),
                      const SizedBox(width: 10),
                      const Expanded(
                        child: Text(
                          'Sustentación de Tesis · Caso UP-ILL-001',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: ColoresAllpa.doradoOscuro,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Carga la campaña completa de cebada (Pampa de Illpe, piso quechua, ciclo 2027) con los 15 indicadores '
                    'exactos del Capítulo V.',
                    style: TextStyle(fontSize: 12.5, color: ColoresAllpa.textoPrincipal, height: 1.35),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: ColoresAllpa.doradoOscuro,
                      side: const BorderSide(color: ColoresAllpa.doradoOscuro, width: 1.2),
                      backgroundColor: Colors.white,
                    ),
                    onPressed: _procesando ? null : _ejemplo,
                    icon: const Icon(Icons.play_circle_outline_rounded, size: 20),
                    label: const Text('Cargar ejemplo de Illpe'),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Píldoras de características del informe
          const Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              _InsigniaCaracteristica(icono: Icons.signal_cellular_off_rounded, texto: '100% Offline (SQLite)'),
              _InsigniaCaracteristica(icono: Icons.table_chart_outlined, texto: '22 Tablas Esquema v2'),
              _InsigniaCaracteristica(icono: Icons.eco_outlined, texto: '5 Cultivos Andinos'),
              _InsigniaCaracteristica(icono: Icons.checklist_rounded, texto: '7 Funciones de Campaña'),
            ],
          ),
          const SizedBox(height: 10),
        ],
      ),
    );
  }

  Future<void> _entrar() async {
    setState(() => _procesando = true);
    final ingreso = await guardar(context, () => widget.servicio.ingresar(_codigo.text, _nombre.text));
    if (!mounted) return;
    setState(() => _procesando = false);
    if (ingreso == null) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PantallaInicio(
          servicio: widget.servicio,
          codigo: ingreso.codigo,
          nombre: ingreso.nombre,
        ),
      ),
    );
  }

  Future<void> _ejemplo() async {
    setState(() => _procesando = true);
    final id = await guardar(context, () => cargarEjemplo(widget.servicio));
    if (!mounted) return;
    setState(() => _procesando = false);
    if (id == null) return;
    await Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => PantallaInicio(
          servicio: widget.servicio,
          codigo: 'UP-ILL-001',
          nombre: 'Unidad de ejemplo',
        ),
      ),
    );
  }
}

class _InsigniaCaracteristica extends StatelessWidget {
  final IconData icono;
  final String texto;

  const _InsigniaCaracteristica({required this.icono, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: ColoresAllpa.verdeSuperficie,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: ColoresAllpa.verdeMentaSuave),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icono, size: 14, color: ColoresAllpa.verdeMedio),
          const SizedBox(width: 5),
          Text(
            texto,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: ColoresAllpa.verdeOscuro,
            ),
          ),
        ],
      ),
    );
  }
}
