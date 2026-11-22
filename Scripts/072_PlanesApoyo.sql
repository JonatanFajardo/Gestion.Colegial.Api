/* =============================================================================
   072 · Plan de apoyo al alumno  (espejo de Skuul: support_plans, support_plan_actions,
         support_plan_notes, support_plan_status_changes)

   - Dirección detecta a un alumno en riesgo y abre un plan: objetivo (título y resumen),
     categoría, responsable, fecha de inicio y de revisión, pasos con responsable y fecha
     límite, notas de seguimiento e historial de estados.
   - Categorías: refuerzo (Refuerzo académico) · orientacion (Orientación) · conducta ·
     salud · adecuacion (Adecuación curricular).
   - Estados (FN_PlanApoyo_Siguientes, mismas transiciones que Skuul):
       borrador  → activo, cancelado
       activo    → en_pausa, completado, cancelado
       en_pausa  → activo, completado, cancelado
       completado→ activo (reabrir)
       cancelado → (ninguno)
     Pausar, cancelar y reabrir piden motivo. Completado y cancelado ya no aceptan pasos
     ni notas hasta reabrir el plan. Al cerrarse se anota la fecha de fin; al reabrir se borra.
   - Responsables (del plan y de cada paso) = USUARIOS (seguridad.tbUsuarios), no empleados:
     varios usuarios pueden compartir el mismo empleado. Solo usuarios activos con rol admin,
     director o Docente.
   - Quién lee un plan (FN_PlanesApoyo_Visibles):
       · @VerTodos = 1 (permiso "Gestionar planes de apoyo") o el plan es suyo: responsable,
         quien lo creó o responsable de algún paso;
       · y si es confidencial: permiso "Ver planes confidenciales", responsable o creador
         (igual que la policy de Skuul). Un plan confidencial no aparece en listas, conteos ni
         consultas directas para nadie más.
   - Avisos: al asignar el plan o un paso, y al cerrarse el plan, se avisa al responsable en
     app.tbNotificaciones (si no es quien hizo el cambio).
   - Prefijos: Apo_ (plan), Apa_ (pasos), Apn_ (notas), Ape_ (estados). Pla_ ya lo usa
     app.tbPlanClases.

   Solo agrega objetos nuevos; se puede ejecutar varias veces.
   Crear SIEMPRE con QUOTED_IDENTIFIER ON (índices filtrados y STRING_SPLIT).
   ============================================================================= */
USE [DB_GestionColegial]
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO

/* ---------------------------------------------------------------- Tablas */
IF OBJECT_ID('app.tbPlanesApoyo') IS NULL
BEGIN
    CREATE TABLE app.tbPlanesApoyo
    (
        Apo_Id              int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbPlanesApoyo PRIMARY KEY,
        Alu_Id              int            NOT NULL CONSTRAINT FK_tbPlanesApoyo_tbAlumnos REFERENCES app.tbAlumnos (Alu_Id),
        Ani_Id              int            NULL     CONSTRAINT FK_tbPlanesApoyo_tbAnioLectivo REFERENCES app.tbAnioLectivo (Ani_Id),
        Apo_Categoria       varchar(20)    NOT NULL CONSTRAINT DF_tbPlanesApoyo_Categoria DEFAULT ('refuerzo'),
        Apo_Estado          varchar(20)    NOT NULL CONSTRAINT DF_tbPlanesApoyo_Estado DEFAULT ('borrador'),
        Apo_EsConfidencial  bit            NOT NULL CONSTRAINT DF_tbPlanesApoyo_EsConfidencial DEFAULT (0),
        Apo_Titulo          nvarchar(150)  NOT NULL,
        Apo_Resumen         nvarchar(max)  NULL,
        Apo_FechaInicio     date           NOT NULL,
        Apo_FechaRevision   date           NULL,
        Apo_FechaFin        date           NULL,
        Usu_IdResponsable   int            NULL     CONSTRAINT FK_tbPlanesApoyo_Responsable REFERENCES seguridad.tbUsuarios (Usu_Id),
        Apo_Version         int            NOT NULL CONSTRAINT DF_tbPlanesApoyo_Version DEFAULT (1),
        Apo_EsEliminado     bit            NOT NULL CONSTRAINT DF_tbPlanesApoyo_EsEliminado DEFAULT (0),
        Apo_UsuarioRegistra int            NULL,
        Apo_FechaRegistra   datetime2(0)   NOT NULL CONSTRAINT DF_tbPlanesApoyo_FechaRegistra DEFAULT (SYSDATETIME()),
        Apo_UsuarioModifica int            NULL,
        Apo_FechaModifica   datetime2(0)   NULL,
        CONSTRAINT CK_tbPlanesApoyo_Categoria CHECK (Apo_Categoria IN ('refuerzo','orientacion','conducta','salud','adecuacion')),
        CONSTRAINT CK_tbPlanesApoyo_Estado CHECK (Apo_Estado IN ('borrador','activo','en_pausa','completado','cancelado')),
        CONSTRAINT CK_tbPlanesApoyo_Revision CHECK (Apo_FechaRevision IS NULL OR Apo_FechaRevision >= Apo_FechaInicio)
    );
    CREATE INDEX IX_tbPlanesApoyo_Alumno ON app.tbPlanesApoyo (Alu_Id) WHERE Apo_EsEliminado = 0;
    CREATE INDEX IX_tbPlanesApoyo_Estado ON app.tbPlanesApoyo (Apo_Estado) INCLUDE (Apo_EsConfidencial, Usu_IdResponsable, Apo_FechaRevision) WHERE Apo_EsEliminado = 0;
END
GO

IF OBJECT_ID('app.tbPlanesApoyoAcciones') IS NULL
BEGIN
    CREATE TABLE app.tbPlanesApoyoAcciones
    (
        Apa_Id              int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbPlanesApoyoAcciones PRIMARY KEY,
        Apo_Id              int            NOT NULL CONSTRAINT FK_tbPlanesApoyoAcciones_Plan REFERENCES app.tbPlanesApoyo (Apo_Id),
        Apa_Descripcion     nvarchar(500)  NOT NULL,
        Apa_FechaLimite     date           NULL,
        Usu_IdResponsable   int            NULL     CONSTRAINT FK_tbPlanesApoyoAcciones_Responsable REFERENCES seguridad.tbUsuarios (Usu_Id),
        Apa_FechaHecha      datetime2(0)   NULL,
        Apa_UsuarioHecha    int            NULL,
        Apa_EsEliminado     bit            NOT NULL CONSTRAINT DF_tbPlanesApoyoAcciones_EsEliminado DEFAULT (0),
        Apa_UsuarioRegistra int            NULL,
        Apa_FechaRegistra   datetime2(0)   NOT NULL CONSTRAINT DF_tbPlanesApoyoAcciones_FechaRegistra DEFAULT (SYSDATETIME()),
        Apa_UsuarioModifica int            NULL,
        Apa_FechaModifica   datetime2(0)   NULL
    );
    CREATE INDEX IX_tbPlanesApoyoAcciones_Plan ON app.tbPlanesApoyoAcciones (Apo_Id) WHERE Apa_EsEliminado = 0;
    CREATE INDEX IX_tbPlanesApoyoAcciones_Responsable ON app.tbPlanesApoyoAcciones (Usu_IdResponsable) INCLUDE (Apo_Id) WHERE Apa_EsEliminado = 0;
END
GO

IF OBJECT_ID('app.tbPlanesApoyoNotas') IS NULL
BEGIN
    CREATE TABLE app.tbPlanesApoyoNotas
    (
        Apn_Id      int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbPlanesApoyoNotas PRIMARY KEY,
        Apo_Id      int           NOT NULL CONSTRAINT FK_tbPlanesApoyoNotas_Plan REFERENCES app.tbPlanesApoyo (Apo_Id),
        Apn_Texto   nvarchar(max) NOT NULL,
        Apn_Usuario int           NULL,
        Apn_Fecha   datetime2(0)  NOT NULL CONSTRAINT DF_tbPlanesApoyoNotas_Fecha DEFAULT (SYSDATETIME())
    );
    CREATE INDEX IX_tbPlanesApoyoNotas_Plan ON app.tbPlanesApoyoNotas (Apo_Id, Apn_Id);
END
GO

