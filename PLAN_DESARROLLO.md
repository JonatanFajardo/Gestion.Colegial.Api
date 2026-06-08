# Plan de Desarrollo — Gestión Colegial (Pantallas Funcionales)

> **Estado:** Fases 1-8 completas ✅ · Scripts 005-028 ejecutados · ADM y API sin errores de compilación  
> **Rama:** `feature/roles-dashboards-pantallas-operativas`  
> **DB:** `DB_GestionColegial` en `(localdb)\MSSQLLocalDB`
>
> **Leyenda de capas:**  
> `[SP]` Stored Procedure SQL · `[R]` Repositorio C# · `[S]` Servicio C# · `[C]` Controlador/Endpoint · `[ADM]` Vista ADM + JS

---

## Estrategia de desarrollo paralelo

> Paralelizar por **capa**, no por fase. Las capas son secuenciales dentro de un módulo (SQL → API → ADM), pero distintos módulos/capas pueden ejecutarse en paralelo.

| Agente | Tarea | Alcance |
|---|---|---|
| **SQL** | Crear todos los SPs faltantes | Fases 3-8 de una vez |
| **API** | Completar endpoints para módulos que ya tienen SP | Lo que ya está listo |
| **ADM** | Crear Buscador + Notificaciones + Perfil en el ADM | 3 módulos sin implementación |

---

## Base ejecutada en DB ✅

| Script | Contenido | Estado |
|---|---|---|
| 005_Roles_Iniciales.sql | 7 roles + asignación de pantallas CRUD existentes | ✅ Ejecutado |
| 006_Tablas_Funcionales.sql | 7 tablas nuevas (Asistencia, Vacaciones, Notificaciones, etc.) | ✅ Ejecutado |
| 007_SPs_Funcionales.sql | 35 SPs (dashboards + CRUD nuevas tablas) | ✅ Ejecutado |
| 008_Pantallas_Funcionales.sql | 46 pantallas en tbPantallas + asignaciones por rol | ✅ Ejecutado |
| 009_Pantallas_Expandidas.sql | 26 pantallas adicionales + asignaciones por rol | ✅ Ejecutado |
| 010_SPs_Fase1.sql | SPs Fase 1 adicionales | ✅ Ejecutado |
| 011_Horarios_Setup.sql | tbHorarios + 5 SPs CRUD (corrige bug tbHorario→tbHorarios) | ✅ Ejecutado |
| 013_Tablas_Fase3.sql | tbPlanClases + tbTareas | ✅ Ejecutado |
| 014_SPs_Fase3.sql | 12 SPs: PlanClases, Tareas, MisAlumnos, MapaOcupacion | ✅ Ejecutado |
| 015_Pantallas_Fase3.sql | 4 pantallas en tbPantallas + asignaciones por rol | ✅ Ejecutado |
| 016_SPs_Fase3_Notas.sql | PR_tbNotas_List/Insert/Update, PR_Boletin_Generate | ✅ Ejecutado |
| 017_SPs_Fase4.sql | PR_Alumnos_Directorio, PR_Alumnos_PiramideMatricula | ✅ Ejecutado |
| 018_SPs_Fase5.sql | tbAsistenciaEmpleados + PR_Empleados_Cumpleanos/Asistencia | ✅ Ejecutado |
| 019_SPs_Fase6.sql | PR_Finanza_PagosDelDia, PendientesCobrar, HistorialTransacciones | ✅ Ejecutado |
| 020_Pantallas_NuevosModulos.sql | 12 pantallas nuevas en tbPantallas | ✅ Ejecutado |
| 021_SPs_Fase5_Resto.sql | tbAnuncios + PR_CumplimientoDocumentos, PR_CentroAnuncios_* | ✅ Ejecutado |
| 022_SPs_Fase7.sql | PR_ComparativoAnios, PR_RendimientoPorSeccion, PR_KPIs_* | ✅ Ejecutado |
| 023_SPs_Fase8.sql | tbSesiones + PR_SesionesActivas, PR_MatrizRolPantallas | ✅ Ejecutado |
| 024_SPs_Fase6_Resto.sql | PR_Finanza_FlujoCaja, EstadoResultados, AnalisisIngresos, PR_Organigrama_GetTree | ✅ Ejecutado |
| 025_SPs_Fase8_Resto.sql | tbConfiguracion + PR_Configuracion_List/Update (con seed data) | ✅ Ejecutado |
| 026_SPs_Fase4_Mensajes.sql | tbMensajes + PR_Mensajes_List/Insert/Delete | ✅ Ejecutado |
| 012_Notas_SPs.sql | PR_tbNotas_Insert (corregido), PR_tbNotas_Update, PR_Notas_CuadernoParcial, PR_Notas_BoletinAlumno | ✅ Ejecutado |
| 012b_Notas_CuadernoParcial.sql | PR_Notas_CuadernoParcial (versión sin join tbMatriculas) | ✅ Ejecutado |
| 027_Pantallas_Fase2_Nuevas.sql | 19 pantallas nuevas + correcciones de acentos (⚠️ generó duplicados en tbPantallas) | ✅ Ejecutado |
| 028_Cleanup_Duplicados.sql | Drop dbo.PR_tbNotas_Insert/Update + elimina 16 pantallas duplicadas (IDs 2068-2073 y 3068-3079) | ✅ Ejecutado |

