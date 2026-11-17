# Diagramas derivados del código

Estos diagramas reflejan clases y relaciones de persistencia presentes. No afirman que los flujos estén accesibles desde la app ejecutable.

```mermaid
flowchart LR
  UI[Pantallas parciales] --> P[AllpaProvider]
  P --> R[Repositorios]
  R --> H[DatabaseHelper]
  H --> M[DatabaseMigrations]
  H --> DB[(SQLite local)]
  R --> C[Consultas bitácora e indicadores]
  C --> P
```

```mermaid
flowchart TD
  A[Inicio de alta] --> B{Formulario y validadores}
  B -->|válido| C[Provider guarda]
  B -->|inválido| D[Mensaje de validación]
  C --> E[Repositorio]
  E --> F[(SQLite)]
  F --> G[Recarga de estado]
```

El modelo entidad-relación está en `../02_base_datos/ESQUEMA_SQLITE.md`. El diagrama de casos de uso aún es una especificación de requerimientos: perfil, terrenos, cultivos/siembra, labores/insumos, bitácora y cosecha; su aceptación debe comprobarse luego de integrar la navegación.