IF OBJECT_ID('app.tbPlanesApoyoEstados') IS NULL
BEGIN
    CREATE TABLE app.tbPlanesApoyoEstados
    (
        Ape_Id      int IDENTITY(1,1) NOT NULL CONSTRAINT PK_tbPlanesApoyoEstados PRIMARY KEY,
        Apo_Id      int           NOT NULL CONSTRAINT FK_tbPlanesApoyoEstados_Plan REFERENCES app.tbPlanesApoyo (Apo_Id),
        Ape_De      varchar(20)   NOT NULL,
        Ape_A       varchar(20)   NOT NULL,
        Ape_Motivo  nvarchar(500) NULL,
        Ape_Usuario int           NULL,
        Ape_Fecha   datetime2(0)  NOT NULL CONSTRAINT DF_tbPlanesApoyoEstados_Fecha DEFAULT (SYSDATETIME())
    );
    CREATE INDEX IX_tbPlanesApoyoEstados_Plan ON app.tbPlanesApoyoEstados (Apo_Id, Ape_Id);
END
GO

/* ---------------------------------------------------------------- Funciones */

-- Estados a los que puede pasar un plan (el primero es la sugerencia) y si pide motivo.
CREATE OR ALTER FUNCTION app.FN_PlanApoyo_Siguientes (@Estado varchar(20))
RETURNS TABLE
AS
RETURN
    SELECT v.Estado, v.Orden, CAST(v.PideMotivo AS bit) AS PideMotivo
    FROM (VALUES
        ('borrador',   'activo',     1, 0), ('borrador',   'cancelado',  2, 1),
        ('activo',     'en_pausa',   1, 1), ('activo',     'completado', 2, 0), ('activo',   'cancelado', 3, 1),
        ('en_pausa',   'activo',     1, 0), ('en_pausa',   'completado', 2, 0), ('en_pausa', 'cancelado', 3, 1),
        ('completado', 'activo',     1, 1)
    ) v (Desde, Estado, Orden, PideMotivo)
    WHERE v.Desde = @Estado;
GO

-- ¿El usuario puede ser responsable de un plan o de un paso? Activo, sin suspender, rol admin, director o Docente.
CREATE OR ALTER FUNCTION app.FN_PlanApoyo_UsuarioElegible (@Usu_Id int)
RETURNS bit
AS
BEGIN
    RETURN CASE WHEN EXISTS (
        SELECT 1
        FROM seguridad.tbUsuarios u
        JOIN seguridad.tbRoles r ON r.Rol_Id = u.Rol_Id
        WHERE u.Usu_Id = @Usu_Id
          AND ISNULL(u.Usu_EsEliminado, 0) = 0
          AND ISNULL(u.Usu_EsActivo, 1) = 1
          AND ISNULL(u.Usu_Suspendido, 0) = 0
          AND ISNULL(r.Rol_EsEliminado, 0) = 0
          AND LOWER(LTRIM(RTRIM(r.Rol_Descripcion))) IN ('admin', 'director', 'docente')
    ) THEN 1 ELSE 0 END;
END
GO

-- ¿El rol del usuario tiene esta pantalla? (admin pasa todo, igual que SessionManager.EsAdmin)
CREATE OR ALTER FUNCTION app.FN_PlanApoyo_RolTiene (@Usu_Id int, @Pantalla nvarchar(100))
RETURNS bit
AS
BEGIN
    RETURN CASE WHEN EXISTS (
        SELECT 1
        FROM seguridad.tbUsuarios u
        JOIN seguridad.tbRoles r ON r.Rol_Id = u.Rol_Id
        WHERE u.Usu_Id = @Usu_Id
          AND (   LOWER(LTRIM(RTRIM(r.Rol_Descripcion))) = 'admin'
               OR EXISTS (SELECT 1
                          FROM seguridad.tbRolesPantallas rp
                          JOIN seguridad.tbPantallas p ON p.Pan_Id = rp.Pan_Id
                          WHERE rp.Rol_Id = r.Rol_Id AND p.Pan_Descripcion = @Pantalla AND ISNULL(p.Pan_EsEliminado, 0) = 0))
    ) THEN 1 ELSE 0 END;
END
GO

-- Nombre visible del usuario para elegirlo: "Nombre del empleado (usuario)". Varios usuarios de
-- prueba comparten empleado, por eso va siempre el nombre de usuario.
CREATE OR ALTER FUNCTION app.FN_PlanApoyo_NombreUsuario (@Usu_Id int)
RETURNS nvarchar(250)
AS
BEGIN
    RETURN (
        SELECT TOP (1)
            CASE WHEN n.Nombre IS NULL OR n.Nombre = u.Usu_Name THEN u.Usu_Name
                 ELSE n.Nombre + N' (' + u.Usu_Name + N')' END
        FROM seguridad.tbUsuarios u
        CROSS APPLY (SELECT NULLIF(app.FN_NombreUsuario(u.Usu_Id), N'') AS Nombre) n
        WHERE u.Usu_Id = @Usu_Id);
END
GO

-- Planes que una persona puede leer (ver el encabezado del script).
CREATE OR ALTER FUNCTION app.FN_PlanesApoyo_Visibles (@VerTodos bit, @VerConfidenciales bit, @Usu_Id int)
RETURNS TABLE
AS
RETURN
    SELECT p.Apo_Id
    FROM app.tbPlanesApoyo p
    WHERE p.Apo_EsEliminado = 0
      AND (   @VerTodos = 1
           OR p.Usu_IdResponsable = @Usu_Id
           OR p.Apo_UsuarioRegistra = @Usu_Id
           OR EXISTS (SELECT 1 FROM app.tbPlanesApoyoAcciones a
                      WHERE a.Apo_Id = p.Apo_Id AND a.Apa_EsEliminado = 0 AND a.Usu_IdResponsable = @Usu_Id))
      AND (   p.Apo_EsConfidencial = 0
           OR @VerConfidenciales = 1
           OR p.Usu_IdResponsable = @Usu_Id
           OR p.Apo_UsuarioRegistra = @Usu_Id);
GO

-- ¿Este usuario podría leer el plan si se le asigna un paso? (confidencial: permiso, responsable o creador)
CREATE OR ALTER FUNCTION app.FN_PlanApoyo_PodriaLeer (@EsConfidencial bit, @Responsable int, @Creador int, @Usu_Id int)
RETURNS bit
AS
BEGIN
    RETURN CASE WHEN @EsConfidencial = 0
                  OR @Usu_Id = @Responsable
                  OR @Usu_Id = @Creador
                  OR app.FN_PlanApoyo_RolTiene(@Usu_Id, N'Ver planes confidenciales') = 1
                THEN 1 ELSE 0 END;
END
GO

-- Texto de una categoría y de un estado (para los avisos).
CREATE OR ALTER FUNCTION app.FN_PlanApoyo_Estado (@Estado varchar(20))
RETURNS nvarchar(30)
AS
BEGIN
    RETURN CASE @Estado WHEN 'borrador' THEN N'Borrador' WHEN 'activo' THEN N'Activo' WHEN 'en_pausa' THEN N'En pausa'
                        WHEN 'completado' THEN N'Completado' WHEN 'cancelado' THEN N'Cancelado' ELSE @Estado END;
END
GO

/* ---------------------------------------------------------------- Lecturas */

