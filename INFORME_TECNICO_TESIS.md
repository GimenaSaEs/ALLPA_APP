# INFORME TÉCNICO PARA CAPÍTULO III — ALLPA

## Alcance y estado de la evidencia

Este informe describe lo observado en el código entregado. La tesis especifica requisitos y evidencias fotográficas esperadas, pero el producto del directorio aún tiene una integración incompleta. No se reportan resultados de usuarios, cobertura, ni validación fuera de línea hasta que existan registros verificables.

## Arquitectura y componentes

La organización separa presentación (`lib/presentation`), estado (`AllpaProvider`), modelos/repositorios (`lib/data`) y servicios locales (`lib/core/database`). `DatabaseHelper` administra SQLite con migración versionada y `DatabaseMigrations` crea tablas, claves foráneas e índices. `sqflite_common_ffi` habilita una fábrica FFI en escritorio y modo test. El provider coordina repositorios y mantiene listas de terreno, cultivo, labores, insumos, cosechas, bitácora e indicadores. El punto de entrada, sin embargo, todavía monta el contador Flutter y no este provider.

## Módulos y flujo técnico

| Módulo y objetivo | Archivos/clases principales | Tablas | Flujo | Validaciones observables | Pruebas/captura |
|---|---|---|---|---|---|
| Perfil: datos del agricultor | `perfil_screen.dart`, `AgricultorModel`, `AgricultorRepository`, `AllpaProvider` | agricultor | formulario → provider → repo → SQLite → lectura | `nombre`, `codigo_local` NOT NULL; código UNIQUE | APP-01 pendiente; EV-01 pendiente |
| Terrenos: registrar superficie/ubicación | pantallas `terrenos/*`, `TerrenoModel`, repo | agricultor, terreno | UI → provider → repo → FK y fila | área > 0 en SQL; UI usa `Validators` | APP-02 pendiente; EV-02/10 |
| Cultivos: asociar especie y superficie al terreno | `cultivos/*`, modelo y repo cultivo | terreno, cultivo, plan_siembra | captura → cultivo ligado a terreno; consulta puede anexar plan/cosecha | especie/fecha obligatorias en SQL; utilitario limita superficie >5% con aviso/error | APP-03 pendiente; EV-07/08 |
| Plan de siembra: guardar fecha prevista/real | `PlanSiembraModel`, repo, `plan_siembra_form_screen.dart` | plan_siembra, cultivo | fechas → repo calcula desfase/estado → upsert por cultivo | una fila por cultivo; `escrito` 0/1 | APP-03 pendiente; EV-03 |
| Labores: registrar tarea y jornales | `labor_form_screen.dart`, modelo/repo | labor, cultivo | formulario → provider → repo → lectura | tipo/fecha requeridos; jornales >=0 en SQL | APP-04 pendiente; EV-04 |
| Insumos: registrar recursos aplicados | `insumo_form_screen.dart`, modelo/repo | insumo, cultivo | formulario → provider → repo → consulta | cantidad >=0; nombre/tipo/unidad/fecha obligatorios en SQL | APP-04 pendiente; EV-04 |
| Bitácora: consolidar eventos y filtrar | `BitacoraRepository`, `BitacoraItem`, filtros provider | labor, insumo, plan_siembra, cosecha + joins | consultas SQL con joins y filtros → lista agregada → CSV | filtro por terreno/cultivo/tipo; no hay pantalla localizada | APP-05 pendiente; EV-05/11 |
| Cosecha: registrar producción | `CosechaModel`, `CosechaRepository` | cosecha, cultivo | guarda cosecha; calcula rendimiento/productividad; actualiza estado | una cosecha por cultivo; área >0, kg/jornales >=0 | APP-06 pendiente; EV-06 |
| Indicadores: métricas por cultivo/resumen | `IndicadoresRepository`, `IndicadoresModel`, cálculos | agricultor, terreno, cultivo, plan, insumo, labor, cosecha | joins/agregaciones → métricas → provider/CSV | divisiones inválidas se evitan mediante chequeos en funciones | prueba pendiente; EV-12 |
| Exportación: salida de bitácora/indicadores | `CsvExporter`, `AllpaProvider` | vistas derivadas de las tablas anteriores | mapa de filas → texto CSV | codificación/escape según utilitario, validar importación | prueba pendiente; EV-11 |

La validación de formulario depende de su conexión con los widgets; la existencia de `Validators` y restricciones SQL no acredita que todas las pantallas las invoquen.

## Persistencia y seguridad de datos

Esquema versión 1: agricultor, terreno, cultivo, plan_siembra, labor, insumo y cosecha. Relaciones y restricciones exactas constan en `documentacion_tesis/02_base_datos/ESQUEMA_SQLITE.md`. La aplicación apunta a operar localmente sin backend. No se verificó mediante modo avión. `.gitignore` excluye bases locales, archivos de firma y configuración local; una revisión manual adicional sigue siendo necesaria al preparar commits.

## Limitaciones identificadas

El arranque Flutter aún presenta el contador. Falta `home_dashboard_screen.dart` referenciado desde la pantalla de bienvenida. El test incluido prueba contador. No se encontraron vistas completas para cosecha, bitácora o indicadores, ni capturas reales. La migración v2 es un comentario vacío. Release usa firma debug. El APK de esta revisión, si compila, no debe describirse como demostración operativa de ALLPA.

## Protocolo de verificación propuesto

Ejecutar análisis estático, pruebas Flutter y build APK; después, integrar navegación, agregar pruebas de esquema/repositorios y UI, instalar en Android, activar modo avión, registrar y recuperar datos tras reinicio. Adjuntar logs completos, versión, dispositivo, datos sintéticos y capturas EV correspondientes. Aceptación de usabilidad requiere observación real y registro de tareas, errores y duración.

## Evidencias

La revisión del 2026-11-17 resolvió dependencias, el análisis reportó 106 hallazgos, pasaron tres tests Flutter (dos de esquema SQLite FFI y el widget smoke de plantilla) y se generó el APK debug. Resultados de comandos y límites se registran en `documentacion_tesis/05_pruebas/RESULTADOS.md`. Las trece ubicaciones EV se describen en `documentacion_tesis/04_capturas/README.md`; están pendientes de capturas reales. Los requisitos RF-01..RF-06 y RNF-01..RNF-03 se enlazan con código y pruebas propuestas en `documentacion_tesis/06_trazabilidad/TRAZABILIDAD.md`.