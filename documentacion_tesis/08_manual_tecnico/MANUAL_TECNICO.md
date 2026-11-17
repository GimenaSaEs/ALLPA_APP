# Manual técnico y mantenimiento

1. Instale Flutter (Dart SDK `^3.11.5`), Android Studio/SDK y JDK 17.
2. Abra `allpa/`, ejecute `flutter pub get`.
3. Analice y ejecute: `flutter analyze`, `flutter test`, `flutter run`.
4. Compile: `flutter build apk --debug`. Salida esperada: `build/app/outputs/flutter-apk/app-debug.apk`.
5. Base de datos: `DatabaseHelper` crea `allpa_database.db`; el esquema versión 1 está en `DatabaseMigrations`. Incrementar `currentVersion` y agregar migración antes de cambiar el esquema publicado.
6. Pruebas SQLite de escritorio usan `sqflite_common_ffi`; Android utiliza `sqflite`. Las rutas y fábrica no son iguales entre plataformas.
7. Antes de publicar, revisar `git status`, `.gitignore`, datos personales y claves. Release actual firma con debug; configure firma privada fuera del repositorio antes de distribuir, nunca incluya la clave.

Ver [estado actual y limitaciones](estado_actual.md). No se ha verificado ejecución en modo avión ni aceptación de usuarios.