-- Directorio: todos los planes que la persona puede leer, abiertos primero y por fecha de revisión.
CREATE OR ALTER PROCEDURE app.PR_tbPlanesApoyo_List
    @VerTodos          bit = 0,
    @VerConfidenciales bit = 0,
    @Usu_Id            int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Hoy date = CAST(app.FN_AhoraHonduras() AS date);

    SELECT p.Apo_Id, p.Alu_Id,
           CONCAT_WS(N' ', NULLIF(LTRIM(RTRIM(pe.Per_PrimerNombre)), N''), NULLIF(LTRIM(RTRIM(pe.Per_SegundoNombre)), N''),
                           NULLIF(LTRIM(RTRIM(pe.Per_ApellidoPaterno)), N''), NULLIF(LTRIM(RTRIM(pe.Per_ApellidoMaterno)), N'')) AS Alumno,
           pe.Per_Identidad AS Identidad, pe.Per_Imagen AS Foto,
           al.Niv_Id, n.Niv_Descripcion AS Nivel, al.Cun_Id, cn.Cun_Descripcion AS Grado, al.Sec_Id, s.Sec_Descripcion AS Seccion,
           p.Apo_Categoria, p.Apo_Titulo, p.Apo_Estado, p.Apo_EsConfidencial,
           p.Apo_FechaInicio, p.Apo_FechaRevision, p.Apo_FechaFin,
           p.Usu_IdResponsable, app.FN_PlanApoyo_NombreUsuario(p.Usu_IdResponsable) AS Responsable,
           ISNULL(x.Total, 0) AS PasosTotal, ISNULL(x.Hechos, 0) AS PasosHechos,
           CASE WHEN p.Apo_Estado IN ('borrador','activo','en_pausa') THEN ISNULL(x.Atrasados, 0) ELSE 0 END AS PasosAtrasados,
           ISNULL(x.MiosPendientes, 0) AS MisPasosPendientes,
           CAST(CASE WHEN p.Apo_Estado IN ('borrador','activo','en_pausa') AND p.Apo_FechaRevision < @Hoy THEN 1 ELSE 0 END AS bit) AS RevisionVencida,
           CAST(CASE WHEN p.Usu_IdResponsable = @Usu_Id THEN 1 ELSE 0 END AS bit) AS EsResponsable,
           CAST(CASE WHEN ISNULL(x.Mios, 0) > 0 THEN 1 ELSE 0 END AS bit) AS TienePasos,
           p.Apo_FechaRegistra
    FROM app.FN_PlanesApoyo_Visibles(@VerTodos, @VerConfidenciales, @Usu_Id) v
    JOIN app.tbPlanesApoyo p        ON p.Apo_Id  = v.Apo_Id
    JOIN app.tbAlumnos al           ON al.Alu_Id = p.Alu_Id
    JOIN app.tbPersonas pe          ON pe.Per_Id = al.Per_Id
    LEFT JOIN app.tbNivelesEducativos n  ON n.Niv_Id  = al.Niv_Id
    LEFT JOIN app.tbCursosNiveles     cn ON cn.Cun_Id = al.Cun_Id
    LEFT JOIN app.tbSecciones         s  ON s.Sec_Id  = al.Sec_Id
    OUTER APPLY (
        SELECT COUNT(*) AS Total,
               SUM(CASE WHEN a.Apa_FechaHecha IS NOT NULL THEN 1 ELSE 0 END) AS Hechos,
               SUM(CASE WHEN a.Apa_FechaHecha IS NULL AND a.Apa_FechaLimite < @Hoy THEN 1 ELSE 0 END) AS Atrasados,
               SUM(CASE WHEN a.Usu_IdResponsable = @Usu_Id THEN 1 ELSE 0 END) AS Mios,
               SUM(CASE WHEN a.Usu_IdResponsable = @Usu_Id AND a.Apa_FechaHecha IS NULL THEN 1 ELSE 0 END) AS MiosPendientes
        FROM app.tbPlanesApoyoAcciones a
        WHERE a.Apo_Id = p.Apo_Id AND a.Apa_EsEliminado = 0
    ) x
    ORDER BY CASE WHEN p.Apo_Estado IN ('borrador','activo','en_pausa') THEN 0 ELSE 1 END,
             p.Apo_FechaRevision, p.Apo_Id DESC;
END
GO

-- Indicadores del directorio con las mismas reglas de lectura.
CREATE OR ALTER PROCEDURE app.PR_tbPlanesApoyo_Resumen
    @VerTodos          bit = 0,
    @VerConfidenciales bit = 0,
    @Usu_Id            int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Hoy date = CAST(app.FN_AhoraHonduras() AS date);
    DECLARE @Ani_Id int = (SELECT TOP (1) Ani_Id FROM app.FN_AnioLectivoDeFecha(@Hoy));
    DECLARE @Desde date, @Hasta date, @AnioNombre varchar(50);
    SELECT @Desde = Ani_FechaInicio, @Hasta = Ani_FechaFin, @AnioNombre = Ani_Nombre FROM app.tbAnioLectivo WHERE Ani_Id = @Ani_Id;
    IF @Desde IS NULL OR @Hasta IS NULL
        SELECT @Desde = DATEFROMPARTS(YEAR(@Hoy), 1, 1), @Hasta = DATEFROMPARTS(YEAR(@Hoy), 12, 31), @AnioNombre = CONVERT(varchar(4), YEAR(@Hoy));

    SELECT
        ISNULL(SUM(CASE WHEN p.Apo_Estado = 'activo' THEN 1 ELSE 0 END), 0) AS Activos,
        ISNULL(SUM(CASE WHEN p.Apo_Estado IN ('borrador','activo','en_pausa') THEN 1 ELSE 0 END), 0) AS Abiertos,
        ISNULL(SUM(CASE WHEN p.Apo_Estado IN ('borrador','activo','en_pausa') AND p.Apo_FechaRevision < @Hoy THEN 1 ELSE 0 END), 0) AS RevisionVencida,
        ISNULL(SUM(CASE WHEN p.Apo_Estado IN ('borrador','activo','en_pausa') THEN x.Atrasados ELSE 0 END), 0) AS PasosAtrasados,
        ISNULL(SUM(CASE WHEN p.Apo_Estado = 'completado' AND p.Apo_FechaFin BETWEEN @Desde AND @Hasta THEN 1 ELSE 0 END), 0) AS CompletadosAnio,
        CAST(@AnioNombre AS varchar(50)) AS AnioNombre
    FROM app.FN_PlanesApoyo_Visibles(@VerTodos, @VerConfidenciales, @Usu_Id) v
    JOIN app.tbPlanesApoyo p ON p.Apo_Id = v.Apo_Id
    OUTER APPLY (
        SELECT COUNT(*) AS Atrasados
        FROM app.tbPlanesApoyoAcciones a
        WHERE a.Apo_Id = p.Apo_Id AND a.Apa_EsEliminado = 0 AND a.Apa_FechaHecha IS NULL AND a.Apa_FechaLimite < @Hoy
    ) x;
END
GO

-- Un plan. Sin fila si no existe, está eliminado o la persona no lo puede leer.
CREATE OR ALTER PROCEDURE app.PR_tbPlanesApoyo_Find
    @Apo_Id            int,
    @VerTodos          bit = 0,
    @VerConfidenciales bit = 0,
    @Usu_Id            int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Hoy date = CAST(app.FN_AhoraHonduras() AS date);

    SELECT p.Apo_Id, p.Alu_Id,
           CONCAT_WS(N' ', NULLIF(LTRIM(RTRIM(pe.Per_PrimerNombre)), N''), NULLIF(LTRIM(RTRIM(pe.Per_SegundoNombre)), N''),
                           NULLIF(LTRIM(RTRIM(pe.Per_ApellidoPaterno)), N''), NULLIF(LTRIM(RTRIM(pe.Per_ApellidoMaterno)), N'')) AS Alumno,
           pe.Per_Identidad AS Identidad, pe.Per_Imagen AS Foto,
           n.Niv_Descripcion AS Nivel, cn.Cun_Descripcion AS Grado, s.Sec_Descripcion AS Seccion,
           NULLIF(LTRIM(RTRIM(REPLACE(REPLACE(c.Cur_Nombre, CHAR(13), N''), CHAR(10), N''))), N'') AS Curso,
           p.Ani_Id, a.Ani_Nombre,
           p.Apo_Categoria, p.Apo_Titulo, p.Apo_Resumen, p.Apo_Estado, p.Apo_EsConfidencial,
           p.Apo_FechaInicio, p.Apo_FechaRevision, p.Apo_FechaFin, p.Apo_Version,
           p.Usu_IdResponsable, app.FN_PlanApoyo_NombreUsuario(p.Usu_IdResponsable) AS Responsable,
           p.Apo_UsuarioRegistra, app.FN_PlanApoyo_NombreUsuario(p.Apo_UsuarioRegistra) AS Creador,
           p.Apo_FechaRegistra, p.Apo_FechaModifica,
           (SELECT COUNT(*) FROM app.tbPlanesApoyoAcciones x WHERE x.Apo_Id = p.Apo_Id AND x.Apa_EsEliminado = 0) AS PasosTotal,
           (SELECT COUNT(*) FROM app.tbPlanesApoyoAcciones x WHERE x.Apo_Id = p.Apo_Id AND x.Apa_EsEliminado = 0 AND x.Apa_FechaHecha IS NOT NULL) AS PasosHechos,
           CAST(CASE WHEN p.Apo_Estado IN ('borrador','activo','en_pausa') AND p.Apo_FechaRevision < @Hoy THEN 1 ELSE 0 END AS bit) AS RevisionVencida,
           CAST(CASE WHEN p.Usu_IdResponsable = @Usu_Id THEN 1 ELSE 0 END AS bit) AS EsResponsable,
           CAST(CASE WHEN p.Apo_UsuarioRegistra = @Usu_Id THEN 1 ELSE 0 END AS bit) AS EsCreador
    FROM app.FN_PlanesApoyo_Visibles(@VerTodos, @VerConfidenciales, @Usu_Id) v
    JOIN app.tbPlanesApoyo p ON p.Apo_Id = v.Apo_Id
    JOIN app.tbAlumnos al    ON al.Alu_Id = p.Alu_Id
    JOIN app.tbPersonas pe   ON pe.Per_Id = al.Per_Id
    LEFT JOIN app.tbNivelesEducativos n  ON n.Niv_Id  = al.Niv_Id
    LEFT JOIN app.tbCursosNiveles     cn ON cn.Cun_Id = al.Cun_Id
    LEFT JOIN app.tbSecciones         s  ON s.Sec_Id  = al.Sec_Id
    LEFT JOIN app.tbCursos            c  ON c.Cur_Id  = al.Cur_Id
    LEFT JOIN app.tbAnioLectivo       a  ON a.Ani_Id  = p.Ani_Id
    WHERE p.Apo_Id = @Apo_Id;
