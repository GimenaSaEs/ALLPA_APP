# Mejoras de ALLPA

Esta revisión corrige la validación de datos y el seguimiento del respaldo local de la bitácora. Mantiene las fórmulas y los datos de referencia de UP-ILL-001.

## Cambios

- Las superficies, semillas, jornales y tiempos rechazan NaN e infinito mediante errores de validación controlados.
- Los campos numéricos del dominio admiten coma decimal. La creación de parcela también admite hectáreas como `1,2`.
- La modalidad de siembra exige una respuesta booleana; una entrada inválida ya no se interpreta como siembra con apoyo.
- Una campaña nueva queda pendiente de respaldo, incluso con señal. Modificar plan, siembra, labor o cosecha vuelve a marcarla como pendiente.
- La interfaz identifica el respaldo como local y no afirma que se haya enviado a un servidor.
- El calendario se abre en la fecha actual para nuevos registros.
- Las etiquetas de avance de las chacras se distribuyen en varias líneas cuando falta espacio horizontal.

## Pruebas añadidas

| Archivo | Casos | Qué comprueba |
|---|---:|---|
| `Codigo/test/validacion_regresion_test.dart` | 4 | Superficies no finitas, semilla/jornales/tiempo inválidos, coma decimal y modalidad de siembra |
| `Codigo/test/respaldo_regresion_test.dart` | 3 | Campaña nueva pendiente, cambios después de respaldar y fallo de escritura del respaldo |

La suite incluye las 30 pruebas existentes y estos 7 casos nuevos. La ejecución final obtuvo **37 pruebas aprobadas y 0 fallidas**. El registro completo está en `resultado_pruebas.txt`.

El análisis estático final no encontró errores ni advertencias; reportó 35 avisos informativos, principalmente APIs de interfaz deprecadas. El registro está en `analisis_flutter.txt`. No se realizó una migración completa de esas APIs en esta revisión.

La compilación de Windows se intentó, pero el equipo no dispone de los componentes C++ y Windows SDK requeridos por Flutter. El ejecutable Windows original no fue recompilado.

La compilación Android terminó correctamente y generó el APK **ALLPA_MEJORADO_1.0.1.apk**, versión 1.0.1, código de versión 2. Se compiló con `flutter build apk --release --build-name=1.0.1 --build-number=2`. El registro está en `compilacion_android.txt`. Conserva la firma de depuración configurada en el proyecto y se entrega para pruebas, no como una publicación en Google Play.

Las comprobaciones manuales de la siguiente sección quedan pendientes; las pruebas automatizadas no sustituyen el uso en un teléfono real.

## Ejecutar las pruebas

La revisión final se verificó con Flutter 3.44.0 y Dart 3.12.0. Flutter actualizó dos dependencias transitivas del archivo de bloqueo y las opciones de compatibilidad de Gradle durante la preparación. Usar esa misma versión permite reproducir el entorno. Desde `Codigo`, con Flutter instalado:

```powershell
flutter test --reporter expanded
flutter analyze --no-fatal-infos
```

En Windows, colocar el SDK de Flutter en una ruta sin espacios. Esta versión de Dart puede fallar al construir los componentes nativos de SQLite si la ruta del SDK contiene espacios. Para esta revisión se usó un enlace temporal al SDK; el proyecto permaneció en su carpeta original.

## Comprobación manual recomendada

1. Ingresar con una unidad nueva y crear una chacra. Confirmar el estado pendiente de respaldo.
2. Crear el respaldo local. Confirmar el cambio de estado.
3. Registrar la siembra con señal activada. Confirmar que vuelve a quedar pendiente y que el siguiente respaldo contiene la siembra.
4. Desactivar el modo de señal del aplicativo, registrar una labor, cerrar y abrir. Confirmar que el registro permanece.
5. Cargar el ejemplo UP-ILL-001 y comprobar los indicadores de referencia.
6. Probar la lista de chacras en un teléfono estrecho y con texto ampliado.

## Alcance del respaldo y de la verificación

`Con señal / Sin señal` es un modo manual de prueba; no detecta la conectividad real del dispositivo. La acción de respaldo escribe un archivo JSON local y conserva la restricción de señal del proyecto. No implementa almacenamiento en la nube, envío a un servidor ni restauración desde archivo. Una copia en el mismo dispositivo no protege frente a la pérdida del equipo.

Los 45 segundos y demás valores de UP-ILL-001 proceden del ejemplo precargado. Las pruebas de ese ejemplo comprueban consistencia de cálculos y comportamiento técnico; no acreditan mediciones de usabilidad con productores ni mejoras agrícolas observadas.

El APK nuevo se entrega por separado. Los archivos `allpa.exe` y `allpa.apk` originales del repositorio no se sustituyeron. Las modificaciones están en la copia local; no se enviaron a GitHub.

Antes de actualizar una instalación con datos importantes, conservar una copia externa de los datos. Si Android informa de una firma incompatible, no desinstalar la aplicación existente sin preservar primero sus datos: desinstalar puede eliminar la base local. El respaldo JSON actual no tiene una función de restauración implementada.
