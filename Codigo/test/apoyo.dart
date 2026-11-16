import 'dart:io';

import 'package:allpa/datos/base_datos.dart';
import 'package:allpa/datos/repositorio.dart';
import 'package:allpa/servicios/bitacora_servicio.dart';
import 'package:path/path.dart' as p;

Future<BitacoraServicio> nuevoServicio() async {
  asegurarMotorSqlite();
  final directorio = await Directory.systemTemp.createTemp('allpa_');
  final repo = await Repositorio.abrir(p.join(directorio.path, 'allpa.db'));
  return BitacoraServicio(repo, rutaRespaldo: p.join(directorio.path, 'respaldo_illpe.json'));
}

Future<CampanaId> abrirCampana(BitacoraServicio servicio, {Map<String, dynamic> cambios = const {}}) async {
  await servicio.ingresar('UP-ILL-001', 'Unidad de prueba');
  final datos = {
    'codigo_unidad': 'UP-ILL-001',
    'nombre_parcela': 'Pampa',
    'piso_ecologico': 'quechua',
    'hectareas_disponibles': 2,
    'cultivo': 'cebada',
    'hectareas_previstas': 1,
    'fecha_siembra_prevista': '2027-11-01',
    'labores_planificadas': ['Arado'],
    ...cambios,
  };
  final campana = await servicio.crearCampana(datos);
  return (id: campana.id, servicio: servicio);
}

typedef CampanaId = ({String id, BitacoraServicio servicio});
