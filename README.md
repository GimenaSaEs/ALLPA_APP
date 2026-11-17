# Allpa — Bitácora Agrícola para Illpe

## Actualización 1.0.3

El código actual incorpora validación de números no finitos y coma decimal, seguimiento correcto del respaldo, icono propio, menú de Android para compartir el JSON y corrección del texto comprimido en Pruebas del aplicativo (incidencia M09).

- **Instalador Android actualizado:** descargar `ALLPA_MEJORADO_1.0.3.apk` desde [la versión de pruebas 1.0.3](https://github.com/GimenaSaEs/ALLPA_APP/releases/tag/v1.0.3). Los binarios `allpa.apk` y `allpa.exe` conservados en la raíz corresponden a la entrega anterior.
- **Verificación actual:** 42 pruebas automatizadas aprobadas; análisis sin errores ni advertencias y con 34 avisos informativos. Los resultados están en [documentacion/evidencias](documentacion/evidencias).
- **Documentos:** [informe de pruebas](documentacion/INFORME_PRUEBAS_ALLPA.docx) y [análisis descriptivo](documentacion/ANALISIS_RESULTADOS_ALLPA.docx). Esos Word documentan la versión 1.0.2 y sus 39 pruebas; [el registro M09](INCIDENCIA_M09_1.0.3.md) complementa la revisión para 1.0.3. Falta confirmar la corrección visual en el teléfono del usuario.
- **Respaldo:** se crea un archivo JSON local con todas las unidades del dispositivo. Compartir respaldo abre el selector de Android; el usuario elige el destino y confirma allí. No hay entrega automática, restauración desde JSON ni detección real de conectividad. Con señal / Sin señal es un modo manual de prueba.
- **Caso UP-ILL-001:** es el ejemplo precargado para verificar cálculos. Los 45 segundos no son una medición realizada con un productor. La cobertura de siete funciones no equivale a cobertura de código.

Entorno verificado: Flutter 3.44.0 y Dart 3.12.0. En Windows, usar una ruta del SDK sin espacios para evitar problemas al construir los componentes nativos de SQLite. El APK conserva la firma de depuración del proyecto y se distribuye para pruebas. Instalar como actualización; no desinstalar una instalación con datos importantes si aparece un conflicto de firma.

La documentación de la entrega original se conserva a continuación como referencia histórica; sus cifras de 30 pruebas y sus descripciones de sincronización deben leerse junto con las precisiones de esta actualización.

## Propósito

Allpa registra la campaña agrícola de una unidad productiva en el centro poblado de Illpe, Pachamarca, Churcampa, Huancavelica. El programa se desarrolló e implementó conforme a los requisitos, reglas de negocio, indicadores agronómicos y criterios de aceptación descritos en los Capítulos III, IV y V de la tesis (*CCENTE-SALAZAR-ZEVALLOS*). El almacenamiento principal se conserva íntegramente en SQLite en el dispositivo móvil y funciona al 100 % sin conexión a internet.

La carpeta contiene el ejecutable para Windows (`allpa.exe`), el instalador Android (`allpa.apk`) y el código fuente completo en Flutter dentro de `Codigo/`.

---

## Mejoras de Diseño y Experiencia de Usuario (UI/UX)

La versión actualizada incorpora un diseño moderno basado en **Material 3**, optimizado para el trabajo en campo de los productores agrícolas y para la sustentación académica:

1. **Identidad Visual Agrícola y Andina:**
   - Paleta de color armónica inspirada en la tierra fértil ("*Allpa*"): Verde bosque esmeralda (`#1B4D3E`), verde hoja (`#2D6A4F`), tonos trigo/dorado andino (`#C07A2B` y `#FDE8C8`) y fondo cálido tipo lienzo/papel (`#F7F5EE`).
   - Jerarquía tipográfica legible con encabezados destacados, subtítulos claros e insignias contextuales para los cultivos tradicionales (cebada, trigo, arveja, maíz amiláceo y haba).

2. **Panel de Control del Productor (Dashboard):**
   - Tarjetas métricas (KPIs) en tiempo real: número de chacras, porcentaje de superficie sembrada y estado del plan escrito.
   - Píldoras interactivas de estado de sincronización (`Respaldo sincronizado` / `Pendiente sin señal`).
   - Selector visual de cobertura en la barra superior con interruptor dinámico **Con señal / Sin señal**.

3. **Flujo de las Siete Funciones de Campaña:**
   - Matriz visual interactiva en la pantalla de detalle que muestra el avance paso a paso: *Parcela*, *Plan*, *Siembra*, *Labor*, *Insumo*, *Consulta* y *Cosecha*.
   - Botones de acción contextuales según la etapa de la campaña (ej. habilitación de cosecha posterior a la siembra conforme a RN-05).

4. **Registro Rápido y Herramientas en Campo:**
   - **Cronómetro activo en pantalla de labor (RNF-02):** Medición precisa en segundos del tiempo de captura con fichas táctiles de selección rápida para labores frecuentes (arado, deshierbo, aporque, riego, etc.).
   - **Cálculo en vivo de rendimiento (RF-12):** En la pantalla de cosecha, calcula automáticamente el rendimiento estimado en kg/ha a medida que se ingresa el área y los kilogramos cosechados.
   - **Selectores táctiles de modalidad:** Tarjetas estilizadas para indicar siembra individual vs. con apoyo familiar/ayni.

5. **Pantalla de Verificación y Sustentación de Tesis:**
   - Cuadro de mando de contraste frente a la **Tabla 21 / 25 del Capítulo V**: evaluación automática de los 15 criterios de aceptación con insignias de cumplimiento (`CUMPLE 100%`).
   - Auditoría en vivo de las **22 tablas de SQLite** con conteo de registros e integridad referencial (`PRAGMA foreign_keys = ON`).

---

## Funciones de Campaña y Requisitos

| Pantalla | Trabajo que realiza | Requisito Tesis |
|---|---|---|
| **Ingreso** | Valida el código de unidad productiva (RN-01) y permite cargar el caso de estudio UP-ILL-001. | RF-01 |
| **Inicio / Mis chacras** | Dashboard del productor, resumen de indicadores de gestión y acceso a respaldo. | RF-02, RF-08 |
| **Nueva chacra** | Registra parcela, piso ecológico (valle, quechua, suni, puna) y plan escrito con labores. | RF-02, RF-03 |
| **Detalle de chacra** | Muestra el avance de las 7 funciones, desfase de siembra en días y lista de labores. | RF-01 a RF-07 |
| **Siembra** | Guarda fecha real, hectáreas sembradas, modalidad individual, semilla (insumo) y jornales. | RF-04, RF-05 |
| **Labor** | Registra actividad, fecha, jornales y cronometra el tiempo de captura en segundos. | RF-06, RNF-02 |
| **Cosecha** | Registra superficie cosechada, producción en kg y calcula rendimiento en kg/ha. | RF-07, RF-12 |
| **Ficha de gestión** | Calcula las tres dimensiones de la variable dependiente (manejo, recursos y cosecha). | RF-08, RF-12 |
| **Pruebas del aplicativo** | Evalúa la variable independiente: cobertura, tareas, usabilidad, disponibilidad y fallos. | RNF-01 a RNF-03 |
| **Verificación UP-ILL-001** | Contrasta los valores del Capítulo V (Tabla 21) y audita las 22 tablas SQLite. | Cap. V |

---

## Reglas de Negocio Implementadas

- **RN-01:** Código de unidad entre 3 y 20 caracteres alfanuméricos o guiones.
- **RN-02:** Admisión exclusiva de los 5 cultivos del estudio (cebada, trigo, arveja, maíz amiláceo y haba).
- **RN-03:** Hectáreas previstas, sembradas y cosechadas no superan la superficie de la parcela.
- **RN-04:** Registro único de siembra por campaña agrícola.
- **RN-05:** Cosecha exige siembra previa y no supera las hectáreas sembradas.
- **RN-06:** El plan escrito se congela cuando la siembra ya está registrada.
- **RN-07:** Hay plan escrito si existen cultivo, hectáreas previstas, fecha prevista y al menos una labor.
- **RN-08:** Sin señal no se envía el respaldo; el dato permanece protegido en el dispositivo móvil.
- **RN-09:** Las validaciones de regla rechazadas se auditan como rechazos controlados, no como fallos del sistema.
- **RN-10:** Los jornales familiares suman los jornales de siembra más todas las labores ejecutadas.

---

## Base de Datos SQLite (22 Tablas)

El diccionario de datos del sistema está implementado en SQLite (esquema v2) con claves foráneas activadas:
`comunidad`, `productor`, `unidad`, `cultivo`, `tipo_labor`, `piso_ecologico`, `parcela`, `campana`, `plan`, `plan_labor`, `siembra`, `insumo`, `labor`, `cosecha`, `indicador_ficha`, `evento_app`, `sesion_prueba`, `respaldo`, `rechazo_regla`, `configuracion`, `evidencia` y `sincronizacion_log`.

En Windows, la base de datos se almacena en `%LOCALAPPDATA%\Allpa\allpa.db`; en Android, dentro del almacenamiento interno protegido del aplicativo.

---

## Resultados de Verificación UP-ILL-001 (Aceptación Tesis)

Al pulsar **Cargar ejemplo de Illpe**, se reproduce la campaña de cebada (Pampa de Illpe, piso quechua, 2027) con los valores exactos reportados en la investigación:

- **Plan escrito:** Sí (100 %)
- **Desfase de siembra:** 8 días
- **Registros agronómicos completos:** 100 %
- **Superficie sembrada:** 60 % (1,2 ha de 2,0 ha disponibles)
- **Dosis de semilla:** 75 kg/ha (90 kg sembrados)
- **Siembra individual:** Sí (sin apoyo familiar)
- **Jornales familiares:** 6 jornales
- **Rendimiento agrícola:** 2 400 kg/ha
- **Producción total:** 2 640 kg en 1,1 ha cosechadas
- **Productividad:** 440 kg/jornal
- **Cobertura de funciones:** 100 % (7 de 7)
- **Tiempo de registro de labor:** 45 s (cronometrado)
- **Fallos de operación:** 0 fallos
- **Tablas SQLite verificadas:** 22 tablas

---

## Cómo Ejecutar el Software

### 1. Ejecutar en Windows
Abra directamente el archivo ejecutable `allpa.exe` en esta carpeta.

Para recompilar o ejecutar en modo desarrollo desde el código fuente:
```powershell
cd .\Codigo
flutter pub get
flutter run -d windows
```

### 2. Ejecutar o Instalar en Android
El paquete instalador listo para sustentación está en la raíz: `allpa.apk`. Puede instalarlo mediante cable USB con depuración activada o transferirlo directamente al dispositivo móvil.

Para recompilar el APK de producción:
```powershell
cd .\Codigo
flutter build apk --release
Copy-Item .\build\app\outputs\flutter-apk\app-release.apk ..\allpa.apk -Force
```

### 3. Suite de Pruebas Automatizadas
Para verificar el 100 % de las pruebas automatizadas (30 pruebas unitarias, de integración y de widgets):
```powershell
cd .\Codigo
flutter test
```