END
GO

-- Pasos de un plan legible (vacío si la persona no lo puede leer).
CREATE OR ALTER PROCEDURE app.PR_tbPlanesApoyoAcciones_List
    @Apo_Id            int,
    @VerTodos          bit = 0,
    @VerConfidenciales bit = 0,
    @Usu_Id            int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Hoy date = CAST(app.FN_AhoraHonduras() AS date);

    SELECT a.Apa_Id, a.Apa_Descripcion, a.Apa_FechaLimite, a.Apa_FechaHecha,
           a.Usu_IdResponsable, app.FN_PlanApoyo_NombreUsuario(a.Usu_IdResponsable) AS Responsable,
           app.FN_PlanApoyo_NombreUsuario(a.Apa_UsuarioHecha) AS HechaPor,
           CAST(CASE WHEN a.Apa_FechaHecha IS NULL AND a.Apa_FechaLimite < @Hoy THEN 1 ELSE 0 END AS bit) AS Atrasado,
           CAST(CASE WHEN a.Usu_IdResponsable = @Usu_Id THEN 1 ELSE 0 END AS bit) AS EsMio
    FROM app.FN_PlanesApoyo_Visibles(@VerTodos, @VerConfidenciales, @Usu_Id) v
    JOIN app.tbPlanesApoyoAcciones a ON a.Apo_Id = v.Apo_Id
    WHERE v.Apo_Id = @Apo_Id
      AND a.Apa_EsEliminado = 0
    ORDER BY CASE WHEN a.Apa_FechaHecha IS NULL THEN 0 ELSE 1 END, a.Apa_FechaLimite, a.Apa_Id;
END
GO

-- Notas de seguimiento (más reciente primero).
CREATE OR ALTER PROCEDURE app.PR_tbPlanesApoyoNotas_List
    @Apo_Id            int,
    @VerTodos          bit = 0,
    @VerConfidenciales bit = 0,
    @Usu_Id            int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT nt.Apn_Id, nt.Apn_Texto, nt.Apn_Fecha, nt.Apn_Usuario, app.FN_PlanApoyo_NombreUsuario(nt.Apn_Usuario) AS Usuario
    FROM app.FN_PlanesApoyo_Visibles(@VerTodos, @VerConfidenciales, @Usu_Id) v
    JOIN app.tbPlanesApoyoNotas nt ON nt.Apo_Id = v.Apo_Id
    WHERE v.Apo_Id = @Apo_Id
    ORDER BY nt.Apn_Id DESC;
END
GO

-- Historial de estados (en el orden en que pasó).
CREATE OR ALTER PROCEDURE app.PR_tbPlanesApoyoEstados_List
    @Apo_Id            int,
    @VerTodos          bit = 0,
    @VerConfidenciales bit = 0,
    @Usu_Id            int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    SELECT e.Ape_Id, e.Ape_De, e.Ape_A, e.Ape_Motivo, e.Ape_Fecha, app.FN_PlanApoyo_NombreUsuario(e.Ape_Usuario) AS Usuario
    FROM app.FN_PlanesApoyo_Visibles(@VerTodos, @VerConfidenciales, @Usu_Id) v
    JOIN app.tbPlanesApoyoEstados e ON e.Apo_Id = v.Apo_Id
    WHERE v.Apo_Id = @Apo_Id
    ORDER BY e.Ape_Id;
END
GO

-- Usuarios que pueden ser responsables (admin, director, Docente activos).
CREATE OR ALTER PROCEDURE app.PR_tbPlanesApoyo_Usuarios
AS
BEGIN
    SET NOCOUNT ON;
    SELECT u.Usu_Id, u.Usu_Name AS Usuario, app.FN_PlanApoyo_NombreUsuario(u.Usu_Id) AS Nombre, r.Rol_Descripcion AS Rol
    FROM seguridad.tbUsuarios u
    JOIN seguridad.tbRoles r ON r.Rol_Id = u.Rol_Id
    WHERE app.FN_PlanApoyo_UsuarioElegible(u.Usu_Id) = 1
    ORDER BY CASE LOWER(r.Rol_Descripcion) WHEN 'director' THEN 0 WHEN 'docente' THEN 1 ELSE 2 END,
             app.FN_PlanApoyo_NombreUsuario(u.Usu_Id);
END
GO

-- Alumnos activos a los que se les puede abrir un plan, con su ubicación.
CREATE OR ALTER PROCEDURE app.PR_tbPlanesApoyo_Alumnos
AS
BEGIN
    SET NOCOUNT ON;
    SELECT al.Alu_Id,
           CONCAT_WS(N' ', NULLIF(LTRIM(RTRIM(p.Per_PrimerNombre)), N''), NULLIF(LTRIM(RTRIM(p.Per_SegundoNombre)), N''),
                           NULLIF(LTRIM(RTRIM(p.Per_ApellidoPaterno)), N''), NULLIF(LTRIM(RTRIM(p.Per_ApellidoMaterno)), N'')) AS Nombre,
           p.Per_Identidad AS Identidad,
           n.Niv_Descripcion AS Nivel,
           NULLIF(CONCAT_WS(N' · ', cn.Cun_Descripcion, s.Sec_Descripcion), N'') AS Ubicacion
    FROM app.tbAlumnos al
    JOIN app.tbPersonas p ON p.Per_Id = al.Per_Id
    LEFT JOIN app.tbNivelesEducativos n  ON n.Niv_Id  = al.Niv_Id
    LEFT JOIN app.tbCursosNiveles     cn ON cn.Cun_Id = al.Cun_Id
    LEFT JOIN app.tbSecciones         s  ON s.Sec_Id  = al.Sec_Id
    WHERE ISNULL(p.Per_EsEliminado, 0) = 0
      AND ISNULL(al.Est_Id, 1) = 1
    ORDER BY p.Per_PrimerNombre, p.Per_ApellidoPaterno, p.Per_ApellidoMaterno;
END
GO

-- Secciones de un grado (las que tienen alumnos activos), para el filtro en cascada.
CREATE OR ALTER PROCEDURE app.PR_tbPlanesApoyo_Secciones
    @Cun_Id int
AS
BEGIN
    SET NOCOUNT ON;
    SELECT DISTINCT s.Sec_Id, s.Sec_Descripcion
    FROM app.tbAlumnos al
    JOIN app.tbSecciones s ON s.Sec_Id = al.Sec_Id
    WHERE al.Cun_Id = @Cun_Id
      AND ISNULL(al.Est_Id, 1) = 1
    ORDER BY s.Sec_Descripcion;
END
GO

-- Planes abiertos legibles de una lista de alumnos ("1,2,3"), para "Crear plan" / "Ver plan".
CREATE OR ALTER PROCEDURE app.PR_tbPlanesApoyo_AbiertosDeAlumnos
    @Alumnos           varchar(4000),
    @VerTodos          bit = 0,
    @VerConfidenciales bit = 0,
    @Usu_Id            int = NULL
AS
BEGIN
    SET NOCOUNT ON;
    DECLARE @Ids TABLE (Alu_Id int PRIMARY KEY);
    INSERT INTO @Ids (Alu_Id)
    SELECT DISTINCT TOP (500) TRY_CAST(LTRIM(RTRIM(value)) AS int)
    FROM STRING_SPLIT(ISNULL(@Alumnos, ''), ',')
    WHERE TRY_CAST(LTRIM(RTRIM(value)) AS int) IS NOT NULL;

    SELECT p.Alu_Id, p.Apo_Id, p.Apo_Titulo, p.Apo_Estado, p.Apo_Categoria, p.Apo_FechaRevision
    FROM app.FN_PlanesApoyo_Visibles(@VerTodos, @VerConfidenciales, @Usu_Id) v
    JOIN app.tbPlanesApoyo p ON p.Apo_Id = v.Apo_Id
    JOIN @Ids i ON i.Alu_Id = p.Alu_Id
    WHERE p.Apo_Estado IN ('borrador','activo','en_pausa')
    ORDER BY p.Alu_Id, p.Apo_Id DESC;
