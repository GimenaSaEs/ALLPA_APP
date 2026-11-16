import 'package:allpa/datos/base_datos.dart';
import 'package:allpa/servicios/bitacora_servicio.dart';
import 'package:allpa/ui/pantalla_ingreso.dart';
import 'package:allpa/ui/tema.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  asegurarMotorSqlite();
  final servicio = await BitacoraServicio.abrir();
  runApp(AllpaApp(servicio: servicio));
}

class AllpaApp extends StatelessWidget {
  final BitacoraServicio servicio;

  const AllpaApp({super.key, required this.servicio});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Allpa',
      debugShowCheckedModeBanner: false,
      theme: temaAllpa(),
      home: PantallaIngreso(servicio: servicio),
    );
  }
}
