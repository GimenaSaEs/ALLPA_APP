# Revisión cruzada: documentación de tesis y código

Fecha: 2026-11-17. Alcance: revisión de `documentacion_tesis/`, requisitos extraídos de la tesis (`RF-01..RF-06`, `RNF-01..RNF-03`), código fuente y comandos Flutter ejecutados en esta revisión.

## Dictamen

La carpeta de documentación **describe correctamente la estructura de datos y reconoce la integración incompleta**, pero no equivale a una demostración de que ALLPA esté funcional de extremo a extremo. El punto de entrada `lib/main.dart` todavía presenta el contador Flutter; las pantallas, provider y repositorios ALLPA no se inicializan desde allí. La documentación sí lo advierte en README, arquitectura, manuales y trazabilidad. Por ello, el estado documentado coincide con el código en cuanto a la limitación, mientras que los requisitos funcionales de tesis aún no están aceptados como implementados.

## Comparación resumida

| Tema de la tesis / carpeta | Lo que muestra el código revisado | Evaluación |
|---|---|---|
| Perfil y datos del agricultor (RF-01) | Modelo, repositorio, provider y pantalla de perfil parcial. | Parcial; navegación no conectada. |
| Terrenos (RF-02) | Modelo, repositorio y pantallas de lista, detalle y formulario. | Parcial; UI no alcanzable desde el arranque. |
| Cultivo/plan de siembra (RF-03) | Modelo, repositorios, formularios y cálculos de desfase. | Parcial; no probado como flujo completo. |
| Labores e insumos (RF-04) | Modelos, repositorios y formularios. | Parcial; integración y pruebas funcionales pendientes. |
| Bitácora (RF-05) | Repositorio con consultas agregadas y filtros del provider. | Capa de datos presente; no se localizó pantalla. |
| Cosecha (RF-06) | Modelo/repositorio y cálculo de métricas. | Capa de datos presente; formulario/pantalla referenciada está ausente. |
| SQLite local / sin señal (RNF-01) | Helper y migración SQLite; prueba FFI en memoria confirma esquema, FK y una inserción relacionada. | Persistencia local diseñada; modo avión y persistencia Android no verificados. |
| Integridad (RNF-03) | Restricciones SQL y clase `Validators`. | Parte comprobada en FFI (FK y área positiva); falta cobertura completa e integración de validadores en UI. |
| Usabilidad (RNF-02) | Sin prueba con usuarios en los artefactos. | Pendiente; no declarar aceptación. |
| Capturas EV | Trece archivos de estado pendiente; no se hallaron imágenes de ejecución. La tesis fuente enumeraba EV-01..EV-06. | Aún no coincide con el requisito de evidencia real; las trece capturas deben obtenerse de una versión ejecutable. |
| Diagramas e informe técnico | Diagramas derivan de estructura/código existente y advierten que no son prueba de ejecución. | Útiles como documentación técnica, no como evidencia de aceptación. |

## Comprobaciones repetidas

- `flutter test --reporter expanded`: 3 pasaron (dos SQLite FFI y un contador widget).
- `flutter analyze`: falla con 106 hallazgos.
- `flutter build windows --debug`: no compila porque Windows Developer Mode/symlink support está deshabilitado.
- `flutter build apk --debug`: compiló en la revisión anterior; produce la pantalla contador, no el sistema agrícola integrado.
- No hay Android emulador/dispositivo en este entorno, así que no se instaló ni ensayó modo avión.

## Cambios necesarios para que la tesis y el producto queden alineados

1. Conectar Provider y navegación ALLPA desde `main.dart` y completar las vistas ausentes.
2. Corregir los errores que reporta `flutter analyze` y reemplazar el widget test de contador por pruebas de pantallas/funciones relevantes.
3. Probar operaciones CRUD y cierres/reaperturas sobre archivo SQLite en Android, incluida la prueba en modo avión.
4. Ejecutar los criterios RF/RNF con datos sintéticos y registrar resultados observados, dispositivo y versión.
5. Capturar las trece pantallas reales solicitadas; mantenerlas sin datos personales y con sus metadatos.

Hasta completar estos puntos, usar expresiones como “diseñado”, “presente en la capa de datos” o “parcial” para los módulos sin validación integral; no reportarlos como funcionalidades aceptadas.