END
GO

/* ---------------------------------------------------------------- Escrituras */

-- Abrir un plan (borrador; con @Activar = 1 queda activo de una vez y lo anota en el historial).
CREATE OR ALTER PROCEDURE app.PR_tbPlanesApoyo_Crear
    @Alu_Id             int,
    @Apo_Categoria      varchar(20),
    @Apo_Titulo         nvarchar(150),
    @Apo_Resumen        nvarchar(max) = NULL,
    @Apo_FechaInicio    date,
    @Apo_FechaRevision  date,
    @Usu_IdResponsable  int,
    @Apo_EsConfidencial bit = 0,
    @Activar            bit = 0,
    @Usuario            int = NULL,
    @PuedeGestionar     bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @Apo_Titulo  = LTRIM(RTRIM(ISNULL(@Apo_Titulo, N'')));
    SET @Apo_Resumen = NULLIF(LTRIM(RTRIM(@Apo_Resumen)), N'');

    IF ISNULL(@PuedeGestionar, 0) = 0
        THROW 50080, N'No tiene permiso para gestionar planes de apoyo.', 1;
    IF NOT EXISTS (SELECT 1 FROM app.tbAlumnos al JOIN app.tbPersonas p ON p.Per_Id = al.Per_Id
                   WHERE al.Alu_Id = @Alu_Id AND ISNULL(al.Est_Id, 1) = 1 AND ISNULL(p.Per_EsEliminado, 0) = 0)
        THROW 50081, N'Elija un alumno activo: solo se abren planes a alumnos con matrícula activa.', 1;
    IF @Apo_Categoria IS NULL OR @Apo_Categoria NOT IN ('refuerzo','orientacion','conducta','salud','adecuacion')
        THROW 50082, N'Elija la categoría del plan.', 1;
    IF @Apo_Titulo = N''
        THROW 50083, N'Escriba el objetivo del plan.', 1;
    IF LEN(@Apo_Titulo) > 150
        THROW 50083, N'El objetivo admite hasta 150 caracteres.', 1;
    IF LEN(@Apo_Resumen) > 5000
        THROW 50084, N'La descripción admite hasta 5000 caracteres.', 1;
    IF @Apo_FechaInicio IS NULL OR YEAR(@Apo_FechaInicio) NOT BETWEEN 2000 AND 2100
        THROW 50085, N'Indique cuándo empieza el plan.', 1;
    IF @Apo_FechaRevision IS NULL OR YEAR(@Apo_FechaRevision) NOT BETWEEN 2000 AND 2100
        THROW 50086, N'Indique cuándo se revisa el plan.', 1;
    IF @Apo_FechaRevision < @Apo_FechaInicio
        THROW 50086, N'La revisión no puede ser antes del inicio del plan.', 1;
    IF @Usu_IdResponsable IS NULL OR app.FN_PlanApoyo_UsuarioElegible(@Usu_IdResponsable) = 0
        THROW 50087, N'Elija como responsable a un usuario activo con rol de dirección, docente o administración.', 1;

    DECLARE @Ahora datetime2(0) = app.FN_AhoraHonduras();
    DECLARE @Ani_Id int = (SELECT TOP (1) Ani_Id FROM app.FN_AnioLectivoDeFecha(@Apo_FechaInicio));
    DECLARE @Apo_Id int, @Estado varchar(20) = CASE WHEN @Activar = 1 THEN 'activo' ELSE 'borrador' END;

    BEGIN TRY
        BEGIN TRANSACTION;

        INSERT INTO app.tbPlanesApoyo
            (Alu_Id, Ani_Id, Apo_Categoria, Apo_Estado, Apo_EsConfidencial, Apo_Titulo, Apo_Resumen,
             Apo_FechaInicio, Apo_FechaRevision, Usu_IdResponsable, Apo_UsuarioRegistra, Apo_FechaRegistra)
        VALUES
            (@Alu_Id, @Ani_Id, @Apo_Categoria, @Estado, ISNULL(@Apo_EsConfidencial, 0), @Apo_Titulo, @Apo_Resumen,
             @Apo_FechaInicio, @Apo_FechaRevision, @Usu_IdResponsable, @Usuario, @Ahora);
        SET @Apo_Id = CAST(SCOPE_IDENTITY() AS int);

        IF @Activar = 1
            INSERT INTO app.tbPlanesApoyoEstados (Apo_Id, Ape_De, Ape_A, Ape_Motivo, Ape_Usuario, Ape_Fecha)
            VALUES (@Apo_Id, 'borrador', 'activo', NULL, @Usuario, @Ahora);

        IF @Usu_IdResponsable <> ISNULL(@Usuario, 0)
            INSERT INTO app.tbNotificaciones (Usu_Id, Not_Titulo, Not_Mensaje, Not_Tipo, Not_EsLeida, Not_UrlDestino,
                                              Not_FechaEnvio, Not_EsEliminado, Not_UsuarioRegistra, Not_FechaRegistra)
            SELECT @Usu_IdResponsable, 'Le asignaron un plan de apoyo',
                   LEFT(CONCAT(N'Es responsable del plan ',
                               CASE WHEN ISNULL(@Apo_EsConfidencial, 0) = 1 THEN N'(confidencial)' ELSE N'«' + @Apo_Titulo + N'»' END,
                               N' de ', CONCAT_WS(N' ', p.Per_PrimerNombre, p.Per_ApellidoPaterno),
                               N'. Revisión: ', CONVERT(varchar(10), @Apo_FechaRevision, 103), N'.'), 500),
                   'I', 0, CONCAT('/PlanesApoyo/Plan/', @Apo_Id), @Ahora, 0, ISNULL(@Usuario, @Usu_IdResponsable), @Ahora
            FROM app.tbAlumnos al JOIN app.tbPersonas p ON p.Per_Id = al.Per_Id
            WHERE al.Alu_Id = @Alu_Id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT @Apo_Id AS Apo_Id, @Estado AS Apo_Estado, 1 AS Apo_Version;
END
GO

