# Casos de prueba y resultados observados

Fecha de ejecución: 2026-11-17 (America/Lima). Se anotan únicamente salidas observadas; no se declara cobertura porcentual.

## Ejecución

| Comando | Resultado observado |
|---|---|
| `flutter pub get` | Correcto. Dependencias resueltas; Flutter informó que 23 paquetes tienen versiones más recientes fuera de las restricciones actuales. |
| `flutter analyze` | Falló. Informó 106 hallazgos en el proyecto, con errores de compilación/análisis y advertencias/info; entre ellos imports inexistentes (`home_dashboard_screen.dart`, `cosecha_form_screen.dart`), errores sintácticos en pantallas y errores de símbolos/imports. |
| `flutter test --reporter compact` | Correcto: 3 pruebas pasaron (2 de esquema SQLite FFI y 1 smoke test del contador Flutter). El widget test solo valida la plantilla. |
| `flutter test test/database_schema_test.dart` | Correcto: 2 pruebas pasaron. Verifican siete tablas, `PRAGMA foreign_keys=1`, persistencia vinculada con datos sintéticos y rechazo de área cero. |
| `flutter build apk --debug` | Correcto. Generó `build/app/outputs/flutter-apk/app-debug.apk` (debug). El binario ejecuta el `main.dart` de contador, no los flujos ALLPA. |
| `flutter build windows --debug` | Falló antes de compilar: Windows requiere habilitar Developer Mode para admitir symlinks. |
| Instalación Android / modo avión / relanzamiento | No ejecutada: `flutter devices` detectó Windows y navegadores, sin emulador ni dispositivo Android. Por tanto no se afirma funcionamiento offline del aplicativo Android. |

## Casos de prueba funcionales propuestos

No se consideran ejecutados:

- APP-01 a APP-06: criterios RF-01..RF-06 de perfil, terrenos, cultivo/siembra, labores/insumos, bitácora y cosecha una vez integrada la navegación.
- OFF-01: crear y consultar registros en modo avión y confirmar persistencia tras cerrar/reabrir en Android.
- DB-03: probar unicidad de plan/cosecha por cultivo; DB-04: restricciones de borrado referencial.
- Prueba guiada de usabilidad con participantes, midiendo éxito, errores y duración.

El test agregado usa SQLite en memoria mediante `sqflite_common_ffi`; no demuestra persistencia de archivo ni comportamiento de la app Android desconectada.