---

## Fase 1 — Infraestructura compartida (todos los roles) ✅

| Pantalla | SP | R | S | C | ADM |
|---|---|---|---|---|---|
| Login / recuperar contraseña | — | — | — | `UsuarioController` ✅ | ✅ |
| Mi perfil | `UDP_tbUsuarios_Perfil` ✅ | ✅ | ✅ | ✅ | ✅ |
| Notificaciones (campanita) | `PR_tbNotificaciones_*` ✅ | ✅ | ✅ | ✅ | ✅ |
| Buscador global (Ctrl+K) | `PR_BuscadorGlobal` ✅ | ✅ | ✅ | ✅ | ✅ |
| Configuracion de tema | — (frontend only) | — | — | — | — |

---

## Fase 2 — Dashboards por rol ✅

| Pantalla | SP | R | S | C | ADM |
|---|---|---|---|---|---|
| Dashboard Admin | `PR_DashboardAdmin_Resumen` ✅ | ✅ | ✅ | ✅ | ✅ |
| Dashboard Director | `PR_DashboardDirector_KPIs` ✅ | ✅ | ✅ | ✅ | ✅ |
| Dashboard Docente | `PR_DashboardDocente_Hoy` ✅ | ✅ | ✅ | ✅ | ✅ |
| Dashboard Secretaria | `PR_DashboardSecretaria_Resumen` ✅ | ✅ | ✅ | ✅ | ✅ |
| Dashboard Recursos Humanos | `PR_DashboardRRHH_Resumen` ✅ | ✅ | ✅ | ✅ | ✅ |
| Dashboard Caja | `PR_DashboardCajero_Hoy` ✅ | ✅ | ✅ | ✅ | ✅ |
| Dashboard Financiero | `PR_DashboardFinanciero_Resumen` ✅ | ✅ | ✅ | ✅ | ✅ |
| Dashboard Consulta | `PR_DashboardConsulta_KPIs` ✅ | ✅ | ✅ | ✅ | ✅ |

---

## Fase 3 — Módulo Académico ✅

| Pantalla | SP | R | S | C | ADM |
|---|---|---|---|---|---|
| Pase de lista / Asistencia diaria | `PR_tbAsistencia_Insert` ✅ `PR_tbAsistencia_List` ✅ | ✅ | ✅ | ✅ | ✅ |
| Horario semanal | `PR_tbHorarios_*` ✅ (011) | ✅ | ✅ | ✅ | ✅ |
| Cuaderno de notas por parcial | `PR_tbNotas_*` ✅ (016) | ✅ | ✅ | ✅ | ✅ |
| Boletín de calificaciones | `PR_Boletin_Generate` ✅ (016) | ✅ | ✅ | ✅ | ✅ |
| Plan de clases / Sílabo | `PR_tbPlanClases_*` ✅ (014) | ✅ | ✅ | ✅ | ✅ |
| Tareas y entregas | `PR_tbTareas_*` ✅ (014) | ✅ | ✅ | ✅ | ✅ |
| Mis alumnos (galería con foto) | `PR_Docente_MisAlumnos` ✅ (014) | ✅ | ✅ | ✅ | ✅ |
| Mapa de ocupacion de aulas | `PR_Aulas_MapaOcupacion` ✅ (014) | ✅ | ✅ | ✅ | ✅ |
| Mapa de aulas / cupos | — (usa AulasController existente) | — | — | — | ✅ vía MapaAulasAdm |

---

## Fase 4 — Módulo Alumnos

| Pantalla | SP | R | S | C | ADM |
|---|---|---|---|---|---|
| Ficha 360° del alumno | `PR_Alumnos_Ficha360` ✅ | ✅ | ✅ | ✅ | ✅ |
| Wizard de matrícula nueva | — (usa Alumnos/CreateAsync existente) | — | — | — | ✅ vía Alumnos/Create |
| Wizard de re-matrícula masiva | — (usa CuentasCobrar/CargosMasivos) | — | — | — | ✅ vía CargosMasivos |
| Generador de carnets | [ ] complejo — requiere generación de imagen | [ ] | [ ] | [ ] | [ ] |
| Generador de constancias | [ ] complejo — requiere PDF | [ ] | [ ] | [ ] | [ ] |
| Directorio de encargados | `PR_Alumnos_Directorio` ✅ (017) | ✅ | ✅ | ✅ | ✅ |
| Bandeja de documentos pendientes | `PR_tbDocumentosAlumno_List` ✅ `PR_tbDocumentosAlumno_Update` ✅ | ✅ | ✅ | ✅ | ✅ |
| Mensajes a encargados | `PR_Mensajes_*` ✅ (026) | ✅ | ✅ | ✅ | ✅ |
| Piramide de matricula | `PR_Alumnos_PiramideMatricula` ✅ (017) | ✅ | ✅ | ✅ | ✅ |

