import 'package:flutter/services.dart';

/// Abre el selector de Android; abrirlo no confirma que el usuario envió el archivo.
Future<void> compartirRespaldo(String ruta) async {
  const canal = MethodChannel('allpa/respaldo');
  await canal.invokeMethod<void>('compartir', {'ruta': ruta});
}