-- Cambiar los datos de un plan abierto. @Apo_Version = la que leyó quien edita (no pisa cambios ajenos).
CREATE OR ALTER PROCEDURE app.PR_tbPlanesApoyo_Editar
    @Apo_Id             int,
    @Apo_Categoria      varchar(20),
    @Apo_Titulo         nvarchar(150),
    @Apo_Resumen        nvarchar(max) = NULL,
    @Apo_FechaInicio    date,
    @Apo_FechaRevision  date,
    @Usu_IdResponsable  int,
    @Apo_EsConfidencial bit = 0,
    @Apo_Version        int = NULL,
    @Usuario            int = NULL,
    @PuedeGestionar     bit = 0,
    @VerConfidenciales  bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @Apo_Titulo  = LTRIM(RTRIM(ISNULL(@Apo_Titulo, N'')));
    SET @Apo_Resumen = NULLIF(LTRIM(RTRIM(@Apo_Resumen)), N'');
    SET @Apo_EsConfidencial = ISNULL(@Apo_EsConfidencial, 0);

    IF ISNULL(@PuedeGestionar, 0) = 0
        THROW 50080, N'No tiene permiso para gestionar planes de apoyo.', 1;
    IF @Apo_Categoria IS NULL OR @Apo_Categoria NOT IN ('refuerzo','orientacion','conducta','salud','adecuacion')
        THROW 50082, N'Elija la categoría del plan.', 1;
    IF @Apo_Titulo = N''
        THROW 50083, N'Escriba el objetivo del plan.', 1;
    IF LEN(@Apo_Titulo) > 150
        THROW 50083, N'El objetivo admite hasta 150 caracteres.', 1;
    IF LEN(@Apo_Resumen) > 5000
        THROW 50084, N'La descripción admite hasta 5000 caracteres.', 1;
    IF @Apo_FechaInicio IS NULL OR YEAR(@Apo_FechaInicio) NOT BETWEEN 2000 AND 2100
        THROW 50085, N'Indique cuándo empieza el plan.', 1;
    IF @Apo_FechaRevision IS NULL OR YEAR(@Apo_FechaRevision) NOT BETWEEN 2000 AND 2100
        THROW 50086, N'Indique cuándo se revisa el plan.', 1;
    IF @Apo_FechaRevision < @Apo_FechaInicio
        THROW 50086, N'La revisión no puede ser antes del inicio del plan.', 1;
    IF @Usu_IdResponsable IS NULL OR app.FN_PlanApoyo_UsuarioElegible(@Usu_IdResponsable) = 0
        THROW 50087, N'Elija como responsable a un usuario activo con rol de dirección, docente o administración.', 1;

    DECLARE @Ahora datetime2(0) = app.FN_AhoraHonduras();

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Estado varchar(20), @Version int, @ResponsableAntes int, @Creador int, @Alu_Id int;
        SELECT @Estado = p.Apo_Estado, @Version = p.Apo_Version, @ResponsableAntes = p.Usu_IdResponsable,
               @Creador = p.Apo_UsuarioRegistra, @Alu_Id = p.Alu_Id
        FROM app.tbPlanesApoyo p WITH (UPDLOCK, HOLDLOCK)
        JOIN app.FN_PlanesApoyo_Visibles(1, @VerConfidenciales, @Usuario) v ON v.Apo_Id = p.Apo_Id
        WHERE p.Apo_Id = @Apo_Id;

        IF @Estado IS NULL
            THROW 50088, N'El plan ya no existe o no lo puede ver.', 1;
        IF @Estado IN ('completado','cancelado')
            THROW 50089, N'Este plan ya terminó. Reábralo antes de cambiarlo.', 1;
        IF @Apo_Version IS NULL OR @Apo_Version <> @Version
            THROW 50090, N'Otra persona cambió este plan mientras usted lo editaba. Recargue la página para ver la versión actual y vuelva a hacer sus cambios.', 1;

        -- Un plan confidencial no puede tener pasos de personas que no lo podrían leer.
        DECLARE @SinAcceso nvarchar(1000) = (
            SELECT STRING_AGG(x.Nombre, N', ')
            FROM (SELECT DISTINCT app.FN_PlanApoyo_NombreUsuario(a.Usu_IdResponsable) AS Nombre
                  FROM app.tbPlanesApoyoAcciones a
                  WHERE a.Apo_Id = @Apo_Id AND a.Apa_EsEliminado = 0 AND a.Usu_IdResponsable IS NOT NULL
                    AND app.FN_PlanApoyo_PodriaLeer(@Apo_EsConfidencial, @Usu_IdResponsable, @Creador, a.Usu_IdResponsable) = 0) x);
        IF @SinAcceso IS NOT NULL
        BEGIN
            DECLARE @Msj nvarchar(2048) = CONCAT(N'Si el plan es confidencial, estas personas con pasos ya no lo podrían ver: ', @SinAcceso,
                                                 N'. Quite esos pasos o haga responsable a quien corresponda.');
            THROW 50091, @Msj, 1;
        END

        UPDATE app.tbPlanesApoyo
        SET Apo_Categoria       = @Apo_Categoria,
            Apo_Titulo          = @Apo_Titulo,
            Apo_Resumen         = @Apo_Resumen,
            Apo_FechaInicio     = @Apo_FechaInicio,
            Apo_FechaRevision   = @Apo_FechaRevision,
            Ani_Id              = (SELECT TOP (1) Ani_Id FROM app.FN_AnioLectivoDeFecha(@Apo_FechaInicio)),
            Usu_IdResponsable   = @Usu_IdResponsable,
            Apo_EsConfidencial  = @Apo_EsConfidencial,
            Apo_Version         = Apo_Version + 1,
            Apo_UsuarioModifica = @Usuario,
            Apo_FechaModifica   = @Ahora
        WHERE Apo_Id = @Apo_Id;

        IF ISNULL(@ResponsableAntes, 0) <> @Usu_IdResponsable AND @Usu_IdResponsable <> ISNULL(@Usuario, 0)
            INSERT INTO app.tbNotificaciones (Usu_Id, Not_Titulo, Not_Mensaje, Not_Tipo, Not_EsLeida, Not_UrlDestino,
                                              Not_FechaEnvio, Not_EsEliminado, Not_UsuarioRegistra, Not_FechaRegistra)
            SELECT @Usu_IdResponsable, 'Le asignaron un plan de apoyo',
                   LEFT(CONCAT(N'Ahora es responsable del plan ',
                               CASE WHEN @Apo_EsConfidencial = 1 THEN N'(confidencial)' ELSE N'«' + @Apo_Titulo + N'»' END,
                               N' de ', CONCAT_WS(N' ', p.Per_PrimerNombre, p.Per_ApellidoPaterno),
                               N'. Revisión: ', CONVERT(varchar(10), @Apo_FechaRevision, 103), N'.'), 500),
                   'I', 0, CONCAT('/PlanesApoyo/Plan/', @Apo_Id), @Ahora, 0, ISNULL(@Usuario, @Usu_IdResponsable), @Ahora
            FROM app.tbAlumnos al JOIN app.tbPersonas p ON p.Per_Id = al.Per_Id
            WHERE al.Alu_Id = @Alu_Id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT Apo_Id, Apo_Estado, Apo_Version FROM app.tbPlanesApoyo WHERE Apo_Id = @Apo_Id;
END
GO

-- Mover el plan de estado. Bloquea la fila: si dos personas lo mueven a la vez, decide el estado
-- leído bajo el bloqueo (el historial nunca salta un paso).
CREATE OR ALTER PROCEDURE app.PR_tbPlanesApoyo_CambiarEstado
    @Apo_Id            int,
    @Estado            varchar(20),
    @Motivo            nvarchar(500) = NULL,
    @Usuario           int = NULL,
    @PuedeGestionar    bit = 0,
    @VerConfidenciales bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @Motivo = NULLIF(LTRIM(RTRIM(@Motivo)), N'');

    IF ISNULL(@PuedeGestionar, 0) = 0
        THROW 50080, N'No tiene permiso para cambiar el estado de un plan de apoyo.', 1;
    IF LEN(@Motivo) > 500
        THROW 50092, N'El motivo admite hasta 500 caracteres.', 1;

    DECLARE @Ahora datetime2(0) = app.FN_AhoraHonduras();
    DECLARE @Hoy date = CAST(@Ahora AS date);

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Actual varchar(20), @Inicio date, @Responsable int, @Titulo nvarchar(150), @EsConf bit, @Alu_Id int;
        SELECT @Actual = p.Apo_Estado, @Inicio = p.Apo_FechaInicio, @Responsable = p.Usu_IdResponsable,
               @Titulo = p.Apo_Titulo, @EsConf = p.Apo_EsConfidencial, @Alu_Id = p.Alu_Id
        FROM app.tbPlanesApoyo p WITH (UPDLOCK, HOLDLOCK)
        JOIN app.FN_PlanesApoyo_Visibles(1, @VerConfidenciales, @Usuario) v ON v.Apo_Id = p.Apo_Id
        WHERE p.Apo_Id = @Apo_Id;

        IF @Actual IS NULL
            THROW 50088, N'El plan ya no existe o no lo puede ver.', 1;

        IF @Actual <> @Estado
        BEGIN
            DECLARE @PideMotivo bit = (SELECT PideMotivo FROM app.FN_PlanApoyo_Siguientes(@Actual) WHERE Estado = @Estado);
            IF @PideMotivo IS NULL
            BEGIN
                DECLARE @MsjTransicion nvarchar(300) = CONCAT(N'Un plan no puede pasar de ', app.FN_PlanApoyo_Estado(@Actual),
                                                              N' a ', app.FN_PlanApoyo_Estado(@Estado), N'.');
                THROW 50093, @MsjTransicion, 1;
            END
            IF @PideMotivo = 1 AND @Motivo IS NULL
                THROW 50094, N'Escriba el motivo del cambio.', 1;

            UPDATE app.tbPlanesApoyo
            SET Apo_Estado = @Estado,
                Apo_FechaFin = CASE WHEN @Estado IN ('completado','cancelado')
                                    THEN ISNULL(Apo_FechaFin, CASE WHEN Apo_FechaInicio > @Hoy THEN Apo_FechaInicio ELSE @Hoy END)
                                    ELSE NULL END,
                Apo_Version = Apo_Version + 1,
                Apo_UsuarioModifica = @Usuario,
                Apo_FechaModifica = @Ahora
            WHERE Apo_Id = @Apo_Id;

            INSERT INTO app.tbPlanesApoyoEstados (Apo_Id, Ape_De, Ape_A, Ape_Motivo, Ape_Usuario, Ape_Fecha)
            VALUES (@Apo_Id, @Actual, @Estado, @Motivo, @Usuario, @Ahora);

            -- Como en Skuul: al cerrarse el plan se avisa a quien lo lleva (si no lo cerró él).
            IF @Estado IN ('completado','cancelado') AND @Responsable IS NOT NULL AND @Responsable <> ISNULL(@Usuario, 0)
                INSERT INTO app.tbNotificaciones (Usu_Id, Not_Titulo, Not_Mensaje, Not_Tipo, Not_EsLeida, Not_UrlDestino,
                                                  Not_FechaEnvio, Not_EsEliminado, Not_UsuarioRegistra, Not_FechaRegistra)
                SELECT @Responsable, CASE WHEN @Estado = 'completado' THEN 'Plan de apoyo completado' ELSE 'Plan de apoyo cancelado' END,
                       LEFT(CONCAT(N'El plan ', CASE WHEN @EsConf = 1 THEN N'(confidencial)' ELSE N'«' + @Titulo + N'»' END,
                                   N' de ', CONCAT_WS(N' ', p.Per_PrimerNombre, p.Per_ApellidoPaterno),
                                   N' pasó a ', LOWER(app.FN_PlanApoyo_Estado(@Estado)), N'.',
                                   CASE WHEN @Motivo IS NOT NULL THEN N' Motivo: ' + @Motivo ELSE N'' END), 500),
                       CASE WHEN @Estado = 'cancelado' THEN 'A' ELSE 'I' END, 0, CONCAT('/PlanesApoyo/Plan/', @Apo_Id),
                       @Ahora, 0, ISNULL(@Usuario, @Responsable), @Ahora
                FROM app.tbAlumnos al JOIN app.tbPersonas p ON p.Per_Id = al.Per_Id
                WHERE al.Alu_Id = @Alu_Id;
        END

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT Apo_Id, Apo_Estado, Apo_Version FROM app.tbPlanesApoyo WHERE Apo_Id = @Apo_Id;
END
GO

