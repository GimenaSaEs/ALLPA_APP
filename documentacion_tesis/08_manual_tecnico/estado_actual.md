# Estado actual de ALLPA

- `lib/main.dart` inicializa `AllpaProvider`; primera ejecución lleva a bienvenida/perfil y un perfil existente abre el panel ALLPA.
- El panel conecta terrenos, cultivos, bitácora, indicadores y perfil. El detalle de cultivo enlaza plan de siembra, labores, insumos y cosecha.
- Formularios de las entidades persisten a través de repositorios SQLite.
- `flutter analyze`: `No issues found!` (verificación del 17-11-2026).
- `flutter test --reporter expanded`: 6 pruebas pasan: SQLite FFI en memoria, bienvenida/perfil, navegación básica y fecha/selector localizado en español.
- `flutter build apk --debug`: correcto; APK en `build/app/outputs/flutter-apk/app-debug.apk`.
- Android: instalado y abierto en Samsung SM-A155M Android 14. OFF-01 verificó la recuperación del perfil sintético después de forzar cierre y relanzar sin Wi-Fi/datos; ver EV-13.
- Formulario de cultivo y calendario en español probados en Android, sin `LocaleDataException`; ver EV-08. No se guardó un cultivo durante esta verificación.
- Capturas reales disponibles: EV-01 bienvenida, EV-08 formulario de cultivo, EV-13 reinicio sin red. EV-02..EV-07 y EV-09..EV-12 pendientes.
- `flutter build windows --debug` no se completó por Developer Mode/symlink support deshabilitado en este equipo.
- Esquema SQLite declarado versión 1; `onUpgrade` aún no contiene migraciones efectivas posteriores.
- Build actual debug; release requiere firma configurada fuera del repositorio.
- No se encontró base de datos real versionada ni se incluyeron datos personales de agricultores en las capturas.
