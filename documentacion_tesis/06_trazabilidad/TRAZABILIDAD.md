# Trazabilidad requisito → código → prueba

La trazabilidad distingue presencia de implementación y verificación efectivamente ejecutada. Consulte `05_pruebas/REVISION_DOCUMENTACION_VS_CODIGO.md` para el dictamen comparativo.

| Req. tesis | Código/interfaz | Prueba/evidencia | Estado verificado |
|---|---|---|---|
| RF-01 Perfil agricultor | `WelcomeScreen`, `PerfilScreen`, `AgricultorRepository`, `AllpaProvider` | UI-01/UI-02; EV-01; OFF-01/EV-13 | Bienvenida y navegación probadas; perfil sintético guardado y recuperado sin red tras relanzamiento |
| RF-02 Terrenos | `TerrenosListScreen`, formularios/detalle, `TerrenoRepository` | DB-02 parcial; EV-02/10 pendientes | Código conectado; restricción y FK probadas en SQLite FFI, recorrido CRUD Android pendiente |
| RF-03 Cultivo/siembra | `CultivosListScreen`, formularios/detalle, `PlanSiembraRepository` | UI-03 navegación; EV-03/07/08 pendientes | Código conectado; CRUD completo no probado |
| RF-04 Labores e insumos | formularios/repositorios desde detalle de cultivo | EV-04 pendiente | Código conectado; captura y recorrido CRUD pendientes |
| RF-05 Bitácora | `BitacoraScreen`, `BitacoraRepository`, filtros/CSV | EV-05/11 pendientes | Interfaz/código presente; verificación con registros pendiente |
| RF-06 Cosecha | `CosechaFormScreen`, `CosechaRepository`, cálculos | EV-06 pendiente | Código conectado; recorrido CRUD pendiente |
| RNF-01 Sin señal | `DatabaseHelper`, SQLite local y repositorios | OFF-01; EV-13 | Persistencia del perfil comprobada; otras entidades/operaciones offline pendientes |
| RNF-02 Usabilidad | formularios y navegación | evaluación con participantes pendiente | No evaluado |
| RNF-03 Integridad | `Validators`, migración SQLite, claves y checks | DB-01/DB-02 | Tablas/FK/área cero cubiertos; más restricciones pendientes |