-- Agregar un paso (qué hay que hacer, quién y para cuándo). Solo en un plan abierto.
CREATE OR ALTER PROCEDURE app.PR_tbPlanesApoyoAcciones_Agregar
    @Apo_Id            int,
    @Apa_Descripcion   nvarchar(500),
    @Apa_FechaLimite   date,
    @Usu_IdResponsable int,
    @Usuario           int = NULL,
    @PuedeGestionar    bit = 0,
    @VerConfidenciales bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    SET @Apa_Descripcion = LTRIM(RTRIM(ISNULL(@Apa_Descripcion, N'')));

    IF ISNULL(@PuedeGestionar, 0) = 0
        THROW 50080, N'No tiene permiso para agregar pasos a un plan de apoyo.', 1;
    IF @Apa_Descripcion = N''
        THROW 50095, N'Diga qué tiene que pasar.', 1;
    IF LEN(@Apa_Descripcion) > 500
        THROW 50095, N'El paso admite hasta 500 caracteres.', 1;
    IF @Apa_FechaLimite IS NULL OR YEAR(@Apa_FechaLimite) NOT BETWEEN 2000 AND 2100
        THROW 50096, N'Indique la fecha límite del paso.', 1;
    IF @Usu_IdResponsable IS NULL OR app.FN_PlanApoyo_UsuarioElegible(@Usu_IdResponsable) = 0
        THROW 50087, N'Elija como responsable del paso a un usuario activo con rol de dirección, docente o administración.', 1;

    DECLARE @Ahora datetime2(0) = app.FN_AhoraHonduras();
    DECLARE @Apa_Id int;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Estado varchar(20), @EsConf bit, @Responsable int, @Creador int, @Titulo nvarchar(150), @Alu_Id int;
        SELECT @Estado = p.Apo_Estado, @EsConf = p.Apo_EsConfidencial, @Responsable = p.Usu_IdResponsable,
               @Creador = p.Apo_UsuarioRegistra, @Titulo = p.Apo_Titulo, @Alu_Id = p.Alu_Id
        FROM app.tbPlanesApoyo p WITH (UPDLOCK, HOLDLOCK)
        JOIN app.FN_PlanesApoyo_Visibles(1, @VerConfidenciales, @Usuario) v ON v.Apo_Id = p.Apo_Id
        WHERE p.Apo_Id = @Apo_Id;

        IF @Estado IS NULL
            THROW 50088, N'El plan ya no existe o no lo puede ver.', 1;
        IF @Estado IN ('completado','cancelado')
            THROW 50089, N'Este plan ya terminó. Reábralo antes de agregar un paso.', 1;
        IF app.FN_PlanApoyo_PodriaLeer(@EsConf, @Responsable, @Creador, @Usu_IdResponsable) = 0
            THROW 50091, N'El plan es confidencial y esa persona no lo puede ver. Asigne el paso a quien lleva el plan o a alguien con permiso para ver planes confidenciales.', 1;

        INSERT INTO app.tbPlanesApoyoAcciones
            (Apo_Id, Apa_Descripcion, Apa_FechaLimite, Usu_IdResponsable, Apa_UsuarioRegistra, Apa_FechaRegistra)
        VALUES (@Apo_Id, @Apa_Descripcion, @Apa_FechaLimite, @Usu_IdResponsable, @Usuario, @Ahora);
        SET @Apa_Id = CAST(SCOPE_IDENTITY() AS int);

        IF @Usu_IdResponsable <> ISNULL(@Usuario, 0)
            INSERT INTO app.tbNotificaciones (Usu_Id, Not_Titulo, Not_Mensaje, Not_Tipo, Not_EsLeida, Not_UrlDestino,
                                              Not_FechaEnvio, Not_EsEliminado, Not_UsuarioRegistra, Not_FechaRegistra)
            SELECT @Usu_IdResponsable, 'Tiene un paso en un plan de apoyo',
                   LEFT(CONCAT(N'«', @Apa_Descripcion, N'» para el ', CONVERT(varchar(10), @Apa_FechaLimite, 103),
                               N', en el plan de apoyo de ', CONCAT_WS(N' ', p.Per_PrimerNombre, p.Per_ApellidoPaterno), N'.'), 500),
                   'I', 0, CONCAT('/PlanesApoyo/Plan/', @Apo_Id), @Ahora, 0, ISNULL(@Usuario, @Usu_IdResponsable), @Ahora
            FROM app.tbAlumnos al JOIN app.tbPersonas p ON p.Per_Id = al.Per_Id
            WHERE al.Alu_Id = @Alu_Id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT @Apa_Id AS Apa_Id;
END
GO

-- Marcar un paso como hecho. Quien no gestiona planes solo marca SUS pasos. Un paso ya hecho
-- conserva la fecha en que se hizo primero (como Skuul).
CREATE OR ALTER PROCEDURE app.PR_tbPlanesApoyoAcciones_Completar
    @Apo_Id            int,
    @Apa_Id            int,
    @Usuario           int = NULL,
    @PuedeGestionar    bit = 0,
    @VerConfidenciales bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    DECLARE @Ahora datetime2(0) = app.FN_AhoraHonduras();

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Bloquea el plan: si a la vez alguien lo completa o cancela, no se marca un paso en un plan ya cerrado.
        DECLARE @Estado varchar(20) = (
            SELECT p.Apo_Estado
            FROM app.tbPlanesApoyo p WITH (UPDLOCK, HOLDLOCK)
            JOIN app.FN_PlanesApoyo_Visibles(ISNULL(@PuedeGestionar, 0), @VerConfidenciales, @Usuario) v ON v.Apo_Id = p.Apo_Id
            WHERE p.Apo_Id = @Apo_Id);
        IF @Estado IS NULL
            THROW 50088, N'El plan ya no existe o no lo puede ver.', 1;
        IF @Estado IN ('completado','cancelado')
            THROW 50089, N'Este plan ya terminó. Reábralo antes de cambiar sus pasos.', 1;

        DECLARE @Responsable int, @Hecha datetime2(0), @Existe bit = 0;
        SELECT @Existe = 1, @Responsable = a.Usu_IdResponsable, @Hecha = a.Apa_FechaHecha
        FROM app.tbPlanesApoyoAcciones a WITH (UPDLOCK, HOLDLOCK)
        WHERE a.Apa_Id = @Apa_Id AND a.Apo_Id = @Apo_Id AND a.Apa_EsEliminado = 0;

        IF @Existe = 0
            THROW 50097, N'El paso ya no existe.', 1;
        IF ISNULL(@PuedeGestionar, 0) = 0 AND (@Responsable IS NULL OR @Responsable <> ISNULL(@Usuario, -1))
            THROW 50080, N'Solo puede marcar los pasos que tiene asignados.', 1;

        IF @Hecha IS NULL
            UPDATE app.tbPlanesApoyoAcciones
            SET Apa_FechaHecha = @Ahora, Apa_UsuarioHecha = @Usuario, Apa_UsuarioModifica = @Usuario, Apa_FechaModifica = @Ahora
            WHERE Apa_Id = @Apa_Id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT @Apa_Id AS Apa_Id;
