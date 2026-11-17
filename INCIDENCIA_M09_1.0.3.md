# Corrección de la incidencia M09

## Evidencia observada

En ALLPA 1.0.2, la pantalla Pruebas del aplicativo mostraba Funciones cubiertas letra por letra y la lista de funciones excedía el espacio disponible. La captura enviada durante el testeo manual confirma el defecto de presentación. No demuestra un error en los indicadores numéricos.

## Causa y corrección

El valor largo se dibujaba sin una restricción de ancho y dejaba el título sin espacio dentro de una fila. En 1.0.3, FilaCalidad mide ambos textos considerando el tamaño de letra del dispositivo. Cuando no caben, coloca el título arriba y el valor debajo, con saltos de línea. Cuando caben, conserva la presentación horizontal.

La corrección se aplica a las filas de indicadores de la pantalla de calidad, no solo al texto de funciones. No cambia las fórmulas ni los registros agrícolas.

## Comprobaciones

La suite final obtuvo 42 pruebas aprobadas y 0 fallidas. Los tres casos nuevos verifican la lista larga a 280 píxeles lógicos, el ancho de 240 con texto al 150 % y un valor corto a 520. El archivo es Codigo/test/fila_calidad_test.dart.

Los informes Word anteriores documentan la revisión de 1.0.2 y sus 39 pruebas. Este registro complementa esos informes para la revisión 1.0.3; no se sustituyen sus resultados históricos.

## Repetición en el teléfono

1. Instalar ALLPA 1.0.3 como actualización, sin desinstalar la versión anterior ni borrar datos.
2. Abrir Pruebas del aplicativo con las siete funciones cubiertas.
3. Confirmar que el título se lee horizontalmente y la lista se ajusta debajo cuando no cabe a su lado.
4. Repetir con el texto del teléfono ampliado y comprobar que no haya recortes.
5. Conservar una captura del resultado junto con la captura del defecto original y registrar el modelo de teléfono y Android.

Estado: corregida en el código y verificada con pruebas automatizadas. Falta confirmar la corrección visual en el teléfono donde se observó el defecto antes de cerrar M09.
