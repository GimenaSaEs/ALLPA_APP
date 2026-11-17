# Casos de prueba ejecutados y pendientes

## Ejecutados

| ID | Caso | Resultado |
|---|---|---|
| DB-01 | Crear esquema SQLite FFI y comprobar siete tablas + FK activas | Pasó |
| DB-02 | Insertar agricultor/terreno sintético relacionado y rechazar área cero | Pasó |
| UI-01 | Abrir bienvenida ALLPA sin datos de inicio | Pasó |
| UI-02 | Desde bienvenida navegar al formulario de perfil | Pasó |
| UI-03 | Navegar en panel a terrenos y cultivos | Pasó |
| UI-04 | Formatear fecha y abrir selector de fecha en español | Pasó en widget y verificado en Android dentro del formulario de cultivo; EV-08 |
| UI-05 | Presentar detalle del terreno en ancho reducido con texto ampliado | Pasó en widget a 360×800 y escala 1.4; verificación visual Android sin overflow |
| OFF-01 | Apagar Wi-Fi/datos, forzar cierre y relanzar; comprobar perfil local | Pasó para el perfil sintético en Samsung SM-A155M Android 14; evidencia EV-13 |

## Pendientes

- Validar alta/edición/consulta de terrenos, cultivos, planes, labores, insumos y cosechas en Android.
- Comprobar unicidad de plan/cosecha, eliminaciones y checks restantes.
- Probar persistencia sin red de entidades agrícolas además del perfil.
- Ejecutar prueba guiada de usabilidad con participantes e instrumento aprobado.
- Completar capturas reales EV-02..EV-07 y EV-09..EV-12. EV-01, EV-08 y EV-13 cuentan con capturas reales.

Los comandos y resultados están en `RESULTADOS.md`. Los pendientes no se cuentan como ejecutados.
