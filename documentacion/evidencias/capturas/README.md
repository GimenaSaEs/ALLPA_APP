# Capturas del código de ALLPA

Capturas originales proporcionadas por Gimena durante la revisión del código en VS Code. Se conservaron sin alterar su contenido.

| Captura | Archivo y contenido visible |
|---|---|
| [Configuración SQLite](codigo/01_configuracion_sqlite.png) | `lib/datos/base_datos.dart`: inicialización del motor, rutas de almacenamiento y creación del esquema. |
| [Superficie disponible](codigo/02_validacion_superficie_disponible.png) | `lib/dominio/reglas.dart`: función `validarSuperficieDisponible`, líneas 65 a 79. |
| [Superficie usada](codigo/03_validacion_superficie_usada.png) | `lib/dominio/reglas.dart`: función `validarSuperficieUsada`, líneas 81 a 95; rechazo de superficie excedida. |
| [Validación de cosecha](codigo/04_validacion_cosecha.png) | `lib/dominio/reglas.dart`: función `validarCosecha`, líneas 216 a 233; exige siembra previa y limita el área cosechada. |

Estas imágenes documentan la implementación visible. Los resultados de ejecución se encuentran en los registros de la carpeta superior. Las capturas del código no sustituyen las pruebas manuales del aplicativo en un teléfono.
