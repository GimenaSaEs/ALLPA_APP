# EV-13 — Persistencia tras reinicio sin red

- Estado: captura real verificada visualmente.
- Versión: ALLPA debug `1.0.0+1`.
- Dispositivo: Samsung SM-A155M, Android 14 (API 34).
- Fecha: 2026-11-17, aproximadamente 13:33 (America/Lima).
- Datos: perfil sintético `Agricultor demo`; sin documento ni teléfono.
- Pasos: desactivar Wi-Fi y datos móviles; confirmar ambas radios apagadas; forzar cierre de ALLPA; volver a abrir; capturar el panel mostrado; reactivar las radios al terminar.
- Resultado observado: se mostró el panel y el perfil `Agricultor demo` con sus indicadores vacíos. Resultado correcto para persistencia del perfil local.
- Archivo: `EV-13_persistencia_sin_red.png`.
- Alcance: demuestra recuperación local de ese perfil después de reiniciar la app sin red. No prueba persistencia de terrenos, cultivos, labores u otras entidades.
