import 'package:allpa/servicios/bitacora_servicio.dart';

Future<String> cargarEjemplo(BitacoraServicio servicio) async {
  servicio.establecerSenal(true);
  await servicio.ingresar('UP-ILL-001', 'Unidad de ejemplo');
  final existentes = await servicio.listar('UP-ILL-001');
  if (existentes.isNotEmpty) return existentes.first.id;
  final campana = await servicio.crearCampana({
    'codigo_unidad': 'UP-ILL-001',
    'nombre_parcela': 'Pampa de Illpe',
    'piso_ecologico': 'quechua',
    'hectareas_disponibles': 2.0,
    'cultivo': 'cebada',
    'hectareas_previstas': 1.2,
    'fecha_siembra_prevista': '2027-11-10',
    'labores_planificadas': ['Arado', 'Siembra', 'Deshierbo'],
  });
  await servicio.registrarSiembra(campana.id, {
    'fecha_real': '2027-11-18',
    'individual': true,
    'kilogramos_semilla': 90,
    'hectareas_sembradas': 1.2,
    'jornales': 2,
  });
  await servicio.registrarLabor(campana.id, {
    'nombre': 'Deshierbo',
    'fecha': '2027-12-20',
    'jornales': 4,
    'segundos_registro': 45,
  });
  await servicio.registrarCosecha(campana.id, {
    'superficie_cosechada_ha': 1.1,
    'produccion_kg': 2640,
  });
  // RF-08 / función consulta: deja cobertura de las siete funciones en 100 %
  await servicio.consultar(campana.id);
  return campana.id;
}
