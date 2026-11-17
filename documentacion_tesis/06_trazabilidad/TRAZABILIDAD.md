# Trazabilidad requisito → historia → código → prueba

Las historias son tareas derivadas resumidas; la tesis indica que deben validarse con asesor/usuarios. El mapeo de código indica artefactos existentes, no aceptación funcional.

| Req. tesis | Historia derivada | Código relacionado | Evidencia/prueba | Estado |
|---|---|---|---|---|
| RF-01 Perfil agricultor | Crear/editar perfil | `perfil/perfil_screen.dart`, modelo/repositorio agricultor, proveedor | APP-01; EV-01 | Parcial; no conectado al arranque |
| RF-02 Terrenos | Registrar/consultar terrenos | formularios/lista/detalle, `TerrenoRepository`, tabla terreno | APP-02; EV-02 | Parcial |
| RF-03 Cultivo y siembra | Asociar cultivo y fechas | pantallas cultivo/plan, repositorios, tablas cultivo/plan_siembra | APP-03; EV-03, EV-07/08 | Parcial |
| RF-04 Labores e insumos | Registrar actividad/insumo fechado | formularios y repositorios labor/insumo | APP-04; EV-04 | Parcial |
| RF-05 Bitácora | Consultar por terreno/cultivo/tipo | `BitacoraRepository`, filtros de provider | APP-05; EV-05 | Consulta implementada en capa de datos; no hay pantalla localizada |
| RF-06 Cosecha | Registrar producción y superficie | `CosechaRepository`, modelo, tabla cosecha | APP-06; EV-06 | Capa de datos; pantalla no localizada |
| RNF-01 Sin señal | Capturar y leer localmente sin red | `DatabaseHelper`, sqflite/repositorios | OFF-01; EV-05/13 | Diseño local presente; operación no probada |
| RNF-02 Usabilidad | Completar tareas guiadas | Formularios y validadores | Registro de observación propuesto | Pendiente |
| RNF-03 Integridad | Validar campos y relaciones | `Validators`, migración SQLite y FKs | DB-01..04 | Restricciones presentes; verificación ejecutada pendiente |