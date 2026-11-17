# ALLPA — gestión local de cultivos agrícolas

Aplicación móvil Flutter para registrar y consultar información agrícola con SQLite local. En una instalación nueva se abre la bienvenida de ALLPA para crear el perfil; luego se presenta el panel con terrenos, cultivos, bitácora, indicadores y perfil.

## Requisitos

- Flutter 3.41.x y Dart 3.11.x (el `pubspec.yaml` declara Dart `^3.11.5`).
- Android Studio, Android SDK y JDK 17 para compilar Android.
- Dispositivo Android con depuración USB o emulador para instalar y verificar la app.

## Instalación y ejecución

```powershell
flutter pub get
flutter run
```

Para elegir un dispositivo: `flutter devices` y `flutter run -d <device-id>`.

## Módulos

- Perfil local de agricultor.
- Registro/listado/detalle de terrenos y cultivos.
- Plan de siembra, labores e insumos desde el detalle del cultivo.
- Cosecha con cálculo de rendimiento y productividad laboral.
- Bitácora consolidada con filtros y copia de CSV.
- Indicadores de campaña y exportación CSV al portapapeles.

## Arquitectura y datos

- `lib/core`: SQLite, migraciones, tema, constantes y validaciones/cálculos.
- `lib/data/models` y `lib/data/repositories`: modelos y acceso a datos.
- `lib/presentation/providers`: estado compartido (`AllpaProvider`).
- `lib/presentation/screens` y `widgets`: interfaz.
- `android/`: configuración Gradle y manifiesto Android.

La app usa `sqflite` sin backend ni sincronización remota. Esquema y relaciones: [documentación SQLite](documentacion_tesis/02_base_datos/ESQUEMA_SQLITE.md). La carpeta [documentacion_tesis](documentacion_tesis/) contiene arquitectura, diagramas, capturas verificadas/pendientes, pruebas, trazabilidad y manuales.

## Validación y APK

```powershell
flutter analyze
flutter test --reporter expanded
flutter build apk --debug
```

En la verificación del 17-11-2026, `flutter analyze` no reportó problemas, pasaron 5 pruebas automatizadas y el APK debug se generó correctamente en `build/app/outputs/flutter-apk/app-debug.apk`. También se instaló y abrió en Samsung SM-A155M Android 14. OFF-01 verificó que un perfil sintético reaparece tras forzar cierre y relanzar con Wi-Fi/datos móviles apagados. Esta comprobación no acredita el CRUD de todas las entidades. Resultados y límites: [RESULTADOS.md](documentacion_tesis/05_pruebas/RESULTADOS.md).

El APK es debug y no corresponde a una distribución release firmada. Ruta: `build/app/outputs/flutter-apk/app-debug.apk` (el directorio `build/` está excluido por `.gitignore`). Para regenerar: `flutter build apk --debug`.

## Datos y privacidad

No incluir bases reales, contraseñas, claves privadas ni archivos de firma. `.gitignore` excluye bases locales, propiedades privadas y materiales de firma. La evidencia Android usa un perfil sintético sin DNI ni teléfono.

## Publicación en GitHub

El repositorio local está en la rama `main`; no se ha publicado. Cree un repositorio vacío en GitHub, configure autenticación y ejecute:

```powershell
git remote add origin https://github.com/USUARIO/REPOSITORIO.git
git push -u origin main
```

Antes de subir, revise `git status` y confirme que no haya datos personales o secretos.