END
GO

-- Quitar un paso pendiente (borrado lógico). Los pasos hechos se quedan como historia.
CREATE OR ALTER PROCEDURE app.PR_tbPlanesApoyoAcciones_Quitar
    @Apo_Id            int,
    @Apa_Id            int,
    @Usuario           int = NULL,
    @PuedeGestionar    bit = 0,
    @VerConfidenciales bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF ISNULL(@PuedeGestionar, 0) = 0
        THROW 50080, N'No tiene permiso para quitar pasos de un plan de apoyo.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Estado varchar(20) = (
            SELECT p.Apo_Estado
            FROM app.tbPlanesApoyo p WITH (UPDLOCK, HOLDLOCK)
            JOIN app.FN_PlanesApoyo_Visibles(1, @VerConfidenciales, @Usuario) v ON v.Apo_Id = p.Apo_Id
            WHERE p.Apo_Id = @Apo_Id);
        IF @Estado IS NULL
            THROW 50088, N'El plan ya no existe o no lo puede ver.', 1;
        IF @Estado IN ('completado','cancelado')
            THROW 50089, N'Este plan ya terminó. Reábralo antes de cambiar sus pasos.', 1;
        IF NOT EXISTS (SELECT 1 FROM app.tbPlanesApoyoAcciones WHERE Apa_Id = @Apa_Id AND Apo_Id = @Apo_Id AND Apa_EsEliminado = 0)
            THROW 50097, N'El paso ya no existe.', 1;
        IF EXISTS (SELECT 1 FROM app.tbPlanesApoyoAcciones WHERE Apa_Id = @Apa_Id AND Apa_FechaHecha IS NOT NULL)
            THROW 50097, N'Un paso hecho no se quita: queda como parte de la historia del plan.', 1;

        UPDATE app.tbPlanesApoyoAcciones
        SET Apa_EsEliminado = 1, Apa_UsuarioModifica = @Usuario, Apa_FechaModifica = app.FN_AhoraHonduras()
        WHERE Apa_Id = @Apa_Id AND Apo_Id = @Apo_Id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT @Apa_Id AS Apa_Id;
END
GO

-- Escribir una nota de seguimiento (no se edita después). Quien puede leer el plan y el plan sigue abierto.
CREATE OR ALTER PROCEDURE app.PR_tbPlanesApoyoNotas_Agregar
    @Apo_Id            int,
    @Apn_Texto         nvarchar(max),
    @Usuario           int = NULL,
    @PuedeGestionar    bit = 0,
    @VerConfidenciales bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET @Apn_Texto = LTRIM(RTRIM(ISNULL(@Apn_Texto, N'')));

    IF @Apn_Texto = N''
        THROW 50098, N'Escriba la nota.', 1;
    IF LEN(@Apn_Texto) > 5000
        THROW 50098, N'La nota admite hasta 5000 caracteres.', 1;

    SET XACT_ABORT ON;
    DECLARE @Apn_Id int;

    BEGIN TRY
        BEGIN TRANSACTION;

        -- Bloquea el plan: si a la vez alguien lo completa o cancela, la nota no entra en un plan ya cerrado.
        DECLARE @Estado varchar(20) = (
            SELECT p.Apo_Estado
            FROM app.tbPlanesApoyo p WITH (UPDLOCK, HOLDLOCK)
            JOIN app.FN_PlanesApoyo_Visibles(ISNULL(@PuedeGestionar, 0), @VerConfidenciales, @Usuario) v ON v.Apo_Id = p.Apo_Id
            WHERE p.Apo_Id = @Apo_Id);
        IF @Estado IS NULL
            THROW 50088, N'El plan ya no existe o no lo puede ver.', 1;
        IF @Estado IN ('completado','cancelado')
            THROW 50089, N'Este plan ya terminó. Reábralo antes de escribir una nota.', 1;

        INSERT INTO app.tbPlanesApoyoNotas (Apo_Id, Apn_Texto, Apn_Usuario, Apn_Fecha)
        VALUES (@Apo_Id, @Apn_Texto, @Usuario, app.FN_AhoraHonduras());
        SET @Apn_Id = CAST(SCOPE_IDENTITY() AS int);

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT @Apn_Id AS Apn_Id;
END
GO

-- Eliminar un borrador (borrado lógico). Un plan que ya arrancó se cancela, no se elimina.
CREATE OR ALTER PROCEDURE app.PR_tbPlanesApoyo_Eliminar
    @Apo_Id            int,
    @Usuario           int = NULL,
    @PuedeGestionar    bit = 0,
    @VerConfidenciales bit = 0
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;
    IF ISNULL(@PuedeGestionar, 0) = 0
        THROW 50080, N'No tiene permiso para eliminar planes de apoyo.', 1;

    BEGIN TRY
        BEGIN TRANSACTION;

        DECLARE @Estado varchar(20) = (
            SELECT p.Apo_Estado
            FROM app.tbPlanesApoyo p WITH (UPDLOCK, HOLDLOCK)
            JOIN app.FN_PlanesApoyo_Visibles(1, @VerConfidenciales, @Usuario) v ON v.Apo_Id = p.Apo_Id
            WHERE p.Apo_Id = @Apo_Id);
        IF @Estado IS NULL
            THROW 50088, N'El plan ya no existe o no lo puede ver.', 1;
        IF @Estado <> 'borrador'
            THROW 50099, N'Solo se elimina un borrador. Un plan que ya arrancó se cancela con un motivo.', 1;

        UPDATE app.tbPlanesApoyo
        SET Apo_EsEliminado = 1, Apo_UsuarioModifica = @Usuario, Apo_FechaModifica = app.FN_AhoraHonduras()
        WHERE Apo_Id = @Apo_Id;

        COMMIT TRANSACTION;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;
        THROW;
    END CATCH;

    SELECT @Apo_Id AS Apo_Id, 'eliminado' AS Apo_Estado, 0 AS Apo_Version;
END
GO

/* ---------------------------------------------------------------- Pantallas y permisos */
--   Planes de apoyo            = directorio y detalle (admin, director, Docente). El docente solo
--                                ve los planes donde es responsable o tiene un paso; marca SUS pasos
--                                y escribe notas en ellos.
--   Gestionar planes de apoyo  = ver todos, crear, editar, cambiar estado, pasos de cualquiera (admin, director)
--   Ver planes confidenciales  = leer los planes confidenciales aunque no sean suyos (admin, director)
DECLARE @Pantallas TABLE (Nombre nvarchar(100), Roles nvarchar(200));
INSERT INTO @Pantallas VALUES
    (N'Planes de apoyo',           N'|admin|director|docente|'),
    (N'Gestionar planes de apoyo', N'|admin|director|'),
    (N'Ver planes confidenciales', N'|admin|director|');

INSERT INTO seguridad.tbPantallas (Pan_Descripcion, Pan_Estado, Pan_EsEliminado, Pan_Grupo)
SELECT x.Nombre, 1, 0, 'Academico'
FROM @Pantallas x
WHERE NOT EXISTS (SELECT 1 FROM seguridad.tbPantallas p WHERE p.Pan_Descripcion = x.Nombre);

INSERT INTO seguridad.tbRolesPantallas (Rol_Id, Pan_Id)
SELECT r.Rol_Id, p.Pan_Id
FROM seguridad.tbPantallas p
JOIN @Pantallas x ON x.Nombre = p.Pan_Descripcion
JOIN seguridad.tbRoles r ON r.Rol_EsEliminado = 0
                        AND x.Roles LIKE N'%|' + LOWER(LTRIM(RTRIM(r.Rol_Descripcion))) + N'|%'
WHERE NOT EXISTS (SELECT 1 FROM seguridad.tbRolesPantallas y WHERE y.Rol_Id = r.Rol_Id AND y.Pan_Id = p.Pan_Id);
GO
