# Casos de prueba y resultados observados

Fecha de revisión: 2026-11-17 (America/Lima). No se reporta porcentaje de cobertura.

| Comando / verificación | Resultado observado |
|---|---|
| `flutter analyze` | Correcto: `No issues found!` (112.4 s). |
| `flutter test --reporter expanded` | Correcto: 6 pruebas pasan: dos de esquema SQLite FFI y cuatro widget, incluyendo formato de fecha y selector en español. |
| `flutter build apk --debug` | Correcto; APK generado en `build/app/outputs/flutter-apk/app-debug.apk`. |
| Instalación y arranque Android | Correctos en Samsung SM-A155M con Android 14; la app muestra la bienvenida/panel de ALLPA, no la pantalla demo de Flutter. |
| Formulario de registro de cultivos / selector de fecha | Correcto en Samsung SM-A155M: formulario visible, fecha formateada en español y calendario localizado sin `LocaleDataException`; captura EV-08. |
| Persistencia al reiniciar sin red | Correcta para el perfil sintético `Agricultor demo`: con Wi-Fi y datos móviles apagados, se forzó el cierre y se reabrió la app; reapareció el panel con ese perfil. Ver `../04_capturas/EV-13_persistencia_sin_red.png`. |
| `flutter build windows --debug` | No compila en este equipo: Flutter requiere Developer Mode para crear symlinks de plugins. |

## Alcance y límites

La prueba OFF-01 acredita persistencia local del perfil después de un cierre forzado y relanzamiento con las radios desactivadas en un dispositivo Android. No prueba cada operación CRUD, la persistencia de terrenos/cultivos/bitácora, una instalación limpia en modo avión, pérdida/recuperación de datos, ni usabilidad con participantes.

Las pruebas de SQLite usan `sqflite_common_ffi` en memoria: comprueban las siete tablas, claves foráneas activas, inserción relacionada y rechazo de superficie cero. No sustituyen la prueba de persistencia Android. Las seis pruebas automatizadas no constituyen aceptación de campo.

La app se ejecutó y se navegó al formulario de cultivo en Android. Las capturas reales disponibles son EV-01 (bienvenida inicial), EV-08 (formulario de cultivo con fecha en español) y EV-13 (panel después de reiniciar sin red). EV-02 a EV-07 y EV-09 a EV-12 siguen pendientes; EV-08 verifica la representación del formulario y no un guardado de cultivo.
