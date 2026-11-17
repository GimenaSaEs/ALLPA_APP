# ALLPA 1.0.2

Esta versión incorpora un icono propio y permite compartir el respaldo desde Android.

## Icono

Un brote claro sobre surcos dorados identifica la bitácora agrícola. El fondo verde mantiene los colores de ALLPA. Android incluye un icono adaptable a la forma del lanzador y una alternativa para versiones anteriores. El código de Windows también incluye el nuevo icono, aunque el ejecutable Windows no se recompiló.

La fuente editable está en `Codigo/assets/allpa_icon.svg`; la vista previa, en `Codigo/assets/allpa_icon.png`.

## Compartir el respaldo

1. Instalar el APK 1.0.2 como actualización de la versión anterior.
2. Ingresar con el código de la unidad productiva.
3. En la pantalla de chacras, pulsar **Compartir respaldo**. Mantener activado el modo **Con señal** del aplicativo, conforme a la restricción del proyecto.
4. Elegir una aplicación disponible en el menú de Android, por ejemplo WhatsApp, correo o Drive.
5. Elegir el destinatario o la carpeta y confirmar el envío en esa aplicación.

ALLPA genera un archivo JSON actualizado con **todas las unidades productivas guardadas en ese celular**, no solo la unidad abierta. Incluye identificación, planes, siembras, labores y cosechas. Compartirlo requiere escoger conscientemente el destinatario. ALLPA no envía nada automáticamente ni confirma la entrega en la aplicación elegida.

El archivo compartido tiene fecha y hora en su nombre. Se comparte una copia temporal de solo lectura mediante el selector de Android; la base de datos privada permanece dentro de ALLPA. La función está implementada con un canal Flutter y un FileProvider limitado a la carpeta temporal de respaldos.

La opción **Crear respaldo local** continúa disponible. El modo de señal es manual, no una medición de conectividad. El envío por WhatsApp, correo o Drive depende de la conexión y de la aplicación seleccionada. Aún no existe importación o restauración desde JSON ni sincronización automática con un servidor.

## Verificación

- 39 pruebas automatizadas aprobadas, incluidas dos sobre la comunicación con Android para compartir.
- Análisis estático sin errores ni advertencias; 35 avisos informativos de APIs y estilo existentes.
- La vista previa del icono se revisó visualmente.
- La prueba de enviar y recibir el archivo en un teléfono real queda pendiente. Las pruebas del canal no sustituyen esa comprobación.

Registros: `resultado_pruebas_1.0.2.txt`, `analisis_flutter_1.0.2.txt` y `compilacion_android_1.0.2.txt`. Entorno: Flutter 3.44.0 y Dart 3.12.0, con el SDK en una ruta sin espacios.

El APK mantiene la firma de depuración del proyecto para pruebas. Si Android indica firma incompatible, no desinstalar una instalación con datos importantes sin conservarlos antes: desinstalar puede eliminar la base local. Los cambios permanecen en la copia local y no se han enviado a GitHub.
