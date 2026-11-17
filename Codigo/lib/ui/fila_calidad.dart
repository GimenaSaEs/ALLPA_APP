import 'package:allpa/ui/tema.dart';
import 'package:flutter/material.dart';

/// Conserva el espacio del título; apila el valor si ambos no caben en una fila.
class FilaCalidad extends StatelessWidget {
  final String titulo;
  final String valor;
  final bool esDestacado;
  final Color? colorDestacado;

  const FilaCalidad({
    super.key,
    required this.titulo,
    required this.valor,
    this.esDestacado = false,
    this.colorDestacado,
  });

  @override
  Widget build(BuildContext context) {
    const estiloTitulo = TextStyle(fontSize: 13.5, color: ColoresAllpa.textoPrincipal);
    final estiloValor = TextStyle(
      fontSize: esDestacado ? 14 : 13.5,
      fontWeight: FontWeight.w700,
      color: esDestacado ? (colorDestacado ?? ColoresAllpa.verdeBosque) : ColoresAllpa.textoPrincipal,
    );
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: LayoutBuilder(builder: (context, limites) {
        double ancho(String texto, TextStyle estilo) {
          final medidor = TextPainter(
            text: TextSpan(text: texto, style: DefaultTextStyle.of(context).style.merge(estilo)),
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
          )..layout();
          final resultado = medidor.width;
          medidor.dispose();
          return resultado;
        }

        final apilar = ancho(titulo, estiloTitulo) + ancho(valor, estiloValor) +
            12 + (esDestacado ? 16 : 0) > limites.maxWidth;
        final etiqueta = Text(titulo, style: estiloTitulo);
        final dato = Container(
          padding: esDestacado ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3) : EdgeInsets.zero,
          decoration: esDestacado
              ? BoxDecoration(
                  color: (colorDestacado ?? ColoresAllpa.verdeMedio).withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(6),
                )
              : null,
          child: Text(valor, textAlign: apilar ? TextAlign.left : TextAlign.right, style: estiloValor),
        );
        if (apilar) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [etiqueta, const SizedBox(height: 6), dato],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [Expanded(child: etiqueta), const SizedBox(width: 12), dato],
        );
      }),
    );
  }
}
