# Manual técnico y mantenimiento

## Requisitos y ejecución

1. Instala Flutter 3.41.x/Dart 3.11.x, Android Studio/SDK y JDK 17.
2. Desde la raíz del proyecto, ejecuta `flutter pub get`.
3. Ejecuta `flutter analyze` y `flutter test`.
4. Conecta un dispositivo/emulador y ejecuta `flutter run`. ALLPA inicializa SQLite y muestra bienvenida o panel según exista perfil.
5. Para generar el APK: `flutter build apk --debug`. Archivo: `build/app/outputs/flutter-apk/app-debug.apk`.

## Datos y migraciones

`DatabaseHelper` administra `allpa_database.db`; el esquema versión 1 está en `DatabaseMigrations`. Incrementa la versión y crea una migración incremental antes de cambiar el esquema de una base instalada. No publiques archivos `.db` de usuarios.

Las pruebas de esquema usan `sqflite_common_ffi` con una base en memoria; Android usa `sqflite`. La prueba OFF-01 en Samsung SM-A155M Android 14 comprobó que el perfil sintético se recupera después de forzar cierre y relanzar sin red. No reemplaza pruebas CRUD de cada entidad ni una prueba de actualización de esquema.

## Publicación y firma

La configuración Gradle actual firma la variante local con la clave debug. Para distribuir, configura una clave release privada fuera del repositorio. Revisa `.gitignore`, `git status` y posibles secretos antes de publicar.
