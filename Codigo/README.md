# Código fuente de Allpa

Este proyecto Flutter genera el ejecutable que acompaña a `Software Allpa/README.md`.

Desde esta carpeta:

```powershell
flutter pub get
flutter run -d windows
```

Para Android, use `flutter run` con el dispositivo conectado. Para compilar, ejecute `flutter build windows --release` o `flutter build apk --release`.

Módulos principales: `lib/datos/` (SQLite versión 2), `lib/dominio/` (reglas e indicadores), `lib/servicios/` (flujo de bitácora y respaldo) y `lib/ui/` (pantallas). La suite de pruebas está en `test/`.
