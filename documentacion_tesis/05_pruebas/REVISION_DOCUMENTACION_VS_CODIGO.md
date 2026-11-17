# Revisión cruzada: documentación de tesis y código

Revisión: 2026-11-17. Se contrastaron los requisitos RF-01..RF-06/RNF-01..RNF-03, el código, las pruebas automatizadas y la ejecución observada en Android.

## Dictamen

La documentación anterior estaba desactualizada: indicaba que no había dispositivo, que la app no se había iniciado en Android y que todas las capturas estaban pendientes. La evidencia actual contradice esas tres afirmaciones. La app ALLPA se instaló y abrió en un Samsung SM-A155M Android 14; OFF-01 confirmó que el perfil sintético persiste tras reiniciar la app sin Wi-Fi ni datos móviles. También se abrió el formulario de cultivo y su selector de fecha en español. El detalle de terreno se reordenó para evitar el overflow en pantallas estrechas. Las capturas reales disponibles son EV-01, EV-08 y EV-13.

La verificación no cubre todas las operaciones funcionales ni la aceptación de campo. Las demás capacidades que se describen abajo se contrastaron con rutas, formularios, provider y repositorios, y con pruebas automatizadas de alcance limitado.

| Requisito | Implementación observada | Validación / estado |
|---|---|---|
| RF-01 Perfil | Bienvenida, formulario y guardado vía `AllpaProvider`/repositorio | Widget abre el formulario; guardado y persistencia del perfil comprobados en Android; EV-01/13 |
| RF-02 Terrenos | Lista, alta, detalle y edición conectados a provider/repositorio | FFI comprueba FK y área > 0; captura y recorrido CRUD completo pendientes |
| RF-03 Cultivo/siembra | Lista, formulario, detalle y plan enlazados | Navegación a cultivos y localización de fecha probadas; EV-08; CRUD completo y EV-03/07 pendientes |
| RF-04 Labores/insumos | Formularios accesibles desde detalle del cultivo | Código conectado; captura y recorrido CRUD Android pendientes |
| RF-05 Bitácora | Consulta consolidada, filtros y copia CSV | Pantalla/código presentes; EV-05/11 y comprobación funcional con registros pendientes |
| RF-06 Cosecha | Formulario, repositorio y cálculos enlazados | Código presente; recorrido CRUD y EV-06 pendientes |
| RNF-01 Sin señal | SQLite local sin backend; perfil recuperado tras relanzar sin red | OFF-01 pasa para perfil; no acredita todas las entidades ni operaciones |
| RNF-02 Usabilidad | Formularios y navegación implementados | No evaluado con participantes |
| RNF-03 Integridad | Validadores, FK y checks en SQLite | FFI comprueba tablas/FK/área; otras restricciones pendientes |

## Comprobaciones ejecutadas

- `flutter analyze`: `No issues found!`.
- `flutter test --reporter expanded`: 7 pruebas pasaron (2 SQLite FFI, 5 widget, incluida localización de fecha y diseño adaptable).
- `flutter build apk --debug`: correcto; `build/app/outputs/flutter-apk/app-debug.apk`.
- Android: instalación, inicio y reinicio sin red observados en Samsung SM-A155M Android 14.
- `flutter build windows --debug`: no disponible en este equipo por symlink support deshabilitado.

Las capturas EV-01, EV-08 y EV-13 son evidencia real de bienvenida, formulario de cultivo y persistencia del perfil, respectivamente. EV-02..EV-07 y EV-09..EV-12 permanecen pendientes. EV-08 no prueba guardado de un cultivo. Consultar `RESULTADOS.md` para el alcance preciso de cada comprobación.
