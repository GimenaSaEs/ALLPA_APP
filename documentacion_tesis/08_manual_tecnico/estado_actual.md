# Estado de preparación

- Git está instalado, pero `allpa/` no era un repositorio Git y no se detectó remoto configurado.
- El arranque es la app Counter estándar; no inicializa Provider ni `WelcomeScreen`.
- `welcome_screen.dart` importa `home_dashboard_screen.dart`, que no se encuentra en `lib/`.
- El test único aún afirma comportamiento de contador.
- La base de datos y capa de datos tienen entidades y operaciones, pero no se acreditó el CRUD desde una UI integrada.
- `DatabaseHelper.seedInitialDataIfEmpty()` incluía nombre, documento y teléfono de apariencia identificable; fue retirado para reducir riesgo de publicación. No había una base real versionada localizada.
- La compilación APK, análisis y test se consignan en `../05_pruebas/RESULTADOS.md` al ejecutar.
- Las release usan firma debug en `android/app/build.gradle.kts`; no es configuración de distribución pública.
- No se encontraron capturas de ejecución. Solo se reservan EV-01..EV-13; no se fabrican imágenes.
- Hay funciones de datos de bitácora, indicadores, exportación CSV y cálculos. Su presencia no prueba disponibilidad desde la interfaz.
- Revisión cruzada de documentación/código y prueba de build Windows: documentacion_tesis/05_pruebas/REVISION_DOCUMENTACION_VS_CODIGO.md; compilación Windows bloqueada por symlink support deshabilitado. La suite Flutter volvió a pasar 3 pruebas y el análisis reportó 106 hallazgos.
