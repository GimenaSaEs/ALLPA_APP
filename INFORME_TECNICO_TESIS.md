# Informe técnico para Capítulo III — ALLPA

**Fecha de verificación:** 17 de noviembre de 2026. Este informe describe el código presente y separa resultados observados de funcionalidades cuya aceptación aún requiere pruebas adicionales.

## Arquitectura implementada

`lib/main.dart` crea `AllpaProvider`, que inicializa SQLite. Si no existe perfil, presenta `WelcomeScreen` y el formulario de perfil; con perfil existente abre `HomeDashboardScreen`. La presentación reside en `lib/presentation/screens` y `widgets`; el estado compartido está en `lib/presentation/providers`; modelos y consultas están en `lib/data/models` y `lib/data/repositories`; persistencia y migración están en `lib/core/database`. SQLite mediante `sqflite` funciona en el dispositivo sin backend. `sqflite_common_ffi` permite probar el esquema en memoria desde pruebas de escritorio.

## Módulos y evidencia técnica

| Módulo y objetivo | Archivos/clases principales | Tablas | Flujo y validación identificada | Prueba/captura |
|---|---|---|---|---|
| Perfil: identificar al agricultor local | `welcome_screen.dart`, `perfil/perfil_screen.dart`, `AllpaProvider`, `AgricultorRepository` | `agricultor` | Bienvenida → formulario → provider → repositorio → SQLite; nombre/código requeridos y código único | UI-01/UI-02; perfil sintético persiste tras OFF-01; EV-01/13 |
| Terrenos: organizar parcelas | `terrenos/terrenos_list_screen.dart`, `terreno_form_screen.dart`, `terreno_detail_screen.dart`, `TerrenoRepository` | `agricultor`, `terreno` | Panel → lista/formulario → guardado/consulta; área positiva y FK | DB-02 cubre FK/área en FFI; EV-02/10 pendientes |
| Cultivos y siembra: asociar campaña y fechas | `cultivos/cultivos_list_screen.dart`, `cultivo_form_screen.dart`, `cultivo_detail_screen.dart`, `plan_siembra/plan_siembra_form_screen.dart`, repositorios | `terreno`, `cultivo`, `plan_siembra` | Cultivo enlaza a terreno; detalle abre plan; fechas producen desfase/estado; relación de plan única | UI-03 verifica navegación; EV-03/07/08 y CRUD completo pendientes |
| Labores: registrar actividad y jornales | `labores/labor_form_screen.dart`, `LaborRepository` | `cultivo`, `labor` | Detalle → formulario → repositorio; jornales no negativos | Validación automatizada integral y EV-04 pendientes |
| Insumos: registrar materiales y cantidades | `insumos/insumo_form_screen.dart`, `InsumoRepository` | `cultivo`, `insumo` | Detalle → formulario → SQLite; cantidad no negativa | Validación automatizada integral y EV-04 pendientes |
| Bitácora: consultar actividades | `bitacora/bitacora_screen.dart`, `BitacoraRepository` | `plan_siembra`, `labor`, `insumo`, `cosecha` | Consultas combinadas con filtros por terreno/tipo; copia CSV | Código presente; recorrido con registros y EV-05/11 pendientes |
| Cosecha: registrar producción | `cosechas/cosecha_form_screen.dart`, `CosechaRepository` | `cultivo`, `cosecha` | Detalle → fecha/área/producción/jornales → cálculos de rendimiento y kg/jornal; una cosecha por cultivo | Recorrido CRUD y EV-06 pendientes |
| Indicadores: resumir campaña | `indicadores/indicadores_screen.dart`, `IndicadoresRepository` | varias tablas agrícolas | Agregaciones de terreno/cultivo/plan/insumo/labor/cosecha y exportación CSV | Código presente; resultados con registros y EV-12 pendientes |

El esquema y las relaciones documentados se contrastaron con `lib/core/database/database_migrations.dart`; ver `documentacion_tesis/02_base_datos/ESQUEMA_SQLITE.md`.

## Verificación y resultados

- `flutter analyze`: `No issues found!`.
- `flutter test --reporter expanded`: cinco pruebas automáticas pasan (dos de esquema SQLite FFI y tres widget).
- `flutter build apk --debug`: exitoso; artefacto en `build/app/outputs/flutter-apk/app-debug.apk`.
- Instalación e inicio observados en Samsung SM-A155M Android 14; aparece ALLPA y no la pantalla demo de Flutter.
- OFF-01 pasó para persistencia del perfil sintético: con Wi-Fi/datos apagados se forzó cierre y se relanzó la aplicación; el panel recuperó el perfil. Evidencia EV-13.
- `flutter build windows --debug` no se completó porque en este equipo está deshabilitado el soporte de symlinks requerido por Flutter.

Las pruebas FFI usan SQLite en memoria y no validan el almacenamiento persistente Android. OFF-01 no prueba la persistencia de las demás entidades ni todos los flujos CRUD. No se ejecutaron pruebas de usabilidad con participantes. Las capturas reales disponibles son EV-01 (bienvenida) y EV-13 (reinicio sin red); EV-02..EV-12 siguen pendientes. Consultar `documentacion_tesis/05_pruebas/RESULTADOS.md` y `REVISION_DOCUMENTACION_VS_CODIGO.md` para el detalle y los límites.

## Seguridad y mantenimiento

Los datos se almacenan localmente y no existe sincronización/backend configurado. No se conserva una base de agricultores reales en el repositorio; se usó un perfil sintético sin documento ni teléfono para la prueba Android. Antes de publicar, revisar `git status`, secretos y bases locales. `.gitignore` excluye archivos de firma, propiedades locales y bases de datos. La compilación actual es debug; distribución requiere firma de release administrada fuera del repositorio.
