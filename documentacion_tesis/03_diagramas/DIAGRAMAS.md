# Diagramas derivados de la implementación

## Componentes y flujo

```mermaid
flowchart TD
  M[main.dart] --> P[AllpaProvider]
  P --> I{Perfil guardado?}
  I -->|No| W[WelcomeScreen]
  W --> F[PerfilScreen]
  I -->|Sí| H[HomeDashboardScreen]
  F --> H
  H --> T[Terrenos]
  H --> C[Cultivos]
  H --> B[Bitácora]
  H --> R[Indicadores]
  C --> D[Detalle de cultivo]
  D --> PS[Plan de siembra]
  D --> L[Labores]
  D --> N[Insumos]
  D --> CO[Cosecha]
  P --> RE[Repositorios]
  RE --> DB[(SQLite local)]
```

## Entidades y relaciones

```mermaid
erDiagram
  AGRICULTOR ||--o{ TERRENO : posee
  TERRENO ||--o{ CULTIVO : contiene
  CULTIVO ||--o| PLAN_SIEMBRA : programa
  CULTIVO ||--o{ LABOR : registra
  CULTIVO ||--o{ INSUMO : consume
  CULTIVO ||--o| COSECHA : produce
```

Los diagramas reflejan componentes y relaciones observables en el código y el esquema SQLite. La prueba Android OFF-01 confirma persistencia del perfil sintético tras relanzar sin red (EV-13), no la persistencia de todas las entidades ni aceptación de usuarios. Para el detalle de verificaciones, consulte `../05_pruebas/RESULTADOS.md`.
