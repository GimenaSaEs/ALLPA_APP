# ALLPA — gestión local de cultivos

Aplicación Flutter en desarrollo para registrar información agrícola localmente con SQLite. Este repositorio contiene modelos, repositorios, pantallas parciales y el esquema de datos. **El estado actual todavía no constituye una aplicación funcional integrada:** `lib/main.dart` conserva la plantilla de contador Flutter; las pantallas ALLPA no están conectadas y hay imports a pantallas ausentes. Consulte [limitaciones](documentacion_tesis/08_manual_tecnico/estado_actual.md) antes de interpretar el APK o las funcionalidades descritas en los documentos.

## Requisitos

- Flutter SDK compatible con Dart `^3.11.5` (revise `flutter --version`).
- Android Studio/Android SDK y JDK 17 para Android.
- Git para clonar el código.

## Preparar y ejecutar

```powershell
cd allpa
flutter pub get
flutter analyze
flutter run
```

`flutter run` ejecuta la aplicación configurada en `lib/main.dart`; por ahora muestra la plantilla contador, no el flujo ALLPA. En la revisión del 2026-11-17, `flutter analyze` reportó 106 hallazgos; `flutter test` pasó 3 pruebas (incluye SQLite en memoria) y el APK debug compiló. Los resultados y límites constan en `documentacion_tesis/05_pruebas/RESULTADOS.md`.

## Arquitectura del código disponible

- `lib/core`: SQLite/migraciones, tema, constantes y utilidades de validación, cálculo, fechas y CSV.
- `lib/data/models`: modelos de agricultor, terreno, cultivo, siembra, labor, insumo, cosecha e indicadores.
- `lib/data/repositories`: acceso SQLite y consultas de bitácora e indicadores.
- `lib/presentation/providers`: estado de aplicación con Provider.
- `lib/presentation/screens`: formularios y vistas parciales; varias referencias/integraciones están incompletas.
- `android/`: proyecto Gradle Kotlin DSL y manifiestos Android.

El esquema SQLite ejecutable está definido en `lib/core/database/database_migrations.dart`; la descripción legible está en `documentacion_tesis/02_base_datos/ESQUEMA_SQLITE.md`. SQLite local no requiere red, pero la operación sin conexión de las pantallas no se ha validado.

## Comandos de validación y APK

```powershell
flutter analyze
flutter test
flutter build apk --debug
```

El APK debug (si la compilación termina correctamente) se genera en `build/app/outputs/flutter-apk/app-debug.apk`. Un APK generado desde el estado actual solo empaqueta la app contador. No distribuir como versión de ALLPA ni como prueba de funcionamiento agrícola.

## Pruebas

Consulte `documentacion_tesis/05_pruebas/RESULTADOS.md` para comandos ejecutados y resultados observados. El test inicial `test/widget_test.dart` aún espera un contador y no verifica funciones agrícolas ni SQLite. No se declara cobertura porcentual.

## Documentación de tesis

La carpeta `documentacion_tesis/` organiza arquitectura, esquema, diagramas, evidencias pendientes, pruebas, trazabilidad y manuales. `INFORME_TECNICO_TESIS.md` resume los módulos y su estado para apoyar la actualización del Capítulo III. Las carpetas EV de capturas están reservadas; no se incluyen imágenes simuladas como evidencia real.

## Privacidad y publicación

No agregue datos identificables de agricultores, bases reales, archivos de firma, credenciales ni secretos. `.gitignore` excluye bases SQLite locales, archivos de firma y configuración local. Revise los cambios con `git status` y haga una inspección de secretos antes de publicar.

## Publicación en GitHub

Este directorio no estaba inicializado como repositorio Git y no se encontró un remoto ni configuración de publicación confirmada durante la preparación. Tras revisar el proyecto y crear un repositorio vacío en GitHub:

```powershell
git init -b main
git add .
git status --short
git commit -m "Preparar documentación y proyecto ALLPA"
git remote add origin https://github.com/USUARIO/REPOSITORIO.git
git push -u origin main
```

Sustituya la URL por la del repositorio autorizado. El `git status` debe confirmar que no se incluyen datos privados ni claves. No se ha publicado este código.