---

## Fase 5 — Módulo Recursos Humanos

| Pantalla | SP | R | S | C | ADM |
|---|---|---|---|---|---|
| Ficha 360° del empleado | `PR_Empleados_Ficha360` ✅ | ✅ | ✅ | ✅ | ✅ |
| Organigrama interactivo | `PR_Organigrama_GetTree` ✅ (024) | ✅ | ✅ | ✅ | ✅ |
| Calendario de cumpleaños | `PR_Empleados_Cumpleanos` ✅ (018) | ✅ | ✅ | ✅ | ✅ |
| Control de vacaciones / permisos | `PR_tbVacaciones_*` ✅ | ✅ | ✅ | ✅ | ✅ |
| Asistencia de empleados | `PR_Empleados_Asistencia_*` ✅ (018) | ✅ | ✅ | ✅ | ✅ |
| Cumplimiento de documentos empleado | `PR_Empleados_CumplimientoDocumentos` ✅ (021) | ✅ | ✅ | ✅ | ✅ |
| Reporte de antigüedad | `PR_Empleados_Antiguedad` ✅ | ✅ | ✅ | ✅ | ✅ |
| Constancias laborales | [ ] complejo — requiere PDF | [ ] | [ ] | [ ] | [ ] |
| Centro de anuncios | `PR_CentroAnuncios_*` ✅ (021) | ✅ | ✅ | ✅ | ✅ |

---

## Fase 6 — Módulo Financiero / Caja

| Pantalla | SP | R | S | C | ADM |
|---|---|---|---|---|---|
| Estado de cuenta del alumno | `PR_Finanza_EstadoCuenta` ✅ | ✅ | ✅ | ✅ | ✅ |
| Punto de cobro rápido (POS) | — (usa Pagos/NuevoPago existente) | — | — | — | ✅ vía NuevoPago |
| Arqueo de caja | `PR_tbArqueosCaja_Insert` ✅ `PR_tbArqueosCaja_Find` ✅ | ✅ | ✅ | ✅ | ✅ |
| Pagos del día | `PR_Finanza_PagosDelDia` ✅ (019) | ✅ | ✅ | ✅ | ✅ |
| Pendientes por cobrar hoy | `PR_Finanza_PendientesCobrar` ✅ (019) | ✅ | ✅ | ✅ | ✅ |
| Historial de transacciones | `PR_Finanza_HistorialTransacciones` ✅ (019) | ✅ | ✅ | ✅ | ✅ |
| Conciliacion rapida | — (combina PagosDelDia + PendientesCobrar) | — | — | — | ✅ ConciliacionController |
| Comprobante / recibo imprimible | — (usa Pagos/Recibo.cshtml existente) | — | — | — | ✅ vía Recibo |
| Reporte de morosidad | `PR_Finanza_Morosidad_PorNivel` ✅ | ✅ | ✅ | ✅ | ✅ |
| Top alumnos con deuda | `PR_Finanza_TopDeudores` ✅ | ✅ | ✅ | ✅ | ✅ |
| Aging de cuentas por cobrar | `PR_Finanza_AgingCuentas` ✅ | ✅ | ✅ | ✅ | ✅ |
| Flujo de caja proyectado | `PR_Finanza_FlujoCaja` ✅ (024) | ✅ | ✅ | ✅ | ✅ |
| Estado de resultados mensual | `PR_Finanza_EstadoResultados` ✅ (024) | ✅ | ✅ | ✅ | ✅ |
| Asignador masivo de descuentos | — (usa CuentasCobrar/AplicarDescuento existente) | — | — | — | ✅ vía CargosMasivos |
| Generador de recibos masivos | — (usa CuentasCobrar/CargosMasivos existente) | — | — | — | ✅ vía CargosMasivos |
| Analisis ingresos vs egresos | `PR_Finanza_AnalisisIngresos` ✅ (024) | ✅ | ✅ | ✅ | ✅ |

---

## Fase 7 — Reportes

