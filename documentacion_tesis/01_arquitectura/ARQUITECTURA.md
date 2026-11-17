# Arquitectura implementada

La aplicación separa presentación, estado, datos y persistencia local.

1. **Presentación** (`lib/presentation/screens`, `widgets`): bienvenida, panel, perfil, formularios y vistas de terrenos/cultivos, bitácora e indicadores.
2. **Estado** (`AllpaProvider`): coordina consultas y cambios mediante repositorios y notifica a los widgets con `ChangeNotifier`.
3. **Datos** (`lib/data/models`, `repositories`): modelos y operaciones SQLite. Bitácora e indicadores reúnen registros mediante consultas y cálculos.
4. **Persistencia** (`DatabaseHelper`, `DatabaseMigrations`): SQLite versión 1, relaciones e índices; `sqflite_common_ffi` permite ejecutar pruebas en memoria.
5. **Utilidades**: validadores, cálculos, fechas y generación de CSV.

## Flujo de entrada

`main.dart` crea `AllpaProvider` e inicializa la base. Si no existe perfil muestra `WelcomeScreen`, desde donde se abre `PerfilScreen`; después de guardar, el panel principal da acceso a terrenos, cultivos, bitácora, indicadores y perfil. Con un perfil ya guardado, abre directamente el panel. El detalle del cultivo enlaza plan, labores, insumos y cosecha.

## Decisiones técnicas observables

- Los datos se guardan localmente; no hay backend remoto implementado.
- SQLite aplica claves foráneas, restricciones `CHECK`, índices y eliminación restringida o en cascada según entidad.
- Cada cultivo tiene como máximo un plan de siembra y una cosecha mediante restricciones `UNIQUE`.
- CSV se genera y se copia al portapapeles desde las pantallas correspondientes.
- Android usa la ruta administrada por `sqflite`; la base no se almacena dentro del repositorio.

## Evidencia y límites

La compilación, análisis estático y pruebas automatizadas son satisfactorios. En Samsung SM-A155M Android 14 se observó la persistencia del perfil sintético al forzar cierre y relanzar sin red (EV-13). Esta prueba no acredita todas las entidades ni flujos CRUD. Consultar `../05_pruebas/RESULTADOS.md` para los resultados y pendientes.
