# Arquitectura implementada en el código disponible

La base del proyecto sigue una separación por responsabilidades, aunque la integración visual no está completada.

1. **Presentación** (`lib/presentation/screens`, `widgets`): formularios de perfil, terreno, cultivo, plan de siembra, labor e insumo; pantallas de detalle/listado de terreno y cultivo.
2. **Estado** (`AllpaProvider`): coordina lecturas/escrituras de repositorios y notifica cambios mediante `ChangeNotifier`.
3. **Datos** (`lib/data/models`, `repositories`): conversión de filas SQLite a modelos y operaciones SQL. La bitácora e indicadores usan consultas de unión y cálculos.
4. **Persistencia** (`DatabaseHelper`, `DatabaseMigrations`): instancia singleton de SQLite, versión 1, claves foráneas activadas. Usa `sqflite` en móvil y `sqflite_common_ffi` para escritorio/pruebas.
5. **Utilidades**: validación, cálculos agronómicos, fechas y exportación CSV.

## Decisiones observables

- Persistencia local y sin servicio remoto en los componentes revisados.
- Relaciones con claves foráneas; restricciones `CHECK`, índices de consulta y eliminación restringida/cascada según entidad.
- `plan_siembra` y `cosecha` limitan a un registro por cultivo mediante `UNIQUE`.
- CSV generado por utilidades; el proyecto declara `csv`, `path_provider`, `provider`, `sqflite`, `fl_chart` e `intl`.

## Estado de integración

`lib/main.dart` monta la plantilla Flutter Counter. No se encuentra `home_dashboard_screen.dart`, aunque `welcome_screen.dart` lo importa. El provider no aparece conectado desde `main.dart`. Por ello los diagramas representan componentes presentes en código, no una arquitectura de ejecución integrada y probada.