| Pantalla | SP | R | S | C | ADM |
|---|---|---|---|---|---|
| Indicadores académicos / Alumnos en riesgo | `PR_Academico_AlumnosEnRiesgo` ✅ | ✅ | ✅ | ✅ | ✅ |
| Búsqueda global de alumnos | `PR_Alumnos_BusquedaGlobal` ✅ | ✅ | ✅ | ✅ | ✅ |
| Comparativo de años lectivos | `PR_Academico_ComparativoAnios` ✅ (022) | ✅ | ✅ | ✅ | ✅ |
| Rendimiento por sección | `PR_Academico_RendimientoPorSeccion` ✅ (022) | ✅ | ✅ | ✅ | ✅ |
| KPIs académicos | `PR_KPIs_Academicos` ✅ (022) | ✅ | ✅ | ✅ | ✅ |
| KPIs financieros | `PR_KPIs_Financieros` ✅ (022) | ✅ | ✅ | ✅ | ✅ |
| Reportes pre-generados | — (landing page con links a todos los reportes) | — | — | — | ✅ ReportesPregeneradosController |
| Visor de gráficos consolidados | — (usa DashboardAdmin + DashboardFinanciero) | — | — | — | ✅ VisorGraficosController |
| Reportes financieros descargables | — (exportar vía Importador/tabs Exportar) | — | — | — | ✅ vía ImportadorController |

---

## Fase 8 — Seguridad / Admin

| Pantalla | SP | R | S | C | ADM |
|---|---|---|---|---|---|
| Bitácora de actividad | `PR_tbBitacora_List` ✅ | ✅ | ✅ | ✅ | ✅ |
| Sesiones activas | `PR_SesionesActivas_List` ✅ (023) | ✅ | ✅ | ✅ | ✅ |
| Configuración del sistema | `PR_Configuracion_List/Update` ✅ (025) | ✅ | ✅ | ✅ | ✅ |
| Backup & restore | [ ] complejo — requiere permisos SQL Server | [ ] | [ ] | [ ] | [ ] |
| Logs de errores (Serilog) | — (lee archivos .log del disco) | — | — | — | ✅ LogsErroresController |
| Importador / Exportador masivo | — (CSV upload + export links) | — | — | — | ✅ ImportadorController |
| Matriz visual Rol × Pantallas | `PR_MatrizRolPantallas_Get` ✅ (023) | ✅ | ✅ | ✅ | ✅ |

---

## Progreso general (actualizado)

| Fase | Pantallas | SP listos | API lista | ADM lista |
|---|---|---|---|---|
| 1. Infraestructura | 5 | 5/5 ✅ | 5/5 ✅ | 5/5 ✅ |
| 2. Dashboards | 8 | 8/8 ✅ | 8/8 ✅ | 8/8 ✅ |
| 3. Académico | 9 | 9/9 ✅ | 9/9 ✅ | 9/9 ✅ |
| 4. Alumnos | 9 | 7/9 ✅ | 7/9 ✅ | 7/9 ✅ |
| 5. RRHH | 9 | 8/9 ✅ | 8/9 ✅ | 8/9 ✅ |
| 6. Financiero/Caja | 16 | 14/16 ✅ | 14/16 ✅ | 16/16 ✅ |
| 7. Reportes | 9 | 7/9 ✅ | 7/9 ✅ | 9/9 ✅ |
| 8. Seguridad/Admin | 7 | 5/7 ✅ | 5/7 ✅ | 6/7 ✅ |
| **Total** | **72** | **63/72** | **63/72** | **68/72** |
> Nota: Las 9 pantallas sin SP/API son módulos complejos (carnets, constancias PDF, backup) o frontends puros (conciliación rápida, reportes pre-generados, visor de gráficos, importador, logs).

---

## Pendiente — Módulos complejos que requieren infraestructura extra

Estos módulos están identificados como pendientes porque requieren generación de PDF, imágenes, o permisos especiales:

### Fase 4 (Alumnos)
- **Generador de carnets** — requiere librería de generación de imágenes (SkiaSharp/iTextSharp)
- **Generador de constancias** — requiere librería PDF (iTextSharp/FastReport)

### Fase 5 (RRHH)  
- **Constancias laborales** — requiere librería PDF

### Fase 8 (Admin)
- **Backup & restore** — requiere permisos `BACKUP DATABASE` en SQL Server (riesgo de seguridad)

---

## Notas

- Los SPs marcados ✅ ya existen en DB. Los `[ ]` hay que crearlos.
- Script `011_Horarios_Setup.sql` debe ejecutarse con el ejecutor de scripts antes de usar el módulo Horarios.
- Cada pantalla nueva en la API sigue el patrón: `SP → Repositorio → Servicio → Controlador`.
- El frontend (Razor / React / Blazor) es un proyecto separado — este plan cubre solo la API.
- Al completar una fila, marcar las celdas con ✅.
- Crear SPs nuevos en `Scripts/0XX_SPs_FaseX.sql` y ejecutarlos con el ejecutor de scripts.
