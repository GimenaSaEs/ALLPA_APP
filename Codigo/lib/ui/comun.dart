import 'package:allpa/dominio/reglas.dart';
import 'package:allpa/servicios/bitacora_servicio.dart';
import 'package:allpa/ui/tema.dart';
import 'package:flutter/material.dart';

void avisar(BuildContext context, String mensaje, {bool esError = false}) {
  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Row(
        children: [
          Icon(
            esError ? Icons.warning_amber_rounded : Icons.info_outline_rounded,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              mensaje,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
      backgroundColor: esError ? ColoresAllpa.tierraBarro : ColoresAllpa.verdeOscuro,
      behavior: SnackBarBehavior.floating,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      duration: const Duration(seconds: 4),
    ),
  );
}

Future<T?> guardar<T>(BuildContext context, Future<T> Function() accion) async {
  try {
    return await accion();
  } on ErrorDeRegla catch (error) {
    if (context.mounted) avisar(context, error.mensaje, esError: true);
  } on ErrorPersistencia catch (error) {
    if (context.mounted) avisar(context, error.mensaje, esError: true);
  } catch (error) {
    if (context.mounted) avisar(context, 'Ocurrió un error inesperado: $error', esError: true);
  }
  return null;
}

class Cascaron extends StatelessWidget {
  final BitacoraServicio servicio;
  final Widget cuerpo;
  final VoidCallback alCambiarSenal;
  final bool raiz;
  final List<Widget>? accionesAdicionales;

  const Cascaron({
    super.key,
    required this.servicio,
    required this.cuerpo,
    required this.alCambiarSenal,
    this.raiz = false,
    this.accionesAdicionales,
  });

  @override
  Widget build(BuildContext context) {
    final haySenal = servicio.haySenal;

    return Scaffold(
      backgroundColor: ColoresAllpa.fondoPapel,
      appBar: AppBar(
        automaticallyImplyLeading: !raiz,
        titleSpacing: raiz ? 16 : 0,
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.eco_rounded, size: 20, color: ColoresAllpa.doradoClaro),
            ),
            const SizedBox(width: 10),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Allpa',
                  style: TextStyle(
                    fontSize: 21,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                    color: Colors.white,
                  ),
                ),
                Text(
                  'Illpe · bitácora de campaña',
                  style: TextStyle(
                    fontSize: 11,
                    color: ColoresAllpa.doradoClaro,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          if (accionesAdicionales != null) ...accionesAdicionales!,
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: InkWell(
              onTap: alCambiarSenal,
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: haySenal
                      ? Colors.white.withOpacity(0.18)
                      : const Color(0xFFC05621).withOpacity(0.35),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: haySenal ? const Color(0xFF74C69D) : const Color(0xFFF6AD55),
                    width: 1.2,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: haySenal ? const Color(0xFF52B788) : const Color(0xFFF6AD55),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      haySenal ? Icons.wifi_rounded : Icons.signal_cellular_off_rounded,
                      size: 15,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 5),
                    Text(
                      haySenal ? 'Con señal' : 'Sin señal',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: cuerpo,
          ),
        ),
      ),
    );
  }
}

Future<void> elegirFecha(
  BuildContext context,
  DateTime? actual,
  void Function(DateTime fecha) alElegir,
) async {
  final elegida = await showDatePicker(
    context: context,
    initialDate: actual ?? DateTime.now(),
    firstDate: DateTime(2024),
    lastDate: DateTime(2032),
    builder: (context, child) {
      return Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: ColoresAllpa.verdeBosque,
            onPrimary: Colors.white,
            onSurface: ColoresAllpa.textoPrincipal,
          ),
        ),
        child: child!,
      );
    },
  );
  if (elegida != null) alElegir(elegida);
}
